import 'package:flutter/material.dart';

class Customtextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool? obscureText;
  final String? Function(String?)? validator;
  const Customtextfield({super.key, required this.hintText, this.obscureText = false,this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 11.0,right: 11),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.black,
        cursorHeight: 15,
        textInputAction: TextInputAction.next,
        obscureText: obscureText!,
        obscuringCharacter: "*",
        decoration: InputDecoration(
          hintText: hintText,
        ),
        validator: validator,
      ),
    );
  }
}