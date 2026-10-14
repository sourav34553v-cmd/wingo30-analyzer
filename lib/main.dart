
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const WinGoAnalyzer());
}

class WinGoAnalyzer extends StatelessWidget {
  const WinGoAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WinGo 30S Analyzer',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF10141B),
        useMaterial3: true,
      ),
      home: const AnalyzerHome(),
    );
  }
}

class AnalyzerHome extends StatefulWidget {
  const AnalyzerHome({super.key});

  @override
  State<AnalyzerHome> createState() => _AnalyzerHomeState();
}

class _AnalyzerHomeState extends State<AnalyzerHome> {
  final List<int> results = [];
  final TextEditingController input = TextEditingController();
  Timer? timer;
  int seconds = 30;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        seconds = seconds <= 1 ? 30 : seconds - 1;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    input.dispose();
    super.dispose();
  }

  void addResult() {
    final value = int.tryParse(input.text.trim());
    if (value == null || value < 0 || value > 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a number from 0 to 9')),
      );
      return;
    }
    setState(() {
      results.insert(0, value);
      input.clear();
    });
  }

  int countNumber(int number) =>
      results.where((value) => value == number).length;

  int get currentStreak {
    if (results.isEmpty) return 0;
    int count = 0;
    for (final value in results) {
      if (value == results.first) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final big = results.where((n) => n >= 5).length;
    final small = results.length - big;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WinGo 30S Analyzer'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => results.clear()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('LOCAL 30-SECOND TIMER',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    '00:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Independent timer — not synced to JaiClub66',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('RECORD A RESULT',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(
                    labelText: 'Result (0–9)',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  onSubmitted: (_) => addResult(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: addResult,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard('Total results', '${results.length}'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard('Big (5–9)', '$big'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard('Small (0–4)', '$small'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'NUMBER FREQUENCY',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...List.generate(10, (number) {
            final count = countNumber(number);
            final percentage = results.isEmpty
                ? 0.0
                : count / results.length;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: number.isEven
                              ? Colors.teal
                              : Colors.deepOrange,
                          child: Text('$number'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('$count (${(percentage * 100).toStringAsFixed(0)}%)'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'RECENT HISTORY',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (results.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No results recorded yet. Enter results manually above.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: results.take(50).map((n) {
                return CircleAvatar(
                  backgroundColor:
                      n >= 5 ? Colors.deepOrange : Colors.teal,
                  child: Text('$n'),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATISTICAL SUMMARY',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Most recent result: '
                      '${results.isEmpty ? '—' : results.first}'),
                  Text('Current same-number streak: $currentStreak'),
                  Text('Big results: $big'),
                  Text('Small results: $small'),
                  const SizedBox(height: 8),
                  const Text(
                    'Past frequencies and streaks describe recorded data; '
                    'they do not predict the next winning result. '
                    'This app does not hack or connect to JaiClub66.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 21, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
