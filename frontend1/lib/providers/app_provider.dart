import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  
  int get selectedTabIndex => _selectedTabIndex;
  
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }
}
