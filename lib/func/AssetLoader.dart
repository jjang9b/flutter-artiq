import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;

class FileAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String localePath, Locale locale) async {
    String path = localePath + "/" + locale.toString() + ".json";
    String localeJson = await rootBundle.loadString(path);

    return json.decode(await localeJson);
  }
}
