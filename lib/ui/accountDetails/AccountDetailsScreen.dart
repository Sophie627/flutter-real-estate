import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_listings/model/User.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';

import '../../constants.dart';
import '../../main.dart';

class AccountDetailsScreen extends StatefulWidget {
  final User user;

  AccountDetailsScreen({Key key, @required this.user}) : super(key: key);

  @override
  _AccountDetailsScreenState createState() {
    return _AccountDetailsScreenState(user);
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  User user;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String firstName, lastName, email, mobile;

  _AccountDetailsScreenState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detalles de tu cuenta'),
        ),
        body: Builder(
            builder: (buildContext) => SingleChildScrollView(
                  child: Form(
                    key: _key,
                    autovalidate: _validate,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, bottom: 8, top: 24),
                            child: Text(
                              'INFORMACIÓN PÚBLICA',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Material(
                              elevation: 2,
                              color: isDarkMode(context)
                                  ? Colors.black12
                                  : Colors.white,
                              child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: ListTile.divideTiles(
                                      context: buildContext,
                                      tiles: [
                                        ListTile(
                                          title: Text(
                                            'Nombre',
                                            style: TextStyle(
                                              color: isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          trailing: ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 100),
                                            child: TextFormField(
                                              onSaved: (String val) {
                                                firstName = val;
                                              },
                                              validator: validateName,
                                              textInputAction:
                                                  TextInputAction.next,
                                              textAlign: TextAlign.end,
                                              initialValue: user.firstName,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: isDarkMode(context)
                                                      ? Colors.white
                                                      : Colors.black),
                                              cursorColor: Color(COLOR_ACCENT),
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Nombre',
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5)),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Apellido',
                                            style: TextStyle(
                                                color: isDarkMode(context)
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                          trailing: ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 100),
                                            child: TextFormField(
                                              onSaved: (String val) {
                                                lastName = val;
                                              },
                                              validator: validateName,
                                              textInputAction:
                                                  TextInputAction.next,
                                              textAlign: TextAlign.end,
                                              initialValue: user.lastName,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: isDarkMode(context)
                                                      ? Colors.white
                                                      : Colors.black),
                                              cursorColor: Color(COLOR_ACCENT),
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'Apellido',
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5)),
                                            ),
                                          ),
                                        ),
                                      ]).toList())),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, bottom: 8, top: 24),
                            child: Text(
                              'INFORMACIÓN PRIVADA',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Material(
                            elevation: 2,
                            color: isDarkMode(context)
                                ? Colors.black12
                                : Colors.white,
                            child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: ListTile.divideTiles(
                                  context: buildContext,
                                  tiles: [
                                    ListTile(
                                      title: Text(
                                        'Correo electrónico',
                                        style: TextStyle(
                                            color: isDarkMode(context)
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      trailing: ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxWidth: 200),
                                        child: TextFormField(
                                          onSaved: (String val) {
                                            email = val;
                                          },
                                          validator: validateEmail,
                                          textInputAction: TextInputAction.next,
                                          initialValue: user.email,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black),
                                          cursorColor: Color(COLOR_ACCENT),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Correo electrónico',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5)),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Teléfono',
                                        style: TextStyle(
                                            color: isDarkMode(context)
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      trailing: ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxWidth: 150),
                                        child: TextFormField(
                                          onSaved: (String val) {
                                            mobile = val;
                                          },
                                          validator: validateMobile,
                                          textInputAction: TextInputAction.done,
                                          initialValue: user.phoneNumber,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: isDarkMode(context)
                                                  ? Colors.white
                                                  : Colors.black),
                                          cursorColor: Color(COLOR_ACCENT),
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Teléfono',
                                              contentPadding:
                                                  EdgeInsets.only(bottom: 2)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ).toList()),
                          ),
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 32.0, bottom: 16),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    minWidth: double.infinity),
                                child: Material(
                                  elevation: 2,
                                  color: isDarkMode(context)
                                      ? Colors.black12
                                      : Colors.white,
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.all(12.0),
                                    onPressed: () async {
                                      _validateAndSave(buildContext);
                                    },
                                    child: Text(
                                      'Guardar',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color(COLOR_PRIMARY)),
                                    ),
                                  ),
                                ),
                              )),
                        ]),
                  ),
                )));
  }

  _validateAndSave(BuildContext buildContext) async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      if (user.email != email) {
        TextEditingController _passwordController = new TextEditingController();
        showDialog(
            context: context,
            child: Dialog(
              elevation: 16,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Para cambiar tu correo electrónico, primero debes escribir tu contraseña',
                        style: TextStyle(color: Colors.red, fontSize: 17),
                        textAlign: TextAlign.start,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(hintText: 'Clave'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RaisedButton(
                          color: Color(COLOR_ACCENT),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          onPressed: () async {
                            if (_passwordController.text.isEmpty) {
                              showAlertDialog(context, "Si Clave",
                                  "La clave en necesaria");
                            } else {
                              Navigator.pop(context);
                              showProgress(context, 'Verificando...', false);
                              AuthResult result = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: 'mail@mail.com',
                                      password: _passwordController.text)
                                  .catchError((onError) {
                                hideProgress();
                                showAlertDialog(context, 'No me pude verificar',
                                    'Vuelva a verificar la contraseña e intentalo de nuevo.');
                              });
                              _passwordController.dispose();
                              if (result.user != null) {
                                await result.user.updateEmail(email);
                                updateProgress('Guardando...');
                                await _updateUser(buildContext);
                                hideProgress();
                              } else {
                                hideProgress();
                                Scaffold.of(buildContext).showSnackBar(SnackBar(
                                    content: Text(
                                  'No pude verificarlo, intenta nuevamente',
                                  style: TextStyle(fontSize: 17),
                                )));
                              }
                            }
                          },
                          child: Text(
                            'Verificar',
                            style: TextStyle(
                                color: isDarkMode(context)
                                    ? Colors.black
                                    : Colors.white),
                          ),
                        ),
                      )
                    ],
                  )),
            ));
      } else {
        showProgress(context, "Guardando...", false);
        await _updateUser(buildContext);
        hideProgress();
      }
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  _updateUser(BuildContext buildContext) async {
    user.firstName = firstName;
    user.lastName = lastName;
    user.email = email;
    user.phoneNumber = mobile;
    var updatedUser = await FireStoreUtils.updateCurrentUser(user);
    if (updatedUser != null) {
      MyAppState.currentUser = user;
      Scaffold.of(buildContext).showSnackBar(SnackBar(
          content: Text(
        'Guardado correctamente',
        style: TextStyle(fontSize: 17),
      )));
    } else {
      Scaffold.of(buildContext).showSnackBar(SnackBar(
          content: Text(
        'No se pudieron guardar, por favor intenta nuevamente',
        style: TextStyle(fontSize: 17),
      )));
    }
  }
}
