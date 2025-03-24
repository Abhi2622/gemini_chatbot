A Flutter package that integrates Google Gemini AI to create a chatbot with customizable UI and trained responses.

# Features

* Uses Google Gemini AI for chatbot responses
* Supports predefined trained responses
* Customizable UI for chat messages
* Simple and clean UI design
* Easy to integrate into any Flutter application

## Installation

Add this to your package's pubspec.yaml file:

    yaml

    dependencies:
       gemini_chatbot: latest_version

Then, run:


    flutter pub get



## Basic Usage

    import 'package:flutter/material.dart';
    import 'package:gemini_chatbot/gemini_chatbot.dart';

    void main() {
    runApp(const MyApp());
    }

    class MyApp extends StatelessWidget {

    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
     return MaterialApp(
      home: NetworkChecker(
       child: Scaffold(
        appBar: AppBar(title: const Text('Gemini Chatbot')),
         body: GeminiChatbot(
          apiKey: "YOUR_GEMINI_API_KEY", // Replace with your actual API key
        ),
         ),
        );
      }
     }


## Custom Retry Screen

You can customize the chat UI using the customUI parameter:

    GeminiChatbot(
      apiKey: "YOUR_GEMINI_API_KEY",
      trainedData: {
        "Hello": "Hi there! How can I assist you today?",
        "How are you?": "I'm just a chatbot, but I'm doing great!"
      },
    customUI: (context, messages, sendMessage) {
      return Column(
       children: [
        Expanded(
         child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
           final message = messages[index];
           return Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
             color: message['role'] == 'user' ? Colors.blue[300] : Colors.grey[300],
             borderRadius: BorderRadius.circular(10),
            ),
           alignment: message['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
           child: Text(
            message['text']!,
            style: TextStyle(fontSize: 16, color: Colors.black),
           ),
          );
         },
        ),
       ),
      ],
     );
     },
    ),

License
This project is licensed under the MIT License - see the LICENSE file for details.
Contributing
Contributions are welcome! Please feel free to submit a Pull Request.