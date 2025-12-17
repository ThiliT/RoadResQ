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
}

