import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:http/http.dart' as http;
import 'package:khedni_maak/globals/constant.dart';
import 'package:khedni_maak/introduction_screen/introduction_screen.dart';
import 'package:khedni_maak/login/utils/models/login_data.dart';
import 'package:khedni_maak/login/utils/models/signUp_data.dart';
import 'package:khedni_maak/login/utils/providers/login_messages.dart';

import 'constants.dart';
import 'custom_route.dart';
import 'flutter_login.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

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
        "name": data.firstName + data.lastName,
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
        forgotPasswordButton: 'Forgot huh?',
        recoverPasswordButton: 'HELP ME',
        goBackButton: 'GO BACK',
        confirmPasswordError: 'Not match!',
        recoverPasswordIntro: 'Don\'t feel bad. Happens all the time.',
        recoverPasswordDescription:
            'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
        recoverPasswordSuccess: 'Password rescued successfully',
      ),
      emailValidator: (value) {
        if (!value.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) return 'Password is empty';

        return null;
      },
      firstNameValidator: (value) {
        if (value.isEmpty) return 'First Name is empty';

        return null;
      },
      lastNameValidator: (value) {
        if (value.isEmpty) return 'Last Name is empty';

        return null;
      },
      phoneNumberValidator: (value) {
        if (value.isEmpty) return 'Phone Number is empty';

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
        Navigator.of(context).pushReplacement(FadePageRoute(
          // builder: (context) => DashboardScreen(),
          builder: (context) => IntroductionView(),
        ));
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
