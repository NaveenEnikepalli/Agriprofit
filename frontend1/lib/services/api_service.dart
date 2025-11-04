import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price.dart';
import '../config/app_config.dart';

class ApiService {
  
  static Future<List<Price>> fetchAndSavePrices({
    required String state,
    required String commodity,
    String? district,
    String? market,
  }) async {
    final uri = Uri.parse(AppConfig.fetchPricesUrl).replace(
      queryParameters: {
        'state': state,
        'commodity': commodity,
        if (district != null && district.isNotEmpty) 'district': district,
        if (market != null && market.isNotEmpty) 'market': market,
      },
    );

    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> pricesList = responseData['prices'] ?? [];
        print('Fetched ${pricesList.length} prices from source API');
        
        if (pricesList.isEmpty) {
          print('Warning: No prices found in API response');
          print('Response data keys: ${responseData.keys.toList()}');
        }
        
        return pricesList.map((json) {
          try {
            return Price.fromJson(json);
          } catch (e) {
            print('Error parsing price item: $e');
            print('Price item: $json');
            rethrow;
          }
        }).toList();
      } catch (e) {
        print('Error parsing fetch response: $e');
        print('Response body: ${response.body}');
        rethrow;
      }
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch prices: ${response.statusCode}');
      } catch (e) {
        throw Exception('Failed to fetch prices: ${response.statusCode} - ${response.body}');
      }
    }
  }

  static Future<List<Price>> fetchPrices({
    String? state,
    String? commodity,
    String? district,
    String? market,
  }) async {
    final Map<String, String> queryParams = {};
    if (state != null && state.isNotEmpty) queryParams['state'] = state;
    if (commodity != null && commodity.isNotEmpty) queryParams['commodity'] = commodity;
    if (district != null && district.isNotEmpty) queryParams['district'] = district;
    if (market != null && market.isNotEmpty) queryParams['market'] = market;

    final uri = Uri.parse(AppConfig.pricesUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      try {
        // This endpoint returns a direct array
        final List<dynamic> jsonList = json.decode(response.body);
        print('Fetched ${jsonList.length} prices from database');
        
        if (jsonList.isEmpty) {
          print('Warning: No prices found in database');
        }
        
        return jsonList.map((json) {
          try {
            return Price.fromJson(json);
          } catch (e) {
            print('Error parsing price item: $e');
            print('Price item: $json');
            rethrow;
          }
        }).toList();
      } catch (e) {
        print('Error parsing DB response: $e');
        print('Response body: ${response.body}');
        rethrow;
      }
    } else {
      try {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch prices: ${response.statusCode}');
      } catch (e) {
        throw Exception('Failed to fetch prices: ${response.statusCode} - ${response.body}');
      }
    }
  }
}
