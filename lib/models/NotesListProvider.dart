import 'package:flutter/material.dart';
import 'package:notes/services/dbhelper.dart';
import 'package:notes/widgets/ColorPicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Note.dart';

class NotesListProvider extends ChangeNotifier{
  List<Note> list=[];
  int gridNumberPerRow;
  final dbHelper = DatabaseHelper.instance;



  void getAllNotes() async
  {
    final allRows = await dbHelper.queryAllRows();
    list = new List<Note>();
    allRows.forEach((row) => list.add(Note.fromMap(row)));
    notifyListeners();
  }
  void addNote(Note note){
   list.add(note);
   notifyListeners();
  }
  void updateNote(Note note, Note tempNote) {
    int updatedNoteIndex=list.indexOf(note);
    list[updatedNoteIndex]=tempNote;
    print(list[updatedNoteIndex].title + list[updatedNoteIndex].info);
    notifyListeners();
  }
  void updateList(List notes){
    list=notes;
    notifyListeners();
  }

  updateGridStyle(int numberPerRow)
  {

  }



  int currentColor;
  int currentIndex;
  int numberOfItems = 2;
  //update settings
  void getSavedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentColor= prefs.getInt('color') ?? -1;
    numberOfItems=prefs.getInt('gridRowNumber')?? 2;
    if (currentColor == -1)
      currentIndex = -1;
    else
      currentIndex = colors.indexOf(currentColor);
    notifyListeners();
  }
  void updateColor(int color,int index,BuildContext context) async {
    currentColor=color;
    currentIndex=index;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color', color);

    notifyListeners();
  }
  void changeGrid() async{
    numberOfItems ==2 ?numberOfItems=1:numberOfItems=2;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gridRowNumber', numberOfItems);
    notifyListeners();
  }

  void removeItem(Note checkedNot) {
    list.remove(checkedNot);
    notifyListeners();
  }


}