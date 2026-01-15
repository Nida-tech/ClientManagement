import 'package:url_launcher/url_launcher.dart';
import '../models/client_model.dart';

class WhatsAppService {
  static Future<void> sendTeamMessage({
    required String teamPhone,
    required String teamName,
    required List<Client> clients,
  }) async {
    String message = 'Hello $teamName 👋\n\nToday Clients:\n\n';

    for (int i = 0; i < clients.length; i++) {
      final c = clients[i];
      message += '''
${i + 1}. ${c.name}
📍 Location: ${c.pinLocation}

''';
    }

    final uri = Uri.parse(
      'https://wa.me/${teamPhone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('WhatsApp could not be opened');
    }
  }
}
