import 'package:bompare/service/domain/item_id.dart';
import 'package:test/test.dart';

void main() {
  group('$ItemId', () {
    const package = 'package';
    const version = 'version';

    test('createsInstance', () {
      final id = ItemId(package, version);

      expect(id.package, equals(package));
      expect(id.version, equals(version));
    });

    test('implements equality', () {
      final id = ItemId(package, version);
      final other1 = ItemId('other', version);
      final other2 = ItemId(package, 'other');
      final equal = ItemId(package, version);

      expect(id, equals(id));
      expect(id, equals(equal));
      expect(id, isNot(equals(other1)));
      expect(id, isNot(equals(other2)));
    });

    group('implements comparable', () {
      test('0 if equal', () {
        final id = ItemId(package, version);

        expect(id.compareTo(id), equals(0));
      });

      test('-1 if before', () {
        expect(
            ItemId('aaa', 'zzz').compareTo(ItemId('bbb', 'xxx')), equals(-1));
        expect(ItemId(package, 'aaa').compareTo(ItemId(package, 'zzz')),
            equals(-1));
      });

      test('+1 if after', () {
        expect(ItemId('bbb', 'xxx').compareTo(ItemId('aaa', 'zzz')), equals(1));
        expect(ItemId(package, 'bbb').compareTo(ItemId(package, 'aaa')),
            equals(1));
      });
    });
  });
}