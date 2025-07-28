/// An object that can be searched in a list.
mixin Searchable {
  /// The search terms.
  List<String> get searchTerms => [];
}

/// Allows to search a list of items.
extension SearchableExtension<T extends Searchable> on List<T> {
  /// Finds the items that match the request.
  List<T> find(String request) => [
    for (T item in this)
      if (item.searchTerms.any((term) => term.toLowerCase().contains(request)))
        item
  ];
}
