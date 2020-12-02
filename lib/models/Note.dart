
class Note {
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

}
