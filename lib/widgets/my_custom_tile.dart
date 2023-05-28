import 'package:flutter/material.dart';

class MyCustomTile extends StatelessWidget {
  const MyCustomTile({
    super.key,
    required this.iconBackGroundColor,
    required this.icon,
    required this.onClick,
    required this.title,
    this.subTitle,
  });
  final Color iconBackGroundColor;
  final IconData icon;
  final VoidCallback onClick;
  final String title;
  final String? subTitle;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 18,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: iconBackGroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          icon,
          size: 30,
        ),
      ),
      onTap: onClick,
      tileColor: Colors.black.withAlpha(90),
      title: Text(title),
      subtitle: subTitle != null ? Text(subTitle!) : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey[700],
        size: 30,
      ),
    );
  }
}
