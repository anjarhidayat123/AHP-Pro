import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/ahp_data.dart';

class ResultScreen extends StatelessWidget {
  final ComparisonResult result;
  final List<AhpCriterion> criteria;
  final List<AhpAlternative> alternatives;

  const ResultScreen({
    super.key,
    required this.result,
    required this.criteria,
    required this.alternatives,
  });

  @override
  Widget build(BuildContext context) {
    // Combine data for display
    List<Map<String, dynamic>> rankingData = [];
    for (int i = 0; i < alternatives.length; i++) {
        rankingData.add({
            'name': alternatives[i].name,
            'score': result.globalRanking.length > i ? result.globalRanking[i] : 0.0,
        });
    }
    // Sort by score descending
    rankingData.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Prioritas Maintenance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: result.criteriaCR <= 0.1 ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("Konsistensi Kriteria (CR)", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      result.criteriaCR.toStringAsFixed(4),
                      style: TextStyle(
                        fontSize: 24, 
                        color: result.criteriaCR <= 0.1 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(result.criteriaCR <= 0.1 ? "Konsisten" : "Tidak Konsisten (> 0.1)"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Ranking Prioritas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0, 
                  barGroups: rankingData.asMap().entries.map((e) {
                    int index = e.key;
                    var data = e.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (data['score'] as double),
                          color: Colors.blueAccent,
                          width: 20, 
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < rankingData.length) {
                             // Show abbreviated name or index if too long
                             return SideTitleWidget(
                               axisSide: meta.axisSide,
                               child: Text(
                                   rankingData[index]['name'].toString().split(' ')[0], 
                                   style: const TextStyle(fontSize: 10)
                               ),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rankingData.length,
                itemBuilder: (context, index) {
                    var item = rankingData[index];
                    return ListTile(
                        leading: CircleAvatar(child: Text("${index + 1}")),
                        title: Text(item['name']),
                        subtitle: Text("Score: ${(item['score'] as double).toStringAsFixed(4)}"),
                    );
                }
            )
          ],
        ),
      ),
    );
  }
}
