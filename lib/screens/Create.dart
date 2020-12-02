import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/services/dbhelper.dart';
import 'package:notes/widgets/CustomInputText.dart';
import 'package:notes/widgets/NotesButton.dart';

class Create extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateState();
  }
}

class CreateState extends State<Create> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to discard this note'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {Navigator.of(context).pop();
                Navigator.of(context).pop();} ,
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  final titleController = TextEditingController();
  final noteController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showMessageInScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void back() {
    if (noteController.text.isNotEmpty || titleController.text.isNotEmpty) {
      _onWillPop();
      return;
    }
    Navigator.of(this.context).pop();
  }

  void _saveNote() async {
    if (noteController.text.isEmpty) {
      _showMessageInScaffold("There in nothing to save.");
      return;
    }

    var now = new DateTime.now();
    var formatter = new DateFormat('MMM dd,yyyy');
    String formattedDate = formatter.format(now);

    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> row = {
      DatabaseHelper.columnTitle: titleController.text,
      DatabaseHelper.columnInfo: noteController.text,
      DatabaseHelper.columnDate: formattedDate,
    };
    Note note = Note.fromMap(row);
    await dbHelper.insert(note);
    Navigator.of(this.context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xFF252525),
        body: Padding(
          padding: EdgeInsets.only(
              top: 50.0, bottom: 16.0, right: 16.00, left: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NotesButton(
                      callback: back, icon: Icons.arrow_back_ios_outlined),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: new Text("Save"),
                    padding: EdgeInsets.all(16),
                    textColor: Colors.white,
                    color: Color(0xFF3B3B3B),
                    onPressed: () => _saveNote(),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
              ),
              CustomInputText(
                maxLines: 2,
                maxLength: null,
                autoFocus: true,
                textSize: 26,
                readOnly: false,
                hintText: "Title",
                controller: titleController,
                inputType: TextInputType.text,
              ),
              Expanded(
                child: CustomInputText(
                  maxLines: 50,
                  maxLength: null,
                  autoFocus: false,
                  textSize: 20,
                  readOnly: false,
                  hintText: "Type something...",
                  controller: noteController,
                  inputType: TextInputType.multiline,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
