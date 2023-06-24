import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qibla_finder/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../models/admin.dart';
import 'adminhomescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late double screenHeight, screenWidth, controlWidth;
  bool remember = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height; //to get value screen
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 800) {
      controlWidth = screenWidth / 1.5;
    }
    if (screenWidth < 800) {
      controlWidth = screenWidth;
    }
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: SizedBox(
              width: controlWidth,
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                                height: screenHeight / 2.5,
                                width: screenWidth,
                                child: Image.asset(
                                    'assets/images/carikiblatlogo.png')),
                            Center(
                              child: const Text(
                                "Log Masuk Admin",
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: "Emel",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                              //keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Sila masukkan emel yang sah';
                                }
                                bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value);

                                if (!emailValid) {
                                  return 'Sila masukkan emel yang sah';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  hintText: "Kata Laluan",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                              //keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Sila masukkan kata laluan anda';
                                }
                                if (value.length < 6) {
                                  return "Panjang kata laluan sekurang-kurangnya enam (6) aksara";
                                }
                                return null;
                              },
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: remember,
                                  onChanged: (bool? value) {
                                    _onRememberMe(value!);
                                  },
                                ),
                                const Text("Simpan Maklumat Saya")
                              ],
                            ),
                            SizedBox(
                                width: screenWidth,
                                height: 50,
                                child: ElevatedButton(
                                  child: const Text("Log Masuk"),
                                  onPressed: _loginUser,
                                ))
                          ],
                        ),
                      ),
                    ],
                  )))),
    ));
  }

  void _saveRemovePref(bool value) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String email = emailController.text;
      String password = passwordController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (value) {
        await prefs.setString('email', email);
        await prefs.setString('pass', password);
        await prefs.setBool('remember', true);
        Fluttertoast.showToast(
            msg: "Maklumat Disimpan",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      } else {
        await prefs.setString('email', '');
        await prefs.setString('pass', '');
        await prefs.setBool('remember', false);
        emailController.text = "";
        passwordController.text = "";
        Fluttertoast.showToast(
            msg: "Maklumat Dibuang",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Gagal Simpan Maklumat",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      remember = false;
    }
  }

  void _onRememberMe(bool value) {
    remember = value;
    setState(() {
      if (remember) {
        _saveRemovePref(true);
      } else {
        _saveRemovePref(false);
      }
    });
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    remember = (prefs.getBool('remember')) ?? false;

    if (remember) {
      setState(() {
        emailController.text = email;
        passwordController.text = password;
        remember = true;
      });
    }
  }

  void _loginUser() {
    String _email = emailController.text;
    String _password = passwordController.text;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      http.post(
          Uri.parse(
              CONSTANTS.server + "/carikiblat/mobile/php/login_admin.php"),
          body: {"email": _email, "password": _password}).then((response) {
        var data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['status'] == 'success') {
          Admin admin = Admin.fromJson(data['data']);
          Fluttertoast.showToast(
              msg: "Berjaya",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) => AdminHomeScreen(
                        admin: admin,
                      )));
        } else {
          Fluttertoast.showToast(
              msg: "Gagal",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
        }
      });
    }
  }
}
