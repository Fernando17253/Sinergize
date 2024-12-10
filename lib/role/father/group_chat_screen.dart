import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String currentUser = "anon";  // Se inicializa con un valor por defecto
  final String baseUrl = "http://13.59.36.12:3000/posts/";
  List<dynamic> _messages = [];

  late StreamController<List<dynamic>> _messageStreamController;
  late Timer _messageTimer;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageStreamController = StreamController<List<dynamic>>.broadcast();
    _scrollController = ScrollController();
    _fetchMessages();
    
    // Obtener el correo del usuario desde SharedPreferences
    _getUserEmail();

    _messageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages();
    });
  }

  // Obtener el correo del usuario desde SharedPreferences
  Future<void> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('user_email') ?? "anon";  // Lee el correo guardado o usa "anon"
    });
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          _messages = jsonDecode(response.body);
        });

        _messageStreamController.sink.add(_messages);
        _scrollToBottom();
      } else {
        _showMessage("Error al obtener los mensajes: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Error de red: $e");
    }
  }

  Future<void> _createMessage(String content) async {
    if (content.isEmpty) return;

    final newMessage = {
      'content': content,
      'author': currentUser,
      '_id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    setState(() {
      _messages.insert(0, newMessage);
    });

    final Map<String, String> body = {"content": content, "author": currentUser};

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 201) {
        _showMessage("Error al enviar el mensaje: ${response.statusCode}");
        setState(() {
          _messages.removeAt(0); 
        });
      } else {
        _messageStreamController.sink.add(_messages);
        _scrollToBottom();
      }
    } catch (e) {
      _showMessage("Error de red: $e");
      setState(() {
        _messages.removeAt(0);
      });
    }

    // Limpiar el campo de texto después de enviar el mensaje
    _messageController.clear();
  }

  Future<void> _deleteMessage(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl$id"));

      if (response.statusCode == 200) {
        _fetchMessages();
      } else {
        _showMessage("Error al eliminar el mensaje: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Error de red: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _messageStreamController.close();
    _messageTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFE0FFFF),
              Color(0xFF87CEEB),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: _messageStreamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay mensajes aún.'));
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message['author'] == currentUser;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? const Color(0xFF203F8E) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                            child: Column(
                              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Autor: ${message['author']}",
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Escribe tu mensaje...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF203F8E)),
                    onPressed: () => _createMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
