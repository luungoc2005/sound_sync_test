import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:sound_test_mobile/common.dart';
import 'package:flutter/material.dart';
import 'package:sound_test_mobile/downloader.dart';
import 'package:sound_test_mobile/screens/MediaLoadScreen.dart';

class ServerSelection extends StatefulWidget {
  final ValueChanged<ChannelInfo> setChannel;

  ServerSelection({Key key, this.setChannel}): super();

  @override
  _ServerSelectionState createState() => _ServerSelectionState();
}

class _ServerSelectionState extends State<ServerSelection> {
  List<ChannelInfo> channelsList;
  bool downloading = false;
  ChannelInfo nextChannel;

  _ServerSelectionState(): super() {
    getChannelsList();

    var refreshInterval = Duration(seconds:5);
    new Timer.periodic(refreshInterval, (_) => this.getChannelsList());
  }
  
  void getChannelsList() async {
    var request = await HttpClient().getUrl(Uri.parse('${DEFAULT_SERVER_ADDRESS}/channels/'));
    
    var response = await request.close();
    
    await for (var content in response.transform(Utf8Decoder())) {
      try {
        var jsonContent = jsonDecode(content);
        assert(jsonContent is List);

        var newList = new List<ChannelInfo>();
        for (var channelData in jsonContent) {
          newList.add(new ChannelInfo(
            channelId: channelData['id'],
            name: channelData['name'],
            status: channelData['status']
          ));
        }

        setState(() {
          channelsList = newList;
        });
      }
      catch (e) {

      }
    }
  }

  void connectTo(int channelIndex) async {
    try {
      var nextChannel = channelsList[channelIndex];

      this.setState(() {
        this.nextChannel = nextChannel;
        this.downloading = true;
      });

      var fileName = await downloadMedia(nextChannel);
      nextChannel.fileName = fileName;
      print('Downloaded ${fileName}');

      this.setState(() {
        this.downloading = false;
      });

      widget.setChannel(nextChannel);

      await Navigator.of(context).pushNamed('/player');
    }
    catch (e) {
      print(e);
      this.setState(() {
        this.nextChannel = null;
        this.downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.downloading) {
      return MediaLoadScreen(channelInfo: this.nextChannel);
    }
    else {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Channel Selection'),
        ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: this.channelsList?.length ?? 0,
                itemBuilder: (context, int index) {
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Text(
                                '${this.channelsList[index].name}',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            Text('${this.channelsList[index].status}'),
                          ],
                        ),
                      ),
                      onPressed: () => this.connectTo(index),
                    ),
                  );
                },
              )
            ),
          ],
        )
      )
    );
    }
  }
}