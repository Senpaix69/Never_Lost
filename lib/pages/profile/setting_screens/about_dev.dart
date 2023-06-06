import 'package:flutter/material.dart';
import 'package:neverlost/contants/profile_contants/about_dev_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloper extends StatelessWidget {
  const AboutDeveloper({super.key});

  Future<void> launchURL({
    required String url,
  }) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 30.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "About Developer",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    textMessageBold(
                      message: "Senpai",
                      size: 18.0,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(aboutDev),
                    const SizedBox(height: 20.0),
                    textMessageBold(
                      message: "For further queries:",
                      size: 16.0,
                    ),
                    const SizedBox(height: 10.0),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: const Text(aboutDevEmail),
                      leading: const Icon(Icons.email),
                      onTap: () async => await launchURL(
                        url:
                            'mailto:$aboutDevEmail?subject=Query&body=hello senpai?',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  socialIcon(
                    asset: "assets/insta.png",
                    color: const Color(0xFFFD1D1D),
                    callback: () async => await launchURL(
                      url: aboutDevInsta,
                    ),
                  ),
                  socialIcon(
                    asset: "assets/linkedin.png",
                    color: const Color(0xFF0077B5),
                    callback: () async => await launchURL(
                      url: aboutDevLinkedIn,
                    ),
                  ),
                  socialIcon(
                    asset: "assets/github.png",
                    color: Colors.black,
                    height: 54.0,
                    callback: () async => await launchURL(
                      url: aboutDevGitHub,
                    ),
                  ),
                  socialIcon(
                    asset: "assets/facebook.png",
                    color: const Color(0xFF1877F2),
                    callback: () async => await launchURL(
                      url: aboutDevLinkedIn,
                    ),
                  ),
                  socialIcon(
                    asset: "assets/youtube.png",
                    color: const Color(0xFFFF0000),
                    callback: () async => await launchURL(
                      url: aboutDevYouTube,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget socialIcon({
    required String asset,
    required Color color,
    required VoidCallback callback,
    double height = 32.0,
  }) {
    return MaterialButton(
      padding: EdgeInsets.zero,
      minWidth: height,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      splashColor: color,
      onPressed: callback,
      child: Container(
        padding: const EdgeInsets.all(10),
        height: height + 15,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.2),
              spreadRadius: 10,
              blurRadius: 6.0,
              offset: const Offset(0, 6),
            ),
          ],
          color: color,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          asset,
          height: height,
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
