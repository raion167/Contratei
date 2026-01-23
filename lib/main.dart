import 'package:contratei/cadastrar_servico_page.dart';
import 'package:contratei/config/api.dart';
import 'package:contratei/prestador_catalogo_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'lista_prestadores_page.dart';
import 'prestador_detalhes_page.dart';
import 'basescreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      theme: ThemeData(
        primaryColor: const Color(0xFFFF4E00),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
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
      backgroundColor: const Color(0xFFFF4E00),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,

        titleTextStyle: TextStyle(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ⭐ LOGO AQUI
              Image.asset("assets/images/logo.png", width: 350),
              const SizedBox(height: 30),

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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
      // Flutter Web

      final response = await http.post(
        Uri.parse("https://contratei.infinityfreeapp.com/app/login.php"),
        body: {
          "email": emailController.text,
          "senha": senhaController.text,
          "tipoUsuario": tipoUsuario,
        },
      );

      if (!response.body.trim().startsWith("{")) {
        debugPrint("Resposta inválida:");
        debugPrint(response.body);
        throw Exception("Servidor não retornou JSON");
      }
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
        const SizedBox(height: 10),
        Center(
          child: ToggleButtons(
            isSelected: isSelected,
            borderRadius: BorderRadius.circular(12),

            fillColor: Colors.white, // fundo branco quando selecionado
            color: Colors.black, // letra preta quando não selecionado
            selectedColor: Colors.black, // letra preta quando selecionado
            borderColor: Colors.grey, // borda padrão
            selectedBorderColor: Colors.grey, // borda quando selecionado

            onPressed: (index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text("Contratante"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text("Prestador"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: login,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            child: const Text("Entrar"),
          ),
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
      final url = Uri.parse("${ApiConfig.baseUrl}/getCategorias.php");
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
      final url = Uri.parse("${ApiConfig.baseUrl}/cadastro.php");

      var response = await http.post(
        url,
        body: {
          "nome": nomeController.text.trim(),
          "email": emailController.text.trim(),
          "senha": senhaController.text.trim(),
          "cpf": cpfController.text.trim(),
          "telefone": telefoneController.text.trim(),
          "tipoUsuario": tipoUsuario,
          "ocupacao": tipoUsuario == "Prestador"
              ? ocupacaoSelecionada ?? ""
              : "",
        },
      );
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
            fillColor: Colors.white, // fundo branco quando selecionado
            color: Colors.black, // letra preta quando não selecionado
            selectedColor: Colors.black, // letra preta quando selecionado
            borderColor: Colors.grey, // borda padrão
            selectedBorderColor: Colors.grey, // borda quando s
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
          const SizedBox(height: 12),
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: "Nome"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Senha"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cpfController,
            decoration: const InputDecoration(labelText: "CPF"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: telefoneController,
            decoration: const InputDecoration(labelText: "Telefone"),
          ),
          const SizedBox(height: 12),

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
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
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

  // MAPA DE IMAGENS → sempre em minúsculo para evitar erro
  final Map<String, String> categoriaImagens = {
    "eletricista": "assets/categorias/eletricista.png",
    "pedreiro": "assets/categorias/pedreiro.png",
    "pintor": "assets/categorias/pintor.png",
    "encanador": "assets/categorias/encanador.png",
    "marceneiro": "assets/categorias/marceneiro.png",
    "barbearia": "assets/categorias/barbearia.jpg",
    "cozinheira": "assets/categorias/cozinheira.jpg",
    "desenvolvedor": "assets/categorias/desenvolvedor.png",
    "entretenimento": "assets/categorias/entretenimento.jpg",
    "garçom": "assets/categorias/garcom.jpg",
    "serralheria": "assets/categorias/serralheria.jpg",
    "manicure / pedicure": "assets/categorias/manicure.jpg",
  };

  List<String> allCategorias = [];
  List<String> filteredCategorias = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCategorias();
  }

  Future<void> fetchCategorias() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/getCategorias.php");
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
      backgroundColor: const Color(0xFFFF4E00), // fundo laranja
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    onChanged: filterCategorias,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Pesquisar Categorias...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔽 GRID COM IMAGEM + NOME
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: List.generate(filteredCategorias.length, (
                        index,
                      ) {
                        final categoria = filteredCategorias[index];

                        // Converte nome vindo do banco para minúsculo
                        final chave = categoria.toLowerCase();

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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage(
                                    categoriaImagens[chave] ??
                                        "assets/categorias/pintor.png",
                                  ),
                                  fit: BoxFit
                                      .cover, // 👉 preenche tudo sem recortar errado
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),

                              // FADE PRETO PARA LER O TEXTO EM CIMA DA IMAGEM
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black.withOpacity(0.45),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  categoria,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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

  File? fotoPerfil;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.usuario.nome);
    emailController = TextEditingController(text: widget.usuario.email);
    cpfController = TextEditingController(text: widget.usuario.cpf);
    telefoneController = TextEditingController(text: widget.usuario.telefone);
    ocupacaoController = TextEditingController(
      text: widget.usuario.ocupacao ?? "",
    );

    if (widget.usuario.fotoPath != null) {
      fotoPerfil = File(widget.usuario.fotoPath!);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    ocupacaoController.dispose();
    super.dispose();
  }

  // ================= FOTO =================
  Future<void> _selecionarFoto(ImageSource source) async {
    final XFile? imagem = await picker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (imagem != null) {
      setState(() {
        fotoPerfil = File(imagem.path);
        widget.usuario.fotoPath = imagem.path; // salva localmente
      });
    }
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Tirar foto"),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Escolher da galeria"),
              onTap: () {
                Navigator.pop(context);
                _selecionarFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= SALVAR =================
  void salvar() {
    widget.usuario.nome = nomeController.text;
    widget.usuario.telefone = telefoneController.text;
    widget.usuario.ocupacao = ocupacaoController.text.isEmpty
        ? null
        : ocupacaoController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Dados atualizados com sucesso")),
    );
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    TextInputType? teclado,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade100 : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4E00),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= AVATAR =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _mostrarOpcoesFoto,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFF4E00),
                      backgroundImage: fotoPerfil != null
                          ? FileImage(fotoPerfil!)
                          : null,
                      child: fotoPerfil == null
                          ? Text(
                              widget.usuario.nome.isNotEmpty
                                  ? widget.usuario.nome[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.usuario.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.usuario.tipoUsuario,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= DADOS =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informações Pessoais",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _campo(label: "Nome", controller: nomeController),

                  // 🔒 EMAIL READONLY
                  _campo(
                    label: "Email",
                    controller: emailController,
                    teclado: TextInputType.emailAddress,
                    readOnly: true,
                  ),

                  // 🔒 CPF READONLY
                  _campo(
                    label: "CPF",
                    controller: cpfController,
                    teclado: TextInputType.number,
                    readOnly: true,
                  ),

                  _campo(
                    label: "Telefone",
                    controller: telefoneController,
                    teclado: TextInputType.phone,
                  ),

                  if (widget.usuario.tipoUsuario == "Prestador")
                    _campo(label: "Ocupação", controller: ocupacaoController),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= SALVAR =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4E00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Salvar Alterações",
                  style: TextStyle(fontSize: 16),
                ),
              ),
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
  final numeroController = TextEditingController();
  final nomeController = TextEditingController();
  final validadeController = TextEditingController();
  final cvvController = TextEditingController();

  bool isLoading = false;
  bool isLoadingCartoes = true;
  List<dynamic> meusCartoes = [];

  static const corPrincipal = Color(0xFFFF4E00);

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: corPrincipal, width: 2),
      ),
    );
  }

  // ================= CADASTRAR CARTÃO =================
  Future<void> cadastrarPagamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/pagamento.php");
      final response = await http.post(
        url,
        body: {
          "usuario_id": widget.usuario.id,
          "tipo_cartao": tipoCartao,
          "numero_cartao": numeroController.text,
          "nome_cartao": nomeController.text,
          "validade": validadeController.text,
          "cvv": cvvController.text,
        },
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Erro"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (data["success"] == true) {
        numeroController.clear();
        nomeController.clear();
        validadeController.clear();
        cvvController.clear();
        carregarCartoes();
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= LISTAR CARTÕES =================
  Future<void> carregarCartoes() async {
    setState(() => isLoadingCartoes = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/listar_pagamentos.php");
      final response = await http.post(
        url,
        body: {"usuario_id": widget.usuario.id},
      );

      final data = jsonDecode(response.body);
      meusCartoes = data["success"] == true ? data["cards"] : [];
    } finally {
      setState(() => isLoadingCartoes = false);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarCartoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Formas de Pagamento"),
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= FORM =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cadastrar Cartão",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text("Crédito"),
                          selected: tipoCartao == "Crédito",
                          selectedColor: corPrincipal.withOpacity(0.2),
                          onSelected: (_) =>
                              setState(() => tipoCartao = "Crédito"),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text("Débito"),
                          selected: tipoCartao == "Débito",
                          selectedColor: corPrincipal.withOpacity(0.2),
                          onSelected: (_) =>
                              setState(() => tipoCartao = "Débito"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: numeroController,
                      decoration: _decoration("Número do cartão"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Informe o número" : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nomeController,
                      decoration: _decoration("Nome no cartão"),
                      validator: (v) => v!.isEmpty ? "Informe o nome" : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: validadeController,
                            decoration: _decoration("Validade"),
                            validator: (v) =>
                                v!.isEmpty ? "Informe a validade" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: cvvController,
                            decoration: _decoration("CVV"),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? "Informe o CVV" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : cadastrarPagamento,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corPrincipal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Salvar Cartão",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= LISTA =================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Meus Cartões",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),

            isLoadingCartoes
                ? const CircularProgressIndicator()
                : meusCartoes.isEmpty
                ? const Text("Nenhum cartão cadastrado")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meusCartoes.length,
                    itemBuilder: (_, i) {
                      final card = meusCartoes[i];
                      final numero = card["numero_cartao"].toString();
                      final ultimos = numero.substring(numero.length - 4);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.credit_card,
                            color: corPrincipal,
                          ),
                          title: Text("**** **** **** $ultimos"),
                          subtitle: Text(
                            "${card["nome_cartao"]} • ${card["validade"]}",
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
  static const corPrincipal = Color(0xFFFF4E00);

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

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: corPrincipal, width: 2),
      ),
    );
  }

  // ================= ATUALIZAR CARTÃO =================
  Future<void> atualizarCartao() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/editar_cartao.php");
      final response = await http.post(
        url,
        body: {
          "id": widget.card["id"],
          "tipo_cartao": tipoController.text,
          "numero_cartao": numeroController.text,
          "nome_cartao": nomeController.text,
          "validade": validadeController.text,
          "cvv": cvvController.text,
        },
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Erro"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (data["success"] == true) {
        widget.onAtualizar();
        Navigator.pop(context);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= DELETAR CARTÃO =================
  Future<void> deletarCartao() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/deletar_cartao.php");
      final response = await http.post(url, body: {"id": widget.card["id"]});

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Erro"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );

      if (data["success"] == true) {
        widget.onAtualizar();
        Navigator.pop(context);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Editar Cartão"),
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dados do Cartão",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: tipoController,
                decoration: _decoration("Tipo do Cartão"),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: numeroController,
                decoration: _decoration("Número do Cartão"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: nomeController,
                decoration: _decoration("Nome no Cartão"),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: validadeController,
                      decoration: _decoration("Validade"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: _decoration("CVV"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // BOTÕES
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : atualizarCartao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Salvar Alterações",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : deletarCartao,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Excluir Cartão"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
