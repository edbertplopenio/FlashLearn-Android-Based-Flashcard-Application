class FlashcardSet {
  final String name;
  final String creationDate;

  FlashcardSet({required this.name, required this.creationDate});

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      name: json['name'],
      creationDate: json['creationDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'creationDate': creationDate,
    };
  }

  FlashcardSet copyWith({String? name, String? creationDate}) {
    return FlashcardSet(
      name: name ?? this.name,
      creationDate: creationDate ?? this.creationDate,
    );
  }
}
