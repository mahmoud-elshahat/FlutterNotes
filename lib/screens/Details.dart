import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart' as intl;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/models/NotesListProvider.dart';
import 'package:notes/widgets/CustomInputText.dart';
import 'package:notes/widgets/NotesButton.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

// ignore: must_be_immutable
class Details extends StatelessWidget {
  Note note;

  Details({Key key, @required this.note}) : super(key: key)
  {
    int x =0;
  }
  var titleController = TextEditingController();
  var noteController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var screenshotKey= new GlobalKey();

  void _showMessageInScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  // ignore: missing_return
  Future<bool> _onWillPop(BuildContext context) async {
    if (note.title == titleController.text &&
        note.info == noteController.text) {
      Navigator.of(context).pop();
      return false;
    }

    if (note.title != titleController.text ||
        note.info != noteController.text) {
      await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Are you sure?'),
          content: new Text('Do you want to discard changes ?'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: new Text('Yes'),
            ),
          ],
        ),
      );
    }
  }

  updateNote(BuildContext context) async {
    if (note.title == titleController.text &&
        note.info == noteController.text) {
      _showMessageInScaffold("No changes!");
      return;
    }
    Note tempNote = new Note(
        id: note.id, info: noteController.text, title: titleController.text);
    tempNote.update();

    //update provider state
    tempNote.date = note.getCurrentDate();

    var notesList = Provider.of<NotesListProvider>(context, listen: false);
    notesList.updateNote(note, tempNote);

    note = tempNote;
    _showMessageInScaffold("Note has been updated!");
  }

  ScreenshotController screenshotController = ScreenshotController();
  Future<void> shareImage() async {
    RenderRepaintBoundary boundary = screenshotKey.currentContext.findRenderObject();
    var image = await boundary.toImage();
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();


    await WcFlutterShare.share(
        sharePopupTitle: 'Share Note',
        fileName: 'note.png',
        mimeType: 'image/png',
        bytesOfFile: pngBytes);
    // Share.file("Notes App",note.title, pngBytes, 'image/jpg');
  }

  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(

        key: _scaffoldKey,
        backgroundColor: Color(0xFF252525),
        body: RepaintBoundary(
          key: screenshotKey,
          child: Padding(
            padding: EdgeInsets.only(
                top: 50.0, bottom: 16.0, right: 16.00, left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NotesButton(
                      callback: () => _onWillPop(context),
                      icon: Icons.arrow_back_ios_outlined,
                    ),
                    Spacer(),
                    NotesButton(
                      callback: () => shareImage(),
                      icon: Icons.share_outlined,
                    ),                    SizedBox(width: 4,),

                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: new Text(
                        "Update",
                        style: TextStyle(fontSize: 17),
                      ),
                      padding: EdgeInsets.only(
                          top: 15, left: 15, bottom: 13, right: 15),
                      textColor: Colors.white,
                      color: Color(0xFF3B3B3B),
                      onPressed: () => updateNote(context),
                    ),

                  ],

                ),
                SizedBox(
                  height: 10,
                  width: 10,
                ),
                CustomInputText(
                  maxLines: null,
                  maxLength: null,
                  autoFocus: false,
                  textSize: 26,
                  readOnly: false,
                  hintText: "Title",
                  fontWeight: FontWeight.bold,
                  controller: titleController..text = note.title,
                  inputType: TextInputType.text,
                ),
                Padding(
                  child: Text(
                    note.date,
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                    textAlign: TextAlign.start,
                  ),
                  padding:
                      EdgeInsets.only(top: 12, left: 9, right: 16, bottom: 12),
                ),
                Expanded(
                  child: CustomInputText(
                    maxLines: 50,
                    maxLength: null,
                    autoFocus: false,
                    textSize: 16,
                    readOnly: false,
                    hintText: "Type something...",
                    controller: noteController..text = note.info,
                    inputType: TextInputType.multiline,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
