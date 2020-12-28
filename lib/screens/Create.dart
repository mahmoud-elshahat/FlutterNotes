import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/models/NotesListProvider.dart';
import 'package:notes/widgets/CustomInputText.dart';
import 'package:notes/widgets/NotesButton.dart';
import 'package:provider/provider.dart';

class Create extends StatelessWidget {
  Future<bool> _onWillPop(BuildContext context) async {
    if (noteController.text.isNotEmpty || titleController.text.isNotEmpty) {
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
              onPressed: (){
                Navigator.of(context).pop();
                titleController.dispose();
                noteController.dispose();
                Navigator.of(context).pop();

              },
              child: new Text('Yes'),
            ),
          ],
        ),
      ));
    }else
      Navigator.of(context).pop();
    return false;
  }

  final titleController = TextEditingController();
  final noteController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }






  void _saveNote(BuildContext context) async {
    if (noteController.text.isEmpty && titleController.text.isEmpty) {
      _showMessageInScaffold("There in nothing to save.");
      return;
    }
    Note note =
    new Note(title: titleController.text, info: noteController.text);
    note.save();
    note.date=note.getCurrentDate();

    var notesList = Provider.of<NotesListProvider>(context, listen: false);
    notesList.addNote(note);

    Navigator.of(context).pop(true);
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()=> _onWillPop(context),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotesButton(
                      callback:() => _onWillPop(context),
                      icon: Icons.arrow_back_ios_outlined),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: new Text(
                      "Save",
                      style: TextStyle(fontSize: 17),
                    ),
                    padding: EdgeInsets.only(
                        top: 15, left: 15, bottom: 13, right: 15),
                    textColor: Colors.white,
                    color: Color(0xFF3B3B3B),
                    onPressed: () => _saveNote(context),
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
