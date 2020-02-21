import 'package:flutter/material.dart';
import '../index.dart';
import 'package:flukit/flukit.dart';
class HomeRoute extends StatefulWidget{
  @override
  _HomeRouteState createState() {
    // TODO: implement createState
    return new _HomeRouteState();
  }
}

class _HomeRouteState extends State<HomeRoute>{


  @override
  void initState() {
    // TODO: implement initState
    print("HomeRoute initState");
    super.initState();
  }

  @override
  void didUpdateWidget(HomeRoute oldWidget) {
    // TODO: implement didUpdateWidget
    print("HomeRoute didUpdateWidget");
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print("HomeRoute build");
    return Scaffold(
      appBar: AppBar(
        //GmLocalizations是我们提供的一个Localizations类
        //用于支持多语言，因此当APP语言改变时，凡是使用GmLocalizations
        //动态获取的文案都会是相应语言的文案
        title: Text(GmLocalizations.of(context).home),
      ),
      body: _buildBody(), //构建主页面
      drawer: MyDrawer(), //抽屉菜单
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
    }else {
      //已登录，则展示列表项目
      return InfiniteListView<Repo>(
        onRetrieveData: (int page, List<Repo> items, bool refresh) async {
          var data = await Git(context).getRepos(
            refresh: refresh,
            queryParameters: {
              'page':page,
              'page_size':20,
            }
          );
          print("getRepos==>"+data.toString());
          //把请求到的新数据添加到items中
          items.addAll(data);
          //如果接口返回的数量等于'page_size',则认为还有数据，反之则认为最后一页
          return data.length==20;
        },
        itemBuilder: (List list, int index, BuildContext ctx){
          //项目信息列表项
          print(list[index].toString());
          return RepoItem(list[index]);
        },
      );
    }
  }
}

class MyDrawer extends StatelessWidget{

  const MyDrawer({Key key}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(), //构建抽屉菜单头部
            Expanded(
              child: _buildMenus(), //构建功能菜单
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(){
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel value, Widget child){
        return GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.only(top: 40,bottom: 20),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipOval(
                    //如果已登录，则显示用户头像，若未登录，则显示默认头像
                    child: value.isLogin
                        ? gmAvatar(value.user.avatar_url,width: 80)
                        : Image.asset(
                              "imgs/avatar-default.png",
                              width: 80,
                    )
                  ),
                ),
                Text(
                  value.isLogin
                        ? value.user.login
                        : GmLocalizations.of(context).login,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          onTap: (){
            if(!value.isLogin)
              Navigator.of(context).pushNamed("login");
          },
        );
      },
    );
  }

  //构建菜单项
  Widget _buildMenus(){
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel userModel, Widget child){
        var gm = GmLocalizations.of(context);
        return ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(gm.theme),
              onTap: () => Navigator.pushNamed(context, "themes"),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(gm.language),
              onTap: () => Navigator.pushNamed(context, "language"),
            ),
            if(userModel.isLogin) ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: Text(gm.logout),
              onTap: (){
                showDialog(
                  context: context,
                  builder: (ctx){
                    return AlertDialog(
                      content: Text(gm.logoutTip),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(gm.cancel),
                        ),
                        FlatButton(
                          onPressed: (){
                            userModel.user = null;
                            Navigator.pop(context);
                          },
                          child: Text(gm.yes),
                        ),
                      ],
                    );
                  }
                );
              },
            ),
          ],
        );
      },
    );
  }
}