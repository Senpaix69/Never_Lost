import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:my_timetable/utils.dart' show textValidate;
import 'package:my_timetable/widgets/styles.dart' show textFormField;

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

  final _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;

  // void _pickImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() => _imageFile = pickedFile.path);
  //   }
  // }

  // Future<void> _createUser() async {
  //   try {
  //     String? profilePic = _imageFile;
  //     String displayName = '${_fname.text} ${_lname.text}';
  //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: _email.text,
  //       password: _password.text,
  //     );
  //     if (_imageFile != null) {
  //       final String downloadUrl = await uploadImage(image: File(_imageFile!));
  //       await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
  //     }
  //     await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);

  // creating user in db
  //     _notesService.createUser(
  //       email: _email.text,
  //       fullname: displayName,
  //       profilePic: profilePic,
  //     );

  //     await FirebaseAuth.instance.signOut();
  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       Navigator.of(context).pushReplacementNamed('/login');
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       await errorDialogue(context, "Weak Password");
  //     } else if (e.code == 'email-already-in-use') {
  //       await errorDialogue(context, "Email Already In Use");
  //     } else if (e.code == 'invalid-email') {
  //       await errorDialogue(context, "Invalid Email");
  //     } else {
  //       await errorDialogue(context, 'Error: ${e.code}');
  //     }
  //   } catch (e) {
  //     await errorDialogue(context, e.toString());
  //   }
  // }

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
                          backgroundColor: Colors.lightBlue.withAlpha(100),
                          radius: 70,
                          child: _imageFile != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_imageFile!),
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
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
                            child: _isRegistering
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      // _pickImage();
                                    },
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
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
                    icon: Icons.email,
                    enable: !_isRegistering,
                    controller: _email,
                    hint: "Enter email",
                    validator: textValidate,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: textFormField(
                          icon: Icons.person_pin,
                          enable: !_isRegistering,
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
                          icon: Icons.person_pin,
                          hint: "Last name",
                          enable: !_isRegistering,
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
                    icon: Icons.password,
                    enable: !_isRegistering,
                    controller: _password,
                    hint: "Enter password",
                    obsecure: true,
                    validator: textValidate,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  textFormField(
                    icon: Icons.password,
                    obsecure: true,
                    hint: "Enter password again",
                    enable: !_isRegistering,
                    controller: _repassword,
                    validator: textValidate,
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
                        onPressed: _isRegistering
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isRegistering = true);
                                  // await _createUser();
                                  setState(() => _isRegistering = false);
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
