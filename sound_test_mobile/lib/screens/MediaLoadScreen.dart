
import 'package:flutter/material.dart';
import 'package:sound_test_mobile/common.dart';

class MediaLoadScreen extends StatelessWidget {
  final ChannelInfo channelInfo;

  MediaLoadScreen({Key key, this.channelInfo}): super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Loading...'),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(channelInfo.name, style: new TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      )),
                    )
                  ],
                ),
              )
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(channelInfo.status, style: new TextStyle(
                      fontSize: 20,
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 100.0),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            )
          ],
        )
      )
    );
  }
}