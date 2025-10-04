import 'package:flutter/material.dart';
import '../models/link.dart';
import 'link_card.dart';

class PinnedLinksSection extends StatelessWidget {
  final List<Link> links;

  const PinnedLinksSection({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.push_pin, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pinned Links',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...links.map((link) => LinkCard(link: link)),
      ],
    );
  }
}