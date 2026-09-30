import 'package:flutter/material.dart';

import '../logic/line_diff.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _left = TextEditingController(text: 'apple\nbanana\ncherry');
  final _right = TextEditingController(text: 'apple\nblueberry\ncherry\ndate');
  bool _ignoreWhitespace = false;

  @override
  void dispose() {
    _left.dispose();
    _right.dispose();
    super.dispose();
  }

  Widget _input(TextEditingController c, String label, String key) {
    return TextField(
      key: Key(key),
      controller: c,
      minLines: 4,
      maxLines: 8,
      style: const TextStyle(fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    List<DiffLine>? diff;
    String? error;
    try {
      diff = diffLines(
        _left.text,
        _right.text,
        ignoreWhitespace: _ignoreWhitespace,
      );
    } on ArgumentError catch (e) {
      error = '${e.message}';
    }
    final summary = diff == null ? null : summarise(diff);
    return Scaffold(
      appBar: AppBar(title: const Text('Diffchecker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _input(_left, 'Original', 'left-input'),
          const SizedBox(height: 12),
          _input(_right, 'Changed', 'right-input'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ignore whitespace'),
            value: _ignoreWhitespace,
            onChanged: (v) => setState(() => _ignoreWhitespace = v),
          ),
          if (error != null) Text(error, style: TextStyle(color: colors.error)),
          if (summary != null)
            Text(
              summary.identical
                  ? 'No differences'
                  : '+${summary.added} added, -${summary.removed} removed',
              key: const Key('diff-summary'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 8),
          for (final d in diff ?? const <DiffLine>[])
            Container(
              color: switch (d.op) {
                DiffOp.added => colors.primaryContainer,
                DiffOp.removed => colors.errorContainer,
                DiffOp.same => null,
              },
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                d.toString(),
                semanticsLabel: '${d.op.name}: ${d.text}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }
}
