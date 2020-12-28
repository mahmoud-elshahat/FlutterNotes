import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/NotesListProvider.dart';
import 'package:provider/provider.dart';

List<int> colors = [
  0xFFF38FB1,
  0xFFFFCC80,
  0xFFE6EE9B,
  0xFFCF93D9,
  0xFFcfb845,
  0xFFF28B83,
  0xFFefb5a3,
  0xFFf9813a,
  0xFFffe3d8,
];

class ColorPicker extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;

  ColorPicker({this.onTap, this.selectedIndex});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == null) {
      selectedIndex = widget.selectedIndex;
    }
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (BuildContext context, int index) {
          return Consumer<NotesListProvider>(builder: (context, model, child) {
            return InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onTap(index);
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: 50,
                height: 50,
                child: Container(
                  child: Center(
                      child: model.currentIndex == index
                          ? Icon(Icons.done)
                          : Container()),
                  decoration: BoxDecoration(
                      color: Color(colors[index]),
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.black)),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
