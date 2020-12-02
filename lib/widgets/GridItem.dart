import 'package:flutter/material.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/screens/Details.dart';
import 'package:intl/intl.dart' as intl;

bool inCheckingState = false;
List<Note> checkedNotes = List<Note>();

typedef NotesCallback = void Function(bool val);

class GridItem extends StatefulWidget {
  final Note note;
  final int color;
  final NotesCallback getAllNotes;

  GridItem(this.note, this.color, this.getAllNotes);

  @override
  State<StatefulWidget> createState() {
    return GridItemState(note, color, getAllNotes);
  }
}

class GridItemState extends State<GridItem> {
  final Note note;
  final int color;
  final NotesCallback getAllNotes;

  bool isVisible = true;
  double _height = 5;
  var _maxLines = 4;

  GridItemState(this.note, this.color, this.getAllNotes);

  var crossAxis = CrossAxisAlignment.start;
  var isArabic = false;

  @override
  void initState() {
    super.initState();
    if (note.title.isEmpty) {
      isVisible = false;
      _height = 0;
      _maxLines = 6;
    }
    if (isRTL(note.info)) {
      crossAxis = CrossAxisAlignment.end;
      isArabic = true;
    } else {
      crossAxis = CrossAxisAlignment.start;
      isArabic = false;
    }
  }

  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  void viewSelectableItems(Note note) {
    if (getAllNotes == null) return;

    setState(() {
      inCheckingState = true;
      if (checkedNotes.contains(note))
        checkedNotes.remove(note);
      else
        checkedNotes.add(note);
      getAllNotes(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(color),
      child: new InkWell(
        onLongPress: () => viewSelectableItems(note),
        onTap: _openItemDetails,
        child: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: crossAxis,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Visibility(
                        child: Align(
                          child: Text(
                            note.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF252525),
                            ),
                            textDirection:
                                isArabic ? TextDirection.rtl : TextDirection.ltr,
                          ),
                          alignment: isArabic ? Alignment.topRight: Alignment.topLeft
                        ),
                        visible: isVisible,
                      ),
                    ),
                    if (checkedNotes.contains(note))
                      Icon(Icons.check_box_rounded, color: Color(0xff252525)),
                    if (inCheckingState && !checkedNotes.contains(note))
                      Icon(Icons.check_box_outline_blank_sharp,
                          color: Color(0xff252525))
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                SizedBox(
                  height: _height,
                ),
                Text(
                  note.info,
                  overflow: TextOverflow.ellipsis,
                  maxLines: _maxLines,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF252525),
                  ),
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                Spacer(),
                Align(
                  alignment: isArabic
                      ? FractionalOffset.bottomLeft
                      : FractionalOffset.bottomRight,
                  child: Text(
                    note.date,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  void _openItemDetails() {
    if (getAllNotes != null) {
      if (inCheckingState) {
        if (checkedNotes.contains(note))
          checkedNotes.remove(note);
        else
          checkedNotes.add(note);
        getAllNotes(true);
        return;
      }
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Details(note: note)))
        .then((value) => value ? refreshPage() : print("No changes!"));
  }

  void refreshPage() {
    getAllNotes(false);
  }
}
