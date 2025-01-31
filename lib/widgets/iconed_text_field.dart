import 'package:flutter/material.dart';

class IconedTextField extends StatefulWidget {
  final Text text;
  final Icon icon;
  final Color? iconColor;
  final Function(String?)? validator;
  final Function(String?)? onSaved;

  const IconedTextField(
      {super.key,
      required this.text,
      required this.icon,
      this.iconColor,
      this.validator,
      this.onSaved});

  @override
  State<IconedTextField> createState() => _IconedTextFieldState();
}

class _IconedTextFieldState extends State<IconedTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        border: OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.email,
          color: Colors.grey,
        ),
      ),
      //validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }
}
