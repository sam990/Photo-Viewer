import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photoviewer/my_photo_view.dart';
import 'custom_tab_view.dart';

void main() {
  runApp(MyApp());
}

//
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PhotoViewerr',
        theme: ThemeData(primaryColor: Colors.black),
        home: CustomTabView());
  }
}

