import 'package:flutter/material.dart';

InputDecoration decorationFormField(
    IconData prefixIcon, String hintText, BuildContext context) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(15.0),
    prefixIcon: Icon(
      prefixIcon,
      color: Theme.of(context).colorScheme.inversePrimary,
    ),
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey[200],
    ),
    filled: true,
    fillColor: Theme.of(context).focusColor,
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
      color: Theme.of(context).colorScheme.inversePrimary,
    ),
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.grey[200],
    ),
    filled: true,
    fillColor: Theme.of(context).focusColor,
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
        color: Colors.grey[400],
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
                    color: reminder ? Colors.lightBlue : Colors.grey[300],
                  ),
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                    offset: const Offset(-13, 30),
                    elevation: 12,
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry>[
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'Edit',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                          ),
                        ),
                        PopupMenuItem(
                          value: reminder ? 'cancelReminder' : 'reminder',
                          child: Text(
                            reminder ? 'Cancel Reminder' : 'Set Reminder',
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) => onClick(value),
                    color: Theme.of(context).primaryColorLight,
                    shadowColor: Theme.of(context).primaryColorDark,
                    icon: const Icon(
                      Icons.menu_open_rounded,
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
      color: Colors.black,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: TextFormField(
      key: ValueKey(key),
      enabled: enable,
      controller: controller,
      obscureText: obsecure,
      enableSuggestions: false,
      autocorrect: false,
      style: const TextStyle(color: Colors.white),
      decoration: callback != null
          ? decorationPasswordFormField(icon, hint, obsecure, context, callback)
          : decorationFormField(icon, hint, context),
      validator: validator,
    ),
  );
}
