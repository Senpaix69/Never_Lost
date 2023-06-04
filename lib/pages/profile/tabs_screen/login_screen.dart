import 'package:connectivity_plus/connectivity_plus.dart';
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
  final _formKey1 = GlobalKey<FormState>();
  final FirebaseService _firebase = FirebaseService.instance();
  final LoadingScreen _loading = LoadingScreen.instance();

  bool _hidePass = true;

  void toggleHidePassword() {
    setState(() {
      _hidePass = !_hidePass;
    });
  }

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

  void notConnectedToInternet() {
    errorDialogue(
      context: context,
      title: "No Internet Connection",
      message: "You are not connected to internet",
    );
    _loading.hide();
  }

  Future<void> _loginUser() async {
    _loading.show(context: context, text: "Login in...");
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      notConnectedToInternet();
      return;
    }
    final email = _email.text.trim();
    final password = _password.text.trim();
    try {
      final success = await _firebase.loginWithEmailPassword(
        email: email,
        password: password,
      );
      if (success != null) {
        _loading.hide();
        showDialogue(title: success.dialogTitle, text: success.dialogText);
      } else {
        _loading.hide();
        showSnack(message: "Logged_In successfully!");
        Future.delayed(
          const Duration(milliseconds: 100),
          () => Navigator.of(context).pop(),
        );
      }
    } catch (e) {
      _loading.hide();
      showSnack(message: "Error occurred during saving SPUser");
    }
  }

  void showSnack({required String message}) => showSnackBar(context, message);

  Future<void> signInWithGoogle() async {
    if (await _firebase.signInWithGoogle() == null) {
      Future.delayed(
        const Duration(milliseconds: 10),
        () => Navigator.of(context).pop(),
      );
    }
  }

  void showDialogue({required String title, required String text}) =>
      errorDialogue(
        context: context,
        message: text,
        title: title,
      );

  Future<void> resetPassword() async {
    _loading.show(context: context, text: "Please wait...");
    final success = await _firebase.resetPassword(email: _email.text.trim());
    if (success == null) {
      _loading.hide();
      showDialogue(
        text: "You will be receiving reset password email soon",
        title: "Reset Password Email Sent",
      );
      _loading.hide();
      return;
    }
    _loading.hide();
    showDialogue(text: success.dialogText, title: success.dialogTitle);
  }

  Future<void> forgotPassword() async {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (context) {
        return Form(
          key: _formKey1,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  textWidget(
                    mess: "Reset Your Password",
                    bold: true,
                    size: 18.0,
                    color: Theme.of(context).shadowColor,
                  ),
                  const Text(
                    "You will recieve an email to reset the password on the provided email please make sure that you are entering the correct email",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  textFormField(
                    context: context,
                    controller: _email,
                    key: 12,
                    validator: textValidate,
                    hint: "Enter your email",
                    icon: Icons.email,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0,
                        ),
                      ),
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Theme.of(context).primaryColorDark,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey1.currentState!.validate()) {
                        await resetPassword();
                      }
                    },
                    child: textWidget(
                      mess: "Send Email",
                      bold: true,
                      size: 18.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 63),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      backgroundImage: const AssetImage("assets/prof.png"),
                      backgroundColor: Theme.of(context).primaryColorDark,
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
                    context: context,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  textFormField(
                    key: 9,
                    icon: Icons.password,
                    controller: _password,
                    validator: textValidate,
                    obsecure: _hidePass,
                    hint: "Enter password",
                    callback: toggleHidePassword,
                    context: context,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: forgotPassword,
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0,
                        ),
                      ),
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Theme.of(context).primaryColorDark,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                    child: textWidget(
                      mess: "Login",
                      bold: true,
                      size: 18.0,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  textWidget(
                    mess: "< - - OR - - >",
                    center: true,
                    size: 18.0,
                    color: Theme.of(context).shadowColor,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 24.0,
                        ),
                      ),
                      backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Theme.of(context).canvasColor,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                    onPressed: () async => await signInWithGoogle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/google.png",
                          height: 25,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        textWidget(
                          color: Theme.of(context).shadowColor,
                          mess: "SignIn with Google",
                          size: 18,
                          bold: true,
                        ),
                      ],
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

  Text textWidget({
    required String mess,
    required double size,
    Color? color,
    bool? bold,
    bool? center,
  }) {
    return Text(
      mess,
      style: TextStyle(
        color: color ?? Colors.white,
        fontSize: size,
        fontWeight: bold != null && bold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: center != null ? TextAlign.center : null,
    );
  }
}
