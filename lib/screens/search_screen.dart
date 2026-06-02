import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publication.dart';
import '../state/research_controller.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/publication_card.dart';
import 'publication_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _suggestedTopics = [
    'Artificial Intelligence',
    'Software Engineering',
    'Data Science',
    'Cybersecurity',
    'Internet of Things',
    'Blockchain',
  ];

  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submitSearch(String topic) {
    final query = topic.trim();
    if (query.isEmpty) {
      return;
    }

    _queryController.text = query;
    FocusManager.instance.primaryFocus?.unfocus();
    context.read<ResearchController>().search(query);
  }

  void _openPublication(Publication publication) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicationDetailScreen(publication: publication),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResearchController>();
    final analysis = controller.analysis;

    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SearchPanel(
                queryController: _queryController,
                suggestedTopics: _suggestedTopics,
                isLoading: controller.isLoading,
                onSubmit: _submitSearch,
              ),
              const SizedBox(height: 18),
              if (controller.status == ResearchStatus.error)
                _ErrorPanel(
                  message: controller.errorMessage ?? 'Unable to load data.',
                  onRetry: controller.currentTopic.isEmpty
                      ? null
                      : () => controller.refresh(),
                ),
              if (analysis == null && controller.status != ResearchStatus.error)
                const SizedBox(
                  height: 360,
                  child: EmptyState(
                    icon: Icons.manage_search_outlined,
                    title: 'Search a research topic',
                    message: 'OpenAlex publications will appear here.',
                  ),
                ),
              if (analysis != null) ...[
                _ResultHeader(
                  topic: analysis.topic,
                  total: analysis.totalPublications,
                  shown: analysis.publications.length,
                ),
                const SizedBox(height: 12),
                for (final publication in analysis.publications) ...[
                  PublicationCard(
                    publication: publication,
                    onTap: () => _openPublication(publication),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.queryController,
    required this.suggestedTopics,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController queryController;
  final List<String> suggestedTopics;
  final bool isLoading;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: queryController,
              enabled: !isLoading,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmit,
              decoration: InputDecoration(
                labelText: 'Research topic',
                hintText: 'Machine learning, IoT, cybersecurity...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: isLoading
                      ? null
                      : () => onSubmit(queryController.text),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final topic in suggestedTopics)
                  ActionChip(
                    avatar: const Icon(Icons.tag, size: 16),
                    label: Text(topic),
                    onPressed: isLoading ? null : () => onSubmit(topic),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.topic,
    required this.total,
    required this.shown,
  });

  final String topic;
  final int total;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '${formatCount(total)} matching articles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Showing $shown',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
