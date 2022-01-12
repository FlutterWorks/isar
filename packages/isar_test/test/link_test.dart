import 'package:isar/isar.dart';
import 'package:isar_test/common.dart';

import 'package:test/test.dart';

import 'package:isar_test/link_model.dart';

void main() {
  group('Links', () {
    late Isar isar;
    late IsarCollection<LinkModelA> linksA;
    late IsarCollection<LinkModelB> linksB;

    late LinkModelA objA1;
    late LinkModelA objA2;
    late LinkModelA objA3;

    late LinkModelB objB1;
    late LinkModelB objB2;
    late LinkModelB objB3;

    setUp(() async {
      isar = await openTempIsar([LinkModelASchema, LinkModelBSchema]);
      linksA = isar.linkModelAs;
      linksB = isar.linkModelBs;

      objA1 = LinkModelA.name('modelA1');
      objA2 = LinkModelA.name('modelA2');
      objA3 = LinkModelA.name('modelA3');

      objB1 = LinkModelB.name('modelB1');
      objB2 = LinkModelB.name('modelB2');
      objB3 = LinkModelB.name('modelB3');
    });

    tearDown(() async {
      await isar.close();
    });

    group('self link', () {
      isarTest('new obj new target', () async {
        objA1.selfLink.value = objA2;
        objA3.selfLink.value = objA3;
        await isar.writeTxn((isar) async {
          await linksA.putAll([objA1, objA3]);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.selfLink.load();
        expect(newA1.selfLink.value, objA2);

        final newA3 = await linksA.get(objA3.id!);
        await newA3!.selfLink.load();
        expect(newA3.selfLink.value, objA3);
      });

      isarTest('new obj existing target', () async {
        await isar.writeTxn((isar) async {
          await linksA.put(objA2);
        });

        objA1.selfLink.value = objA2;
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.selfLink.load();
        expect(newA1.selfLink.value, objA2);
      });

      isarTest('existing obj new target', () async {
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        objA1.selfLink.value = objA2;
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.selfLink.load();
        expect(newA1.selfLink.value, objA2);
      });

      isarTest('.load() / .save()', () async {
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        objA1.selfLink.value = objA2;
        await isar.writeTxn((isar) async {
          await objA1.selfLink.save();
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.selfLink.load();
        expect(newA1.selfLink.value, objA2);

        objA1.selfLink.value = null;
        await isar.writeTxn((isar) async {
          await objA1.selfLink.save();
        });

        await newA1.selfLink.load();
        expect(newA1.selfLink.value, null);
      });
    });

    group('other link', () {
      isarTest('new obj new target', () async {
        objA1.otherLink.value = objB1;
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.otherLink.load();
        expect(newA1.otherLink.value, objB1);
      });

      isarTest('new obj existing target', () async {
        await isar.writeTxn((isar) async {
          await linksB.put(objB1);
        });

        objA1.otherLink.value = objB1;
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.otherLink.load();
        expect(newA1.otherLink.value, objB1);
      });

      isarTest('existing obj added new', () async {
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        objA1.otherLink.value = objB1;
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.otherLink.load();
        expect(newA1.otherLink.value, objB1);
      });

      isarTest('.load() / .save()', () async {
        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        objA1.otherLink.value = objB1;
        await isar.writeTxn((isar) async {
          await objA1.otherLink.save();
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.otherLink.load();
        expect(newA1.otherLink.value, objB1);

        objA1.otherLink.value = null;
        await isar.writeTxn((isar) async {
          await objA1.otherLink.save();
        });

        await newA1.otherLink.load();
        expect(newA1.otherLink.value, null);
      });
    });

    group('self links', () {
      isarTest('new obj', () async {
        await isar.writeTxn((isar) async {
          await linksA.put(objA3);
        });
        objA1.selfLinks.add(objA2);
        objA1.selfLinks.add(objA3);

        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.selfLinks.load();
        expect(newA1.selfLinks.length, 2);
        expect(newA1.selfLinks, {objA2, objA3});
      });

      isarTest('existing obj', () async {
        await isar.writeTxn((isar) async {
          await linksA.putAll([objA1, objA3]);
        });
        objA1.selfLinks.add(objA2);
        objA1.selfLinks.add(objA3);

        await isar.writeTxn((isar) async {
          await linksA.put(objA1);
        });

        final newA1 = await linksA.get(objA1.id!);
        await newA1!.selfLinks.load();
        expect(newA1.selfLinks.length, 2);
        expect(newA1.selfLinks, {objA2, objA3});
      });
    });
  });
}
