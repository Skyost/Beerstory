import 'package:beerstory/model/repository_object.dart';

/// Represents a bar.
class Bar extends RepositoryObject {
  /// The bar name.
  String _name;

  /// The bar address.
  String? _address;

  /// Creates a new bar instance.
  Bar({
    super.uuid,
    required String name,
    String? address,
  })  : _name = name,
        _address = address;

  /// Creates a new bar instance from a JSON map.
  Bar.fromJson(Map<String, dynamic> jsonData)
      : this(
          uuid: jsonData['uuid'],
          name: jsonData['name'],
          address: jsonData['address'],
        );

  /// Returns the bar name.
  String get name => _name;

  /// Changes the bar name.
  set name(String name) {
    _name = name;
    notifyListeners();
  }

  /// Returns the bar address.
  String? get address => _address;

  /// Changes the bar address.
  set address(String? address) {
    _address = address;
    notifyListeners();
  }

  @override
  String get orderKey => _name.toLowerCase();

  @override
  List<String> get searchTerms => [_name, _address ?? ''];

  @override
  Map<String, dynamic> get jsonData => {
        'name': _name,
        'address': _address,
      };
}
