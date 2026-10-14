
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF10141B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
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
  final TextEditingController controller = TextEditingController();

  void addResult() {
    final value = int.tryParse(controller.text.trim());

    if (value == null || value < 0 || value > 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a number from 0 to 9')),
      );
      return;
    }

    setState(() {
      results.insert(0, value);
      controller.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final big = results.where((n) => n >= 5).length;
    final small = results.length - big;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WinGo 30S Analyzer'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STATISTICAL ANALYZER',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 8),
                  Text('Record results and review past data.'),
                  SizedBox(height: 8),
                  Text('Big: 5–9  |  Small: 0–4'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: const InputDecoration(
              labelText: 'Enter result (0–9)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => addResult(),
          ),
          ElevatedButton.icon(
            onPressed: addResult,
            icon: const Icon(Icons.add),
            label: const Text('ADD RESULT'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCard('Total', results.length, Colors.blue),
              ),
              Expanded(
                child: _statCard('Big', big, Colors.orange),
              ),
              Expanded(
                child: _statCard('Small', small, Colors.cyan),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Results',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty)
            const Text('No results added yet.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: results.map((n) {
                return CircleAvatar(
                  backgroundColor:
                      n >= 5 ? Colors.orange : Colors.blue,
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: results.isEmpty
                ? null
                : () => setState(() => results.clear()),
            child: const Text('CLEAR HISTORY'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: Past results do not reliably predict the next '
            'result. This app does not connect to or alter any game.',
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
