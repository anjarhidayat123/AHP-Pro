import 'package:flutter/material.dart';
import '../models/ahp_data.dart';
import 'comparison_screen.dart';

class CriteriaScreen extends StatefulWidget {
  final String baseUrl;

  const CriteriaScreen({super.key, required this.baseUrl});

  @override
  State<CriteriaScreen> createState() => _CriteriaScreenState();
}

class _CriteriaScreenState extends State<CriteriaScreen> {
  // Hardcoded default data based on TOR case studies
  // Can be made dynamic later
  final List<AhpCriterion> _criteria = [
    AhpCriterion(id: 'c1', name: 'Oil Extraction Rate (OER)'),
    AhpCriterion(id: 'c2', name: 'Free Fatty Acid (FFA)'),
    AhpCriterion(id: 'c3', name: 'Safety Risk (Tekanan Tinggi)'),
    AhpCriterion(id: 'c4', name: 'Biaya Perbaikan'), // Added to meet min 4 requirement
  ];

  final List<AhpAlternative> _alternatives = [
    AhpAlternative(id: 'a1', name: 'Sterilizer Station'),
    AhpAlternative(id: 'a2', name: 'Screw Press'),
    AhpAlternative(id: 'a3', name: 'Thresher Drum'),
    AhpAlternative(id: 'a4', name: 'Clarification Tank'),
    AhpAlternative(id: 'a5', name: 'Boiler'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kriteria Penilaian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._criteria.map((c) => Card(
              child: ListTile(
                leading: const Icon(Icons.rule),
                title: Text(c.name),
              ),
            )),
            
            const SizedBox(height: 24),
            const Text(
              'Alternatif Mesin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._alternatives.map((a) => Card(
              child: ListTile(
                leading: const Icon(Icons.precision_manufacturing),
                title: Text(a.name),
              ),
            )),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComparisonScreen(
                        baseUrl: widget.baseUrl,
                        criteria: _criteria,
                        alternatives: _alternatives,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Mulai Penilaian (AHP)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
