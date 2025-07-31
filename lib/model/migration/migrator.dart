import 'dart:convert';

import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/history_entry/repository.dart';
import 'package:beerstory/model/migration/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Allows to migrate old app data.
class Migrator {
  /// Returns `true` if the repositories need to be migrated.
  static Future<bool> needsMigration(WidgetRef ref) async {
    Storage storage = Storage();
    return await storage.fileExists('bars') || await storage.fileExists('beers') || await storage.fileExists('history');
  }

  /// Migrates all repositories.
  static Future<void> migrate(WidgetRef ref) async {
    Storage storage = Storage();
    Map<String, String> migratedBarsUuids = {};
    if (await storage.fileExists('bars')) {
      BarRepository barRepository = ref.read(barRepositoryProvider.notifier);
      Map objects = jsonDecode(await storage.readFile('bars'));
      for (Map object in objects.values) {
        Bar bar = Bar(
          name: object['name'],
          address: object['address'],
        );
        await barRepository.add(bar);
        migratedBarsUuids[object['uuid']] = bar.uuid;
      }
    }
    Map<String, String> migratedBeersUuids = {};
    if (await storage.fileExists('beers')) {
      BeerRepository beerRepository = ref.read(beerRepositoryProvider.notifier);
      BeerPriceRepository beerPriceRepository = ref.read(
        beerPriceRepositoryProvider.notifier,
      );
      Map objects = jsonDecode(await storage.readFile('beers'));
      for (Map object in objects.values) {
        String? image = object['image'];
        if (image != null) {
          image = await BeerImage.copyImage(
            originalFilePath: image,
            filenamePrefix: object['uuid'],
          );
        }
        Beer beer = Beer(
          name: object['name'],
          image: image,
          tags: object['tags'].cast<String>(),
          degrees: object['degrees'],
          rating: object['rating'],
        );
        await beerRepository.add(beer);
        migratedBeersUuids[object['uuid']] = beer.uuid;
        Map? prices = jsonDecode(object['prices']);
        if (prices != null) {
          for (Map price in prices.values) {
            await beerPriceRepository.add(
              BeerPrice(
                beerUuid: beer.uuid,
                barUuid: migratedBarsUuids[price['barUuid']],
                amount: price['price'],
              ),
            );
          }
        }
      }
    }
    if (await storage.fileExists('history')) {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      History history = ref.read(historyProvider.notifier);
      Map objects = jsonDecode(await storage.readFile('history'));
      for (Map object in objects.values) {
        DateTime date = formatter.parse(object['date']);
        List entries = object['entries'];
        for (Map entry in entries) {
          String? beerUuid = migratedBeersUuids[entry['beer']];
          if (beerUuid != null) {
            await history.add(
              HistoryEntry(
                date: date,
                beerUuid: beerUuid,
                quantity: entry['quantity'],
                times: entry['times'],
                moreThanQuantity: entry['moreThanQuantity'],
              ),
            );
          }
        }
      }
    }
  }
}
