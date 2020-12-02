import 'package:flutter/material.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/widgets/CustomGridDelegate.dart';
import 'package:notes/widgets/CustomInputText.dart';
import 'package:notes/widgets/GridItem.dart';

class Search extends StatefulWidget {
  final List<Note> notes;
  final int itemColor;

  const Search({Key key, this.notes, this.itemColor}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }
}

class SearchState extends State<Search> {
  List<Note> resultNotes = new List<Note>();
  final searchController = new TextEditingController();
  String tempText = "Results will be here.";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    searchController.addListener(_viewResult);
  }

  void _viewResult() {
    if (widget.notes == null || widget.notes.length == 0) {
      setState(() {
        tempText = "There is nothing to search in.";
      });
      return;
    }
    setState(() {
      resultNotes = new List<Note>();
    });

    String text = searchController.text.toLowerCase();
    if (text == "" || text == " ") return;

    for (int i = 0; i < widget.notes.length; i++) {
      String mainText = widget.notes[i].title + " " + widget.notes[i].info;
      mainText = mainText.toLowerCase();

      if (mainText.indexOf(text) != -1) {
        if (!resultNotes.contains(widget.notes[i])){
          setState(() {
            resultNotes.add(widget.notes[i]);
          });
        }


      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xFF252525),
        body: Padding(
            padding: const EdgeInsets.only(
                top: 50.0, bottom: 16.0, right: 16.00, left: 16.0),
            child: Column(
              children: [
                CustomInputText(
                    maxLines: 1,
                    maxLength: null,
                    autoFocus: true,
                    textSize: 18,
                    readOnly: false,
                    hintText: "Search...",
                    controller: searchController,
                    inputType: TextInputType.text),
                resultNotes.length > 0
                    ? Flexible(
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: resultNotes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  height: 190),
                          itemBuilder: (BuildContext context, int i) {
                            return new GridItem(
                                resultNotes[i], widget.itemColor, null,);
                          },
                        ),
                      )
                    : Flexible(
                        child: Center(
                        child: Text(
                          tempText,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )),
              ],
            )));
  }
}
