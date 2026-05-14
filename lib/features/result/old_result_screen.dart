import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:maahvi/features/state/state_viewmodel.dart';

class OldResultScreen extends StatefulWidget {
  final String stateId;
  const OldResultScreen({super.key, required this.stateId});

  @override
  State<OldResultScreen> createState() => _OldResultScreenState();
}

class _OldResultScreenState extends State<OldResultScreen> {
  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1)); // ডিফল্ট গতকালের তারিখ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    context.read<StateViewModel>().fetchStateData(widget.stateId, date: formattedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Past Results / Archive"),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.yellow.shade700,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Results for: ${DateFormat('dd-MM-yyyy').format(selectedDate)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_month),
                  label: const Text("Change Date"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Consumer<StateViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.red));
                
                if (viewModel.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text("No results found for ${DateFormat('dd-MM-yyyy').format(selectedDate)}", 
                             style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: viewModel.results.length,
                  itemBuilder: (context, index) {
                    final result = viewModel.results[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            color: Colors.blue.shade900,
                            child: Text(
                              "${result.drawName} (${result.drawTime})",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (result.imageUrl != null)
                            Image.network(result.imageUrl!, fit: BoxFit.contain),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton.icon(
                              onPressed: () {}, // পিডিএফ ডাউনলোডের লজিক
                              icon: const Icon(Icons.download),
                              label: const Text("Download Result"),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
