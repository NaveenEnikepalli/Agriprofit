import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mandi_prices_provider.dart';

class PriceTrendsScreen extends StatefulWidget {
  const PriceTrendsScreen({super.key});

  @override
  State<PriceTrendsScreen> createState() => _PriceTrendsScreenState();
}

class _PriceTrendsScreenState extends State<PriceTrendsScreen> {
  final TextEditingController _stateController = TextEditingController(text: 'Andhra Pradesh');
  final TextEditingController _commodityController = TextEditingController(text: 'Tomato');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _stateController.dispose();
    _commodityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<MandiPricesProvider>();
    provider.setSelectedState(_stateController.text);
    provider.setSelectedCommodity(_commodityController.text);
    await provider.refreshFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MandiPricesProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Trend Analysis',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _commodityController,
                    decoration: const InputDecoration(
                      labelText: 'Commodity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 16),
            // Chart Placeholder
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Price Trend Chart',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: provider.prices.isEmpty
                            ? const Center(
                                child: Text('No data available for trend analysis'),
                              )
                            : _buildSimpleChart(provider.prices),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimpleChart(List prices) {
    if (prices.isEmpty) return const SizedBox();

    // Get price values for chart
    final values = prices
        .map((p) => p.modalPrice ?? p.maxPrice ?? p.minPrice)
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) return const Center(child: Text('No price data available'));

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    return CustomPaint(
      painter: PriceChartPainter(values, min, max),
      size: const Size(double.infinity, 200),
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final List<double> values;
  final double min;
  final double max;

  PriceChartPainter(this.values, this.min, this.max);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final xStep = size.width / (values.length - 1);
    final yRange = max - min;

    for (int i = 0; i < values.length; i++) {
      final x = i * xStep;
      final y = size.height - ((values[i] - min) / yRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = i * xStep;
      final y = size.height - ((values[i] - min) / yRange) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
