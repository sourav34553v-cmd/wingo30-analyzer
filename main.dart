import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const WinGoAnalyzerApp());

class WinGoAnalyzerApp extends StatelessWidget {
  const WinGoAnalyzerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'WinGo 30S Analyzer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B1020),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF), brightness: Brightness.dark),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    ),
    home: const AnalyzerHome(),
  );
}

class GameResult {
  final int number;
  final DateTime time;
  GameResult(this.number, this.time);
  String get colorName => number == 0 || number == 5 ? 'Violet' : (number.isEven ? 'Red' : 'Green');
  String get sizeName => number <= 4 ? 'Small' : 'Big';
}

class AnalyzerHome extends StatefulWidget {
  const AnalyzerHome({super.key});
  @override
  State<AnalyzerHome> createState() => _AnalyzerHomeState();
}

class _AnalyzerHomeState extends State<AnalyzerHome> {
  final List<GameResult> _history = [];
  final TextEditingController _numberController = TextEditingController();
  Timer? _timer;
  int _seconds = 30;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds = _seconds <= 1 ? 30 : _seconds - 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _numberController.dispose();
    super.dispose();
  }

  void _addResult() {
    final n = int.tryParse(_numberController.text.trim());
    if (n == null || n < 0 || n > 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a number from 0 to 9.')));
      return;
    }
    setState(() {
      _history.insert(0, GameResult(n, DateTime.now()));
      _numberController.clear();
    });
  }

  int _count(String Function(GameResult) test) => _history.where((r) => test(r) == 'yes').length;
  int _colorCount(String color) => _history.where((r) => r.colorName == color).length;
  int _sizeCount(String size) => _history.where((r) => r.sizeName == size).length;
  String _pct(int count) => _history.isEmpty ? '—' : '${(100 * count / _history.length).toStringAsFixed(1)}%';

  String get _currentStreak {
    if (_history.isEmpty) return 'No results yet';
    final first = _history.first.colorName;
    var count = 0;
    for (final r in _history) {
      if (r.colorName != first) break;
      count++;
    }
    return '$first × $count';
  }

  String get _summary {
    if (_history.length < 10) return 'Add at least 10 results for a more useful summary.';
    final recent = _history.take(10).toList();
    final red = recent.where((r) => r.colorName == 'Red').length;
    final green = recent.where((r) => r.colorName == 'Green').length;
    final big = recent.where((r) => r.sizeName == 'Big').length;
    final small = recent.where((r) => r.sizeName == 'Small').length;
    final top = red > green ? 'Red appeared more often' : green > red ? 'Green appeared more often' : 'Red and Green were tied';
    final size = big > small ? 'Big appeared more often' : small > big ? 'Small appeared more often' : 'Big and Small were tied';
    return 'Last 10: $top; $size. This describes past results only and does not predict the next round.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WinGo 30S Analyzer'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('30-second timer', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(children: [
                Text('00:${_seconds.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => setState(() => _seconds = 30), icon: const Icon(Icons.refresh), tooltip: 'Reset timer'),
              ]),
              const Text('Local timer only — it is not synced with JaiClub66.', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          )),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Enter result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(labelText: 'Result number (0–9)', counterText: ''),
                  onSubmitted: (_) => _addResult(),
                )),
                const SizedBox(width: 10),
                FilledButton(onPressed: _addResult, child: const Text('Add')),
              ]),
              const Text('Color mapping used here: 0/5 Violet; even 2/4/6/8 Red; odd 1/3/7/9 Green. Verify the game’s rules before relying on this mapping.', style: TextStyle(fontSize: 12, color: Colors.white54)),
            ]),
          )),
          const SizedBox(height: 12),
          const Text('Historical statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.55,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _statCard('Total entered', '${_history.length}', 'Recorded rounds'),
              _statCard('Red', '${_colorCount('Red')} · ${_pct(_colorCount('Red'))}', 'Historical frequency'),
              _statCard('Green', '${_colorCount('Green')} · ${_pct(_colorCount('Green'))}', 'Historical frequency'),
              _statCard('Violet', '${_colorCount('Violet')} · ${_pct(_colorCount('Violet'))}', 'Historical frequency'),
              _statCard('Big', '${_sizeCount('Big')} · ${_pct(_sizeCount('Big'))}', 'Historical frequency'),
              _statCard('Small', '${_sizeCount('Small')} · ${_pct(_sizeCount('Small'))}', 'Historical frequency'),
            ],
          ),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Recent pattern summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_summary),
              const SizedBox(height: 12),
              Text('Current color streak: $_currentStreak'),
              const SizedBox(height: 8),
              const Text('This is descriptive statistics, not a reliable signal. Random or server-controlled outcomes can change independently of past rounds.', style: TextStyle(color: Colors.amber, fontSize: 12)),
            ]),
          )),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Text('Result history', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            TextButton(onPressed: _history.isEmpty ? null : () => setState(_history.clear), child: const Text('Clear all')),
          ]),
          if (_history.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No results entered yet.')))
          else
            ..._history.asMap().entries.map((entry) {
              final r = entry.value;
              final color = r.colorName == 'Red' ? Colors.redAccent : r.colorName == 'Green' ? Colors.greenAccent : Colors.purpleAccent;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: color, child: Text('${r.number}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                  title: Text('${r.colorName} · ${r.sizeName}'),
                  subtitle: Text('${r.time.toLocal()}'.split('.').first),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => _history.removeAt(entry.key))),
                ),
              );
            }),
          const SizedBox(height: 24),
          const Center(child: Text('Free demo • Manual input • No account connection', style: TextStyle(color: Colors.white38, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String caption) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
        const SizedBox(height: 3),
        Text(caption, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
    ),
  );
}
