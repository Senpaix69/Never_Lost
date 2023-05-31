import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/utils.dart'
    show passwordValidate, showSnackBar, textValidate, rePasswordValidate;
import 'package:neverlost/widgets/dialog_boxs.dart' show errorDialogue;
import 'package:neverlost/widgets/loading/loading_screen.dart';
import 'package:neverlost/widgets/styles.dart' show textFormField;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _repassword;
  late final TextEditingController _fname;
  late final TextEditingController _lname;
  late String? _imageFile;

  bool _hidePass = true;
  bool _hideRePass = true;

  void toggleHidePassword({bool rePassword = false}) {
    setState(() {
      if (rePassword) {
        _hideRePass = !_hideRePass;
      } else {
        _hidePass = !_hidePass;
      }
    });
  }

  final _formKey = GlobalKey<FormState>();

  void _pickImage() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (pickedFile != null) {
      setState(
        () => _imageFile = pickedFile.files.single.path,
      );
    }
  }

  void notConnectedToInternet() {
    errorDialogue(
      context: context,
      title: "No Internet Connection",
      message: "You are not connected to internet",
    );
    LoadingScreen.instance().hide();
  }

  Future<void> _createUser() async {
    LoadingScreen.instance().show(
      context: context,
      text: "Registering...",
    );
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      notConnectedToInternet();
      return;
    }
    String? profilePic = _imageFile;
    String displayName = '${_fname.text.trim()} ${_lname.text.trim()}';

    try {
      final success =
          await FirebaseService.instance().createUserWithEmailPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
        fullName: displayName,
        profilePicPath: profilePic,
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
        showSnack(message: "User registered successfully!");
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
  void initState() {
    _imageFile = null;
    _email = TextEditingController();
    _fname = TextEditingController();
    _lname = TextEditingController();
    _password = TextEditingController();
    _repassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _repassword.dispose();
    _fname.dispose();
    _lname.dispose();
    super.dispose();
  }

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
                    child: Stack(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.grey[900],
                          radius: 70,
                          child: _imageFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_imageFile!),
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 80.0,
                                  color: Colors.white,
                                ),
                        ),
                        Positioned(
                          bottom: -5,
                          right: -4,
                          child: Center(
                            child: IconButton(
                              onPressed: () => _pickImage(),
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[400],
                              ),
                              iconSize: 40.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Center(
                    child: Text(
                      "Profile Pic",
                      style: TextStyle(
                        fontSize: 15.0,
                        letterSpacing: 0.6,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  textFormField(
                    key: 0,
                    icon: Icons.email,
                    controller: _email,
                    hint: "Enter email",
                    validator: textValidate,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: textFormField(
                          key: 1,
                          icon: Icons.person_pin,
                          controller: _fname,
                          hint: "First name",
                          validator: textValidate,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: textFormField(
                          key: 2,
                          icon: Icons.person_pin,
                          hint: "Last name",
                          controller: _lname,
                          validator: textValidate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  textFormField(
                    key: 3,
                    icon: Icons.password,
                    controller: _password,
                    hint: "Enter password",
                    obsecure: _hideRePass,
                    validator: passwordValidate,
                    callback: () => toggleHidePassword(rePassword: true),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  textFormField(
                    key: 4,
                    icon: Icons.password,
                    obsecure: _hidePass,
                    hint: "Enter password again",
                    controller: _repassword,
                    validator: (value) => rePasswordValidate(
                      value,
                      _password.text.trim(),
                    ),
                    callback: toggleHidePassword,
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
                            (states) => Colors.grey.shade700,
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
                            await _createUser();
                          }
                        },
                        child: const Text(
                          "Register",
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
