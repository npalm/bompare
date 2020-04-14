/// Bill-of-material item identifier.
class ItemId implements Comparable<ItemId> {
  final String package;
  final String version;

  ItemId(this.package, this.version);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemId &&
          runtimeType == other.runtimeType &&
          package == other.package &&
          version == other.version;

  @override
  int get hashCode => package.hashCode ^ version.hashCode;

  @override
  int compareTo(ItemId other) {
    final diff = package.compareTo(other.package);
    if (diff != 0) return diff;

    return version.compareTo(other.version);
  }
}