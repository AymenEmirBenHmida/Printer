import 'dart:developer';
import 'dart:io';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:thermal_printer_flutter/home.dart';
import 'package:thermal_printer_flutter/models/ticket.dart';
import 'package:thermal_printer_flutter/print.dart';
import 'package:awesome_dialog/awesome_dialog.dart' as awesome;
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'dart:io' show Platform;
import 'package:image/image.dart';
import 'package:thermal_printer_flutter/models/ticket.dart';

class Dinar extends StatefulWidget {
  String operator;
  Dinar({this.operator});
  @override
  _DinarState createState() => _DinarState();
}

class _DinarState extends State<Dinar> {
  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  TicketC ticketC;
  int typo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      bluetoothManager.state.listen((val) {
        print('state = $val');
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() => _devicesMsg = 'Bluetooth Disconnect!');
        }
      });
    } else {
      initPrinter();
    }
  }

  void initPrinter() {
    try {
      _printerManager.startScan(Duration(seconds: 2));
      _printerManager.scanResults.listen((val) {
        if (!mounted) return;
        setState(() => _devices = val);
        if (_devices.isEmpty) setState(() => _devicesMsg = 'No Devices');
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    try {
      _printerManager.selectPrinter(printer);
      String code = await TicketC(
              operator: widget.operator,
              type: typo,
              code: "12345687",
              status: "")
          .getTicket();
      log("code" + code);

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => Print(
      //             ticket: TicketC(
      //                 operator: widget.operator,
      //                 type: 1,
      //                 code: code,
      //                 status: ""),
      //           )),
      // );
      setState(() {
        ticketC = TicketC(
            operator: widget.operator, type: typo, code: code, status: "");
      });
      final result =
          await _printerManager.printTicket(await _ticket(PaperSize.mm80));
      var tt = await _ticket(PaperSize.mm80);
      if (tt == null || tt.bytes.isEmpty || result.msg.contains("Error")) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content:
                Text(result.msg + " , get code manually = " + ticketC.code),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(result.msg),
          ),
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    try {
      final ticket = Ticket(paper);
      int total = 0;

      // // Image assets
      // final ByteData data = await rootBundle.load('assets/store.png');
      // final Uint8List bytes = data.buffer.asUint8List();
      // final Image image = decodeImage(bytes);
      // ticket.image(image);
      // ticket.text(
      //   'TOKO KU',
      //   styles: PosStyles(
      //       align: PosAlign.center,
      //       height: PosTextSize.size2,
      //       width: PosTextSize.size2),
      //   linesAfter: 1,
      // );

      // for (var i = 0; i < widget.data.length; i++) {
      //   total += widget.data[i]['total_price'];
      //   ticket.text(widget.data[i]['title']);
      //   ticket.row([
      //     PosColumn(
      //         text: '${widget.data[i]['price']} x ${widget.data[i]['qty']}',
      //         width: 6),
      //     PosColumn(text: 'Rp ${widget.data[i]['total_price']}', width: 6),
      //   ]);
      // }

      ticket.feed(1);
      ticket.row([
        PosColumn(
            text: ticketC.operator + " ",
            width: 12,
            styles: PosStyles(bold: true)),
        //PosColumn(text: 'Rp $total', width: 6, styles: PosStyles(bold: true)),
      ]);
      ticket.feed(2);
      ticket.text("Code:  " + ticketC.code,
          styles: PosStyles(align: PosAlign.center, bold: true));
      ticket.cut();

      return ticket;
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    try {
      _printerManager.stopScan();
    } catch (e) {
      log(e.toString());
    }
    super.dispose();
  }

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
            StreamBuilder(
              stream: Stream.periodic(Duration(milliseconds: 20))
                  .asyncMap((i) => getNumberOf1dt()),
              builder: (context, snapshot) {
                if (snapshot.data.toString() != "0")
                  return Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, //Center Row contents vertically,
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
                              buttonsTextStyle:
                                  const TextStyle(color: Colors.black),
                              showCloseIcon: true,
                              btnCancelText: "No",
                              btnOkText: "Yes",
                              btnCancelOnPress: () {
                                response = false;
                              },
                              btnOkOnPress: () async {
                                try {
                                  if (_devices != 0) {
                                    response = true;
                                    setState(() {
                                      typo = 1;
                                    });
                                    _startPrint(_devices[0]);
                                  }
                                } catch (e) {
                                  log(e.toString());
                                }
                              },
                            ).show();
                          } catch (e) {
                            log(e.toString());
                          }
                        },
                        padding: EdgeInsets.zero,
                        shape: StadiumBorder(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.blue, Colors.green]),
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
                      if (snapshot.hasData)
                        Text("Total : " + snapshot.data.toString() == "null"
                            ? ""
                            : snapshot.data.toString()),
                    ],
                  );
                else
                  return Container();
              },
            ),
            SizedBox(
              height: 16,
            ),
            StreamBuilder(
              stream: Stream.periodic(Duration(milliseconds: 20))
                  .asyncMap((i) => getNumberOf5dt()),
              builder: (context, snapshot) {
                if (snapshot.data.toString() != "0")
                  return Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment
                        .center, //Center Row contents vertically,
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
                              buttonsTextStyle:
                                  const TextStyle(color: Colors.black),
                              showCloseIcon: true,
                              btnCancelText: "No",
                              btnOkText: "Yes",
                              btnCancelOnPress: () {
                                response = false;
                              },
                              btnOkOnPress: () async {
                                response = true;
                                if (_devices != 0) {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => Print(
                                  //             ticket: TicketC(
                                  //                 operator: widget.operator,
                                  //                 type: 5,
                                  //                 code: code,
                                  //                 status: ""),
                                  //           )),
                                  // );
                                  setState(() {
                                    typo = 5;
                                  });
                                  _startPrint(_devices[0]);
                                }
                              },
                            ).show();
                          } catch (e) {
                            log(e.toString());
                          }
                        },
                        padding: EdgeInsets.zero,
                        shape: StadiumBorder(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                                colors: [Colors.blue, Colors.green]),
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
                      if (snapshot.hasData)
                        Text("Total : " + snapshot.data.toString() == "null"
                            ? ""
                            : snapshot.data.toString()),
                    ],
                  );
                else
                  return Container();
              },
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
