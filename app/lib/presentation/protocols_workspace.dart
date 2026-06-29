part of '../main.dart';

// Project protocol view for local metric and workflow events.

final class _ProtocolsWorkspace extends StatelessWidget {
  const _ProtocolsWorkspace({
    required this.copy,
    required this.project,
    required this.metrics,
  });

  final WritellerCopy copy;
  final Project? project;
  final List<MetricEvent> metrics;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final orderedMetrics = [...metrics]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: color.surface,
            border: Border(
              bottom: BorderSide(color: color.outlineVariant),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: color.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    copy.t('protocols'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  '${orderedMetrics.length}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
            children: [
              Text(
                project?.title ?? copy.t('selectProject'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                copy.t('protocolsBody'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              _DashboardSection(
                title: copy.t('protocols'),
                body: copy.t('activityStreamBody'),
                child: orderedMetrics.isEmpty
                    ? _EmptyInlineMessage(message: copy.t('noProtocolsYet'))
                    : Column(
                        children: [
                          for (final event in orderedMetrics)
                            _ProtocolEventRow(copy: copy, event: event),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _ProtocolEventRow extends StatelessWidget {
  const _ProtocolEventRow({
    required this.copy,
    required this.event,
  });

  final WritellerCopy copy;
  final MetricEvent event;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final metadata = event.metadata.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}: ${_compactMetricValue(entry.value)}')
        .join('  |  ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              _formatLocalDateTime(event.occurredAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(Icons.insights_outlined, color: color.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _metricEventLabel(event.eventType, copy.languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    metadata,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (event.value != null) ...[
            const SizedBox(width: 12),
            Text(
              '${event.value}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _compactMetricValue(Object? value) {
  if (value is String) return value;
  if (value is num || value is bool) return '$value';
  return jsonEncode(value);
}
