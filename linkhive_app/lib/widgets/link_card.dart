// lib/widgets/link_card.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/link.dart';

class LinkCard extends StatelessWidget {
  final Link link;

  const LinkCard({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getIconForType(link.type)),
        title: Text(
          link.title ?? link.url,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          link.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: link.pinnedFlag
            ? const Icon(Icons.push_pin, color: Colors.orange)
            : null,
        onTap: () => _launchUrl(link.url),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'job':
        return Icons.work;
      case 'reel':
        return Icons.video_camera_front;
      case 'video':
        return Icons.play_circle;
      case 'article':
        return Icons.article;
      default:
        return Icons.link;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}