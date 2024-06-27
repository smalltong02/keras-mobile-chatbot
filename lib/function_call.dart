import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:location/location.dart' as locationpkg;
import 'package:geocode/geocode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:neom_maps_services/directions.dart';
//import 'package:neom_maps_services/distance.dart';
import 'package:neom_maps_services/geocoding.dart';
//import 'package:neom_maps_services/geolocation.dart';
import 'package:neom_maps_services/places.dart';
//import 'package:neom_maps_services/staticmap.dart';
//import 'package:neom_maps_services/timezone.dart';

Future<Tuple2<double, double>> getGeocode(String address) async {
  String geoKey = dotenv.get("geocode_key");
  GeoCode geoCode = GeoCode(apiKey: geoKey);

  try {
    Coordinates coordinates = await geoCode.forwardGeocoding(
        address: address);

    double lat = coordinates.latitude ?? 0.0;
    double lng = coordinates.longitude ?? 0.0;
    return Tuple2(lat, lng);
  } catch (e) {
    return Tuple2(0.0, 0.0);
  }
}

Future<String> getReverseGeocode(double latitude, double longitude) async {
  GeoCode geoCode = GeoCode();

  try {
    final address = await geoCode.reverseGeocoding(
        latitude: latitude, longitude: longitude);

    return address.toString();
  } catch (e) {
    return "";
  }
}

Future<Map<String, dynamic>> getCurrentTime() async {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  return {
    'result': formattedTime,
  };
}

Future<Tuple2<double, double>> getLocation(String? address) async {
  if (address == null) {
    locationpkg.Location location = new locationpkg.Location();
    bool serviceEnabled;
    locationpkg.PermissionStatus permissionGranted;
    locationpkg.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Tuple2(0.0, 0.0);
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == locationpkg.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != locationpkg.PermissionStatus.granted) {
        return Tuple2(0.0, 0.0);
      }
    }

    locationData = await location.getLocation();
    return Tuple2(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
  } else {
    return getGeocode(address);
  }
}

Future<Map<String, dynamic>> getCurrentLocation() async {
  Tuple2<double, double> location = await getLocation(null);

  final result = await getReverseGeocode(location.item1, location.item2);
  if(result.isEmpty) {
    return {
        'result': "Unknown Address!",
    };
  }
  return {
    'result': result,
    'show_map': {
      'object': "position",
      'position': {
        'lat': location.item1,
        'lng': location.item2,
      },
    }
  };
}

TravelMode GetTravelModel(String mode) {
  switch (mode) {
    case "driving":
      return TravelMode.driving;
    case "walking":
      return TravelMode.walking;
    case "bicycling":
      return TravelMode.bicycling;
    case "transit":
      return TravelMode.transit;
    default:
      return TravelMode.driving;
  }
}

Future<Map<String, dynamic>> getDirections(Map<String, Object?> arguments, ) async {
  String start = arguments['start'] as String? ?? "";
  String end = arguments['end'] as String? ?? "";
  String mode = arguments['mode'] as String? ?? "";

  String apiKey = dotenv.get("search_key");
  TravelMode travelMode = GetTravelModel(mode);
  GoogleMapsDirections directions = GoogleMapsDirections(apiKey: apiKey);
  DirectionsResponse response = await directions.directionsWithAddress(start, end, travelMode: travelMode,);
  if(response.isOkay) {
    Route route = response.routes[0];
    String summary = route.summary;
    String startAddress = route.legs[0].startAddress;
    Location startLocation = route.legs[0].startLocation;
    String endAddress = route.legs[0].endAddress;
    Location endLocation = route.legs[0].endLocation;
    String distance = route.legs[0].distance.text;
    String duration = route.legs[0].duration.text;
    String overviewPolyline = route.overviewPolyline.points;
    String resultStr = "Starting from '$startAddress', ending at '$endAddress'.the total distance is $distance, and the total time is $duration.The optimal route is to take the '$summary'";
    return {
      'result': resultStr,
      'show_map': {
        'object': "polyline",
        'start_address': startAddress,
        'start_location': startLocation,
        'end_address': endAddress,
        'end_location': endLocation,
        'distance': distance,
        'duration': duration,
        'overview_polyline': overviewPolyline,
        'summary': summary,
      }
    };
  }
  return {
    'result': "Unknown Directions!",
  };
}

String GetPrice(PriceLevel level) {
  switch (level) {
    case PriceLevel.free:
      return "Free";
    case PriceLevel.inexpensive:
      return "Inexpensive";
    case PriceLevel.moderate:
      return "Moderate";
    case PriceLevel.expensive:
      return "Expensive";
    case PriceLevel.veryExpensive:
      return "Very Expensive";
    default:
      return "Unknown";
  }
}

Future<Map<String, dynamic>> getPlaces(Map<String, Object?> arguments, ) async {
  String query = arguments['query'] as String? ?? "";
  String location = arguments['location'] as String? ?? "";
  int radius = arguments['mode'] as int? ?? 100;

  String apiKey = dotenv.get("search_key");
  final geocoding = GoogleMapsGeocoding(apiKey: apiKey);
  Location position = Location(lat: 0, lng: 0);
  if (location.isEmpty) {
    Tuple2<double, double> pos = await getLocation(null);
    position = Location(lat: pos.item1, lng: pos.item2);
  } else {
    GeocodingResponse geoResponse = await geocoding.searchByAddress(location);
    if(geoResponse.isOkay) {
      position = geoResponse.results[0].geometry.location;
    } else {
      return {
        'result': "Unknown Address!",
      };
    }
  }

  final places = GoogleMapsPlaces(apiKey: apiKey);
  PlacesSearchResponse placeResponse = await places.searchByText(query, location: position, radius: radius,);
  if(placeResponse.isOkay) {
    List<PlacesSearchResult> results = placeResponse.results;
    List<Map<String, dynamic>> placesList = [];
    String resultStr = "";
    for(PlacesSearchResult result in results) {
      String name = result.name;
      num rating = result.rating ?? 0.0;
      PriceLevel level = result.priceLevel ?? PriceLevel.free;
      String levelStr = GetPrice(level);
      String address = result.formattedAddress ?? "";
      String placeId = result.placeId;
      String icon = result.icon ?? "";
      Location location_l = result.geometry?.location ?? Location(lat: 0, lng: 0);
      placesList.add(
        {
          'name': name,
          'level': levelStr,
          'address': address,
          'place_id': placeId,
          'icon': icon,
          'location': location_l,
        }
      );
      resultStr += "name: $name \naddress: $address \nrating: $rating \nprice: $level\n\n";
    }
    return {
      'result': resultStr,
      'show_map': {
        'object': "places",
        'position': position,
        'places': placesList,
      }
    };
  }
  return {
    'result': "Unknown Places!",
  }; 
}

final getCurrentTimeFunc = FunctionDeclaration(
    'getCurrentTime',
    'Get the current local time.',
    null
    );
    
final getCurrentLocationFunc = FunctionDeclaration(
    'getCurrentLocation',
    'Get the current location information.',
    null
    );

final getDirectionsFunc = FunctionDeclaration(
    'getDirections',
    'Get the directions from origin to destination.',
    Schema(SchemaType.object, properties: {
      "start": Schema(SchemaType.string, description: "Starting address, When the location is "", it means that you are in the current location."),
      "end": Schema(SchemaType.string, description: "Destination address."),
      "mode": Schema(SchemaType.string, description: "Specifies the mode of transport to use when calculating directions. One of 'driving', 'walking', 'bicycling' or 'transit'."),
    }));

final getPlacesFunc = FunctionDeclaration(
    'getPlaces',
    'Get the places that match the query, such as restaurants, libraries, parks, airports, stores, etc.',
    Schema(SchemaType.object, properties: {
      "query": Schema(SchemaType.string, description: "The text string on which to search, for example: 'restaurant'."),
      "location": Schema(SchemaType.string, description: "location, When the location is "", it means that you are in the current location."),
      "radius": Schema(SchemaType.number, description: "Distance in meters within which to bias results."),
    }));


final normalFunctionCallTool = [getCurrentTimeFunc, getCurrentLocationFunc, getDirectionsFunc, getPlacesFunc];