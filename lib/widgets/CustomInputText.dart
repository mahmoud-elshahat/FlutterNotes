import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';

class CustomInputText extends StatefulWidget {
  final int maxLines;
  final int maxLength;
  final bool autoFocus;
  final double textSize;
  final bool readOnly;
  final String hintText;
  final TextEditingController controller;
  final TextInputType inputType;
  FontWeight fontWeight=FontWeight.normal;

  CustomInputText(
      {@required this.maxLines,
      @required this.maxLength,
      @required this.autoFocus,
      @required this.textSize,
      @required this.readOnly,
      @required this.hintText,
      @required this.controller,
      @required this.inputType,
      this.fontWeight});

  @override
  State<StatefulWidget> createState() {
    return CustomInputTextState();
  }
}

class CustomInputTextState extends State<CustomInputText> {

  String text = "";
  
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(updateLang);
    setState(() {
      text=widget.controller.text;
    });
  }

  void updateLang() {
    setState(() {
      text=widget.controller.text;
    });
  }
  @override
  Widget build(BuildContext context) {
    return AutoDirection(
        text: text,
        child: TextFormField(
          enabled: true,
          controller: widget.controller,
          cursorColor: Colors.white,
          keyboardType: widget.inputType,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          maxLengthEnforced: true,
          style: TextStyle(
            fontSize: widget.textSize,
            color: Colors.white,
            fontWeight: widget.fontWeight
          ),
          autofocus: widget.autoFocus,
          decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            counterStyle: TextStyle(color: Color(0xFF3B3B3B)),
            hintStyle: TextStyle(
                color: Color(0xFF3C3C3C),
                fontSize: widget.textSize,
                fontWeight: FontWeight.bold),
            contentPadding:
                EdgeInsets.only(left: 9, bottom: 0, top: 10, right: 10),
            hintText: widget.hintText,
          ),
        ));
  }

}
