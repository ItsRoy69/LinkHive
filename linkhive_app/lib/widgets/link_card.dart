import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/link.dart';
import '../providers/link_provider.dart';
import '../screens/home/add_link_screen.dart';

class LinkCard extends StatelessWidget {
  final Link link;

  const LinkCard({super.key, required this.link});

  IconData _getIconForType(LinkType type) {
    switch (type) {
      case LinkType.job:
        return Icons.work;
      case LinkType.article:
        return Icons.article;
      case LinkType.reel:
        return Icons.video_library;
      case LinkType.video:
        return Icons.play_circle;
      default:
        return Icons.link;
    }
  }

  Color _getColorForType(LinkType type) {
    switch (type) {
      case LinkType.job:
        return Colors.blue;
      case LinkType.article:
        return Colors.green;
      case LinkType.reel:
        return Colors.purple;
      case LinkType.video:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(LinkStatus status) {
    switch (status) {
      case LinkStatus.applied:
        return 'Applied';
      case LinkStatus.notApplied:
        return 'Not Applied';
      case LinkStatus.read:
        return 'Read';
      case LinkStatus.unread:
        return 'Unread';
      case LinkStatus.none:
        return '';
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final linkProvider = Provider.of<LinkProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Open Link'),
              onTap: () {
                Navigator.pop(context);
                _openUrl(link.url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: link.url));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: Icon(link.pinnedFlag ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(link.pinnedFlag ? 'Unpin' : 'Pin to top'),
              onTap: () {
                linkProvider.togglePin(link.id!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLinkScreen(linkToEdit: link),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, linkProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, LinkProvider linkProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: const Text('Are you sure you want to delete this link?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              linkProvider.deleteLink(link.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openUrl(link.url),
        onLongPress: () => _showOptionsBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getColorForType(link.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(link.type),
                      color: _getColorForType(link.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link.title ?? _shortenUrl(link.url),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          link.type.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getColorForType(link.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (link.pinnedFlag)
                    const Icon(Icons.push_pin, size: 20, color: Colors.amber),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptionsBottomSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                link.url,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (link.status != LinkStatus.none) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(link.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusLabel(link.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(link.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if (link.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Added ${_formatDate(link.createdAt!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _shortenUrl(String url) {
    if (url.length <= 50) return url;
    return '${url.substring(0, 50)}...';
  }

  Color _getStatusColor(LinkStatus status) {
    switch (status) {
      case LinkStatus.applied:
        return Colors.green;
      case LinkStatus.notApplied:
        return Colors.orange;
      case LinkStatus.read:
        return Colors.blue;
      case LinkStatus.unread:
        return Colors.grey;
      case LinkStatus.none:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}