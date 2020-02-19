import 'package:flutter/material.dart';
import '../index.dart';
class HomeRoute extends StatefulWidget{
  @override
  _HomeRouteState createState() {
    // TODO: implement createState
    return new _HomeRouteState();
  }
}

class _HomeRouteState extends State<HomeRoute>{



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(GmLocalizations.of(context).home),
      ),
    );
  }
}