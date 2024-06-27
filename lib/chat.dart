import 'package:flutter/material.dart';
//import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:keras_mobile_chatbot/function_call.dart';
import 'package:keras_mobile_chatbot/chat_bubble.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatHome extends StatelessWidget {
  const ChatHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('gemini-1.5-pro-latest', style: TextStyle(fontSize: 25)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {
              print('Search button');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              semanticLabel: 'settings',
            ),
            onPressed: () {
              print('settings button');
            },
          ),
        ],
      ),
      body: ChatUI(),
    );
  }
}

class ChatUI extends StatefulWidget {
  @override
  _ChatUIState createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  late final stt.SpeechToText _speech;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  Map<int, dynamic> _extendMessageList = {};

  @override
  void initState() {
    super.initState();
    ToolConfig toolConfig = ToolConfig(functionCallingConfig: FunctionCallingConfig(mode: FunctionCallingMode.auto));
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: dotenv.get("api_key"),
      tools: [
        Tool(functionDeclarations: normalFunctionCallTool)
      ],
      toolConfig: toolConfig
    );
    _chatSession = _model.startChat();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    final history = _chatSession.history.toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                final content = history[index];
                final text = 
                  content.parts.whereType<TextPart>().map<String>((e) => e.text).join('');
                if (text.isEmpty) {
                  return SizedBox.shrink();
                } else {
                  if (content.role == 'user') {
                    return SentMessageScreen(message: text, iconPath: 'assets/icons/14/9.png',);
                  }
                  else {
                    Map<String, dynamic> curExtendMessage = {};
                    if (_extendMessageList.containsKey(index)) {
                     curExtendMessage = _extendMessageList[index];
                    }              
                    return ReceivedMessageScreen(message: text, extendMessage: curExtendMessage, iconPath: 'assets/icons/11/11.png',);
                  }
                }
              },
              itemCount: history.length,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    decoration: textFieldDecoration(),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: _textController,
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                if (!_loading)
                  IconButton(
                    onPressed: () async {
                      _sendChatMessage(_textController.text);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void startListening() {
    _speech.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      suffixIcon: IconButton(
        icon: Icon(Icons.mic),
        onPressed: () {
          startListening();
        },
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      var response = await _chatSession.sendMessage(
        Content.text(message),
      );
      Map<String, dynamic> curExtendMessage = {};
      final functionCalls = response.functionCalls.toList();
      if (functionCalls.isNotEmpty) {
        final functionCall = functionCalls.first;
        final result = switch (functionCall.name) {
          // Forward arguments to the hypothetical API.
          'getCurrentTime' => await getCurrentTime(),
          'getCurrentLocation' => await getCurrentLocation(),
          'getDirections' => await getDirections(functionCall.args),
          'getPlaces' => await getPlaces(functionCall.args),
          // Throw an exception if the model attempted to call a function that was
          // not declared.
          _ => throw UnimplementedError(
              'Function not implemented: ${functionCall.name}')
        };
        if(result.isNotEmpty) {
          String resultValue = result['result'];
          if(result.containsKey('show_map')) {
            curExtendMessage = {'show_map': result['show_map']};
          }
          Map<String, dynamic> responseFunction = {'result': resultValue};
          // Send the result of the function call to the model.
          response = await _chatSession.sendMessage(Content.functionResponse(functionCall.name, responseFunction));
        }
        // Send the response to the model so that it can use the result to generate
        // text for the user.
      }
      // When the model responds with non-null text content, print it.
      if (response.text case final text?) {
        if (curExtendMessage.isNotEmpty && _chatSession.history.isNotEmpty) {
          int index = _chatSession.history.length - 1;
          _extendMessageList[index] = curExtendMessage;
        }
        if(text.isEmpty) {
          _showError('No response from API.');
          return;
        } else {
          setState(() {
            _loading = false;
            _scrollDown();
          });
        }
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}