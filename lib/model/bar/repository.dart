import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bar repository provider.
final barRepositoryProvider = ChangeNotifierProvider<BarRepository>((ref) => BarRepository()..init());

/// The repository that handles bars.
class BarRepository extends Repository<Bar> {
  /// Creates a new bar repository instance.
  BarRepository()
      : super(
          file: 'bars',
        );

  @override
  Bar createObjectFromJson(Map<String, dynamic> jsonData) => Bar.fromJson(jsonData);
}
