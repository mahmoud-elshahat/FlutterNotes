import 'package:flutter/material.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/models/SearchedNotesListProvider.dart';
import 'package:notes/widgets/ColorPicker.dart';
import 'package:notes/widgets/CustomGridDelegate.dart';
import 'package:notes/widgets/CustomInputText.dart';
import 'package:notes/widgets/GridItem.dart';
import 'package:provider/provider.dart';

class Search extends StatelessWidget {
  final List<Note> notes;
  final searchController = new TextEditingController();
  final int itemColor;

  Search({Key key, this.notes, this.itemColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var searchedList = Provider.of<SearchedNotesList>(context, listen: false);
    searchController.addListener(()=> searchedList.search(notes,searchController.text));
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
                Consumer<SearchedNotesList>(builder: (context, model, child) {
                  if (model.resultNotes.length > 0) {
                    return Flexible(
                      child: GridView.builder(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        itemCount: model.resultNotes.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                height: 190),
                        itemBuilder: (BuildContext context, int i) {

                          if (itemColor == -1) {
                            return new GridItem(
                                model.resultNotes[i], colors[i % colors.length]);
                          } else {
                            return new GridItem(model.resultNotes[i],itemColor);
                          }
                        },
                      ),
                    );
                  } else {
                    return Flexible(
                        child: Center(
                      child: Text(
                        model.tempText,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ));
                  }
                })
              ],
            )));
  }
}
