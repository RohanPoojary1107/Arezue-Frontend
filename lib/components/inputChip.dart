import 'dart:ui';

import 'package:arezue/utils/colors.dart';
import 'package:arezue/utils/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class inputChip extends StatelessWidget {
  //Constructor of the child widget
  @override
  inputChip(
      {@required this.title,
      this.endpoint,
      this.fieldData,
      @required this.fieldId = "",
      @required this.fieldType = "text",
      this.handler});

  final String
      title; // this goes before the textfield, i.e. what textfield is this.
  final String
      endpoint; // api endpoint, send the whole URL for now but we'll need to generalize this
  final String
      fieldType; // numeric or text, depending on that it displays the keyboard differently
  final String
      fieldId; // the "key" in the data object defined in the parent stateful widget and DB.
  final List<String> fieldData; // the actualy value of the key.
  Function
      handler; // the parent handler function that updates the parent state, this is passed from the parent.

  //created a texteditting controll so that we can modify the text on init of this widget if need be.
  var controller = TextEditingController();

  //keyboard map
  final Map<String, TextInputType> keyboards = {
    "numeric": TextInputType.numberWithOptions(decimal: true),
    "text": TextInputType.text
  };

  // child handler that calls the API and then the parent handler.
  void submitHandler(text, command) {
    // Handle PUT request to the api here
    print("child handler triggered: ${text}");

    // Once that's done, notify the parent so it knows to update its local state.
    handler(text, fieldId, command);
  }

  Widget inputChips(text) {
    return InputChip(
      padding: EdgeInsets.all(2.0),
      label: Text(text),
      labelStyle: TextStyle(
        color: ArezueColors.secondaryColor,
      ),
      onDeleted:(){
        submitHandler(text, "remove");
      }, //this is what happens when the x is pressed
    );
  }

  // The actual object iself.
  Widget build(BuildContext context) {
    //controller.text = this.fieldData as String;
    return Container(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
        margin: const EdgeInsets.only(right: 50, left: 50, bottom: 20, top: 0),
        //height: 200,
        decoration: BoxDecoration(
          color: ArezueColors.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: ArezueColors.shadowColor,
              blurRadius: 10.0,
              spreadRadius: 5.0,
              offset: Offset(
                0.0, // horizontal, move right 10
                0.0, // vertical, move down 10
              ),
            ),
          ],
        ),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(this.title,
                    style: TextStyle(
                      color: ArezueColors.outPrimaryColor,
                      fontSize: 18,
                      fontFamily: 'Arezue',
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            SizedBox(height: 15),
            //Row(children: <Widget>[
              Wrap(
                spacing: 5.0, // gap between adjacent chips
                alignment: WrapAlignment.start  ,
                children: listWidgets(this.fieldData),
              ),
            //],),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                      controller: controller,
                      keyboardType: keyboards[this.fieldType],
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(15, 8, 15, 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(
                              color: ArezueColors.transparent, width: 1),
                        ),
                        hintText: "Enter something",
                      ),
                      onSubmitted: (text) {
                        submitHandler(text, "add");
                        controller.text = "";
                      }),
                ),
              ],
            ),
          ],
        ));
  }

  List<Widget> listWidgets(List<String> list) {
    List<Widget> widglist = new List<Widget>();
    list.forEach((element) {
      widglist.add(inputChips(element));
    });
    return widglist;
  }
}