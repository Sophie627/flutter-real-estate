import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_listings/services/helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String url = "tel:(036)3170017";
          launch(url);
        },
        backgroundColor: Color(COLOR_ACCENT),
        child: Icon(
          Icons.call,
          color: isDarkMode(context) ? Colors.black : Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text('Contáctenos'),
        centerTitle: true,
      ),
      body: Column(children: <Widget>[
        Material(
            elevation: 2,
            color: isDarkMode(context) ? Colors.black12 : Colors.white,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16.0, left: 16, top: 16),
                    child: Text(
                      'Oficina principal',
                      style: TextStyle(
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16, top: 16, bottom: 16),
                    child:
                        Text('Calle 12 # 34 - 56 Medellín / Colombia'),
                  ),
                  ListTile(
                    onTap: () async {
                      var url =
                          'mailto:info@mail.com?subject=Solicitud de contacto';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        showAlertDialog(context, 'No se pudo enviar el correo electrónico',
                            'No tienes ninguna aplicación de correo instalada');
                      }
                    },
                    title: Text(
                      'Nuestro correo de contacto',
                      style: TextStyle(
                          color:
                              isDarkMode(context) ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('info@mail.com'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color:
                          isDarkMode(context) ? Colors.white54 : Colors.black54,
                    ),
                  )
                ]))
      ]),
    );
  }
}
