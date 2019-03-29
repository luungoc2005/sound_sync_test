import 'package:flutter/material.dart';
import 'package:sound_test_mobile/common.dart';
import 'package:sound_test_mobile/screens/ServerSelection.dart';
import 'package:sound_test_mobile/screens/PlayerScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppContainer();
  }
}

class AppContainer extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<AppContainer> {
  ChannelInfo channelInfo;

  @override
  void initState() {
    super.initState();
  }

  void _setChannel(ChannelInfo nextChannel) {
    print(nextChannel);
    setState(() {
      channelInfo = nextChannel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      title: 'Melco WebView Test',
      title: 'Sound Test',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (context) => new ServerSelection(setChannel: _setChannel),
        '/player': (context) => new PlayerScreen(channelInfo: channelInfo),
      },
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
//      home: WebviewTest(),
    );
  }
}
