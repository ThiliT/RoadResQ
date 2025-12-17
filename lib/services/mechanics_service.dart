import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/mechanic.dart';

class MechanicsService {
  /// Fetches mechanics list from backend MySQL database
  Future<List<Mechanic>> fetchMechanics() async {
    try {
      final url = Uri.parse('${AppStrings.backendUrl}/mechanics');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['mechanics'] != null) {
          return (data['mechanics'] as List)
              .map((m) => Mechanic.fromJson(m))
              .toList();
        }

        return [];
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch mechanics: $e');
    }
  }
}
