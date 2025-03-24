import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiChatbot extends StatefulWidget {
  final String apiKey;
  final Map<String, String>? trainedData;
  final Widget Function(
      BuildContext, List<Map<String, String>>, Function(String))? customUI;

  const GeminiChatbot({
    required this.apiKey,
    this.trainedData,
    this.customUI,
    Key? key,
  }) : super(key: key);

  @override
  _GeminiChatbotState createState() => _GeminiChatbotState();
}

class _GeminiChatbotState extends State<GeminiChatbot> {
  late final GenerativeModel _model;
  List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model =
        GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: widget.apiKey);
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": message});
      _isLoading = true;
    });

    String response =
        widget.trainedData?[message] ?? await _fetchGeminiResponse(message);

    setState(() {
      messages.add({"role": "bot", "text": response});
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<String> _fetchGeminiResponse(String query) async {
    try {
      final content = Content.text(query);
      final response = await _model.generateContent([content]);
      return response.text ?? "No response received.";
    } catch (e) {
      return "Error: $e";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.customUI != null
        ? widget.customUI!(context, messages, sendMessage)
        : _defaultChatUI();
  }

  Widget _defaultChatUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ListTile(
                title: Text(message['text']!,
                    textAlign: message['role'] == 'user'
                        ? TextAlign.end
                        : TextAlign.start),
                tileColor: message['role'] == 'user'
                    ? Colors.blue[100]
                    : Colors.grey[300],
              );
            },
          ),
        ),
        if (_isLoading) LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Ask me anything..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage(_controller.text);
                  _controller.clear();
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
