import 'package:flutter/material.dart';

/// Shared card for Loading / Success / Empty / Error responses.
class StateCard extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final String title;
  final String message;
  final String note; // short explanation of the state
  final bool loading;
  final List<Widget> actions;

  const StateCard({
    super.key,
    this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.note,
    this.loading = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: loading
                  ? const SizedBox(
                      height: 48, width: 48, child: CircularProgressIndicator())
                  : Icon(icon, color: color, size: 64),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                note,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            if (actions.isNotEmpty) const SizedBox(height: 20),
            for (final a in actions) ...[a, const SizedBox(height: 8)],
          ],
        ),
      ),
    );
  }
}