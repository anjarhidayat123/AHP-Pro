import 'package:flutter/material.dart';
import '../models/ahp_data.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class ComparisonScreen extends StatefulWidget {
  final String baseUrl;
  final List<AhpCriterion> criteria;
  final List<AhpAlternative> alternatives;

  const ComparisonScreen({
    super.key,
    required this.baseUrl,
    required this.criteria,
    required this.alternatives,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  
  // Data Storage
  late List<List<double>> _criteriaMatrix;
  late Map<String, List<List<double>>> _alternativesMatrices;
  
  // Flattened list of comparison tasks
  // Task Types: 'CRITERIA', 'ALTERNATIVE'
  final List<ComparisonTask> _tasks = [];

  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeMatrices();
    _generateTasks();
  }

  void _initializeMatrices() {
    int nC = widget.criteria.length;
    _criteriaMatrix = List.generate(nC, (_) => List.filled(nC, 1.0));

    _alternativesMatrices = {};
    for (var c in widget.criteria) {
      int nA = widget.alternatives.length;
      _alternativesMatrices[c.id] = List.generate(nA, (_) => List.filled(nA, 1.0));
    }
  }

  void _generateTasks() {
    // 1. Criteria Comparison Task
    _tasks.add(ComparisonTask(
      type: 'CRITERIA',
      title: 'Perbandingan Kriteria',
      items: widget.criteria,
      targetId: 'criteria', // Special ID
    ));

    // 2. Alternatives Comparison Tasks (One for each criteria)
    for (var c in widget.criteria) {
      _tasks.add(ComparisonTask(
        type: 'ALTERNATIVE',
        title: 'Perbandingan Alternatif\n(Berdasarkan: ${c.name})',
        items: widget.alternatives,
        targetId: c.id,
      ));
    }
  }

  void _onNext() async {
    if (_currentPage < _tasks.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finish -> Calculate
      _submitData();
    }
  }

  Future<void> _submitData() async {
    setState(() {
      _isCalculating = true;
    });

    try {
      final apiService = ApiService(widget.baseUrl);
      final result = await apiService.calculateAhp(
        _criteriaMatrix,
        _alternativesMatrices,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: result,
            criteria: widget.criteria,
            alternatives: widget.alternatives,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentPage + 1} of ${_tasks.length}'),
      ),
      body: _isCalculating
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Force navigation via buttons
              onPageChanged: (idx) {
                setState(() {
                  _currentPage = idx;
                });
              },
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return _buildForTask(_tasks[index], index);
              },
            ),
    );
  }

  Widget _buildForTask(ComparisonTask task, int index) {
    // Generate pairs for (N * (N-1)) / 2
    List<Widget> formItems = [];
    int n = task.items.length;
    
    // We only create sliders for i < j
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        var itemA = task.items[i];
        var itemB = task.items[j];
        
        // Helper to access matrix
        double currentValue;
        if (task.type == 'CRITERIA') {
          currentValue = _criteriaMatrix[i][j];
        } else {
          currentValue = _alternativesMatrices[task.targetId]![i][j];
        }

        formItems.add(PairwiseSlider(
          itemA: itemA.name,
          itemB: itemB.name,
          value: currentValue,
          onChanged: (val) {
            setState(() {
              // Update Matrix
              // Saaty Matrix Property: A[j][i] = 1 / A[i][j]
              if (task.type == 'CRITERIA') {
                _criteriaMatrix[i][j] = val;
                _criteriaMatrix[j][i] = 1 / val;
              } else {
                _alternativesMatrices[task.targetId]![i][j] = val;
                _alternativesMatrices[task.targetId]![j][i] = 1 / val;
              }
            });
          },
        ));
        formItems.add(const Divider());
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            task.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...formItems,
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _onNext,
            child: Text(index == _tasks.length - 1 ? 'Hitung Hasil' : 'Lanjut'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class ComparisonTask {
  final String type; // CRITERIA or ALTERNATIVE
  final String title;
  final List<dynamic> items; // AhpCriterion or AhpAlternative
  final String targetId; // 'criteria' or criterionId

  ComparisonTask({
    required this.type,
    required this.title,
    required this.items,
    required this.targetId,
  });
}

class PairwiseSlider extends StatelessWidget {
  final String itemA;
  final String itemB;
  final double value;
  final ValueChanged<double> onChanged;

  const PairwiseSlider({
    super.key,
    required this.itemA,
    required this.itemB,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Slider logic:
    // We store value as strictly positive (1/9 to 9).
    // UI needs a linear-like slider representation.
    // Let's map 1/9...1...9 to -8...0...8 for the slider.
    
    double compareValueToSlider(double v) {
      if (v >= 1) return v - 1;       // 1->0, 9->8
      return -(1/v - 1);              // 1/9 -> -8
    }

    double sliderToCompareValue(double s) {
      if (s >= 0) return s + 1;
      return 1 / (-s + 1);
    }
    
    double sliderVal = compareValueToSlider(value);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Expanded(child: Text(itemA, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
             const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("vs")),
             Expanded(child: Text(itemB, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        Slider(
          value: sliderVal,
          min: -8,
          max: 8,
          divisions: 16,
          label: _getLabel(sliderVal),
          onChanged: (v) {
            onChanged(sliderToCompareValue(v));
          },
        ),
        Text(
          _getDescription(sliderVal),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _getLabel(double s) {
    if (s == 0) return "1 (Sama)";
    if (s > 0) return "${s.toInt() + 1} (Kiri)";
    return "${(-s).toInt() + 1} (Kanan)";
  }
  
  String _getDescription(double s) {
    if (s == 0) return "Sama penting";
    bool left = s > 0;
    double mag = s.abs();
    
    String desc = "";
    if (mag <= 2) desc = "Sedikit lebih penting";
    else if (mag <= 4) desc = "Lebih penting";
    else if (mag <= 6) desc = "Sangat lebih penting";
    else desc = "Mutlak lebih penting";
    
    return "${left ? itemA : itemB} is $desc";
  }
}
