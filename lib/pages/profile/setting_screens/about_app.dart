import 'package:flutter/material.dart';
import 'package:neverlost/contants/profile_contants/about_app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About App"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      textMessageBold(
                        message: appName,
                        size: 18.0,
                      ),
                      textMessageBold(
                        message: "Version: $version",
                        size: 14.0,
                      ),
                      const SizedBox(height: 10.0),
                      const Text(aboutApp),
                      textMessageBold(
                        message: "Features:",
                        size: 18.0,
                      ),
                      const SizedBox(height: 14.0),
                      textMessageBold(
                        message: "- TimeTable:",
                        size: 18.0,
                      ),
                      const Text(aboutTimeTables),
                      const SizedBox(height: 12.0),
                      textMessageBold(
                        message: "- Notes:",
                        size: 18.0,
                      ),
                      const Text(aboutNotes),
                      const SizedBox(height: 12.0),
                      textMessageBold(
                        message: "- Todos:",
                        size: 18.0,
                      ),
                      const Text(aboutTodos),
                      const SizedBox(height: 16.0),
                      const Text(aboutMore),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textMessageBold({
    required String message,
    required double size,
    Color? color,
    bool align = false,
    double? padding,
  }) {
    return Text(
      message,
      style: TextStyle(
        height: padding,
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      textAlign: align ? TextAlign.center : null,
    );
  }
}
