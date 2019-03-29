import 'package:sound_test_mobile/common.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';

class PlayerScreen extends StatefulWidget {
  final ChannelInfo channelInfo;
  final AudioPlayer audioPlayer = new AudioPlayer();

  PlayerScreen({Key key, this.channelInfo}): super();

  @override
  _PlayerScreenState createState() => _PlayerScreenState(
    channelInfo: this.channelInfo,
    audioPlayer: this.audioPlayer,
  );
}

class _PlayerScreenState extends State<PlayerScreen> {
  SocketIO ioClient;
  PidController controller;
  ChannelInfo channelInfo;
  AudioPlayer audioPlayer;
  double position = 0;

  _PlayerScreenState({Key key, this.channelInfo, this.audioPlayer}): super() {
    print('${DEFAULT_SERVER_ADDRESS}/${channelInfo.channelId}');
    ioClient = SocketIOManager().createSocketIO(
        DEFAULT_SERVER_ADDRESS,
        '/${channelInfo.channelId}', socketStatusCallback: _socketStatus);
    ioClient.init();
    ioClient.subscribe('action', this._handlePlayerAction);
    ioClient.connect();

    controller = new PidController();
    controller.setTarget(0);

    audioPlayer.onAudioPositionChanged.listen(this._setPosition);
  }

  void _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  void _setPosition(pos) {
    setState(() {
      this.position = pos;
    });
  }

  void _handlePlayerAction(action) async {
    var actionData = jsonDecode(action);
    print(actionData);
    switch(actionData['type']) {
      case MEDIA_ACTIONS.ONPLAY:
        this.controller.reset();
        await widget.audioPlayer.play(channelInfo.fileName, isLocal: true);
        await widget.audioPlayer.seek(actionData['position']);
        break;
      case MEDIA_ACTIONS.SEEKED:
        this.controller.reset();
        await widget.audioPlayer.seek(actionData['position']);
        break;
      case MEDIA_ACTIONS.ONPAUSE:
        await widget.audioPlayer.pause();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
          ],
        )
      )
    );
  }
}