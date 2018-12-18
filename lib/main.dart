import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

String clientId = "5c18e3daa74ad8d5b32e9436";
String token = "2844865:bd9166356cb06e4f5eb4a7edef01f244";
String id = "2844865";

void main() {
  Mqtt.init();

  Mqtt.connect().then((val) {
    print("===> Connection Result: $val");
    Mqtt.subAndPub();
  });

  return runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gap MQTT',
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Hello world!"),
      ),
    );
  }
}

class Mqtt {
  static MqttClient client;

  static init() {
    client = MqttClient("wss://m4.gap.im/mqtt", clientId);
    client.setProtocolV311();
    client.keepAlivePeriod = 60;
    client.port = 443;
    client.useWebSocket = true;
    client.logging(on: true);

    client.onDisconnected = () {
      print("\n\n\n==> Disconnected | Time: ${DateTime.now().toUtc()}\n\n\n");
      // client.disconnect();
    };

    client.connectionMessage = MqttConnectMessage()
        .authenticateAs(id, token)
        .withClientIdentifier(clientId);

    client.connectionMessage.startClean();
  }

  static Future connect() async {
    try {
      MqttClientConnectionStatus status = await client.connect();

      print("===> Connection Status: $status");

      return status;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static subAndPub() async {
    // client.subscribe("u/$id", MqttQos.exactlyOnce);

    // await MqttUtilities.asyncSleep(1);

    // This Works!
    MqttClientPayloadBuilder builder1 = MqttClientPayloadBuilder();
    builder1.addString(
      json.encode(
        {
          "type": "msgText",
          "data": "Works!",
          "identifier": Random().nextInt(1000000),
        },
      ),
    );

    client.publishMessage("u/$id", MqttQos.exactlyOnce, builder1.payload);

    // This will not works because of delay
    await MqttUtilities.asyncSleep(2);

    MqttClientPayloadBuilder builder2 = MqttClientPayloadBuilder();
    builder2.addString(
      json.encode(
        {
          "type": "msgText",
          "data": "Not works!",
          "identifier": Random().nextInt(1000000),
        },
      ),
    );

    client.publishMessage("u/$id", MqttQos.exactlyOnce, builder2.payload);
  }
}
