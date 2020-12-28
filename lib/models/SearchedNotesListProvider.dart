import 'package:flutter/material.dart';

import 'Note.dart';

class SearchedNotesList extends ChangeNotifier {
  List<Note> resultNotes = new List<Note>();
  String tempText = "Results will be here.";

  void search(List notes, String searchedText) {
    if (notes == null || notes.length == 0) {
      tempText = "There is nothing to search in.";
      notifyListeners();
      return;
    }
    resultNotes = new List<Note>();
    String text = searchedText.toLowerCase();
    if (text == "" || text == " ") {
      notifyListeners();
      return;
    }
    for (int i = 0; i < notes.length; i++) {
      String mainText = notes[i].title + " " + notes[i].info;
      if (mainText.toLowerCase().indexOf(text) != -1) {
        if (!resultNotes.contains(notes[i])) {
          resultNotes.add(notes[i]);
        }
      }
    }
    notifyListeners();
  }
}
