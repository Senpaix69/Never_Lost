import 'package:flutter/material.dart';
import 'package:my_timetable/utils.dart' show textValidate;
import 'package:my_timetable/widgets/styles.dart' show decorationFormField;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final _formKey = GlobalKey<FormState>();
  final RegExp regEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final bool _isLogin = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Login",
        ),
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/profBg.jpg"),
              fit: BoxFit.fitWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          width: double.infinity,
          height: double.infinity,
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      // backgroundColor: Colors.transparent,
                      // backgroundImage: AssetImage("assets/prof.png"),
                      backgroundColor: Colors.lightBlue.withAlpha(120),
                      radius: 80.0,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 100.0,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  TextFormField(
                    enabled: !_isLogin,
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: null,
                    decoration: decorationFormField(Icons.email, "Enter Email"),
                    cursorColor: Colors.amber[200],
                    style: const TextStyle(color: Colors.white),
                    validator: textValidate,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    enabled: !_isLogin,
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration:
                        decorationFormField(Icons.password, "Enter password"),
                    cursorColor: Colors.amber[200],
                    style: const TextStyle(color: Colors.white),
                    validator: textValidate,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.lightBlue.withAlpha(200),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    // onPressed: _isLogin
                    //     ? null
                    //     : () {
                    //         Navigator.of(context)
                    //             .pushReplacementNamed(registerRoute);
                    //       },
                    onPressed: () {},
                    child: Text(
                      "Click here to register",
                      style: TextStyle(
                        color: _isLogin ? Colors.grey : Colors.white,
                        fontSize: 13.0,
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
