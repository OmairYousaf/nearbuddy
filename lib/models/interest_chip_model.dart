
class InterestChipModel {
  final String label;
   bool isSelected;
  final String catID;

  InterestChipModel({
    required this.label,
    required this.catID,
    required this.isSelected,
  });
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'isSelected': isSelected,
      'catID': catID,
    };
  }

  factory InterestChipModel.fromMap(Map<String, dynamic> map) {
    return InterestChipModel(
      label: map['label'],
      isSelected: map['isSelected'],
      catID: map['catID'],
    );
  }
  InterestChipModel copy(
    bool isSelected,
  ) =>
      InterestChipModel(
        label: label,
        catID: catID,
        isSelected: isSelected,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestChipModel &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          isSelected == other.isSelected;

  @override
  int get hashCode => label.hashCode ^ isSelected.hashCode;

  @override
  String toString() {
    return 'TagChipModel{label: $label, tagID: $catID}';
  }
}
