import 'package:flutter/material.dart';
import '../data/location_data.dart';

class CascadedLocationSelect extends StatelessWidget {
  final String stateName;
  final String district;
  final String market;
  final Function(String) onStateChanged;
  final Function(String) onDistrictChanged;
  final Function(String) onMarketChanged;

  const CascadedLocationSelect({
    super.key,
    required this.stateName,
    required this.district,
    required this.market,
    required this.onStateChanged,
    required this.onDistrictChanged,
    required this.onMarketChanged,
  });

  @override
  Widget build(BuildContext context) {
    final states = locationData.keys.toList();
    final districts = stateName.isNotEmpty 
        ? (locationData[stateName]?.keys.toList() ?? [])
        : <String>[];
    final markets = (stateName.isNotEmpty && district.isNotEmpty)
        ? (locationData[stateName]?[district] ?? [])
        : <String>[];

    return Row(
      children: [
        // State Selection
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: stateName.isEmpty ? null : stateName,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Select')),
              ...states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state),
                );
              }),
            ],
            onChanged: (value) {
              if (value != null) {
                onStateChanged(value);
                onDistrictChanged('');
                onMarketChanged('');
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        // District Selection
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: district.isEmpty ? null : district,
            decoration: const InputDecoration(
              labelText: 'District',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Select')),
              ...districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(district),
                );
              }),
            ],
            onChanged: stateName.isEmpty 
                ? null 
                : (value) {
                    if (value != null) {
                      onDistrictChanged(value);
                      onMarketChanged('');
                    }
                  },
          ),
        ),
        const SizedBox(width: 16),
        // Market Selection
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: market.isEmpty ? null : market,
            decoration: const InputDecoration(
              labelText: 'Market',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: '', child: Text('Select')),
              ...markets.map((market) {
                return DropdownMenuItem(
                  value: market,
                  child: Text(market),
                );
              }),
            ],
            onChanged: district.isEmpty 
                ? null 
                : (value) {
                    if (value != null) {
                      onMarketChanged(value);
                    }
                  },
          ),
        ),
      ],
    );
  }
}
