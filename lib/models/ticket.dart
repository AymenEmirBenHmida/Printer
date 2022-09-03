import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermal_printer_flutter/models/globalV.dart';

import 'User.dart';

class TicketC {
  String code;
  int type;
  String status;
  String operator;

  TicketC({code, type, status, operator}) {
    this.code = code;
    this.type = type;
    this.status = status;
    this.operator = operator;
  }

  getNumberOfTickets1dt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String Token = prefs.getString("token");
    http.Response response = await http.get(
        Uri.parse(GlobalV.urlTicketNumbers + this.operator.toString()),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + Token
        });
    if (response.statusCode == 200) {
      var list = json.decode(response.body);

      return list["count1Dt"];
    }
    return [0];
  }

  getNumberOfTickets5dt() async {
    // log("entered get number of tickete 5");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String Token = prefs.getString("token");
    http.Response response = await http.get(
        Uri.parse(GlobalV.urlTicketNumbers + this.operator.toString()),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + Token
        });
    // log("response code " + response.statusCode.toString());
    if (response.statusCode == 200) {
      var list = json.decode(response.body);
      // log("body " + response.body);

      return list["count5Dt"];
    }
    return [0];
  }

  getTicket() async {
    log("entered get ticket");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String Token = prefs.getString("token");
    http.Response response = await http.get(
        Uri.parse(GlobalV.urlTicketNumbers +
            this.operator.toString() +
            "/" +
            this.type.toString()),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + Token
        });
    log("response code " + response.statusCode.toString());
    if (response.statusCode == 200) {
      var list = json.decode(response.body);
      log("body " + response.body);

      return list["ticket"]["code"];
    }
    return [0];
  }
}
