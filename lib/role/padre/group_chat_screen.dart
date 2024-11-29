import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  final String currentUser = "anon"; // Este valor debería ser el identificador del usuario actual

  final String baseUrl = "http://13.59.36.12:3000/posts/";

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // Obtener todos los mensajes
  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          _messages = jsonDecode(response.body);
        });
      } else {
        _showMessage("Error al obtener los mensajes: ${response.statusCode}");
      }
    } catch (e) {
      _showMessage("Error de red: $e");
    }
  }

  // Crear un nuevo mensaje
  Future<void> _createMessage(String content) async {
    if (content.isEmpty) return;

    // Agregar el mensaje inmediatamente a la lista de mensajes
    final newMessage = {
      'content': content,
      'author': currentUser,
      '_id': DateTime.now().millisecondsSinceEpoch.toString(), // Asignamos un id único temporal
    };
    setState(() {
      _messages.insert(0, newMessage); // Insertar al inicio de la lista
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
        // Si la respuesta no es exitosa, eliminamos el mensaje
        setState(() {
          _messages.removeAt(0); // Remover el mensaje en caso de error
        });
      }
    } catch (e) {
      _showMessage("Error de red: $e");
      // Si ocurre un error de red, eliminamos el mensaje
      setState(() {
        _messages.removeAt(0); // Remover el mensaje en caso de error de red
      });
    }
  }

  // Eliminar un mensaje
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foro"),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message['author'] == currentUser;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Color(0xFF203F8E) : Colors.grey[300],
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
    );
  }
}
