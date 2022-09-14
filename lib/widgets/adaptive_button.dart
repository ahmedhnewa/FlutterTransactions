import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton(this.text, this.handler, {Key? key}) : super(key: key);

  final String text;
  final VoidCallback handler;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(
            onPressed: handler,
            color: Colors.blue,
            child: Text(text),
          )
        : ElevatedButton(
            onPressed: handler,
            child: Text(text),
          );
  }
}
