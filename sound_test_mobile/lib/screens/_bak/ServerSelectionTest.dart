import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class ServerInfo {
  String id;
  String name;
  String address;
  int port;

  ServerInfo({Key key, this.id, this.name, this.address, this.port});
}

class ServerSelection extends StatefulWidget {
  @override
  _ServerSelectionState createState()  => _ServerSelectionState();
}

class _ServerSelectionState extends State<ServerSelection> {
  List<ServerInfo> serverList;
  RawDatagramSocket socket;

  _ServerSelectionState(): super() {
    var multicastAddress = new InternetAddress('239.192.0.197');
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 4545, reuseAddress: true)
        .then((RawDatagramSocket socket) {
//        socket.broadcastEnabled = true;
      socket.joinMulticast(multicastAddress);
      this.socket = socket;

      print('[UDP] Scanning for servers on ${socket.address.address}:${socket.port}');
      socket.listen((RawSocketEvent e){
        Datagram d = socket.receive();
        if (d == null) return;

        String message = new String.fromCharCodes(d.data);
        print('Received message - Raw: ${message}');

        try {
          var data = jsonDecode(message);
          assert(data is Map);
          this._addServerInfo(data);
        }
        catch (e) {
          print('Error encountered on decoding JSON: ${e.toString()}');
        }
      });
    });
  }

  void _addServerInfo(Map data) {
    if (data.containsKey('_t') && data['_t'] == 'ADDR_BROADCAST') {
      try {
        assert(data.containsKey('id'));
        assert(data.containsKey('name'));
        assert(data.containsKey('address'));
        assert(data.containsKey('port'));

        if (serverList.firstWhere((ServerInfo item) { return item.id == data['id']; }) != null) {
          setState(() {
            serverList.add(new ServerInfo(
              id: data['id'],
              name: data['name'],
              address: data['address'],
              port: data['port']
            ));
          });
        }
      }
      catch (e) {
        print('Error encountered on decoding JSON: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Server Selection'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 8,
                child: ListView.builder(
                  itemCount: this.serverList?.length ?? 0,
                  itemBuilder: (context, int index) {
                    return Text('${this.serverList[index].name})');
                  },
                )
            ),
            Expanded(
                flex: 1,
                child: SizedBox.expand(child: RaisedButton(
                    child: Text('Connect')
                ))
            ),
            Expanded(
              flex: 1,
              child: SizedBox.expand(child: FlatButton(
                  child: Text('Connect Manually')
              )),
            )
          ],
        )
      )
    );
  }
}