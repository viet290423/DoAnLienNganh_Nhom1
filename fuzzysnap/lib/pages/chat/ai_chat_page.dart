import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIChatDetailScreen extends StatefulWidget {
  final String userName;
  final String userImage;

  const AIChatDetailScreen(
      {super.key, required this.userName, required this.userImage});

  @override
  _AIChatDetailScreenState createState() => _AIChatDetailScreenState();
}

class _AIChatDetailScreenState extends State<AIChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesString = prefs.getString('messages');
    if (messagesString != null) {
      setState(() {
        _messages.addAll(
            List<Map<String, dynamic>>.from(jsonDecode(messagesString)));
      });
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('messages', jsonEncode(_messages));
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final timestamp = DateTime.now();
      setState(() {
        _messages.add({
          "type": "sent",
          "text": _controller.text,
          "timestamp": timestamp.toIso8601String()
        });
      });

      String userMessage = _controller.text;
      _controller.clear();

      String response = await callAIChatAPI(userMessage);
      response = response.trim(); // Loại bỏ các ký tự dòng mới không cần thiết
      setState(() {
        _messages.add({
          "type": "received",
          "text": response,
          "timestamp": DateTime.now().toIso8601String()
        });
      });

      _saveMessages();
    }
  }

  Future<String> callAIChatAPI(String input) async {
    final apiKey = 'AIzaSyANTcBLr4piaR1h8OB6BSgWD97aBx2rmVg';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": input}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 1,
        "topK": 64,
        "topP": 0.95,
        "maxOutputTokens": 8192,
        "responseMimeType": "text/plain"
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['candidates'] != null &&
          jsonResponse['candidates'].isNotEmpty) {
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'No response from AI';
      }
    } else {
      return 'Failed to get response from AI';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
              backgroundImage: AssetImage(widget.userImage),
            ),
            SizedBox(width: 10),
            Text(
              widget.userName,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final showTime = index == 0 ||
                          (index > 0 &&
                              DateTime.parse(_messages[index - 1]['timestamp'])
                                      .difference(
                                          DateTime.parse(message['timestamp']))
                                      .inMinutes
                                      .abs() >
                                  1);
                      return Column(
                        crossAxisAlignment: message['type'] == 'received'
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          if (showTime)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(
                                DateFormat('HH:mm').format(
                                    DateTime.parse(message['timestamp'])),
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          message['type'] == 'received'
                              ? buildReceivedMessage(message['text'])
                              : buildSentMessage(message['text']),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                8.0, 8.0, 8.0, 24.0), // Thêm khoảng cách với viền dưới
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50, // Chiều cao của TextField
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        labelText: 'Type a message...',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                      ),
                      style: TextStyle(
                          fontSize: 16), // Giảm kích thước chữ trong TextField
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_sharp),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReceivedMessage(String message) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).colorScheme.onSecondary),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget buildSentMessage(String message) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: TextStyle(
              color: Theme.of(context).colorScheme.surface, fontSize: 18),
        ),
      ),
    );
  }
}
