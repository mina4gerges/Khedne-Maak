import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'file:///C:/Users/mina2/Desktop/Mobile%20Apps/Khedni-Maak/front-end/lib/screens/dashbaord_screen.dart';
import 'package:khedni_maak/firebase_config/model/message.dart';
import 'file:///C:/Users/mina2/Desktop/Mobile%20Apps/Khedni-Maak/front-end/lib/config/constant.dart';
import 'file:///C:/Users/mina2/Desktop/Mobile%20Apps/Khedni-Maak/front-end/lib/config/Validations.dart';
import 'package:khedni_maak/google_map/main.dart';
import 'package:khedni_maak/login/utils/models/login_data.dart';
import 'package:khedni_maak/login/utils/models/signUp_data.dart';
import 'package:khedni_maak/login/utils/providers/login_messages.dart';
import 'package:khedni_maak/nav_bar/nav_bar_main.dart';

import 'constants.dart';
import 'custom_route.dart';
import 'flutter_login.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  RegExp regexEmail = new RegExp(Validations.emailValidation["pattern"]);

  RegExp regexPhone = new RegExp(Validations.phoneValidation["pattern"]);

  RegExp regexPass = new RegExp(Validations.passValidation['pattern']);

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void initState() {
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _showItemDialog(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    final notification = message['data'];

    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context,
          Message(title: notification['title'], body: notification['body'])),
    );
  }

  Widget _buildDialog(BuildContext context, Message item) {
    return AlertDialog(
      content: Text(item.body),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
  }

  Future<String> _loginUser(LoginData data) async {
    //sign in
    final http.Response response = await http.post(
      '$baseUrl/auth/login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{"username": data.name, "password": data.password}),
    );

    if (response.statusCode == 200) {
      String token = json.decode(response.body)['token'];

      print(token);
      return null;
    } else if (response.statusCode == 400)
      return json.decode(response.body)["message"];
    else
      return "Unknown error";
  }

  Future<String> _signUpUser(SignUpData data) async {
    String firstName = data.firstName;
    String lastName = data.lastName;
    String name = "$firstName $lastName";

    final http.Response response = await http.post(
      '$baseUrl/auth/signup',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "username": data.name,
        "password": data.password,
        "email": data.name,
        "age": 0,
        "name": name,
        "phone": data.phoneNumber,
        "roles": [
          {
            "name": "ROLE_ADMIN",
            "description": "ADMIN",
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String token = json.decode(response.body)['token'];

      print(token);
      return null;
    } else if (response.statusCode == 400)
      return json.decode(response.body)["message"];
    else
      return "Unknown error";
  }

  Future<String> _recoverPassword(String name) {
    // return Future.delayed(loginTime).then((_) {
    //   if (!mockUsers.containsKey(name)) {
    //     return 'Username not exists';
    //   }
    //   return null;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: Constants.appName,
      logo: Constants.logoPath,
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
      messages: LoginMessages(
        usernameHint: 'Email',
        passwordHint: 'Pass',
        confirmPasswordHint: 'Confirm',
        loginButton: 'LOG IN',
        signupButton: 'REGISTER',
        recoverPasswordButton: 'HELP ME',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Not match!',
        recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
        recoverPasswordSuccess: 'Password rescued successfully',
      ),
      emailValidator: (value) {
        if (value.isEmpty || value.trim().isEmpty)
          return "Email is empty";
        else if (!regexEmail.hasMatch(value))
          return Validations.emailValidation["errorMsg"];
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty || value.trim().isEmpty)
          return 'Password is empty';
        else if (!regexPass.hasMatch(value))
          return Validations.passValidation["errorMsg"];
        return null;
      },
      firstNameValidator: (value) {
        if (value.isEmpty || value.trim().isEmpty) return 'First Name is empty';
        return null;
      },
      lastNameValidator: (value) {
        if (value.isEmpty || value.trim().isEmpty) return 'Last Name is empty';
        return null;
      },
      phoneNumberValidator: (value) {
        if (value.isEmpty || value.trim().isEmpty)
          return 'Phone Number is empty';
        else if (!regexPhone.hasMatch(value))
          return Validations.phoneValidation["errorMsg"];
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signUpData) {
        print('SignUp info');
        print('Name: ${signUpData.name}');
        print('Password: ${signUpData.password}');
        return _signUpUser(signUpData);
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context)
            .pushReplacement(FadePageRoute(builder: (context) => NavBarMain()));
        // builder: (context) => DashboardScreen()));
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        return _recoverPassword(name);
        // Show new password dialog
      },
    );
  }
}
