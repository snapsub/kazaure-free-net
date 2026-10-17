import 'package:flutter_v2ray_client/flutter_v2ray.dart';

class VpnConnectionService {
  late final V2ray v2ray;
  bool isConnected = false;

  void initializeVpn(Function(V2RayStatus) onStatusUpdate) {
    v2ray = V2ray(
      onStatusChanged: (status) {
        isConnected = (status.state == "CONNECTED");
        onStatusUpdate(status);
      },
    );
    v2ray.initialize();
  }

  Future<void> connectToServer(String configJson) async {
    bool granted = await v2ray.requestPermission();
    if (granted) {
      await v2ray.startV2Ray(remark: "FreeNet", config: configJson, proxyOnly: false);
    }
  }

  Future<void> disconnectServer() async {
    await v2ray.stopV2Ray();
  }
}
