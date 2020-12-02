import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/services/dbhelper.dart';
import 'package:notes/widgets/CustomInputText.dart';
import 'package:notes/widgets/NotesButton.dart';

class Details extends StatefulWidget {
  final Note note;

  Details({Key key, @required this.note}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DetailsState();
  }
}

class DetailsState extends State<Details> {
  var titleController = TextEditingController();
  var noteController = TextEditingController();
  bool anyUpdate = false;

  DetailsState();

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!anyUpdate) {
      Navigator.of(context).pop(false);
    } else
      Navigator.of(context).pop(true);

    // Navigator.pushNamedAndRemoveUntil(context, '/Home', (route) => false);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NotesButton(
                      callback: _onWillPop,
                      icon: Icons.arrow_back_ios_outlined,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: new Text("Update"),
                      padding: EdgeInsets.all(16),
                      textColor: Colors.white,
                      color: Color(0xFF3B3B3B),
                      onPressed: () => updateNote(),
                    )
                  ],
                ),
                SizedBox(height: 10),
                CustomInputText(
                  maxLines: null,
                  maxLength: null,
                  autoFocus: false,
                  textSize: 26,
                  readOnly: false,
                  hintText: "Title",
                  fontWeight: FontWeight.bold,
                  controller: titleController..text = widget.note.title,
                  inputType: TextInputType.text,
                ),
                Padding(child:Text(
                  widget.note.date,
                  style: TextStyle(color: Colors.white54,fontSize: 16),
                  textAlign: TextAlign.start,
                ), padding: EdgeInsets.only(top:12,left:9,right: 16,bottom: 12),),

                Expanded(
                  child: CustomInputText(
                    maxLines: 50,
                    maxLength: null,
                    autoFocus: false,
                    textSize: 16,
                    readOnly: false,
                    hintText: "Type something...",
                    controller: noteController..text = widget.note.info,
                    inputType: TextInputType.multiline,
                  ),
                )
              ],
            ),
          )),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  updateNote() async {
    if (widget.note.title == titleController.text &&
        widget.note.info == noteController.text) {
      _showMessageInScaffold("No changes!");
    } else {
      var now = new DateTime.now();
      var formatter = new DateFormat('MMM dd,yyyy');
      String formattedDate = formatter.format(now);

      Note updatedNote = Note(
          date: formattedDate,
          id: widget.note.id,
          info: noteController.text,
          title: titleController.text);
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.update(updatedNote);

      widget.note.title = titleController.text;
      widget.note.info = noteController.text;

      _showMessageInScaffold("Note has been updated!");
      anyUpdate = true;
    }
  }
}
