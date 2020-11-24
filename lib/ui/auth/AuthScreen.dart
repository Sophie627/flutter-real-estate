import 'package:flutter/material.dart';
import 'package:flutter_listings/services/helper.dart';

import '../../constants.dart' as Constants;
import '../../constants.dart';
import '../login/LoginScreen.dart';
import '../signUp/SignUpScreen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
            color: isDarkMode(context) ? Colors.white : Colors.black),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 20.0),
                child: Icon(
                  Icons.location_on,
                  size: 150.0,
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 32, top: 32, right: 32, bottom: 8),
              child: Text(
                'Bienvenido a su App de propiedad Raiz',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(Constants.COLOR_PRIMARY),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'La mejor oferta de propiedad raiz',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton(
                  color: Color(Constants.COLOR_PRIMARY),
                  child: Text(
                    'Inicia sesión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  splashColor: Color(Constants.COLOR_PRIMARY),
                  onPressed: () {
                    push(context, new LoginScreen());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Color(Constants.COLOR_PRIMARY))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 40.0, left: 40.0, top: 20, bottom: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: FlatButton(
                  child: Text(
                    'Regístrate',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(COLOR_PRIMARY)),
                  ),
                  onPressed: () {
                    push(context, new SignUpScreen());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.black54)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
