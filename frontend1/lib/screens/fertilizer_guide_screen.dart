import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fertilizer_provider.dart';
import '../data/fertilizer_data.dart';

class FertilizerGuideScreen extends StatefulWidget {
  const FertilizerGuideScreen({super.key});

  @override
  State<FertilizerGuideScreen> createState() => _FertilizerGuideScreenState();
}

class _FertilizerGuideScreenState extends State<FertilizerGuideScreen> {
  @override
  void initState() {
    super.initState();
    // Set default crop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final crops = fertilizerData.keys.toList();
      if (crops.isNotEmpty) {
        context.read<FertilizerProvider>().setSelectedCrop(crops.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FertilizerProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fertilizer Guide',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Crop Selection
            SizedBox(
              width: 300,
              child: DropdownButtonFormField<String>(
                initialValue: provider.selectedCrop.isEmpty ? null : provider.selectedCrop,
                decoration: const InputDecoration(
                  labelText: 'Crop',
                  border: OutlineInputBorder(),
                ),
                items: fertilizerData.keys.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setSelectedCrop(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            // Fertilizer Information
            if (provider.fertilizerInfo != null) ...[
              const Text(
                'Basal Dose (kg/acre)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Nitrogen', provider.fertilizerInfo!.basal.nitrogen),
                      _buildInfoRow('Phosphorus', provider.fertilizerInfo!.basal.phosphorus),
                      _buildInfoRow('Potash', provider.fertilizerInfo!.basal.potash),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Top Dressing (Detailed)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: provider.fertilizerInfo!.topdress.asMap().entries.map((entry) {
                      final index = entry.key;
                      final topDress = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${index + 1}. '),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topDress.daysAfterTransplant != null
                                        ? 'After transplant: ${topDress.daysAfterTransplant} days'
                                        : 'After sowing: ${topDress.daysAfterSowing} days',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text('Nitrogen: ${topDress.nitrogen} kg/acre'),
                                  if (topDress.note != null)
                                    Text(
                                      '— ${topDress.note}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ] else ...[
              const Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Select a crop', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value'),
        ],
      ),
    );
  }
}
