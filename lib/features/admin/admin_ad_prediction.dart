import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maahvi/data/repositories/lottery_repository.dart';

class AdminAdPrediction extends StatefulWidget {
  const AdminAdPrediction({super.key});

  @override
  State<AdminAdPrediction> createState() => _AdminAdPredictionState();
}

class _AdminAdPredictionState extends State<AdminAdPrediction> {
  final _adTitleController = TextEditingController();
  final _adMediaUrlController = TextEditingController();
  final _adLinkController = TextEditingController();
  String? _editingAdId;

  final Map<String, TextEditingController> _numControllers = {
    '1 PM_free': TextEditingController(),
    '1 PM_vip': TextEditingController(),
    '6 PM_free': TextEditingController(),
    '6 PM_vip': TextEditingController(),
    '8 PM_free': TextEditingController(),
    '8 PM_vip': TextEditingController(),
  };

  final _vipCodeController = TextEditingController();
  final _taskLinkController = TextEditingController();
  final _taskInstructionController = TextEditingController();

  String selectedState = 'west-bengal';
  DateTime selectedDate = DateTime.now();
  bool _isLoadingAds = false;
  bool _isSavingPreds = false;
  List<dynamic> _existingAds = [];

  final List<Map<String, String>> _states = [
    {'name': 'West Bengal', 'id': 'west-bengal'},
    {'name': 'Nagaland', 'id': 'nagaland'},
    {'name': 'Sikkim', 'id': 'sikkim'},
    {'name': 'Kerala', 'id': 'kerala'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchAds();
    _loadCurrentPredictions();
  }

  void _loadSettings() async {
    try {
      final settings = await LotteryRepository().getSettings();
      if (!mounted) return;
      setState(() {
        _vipCodeController.text = settings['vipSecretCode'] ?? '';
        _taskLinkController.text = settings['taskUrl'] ?? '';
        _taskInstructionController.text = settings['taskInstructions'] ?? '';
      });
    } catch (e) {
      debugPrint("Load Settings Error: $e");
    }
  }

  Future<void> _fetchAds() async {
    setState(() => _isLoadingAds = true);
    try {
      final ads = await LotteryRepository().getAds();
      if (!mounted) return;
      setState(() => _existingAds = ads);
    } finally {
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }

  Future<void> _loadCurrentPredictions() async {
    for (var controller in _numControllers.values) {
      controller.clear();
    }
    try {
      final preds = await LotteryRepository().getPredictions(selectedState,
          date: DateFormat('dd-MM-yyyy').format(selectedDate));
      if (!mounted) return;
      setState(() {
        for (var p in preds) {
          bool pIsVip =
              (p['isVip'] == true || p['isVip'] == 'true' || p['isVip'] == 1);
          String pTime =
              p['drawTime'].toString().toUpperCase().replaceAll(" ", "");

          _numControllers.forEach((key, controller) {
            final parts = key.split('_');
            String keyTime = parts[0].toUpperCase().replaceAll(" ", "");
            bool keyIsVip = (parts[1] == 'vip');

            if (pTime.contains(keyTime) && pIsVip == keyIsVip) {
              controller.text = (p['predictionNumbers'] as List).join(', ');
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Load Predictions Error: $e");
    }
  }

  void _saveAllPredictions() async {
    setState(() => _isSavingPreds = true);
    try {
      final String dateStr = DateFormat('dd-MM-yyyy').format(selectedDate);
      List<Map<String, dynamic>> predictionsList = [];

      for (var entry in _numControllers.entries) {
        final parts = entry.key.split('_');
        final time = parts[0];
        final isVip = (parts[1] == 'vip');
        final numbers = entry.value.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (numbers.isNotEmpty) {
          predictionsList.add(
              {"drawTime": time, "predictionNumbers": numbers, "isVip": isVip});
        }
      }

      if (predictionsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("দয়া করে অন্তত একটি নম্বর দিন।")));
        setState(() => _isSavingPreds = false);
        return;
      }

      await LotteryRepository().saveBulkPredictions({
        "stateName": selectedState,
        "date": dateStr,
        "predictions": predictionsList
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("All Predictions Saved Successfully!"),
          backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: $e. সার্ভার সচল আছে কি না চেক করুন।"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSavingPreds = false);
    }
  }

  void _saveVipSettings() async {
    try {
      await LotteryRepository().updateSettings({
        "vipSecretCode": _vipCodeController.text.trim(),
        "taskUrl": _taskLinkController.text.trim(),
        "taskInstructions": _taskInstructionController.text.trim()
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("VIP Settings Updated!"),
          backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _postAd() async {
    final adData = {
      "title": _adTitleController.text,
      "type": "image",
      "mediaUrl": _adMediaUrlController.text,
      "linkUrl": _adLinkController.text,
      "isActive": true
    };
    if (_editingAdId == null) {
      await LotteryRepository().postAd(adData);
    } else {
      await LotteryRepository().updateAd(_editingAdId!, adData);
    }
    _adTitleController.clear();
    _adMediaUrlController.clear();
    _adLinkController.clear();
    _editingAdId = null;
    _fetchAds();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Ad Updated!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
          title: const Text("Ads & Predictions Manager"),
          backgroundColor: Colors.blueGrey.shade900,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard("🔑 VIP Task & Code Settings", [
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _vipCodeController,
                        decoration: const InputDecoration(
                            labelText: "Activation Code",
                            prefixIcon: Icon(Icons.vpn_key)))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                        controller: _taskLinkController,
                        decoration: const InputDecoration(
                            labelText: "Task URL",
                            prefixIcon: Icon(Icons.link)))),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _taskInstructionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: "Instructions",
                      prefixIcon: Icon(Icons.help_outline))),
              const SizedBox(height: 15),
              ElevatedButton(
                  onPressed: _saveVipSettings,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white),
                  child: const Text("UPDATE VIP SETTINGS")),
            ]),
            const SizedBox(height: 20),
            _buildCard("🔮 Prediction Manager - Config", [
              Row(children: [
                Expanded(
                    child: DropdownButtonFormField<String>(
                        initialValue: selectedState,
                        items: _states
                            .map((s) => DropdownMenuItem(
                                value: s['id'], child: Text(s['name']!)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => selectedState = v!);
                          _loadCurrentPredictions();
                        },
                        decoration: const InputDecoration(labelText: "State"))),
                const SizedBox(width: 10),
                TextButton.icon(
                    onPressed: () async {
                      final p = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (p != null) {
                        setState(() => selectedDate = p);
                        _loadCurrentPredictions();
                      }
                    },
                    icon: const Icon(Icons.event),
                    label: Text(DateFormat('dd-MM-yyyy').format(selectedDate))),
              ]),
            ]),
            const SizedBox(height: 15),
            _buildCard("🆓 Free Numbers", [
              _field(
                  "1 PM", "free", "1 PM Free Numbers", Colors.orange.shade50),
              const SizedBox(height: 12),
              _field(
                  "6 PM", "free", "6 PM Free Numbers", Colors.orange.shade50),
              const SizedBox(height: 12),
              _field(
                  "8 PM", "free", "8 PM Free Numbers", Colors.orange.shade50),
            ]),
            const SizedBox(height: 15),
            _buildCard("⭐ VIP Numbers", [
              _field("1 PM", "vip", "1 PM VIP Numbers", Colors.purple.shade50),
              const SizedBox(height: 12),
              _field("6 PM", "vip", "6 PM VIP Numbers", Colors.purple.shade50),
              const SizedBox(height: 12),
              _field("8 PM", "vip", "8 PM VIP Numbers", Colors.purple.shade50),
            ]),
            const SizedBox(height: 20),
            _isSavingPreds
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _saveAllPredictions,
                    icon: const Icon(Icons.save_alt),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    label: const Text("SAVE ALL PREDICTIONS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 30),
            _buildCard("📢 Ads Manager", [
              TextFormField(
                  controller: _adTitleController,
                  decoration: const InputDecoration(labelText: "Ad Title")),
              TextFormField(
                  controller: _adMediaUrlController,
                  decoration: const InputDecoration(labelText: "Image URL")),
              TextFormField(
                  controller: _adLinkController,
                  decoration:
                      const InputDecoration(labelText: "Redirect Link")),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _postAd,
                  child: Text(_editingAdId == null ? "Post Ad" : "Update Ad")),
              const Divider(height: 30),
              if (_isLoadingAds) const LinearProgressIndicator(),
              Column(
                  children: _existingAds
                      .map((ad) => ListTile(
                          title: Text(ad['title'] ?? ""),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await LotteryRepository().deleteAd(ad['_id']);
                                _fetchAds();
                              }),
                          onTap: () {
                            setState(() {
                              _editingAdId = ad['_id'];
                              _adTitleController.text = ad['title'] ?? "";
                              _adMediaUrlController.text = ad['mediaUrl'] ?? "";
                              _adLinkController.text = ad['linkUrl'] ?? "";
                            });
                          }))
                      .toList())
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueGrey)),
            const SizedBox(height: 15),
            ...children
          ])));

  Widget _field(String t, String type, String l, Color c) => TextFormField(
      controller: _numControllers["${t}_$type"],
      decoration: InputDecoration(
          labelText: l,
          filled: true,
          fillColor: c,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8)));
}
