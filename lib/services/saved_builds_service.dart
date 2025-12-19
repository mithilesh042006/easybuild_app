import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/component.dart';

/// Model for a saved PC build
class SavedBuild {
  final String id;
  final String name;
  final Map<ComponentType, Component> components;
  final double totalPrice;
  final DateTime createdAt;
  final String userId;

  const SavedBuild({
    required this.id,
    required this.name,
    required this.components,
    required this.totalPrice,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'components': components.map(
        (key, value) => MapEntry(key.index.toString(), _componentToJson(value)),
      ),
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory SavedBuild.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final componentsMap = <ComponentType, Component>{};
    final componentsJson = data['components'] as Map<String, dynamic>? ?? {};

    componentsJson.forEach((key, value) {
      final typeIndex = int.tryParse(key);
      if (typeIndex != null && typeIndex < ComponentType.values.length) {
        componentsMap[ComponentType.values[typeIndex]] = _componentFromJson(
          value,
        );
      }
    });

    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    final createdAt = createdAtTimestamp?.toDate() ?? DateTime.now();

    return SavedBuild(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Build',
      components: componentsMap,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      createdAt: createdAt,
      userId: data['userId'] ?? '',
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

/// Service for persisting saved builds to Firestore
class SavedBuildsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's builds collection reference
  CollectionReference? _getUserBuildsCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('builds');
  }

  /// Load all builds for the current user
  Stream<List<SavedBuild>> loadBuildsStream() {
    final collection = _getUserBuildsCollection();
    if (collection == null) {
      return Stream.value([]);
    }

    return collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => SavedBuild.fromFirestore(doc)).toList();
    });
  }

  /// Add a new build to Firestore
  Future<void> addBuild(SavedBuild build) async {
    final collection = _getUserBuildsCollection();
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(build.id).set(build.toJson());
  }

  /// Delete a build from Firestore
  Future<void> deleteBuild(String id) async {
    final collection = _getUserBuildsCollection();
    if (collection == null) {
      throw Exception('User not authenticated');
    }

    await collection.doc(id).delete();
  }

  /// Generate unique ID for a new build
  String generateId() {
    final collection = _getUserBuildsCollection();
    if (collection == null) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
    return collection.doc().id;
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
}

/// Provider for SavedBuildsService
final savedBuildsServiceProvider = Provider((ref) => SavedBuildsService());

/// Stream provider for saved builds (auto-updates)
final savedBuildsStreamProvider = StreamProvider<List<SavedBuild>>((ref) {
  final service = ref.watch(savedBuildsServiceProvider);
  return service.loadBuildsStream();
});
