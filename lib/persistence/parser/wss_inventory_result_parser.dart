import 'dart:convert';
import 'dart:io';

import 'package:bompare/service/domain/spdx_mapper.dart';
import 'package:path/path.dart' as path;

import '../../service/domain/item_id.dart';
import '../../service/domain/scan_result.dart';
import '../persistence_exception.dart';
import '../result_parser.dart';

/// Decoder for files in WhiteSource "inventory" file format.
class WhiteSourceInventoryResultParser implements ResultParser {
  static const field_name = 'name';
  static const field_version = 'version';
  static const field_group_id = 'groupId';
  static const field_artifact_id = 'artifactId';
  static const field_type = 'type';

  final SpdxMapper mapper;
  final assumed = <ItemId>{};

  WhiteSourceInventoryResultParser(this.mapper);

  @override
  Future<ScanResult> parse(File file) {
    if (!file.existsSync()) {
      throw PersistenceException(
          file, 'WhiteSource inventory (JSON) file not found');
    }

    try {
      final result = ScanResult(path.basenameWithoutExtension(file.path));
      final str = file.readAsStringSync();

      final map = jsonDecode(str) as Map<String, dynamic>;
      (map['libraries'] as Iterable)
          .map(_decodeItem)
          .forEach((itemId) => result.addItem(itemId));

      return Future.value(result);
    } on Exception catch (e) {
      return Future.error(PersistenceException(file, 'Unexpected format: $e'));
    }
  }

  ItemId _decodeItem(dynamic obj) {
    final itemId = _decodeItemId(obj);

    _decodeLicenses(itemId, obj);
    return itemId;
  }

  ItemId _decodeItemId(dynamic obj) {
    final type = obj[field_type];
    final version = obj[field_version] ?? '';
    final name = obj[field_name] as String;
    final group = obj[field_group_id] as String;

    switch (type) {
      case 'Java':
        final artifact = obj[field_artifact_id] as String;
        return ItemId('$group:$artifact', version);
      case 'javascript/Node.js':
      case 'JavaScript':
        return ItemId(group, version);
      case 'ActionScript':
      case 'Alpine':
      case 'Source Library':
      case 'Unknown Library':
        return ItemId(name, version);
      default:
        final id = ItemId(group, version);
        if (!assumed.contains(id)) {
          print('Warning: Assumed $id for WhiteSource type "$type"');
          assumed.add(id);
        }
        return id;
    }
  }

  void _decodeLicenses(ItemId itemId, dynamic obj) {
    final licenses = obj['licenses'] as Iterable ?? [];
    licenses.forEach((lic) {
      final name = lic['name'] as String;
      itemId.addLicenses(mapper[name]);
    });
  }
}
