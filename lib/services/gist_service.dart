import 'dart:convert';
import 'package:http/http.dart' as http;

class GistService {
  // IMPORTANT: Replace this with the ACTUAL RAW URL of your Gist after you create it.
  // This is a placeholder as per the TOR instructions to hardcode the Raw URL.
  // Example: https://gist.githubusercontent.com/username/gist_id/raw/config.json
  static const String _gistRawUrl = 'YOUR_GIST_RAW_URL_HERE'; 

  Future<String> getBaseUrl() async {
    if (_gistRawUrl == 'YOUR_GIST_RAW_URL_HERE') {
      // Return a default localhost for testing if not set, or throw error to prompt user
      // For now, let's return a dummy placeholder or error to force configuration
      throw Exception('Gist Raw URL not configured in lib/services/gist_service.dart');
    }

    try {
      final response = await http.get(Uri.parse(_gistRawUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['base_url'];
      } else {
        throw Exception('Failed to load config from Gist');
      }
    } catch (e) {
      throw Exception('Error fetching Gist: $e');
    }
  }
}
