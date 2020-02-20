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
        //GmLocalizations是我们提供的一个Localizations类
        //用于支持多语言，因此当APP语言改变时，凡是使用GmLocalizations
        //动态获取的文案都会是相应语言的文案
        title: Text(GmLocalizations.of(context).home),
      ),
      body: _buildBody(), //构建主页面
    );
  }

  Widget _buildBody() {
    UserModel userModel = Provider.of(context);
    if(!userModel.isLogin){
      //用户未登录，显示登录按钮
      return Center(
        child: RaisedButton(
          child: Text(GmLocalizations.of(context).login),
          onPressed: () => Navigator.of(context).pushNamed("login"),
        ),
      );
    }
  }


}