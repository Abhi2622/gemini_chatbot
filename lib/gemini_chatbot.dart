library gemini_chatbot;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add({"role": "user", "text": message});
    });

    String response =
        widget.trainedData?[message] ?? await fetchGeminiResponse(message);

    setState(() {
      messages.add({"role": "bot", "text": response});
    });
  }

  Future<String> fetchGeminiResponse(String query) async {
    final url = Uri.parse('https://api.gemini.com/v1/chat');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'prompt': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? "I don't know the answer to that.";
    } else {
      return "Error: Unable to fetch response.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.customUI != null
        ? widget.customUI!(context, messages, sendMessage)
        : defaultChatUI();
  }

  Widget defaultChatUI() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
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
        Padding(
          padding: const EdgeInsets.all(8.0),
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
