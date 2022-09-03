import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globalV.dart';
import 'package:http/http.dart' as http;

class User {
  dynamic token;
  String role;
  bool wasLoggedin = false;
  String username;
  String email;
  String id;
  int balance = 1;

  User({this.token, this.role});

  void setToken(dynamic token) {
    this.token = token;
  }

  setRoles(String roles) {
    this.role = roles;
  }

  getRoles() {
    return this.role;
  }

  getToken() {
    return this.token;
  }

  Login(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log(username + " " + password);

    if (this.wasLoggedin) {
      this.role = prefs.getString("role");
      this.token = prefs.get("token");
      return this.role;
    } else {
      http.Response response = await http.post(Uri.parse(GlobalV.urlSignin),
          body: json.encode({"username": username, "password": password}),
          headers: <String, String>{
            'Content-Type': 'application/json',
          });
      log("status code" + response.statusCode.toString());
      if (response.statusCode == 200) {
        log("status 200");
        //this.token = response.headers["accessToken"];
        var list = json.decode(response.body);
        log("body " + response.body);

        this.token = list["accessToken"];
        this.id = list["id"];

        prefs.setString("token", this.token);
        log(this.token.toString());
        Map<String, dynamic> decodedToken = JwtDecoder.decode(this.token);
        // if (decodedToken["roles"].length > 1) {
        //   this.role = "admin";
        // } else
        //   this.role = "user";

        return response.statusCode;
      } else
        log("status is not ok");
    }
    return this.role;
  }

  Signup(String username, String password, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log("$password $username");
    http.Response response1 = await http.post(Uri.parse(GlobalV.urlSignup),
        body: json.encode(
            {"username": username, "password": password, "email": email}),
        headers: <String, String>{
          'Content-Type': 'application/json',
        });
    if (response1.statusCode == 200)
      log("status 200");
    else
      log("status is not ok 0 sign up part");

    http.Response response = await http.post(Uri.parse(GlobalV.urlSignin),
        body: json.encode({"username": username, "password": password}),
        headers: <String, String>{
          'Content-Type': 'application/json',
        });
    if (response.statusCode == 200) {
      log("status 200");
      var list = json.decode(response.body);
      log("body " + response.body);

      this.token = list["accessToken"];
      prefs.setString("token", this.token);
      this.id = list["id"];

      log(this.token.toString());
      Map<String, dynamic> decodedToken = JwtDecoder.decode(this.token);
      // if (decodedToken["roles"].length > 1) {
      //   this.role = "admin";
      // } else
      //   this.role = "user";
      // prefs.setString("role", this.role);

      return response.statusCode;
    } else
      log("status is not ok 1 sign part 2");
    return 400;
  }

  void logout() async {
    this.role = null;
    //this.token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", "");
  }

  initLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("token") != null || prefs.getString("token") != "") {
      wasLoggedin = true;
    }
    wasLoggedin = false;
  }

  getBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String Token = prefs.getString("token");
    http.Response response = await http
        .get(Uri.parse(GlobalV.urlBalance + this.id), headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + Token
    });
    if (response.statusCode == 200) {
      var list = json.decode(response.body);
      //log("body " + response.body);

      this.balance = list["balance"];
      //log(this.balance.toString());
    }
    return this.balance;
  }
}
