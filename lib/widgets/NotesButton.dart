import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotesButton extends StatelessWidget {
  final Function() callback;
  final IconData icon;

   const NotesButton({Key key, this.callback, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        child: Padding(
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          padding: EdgeInsets.all(12),
        ),
        borderRadius: BorderRadius.circular(10),
        onTap: () => callback(),
      ),
      color: Color(0xFF3B3B3B),
    );
  }
}
