import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

abstract class Toast {
  static void display(BuildContext context, IconData icon, Color textColour, Color backgroundColor, String message) {
    showToastWidget(
      Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            FaIcon(icon, color: textColour),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textColour
                ),
              ),
            )
          ],
        ),
      ),
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      context: context
    );
  }
}