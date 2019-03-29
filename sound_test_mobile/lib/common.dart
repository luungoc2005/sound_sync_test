import 'package:flutter/material.dart';

final DEFAULT_SERVER_ADDRESS = 'http://192.168.23.6:3000';

enum EventTypes {
  action,
}

abstract class MEDIA_ACTIONS {
  static const int ONPLAY = 0;
  static const int PLAYING = 1;
  static const int SEEKING = 2;
  static const int SEEKED = 3;
  static const int ONPAUSE = 4;
  static const int SYNC = 10;
}

class ChannelInfo {
  String channelId;
  String name;
  String status;
  String fileName;

  ChannelInfo({Key key, this.channelId, this.name, this.status});
}

class PidController {
  double k_p = 1;
  double k_i = 0;
  double k_d = 0;
  int dt = 0;

  double currentValue = 0;
  double i_max = 0;
  double sumError = 0;
  double lastError = 0;
  DateTime lastTime;

  double target = 0;

  void setTarget(double newTarget) {
    target = newTarget;
  }

  double update(currentValue) {
    this.currentValue = currentValue;

    // dt
    var dt = this.dt;
    if (dt == 0) {
      var currentTime = new DateTime.now();
      if (this.lastTime == null) {
        dt = 0;
      }
      else {
        dt = currentTime.difference(this.lastTime).inMicroseconds;
      }
      this.lastTime = currentTime;
    }

    if (dt == 0) dt = 1;

    var error = this.target - this.currentValue;
    this.sumError += error * dt;
    if (this.i_max > 0 && this.sumError.abs() > this.i_max) {
      var sumSign = (this.sumError > 0) ? 1 : -1;
      this.sumError = sumSign * this.i_max;
    }

    var dError = (error - this.lastError) / dt;
    this.lastError = error;

    return (this.k_p * error) + (this.k_i * this.sumError) + (this.k_d * dError);
  }

  void reset() {
    this.sumError  = 0;
    this.lastError = 0;
    this.lastTime  = null;
  }
}