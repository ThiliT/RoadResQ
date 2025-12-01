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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['mechanics'] != null) {
          final mechanicsList = (data['mechanics'] as List)
              .map((m) {
                // Convert database row to Mechanic model
                return Mechanic(
                  id: m['id'].toString(),
                  name: m['name'] as String,
                  phone: m['phone'] as String,
                  latitude: (m['latitude'] as num).toDouble(),
                  longitude: (m['longitude'] as num).toDouble(),
                  area: m['area'] as String,
                  available: (m['available'] as int) == 1 || (m['available'] as bool) == true,
                  rating: (m['rating'] as num).toDouble(),
                );
              })
              .toList();
          return mechanicsList;
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

