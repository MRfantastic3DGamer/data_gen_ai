class ItemCategoryDefinitionModel {
  const ItemCategoryDefinitionModel({
    this.category = 0,
    this.consumableTypeValue = 0,
    this.weaponTypeValue = 0,
    this.shieldTypeValue = 0,
  });

  final int category;
  final int consumableTypeValue;
  final int weaponTypeValue;
  final int shieldTypeValue;

  factory ItemCategoryDefinitionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const ItemCategoryDefinitionModel();
    }
    return ItemCategoryDefinitionModel(
      category: (json['category'] ?? json['Category'] ?? 0) as int,
      consumableTypeValue:
          (json['consumableTypeValue'] ?? json['ConsumableTypeValue'] ?? 0)
              as int,
      weaponTypeValue:
          (json['weaponTypeValue'] ?? json['WeaponTypeValue'] ?? 0) as int,
      shieldTypeValue:
          (json['shieldTypeValue'] ?? json['ShieldTypeValue'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'category': category,
    'consumableTypeValue': consumableTypeValue,
    'weaponTypeValue': weaponTypeValue,
    'shieldTypeValue': shieldTypeValue,
  };

  ItemCategoryDefinitionModel copyWith({
    int? category,
    int? consumableTypeValue,
    int? weaponTypeValue,
    int? shieldTypeValue,
  }) {
    return ItemCategoryDefinitionModel(
      category: category ?? this.category,
      consumableTypeValue: consumableTypeValue ?? this.consumableTypeValue,
      weaponTypeValue: weaponTypeValue ?? this.weaponTypeValue,
      shieldTypeValue: shieldTypeValue ?? this.shieldTypeValue,
    );
  }
}
