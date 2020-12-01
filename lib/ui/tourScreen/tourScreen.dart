import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TourScreen extends StatefulWidget {

  final String tourUrl;

  TourScreen({this.tourUrl});

  @override
  _TourScreenState createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
         "Virtual Tour",
        ),
      ),
      body: WebView(
        initialUrl: widget.tourUrl,
      ),
    );
  }
}