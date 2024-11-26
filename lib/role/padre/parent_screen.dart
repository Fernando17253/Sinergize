import 'package:flutter/material.dart';
import 'package:spinkeeper/server/local_data_store.dart';
import 'package:spinkeeper/role/padre/child_registration_screen.dart';

class ParentScreen extends StatefulWidget {
  final int parentId;

  const ParentScreen({required this.parentId, super.key});

  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final LocalDataStore _localDataStore = LocalDataStore();

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    await _localDataStore.loadChildren(widget.parentId);
    setState(() {}); // Actualiza la UI con los datos cargados
  }

  @override
  Widget build(BuildContext context) {
    final children = _localDataStore.children;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijos Registrados'),
        backgroundColor: const Color(0xFF203F8E),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildRegistrationScreen(parentId: widget.parentId),
                ),
              );
              _loadChildren(); // Recargar los datos después de registrar un hijo
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF203F8E),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            child: const Text('Registrar Hijo', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Expanded(
            child: children.isEmpty
                ? const Center(
                    child: Text(
                      'No hay hijos registrados.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return ListTile(
                        title: Text(child['name']),
                        subtitle: Text('Fecha de nacimiento: ${child['birthdate']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _localDataStore.removeChild(child['id']);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
