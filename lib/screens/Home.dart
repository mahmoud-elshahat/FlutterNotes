import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/services/dbhelper.dart';
import 'package:notes/widgets/ColorPicker.dart';
import 'package:notes/widgets/CustomGridDelegate.dart';
import 'package:notes/widgets/GridItem.dart';
import 'package:notes/widgets/NotesButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Search.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  int currentColor;
  double height = 1.7;
  int numberOfItems = 2;

  void _changeGrid() {
    setState(() {
      if (numberOfItems == 2) {
        height = 4;
        numberOfItems = 1;
      } else {
        height = 1.8;
        numberOfItems = 2;
      }
    });
  }

  final dbHelper = DatabaseHelper.instance;
  List<Note> notes= [];

  void createNewNote() {
    Navigator.of(this.context)
        .pushNamed("/Create")
        .then((val) => val ? _getAllNotes(false) : null);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentColor();
    _getAllNotes(false);
  }

  void _getAllNotes(bool notNeedQuery) async {
    if (notNeedQuery) {
      setState(() {});
      return;
    }
    final allRows = await dbHelper.queryAllRows();
    notes = new List<Note>();
    allRows.forEach((row) => notes.add(Note.fromMap(row)));
    setState(() {});
  }

  int currentIndex;

  void _getCurrentColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentColor = prefs.getInt('color') ?? 0xffF28B83;
      if (currentColor == -1)
        currentIndex = -1;
      else
        currentIndex = colors.indexOf(currentColor);
    });
  }

  void openColorsList() {
    showMaterialModalBottomSheet(
        backgroundColor: Color(0xFF252525),
        context: this.context,
        builder: (context) => Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              height: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NotesButton(
                          callback: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icons.arrow_back_ios_outlined),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: new Text("Combination"),
                        padding: EdgeInsets.all(16),
                        textColor: Colors.white,
                        color: Color(0xFF3B3B3B),
                        onPressed: () => saveColor(-1),
                      ),
                    ],
                  ),
                  ColorPicker(
                      onTap: (index) {
                        setState(() {
                          currentColor = colors[index];
                          saveColor(currentColor);
                        });
                      },
                      selectedIndex: currentIndex),
                ],
              ),
            )));
  }

  void saveColor(int color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color', color);
    Navigator.of(context).pop();
    Navigator.pushNamedAndRemoveUntil(context, '/Home', (route) => false);
  }

  // ignore: missing_return
  Future<bool> _onWillPop() async {
    if (inCheckingState) {
      setState(() {
        inCheckingState = false;
        checkedNotes = new List<Note>();
      });
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF3B3B3B),
            child: Icon(Icons.add),
            onPressed: () => createNewNote(),
            foregroundColor: Colors.white,
            elevation: 5,
          ),
          backgroundColor: Color(0xFF252525),
          body: Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, bottom: 16.0, right: 16.00, left: 16.0),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              !inCheckingState
                                  ? "Notes"
                                  : checkedNotes.length.toString() +
                                      " Selected",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          ),
                          Spacer(),
                          inCheckingState ? checkingState() : notCheckingState()
                        ],
                      )),
                  notes.length > 0
                      ? Flexible(
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: notes.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                    crossAxisCount: numberOfItems,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    height: 190),
                            itemBuilder: (BuildContext context, int i) {
                              if (currentColor == -1) {
                                return new GridItem(notes[i],
                                    colors[i % colors.length], _getAllNotes);
                              } else {
                                return new GridItem(
                                    notes[i], currentColor, _getAllNotes);
                              }
                            },
                          ),
                        )
                      : Flexible(
                          child: Center(
                          child: Text(
                            "No notes yet, create a one!",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )),
                ],
              ))),
    );
  }

  Widget notCheckingState() {
    return (Row(
      children: [
        NotesButton(callback: openColorsList, icon: Icons.color_lens_outlined),
        NotesButton(
          callback: _changeGrid,
          icon: Icons.format_align_center_outlined,
        ),
        NotesButton(
            callback: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      Search(notes: notes, itemColor: currentColor)));
            },
            icon: Icons.search),
      ],
    ));
  }

  Widget checkingState() {
    return (NotesButton(
      callback: _deleteSelectedNotes,
      icon: Icons.delete_outline_outlined,
    ));
  }

  void _deleteSelectedNotes() async {
    if (checkedNotes.length == 0) return;

    final dbHelper = DatabaseHelper.instance;
    int i;
    for (i = 0; i < checkedNotes.length; i++) {
      await dbHelper.delete(checkedNotes[i].id);
      notes.remove(checkedNotes[i]);
    }

    setState(() {
      inCheckingState = false;
      Navigator.pushNamedAndRemoveUntil(context, '/Home', (route) => false);
    });
  }
}
