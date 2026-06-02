import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publication.dart';
import '../state/research_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/publication_card.dart';
import '../widgets/ranked_list.dart';
import '../widgets/trend_chart.dart';
import 'publication_detail_screen.dart';

class TrendAnalysisScreen extends StatelessWidget {
  const TrendAnalysisScreen({super.key});

  void _openPublication(BuildContext context, Publication publication) {
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

    if (analysis == null && controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analysis == null) {
      return const EmptyState(
        icon: Icons.stacked_line_chart_outlined,
        title: 'No trend data',
        message: 'Search a topic to load trend analysis.',
      );
    }

    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SectionHeader(
                title: 'Publication Trend',
                subtitle: 'Recent publication volume by year',
              ),
              const SizedBox(height: 10),
              Card(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                  child: TrendChart(points: analysis.recentTrendByYear),
                ),
              ),
              const SizedBox(height: 22),
              const _SectionHeader(
                title: 'Top Influential Papers',
                subtitle: 'Ranked by citation count',
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < analysis.topInfluential.length; i++) ...[
                PublicationCard(
                  publication: analysis.topInfluential[i],
                  rank: i + 1,
                  onTap: () =>
                      _openPublication(context, analysis.topInfluential[i]),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 10),
              const _SectionHeader(
                title: 'Top Research Journals',
                subtitle: 'Sources contributing the most articles',
              ),
              const SizedBox(height: 10),
              Card(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: RankedList(
                    items: analysis.topJournals,
                    emptyLabel: 'No journal data available.',
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _SectionHeader(
                title: 'Top Contributing Authors',
                subtitle: 'Authors with the highest publication counts',
              ),
              const SizedBox(height: 10),
              Card(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: RankedList(
                    items: analysis.topAuthors,
                    emptyLabel: 'No author data available.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
