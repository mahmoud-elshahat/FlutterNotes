
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/services/dbhelper.dart';

class Note{
  int id;
  String title;
  String info;
  String date;

  Note( {this.id,this.title, this.info, this.date, });
  Note.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    info = map['info'];
    date = map['date'];
  }
  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'title': title,
      'info':   info,
      'date': date,
    };
  }

  void save()async
  {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic> row = {
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnInfo: info,
      DatabaseHelper.columnDate: getCurrentDate(),
    };
    Note note = Note.fromMap(row);
    await dbHelper.insert(note);
  }

  void update()async{
    Note updatedNote = Note(
        date: getCurrentDate(),
        id: id,
        info: info,
        title: title);
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.update(updatedNote);
  }

  String getCurrentDate(){
    var now = new DateTime.now();
    var formatter = new DateFormat('MMM dd,yyyy');
    return formatter.format(now);
  }



}