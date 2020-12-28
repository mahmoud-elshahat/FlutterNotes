import 'package:flutter/material.dart';
import 'package:notes/models/NotesListProvider.dart';
import 'package:notes/services/dbhelper.dart';
import 'package:provider/provider.dart';

import 'Note.dart';

class CheckedListProvider extends ChangeNotifier{

  List<Note> checkedNotes=[];
  bool inCheckingState = false;
  void addCheckedItem(Note note)
  {
    checkedNotes.add(note);
    notifyListeners();
  }
  void removeCheckedItem(Note note)
  {
    checkedNotes.remove(note);
    notifyListeners();
  }
  void updateCheckedState(bool state)
  {
    inCheckingState=state;
    notifyListeners();
  }
  void clear(){
    inCheckingState = false;
    checkedNotes = new List<Note>();
    notifyListeners();
  }
  Future<void> deleteSelected(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    var  notesListModel = Provider.of<NotesListProvider>(context, listen: false);
    int i;
    for (i = 0; i < checkedNotes.length; i++) {
      await dbHelper.delete(checkedNotes[i].id);
      notesListModel.removeItem(checkedNotes[i]);
    }
    clear();
  }
}