import 'package:flutter/material.dart';
import 'package:notes/models/CheckedListProvider.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/models/NotesListProvider.dart';
import 'package:notes/screens/Details.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';


typedef NotesCallback = void Function(bool val);

class GridItem extends StatefulWidget {
  final Note note;
  final int color;

  GridItem(this.note, this.color);

  @override
  State<StatefulWidget> createState() {
    return GridItemState(note, color);
  }
}


class GridItemState extends State<GridItem> {
  final Note note;
  final int color;

  bool isVisible = true;
  double _height = 5;
  var _maxLines = 4;

  GridItemState(this.note, this.color);

  var crossAxis = CrossAxisAlignment.start;
  var isArabic = false;
  var notesListModel ;
  var checkedListModel;

  @override
  void initState() {
    super.initState();
    notesListModel= Provider.of<NotesListProvider>(context, listen: false);
    checkedListModel= Provider.of<CheckedListProvider>(context, listen: false);
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
    if (notesListModel.list == null) return;
    checkedListModel.inCheckingState = true;
    if (checkedListModel.checkedNotes.contains(note))
      checkedListModel.removeCheckedItem(note);
    else
      checkedListModel.addCheckedItem(note);
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

                    Consumer<CheckedListProvider>(builder: (context,model,child){
                      if (checkedListModel.checkedNotes.contains(note))
                        return Icon(Icons.check_box_rounded, color: Color(0xff252525));

                      if (checkedListModel.inCheckingState && !checkedListModel.checkedNotes.contains(note))
                        return Icon(Icons.check_box_outline_blank_sharp,
                            color: Color(0xff252525));
                      return Center();
                    })

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
    if (notesListModel.list != null) {
      if (checkedListModel.inCheckingState) {
        if (checkedListModel.checkedNotes.contains(note))
          checkedListModel.removeCheckedItem(note);
        else
          checkedListModel.addCheckedItem(note);
        return;
      }
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Details(note: note)));
  }
}
