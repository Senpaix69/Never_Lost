import 'package:flutter/material.dart';

InputDecoration decorationFormField(
  IconData prefixIcon,
  String hintText,
  BuildContext context, {
  IconData? suffixIcon,
  VoidCallback? callBack,
}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(15.0),
    prefixIcon: Icon(
      prefixIcon,
      color: Theme.of(context).shadowColor,
    ),
    suffixIcon: suffixIcon != null
        ? IconButton(
            icon: Icon(suffixIcon),
            onPressed: callBack,
          )
        : null,
    hintText: hintText,
    filled: true,
    fillColor: Theme.of(context).cardColor,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      borderSide: BorderSide.none,
    ),
  );
}

InputDecoration decorationPasswordFormField(
  IconData prefixIcon,
  String hintText,
  bool action,
  BuildContext context,
  VoidCallback callback,
) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(15.0),
    prefixIcon: Icon(
      prefixIcon,
      color: Theme.of(context).shadowColor,
    ),
    hintText: hintText,
    filled: true,
    fillColor: Theme.of(context).cardColor,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0),
      ),
      borderSide: BorderSide.none,
    ),
    suffixIcon: IconButton(
      onPressed: callback,
      icon: Icon(
        action ? Icons.visibility_off_rounded : Icons.visibility,
        color: Theme.of(context).secondaryHeaderColor,
      ),
    ),
  );
}

Text myText({
  required String text,
  Color? color,
  double size = 16.0,
}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: size,
      color: color,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
}

MaterialButton mySheetIcon({
  required BuildContext context,
  required Color backgroundColor,
  required String title,
  required IconData icon,
  required VoidCallback callback,
}) {
  return MaterialButton(
    onPressed: callback,
    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
    splashColor: Theme.of(context).primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: Column(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: backgroundColor,
          radius: 20.0,
          child: Icon(
            icon,
            color: Theme.of(context).secondaryHeaderColor,
            size: 23.0,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ],
    ),
  );
}

typedef CallbackAction<T> = void Function(T);
Container headerContainer({
  required String title,
  required IconData icon,
  required BuildContext context,
  bool reminder = false,
  Color? color,
  required CallbackAction<String>? onClick,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: myText(text: title, color: color),
        ),
        onClick != null
            ? Row(
                children: [
                  Icon(
                    reminder ? Icons.notifications_active : Icons.notifications,
                    size: 20.0,
                    color: reminder ? Colors.yellow : Colors.grey[200],
                  ),
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                    offset: const Offset(-13, 30),
                    elevation: 12,
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: reminder ? 'cancelReminder' : 'reminder',
                          child: Text(
                            reminder ? 'Cancel Reminder' : 'Set Reminder',
                            style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) => onClick(value),
                    color: Theme.of(context).primaryColorDark,
                    shadowColor: Theme.of(context).primaryColor,
                    icon: Icon(
                      Icons.menu_open_rounded,
                      color: Theme.of(context).indicatorColor,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.grey[200],
                ),
              ),
      ],
    ),
  );
}

Container textFormField({
  required BuildContext context,
  required TextEditingController controller,
  required int key,
  required String? Function(String?)? validator,
  required String hint,
  required IconData icon,
  bool enable = true,
  bool obsecure = false,
  VoidCallback? callback,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: TextFormField(
      key: ValueKey(key),
      enabled: enable,
      controller: controller,
      obscureText: obsecure,
      enableSuggestions: false,
      autocorrect: false,
      decoration: callback != null
          ? decorationPasswordFormField(icon, hint, obsecure, context, callback)
          : decorationFormField(icon, hint, context),
      validator: validator,
    ),
  );
}
