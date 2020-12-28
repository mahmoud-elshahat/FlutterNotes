import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:notes/models/CheckedListProvider.dart';
import 'package:notes/models/Note.dart';
import 'package:notes/models/NotesListProvider.dart';
import 'package:notes/services/dbhelper.dart';
import 'package:notes/widgets/ColorPicker.dart';
import 'package:notes/widgets/CustomGridDelegate.dart';
import 'package:notes/widgets/GridItem.dart';
import 'package:notes/widgets/NotesButton.dart';
import 'package:provider/provider.dart';
import 'Search.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  var notesListModel;
  var checkedListModel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkedListModel =
          Provider.of<CheckedListProvider>(context, listen: false);
      //get saved notes
      notesListModel = Provider.of<NotesListProvider>(context, listen: false);
      notesListModel.getAllNotes();
      //get saved settings
      notesListModel.getSavedState();
    });
  }

  void openColorsList(BuildContext context) {
    showMaterialModalBottomSheet(
        backgroundColor: Color(0xFF252525),
        context: this.context,
        builder: (context) => Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              height: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NotesButton(
                          callback: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icons.arrow_back_ios_outlined),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: new Text("Combination"),
                        padding: EdgeInsets.only(
                            top: 16, left: 16, bottom: 14, right: 16),
                        textColor: Colors.white,
                        color: Color(0xFF3B3B3B),
                        onPressed: () =>
                            notesListModel.updateColor(-1, -1, context),
                      ),
                    ],
                  ),
                  Consumer<NotesListProvider>(builder: (context, model, child) {
                    return ColorPicker(
                        onTap: (index) {
                          notesListModel.updateColor(
                              colors[index], index, context);
                        },
                        selectedIndex: model.currentIndex);
                  })
                ],
              ),
            )));
  }

  // ignore: missing_return
  Future<bool> _onWillPop() async {
    checkedListModel.inCheckingState
        ? checkedListModel.clear()
        : SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  Widget notCheckingState() {
    return (Row(
      children: [
        NotesButton(
            callback: () => openColorsList(context),
            icon: Icons.color_lens_outlined),
        NotesButton(
          callback: () => notesListModel.changeGrid(),
          icon: Icons.format_align_center_outlined,
        ),
        NotesButton(callback: () => openSearch(context), icon: Icons.search),
      ],
    ));
  }

  Widget checkingState() {
    return (NotesButton(
      callback: _deleteSelectedNotes,
      icon: Icons.delete_outline_outlined,
    ));
  }

  void _deleteSelectedNotes() async {
    if (checkedListModel.checkedNotes.length == 0) return;
    checkedListModel.deleteSelected(context);
      // Navigator.pushNamedAndRemoveUntil(context, '/Home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
          //0xFF3B3B3B
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFFFF9F1C),
            child: Icon(Icons.add),
            onPressed: () => Navigator.of(this.context).pushNamed("/Create"),
            foregroundColor: Colors.white,
            elevation: 5,
          ),
          backgroundColor: Color(0xFF252525),
          body: Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, bottom: 16.0, right: 16.00, left: 16.0),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Consumer<CheckedListProvider>(
                                  builder: (context, model, child) {
                                return Text(
                                  !model.inCheckingState
                                      ? "Notes"
                                      : model.checkedNotes.length.toString() +
                                          " Selected",
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.white),
                                );
                              })),
                          Spacer(),
                          Consumer<CheckedListProvider>(
                              builder: (context, model, child) {
                            return model.inCheckingState
                                ? checkingState()
                                : notCheckingState();
                          })
                        ],
                      )),
                  Consumer<NotesListProvider>(builder: (context, model, child) {
                    if (model.list.length > 0) {
                      return Flexible(
                        child: GridView.builder(
                          key: UniqueKey(),
                          shrinkWrap: true,
                          itemCount: model.list.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                  crossAxisCount: notesListModel.numberOfItems,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  height: 190),
                          itemBuilder: (BuildContext context, int i) {
                            if (notesListModel.currentColor == -1) {
                              return new GridItem(
                                  model.list[i], colors[i % colors.length]);
                            } else {
                              return new GridItem(
                                  model.list[i], notesListModel.currentColor);
                            }
                          },
                        ),
                      );
                    } else {
                      return Flexible(
                          child: Center(
                        child: Text(
                          "No notes yet, create a one!",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ));
                    }
                  })
                ],
              ))),
    );
  }

  void openSearch(BuildContext context) {
    {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Search(
              notes: notesListModel.list,
              itemColor: notesListModel.currentColor)));
    }
  }
}
