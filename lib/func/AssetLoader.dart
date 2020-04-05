import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;

class FileAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String localePath) async {
    String localeJson = await rootBundle.loadString(localePath);

    return json.decode(await localeJson);
  }
}
