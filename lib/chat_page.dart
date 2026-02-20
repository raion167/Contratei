import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String conversaId;
  final String usuarioDestinoId;
  final String nomeDestino;

  const ChatPage({
    super.key,
    required this.conversaId,
    required this.usuarioDestinoId,
    required this.nomeDestino,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> mensagens = [];
  late final String currentUserId;
  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser!.id;
    carregarMensagens();
    marcarComoLidas();
    escutarMensagens();
  }

  // ==============================
  // CARREGAR MENSAGENS
  // ==============================
  Future<void> carregarMensagens() async {
    final response = await supabase
        .from('mensagens')
        .select()
        .eq('conversa_id', widget.conversaId)
        .order('created_at');

    setState(() {
      mensagens = List<Map<String, dynamic>>.from(response);
    });

    _scrollToBottom();
  }

  // ==============================
  // ESCUTAR TEMPO REAL
  // ==============================
  void escutarMensagens() {
    channel = supabase
        .channel('chat_${widget.conversaId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mensagens',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversa_id',
            value: widget.conversaId,
          ),
          callback: (payload) {
            final novaMensagem = payload.newRecord;

            // evitar duplicar mensagem própria
            if (novaMensagem["remetente_id"] == currentUserId) return;

            setState(() {
              mensagens.add(novaMensagem);
            });

            marcarComoLidas();
            _scrollToBottom();
          },
        )
        .subscribe();
  }

  // ==============================
  // ENVIAR MENSAGEM
  // ==============================
  Future<void> enviarMensagem() async {
    if (_controller.text.trim().isEmpty) return;

    final texto = _controller.text.trim();
    _controller.clear();

    // atualização otimista
    final mensagemLocal = {
      "id": UniqueKey().toString(),
      "conversa_id": widget.conversaId,
      "remetente_id": currentUserId,
      "texto": texto,
      "created_at": DateTime.now().toIso8601String(),
      "lida": false,
    };

    setState(() {
      mensagens.add(mensagemLocal);
    });

    _scrollToBottom();

    await supabase.from('mensagens').insert({
      "conversa_id": widget.conversaId,
      "remetente_id": currentUserId,
      "texto": texto,
      "lida": false,
    });
  }

  // ==============================
  // MARCAR COMO LIDA
  // ==============================
  Future<void> marcarComoLidas() async {
    await supabase
        .from('mensagens')
        .update({'lida': true, 'lida_em': DateTime.now().toIso8601String()})
        .eq('conversa_id', widget.conversaId)
        .neq('remetente_id', currentUserId);
  }

  // ==============================
  // SCROLL
  // ==============================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ==============================
  // DISPOSE
  // ==============================
  @override
  void dispose() {
    if (channel != null) {
      supabase.removeChannel(channel!);
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(widget.nomeDestino, style: const TextStyle(fontSize: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: mensagens.length,
              itemBuilder: (context, index) {
                final msg = mensagens[index];
                final isMine = msg["remetente_id"] == currentUserId;

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.orange : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["texto"],
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black,
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
