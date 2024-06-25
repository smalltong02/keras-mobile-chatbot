import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Map<String, String>> getCurrentTime() async {
  DateTime now = DateTime.now();
  String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  return {
    'currentTime': formattedTime,
  };
}



final normalFunctionCallTool = FunctionDeclaration(
    'getCurrentTime',
    'Get the current local time.',
    Schema(SchemaType.object, properties: {
    }));