import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ahp_data.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<ComparisonResult> calculateAhp(
    List<List<double>> criteriaMatrix,
    Map<String, List<List<double>>> alternativesMatrices,
  ) async {
    final url = Uri.parse('$baseUrl/calculate');
    final body = json.encode({
      'criteria_matrix': criteriaMatrix,
      'alternatives_matrices': alternativesMatrices,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return ComparisonResult.fromJson(data);
        } else if (data['status'] == 'inconsistent') {
           throw Exception(data['message']); // Handle inconsistency
        } else {
          throw Exception(data['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to calculate AHP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}
