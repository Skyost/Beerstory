/// Compares two objects according to their fields.
int compareAccordingToFields<T>(T a, T b, List<Comparable?> Function(T) fields) {
  List<Comparable?> aValues = fields(a);
  List<Comparable?> bValues = fields(b);
  for (int i = 0; i < aValues.length; i++) {
    Comparable? aValue = aValues[i];
    Comparable? bValue = bValues[i];
    if (aValue == null) {
      if (bValue == null) {
        continue;
      }
      return -1;
    }
    if (bValue == null) {
      return 1;
    }
    int compareResult = aValue.compareTo(bValue);
    if (compareResult != 0) {
      return compareResult;
    }
  }
  return 0;
}
