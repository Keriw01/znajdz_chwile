import 'package:flutter/material.dart';

Widget legendElement(String title, Color color) {
  return Row(
    children: [
      Container(
        width: 10,
        height: 10,
        color: color,
      ),
      const SizedBox(
        width: 10,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Text(title),
      )
    ],
  );
}
