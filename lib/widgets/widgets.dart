import 'package:flutter/material.dart';

Widget getbutton(String signoption) {
  return Container(
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
          ),
          height: 30,
          width: double.infinity,
          child: Center(child: Text(signoption)),
        )
      ],
    ),
  );
}
