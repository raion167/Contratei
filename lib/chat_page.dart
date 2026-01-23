import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final Map prestador;
  final Map servico;

  const ChatPage({super.key, required this.prestador, required this.servico});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> mensagens = [
    {
      "texto": "Olá! Gostaria de saber mais sobre o serviço.",
      "isCliente": true,
    },
    {"texto": "Claro! Posso te ajudar 😊", "isCliente": false},
  ];

  void enviarMensagem() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      mensagens.add({"texto": _controller.text.trim(), "isCliente": true});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.prestador["nome"],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.servico["nome_servico"],
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];
                final isCliente = msg["isCliente"];

                return Align(
                  alignment: isCliente
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isCliente ? Colors.orange : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["texto"],
                      style: TextStyle(
                        color: isCliente ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Digite sua mensagem...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.orange),
                  onPressed: enviarMensagem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
