import 'package:flutter/material.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/utils.dart' show showSnackBar, textValidate;
import 'package:neverlost/widgets/dialog_boxs.dart' show errorDialogue;
import 'package:neverlost/widgets/loading/loading_screen.dart';
import 'package:neverlost/widgets/styles.dart' show textFormField;

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

  Future<void> _loginUser() async {
    LoadingScreen.instance().show(context: context, text: "Login in...");
    final email = _email.text.trim();
    final password = _password.text.trim();
    try {
      final success = await FirebaseService.instance().loginWithEmailPassword(
        email: email,
        password: password,
      );
      if (success != null) {
        LoadingScreen.instance().hide();
        Future.delayed(
          const Duration(milliseconds: 100),
          () => errorDialogue(
            context: context,
            message: success.dialogText,
            title: success.dialogTitle,
          ),
        );
      } else {
        LoadingScreen.instance().hide();
        showSnack(message: "Logged_In successfully!");
        Future.delayed(
          const Duration(milliseconds: 100),
          () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      LoadingScreen.instance().hide();
      showSnack(message: "Error occurred during saving SPUser");
    }
  }

  void showSnack({required String message}) => showSnackBar(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      backgroundImage: const AssetImage("assets/prof.png"),
                      backgroundColor: Colors.lightBlue.withAlpha(120),
                      radius: 70.0,
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  textFormField(
                    key: 8,
                    icon: Icons.email,
                    controller: _email,
                    validator: textValidate,
                    hint: "Enter email",
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  textFormField(
                    key: 9,
                    icon: Icons.password,
                    controller: _password,
                    validator: textValidate,
                    obsecure: true,
                    hint: "Enter password",
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
                            (states) => Colors.lightBlue,
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _loginUser();
                          }
                        },
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
