import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

class Style {
  Future<Map> getData() async {
    final stringData = await rootBundle.loadString('assets/style/style.yaml');
    final YamlMap yamlData = loadYaml(stringData);
    print(yamlData);
    final map = {};
    yamlData.forEach((key, value) => map.putIfAbsent(key, () => value));
    return map;
  }
}
