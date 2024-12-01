import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUser = "anon"; // Este valor debería ser el identificador del usuario actual
  final String baseUrl = "http://13.59.36.12:3000/posts/";
  List<dynamic> _messages = [];

  late StreamController<List<dynamic>> _messageStreamController;
  late Timer _messageTimer;

  @override
  void initState() {
    super.initState();

    _messageStreamController = StreamController<List<dynamic>>.broadcast();
    _fetchMessages();  // Inicializa el primer fetch para cargar los mensajes

    // Hacer polling cada 5 segundos para obtener nuevos mensajes
    _messageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchMessages();
    });
  }

  // Obtener todos los mensajes
  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          _messages = jsonDecode(response.body);
        });

        // Enviar los mensajes al StreamController para actualizar la UI
        _messageStreamController.sink.add(_messages);
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

    final newMessage = {
      'content': content,
      'author': currentUser,
      '_id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    setState(() {
      _messages.insert(0, newMessage);  // Insertar el mensaje al inicio
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
          _messages.removeAt(0);  // Eliminar el mensaje si la creación falla
        });
      } else {
        // Si el mensaje es creado correctamente, lo actualizamos en el stream
        _messageStreamController.sink.add(_messages);
      }
    } catch (e) {
      _showMessage("Error de red: $e");
      setState(() {
        _messages.removeAt(0);  // Eliminar el mensaje si ocurre un error de red
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

  // Mostrar mensajes de error
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _messageStreamController.close();
    _messageTimer.cancel();
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
              Color(0xFFFFFFFF), // Blanco
              Color(0xFFE0FFFF), // Azul claro
              Color(0xFF87CEEB), // Azul más fuerte
            ],
          ),
        ),
        child: Column(
          children: [
            // Eliminar el AppBar y colocar el contenido directamente en el body
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: _messageStreamController.stream,  // Escuchar el Stream de mensajes
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message['author'] == currentUser;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
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
