class AhpCriterion {
  final String id;
  final String name;

  AhpCriterion({required this.id, required this.name});
}

class AhpAlternative {
  final String id;
  final String name;

  AhpAlternative({required this.id, required this.name});
}

class ComparisonResult {
  final List<double> criteriaWeights;
  final double criteriaCR;
  final List<double> globalRanking;

  ComparisonResult({
    required this.criteriaWeights,
    required this.criteriaCR,
    required this.globalRanking,
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) {
    return ComparisonResult(
      criteriaWeights: List<double>.from(json['criteria_weights'] ?? []),
      criteriaCR: (json['criteria_cr'] ?? 0.0).toDouble(),
      globalRanking: List<double>.from(json['global_ranking'] ?? []),
    );
  }
}
