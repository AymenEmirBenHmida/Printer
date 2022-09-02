import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:thermal_printer_flutter/home.dart';
import 'package:thermal_printer_flutter/models/ticket.dart';
import 'package:thermal_printer_flutter/print.dart';
import 'package:awesome_dialog/awesome_dialog.dart' as awesome;

class Dinar extends StatefulWidget {
  String operator;
  Dinar({this.operator});
  @override
  _DinarState createState() => _DinarState();
}

class _DinarState extends State<Dinar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thermal Printer'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Row contents horizontally,
              crossAxisAlignment:
                  CrossAxisAlignment.center, //Center Row contents vertically,
              children: [
                RaisedButton(
                  onPressed: () async {
                    bool response;
                    await awesome.AwesomeDialog(
                      context: context,
                      dialogType: awesome.DialogType.INFO,
                      headerAnimationLoop: false,
                      animType: awesome.AnimType.BOTTOMSLIDE,
                      title: 'Do you want to Print the ticket?',
                      //desc: 'Deleting will make unrecoverebale',
                      buttonsTextStyle: const TextStyle(color: Colors.black),
                      showCloseIcon: true,
                      btnCancelText: "No",
                      btnOkText: "Yes",
                      btnCancelOnPress: () {
                        response = false;
                      },
                      btnOkOnPress: () async {
                        try {
                          response = true;
                          String code = await TicketC(
                                  operator: widget.operator,
                                  type: 1,
                                  code: "12345687",
                                  status: "")
                              .getTicket();
                          log("code" + code);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Print(
                                      ticket: TicketC(
                                          operator: widget.operator,
                                          type: 1,
                                          code: code,
                                          status: ""),
                                    )),
                          );
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                    ).show();
                  },
                  padding: EdgeInsets.zero,
                  shape: StadiumBorder(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: ShapeDecoration(
                      gradient:
                          LinearGradient(colors: [Colors.blue, Colors.green]),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      "1 Dinar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                FutureBuilder(
                  future: getNumberOf1dt(),
                  builder: (context, snapshot) {
                    return Text("Total : " + snapshot.data.toString());
                  },
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Row contents horizontally,
              crossAxisAlignment:
                  CrossAxisAlignment.center, //Center Row contents vertically,
              children: [
                RaisedButton(
                  onPressed: () async {
                    try {
                      bool response;
                      await awesome.AwesomeDialog(
                        context: context,
                        dialogType: awesome.DialogType.INFO,
                        headerAnimationLoop: false,
                        animType: awesome.AnimType.BOTTOMSLIDE,
                        title: 'Do you want to Print the ticket?',
                        //desc: 'Deleting will make unrecoverebale',
                        buttonsTextStyle: const TextStyle(color: Colors.black),
                        showCloseIcon: true,
                        btnCancelText: "No",
                        btnOkText: "Yes",
                        btnCancelOnPress: () {
                          response = false;
                        },
                        btnOkOnPress: () async {
                          response = true;
                          String code = await TicketC(
                                  operator: widget.operator,
                                  type: 5,
                                  code: "12345687",
                                  status: "")
                              .getTicket();
                          log("code" + code);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Print(
                                      ticket: TicketC(
                                          operator: widget.operator,
                                          type: 5,
                                          code: code,
                                          status: ""),
                                    )),
                          );
                        },
                      ).show();
                    } catch (e) {
                      log(e.toString());
                    }
                  },
                  padding: EdgeInsets.zero,
                  shape: StadiumBorder(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: ShapeDecoration(
                      gradient:
                          LinearGradient(colors: [Colors.blue, Colors.green]),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      "5 Dinar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                FutureBuilder(
                  future: getNumberOf5dt(),
                  builder: (context, snapshot) {
                    return Text("Total : " + snapshot.data.toString());
                  },
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  getNumberOf1dt() async {
    return await TicketC(operator: widget.operator).getNumberOfTickets1dt();
  }

  getNumberOf5dt() async {
    TicketC ticket = TicketC(operator: widget.operator);
    return await ticket.getNumberOfTickets5dt();
  }
}
