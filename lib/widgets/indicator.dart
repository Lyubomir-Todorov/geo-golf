import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor
              ),
            )
          ],
        ),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: textColor
          ),
        )
      ],
    );
  }
}