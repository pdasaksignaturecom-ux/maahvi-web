import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maahvi/data/models/result_model.dart';
import 'package:maahvi/data/repositories/lottery_repository.dart';

class AdminResultUpload extends StatefulWidget {
  const AdminResultUpload({super.key});

  @override
  State<AdminResultUpload> createState() => _AdminResultUploadState();
}

class _AdminResultUploadState extends State<AdminResultUpload> {
  final _formKey = GlobalKey<FormState>();
  String selectedState = 'West Bengal';
  String? selectedTime;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _pdfUrlController = TextEditingController();
  final TextEditingController _drawNameController = TextEditingController();

  final List<String> states = [
    'West Bengal',
    'Sikkim',
    'Nagaland',
    'Mizoram',
    'Punjab',
    'Kerala'
  ];
  final List<String> times = [
    '1 PM',
    '6 PM',
    '8 PM',
    'Dhankeasri',
    'Bumper',
    'Kerala 4 PM'
  ];

  List<ResultModel> existingResults = [];
  bool isLoadingResults = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingResults();
  }

  Future<void> _fetchExistingResults() async {
    setState(() => isLoadingResults = true);
    try {
      final stateId = selectedState.toLowerCase().replaceAll(' ', '-');
      final results = await LotteryRepository().getResults(stateId,
          date: DateFormat('dd-MM-yyyy').format(selectedDate));
      if (!mounted) return;
      setState(() => existingResults = results);
    } catch (e) {
      debugPrint("Error fetching results: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingResults = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchExistingResults();
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final stateId = selectedState.toLowerCase().replaceAll(' ', '-');
      final resultData = {
        "stateName": stateId,
        "date": DateFormat('dd-MM-yyyy').format(selectedDate),
        "drawTime": selectedTime,
        "drawName": _drawNameController.text,
        "imageUrl": _imageUrlController.text,
        "pdfUrl": _pdfUrlController.text,
      };

      try {
        await LotteryRepository().uploadResult(resultData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Result Successfully Saved/Updated!"),
            backgroundColor: Colors.green));
        _fetchExistingResults();
        _clearForm();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _clearForm() {
    _imageUrlController.clear();
    _pdfUrlController.clear();
    _drawNameController.clear();
    setState(() {
      selectedTime = null;
    });
  }

  void _deleteResult(String id) async {
    try {
      await LotteryRepository().deleteResult(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Result Deleted")));
      _fetchExistingResults();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Admin Result Manager"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload / Update Result",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedState,
                    decoration:
                        const InputDecoration(labelText: "Select State"),
                    items: states
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedState = val!);
                      _fetchExistingResults();
                    },
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Date: ${DateFormat('dd-MM-yyyy').format(selectedDate)}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTime,
                    decoration:
                        const InputDecoration(labelText: "Select Draw Time"),
                    items: times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedTime = val),
                    validator: (val) =>
                        val == null ? 'Please select time' : null,
                  ),
                  TextFormField(
                    controller: _drawNameController,
                    decoration: const InputDecoration(
                        labelText: "Draw Name (e.g. Dear Dwarka)"),
                    validator: (val) => val!.isEmpty ? 'Enter draw name' : null,
                  ),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration:
                        const InputDecoration(labelText: "Image Result URL"),
                    validator: (val) => val!.isEmpty ? 'Enter image URL' : null,
                  ),
                  TextFormField(
                    controller: _pdfUrlController,
                    decoration: const InputDecoration(
                        labelText: "PDF Result URL (Optional)"),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent),
                    child: const Text("PUBLISH RESULT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("Existing Results List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            isLoadingResults
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                : existingResults.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No results found for this state & date."),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: existingResults.length,
                        itemBuilder: (context, index) {
                          final res = existingResults[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.description,
                                  color: Colors.redAccent),
                              title: Text("${res.drawTime} - ${res.drawName}"),
                              subtitle: Text("Date: ${res.date}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        selectedTime = res.drawTime;
                                        _drawNameController.text = res.drawName;
                                        _imageUrlController.text =
                                            res.imageUrl ?? "";
                                        _pdfUrlController.text =
                                            res.pdfUrl ?? "";
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteResult(res.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
