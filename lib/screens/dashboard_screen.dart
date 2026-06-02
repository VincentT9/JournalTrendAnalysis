import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/research_controller.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResearchController>();
    final analysis = controller.analysis;

    if (analysis == null && controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (analysis == null) {
      return const EmptyState(
        icon: Icons.dashboard_outlined,
        title: 'No dashboard data',
        message: 'Search a topic to load research metrics.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final activeYear = analysis.mostActiveYear;
    final topJournal = analysis.topJournal;
    final topAuthor = analysis.topAuthor;
    final mostInfluential = analysis.mostInfluentialPaper;

    return Column(
      children: [
        if (controller.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                analysis.topic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dashboard summary from OpenAlex works data',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720 ? 3 : 2;
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 3 ? 1.55 : 1.18,
                    ),
                    children: [
                      MetricCard(
                        icon: Icons.library_books_outlined,
                        label: 'Total publications',
                        value: formatCount(analysis.totalPublications),
                        accentColor: colorScheme.primary,
                      ),
                      MetricCard(
                        icon: Icons.format_quote_outlined,
                        label: 'Average citations',
                        value: formatCount(analysis.averageCitationCount),
                        accentColor: colorScheme.tertiary,
                      ),
                      MetricCard(
                        icon: Icons.event_available_outlined,
                        label: 'Most active year',
                        value: activeYear == null
                            ? 'N/A'
                            : '${activeYear.name} (${formatCompactCount(activeYear.count)})',
                        accentColor: colorScheme.secondary,
                      ),
                      MetricCard(
                        icon: Icons.menu_book_outlined,
                        label: 'Top journal',
                        value: topJournal?.name ?? 'N/A',
                        accentColor: const Color(0xFF7C3AED),
                      ),
                      MetricCard(
                        icon: Icons.person_outline,
                        label: 'Top author',
                        value: topAuthor?.name ?? 'N/A',
                        accentColor: const Color(0xFFDC2626),
                      ),
                      MetricCard(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Most influential paper',
                        value: mostInfluential?.title ?? 'N/A',
                        accentColor: const Color(0xFF0891B2),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Card(
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Snapshot',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      _SnapshotRow(
                        label: 'Loaded publications',
                        value: formatCount(analysis.publications.length),
                      ),
                      _SnapshotRow(
                        label: 'Influential papers ranked',
                        value: formatCount(analysis.topInfluential.length),
                      ),
                      _SnapshotRow(
                        label: 'Trend years',
                        value: formatCount(analysis.trendByYear.length),
                      ),
                    ],
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

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
