/// A sortable object.
mixin Findable {
  /// The order key.
  Comparable get orderKey;

  /// The searchable terms.
  List<String> get searchTerms => [];
}
