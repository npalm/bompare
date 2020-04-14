import 'package:bompare/domain/item_id.dart';
import 'package:bompare/domain/scan_result.dart';
import 'package:test/test.dart';

void main() {
  group('$ScanResult', () {
    const name = 'name';
    test('creates instance', () {
      final result = ScanResult(name);

      expect(result.name, equals(name));
    });

    test('holds item identifiers', () {
      final result = ScanResult(name);
      final id = ItemId('package', 'version');

      result.addItem(id);

      expect(result.items, isA<Set<ItemId>>());
      expect(result.items, contains(id));
    });
  });
}