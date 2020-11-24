import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_listings/model/User.dart';
import 'package:flutter_listings/services/FirebaseHelper.dart';
import 'package:flutter_listings/services/helper.dart';

import '../../constants.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({Key key, @required this.user}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState(user);
}

class _SettingsScreenState extends State<SettingsScreen> {
  User user;

  _SettingsScreenState(this.user);

  bool messages;

  @override
  void initState() {
    messages = user.settings.pushNewMessages;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text(
          'Configuración Push',
        ),
      ),
      body: SingleChildScrollView(
        child: Builder(
            builder: (buildContext) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16, top: 16, bottom: 8),
                      child: Text(
                        'GENERAL',
                        style: TextStyle(
                            color: isDarkMode(context)
                                ? Colors.white54
                                : Colors.black54,
                            fontSize: 18),
                      ),
                    ),
                    Material(
                      elevation: 2,
                      color:
                          isDarkMode(context) ? Colors.black12 : Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SwitchListTile.adaptive(
                              activeColor: Color(COLOR_ACCENT),
                              title: Text(
                                'Permitir notificaciones push',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isDarkMode(context)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              value: messages,
                              onChanged: (bool newValue) {
                                messages = newValue;
                                setState(() {});
                              }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        child: Material(
                          elevation: 2,
                          color: isDarkMode(context)
                              ? Colors.black12
                              : Colors.white,
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(12.0),
                            onPressed: () async {
                              showProgress(context, 'Saving changes...', true);
                              user.settings.pushNewMessages = messages;
                              User updateUser =
                                  await FireStoreUtils.updateCurrentUser(user);
                              hideProgress();
                              if (updateUser != null) {
                                this.user = updateUser;
                                MyAppState.currentUser = user;
                                Scaffold.of(buildContext).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text(
                                      'Configuración guardada satisfactoriamente',
                                      style: TextStyle(fontSize: 17),
                                    )));
                              }
                            },
                            child: Text(
                              'Guardar',
                              style: TextStyle(
                                  fontSize: 18, color: Color(COLOR_PRIMARY)),
                            ),
                            color: isDarkMode(context)
                                ? Colors.black12
                                : Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
      ),
    );
  }
}
