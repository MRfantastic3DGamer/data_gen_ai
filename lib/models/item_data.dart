import 'package:data_gen_ai/models/interaction_slot.dart';

class ItemDataModel {
  const ItemDataModel({
    this.itemId = '',
    this.description = '',
    this.category = 1,
    this.consumableTypeValue = 0,
    this.weaponTypeValue = 0,
    this.shieldTypeValue = 0,
    this.interactionSlots = const <ItemInteractionSlotDefinition>[],
  });

  final String itemId;
  final String description;
  final int category;
  final int consumableTypeValue;
  final int weaponTypeValue;
  final int shieldTypeValue;
  final List<ItemInteractionSlotDefinition> interactionSlots;

  factory ItemDataModel.fromJson(Map<String, dynamic> json) {
    return ItemDataModel(
      itemId: (json['ItemId'] ?? '') as String,
      description: (json['Description'] ?? '') as String,
      category: (json['Category'] ?? 1) as int,
      consumableTypeValue: (json['ConsumableTypeValue'] ?? 0) as int,
      weaponTypeValue: (json['WeaponTypeValue'] ?? 0) as int,
      shieldTypeValue: (json['ShieldTypeValue'] ?? 0) as int,
      interactionSlots:
          (json['InteractionSlots'] as List<dynamic>? ?? const <dynamic>[])
              .map(
                (dynamic e) => ItemInteractionSlotDefinition.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ItemId': itemId,
    'Description': description,
    'Category': category,
    'ConsumableTypeValue': consumableTypeValue,
    'WeaponTypeValue': weaponTypeValue,
    'ShieldTypeValue': shieldTypeValue,
    'InteractionSlots': interactionSlots.map((e) => e.toJson()).toList(),
  };

  ItemDataModel copyWith({
    String? itemId,
    String? description,
    int? category,
    int? consumableTypeValue,
    int? weaponTypeValue,
    int? shieldTypeValue,
    List<ItemInteractionSlotDefinition>? interactionSlots,
  }) {
    return ItemDataModel(
      itemId: itemId ?? this.itemId,
      description: description ?? this.description,
      category: category ?? this.category,
      consumableTypeValue: consumableTypeValue ?? this.consumableTypeValue,
      weaponTypeValue: weaponTypeValue ?? this.weaponTypeValue,
      shieldTypeValue: shieldTypeValue ?? this.shieldTypeValue,
      interactionSlots: interactionSlots ?? this.interactionSlots,
    );
  }
}
