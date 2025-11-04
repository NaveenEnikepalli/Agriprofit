import 'package:flutter/material.dart';
import '../models/price.dart';
import '../services/api_service.dart';

class MandiPricesProvider extends ChangeNotifier {
  List<Price> _prices = [];
  bool _isLoading = false;
  String? _error;
  String _selectedState = 'Andhra Pradesh';
  String _selectedDistrict = '';
  String _selectedMarket = '';
  String _selectedCommodity = 'Tomato';

  List<Price> get prices => _prices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedState => _selectedState;
  String get selectedDistrict => _selectedDistrict;
  String get selectedMarket => _selectedMarket;
  String get selectedCommodity => _selectedCommodity;

  void setSelectedState(String state) {
    _selectedState = state;
    _selectedDistrict = '';
    _selectedMarket = '';
    notifyListeners();
  }

  void setSelectedDistrict(String district) {
    _selectedDistrict = district;
    _selectedMarket = '';
    notifyListeners();
  }

  void setSelectedMarket(String market) {
    _selectedMarket = market;
    notifyListeners();
  }

  void setSelectedCommodity(String commodity) {
    _selectedCommodity = commodity;
    notifyListeners();
  }

  Future<void> fetchFromSource() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch from source and get the prices directly
      _prices = await ApiService.fetchAndSavePrices(
        state: _selectedState,
        commodity: _selectedCommodity,
        district: _selectedDistrict.isNotEmpty ? _selectedDistrict : null,
        market: _selectedMarket.isNotEmpty ? _selectedMarket : null,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFromDb() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prices = await ApiService.fetchPrices(
        state: _selectedState,
        commodity: _selectedCommodity,
        district: _selectedDistrict.isNotEmpty ? _selectedDistrict : null,
        market: _selectedMarket.isNotEmpty ? _selectedMarket : null,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
