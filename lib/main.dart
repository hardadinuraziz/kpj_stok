import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KenanApp());
}

class KenanApp extends StatelessWidget {
  const KenanApp({Key? key, this.enableFirebase = true}) : super(key: key);

  final bool enableFirebase;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stok Gudang | CV KENAN PUTRA JAYA',
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: const Color(0xFF0D5C54),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0D5C54),
          secondary: const Color(0xFFEAB308),
        ),
      ),
      home: LoginPage(enableFirebase: enableFirebase),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.enableFirebase = true}) : super(key: key);

  final bool enableFirebase;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _validUsername = 'kenanputrajaya';
  static const String _validPassword = 'kpj2026';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Username dan password wajib diisi.');
      return;
    }

    if (username != _validUsername || password != _validPassword) {
      setState(() => _errorMessage = 'Username atau password salah.');
      return;
    }

    if (widget.enableFirebase) {
      try {
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Gagal autentikasi Firebase: $e';
        });
        return;
      }
    }

    if (!mounted) return;
    setState(() => _errorMessage = null);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            InventoryPage(enableFirebase: widget.enableFirebase),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE1E8E5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF123A36),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warehouse_outlined,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Text(
                              'CV KENAN PUTRA JAYA',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF17312F),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Sistem Stok Gudang',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF627370),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Color(0xFFE4EAE7)),
                  const SizedBox(height: 24),
                  const Text(
                    'Login Akun',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17312F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Masukkan username dan password untuk masuk.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF627370)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  if (_errorMessage != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key, this.enableFirebase = true}) : super(key: key);

  final bool enableFirebase;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _activeMenu = 1;
  int _selectedSalesDay = DateTime.now().day;
  int _selectedSalesMonth = DateTime.now().month;
  String _selectedSalesman = 'Dirman';
  String _discountSalesman = 'Dirman';
  bool _isGlobalDiscount = true;
  int _revenueDay = DateTime.now().day;
  int _revenueMonth = DateTime.now().month;
  int _revenueWeek = ((DateTime.now().day - 1) ~/ 7) + 1;

  final List<String> _salesmen = <String>['Dirman', 'Yono', 'Koko', 'Angges', 'Ibnu', 'Sekhu', 'OFFICE'];
  static const List<String> _months = <String>['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  static const List<String> _productNames = <String>[
    'KRIPIK TEMPE ONE', 'LATIO RASNA', 'NORI LEMBAR', 'NORI ROLL', 'RAJA SAWER', 'POCKY',
    'SUPRISE EGG', 'CHOCOPIE', 'SUGAR CANDY', 'RAINBOW BBG', 'SUPERBOB JUMBO',
    'ROTI SWISS ROLL 2000', 'ROTI LEMBUT 1000', 'WILLO/ CANDY CUBE', 'MIDI MUTER',
    'MILKITA TOPLES', 'MILKITA RENCENG + JAGOAN NEON', 'MILKITA BITES', 'KUSKUS',
    'PERMEN JARI', 'LATIO LONG TANGTANG', "C'BALL", 'MONSTER CANDY', 'BBG STROW/MANGO',
    'LOLY GUMMY', 'BUBBLE GUM TATO', 'PERMEN LIPSTIK', 'PLUIT LONG', 'COPICO KENTANG',
    'SOGI', 'RELAXA PLAY', 'LUNAK SATE NEW', 'CUBE MIX CANDY', 'MELLOW KARTU',
    'MADU STIK', "D'KING", 'DAVOS 1000', 'OPAL FANCY 2000', 'MODI KWEK', 'MODI KUPAS',
    'MODI RINTIK', 'FRUIT CANDY - SUGUS', 'LOLIPOP KARAKTER', 'ROLLETA', 'HEBOH',
    'NOBUR', 'BISKIES OAT GANDUM', 'CHOCOTARO/CHOCO CUBE 120', 'POKEROLL', 'POTATOQ',
    'MAX POTATO', 'PILUS ATOM', 'PIA ABON', 'SENAK BAR', 'GUMMY MANGGO', 'MIE LIDI',
    'RELAXA PLAY ISI 11', 'RELAXA PLAY ISI 20', 'SENANDUNG', 'CHOCO CUBE/TARO CUBE 60',
    'SEBLAK MJS', 'LUNAK SUSHI', 'MODI BERRY', 'BISKUIT BEAR/STIK', 'STICK GUMMY',
    'LUNAK BEBEK', 'MAKARONI 2000', 'PERMEN MIX', 'PERMEN JERUK', '3D BLOCK',
    'NGECAT LOLIPOP', 'NORI HERBY', 'EPEP', 'BOCIL', 'ANOMALI',
  ];

  static const Map<String, List<int>> _productPrices = <String, List<int>>{
    'KRIPIK TEMPE ONE': <int>[1550, 1800], 'LATIO RASNA': <int>[14000, 17000],
    'NORI LEMBAR': <int>[17000, 20000], 'NORI ROLL': <int>[17167, 21000],
    'RAJA SAWER': <int>[15000, 17000], 'POCKY': <int>[19200, 21000],
    'SUPRISE EGG': <int>[25834, 33000], 'CHOCOPIE': <int>[18750, 21000],
    'SUGAR CANDY': <int>[24750, 28000], 'RAINBOW BBG': <int>[24271, 28000],
    'SUPERBOB JUMBO': <int>[7313, 15500], 'ROTI SWISS ROLL 2000': <int>[8750, 15500],
    'ROTI LEMBUT 1000': <int>[4375, 8500], 'WILLO/ CANDY CUBE': <int>[12188, 20000],
    'MIDI MUTER': <int>[24200, 28000], 'MILKITA TOPLES': <int>[22655, 27000],
    'MILKITA RENCENG + JAGOAN NEON': <int>[22163, 25000], 'MILKITA BITES': <int>[22750, 27000],
    'KUSKUS': <int>[6174, 7500], 'PERMEN JARI': <int>[24583, 27000],
    'LATIO LONG TANGTANG': <int>[850, 1167], "C'BALL": <int>[15700, 18000],
    'MONSTER CANDY': <int>[24500, 28000], 'BBG STROW/MANGO': <int>[21550, 27000],
    'LOLY GUMMY': <int>[26050, 28000], 'BUBBLE GUM TATO': <int>[15033, 18000],
    'PERMEN LIPSTIK': <int>[24583, 27000], 'PLUIT LONG': <int>[25850, 35000],
    'COPICO KENTANG': <int>[15146, 17000], 'SOGI': <int>[15675, 18000],
    'RELAXA PLAY': <int>[5000, 7500], 'LUNAK SATE NEW': <int>[24500, 35000],
    'CUBE MIX CANDY': <int>[27500, 42000], 'MELLOW KARTU': <int>[25850, 35000],
    'MADU STIK': <int>[13950, 17000], "D'KING": <int>[13813, 17000],
    'DAVOS 1000': <int>[15000, 17000], 'OPAL FANCY 2000': <int>[20959, 27000],
    'MODI KWEK': <int>[17526, 21000], 'MODI KUPAS': <int>[14699, 18000],
    'MODI RINTIK': <int>[19231, 21000], 'FRUIT CANDY - SUGUS': <int>[24550, 42000],
    'LOLIPOP KARAKTER': <int>[24500, 28000], 'ROLLETA': <int>[14625, 17000],
    'HEBOH': <int>[14625, 17000], 'NOBUR': <int>[7200, 8500],
    'BISKIES OAT GANDUM': <int>[16587, 20000], 'CHOCOTARO/CHOCO CUBE 120': <int>[27605, 42000],
    'POKEROLL': <int>[24500, 27000], 'POTATOQ': <int>[14100, 17000],
    'MAX POTATO': <int>[14625, 17000], 'PILUS ATOM': <int>[15500, 17000],
    'PIA ABON': <int>[16000, 18000], 'SENAK BAR': <int>[14850, 17000],
    'GUMMY MANGGO': <int>[24500, 28000], 'MIE LIDI': <int>[12730, 17000],
    'RELAXA PLAY ISI 11': <int>[6200, 8500], 'RELAXA PLAY ISI 20': <int>[11200, 17000],
    'SENANDUNG': <int>[24318, 28000], 'CHOCO CUBE/TARO CUBE 60': <int>[16303, 21000],
    'SEBLAK MJS': <int>[15250, 17000], 'LUNAK SUSHI': <int>[25500, 28000],
    'MODI BERRY': <int>[19334, 22000], 'BISKUIT BEAR/STIK': <int>[5327, 8000],
    'STICK GUMMY': <int>[24762, 28000], 'LUNAK BEBEK': <int>[25056, 28000],
    'MAKARONI 2000': <int>[6300, 7500], 'PERMEN MIX': <int>[24500, 27000],
    'PERMEN JERUK': <int>[25219, 30000], '3D BLOCK': <int>[19563, 22000],
    'NGECAT LOLIPOP': <int>[19156, 22000], 'NORI HERBY': <int>[18755, 21000],
    'EPEP': <int>[15250, 17000], 'BOCIL': <int>[15250, 17000], 'ANOMALI': <int>[15250, 17000],
  };

  /* Data impor REKAP ALL dinonaktifkan karena sumber penjualan tidak valid.
  static const Map<String, Map<int, int>> _salesByProduct = <String, Map<int, int>>{
    'KRIPIK TEMPE ONE': <int, int>{8: 10}, 'LATIO RASNA': <int, int>{2: 1, 4: 1},
    'NORI LEMBAR': <int, int>{1: 9, 2: 18, 3: 17, 4: 13, 5: 5, 6: 21, 7: 11, 8: 9, 9: 21, 10: 13, 11: 8, 13: 7, 14: 9, 15: 25, 16: 18, 17: 16, 18: 19, 20: 19, 21: 7, 22: 10},
    'NORI ROLL': <int, int>{1: 13, 2: 6, 3: 18, 4: 6, 5: 5, 6: 14, 7: 15, 8: 5, 9: 18, 10: 5, 11: 12, 13: 19, 14: 1, 15: 17, 16: 5, 17: 12, 18: 3, 20: 9, 21: 1, 22: 1},
    'RAJA SAWER': <int, int>{1: 67, 2: 63, 3: 41, 4: 40, 5: 8, 6: 55, 8: 4, 11: 2, 20: 156, 21: 39, 22: 54},
    'POCKY': <int, int>{1: 11, 2: 5, 3: 11, 4: 2, 5: 3, 6: 8, 7: 13, 8: 3, 9: 1, 11: 11, 13: 12, 14: 9, 15: 20, 16: 5, 17: 7, 18: 4, 20: 2, 21: 11, 22: 5},
    'SUPRISE EGG': <int, int>{18: 17, 20: 5, 21: 3, 22: 3},
    'CHOCOPIE': <int, int>{1: 18, 2: 13, 3: 17, 4: 13, 5: 7, 6: 17, 7: 9, 8: 8, 9: 10, 10: 6, 11: 44, 13: 38, 14: 13, 15: 33, 16: 10, 17: 17, 18: 7, 20: 15, 21: 3, 22: 6},
    'RAINBOW BBG': <int, int>{1: 1, 15: 1}, 'SUPERBOB JUMBO': <int, int>{8: 7, 9: 12, 10: 5, 11: 29, 13: 11, 14: 2, 15: 13, 16: 6, 17: 8, 18: 5, 20: 7, 22: 4},
    'MIDI MUTER': <int, int>{1: 5, 2: 10, 3: 9, 4: 4, 5: 2, 6: 9, 7: 9, 8: 4, 9: 12, 10: 4, 11: 8, 13: 12, 14: 2, 15: 9, 16: 11, 17: 3, 18: 1, 20: 3},
    'MILKITA TOPLES': <int, int>{16: 8, 17: 5, 18: 3, 20: 6, 22: 4}, 'MILKITA RENCENG + JAGOAN NEON': <int, int>{16: 9, 17: 4, 18: 8, 20: 3, 21: 5},
    'MILKITA BITES': <int, int>{16: 11, 17: 9, 18: 6, 20: 1, 21: 2}, 'KUSKUS': <int, int>{1: 9, 2: 14, 3: 4, 4: 3, 6: 4, 7: 14, 8: 6, 9: 14, 10: 6, 11: 22, 13: 3, 14: 6, 15: 8, 20: 6, 21: 5},
    'PERMEN JARI': <int, int>{1: 4, 2: 5, 3: 6, 4: 5, 6: 6, 7: 7, 8: 1, 9: 31, 10: 1, 11: 4, 13: 3, 14: 1, 15: 14, 16: 6, 17: 5, 18: 13, 20: 1, 21: 2, 22: 1},
    'LATIO LONG TANGTANG': <int, int>{3: 30, 6: 24, 13: 12}, "C'BALL": <int, int>{1: 1, 2: 2, 3: 7, 4: 1, 5: 2, 6: 7, 7: 2, 9: 1, 10: 1, 11: 6, 13: 2, 14: 2, 15: 3, 16: 1, 17: 2, 18: 1, 20: 1, 21: 2},
    'MONSTER CANDY': <int, int>{18: 14, 20: 5, 21: 1, 22: 2}, 'BBG STROW/MANGO': <int, int>{1: 2, 2: 3, 4: 2, 5: 1, 6: 3, 7: 1, 8: 1, 9: 3, 10: 1, 11: 4, 13: 2, 15: 3, 16: 6, 17: 5, 18: 1, 20: 1, 21: 1},
    'LOLY GUMMY': <int, int>{4: 10, 6: 9, 7: 13, 8: 3, 9: 8, 10: 3, 11: 9, 13: 8, 14: 3, 15: 13, 16: 3, 17: 8, 18: 6, 20: 15, 21: 6, 22: 4},
    'BUBBLE GUM TATO': <int, int>{1: 10, 2: 6, 3: 3, 4: 8, 5: 4, 6: 17, 7: 10, 8: 1, 9: 35, 10: 4, 11: 11, 13: 3, 14: 9, 15: 12, 16: 17, 17: 11, 18: 14, 20: 3, 21: 8},
    'PERMEN LIPSTIK': <int, int>{11: 6, 13: 6, 14: 2, 15: 7, 16: 9, 17: 6, 18: 12, 20: 5, 22: 2}, 'PLUIT LONG': <int, int>{1: 8, 2: 3, 3: 7, 4: 4, 5: 1, 6: 5, 7: 6, 8: 2, 9: 1, 10: 1, 11: 4, 13: 7, 15: 1},
    'COPICO KENTANG': <int, int>{7: 19, 8: 27, 9: 26, 10: 16, 11: 32, 13: 12, 14: 4, 15: 22, 16: 3, 17: 12, 18: 23, 20: 4}, 'SOGI': <int, int>{1: 3, 2: 3, 3: 4, 4: 1, 5: 1, 6: 4, 7: 5, 8: 1, 9: 7, 10: 5, 11: 5, 14: 2, 15: 1, 16: 2, 17: 6, 18: 3},
    'RELAXA PLAY': <int, int>{2: 2}, 'CUBE MIX CANDY': <int, int>{18: 2, 20: 2}, 'MADU STIK': <int, int>{20: 4, 21: 3},
    "D'KING": <int, int>{7: 7, 8: 30, 9: 7, 10: 13, 11: 8, 13: 8, 15: 2}, 'DAVOS 1000': <int, int>{1: 3, 2: 4, 3: 6, 4: 6, 6: 2, 7: 6, 8: 1, 9: 4, 10: 3, 11: 7, 13: 5, 14: 8, 15: 4, 16: 4, 17: 7, 18: 1, 20: 1, 22: 1},
    'OPAL FANCY 2000': <int, int>{20: 3, 21: 2, 22: 1}, 'MODI KWEK': <int, int>{1: 1, 2: 2, 3: 3, 4: 1, 6: 1, 7: 2, 9: 3, 11: 1, 13: 2},
    'MODI KUPAS': <int, int>{3: 1, 6: 2, 7: 1, 10: 1, 11: 2, 14: 1, 16: 2}, 'LOLIPOP KARAKTER': <int, int>{9: 4, 10: 1, 11: 3, 13: 5, 15: 4, 16: 1, 17: 1, 18: 1},
    'ROLLETA': <int, int>{1: 16, 2: 20, 3: 10, 20: 25, 21: 17, 22: 20}, 'HEBOH': <int, int>{1: 46, 2: 24, 3: 16, 4: 9, 20: 57, 21: 20, 22: 71},
    'CHOCOTARO/CHOCO CUBE 120': <int, int>{1: 2, 2: 3, 3: 1, 6: 2, 7: 2, 8: 1, 10: 1, 11: 1, 13: 2, 14: 1, 15: 2, 16: 1, 17: 1, 22: 1}, 'POKEROLL': <int, int>{6: 1},
    'PILUS ATOM': <int, int>{1: 14, 2: 27, 3: 25, 4: 20, 5: 4, 6: 22, 7: 6, 9: 2, 20: 34, 21: 18, 22: 36},
    'PIA ABON': <int, int>{1: 6, 2: 1, 3: 5, 4: 3, 5: 1, 6: 2, 7: 3, 8: 2, 11: 4, 13: 1, 14: 2, 15: 2, 20: 4, 21: 2, 22: 1},
    'SENAK BAR': <int, int>{1: 5, 2: 5, 3: 4, 4: 5, 5: 4, 6: 5, 7: 19, 8: 3, 9: 3, 10: 1, 11: 9, 13: 21, 18: 2, 20: 10, 22: 1},
    'GUMMY MANGGO': <int, int>{9: 2, 10: 1, 11: 10, 13: 4, 14: 4, 15: 8, 16: 3, 18: 6},
    'MIE LIDI': <int, int>{1: 13, 2: 9, 3: 11, 4: 3, 6: 15, 7: 3, 8: 6, 9: 5, 10: 1, 11: 6, 13: 4, 14: 2, 15: 10, 16: 13, 17: 12, 18: 7, 20: 4, 21: 7, 22: 4},
    'RELAXA PLAY ISI 11': <int, int>{3: 2, 11: 2}, 'RELAXA PLAY ISI 20': <int, int>{3: 1, 7: 1},
    'SENANDUNG': <int, int>{1: 6, 2: 2, 3: 3, 4: 1, 5: 1, 6: 8, 7: 6, 8: 1, 9: 11, 10: 2, 11: 4, 13: 5, 14: 3, 15: 3, 16: 6, 17: 7, 18: 8, 20: 9, 21: 1, 22: 1},
    'CHOCO CUBE/TARO CUBE 60': <int, int>{14: 3, 15: 2, 16: 2, 20: 1},
    'SEBLAK MJS': <int, int>{1: 2, 2: 36, 3: 94, 4: 56, 5: 40, 6: 91, 7: 108, 8: 44, 9: 80, 10: 32, 11: 49, 13: 85, 14: 25, 15: 73, 16: 60, 17: 54, 18: 57, 20: 43, 21: 20, 22: 16},
    'LUNAK SUSHI': <int, int>{1: 10, 2: 6, 3: 13, 4: 4, 5: 2, 6: 5, 7: 9, 8: 3, 9: 2, 10: 2, 11: 12, 13: 5, 14: 4, 15: 10, 16: 6, 17: 6, 18: 9, 20: 5},
    'BISKUIT BEAR/STIK': <int, int>{8: 6, 9: 10, 10: 16, 11: 20, 13: 51, 14: 20, 15: 31, 16: 12, 17: 20, 18: 7, 20: 8, 21: 6, 22: 4},
    'STICK GUMMY': <int, int>{1: 10, 2: 9, 3: 5, 4: 3, 5: 1, 6: 4, 7: 4, 8: 3, 9: 3, 10: 2, 11: 4, 13: 5, 14: 4, 15: 8, 16: 5, 17: 3, 18: 2, 20: 3, 21: 1},
    'LUNAK BEBEK': <int, int>{1: 1, 2: 1, 11: 11, 13: 11, 14: 3, 15: 18, 16: 10, 17: 10, 18: 10, 20: 9, 21: 3, 22: 3},
    'MAKARONI 2000': <int, int>{1: 24, 2: 11, 3: 62, 4: 23, 5: 1, 6: 46, 7: 20, 8: 3, 9: 1, 11: 16, 13: 41, 14: 29, 15: 64, 16: 21, 17: 24, 18: 12, 20: 34, 21: 43, 22: 3},
    'PERMEN MIX': <int, int>{4: 1, 6: 3, 7: 1}, '3D BLOCK': <int, int>{1: 10, 2: 1, 3: 10, 4: 9, 5: 3, 6: 5, 7: 6, 8: 3, 9: 9, 10: 8, 11: 8, 13: 6, 14: 5, 15: 14, 16: 8, 17: 12, 18: 9, 20: 4, 21: 7, 22: 6},
    'NGECAT LOLIPOP': <int, int>{1: 7, 2: 8, 3: 10, 4: 1, 5: 2, 6: 2}, 'NORI HERBY': <int, int>{4: 4, 6: 3, 7: 4, 8: 7, 10: 6, 11: 8, 13: 3, 15: 5, 16: 2},
    'EPEP': <int, int>{1: 59, 2: 28, 3: 26, 4: 12, 5: 8, 6: 29, 7: 25, 8: 32, 9: 21, 10: 11, 11: 27, 13: 37, 14: 6, 15: 44, 16: 42, 17: 41, 18: 15, 20: 18, 22: 4},
    'BOCIL': <int, int>{2: 1, 3: 4, 4: 12, 5: 4, 6: 5, 7: 5, 8: 5, 9: 4, 13: 2, 16: 1}, 'ANOMALI': <int, int>{2: 4, 4: 4, 5: 4, 6: 1, 7: 3, 8: 13, 13: 4, 16: 1},
  };
  */
  static const Map<String, Map<int, int>> _salesByProduct = <String, Map<int, int>>{};

  late List<Product> _products = List<Product>.generate(_productNames.length, (int index) {
    final List<int> prices = _productPrices[_productNames[index]]!;
    final int buyPrice = prices[0];
    final int sold = 8 + ((index * 7) % 26);
    final Map<int, int> salesByDay = Map<int, int>.from(_salesByProduct[_productNames[index]] ?? const <int, int>{});
    return Product(
      order: index + 1,
      name: _productNames[index],
      added: 36 + ((index * 11) % 90),
      sold: sold,
      buyPrice: buyPrice,
      sellPrice: prices[1],
      salesByDay: salesByDay,
      salesBySalesman: <String, Map<String, int>>{},
      salesmanDiscounts: <String, int>{},
      discountAmount: 0,
    );
  });

  FirestoreService? _firestoreService;
  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<String>>? _salesmenSub;

  @override
  void initState() {
    super.initState();
    if (widget.enableFirebase) {
      _firestoreService = FirestoreService();
      _initFirestore();
    }
  }

  Future<void> _initFirestore() async {
    final FirestoreService? service = _firestoreService;
    if (service == null) return;
    await service.seedDefaultsIfEmpty(
      defaultProducts: _products,
      defaultSalesmen: _salesmen,
    );
    _productsSub = service.streamProducts().listen((List<Product> items) {
      if (!mounted || items.isEmpty) return;
      setState(() {
        _products = items;
      });
    });
    _salesmenSub = service.streamSalesmen().listen((List<String> items) {
      if (!mounted || items.isEmpty) return;
      setState(() {
        _salesmen
          ..clear()
          ..addAll(items);
        if (!_salesmen.contains(_selectedSalesman)) {
          _selectedSalesman = _salesmen.first;
        }
        if (!_salesmen.contains(_discountSalesman)) {
          _discountSalesman = _salesmen.first;
        }
      });
    });
  }

  void _syncProduct(Product product) {
    _firestoreService?.updateProduct(product);
  }

  void _addProductToFirestore(Product product) {
    _firestoreService?.addProduct(product);
  }

  void _syncSalesmen() {
    _firestoreService?.saveSalesmen(List<String>.from(_salesmen));
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _salesmenSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return _products.where((Product product) {
      return product.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();
  }

  int get _totalStock => _products.fold(0, (int total, Product p) => total + p.remaining);
  int get _totalCapital => _products.fold(0, (int total, Product p) => total + (p.remaining * p.buyPrice));
  int get _potentialMargin => _products.fold(0, (int total, Product p) => total + (p.remaining * p.margin));
  int _dailySalesFor(Product product, int day) {
    if (_selectedSalesMonth != 7) return 0;
    return product.salesByDay[day] ?? 0;
  }

  int _salesPriceFor(Product product, {String? salesman}) {
    final int salesmanDiscount = salesman == null ? 0 : (product.salesmanDiscounts[salesman] ?? 0);
    return (product.sellPrice - product.discountAmount - salesmanDiscount).clamp(0, product.sellPrice) as int;
  }

  String get _salesDateKey => '${DateTime.now().year}-${_selectedSalesMonth.toString().padLeft(2, '0')}-${_selectedSalesDay.toString().padLeft(2, '0')}';

  int _salesmanSalesFor(Product product, String salesman) {
    return product.salesBySalesman[salesman]?[_salesDateKey] ?? 0;
  }

  int _salesmanPacks(String salesman) {
    return _products.fold(0, (int total, Product product) => total + _salesmanSalesFor(product, salesman));
  }

  int _salesmanRevenue(String salesman) {
    return _products.fold(0, (int total, Product product) => total + (_salesmanSalesFor(product, salesman) * _salesPriceFor(product, salesman: salesman)));
  }

  int get _revenueDaysInMonth => DateTime(DateTime.now().year, _revenueMonth + 1, 0).day;

  int _salesmanRevenuePeriod(String salesman, String period) {
    final DateTime selectedDate = DateTime(DateTime.now().year, _revenueMonth, _revenueDay);
    return _products.fold(0, (int total, Product product) {
      final Map<String, int> sales = product.salesBySalesman[salesman] ?? <String, int>{};
      final int quantity = sales.entries.fold(0, (int subtotal, MapEntry<String, int> entry) {
        final DateTime? date = DateTime.tryParse(entry.key);
        if (date == null) return subtotal;
        final bool included = period == 'daily'
            ? date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day
            : period == 'weekly'
                ? date.year == selectedDate.year && date.month == selectedDate.month && ((date.day - 1) ~/ 7) + 1 == _revenueWeek
                : date.year == selectedDate.year && date.month == selectedDate.month;
        return included ? subtotal + entry.value : subtotal;
      });
      return total + (quantity * _salesPriceFor(product, salesman: salesman));
    });
  }

  void _showSalesmanSaleDialog({bool revision = false}) {
    final Map<Product, TextEditingController> quantities = <Product, TextEditingController>{
      for (final Product product in _products) product: TextEditingController(text: revision && _salesmanSalesFor(product, _selectedSalesman) > 0 ? _salesmanSalesFor(product, _selectedSalesman).toString() : ''),
    };
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          final int grandTotal = quantities.entries.fold(0, (int total, MapEntry<Product, TextEditingController> entry) => total + ((int.tryParse(entry.value.text) ?? 0) * _salesPriceFor(entry.key, salesman: _selectedSalesman)));
          return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(revision ? 'Revisi penjualan salesman' : 'Input penjualan salesman'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width < 760 ? 350 : 760,
          height: MediaQuery.of(context).size.height < 650 ? 400 : 500,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('Salesman: $_selectedSalesman', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF17312F))),
            const SizedBox(height: 4),
            Text('Tanggal: $_salesDateLabel', style: const TextStyle(fontSize: 13, color: Color(0xFF627370))),
            const SizedBox(height: 18),
            Row(children: <Widget>[Expanded(flex: 3, child: const Text('NAMA PRODUK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF627370)))), const SizedBox(width: 100, child: Text('TERJUAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF627370)))), const SizedBox(width: 110, child: Text('HARGA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF627370)))), const SizedBox(width: 125, child: Text('JUMLAH HARGA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF627370))))]),
            const SizedBox(height: 8),
            Expanded(child: ListView.separated(
              itemCount: _products.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 1, color: Color(0xFFE7ECEA)),
              itemBuilder: (BuildContext context, int index) {
                final Product product = _products[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: <Widget>[
                    Expanded(flex: 3, child: Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27433F)))),
                    SizedBox(width: 100, height: 38, child: TextField(controller: quantities[product], onChanged: (String value) => setDialogState(() {}), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '0', suffixText: 'qty', isDense: true, border: OutlineInputBorder()))),
                    SizedBox(width: 110, child: Text(_money(_salesPriceFor(product, salesman: _selectedSalesman)), style: const TextStyle(fontSize: 12, color: Color(0xFF516662)))),
                    SizedBox(width: 125, child: Text(_money((int.tryParse(quantities[product]!.text) ?? 0) * _salesPriceFor(product, salesman: _selectedSalesman)), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))),
                  ]),
                );
              },
            )),
            Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(top: 14), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[const Text('GRAND TOTAL HARGA PENJUALAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF516662))), const SizedBox(width: 16), Text(_money(grandTotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))])),
          ]),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final Map<Product, int> values = <Product, int>{for (final MapEntry<Product, TextEditingController> entry in quantities.entries) entry.key: int.tryParse(entry.value.text) ?? 0};
              final List<MapEntry<Product, int>> entries = values.entries.where((MapEntry<Product, int> entry) => entry.value > 0).toList();
              if ((!revision && entries.isEmpty) || values.entries.any((MapEntry<Product, int> entry) => revision && entry.value - _salesmanSalesFor(entry.key, _selectedSalesman) > entry.key.remaining)) return;
              setState(() {
                final Iterable<MapEntry<Product, int>> items = revision ? values.entries : entries;
                for (final MapEntry<Product, int> entry in items) {
                  final Product product = entry.key;
                  final int previousAmount = revision ? _salesmanSalesFor(product, _selectedSalesman) : 0;
                  final int amount = entry.value;
                  final int difference = amount - previousAmount;
                  if (difference == 0) continue;
                  product.sold += difference;
                  if (_selectedSalesMonth == 7) product.salesByDay[_selectedSalesDay] = (product.salesByDay[_selectedSalesDay] ?? 0) + difference;
                  final Map<String, int> salesmanSales = product.salesBySalesman.putIfAbsent(_selectedSalesman, () => <String, int>{});
                  if (amount == 0) {
                    salesmanSales.remove(_salesDateKey);
                  } else {
                    salesmanSales[_salesDateKey] = amount;
                  }
                  _syncProduct(product);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan penjualan'),
          ),
        ],
          );
        },
      ),
    );
  }

  void _showAddSalesmanDialog() {
    final TextEditingController name = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Tambah salesman'),
        content: _dialogField(name, 'Nama salesman', Icons.person_add_alt_1_outlined),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final String salesman = name.text.trim();
              if (salesman.isEmpty || _salesmen.any((String item) => item.toLowerCase() == salesman.toLowerCase())) return;
              setState(() {
                _salesmen.add(salesman);
                _selectedSalesman = salesman;
              });
              _syncSalesmen();
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  int _dailySalesTotal(List<Product> products) {
    return products.fold(0, (int total, Product p) => total + (_dailySalesFor(p, _selectedSalesDay) * _salesPriceFor(p)));
  }

  int _dailyCostTotal(List<Product> products) {
    return products.fold(0, (int total, Product p) => total + (_dailySalesFor(p, _selectedSalesDay) * p.buyPrice));
  }

  int get _daysInSelectedMonth => DateTime(DateTime.now().year, _selectedSalesMonth + 1, 0).day;

  String get _salesDateLabel {
    final DateTime now = DateTime.now();
    return '$_selectedSalesDay ${_months[_selectedSalesMonth - 1]} ${now.year}';
  }

  void _selectSalesMonth(int month) {
    setState(() {
      _selectedSalesMonth = month;
      if (_selectedSalesDay > _daysInSelectedMonth) _selectedSalesDay = _daysInSelectedMonth;
    });
  }

  String _money(int value) {
    final String raw = value.toString();
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) result.write('.');
      result.write(raw[i]);
    }
    return 'Rp $result';
  }

  void _showProductDialog() {
    final TextEditingController name = TextEditingController();
    final TextEditingController stock = TextEditingController();
    final TextEditingController buy = TextEditingController();
    final TextEditingController sell = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Tambah produk baru'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 390,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _dialogField(name, 'Nama produk', Icons.inventory_2_outlined),
                _dialogField(stock, 'Stok awal', Icons.layers_outlined, number: true),
                _dialogField(buy, 'Harga beli', Icons.shopping_bag_outlined, number: true),
                _dialogField(sell, 'Harga jual', Icons.sell_outlined, number: true),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final int? initialStock = int.tryParse(stock.text);
              final int? buyPrice = int.tryParse(buy.text);
              final int? sellPrice = int.tryParse(sell.text);
              if (name.text.trim().isEmpty || initialStock == null || initialStock < 0 || buyPrice == null || buyPrice < 0 || sellPrice == null || sellPrice < buyPrice) return;
              final Product newProduct = Product(
                order: 0,
                name: name.text.trim(),
                added: initialStock,
                sold: 0,
                buyPrice: buyPrice,
                sellPrice: sellPrice,
                salesByDay: <int, int>{},
                salesBySalesman: <String, Map<String, int>>{},
                salesmanDiscounts: <String, int>{},
                discountAmount: 0,
              );
              setState(() {
                _products.insert(0, newProduct);
              });
              _addProductToFirestore(newProduct);
              Navigator.pop(context);
            },
            child: const Text('Simpan produk'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  void _adjustStock(Product product, bool isIncoming) {
    final TextEditingController quantity = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(isIncoming ? 'Tambah stok' : 'Catat produk terjual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _dialogField(quantity, 'Jumlah produk', Icons.numbers_outlined, number: true),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final int? value = int.tryParse(quantity.text);
              if (value == null || value <= 0 || (!isIncoming && value > product.remaining)) return;
              setState(() {
                if (isIncoming) {
                  product.added += value;
                } else {
                  product.sold += value;
                  final int day = DateTime.now().day;
                  product.salesByDay[day] = (product.salesByDay[day] ?? 0) + value;
                }
              });
              _syncProduct(product);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showPriceDialog(Product product) {
    final TextEditingController buy = TextEditingController(text: product.buyPrice.toString());
    final TextEditingController sell = TextEditingController(text: product.sellPrice.toString());
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Ubah harga produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _dialogField(buy, 'Harga beli', Icons.shopping_bag_outlined, number: true),
            _dialogField(sell, 'Harga jual', Icons.sell_outlined, number: true),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final int? buyPrice = int.tryParse(buy.text);
              final int? sellPrice = int.tryParse(sell.text);
              if (buyPrice == null || sellPrice == null || buyPrice < 0 || sellPrice < buyPrice) return;
              setState(() {
                product.buyPrice = buyPrice;
                product.sellPrice = sellPrice;
              });
              _syncProduct(product);
              Navigator.pop(context);
            },
            child: const Text('Simpan harga'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 760;
    final List<Product> products = _filteredProducts;
    return Scaffold(
      drawer: compact ? Drawer(child: _sideNav()) : null,
      body: Row(
        children: <Widget>[
          if (!compact) SizedBox(width: 244, child: _sideNav()),
          Expanded(
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  _topBar(compact),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 18 : 30),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _pageContent(products, compact),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideNav() {
    return Container(
      color: const Color(0xFF123A36),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(22, 28, 20, 26),
            alignment: Alignment.centerLeft,
            child: Row(children: <Widget>[
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFFEAB308), borderRadius: BorderRadius.circular(7)),
                child: const Icon(Icons.warehouse_outlined, color: Color(0xFF123A36)),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('KENAN\nPUTRA JAYA', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.25))),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFF315A55)),
          const SizedBox(height: 16),
          _navItem(Icons.grid_view_rounded, 'Ringkasan', 0),
          _navItem(Icons.inventory_2_rounded, 'Stok Produk', 1),
          _navItem(Icons.percent_rounded, 'Diskon', 7),
          _navItem(Icons.history_rounded, 'Riwayat Stok', 2),
          _navItem(Icons.receipt_long_outlined, 'Laporan Penjualan', 3),
          _navItem(Icons.account_balance_wallet_outlined, 'Cashflow', 8),
          _navItem(Icons.people_alt_outlined, 'Laporan Salesman', 5),
          _navItem(Icons.trending_up_rounded, 'Laporan Margin', 6),
          const Spacer(),
          const Divider(height: 1, color: Color(0xFF315A55)),
          _navItem(Icons.settings_outlined, 'Pengaturan', 4),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFB7CFCA), size: 21),
              title: const Text('Keluar', style: TextStyle(color: Color(0xFFCEE0DC), fontWeight: FontWeight.w400, fontSize: 14)),
              onTap: () async {
                if (widget.enableFirebase) {
                  await FirebaseAuth.instance.signOut();
                }
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        LoginPage(enableFirebase: widget.enableFirebase),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = _activeMenu == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(color: selected ? const Color(0xFF1A5B54) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: selected ? const Color(0xFFFFD34E) : const Color(0xFFB7CFCA), size: 21),
        title: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFFCEE0DC), fontWeight: selected ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
        onTap: () {
          setState(() => _activeMenu = index);
          if (MediaQuery.of(context).size.width < 760) Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _pageContent(List<Product> products, bool compact) {
    if (_activeMenu == 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Ringkasan Gudang', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Ikhtisar persediaan snack kemasan hari ini.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _summaryGrid(compact),
        const SizedBox(height: 30),
        _infoPanel(Icons.inventory_2_outlined, 'Stok perlu diperhatikan', '${_products.where((Product p) => p.remaining < 25).length} produk memiliki stok di bawah 25 pack.'),
        const SizedBox(height: 24),
        _salesmanRevenuePanel(compact),
      ]);
    }
    if (_activeMenu == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Stok Produk', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Pantau persediaan dan pergerakan snack kemasan.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _summaryGrid(compact),
        const SizedBox(height: 30),
        _stockPanel(products, compact),
      ]);
    }
    if (_activeMenu == 7) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Diskon Produk', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Atur potongan harga per produk. Harga diskon akan digunakan pada input penjualan salesman.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _discountPanel(compact),
      ]);
    }
    if (_activeMenu == 3) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Laporan Penjualan Sales', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Rekap penjualan berdasarkan tanggal dalam bulan ini.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _salesReport(products, compact),
      ]);
    }
    if (_activeMenu == 8) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Cashflow', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Ringkasan arus kas penjualan dan modal barang terjual.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _cashflowPanel(products, compact),
      ]);
    }
    if (_activeMenu == 5) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Laporan Penjualan Salesman', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Pilih nama salesman untuk melihat rekap penjualannya.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _salesmanReport(compact),
      ]);
    }
    if (_activeMenu == 6) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Laporan Margin', style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
        const SizedBox(height: 6),
        const Text('Rekap margin penjualan berdasarkan hari dan bulan.', style: TextStyle(color: Color(0xFF627370), fontSize: 15)),
        const SizedBox(height: 24),
        _marginReport(products, compact),
      ]);
    }
    final String title = _activeMenu == 2 ? 'Riwayat Stok' : 'Pengaturan';
    final String description = _activeMenu == 2
        ? 'Riwayat aktivitas stok akan tercatat saat stok masuk atau produk terjual disimpan.'
        : 'Kelola preferensi operasional gudang Anda.';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text(title, style: TextStyle(fontSize: compact ? 26 : 30, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
      const SizedBox(height: 6),
      Text(description, style: const TextStyle(color: Color(0xFF627370), fontSize: 15)),
      const SizedBox(height: 24),
      _infoPanel(_activeMenu == 2 ? Icons.history_rounded : Icons.settings_outlined, title, description),
    ]);
  }

  Widget _cashflowPanel(List<Product> products, bool compact) {
    final int income = _dailySalesTotal(products);
    final int cost = _dailyCostTotal(products);
    final int netCash = income - cost;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
        child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 18, runSpacing: 12, children: <Widget>[const Text('Periode Cashflow', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF17312F))), _salesDateFilters()]),
      ),
      const SizedBox(height: 18),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: compact ? 1 : 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: compact ? 3.4 : 1.9,
        children: <Widget>[
          _cashflowCard('Uang Masuk', _money(income), Icons.south_west_rounded, const Color(0xFF0D7A5F), const Color(0xFFE1F3EB)),
          _cashflowCard('Modal Barang Terjual', _money(cost), Icons.north_east_rounded, const Color(0xFFB45309), const Color(0xFFFFE9D4)),
          _cashflowCard('Arus Kas Bersih', _money(netCash), Icons.account_balance_wallet_outlined, const Color(0xFF1769AA), const Color(0xFFE5F1FA)),
        ],
      ),
      const SizedBox(height: 22),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
        child: Row(children: <Widget>[Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFE1F1EB), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.calendar_today_outlined, size: 19, color: Color(0xFF0D5C54))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Rekap $_salesDateLabel', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF17312F))), const SizedBox(height: 3), Text('Arus kas bersih dari penjualan hari ini sebesar ${_money(netCash)}.', style: const TextStyle(fontSize: 13, color: Color(0xFF627370)))]))]),
      ),
    ]);
  }

  Widget _cashflowCard(String label, String value, IconData icon, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Container(width: 34, height: 34, decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 19, color: color)), const Spacer(), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF70817D)))]),
    );
  }

  Widget _salesReport(List<Product> products, bool compact) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 16, spacing: 18, children: <Widget>[
            SizedBox(width: 260, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Penjualan $_salesDateLabel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), const SizedBox(height: 4), Text('${products.length} produk tercatat dalam laporan sales.', style: const TextStyle(fontSize: 13, color: Color(0xFF70817D)))])),
            _salesDateFilters(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[const Text('TOTAL PENJUALAN', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF70817D), fontSize: 11)), const SizedBox(height: 4), Text(_money(_dailySalesTotal(products)), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54), fontSize: 18))]),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE4EAE7)),
        if (compact)
          Column(children: products.map((Product product) { final int sales = _dailySalesFor(product, _selectedSalesDay); final int price = _salesPriceFor(product); return ListTile(title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('$sales pack x ${_money(price)}'), trailing: Text(_money(sales * price), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))); }).toList())
        else
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F8F7)),
            columnSpacing: 52,
            horizontalMargin: 20,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF627370), fontSize: 12),
            columns: const <DataColumn>[DataColumn(label: Text('NAMA PRODUK')), DataColumn(label: Text('PENJUALAN HARIAN')), DataColumn(label: Text('HARGA PRODUK')), DataColumn(label: Text('TOTAL HARGA PENJUALAN'))],
            rows: products.map((Product product) => DataRow(cells: <DataCell>[
              DataCell(Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27433F)))),
              DataCell(Text('${_dailySalesFor(product, _selectedSalesDay)} pack')),
              DataCell(Text(_money(_salesPriceFor(product)))),
              DataCell(Text(_money(_dailySalesFor(product, _selectedSalesDay) * _salesPriceFor(product)), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))),
            ])).toList(),
          )),
        Padding(padding: const EdgeInsets.all(16), child: Text('Total penjualan $_salesDateLabel: ${_money(_dailySalesTotal(products))}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF17312F)))),
      ]),
    );
  }

  Widget _discountPanel(bool compact) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Wrap(spacing: 10, runSpacing: 10, children: <Widget>[
        ChoiceChip(label: const Text('Diskon Global'), selected: _isGlobalDiscount, onSelected: (bool selected) { if (selected) setState(() => _isGlobalDiscount = true); }),
        ChoiceChip(label: const Text('Diskon Per Salesman'), selected: !_isGlobalDiscount, onSelected: (bool selected) { if (selected) setState(() => _isGlobalDiscount = false); }),
      ]),
      const SizedBox(height: 16),
      _isGlobalDiscount ? _globalDiscountPanel(compact) : _salesmanDiscountPanel(compact),
    ]);
  }

  Widget _globalDiscountPanel(bool compact) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const <Widget>[Text('Daftar Diskon Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), SizedBox(height: 4), Text('Masukkan nilai potongan dalam rupiah.', style: TextStyle(fontSize: 13, color: Color(0xFF70817D)))])),
        const Divider(height: 1, color: Color(0xFFE4EAE7)),
        if (compact)
          Column(children: _products.map((Product product) {
            return ListTile(
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${_money(product.sellPrice)}  ->  ${_money(_salesPriceFor(product))}'),
              trailing: SizedBox(width: 90, child: TextFormField(initialValue: product.discountAmount.toString(), textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ', isDense: true, border: OutlineInputBorder()), onChanged: (String value) { final int? discount = int.tryParse(value); if (discount != null) { setState(() => product.discountAmount = discount.clamp(0, product.sellPrice) as int); _syncProduct(product); } })),
            );
          }).toList())
        else
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F8F7)),
            columnSpacing: 42,
            horizontalMargin: 20,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF627370), fontSize: 12),
            columns: const <DataColumn>[DataColumn(label: Text('NAMA PRODUK')), DataColumn(label: Text('HARGA NORMAL')), DataColumn(label: Text('POTONGAN')), DataColumn(label: Text('HARGA SETELAH DISKON'))],
            rows: _products.map((Product product) => DataRow(cells: <DataCell>[
              DataCell(Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27433F)))),
              DataCell(Text(_money(product.sellPrice))),
              DataCell(SizedBox(width: 106, child: TextFormField(initialValue: product.discountAmount.toString(), textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ', isDense: true, border: OutlineInputBorder()), onChanged: (String value) { final int? discount = int.tryParse(value); if (discount != null) { setState(() => product.discountAmount = discount.clamp(0, product.sellPrice) as int); _syncProduct(product); } }))),
              DataCell(Text(_money(_salesPriceFor(product)), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))),
            ])).toList(),
          )),
      ]),
    );
  }

  Widget _salesmanDiscountPanel(bool compact) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(padding: const EdgeInsets.all(20), child: Wrap(alignment: WrapAlignment.spaceBetween, spacing: 18, runSpacing: 12, children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const <Widget>[Text('Diskon Per Salesman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), SizedBox(height: 4), Text('Potongan tambahan berlaku untuk salesman terpilih.', style: TextStyle(fontSize: 13, color: Color(0xFF70817D)))]),
          DropdownButton<String>(value: _discountSalesman, underline: const SizedBox(), items: _salesmen.map((String salesman) => DropdownMenuItem<String>(value: salesman, child: Text(salesman))).toList(), onChanged: (String? salesman) { if (salesman != null) setState(() => _discountSalesman = salesman); }),
        ])),
        const Divider(height: 1, color: Color(0xFFE4EAE7)),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F8F7)),
          columnSpacing: 38,
          horizontalMargin: 20,
          headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF627370), fontSize: 12),
          columns: const <DataColumn>[DataColumn(label: Text('NAMA PRODUK')), DataColumn(label: Text('HARGA SETELAH GLOBAL')), DataColumn(label: Text('POTONGAN SALESMAN')), DataColumn(label: Text('HARGA SALESMAN'))],
          rows: _products.map((Product product) => DataRow(cells: <DataCell>[
            DataCell(Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27433F)))),
            DataCell(Text(_money(_salesPriceFor(product)))),
            DataCell(SizedBox(width: 118, child: TextFormField(initialValue: (product.salesmanDiscounts[_discountSalesman] ?? 0).toString(), textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rp ', isDense: true, border: OutlineInputBorder()), onChanged: (String value) { final int? discount = int.tryParse(value); if (discount != null) { setState(() => product.salesmanDiscounts[_discountSalesman] = discount.clamp(0, _salesPriceFor(product)) as int); _syncProduct(product); } }))),
            DataCell(Text(_money(_salesPriceFor(product, salesman: _discountSalesman)), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))),
          ])).toList(),
        )),
      ]),
    );
  }

  Widget _salesmanReport(bool compact) {
    final int salesmanRevenue = _salesmanRevenue(_selectedSalesman);
    final int salesmanPacks = _salesmanPacks(_selectedSalesman);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
        child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 18, runSpacing: 10, children: <Widget>[const Text('Filter tanggal laporan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF17312F))), _salesDateFilters(), OutlinedButton.icon(onPressed: _showAddSalesmanDialog, icon: const Icon(Icons.person_add_alt_1_outlined, size: 18), label: const Text('Tambah Salesman')), OutlinedButton.icon(onPressed: () => _showSalesmanSaleDialog(revision: true), icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Revisi Input')), ElevatedButton.icon(onPressed: _showSalesmanSaleDialog, icon: const Icon(Icons.add, size: 18), label: const Text('Input Penjualan'), style: ElevatedButton.styleFrom(elevation: 0, minimumSize: const Size(0, 40)))]),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: compact ? 2 : 3, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: compact ? 1.7 : 2.5),
        itemCount: _salesmen.length,
        itemBuilder: (BuildContext context, int index) {
          final String salesman = _salesmen[index];
          final bool selected = salesman == _selectedSalesman;
          return Material(
            color: selected ? const Color(0xFF0D5C54) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _selectedSalesman = salesman),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: selected ? const Color(0xFF0D5C54) : const Color(0xFFE1E8E5))),
                child: Row(children: <Widget>[
                  CircleAvatar(backgroundColor: selected ? const Color(0xFFFFD34E) : const Color(0xFFE1F1EB), child: Text(salesman.substring(0, 1), style: TextStyle(fontWeight: FontWeight.w700, color: selected ? const Color(0xFF123A36) : const Color(0xFF0D5C54)))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(salesman, style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF17312F), fontSize: 16))),
                ]),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Rekap $_selectedSalesman - $_salesDateLabel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))),
          const SizedBox(height: 18),
          Wrap(spacing: 42, runSpacing: 18, children: <Widget>[
            _salesmanMetric('Produk Terjual', '$salesmanPacks pack', Icons.inventory_2_outlined, const Color(0xFF1769AA)),
            _salesmanMetric('Total Penjualan', _money(salesmanRevenue), Icons.account_balance_wallet_outlined, const Color(0xFF0D5C54)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _marginReport(List<Product> products, bool compact) {
    final int totalMargin = products.fold(0, (int total, Product p) => total + (_dailySalesFor(p, _selectedSalesDay) * p.margin));
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 14, spacing: 18, children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Margin $_salesDateLabel', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), const SizedBox(height: 4), const Text('Margin dari produk yang terjual.', style: TextStyle(fontSize: 13, color: Color(0xFF70817D)))]),
            _salesDateFilters(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[const Text('TOTAL MARGIN', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF70817D), fontSize: 11)), const SizedBox(height: 4), Text(_money(totalMargin), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D7A5F), fontSize: 18))]),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE4EAE7)),
        if (compact)
          Column(children: products.map((Product product) { final int sold = _dailySalesFor(product, _selectedSalesDay); return ListTile(title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('$sold pack x ${_money(product.margin)} margin'), trailing: Text(_money(sold * product.margin), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D7A5F)))); }).toList())
        else
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F8F7)),
            columnSpacing: 48,
            horizontalMargin: 20,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF627370), fontSize: 12),
            columns: const <DataColumn>[DataColumn(label: Text('NAMA PRODUK')), DataColumn(label: Text('TERJUAL')), DataColumn(label: Text('MARGIN / PACK')), DataColumn(label: Text('TOTAL MARGIN'))],
            rows: products.map((Product product) { final int sold = _dailySalesFor(product, _selectedSalesDay); return DataRow(cells: <DataCell>[
              DataCell(Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27433F)))),
              DataCell(Text('$sold pack')),
              DataCell(Text(_money(product.margin))),
              DataCell(Text(_money(sold * product.margin), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D7A5F)))),
            ]); }).toList(),
          )),
        Padding(padding: const EdgeInsets.all(16), child: Text('Total margin $_salesDateLabel: ${_money(totalMargin)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF17312F)))),
      ]),
    );
  }

  Widget _salesmanMetric(String label, String value, IconData icon, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF70817D))), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF17312F), fontSize: 16))]),
    ]);
  }

  Widget _salesDateFilters() {
    return Wrap(spacing: 10, runSpacing: 8, children: <Widget>[
      DropdownButton<int>(
        value: _selectedSalesDay,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: List<DropdownMenuItem<int>>.generate(_daysInSelectedMonth, (int index) {
          final int day = index + 1;
          return DropdownMenuItem<int>(value: day, child: Text('$day'));
        }),
        onChanged: (int? day) {
          if (day != null) setState(() => _selectedSalesDay = day);
        },
      ),
      DropdownButton<int>(
        value: _selectedSalesMonth,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: List<DropdownMenuItem<int>>.generate(_months.length, (int index) => DropdownMenuItem<int>(value: index + 1, child: Text(_months[index]))),
        onChanged: (int? month) {
          if (month != null) _selectSalesMonth(month);
        },
      ),
    ]);
  }

  Widget _infoPanel(IconData icon, String title, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Row(children: <Widget>[
        Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFE1F1EB), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: const Color(0xFF0D5C54))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF17312F))), const SizedBox(height: 4), Text(message, style: const TextStyle(color: Color(0xFF627370), fontSize: 13))])),
      ]),
    );
  }

  Widget _topBar(bool compact) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 30),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE5EBE8)))),
      child: Row(children: <Widget>[
        if (compact) Builder(builder: (BuildContext context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        const Spacer(),
        IconButton(onPressed: () {}, tooltip: 'Notifikasi', icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF55706B))),
        const SizedBox(width: 8),
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE6F0EC), child: Text('KP', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54), fontSize: 13))),
        if (!compact) ...<Widget>[const SizedBox(width: 10), const Text('Admin Gudang', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF17312F)))],
      ]),
    );
  }

  Widget _salesmanRevenuePanel(bool compact) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(padding: const EdgeInsets.all(20), child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 18, runSpacing: 12, children: <Widget>[const Text('Omzet Salesman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), _revenuePeriodFilters()])),
        const Divider(height: 1, color: Color(0xFFE4EAE7)),
        if (compact)
          Column(children: _salesmen.map((String salesman) {
            return ListTile(
              title: Text(salesman, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Harian ${_money(_salesmanRevenuePeriod(salesman, 'daily'))}  |  Mingguan ${_money(_salesmanRevenuePeriod(salesman, 'weekly'))}'),
              trailing: Text(_money(_salesmanRevenuePeriod(salesman, 'monthly')), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0D5C54))),
            );
          }).toList())
        else
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F8F7)),
            horizontalMargin: 20,
            columnSpacing: 70,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF627370), fontSize: 12),
            columns: const <DataColumn>[DataColumn(label: Text('NAMA SALESMAN')), DataColumn(label: Text('HARIAN')), DataColumn(label: Text('MINGGUAN')), DataColumn(label: Text('BULANAN'))],
            rows: _salesmen.map((String salesman) => DataRow(cells: <DataCell>[
              DataCell(Text(salesman, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF27433F)))),
              DataCell(Text(_money(_salesmanRevenuePeriod(salesman, 'daily')))),
              DataCell(Text(_money(_salesmanRevenuePeriod(salesman, 'weekly')))),
              DataCell(Text(_money(_salesmanRevenuePeriod(salesman, 'monthly')), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D5C54)))),
            ])).toList(),
          )),
        const Padding(padding: EdgeInsets.all(16), child: Text('Omzet dihitung dari transaksi yang diinput admin.', style: TextStyle(fontSize: 12, color: Color(0xFF70817D)))),
      ]),
    );
  }

  Widget _revenuePeriodFilters() {
    return Wrap(spacing: 10, runSpacing: 8, children: <Widget>[
      DropdownButton<int>(value: _revenueDay, underline: const SizedBox(), items: List<DropdownMenuItem<int>>.generate(_revenueDaysInMonth, (int index) => DropdownMenuItem<int>(value: index + 1, child: Text('Tanggal ${index + 1}'))), onChanged: (int? day) { if (day != null) setState(() { _revenueDay = day; _revenueWeek = ((day - 1) ~/ 7) + 1; }); }),
      DropdownButton<int>(value: _revenueWeek, underline: const SizedBox(), items: List<DropdownMenuItem<int>>.generate((_revenueDaysInMonth / 7).ceil(), (int index) => DropdownMenuItem<int>(value: index + 1, child: Text('Minggu ke-${index + 1}'))), onChanged: (int? week) { if (week != null) setState(() => _revenueWeek = week); }),
      DropdownButton<int>(value: _revenueMonth, underline: const SizedBox(), items: List<DropdownMenuItem<int>>.generate(_months.length, (int index) => DropdownMenuItem<int>(value: index + 1, child: Text(_months[index]))), onChanged: (int? month) { if (month != null) setState(() { _revenueMonth = month; if (_revenueDay > _revenueDaysInMonth) _revenueDay = _revenueDaysInMonth; _revenueWeek = ((_revenueDay - 1) ~/ 7) + 1; }); }),
    ]);
  }

  Widget _summaryGrid(bool compact) {
    final List<_Summary> summaries = <_Summary>[
      _Summary('Total Produk', '${_products.length} Item', Icons.inventory_2_outlined, const Color(0xFF0D5C54), const Color(0xFFE1F1EB)),
      _Summary('Sisa Stok', '$_totalStock Pack', Icons.layers_outlined, const Color(0xFF1769AA), const Color(0xFFE5F1FA)),
      _Summary('Nilai Persediaan', _money(_totalCapital), Icons.account_balance_wallet_outlined, const Color(0xFF9A5717), const Color(0xFFFFF0D9)),
      _Summary('Potensi Margin', _money(_potentialMargin), Icons.trending_up_rounded, const Color(0xFF6D4796), const Color(0xFFF0E7F8)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: compact ? 2 : 4, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: compact ? 1.25 : 1.7),
      itemCount: summaries.length,
      itemBuilder: (BuildContext context, int index) {
        final _Summary item = summaries[index];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE4EAE7))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Container(width: 34, height: 34, decoration: BoxDecoration(color: item.light, borderRadius: BorderRadius.circular(6)), child: Icon(item.icon, color: item.color, size: 19)),
            const Spacer(),
            Text(item.value, style: TextStyle(fontSize: compact ? 17 : 20, fontWeight: FontWeight.w700, color: const Color(0xFF17312F))),
            const SizedBox(height: 3), Text(item.label, style: const TextStyle(color: Color(0xFF70817D), fontSize: 12)),
          ]),
        );
      },
    );
  }

  Widget _stockPanel(List<Product> products, bool compact) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE1E8E5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 14, spacing: 16, children: <Widget>[
            SizedBox(width: 260, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Daftar Stok Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF17312F))), const SizedBox(height: 4), const Text('Perbarui stok sesuai transaksi gudang.', style: TextStyle(color: Color(0xFF70817D), fontSize: 13))])),
            Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(width: compact ? 150 : 220, height: 40, child: TextField(controller: _searchController, onChanged: (String value) => setState(() => _query = value), decoration: InputDecoration(hintText: 'Cari produk', prefixIcon: const Icon(Icons.search, size: 20), filled: true, fillColor: const Color(0xFFF7F9F8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFDDE6E2))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFDDE6E2))), contentPadding: EdgeInsets.zero))),
              const SizedBox(width: 10),
              Tooltip(message: 'Tambah produk', child: ElevatedButton.icon(onPressed: _showProductDialog, icon: const Icon(Icons.add, size: 18), label: Text(compact ? 'Tambah' : 'Tambah Produk'), style: ElevatedButton.styleFrom(elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16), minimumSize: const Size(0, 40)))),
            ]),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE4EAE7)),
        if (compact) _mobileList(products) else _desktopTable(products),
        Padding(padding: const EdgeInsets.all(16), child: Text('Menampilkan ${products.length} dari ${_products.length} produk', style: const TextStyle(fontSize: 12, color: Color(0xFF70817D)))),
      ]),
    );
  }

  Widget _desktopTable(List<Product> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F8F7)),
        columnSpacing: 25,
        horizontalMargin: 20,
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF627370), fontSize: 12),
        columns: const <DataColumn>[DataColumn(label: Text('NAMA PRODUK')), DataColumn(label: Text('STOK AWAL')), DataColumn(label: Text('TERJUAL')), DataColumn(label: Text('SISA STOK')), DataColumn(label: Text('HARGA BELI')), DataColumn(label: Text('HARGA JUAL')), DataColumn(label: Text('MARGIN')), DataColumn(label: Text('AKSI'))],
        rows: products.map((Product product) => DataRow(cells: <DataCell>[
          DataCell(Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27433F)))),
          DataCell(Text('${product.added} pack')),
          DataCell(Text('${product.sold} pack')),
          DataCell(_stockBadge(product.remaining)),
          DataCell(Text(_money(product.buyPrice))),
          DataCell(Text(_money(product.sellPrice))),
          DataCell(Text(_money(product.margin), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D7A5F)))),
          DataCell(Row(mainAxisSize: MainAxisSize.min, children: <Widget>[IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), color: const Color(0xFF0D5C54), tooltip: 'Tambah stok', onPressed: () => _adjustStock(product, true)), IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), color: const Color(0xFFB45309), tooltip: 'Catat penjualan', onPressed: () => _adjustStock(product, false)), IconButton(icon: const Icon(Icons.edit_outlined, size: 20), color: const Color(0xFF526C67), tooltip: 'Ubah harga', onPressed: () => _showPriceDialog(product))])),
        ])).toList(),
      ),
    );
  }

  Widget _mobileList(List<Product> products) {
    return Column(children: products.map((Product product) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF9FBFA), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE4EAE7))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF27433F)))), _stockBadge(product.remaining)]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text('Masuk ${product.added} pack  |  Terjual ${product.sold} pack', style: const TextStyle(fontSize: 12, color: Color(0xFF627370))), Text(_money(product.margin), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D7A5F)))]),
        const SizedBox(height: 8), Row(children: <Widget>[Text('Beli ${_money(product.buyPrice)}', style: const TextStyle(fontSize: 12, color: Color(0xFF627370))), const Spacer(), IconButton(visualDensity: VisualDensity.compact, tooltip: 'Tambah stok', onPressed: () => _adjustStock(product, true), icon: const Icon(Icons.add_circle_outline), color: const Color(0xFF0D5C54)), IconButton(visualDensity: VisualDensity.compact, tooltip: 'Catat penjualan', onPressed: () => _adjustStock(product, false), icon: const Icon(Icons.remove_circle_outline), color: const Color(0xFFB45309)), IconButton(visualDensity: VisualDensity.compact, tooltip: 'Ubah harga', onPressed: () => _showPriceDialog(product), icon: const Icon(Icons.edit_outlined), color: const Color(0xFF526C67))]),
      ])),
    )).toList());
  }

  Widget _stockBadge(int value) {
    final bool low = value < 25;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: low ? const Color(0xFFFFE9D4) : const Color(0xFFE1F3EB), borderRadius: BorderRadius.circular(20)), child: Text('$value pack', style: TextStyle(color: low ? const Color(0xFF9A5717) : const Color(0xFF0D6B52), fontSize: 12, fontWeight: FontWeight.w700)));
  }
}

class _Summary {
  const _Summary(this.label, this.value, this.icon, this.color, this.light);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color light;
}
