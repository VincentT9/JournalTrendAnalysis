import 'package:flutter/material.dart';

import '../models/research_analysis.dart';
import '../services/openalex_service.dart';

enum ResearchStatus { idle, loading, loaded, error }

class ResearchController extends ChangeNotifier {
  ResearchController(this._service);

  OpenAlexService _service;

  ResearchStatus status = ResearchStatus.idle;
  ResearchAnalysis? analysis;
  String currentTopic = '';
  String? errorMessage;
  ThemeMode _themeMode = ThemeMode.system;

  bool get hasAnalysis => analysis != null;
  bool get isLoading => status == ResearchStatus.loading;
  ThemeMode get themeMode => _themeMode;
  OpenAlexService get service => _service;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setApiKey(String newKey) {
    _service = OpenAlexService(apiKey: newKey.trim().isEmpty ? null : newKey.trim());
    notifyListeners();
  }

  Future<void> search(String topic) async {
    final normalizedTopic = topic.trim();
    if (normalizedTopic.isEmpty) {
      status = ResearchStatus.error;
      errorMessage = 'Please enter a research topic.';
      notifyListeners();
      return;
    }

    currentTopic = normalizedTopic;
    status = ResearchStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      analysis = await _service.analyzeTopic(normalizedTopic);
      status = ResearchStatus.loaded;
    } on OpenAlexException catch (error) {
      status = ResearchStatus.error;
      errorMessage = error.message;
    } on Object catch (error) {
      status = ResearchStatus.error;
      errorMessage = 'Unexpected error: $error';
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    if (currentTopic.isEmpty) return;
    await search(currentTopic);
  }
}
