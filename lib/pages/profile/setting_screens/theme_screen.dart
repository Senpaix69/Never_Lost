import 'package:flutter/material.dart';
import 'package:neverlost/theme/theme_provider.dart';
import 'package:neverlost/widgets/my_custom_tile.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  heading(text: "Themes", size: 30.0),
                ],
              ),
            ),
            MyCustomTile(
              icon: Icons.format_color_fill_rounded,
              onClick: () =>
                  themeProvider.setTheme(theme: themeProvider.navyBlue),
              iconBackGroundColor: Colors.deepPurple,
              title: "Navy Blue",
              trailing: false,
            ),
            MyCustomTile(
              icon: Icons.format_color_fill_rounded,
              onClick: () =>
                  themeProvider.setTheme(theme: themeProvider.blackFold),
              iconBackGroundColor: const Color(0xFF424242),
              title: "Black Fold",
              trailing: false,
            ),
          ],
        ),
      ),
    );
  }

  Padding heading({
    required String text,
    required double size,
    EdgeInsets padding = const EdgeInsets.all(0),
  }) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
