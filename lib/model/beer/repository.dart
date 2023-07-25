import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The beer repository provider.
final beerRepositoryProvider = ChangeNotifierProvider<BeerRepository>((ref) => BeerRepository()..init());

/// The repository that handles beers.
class BeerRepository extends Repository<Beer> {
  /// Creates a new beer repository instance.
  BeerRepository()
      : super(
          file: 'beers',
        );

  /// Removes a bar reference from all beers.
  void removeBar(Bar bar) {
    for (Beer beer in objects) {
      beer.removeBarPrices(bar, notify: false);
    }
    notifyListeners();
  }

  @override
  Future<void> remove(Beer object, {bool notify = true}) async {
    super.remove(object, notify: notify);
    if (object.image != null && await storage.fileExists(object.image!)) {
      storage.deleteFile(file);
    }
  }

  @override
  Beer createObjectFromJson(Map<String, dynamic> jsonData) => Beer.fromJson(jsonData);
}
