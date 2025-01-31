import 'package:flutter/material.dart';

class ShadowedContainer extends StatelessWidget {
  final Widget content;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  const ShadowedContainer(
      {super.key, required this.content, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:
            margin ?? const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        padding: padding ?? const EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white, Colors.yellow],
                stops: const [1.0, 0.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2))
            ]),
        child: content);
  }
}
