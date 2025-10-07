import 'package:contratei/cadastrar_servico_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lista_prestadores_page.dart';
import 'prestador_detalhes_page.dart';
import 'basescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contratei',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthPage(),
    );
  }
}

//=============== MODELO TESTE DE USUARIO
class Usuario {
  final int id;
  String nome;
  String email;
  String cpf;
  String telefone;
  String tipoUsuario;
  String? ocupacao;
  String? fotoPath;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.tipoUsuario,
    this.ocupacao,
    this.fotoPath,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: int.parse(json["id"].toString()),
      nome: json["nome"],
      email: json["email"],
      cpf: json["cpf"],
      telefone: json["telefone"],
      tipoUsuario: json["tipoUsuario"],
      ocupacao: json["ocupacao"],
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

// ======================== PAGINA DE LOGIN
class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showLogin ? "Entrar" : "Cadastrar"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              showLogin ? const LoginForm() : const CadastroScreen(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    showLogin = !showLogin;
                  });
                },
                child: Text(
                  showLogin
                      ? "Não tem conta? Cadastre-se"
                      : "Já tem conta? Entre",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  List<bool> isSelected = [true, false];

  Future<void> login() async {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";

    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha todos os campos")));
      return;
    }

    try {
      var url = Uri.parse("http://localhost:8080/app/login.php"); // Flutter Web

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "senha": senhaController.text.trim(),
          "tipoUsuario": tipoUsuario,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));

          // dados do usuário
          var user = data['usuario'];
          Usuario usuario = Usuario(
            id: user['id'],
            nome: user['nome'],
            email: user['email'],
            cpf: user['cpf'],
            telefone: user['telefone'],
            tipoUsuario: user['tipoUsuario'],
            ocupacao: user['ocupacao'],
          );

          // 🔹 Abrir BaseScreen em vez do HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BaseScreen(usuario: usuario)),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Erro no servidor")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro de conexão: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: senhaController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Senha"),
        ),
        const SizedBox(height: 20),
        const Text("Selecione o tipo de usuário:"),
        const SizedBox(height: 10),
        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(12),
            fillColor: Colors.green,
            selectedColor: Colors.white,
            color: Colors.black,
            isSelected: isSelected,
            onPressed: (index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Contratante"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Prestador"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(onPressed: login, child: const Text("Entrar")),
        ),
      ],
    );
  }
}

// ============================= CADASTRO ======================================
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  String? ocupacaoSelecionada; // valor escolhido no dropdown
  List<String> categorias = []; // lista carregada do banco

  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    fetchCategorias(); // carrega categorias ao abrir tela
  }

  Future<void> fetchCategorias() async {
    try {
      var url = Uri.parse("http://localhost:8080/app/getCategorias.php");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            categorias = List<String>.from(data["categorias"]);
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar categorias: $e");
    }
  }

  Future<void> cadastrarUsuario() async {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";

    try {
      var url = Uri.parse("http://localhost:8080/app/cadastro.php");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nomeController.text.trim(),
          "email": emailController.text.trim(),
          "senha": senhaController.text.trim(),
          "cpf": cpfController.text.trim(),
          "telefone": telefoneController.text.trim(),
          "tipoUsuario": tipoUsuario,
          "ocupacao": tipoUsuario == "Prestador"
              ? ocupacaoSelecionada ?? ""
              : "",
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      var data = jsonDecode(response.body);

      if (data["success"]) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✅ ${data["message"]}")));
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ ${data["message"]}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ToggleButtons(
            borderRadius: BorderRadius.circular(12),
            isSelected: isSelected,
            onPressed: (index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Contratante"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Prestador"),
              ),
            ],
          ),
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: "Nome"),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Senha"),
          ),
          TextField(
            controller: cpfController,
            decoration: const InputDecoration(labelText: "CPF"),
          ),
          TextField(
            controller: telefoneController,
            decoration: const InputDecoration(labelText: "Telefone"),
          ),

          // 🔽 Dropdown carregado do banco
          if (tipoUsuario == "Prestador")
            categorias.isEmpty
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: ocupacaoSelecionada,
                    hint: const Text("Selecione a categoria"),
                    items: categorias
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        ocupacaoSelecionada = value;
                      });
                    },
                  ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: cadastrarUsuario,
            child: const Text("Cadastrar"),
          ),
        ],
      ),
    );
  }
}

//========================= PÁGINA INICIAL =====================================
class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<String> allCategorias = []; // 🔽 Agora vem do banco
  List<String> filteredCategorias = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCategorias();
  }

  Future<void> fetchCategorias() async {
    try {
      var url = Uri.parse("http://localhost:8080/app/getCategorias.php");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"]) {
          setState(() {
            allCategorias = List<String>.from(data["categorias"]);
            filteredCategorias = allCategorias;
            loading = false;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar categorias: $e");
    }
  }

  void filterCategorias(String query) {
    setState(() {
      filteredCategorias = allCategorias
          .where((cat) => cat.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página Inicial"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator()) // 🔄 loading
            : Column(
                children: [
                  TextField(
                    onChanged: filterCategorias,
                    decoration: InputDecoration(
                      hintText: "Pesquisar Categorias...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: List.generate(filteredCategorias.length, (
                        index,
                      ) {
                        final categoria = filteredCategorias[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ListaPrestadoresPage(ocupacao: categoria),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                categoria,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

//================== TELA DE PERFIL DO USUÁRIO
class MeuPerfilScreen extends StatelessWidget {
  final Usuario usuario;
  const MeuPerfilScreen({super.key, required this.usuario});
  //=============== MENU LATERAL =======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil"), centerTitle: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(usuario.nome),
              accountEmail: Text(usuario.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 30, color: Colors.green),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Meus Dados"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeusDadosScreen(usuario: usuario),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Formas de Pagamento"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormasPagamentoScreen(usuario: usuario),
                  ),
                );
              },
            ),
            if (usuario.tipoUsuario == "Prestador") ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text("Cadastrar Serviços"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastrarServicoPage(usuario: usuario),
                    ),
                  );
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Histórico de Serviços"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Abrindo Histórico de serviços..."),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Sair"),
              onTap: () async {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          "Selecione uma opção no menu Lateral",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// ========================== MEUS DADOS ==============================================
class MeusDadosScreen extends StatefulWidget {
  final Usuario usuario;

  const MeusDadosScreen({super.key, required this.usuario});

  @override
  State<MeusDadosScreen> createState() => _MeusDadosScreenState();
}

class _MeusDadosScreenState extends State<MeusDadosScreen> {
  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController cpfController;
  late TextEditingController telefoneController;
  late TextEditingController ocupacaoController;

  String? fotoPerfilPath;

  @override
  void initState() {
    super.initState();
    // inicializa os controllers com os valores do usuário (evita null)
    nomeController = TextEditingController(text: widget.usuario.nome);
    emailController = TextEditingController(text: widget.usuario.email);
    cpfController = TextEditingController(text: widget.usuario.cpf);
    telefoneController = TextEditingController(text: widget.usuario.telefone);
    ocupacaoController = TextEditingController(
      text: widget.usuario.ocupacao ?? "",
    );
    fotoPerfilPath = widget.usuario.fotoPath;
  }

  @override
  void dispose() {
    // sempre descartar controllers
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    ocupacaoController.dispose();
    super.dispose();
  }

  void _salvarAlteracoes() {
    // Atualiza o objeto usuário localmente (a persistência real fica a seu critério)
    widget.usuario.nome = nomeController.text;
    widget.usuario.email = emailController.text;
    widget.usuario.cpf = cpfController.text;
    widget.usuario.telefone = telefoneController.text;
    widget.usuario.ocupacao = ocupacaoController.text.isEmpty
        ? null
        : ocupacaoController.text;
    widget.usuario.fotoPath = fotoPerfilPath;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Dados atualizados!")));
    // opcional: voltar para a tela anterior
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Dados")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // implementar seleção de imagem se desejar (image_picker)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Alterar foto de perfil (implementar)"),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green.shade200,
                backgroundImage: (fotoPerfilPath != null)
                    ? AssetImage(fotoPerfilPath!)
                    : null,
                child: fotoPerfilPath == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cpfController,
              decoration: const InputDecoration(labelText: "CPF"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telefoneController,
              decoration: const InputDecoration(labelText: "Telefone"),
            ),
            const SizedBox(height: 10),
            // mostra ocupação apenas para prestadores (exemplo)
            if (widget.usuario.tipoUsuario == "Prestador") ...[
              TextField(
                controller: ocupacaoController,
                decoration: const InputDecoration(labelText: "Ocupação"),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              child: const Text("Salvar Alterações"),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== TELA DE FORMAS DE PAGAMENTO ================================

class FormasPagamentoScreen extends StatefulWidget {
  final Usuario usuario;
  const FormasPagamentoScreen({super.key, required this.usuario});

  @override
  State<FormasPagamentoScreen> createState() => _FormasPagamentoScreenState();
}

class _FormasPagamentoScreenState extends State<FormasPagamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  String tipoCartao = "Crédito";
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController validadeController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool isLoading = false;
  bool isLoadingCartoes = true;
  List<dynamic> meusCartoes = [];

  // ====================== CADASTRAR CARTÕES =============================================
  Future<void> cadastrarPagamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse(
        "http://localhost:8080/app/pagamento.php",
      ); // Android Emulator

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_id": widget.usuario.id,
          "tipo_cartao": tipoCartao,
          "numero_cartao": numeroController.text.trim(),
          "nome_cartao": nomeController.text.trim(),
          "validade": validadeController.text.trim(),
          "cvv": cvvController.text.trim(),
        }),
      );

      var data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Resposta inválida"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (data["success"] == true) {
        // Limpar campos
        numeroController.clear();
        nomeController.clear();
        validadeController.clear();
        cvvController.clear();

        // Recarregar cartões cadastrados
        carregarCartoes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro de comunicação: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ===================== CARREGAR CARTÕES CADASTRADOS ========================
  Future<void> carregarCartoes() async {
    setState(() {
      isLoadingCartoes = true;
    });

    try {
      var url = Uri.parse(
        "http://localhost:8080/app/listar_pagamentos.php",
      ); // Android Emulator
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario_id": widget.usuario.id}),
      );

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          meusCartoes = data["cards"];
        });
      } else {
        setState(() {
          meusCartoes = [];
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar cartões: $e");
    } finally {
      setState(() {
        isLoadingCartoes = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarCartoes();
  }

  //============ INTERFACE DO MENU LATERAL ===========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formas de Pagamento"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.usuario.nome),
              accountEmail: Text(widget.usuario.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.usuario.nome.isNotEmpty
                      ? widget.usuario.nome[0].toUpperCase()
                      : "?",
                  style: const TextStyle(fontSize: 30, color: Colors.green),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Meus Dados"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeusDadosScreen(usuario: widget.usuario),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Formas de Pagamento"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FormasPagamentoScreen(usuario: widget.usuario),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Histórico de Serviços"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Abrindo Histórico de serviços..."),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Sair"),
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Escolha de tipo de cartão
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Crédito"),
                        selected: tipoCartao == "Crédito",
                        onSelected: (selected) =>
                            setState(() => tipoCartao = "Crédito"),
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text("Débito"),
                        selected: tipoCartao == "Débito",
                        onSelected: (selected) =>
                            setState(() => tipoCartao = "Débito"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Campos do cartão
                  TextFormField(
                    controller: numeroController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Número do Cartão",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Informe o número do cartão"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome no Cartão",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Informe o nome no cartão"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: validadeController,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: "Validade (MM/AA)",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Informe a validade"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "CVV",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Informe o CVV"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: isLoading ? null : cadastrarPagamento,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Cadastrar Cartão"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ============ LISTA DE CARTÕES ============
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Meus Cartões",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 10),

            isLoadingCartoes
                ? const Center(child: CircularProgressIndicator())
                : meusCartoes.isEmpty
                ? const Text("Nenhum cartão cadastrado ainda")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meusCartoes.length,
                    itemBuilder: (context, index) {
                      final card = meusCartoes[index];
                      String numero = card["numero_cartao"]?.toString() ?? "";
                      String ultimosDigitos = numero.length >= 4
                          ? numero.substring(numero.length - 4)
                          : numero; // se tiver menos de 4 dígitos, mostra o que tem
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            card["tipo_cartao"] == "Crédito"
                                ? Icons.credit_card
                                : Icons.payment,
                            color: Colors.blue,
                          ),
                          title: Text(
                            "${card["tipo_cartao"]} - **** **** **** $ultimosDigitos",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${card["nome_cartao"]} | Validade: ${card["validade"]}",
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditarCartaoScreen(
                                  card: card,
                                  onAtualizar: carregarCartoes,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// ========================== TELA DE EDIÇÃO E DELETAR CARTÕES =============================
class EditarCartaoScreen extends StatefulWidget {
  final Map<String, dynamic> card;
  final VoidCallback onAtualizar;

  const EditarCartaoScreen({
    super.key,
    required this.card,
    required this.onAtualizar,
  });

  @override
  State<EditarCartaoScreen> createState() => _EditarCartaoScreenState();
}

class _EditarCartaoScreenState extends State<EditarCartaoScreen> {
  late TextEditingController tipoController;
  late TextEditingController numeroController;
  late TextEditingController nomeController;
  late TextEditingController validadeController;
  late TextEditingController cvvController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tipoController = TextEditingController(text: widget.card["tipo_cartao"]);
    numeroController = TextEditingController(
      text: widget.card["numero_cartao"],
    );
    nomeController = TextEditingController(text: widget.card["nome_cartao"]);
    validadeController = TextEditingController(text: widget.card["validade"]);
    cvvController = TextEditingController(text: widget.card["cvv"]);
  }

  Future<void> atualizarCartao() async {
    setState(() => isLoading = true);
    try {
      var url = Uri.parse("http://localhost:8080/app/editar_cartao.php");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": widget.card["id"],
          "tipo_cartao": tipoController.text,
          "numero_cartao": numeroController.text,
          "nome_cartao": nomeController.text,
          "validade": validadeController.text,
          "cvv": cvvController.text,
        }),
      );

      var data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Resposta inválida"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (data["success"] == true) {
        widget.onAtualizar();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro de comunicação: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deletarCartao() async {
    setState(() => isLoading = true);
    try {
      var url = Uri.parse("http://localhost:8080/app/deletar_cartao.php");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": widget.card["id"]}),
      );

      var data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Resposta inválida"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (data["success"] == true) {
        widget.onAtualizar();
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro de comunicação: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Cartão")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(labelText: "Tipo do Cartão"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numeroController,
              decoration: const InputDecoration(labelText: "Número do Cartão"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: "Nome no Cartão"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: validadeController,
              decoration: const InputDecoration(labelText: "Validade (MM/AA)"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cvvController,
              decoration: const InputDecoration(labelText: "CVV"),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : atualizarCartao,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Atualizar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isLoading ? null : deletarCartao,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Deletar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//=======================PRESTADORES POR CATEGORIAS
class PrestadoresScreen extends StatefulWidget {
  final String categoria;
  const PrestadoresScreen({super.key, required this.categoria});

  @override
  State<PrestadoresScreen> createState() => _PrestadoresScreenState();
}

class _PrestadoresScreenState extends State<PrestadoresScreen> {
  List prestadores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPrestadores();
  }

  Future<void> fetchPrestadores() async {
    try {
      var url = Uri.parse(
        "http://localhost:8080/app/getPrestadores.php",
      ); // seu IP
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"categoria": widget.categoria}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["success"]) {
          setState(() {
            prestadores = data["prestadores"];
            loading = false;
          });
        }
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prestadores - ${widget.categoria}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : prestadores.isEmpty
          ? const Center(child: Text("Nenhum prestador encontrado"))
          : ListView.builder(
              itemCount: prestadores.length,
              itemBuilder: (context, index) {
                final p = prestadores[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(p["nome"]),
                    subtitle: Text(
                      "Ocupação: ${p["ocupacao"]}\nTel: ${p["telefone"]}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
