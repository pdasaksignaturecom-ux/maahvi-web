import 'package:flutter/material.dart';
import 'package:maahvi/data/repositories/lottery_repository.dart';
import 'package:maahvi/features/subscription/vip_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _hasVisitedLink = false;
  String _dynamicTaskUrl = "https://instagram.com/your_profile";
  String _taskInstructions = "Follow the link and find the secret activation code.";

  @override
  void initState() {
    super.initState();
    _loadVipSettings();
  }

  void _loadVipSettings() async {
    try {
      final settings = await LotteryRepository().getSettings();
      if (!mounted) return;
      setState(() {
        _dynamicTaskUrl = settings['taskUrl'] ?? _dynamicTaskUrl;
        _taskInstructions = settings['taskInstructions'] ?? _taskInstructions;
      });
    } catch (e) {
      debugPrint("Error loading VIP settings: $e");
    }
  }

  Future<void> _launchTask() async {
    final Uri url = Uri.parse(_dynamicTaskUrl);
    // Directly try to launch as canLaunchUrl is unreliable on Web
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() => _hasVisitedLink = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $_dynamicTaskUrl')),
        );
      }
    }
  }

  void _handleActivation() async {
    final enteredCode = _codeController.text.trim();
    if (enteredCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code.')),
      );
      return;
    }

    final viewModel = context.read<VipViewModel>();
    
    // Using a consistent ID for now. 
    // IMPORTANT: In production, this should be the actual user ID.
    const String activeUserId = '65d1234567890abcdef12345';
    
    final success = await viewModel.activateFreeVip(activeUserId, enteredCode);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification Successful! VIP Activated.'),
          backgroundColor: Colors.green,
        ),
      );
      // Wait a moment for the user to see the message before popping
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage.isEmpty ? 'Invalid Code!' : viewModel.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FREE VIP ACTIVATION', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Consumer<VipViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
                const SizedBox(height: 10),
                const Text('DEAR VIP CLUB', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text("How to Activate?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(_taskInstructions, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildStepHeader("1", "Visit & Find Code", _hasVisitedLink),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _launchTask,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("GO TO TASK LINK"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 30),
                _buildStepHeader("2", "Enter Verification Code", false),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  enabled: _hasVisitedLink,
                  decoration: InputDecoration(
                    hintText: "Enter the secret code",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.vpn_key),
                    filled: true,
                    fillColor: _hasVisitedLink ? Colors.white : Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 30),
                viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _hasVisitedLink ? _handleActivation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasVisitedLink ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("VERIFY & ACTIVATE VIP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepHeader(String number, String title, bool isDone) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isDone ? Colors.green : Colors.amber.shade700,
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Spacer(),
        if (isDone) const Icon(Icons.check_circle, color: Colors.green, size: 20),
      ],
    );
  }
}
