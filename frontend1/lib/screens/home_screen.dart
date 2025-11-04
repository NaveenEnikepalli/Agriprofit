import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/app_config.dart';
import 'mandi_prices_screen.dart';
import 'fertilizer_guide_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Farmer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find mandi prices, fertilizer guidance',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return Column(
                    children: [
                      // Tab Navigation
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton(
                              context,
                              'Mandi Prices',
                              0,
                              appProvider.selectedTabIndex,
                              () => appProvider.setSelectedTab(0),
                            ),
                            _buildTabButton(
                              context,
                              'Fertilizer Guide',
                              1,
                              appProvider.selectedTabIndex,
                              () => appProvider.setSelectedTab(1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tab Content
                      Expanded(
                        child: IndexedStack(
                          index: appProvider.selectedTabIndex,
                          children: const [
                            MandiPricesScreen(),
                            FertilizerGuideScreen(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Backend base: ${AppConfig.baseUrl}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String text,
    int index,
    int selectedIndex,
    VoidCallback onTap,
  ) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
