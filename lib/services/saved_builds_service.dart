import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/component.dart';

/// Model for a saved PC build
class SavedBuild {
  final String id;
  final String name;
  final Map<ComponentType, Component> components;
  final double totalPrice;
  final DateTime createdAt;

  const SavedBuild({
    required this.id,
    required this.name,
    required this.components,
    required this.totalPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'components': components.map(
        (key, value) => MapEntry(key.index.toString(), _componentToJson(value)),
      ),
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedBuild.fromJson(Map<String, dynamic> json) {
    final componentsMap = <ComponentType, Component>{};
    final componentsJson = json['components'] as Map<String, dynamic>? ?? {};

    componentsJson.forEach((key, value) {
      final typeIndex = int.tryParse(key);
      if (typeIndex != null && typeIndex < ComponentType.values.length) {
        componentsMap[ComponentType.values[typeIndex]] = _componentFromJson(
          value,
        );
      }
    });

    return SavedBuild(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Build',
      components: componentsMap,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> _componentToJson(Component c) {
    return {
      'id': c.id,
      'name': c.name,
      'brand': c.brand,
      'type': c.type.index,
      'price': c.price,
      'imageUrl': c.imageUrl,
      'specs': c.specs,
    };
  }

  static Component _componentFromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      type: ComponentType.values[json['type'] ?? 0],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      specs: Map<String, dynamic>.from(json['specs'] ?? {}),
    );
  }
}

/// Service for persisting saved builds
class SavedBuildsService {
  static const String _storageKey = 'saved_builds';

  Future<List<SavedBuild>> loadBuilds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((j) => SavedBuild.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveBuilds(List<SavedBuild> builds) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = builds.map((b) => b.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<void> addBuild(SavedBuild build) async {
    final builds = await loadBuilds();
    builds.insert(0, build); // Add at beginning (most recent first)
    await saveBuilds(builds);
  }

  Future<void> deleteBuild(String id) async {
    final builds = await loadBuilds();
    builds.removeWhere((b) => b.id == id);
    await saveBuilds(builds);
  }

  /// Generate unique ID for a new build
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
