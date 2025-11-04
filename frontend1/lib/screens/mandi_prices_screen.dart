import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mandi_prices_provider.dart';
import '../widgets/cascaded_location_select.dart';

class MandiPricesScreen extends StatefulWidget {
  const MandiPricesScreen({super.key});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  final List<String> commodities = [
    'Tomato',
    'Onion',
    'Potato',
    'Paddy(Dhan)(Common)',
    'Wheat',
    'Maize',
    'Bajra(Pearl Millet/Cumbu)',
    'Tur',
    'Moong(Green Gram)',
    'Urad(Black Gram)',
    'Groundnut',
    'Soyabean',
    'Mustard',
    'Sunflower',
    'Cotton',
    'Sugarcane',
    'Chillies(Dry)',
    'Turmeric',
    'Banana',
    'Mango',
    'Apple',
    'Grapes',
    'Pomegranate'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MandiPricesProvider>().refreshFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MandiPricesProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mandi Price Finder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Commodity Selection
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<String>(
                initialValue: provider.selectedCommodity,
                decoration: const InputDecoration(
                  labelText: 'Commodity',
                  border: OutlineInputBorder(),
                ),
                items: commodities.map((commodity) {
                  return DropdownMenuItem(
                    value: commodity,
                    child: Text(commodity),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setSelectedCommodity(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Location Selection
            CascadedLocationSelect(
              stateName: provider.selectedState,
              district: provider.selectedDistrict,
              market: provider.selectedMarket,
              onStateChanged: (state) => provider.setSelectedState(state),
              onDistrictChanged: (district) => provider.setSelectedDistrict(district),
              onMarketChanged: (market) => provider.setSelectedMarket(market),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: provider.isLoading ? null : provider.fetchFromSource,
                  child: const Text('Fetch from Source & Save'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: provider.isLoading ? null : provider.refreshFromDb,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Refresh from DB'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Loading/Error Messages
            if (provider.isLoading)
              const Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Loading…', style: TextStyle(color: Colors.white)),
                ),
              ),
            if (provider.error != null)
              Card(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Results Table
            Expanded(
              child: Card(
                child: provider.prices.isEmpty && !provider.isLoading
                    ? const Center(
                        child: Text('No results'),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('State')),
                            DataColumn(label: Text('District')),
                            DataColumn(label: Text('Market')),
                            DataColumn(label: Text('Commodity')),
                            DataColumn(label: Text('Min ₹/kg')),
                            DataColumn(label: Text('Max ₹/kg')),
                            DataColumn(label: Text('Modal ₹/kg')),
                          ],
                          rows: provider.prices.map((price) {
                            return DataRow(
                              cells: [
                                DataCell(Text(price.date)),
                                DataCell(Text(price.state)),
                                DataCell(Text(price.district)),
                                DataCell(Text(price.market)),
                                DataCell(Text(price.commodity)),
                                DataCell(Text(price.minPrice?.toString() ?? '-')),
                                DataCell(Text(price.maxPrice?.toString() ?? '-')),
                                DataCell(Text(price.modalPrice?.toString() ?? '-')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
