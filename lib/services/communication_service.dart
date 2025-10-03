import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class CommunicationService {
  Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch dialer');
    }
  }

  Future<void> sendSMS(String phoneNumber, String message) async {
    final uri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': message});
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch SMS');
    }
  }

  Future<String> simulateSMSSend(Position location) async {
    // Simulate sending an SMS and receiving a response
    await Future.delayed(const Duration(seconds: 2));
    // Mock response text (as if from a service)
    return 'Mechanics near you: 1.Sunil-0771234567-3km, 2.Kamal-0772345678-5km';
  }
}


