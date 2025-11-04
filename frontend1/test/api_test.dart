import 'package:flutter_test/flutter_test.dart';
import 'package:smart_farming_app/models/price.dart';

void main() {
  group('Price Model Tests', () {
    test('should parse price from JSON correctly', () {
      // Sample JSON response from backend
      final jsonData = {
        'state': 'Andhra Pradesh',
        'district': 'Guntur',
        'market': 'Guntur',
        'commodity': 'Tomato',
        'date': '2024-01-15',
        'min_price': 25.5,
        'max_price': 30.0,
        'modal_price': 27.5,
      };

      final price = Price.fromJson(jsonData);

      expect(price.state, 'Andhra Pradesh');
      expect(price.district, 'Guntur');
      expect(price.market, 'Guntur');
      expect(price.commodity, 'Tomato');
      expect(price.date, '2024-01-15');
      expect(price.minPrice, 25.5);
      expect(price.maxPrice, 30.0);
      expect(price.modalPrice, 27.5);
    });

    test('should handle null prices correctly', () {
      final jsonData = {
        'state': 'Andhra Pradesh',
        'district': 'Guntur',
        'market': 'Guntur',
        'commodity': 'Tomato',
        'date': '2024-01-15',
        'min_price': null,
        'max_price': null,
        'modal_price': null,
      };

      final price = Price.fromJson(jsonData);

      expect(price.state, 'Andhra Pradesh');
      expect(price.minPrice, null);
      expect(price.maxPrice, null);
      expect(price.modalPrice, null);
    });

    test('should handle missing price fields', () {
      final jsonData = {
        'state': 'Andhra Pradesh',
        'district': 'Guntur',
        'market': 'Guntur',
        'commodity': 'Tomato',
        'date': '2024-01-15',
        // Missing price fields
      };

      final price = Price.fromJson(jsonData);

      expect(price.state, 'Andhra Pradesh');
      expect(price.minPrice, null);
      expect(price.maxPrice, null);
      expect(price.modalPrice, null);
    });
  });
}

