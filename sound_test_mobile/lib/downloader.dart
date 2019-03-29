import 'package:sound_test_mobile/common.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math';

String getRandomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(
      length,
          (index){
        return rand.nextInt(33)+89;
      }
  );

  return new String.fromCharCodes(codeUnits);
}

Future<String> downloadMedia(ChannelInfo channelInfo) async {
  var request = await HttpClient().getUrl(
      Uri.parse('${DEFAULT_SERVER_ADDRESS}/player/download?channelId=${channelInfo.channelId}')
  );

  Directory tempDir = await getTemporaryDirectory();
  var response = await request.close();
  var data = await consolidateHttpClientResponseBytes(response);

  var fileName = '${tempDir.path}/${getRandomString(16)}';
  var outputFile = new File(fileName);
  await outputFile.writeAsBytes(data);

  return fileName;
}