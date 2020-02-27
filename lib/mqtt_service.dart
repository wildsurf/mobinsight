import "package:mqtt_client/mqtt_client.dart";
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final url = "xxx.azure-devices.net";
  final port = 8883;
  final clientId = "xxx";

  final sas = "xxx";

  MqttServerClient _client;

  Future<MqttServerClient> connectMqtt() async {
    final user = url + "/" + clientId + "/api-version=2018-06-30";
    final client = MqttServerClient(url, clientId);
    final topic = "devices/" + clientId + "/messages/events/";

    client.port = port;
    client.logging(on: true);
    client.secure = true;
    client.setProtocolV311();

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(user, sas)
        .keepAliveFor(8000)
        .withWillTopic(topic + "type=xxx")
        .withWillMessage("")
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client.connect();
    } on Exception catch (e) {
      print(e);
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print("MqttClient connected");
      this._client = client;
    } else {
      print("Error. Connection State is ${client.connectionStatus.state}");
    }

    return client;
  }

  void publish(String text) async {
    if (_client == null ||
        _client.connectionStatus.state != MqttConnectionState.connected) {
      await connectMqtt();
    }

    final topic = "devices/" + clientId + "/messages/events/type=xxx";
    final builder = MqttClientPayloadBuilder();

    builder.addString(text);

    _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);
  }
}
