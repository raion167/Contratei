import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthPage(),
    );
  }
}

//=============== MODELO TESTE DE USUARIO
class Usuario {
  String nome;
  String email;
  String cpf;
  String telefone;
  String tipoUsuario;
  String? ocupacao;
  String? fotoPath;

  Usuario({
    required this.nome,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.tipoUsuario,
    this.ocupacao,
    this.fotoPath,
  });
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
      var url = Uri.parse("http://localhost/app/login.php"); // Flutter Web

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

          // navegar para HomeScreen com dados do usuário
          var user = data['usuario'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                usuario: Usuario(
                  nome: user['nome'],
                  email: user['email'],
                  cpf: user['cpf'],
                  telefone: user['telefone'],
                  tipoUsuario: user['tipoUsuario'],
                  ocupacao: user['ocupacao'],
                ),
              ),
            ),
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
  final TextEditingController ocupacaoController = TextEditingController();

  List<bool> isSelected = [true, false]; // contratante por padrão
  Future<void> cadastrarUsuario() async {
    String tipoUsuario = isSelected[0] ? "Contratante" : "Prestador";

    try {
      var url = Uri.parse("http://localhost/app/cadastro.php");

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
              ? ocupacaoController.text.trim()
              : "",
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["success"]) {
          // Mostra mensagem e depois volta para login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ ${data["message"]}"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // espera 2 segundos e volta para a tela de login
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => AuthPage()),
              (route) => false,
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ ${data["message"]}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro no servidor. Código diferente de 200"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro de conexão: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
          if (tipoUsuario == "Prestador")
            TextField(
              controller: ocupacaoController,
              decoration: const InputDecoration(labelText: "Ocupação"),
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
  final List<String> allCategorias = [
    "Categoria 1",
    "Categoria 2",
    "Categoria 3",
    "Categoria 4",
  ];

  List<String> filteredCategorias = [];
  @override
  void initState() {
    super.initState();
    filteredCategorias = allCategorias;
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
        child: Column(
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
                children: List.generate(4, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Categoria ${index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MeuPerfilScreen(usuario: widget.usuario),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Meu Perfil",
          ),
        ],
      ),
    );
  }
}

//================== TELA DE PERFIL DO USUÁRIO
class MeuPerfilScreen extends StatelessWidget {
  final Usuario usuario;
  const MeuPerfilScreen({super.key, required this.usuario});

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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Abrindo formas de pagamento..."),
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
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
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

// =================== MEUS DADOS ==================
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
