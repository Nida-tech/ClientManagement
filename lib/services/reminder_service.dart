import 'package:url_launcher/url_launcher.dart';

class ReminderService {
  static Future<void> sendWhatsApp(String phone, String message) async {
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeFull(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open WhatsApp for $phone';
    }
  }
}
