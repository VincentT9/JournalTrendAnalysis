import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/publication.dart';
import '../utils/formatters.dart';

class PublicationDetailScreen extends StatelessWidget {
  const PublicationDetailScreen({super.key, required this.publication});

  final Publication publication;

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final abstractText = publication.abstractText;
    final doiUrl = publication.doiUrl;
    final openAlexUrl = publication.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Publication Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            publication.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailPill(
                icon: Icons.event_outlined,
                label: publication.yearLabel,
              ),
              _DetailPill(
                icon: Icons.format_quote_outlined,
                label: '${formatCount(publication.citationCount)} citations',
              ),
              _DetailPill(
                icon: Icons.menu_book_outlined,
                label: publication.journalName,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Authors',
            child: publication.authors.isEmpty
                ? Text(
                    'Unknown authors',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final author in publication.authors)
                        Chip(
                          avatar: const Icon(Icons.person_outline, size: 18),
                          label: Text(author),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Abstract',
            child: Text(
              abstractText == null || abstractText.isEmpty
                  ? 'Abstract not available from OpenAlex.'
                  : abstractText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: abstractText == null || abstractText.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'External Links',
            child: Column(
              children: [
                if (doiUrl.isNotEmpty)
                  _LinkTile(
                    icon: Icons.link,
                    title: 'DOI',
                    subtitle: publication.doi ?? doiUrl,
                    onTap: () => _openUrl(context, doiUrl),
                  ),
                if (openAlexUrl.startsWith('http'))
                  _LinkTile(
                    icon: Icons.open_in_new,
                    title: 'OpenAlex',
                    subtitle: openAlexUrl,
                    onTap: () => _openUrl(context, openAlexUrl),
                  ),
                if (publication.landingPageUrl != null)
                  _LinkTile(
                    icon: Icons.article_outlined,
                    title: 'Publisher page',
                    subtitle: publication.landingPageUrl!,
                    onTap: () => _openUrl(context, publication.landingPageUrl!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: onTap,
    );
  }
}
