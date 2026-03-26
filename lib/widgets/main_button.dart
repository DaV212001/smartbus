import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final Function() onPress;
  final bool isLoading;

  const MainButton(
      {super.key,
      this.isLoading = false,
      this.height = 65,
      this.width = double.infinity,
      required this.text,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    // ThemeData theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPress,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF4B39EF)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: !isLoading
            ? Text(text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ))
            : const CircularProgressIndicator(
                color: Colors.white,
              ),
      ),
    );
  }
}
