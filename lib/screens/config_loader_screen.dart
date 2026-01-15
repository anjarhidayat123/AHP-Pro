import 'package:flutter/material.dart';
import '../services/gist_service.dart';
import 'criteria_screen.dart';

class ConfigLoaderScreen extends StatefulWidget {
  const ConfigLoaderScreen({super.key});

  @override
  State<ConfigLoaderScreen> createState() => _ConfigLoaderScreenState();
}

class _ConfigLoaderScreenState extends State<ConfigLoaderScreen> {
  String _statusMessage = 'Initializing...';
  bool _isLoading = true;
  String? _baseUrl;
  TextEditingController _manualUrlController = TextEditingController();
  bool _showManualInput = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _statusMessage = 'Fetching configuration from Gist...';
      _isLoading = true;
      _showManualInput = false;
    });

    try {
      final gistService = GistService();
      _baseUrl = await gistService.getBaseUrl();
      // Validate simple format
      if (!_baseUrl!.startsWith('http')) throw Exception('Invalid URL');
      _navigateToNext();
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Gagal memuat Config Gist.\nIngin input URL manual?';
          _isLoading = false;
          _showManualInput = true;
        });
      }
    }
  }

  void _navigateToNext() async {
     setState(() {
        _statusMessage = 'Connected! API at: $_baseUrl';
      });

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CriteriaScreen(baseUrl: _baseUrl!)),
        );
      }
  }

  void _submitManualUrl() {
    final url = _manualUrlController.text.trim();
    if (url.isNotEmpty) {
      _baseUrl = url;
      _navigateToNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading) 
                 const Icon(Icons.settings_remote, size: 48, color: Colors.blueGrey),
              
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              
              if (_showManualInput) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _manualUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Masukkan URL Server (Ngrok)',
                    hintText: 'Contoh: https://abcd.ngrok-free.app',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitManualUrl,
                  child: const Text('Gunakan URL Manual'),
                ),
                TextButton(
                  onPressed: _loadConfig,
                  child: const Text('Coba Load Gist Lagi'),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
