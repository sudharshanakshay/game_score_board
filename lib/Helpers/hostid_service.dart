import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class HostIdService {
  static const _key = 'host_is';

  static final _storage = FlutterSecureStorage();

  static Future<String> getHostId() async {
    String? id = await _storage.read(key: _key);

    if (Platform.isLinux) { 
      if (kDebugMode) {
        print(' ----- Platform is Linux -----');
      }
    }

    if (id == null) {
      id = const Uuid().v4();
      await _storage.write(key: _key, value: id);
    }

    return id;
  }
}
