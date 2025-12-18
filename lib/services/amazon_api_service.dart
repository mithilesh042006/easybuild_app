import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/component.dart';

class AmazonApiService {
  static const String _baseUrl = 'real-time-amazon-data.p.rapidapi.com';
  static const String _apiKey =
      '3d87f97ae9msh455fb48c7acdfcep1591bcjsnad1e4bb403f9';
  static const String _apiHost = 'real-time-amazon-data.p.rapidapi.com';

  Future<List<Component>> searchProducts({
    required String query,
    required ComponentType componentType,
    String country = 'US',
  }) async {
    final uri = Uri.https(_baseUrl, '/search', {
      'query': query,
      'country': country,
      'page': '1',
    });

    final response = await http.get(
      uri,
      headers: {'x-rapidapi-key': _apiKey, 'x-rapidapi-host': _apiHost},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['data']?['products'] as List? ?? [];

      return products.take(10).map((product) {
        final priceStr = product['product_price'] as String? ?? '\$0';
        final priceValue =
            double.tryParse(priceStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

        return Component(
          id: product['asin'] ?? '',
          name: product['product_title'] ?? 'Unknown Product',
          brand: _extractBrand(product['product_title'] ?? ''),
          type: componentType,
          price: priceValue,
          imageUrl: product['product_photo'],
          specs: {
            'Rating': product['product_star_rating'] ?? 'N/A',
            'Reviews': product['product_num_ratings']?.toString() ?? '0',
          },
        );
      }).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  String _extractBrand(String title) {
    final words = title.split(' ');
    return words.isNotEmpty ? words.first : 'Unknown';
  }

  /// Get default search query for a component type
  static String getDefaultQuery(ComponentType type) {
    switch (type) {
      case ComponentType.cpu:
        return 'Desktop CPU Processor';
      case ComponentType.gpu:
        return 'Graphics Card GPU';
      case ComponentType.ram:
        return 'Desktop RAM DDR5';
      case ComponentType.motherboard:
        return 'ATX Motherboard';
      case ComponentType.storage:
        return 'SSD NVMe';
      case ComponentType.psu:
        return 'PC Power Supply';
      case ComponentType.pcCase:
        return 'PC Case ATX';
      case ComponentType.cooling:
        return 'CPU Cooler';
    }
  }
}
