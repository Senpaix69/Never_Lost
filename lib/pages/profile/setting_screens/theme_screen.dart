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
      appBar: AppBar(
        title: const Text("About Developer"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
              title: "Grey Fold",
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
