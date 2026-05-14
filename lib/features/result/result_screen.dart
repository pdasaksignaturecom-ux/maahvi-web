import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:maahvi/features/result/result_viewmodel.dart';
import 'package:maahvi/features/subscription/vip_viewmodel.dart'; // সঠিক পাথ
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatefulWidget {
  final String resultId;
  const ResultScreen({super.key, required this.resultId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showVip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ResultViewModel>().fetchResultDetail(widget.resultId);
      }
    });
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch URL")));
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Numbers copied to clipboard!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("RESULT DETAILS",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ResultViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
          }

          final result = viewModel.selectedResult;
          if (result == null) {
            return const Center(
                child: Text("Result not found. Check Connection."));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchResultDetail(widget.resultId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF1F1), Colors.white],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Text(result.drawName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD32F2F))),
                      const SizedBox(height: 20),

                      // Time Slots
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: viewModel.allTodayResults.isEmpty
                            ? [
                                _timeSlotBtn(result.drawTime,
                                    Colors.green.shade800, () {})
                              ]
                            : viewModel.allTodayResults.map((r) {
                                return _timeSlotBtn(
                                    r.drawTime,
                                    r.id == result.id
                                        ? Colors.green.shade800
                                        : const Color(0xFFD32F2F),
                                    () => context
                                        .pushReplacement('/result/${r.id}'));
                              }).toList(),
                      ),

                      const SizedBox(height: 35),
                      _buildEnhancedPredictionSection(viewModel),
                      const SizedBox(height: 45),

                      Text(result.date,
                          style: const TextStyle(
                              fontSize: 26,
                              color: Colors.green,
                              fontWeight: FontWeight.w900)),
                      Text(result.drawTime,
                          style: const TextStyle(
                              fontSize: 26,
                              color: Colors.green,
                              fontWeight: FontWeight.w900)),

                      const SizedBox(height: 25),
                      if (result.imageUrl != null)
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5))
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              result.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("Image not available"),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 35),
                      if (result.pdfUrl != null)
                        _actionBtn(
                            'DOWNLOAD PDF RESULT',
                            const Color(0xFFD32F2F),
                            () => _launchURL(result.pdfUrl),
                            isFullWidth: true),

                      const SizedBox(height: 45),
                      const Divider(thickness: 1.5),
                      const SizedBox(height: 50),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedPredictionSection(ResultViewModel viewModel) {
    final allTimes = ['1 PM', '6 PM', '8 PM'];
    final bool isUserVip = context.watch<VipViewModel>().isVip;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showVip = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_showVip ? Colors.orange : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "FREE PREDICTION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_showVip ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showVip = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _showVip ? Colors.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "VIP PREDICTION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _showVip ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...allTimes.map((time) {
          final pred = viewModel.getPredictionForTime(time, isVip: _showVip);
          if (pred == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _predictionCard(
              _showVip
                  ? "Premium VIP Numbers ($time)"
                  : "Free Lucky Numbers ($time)",
              pred,
              _showVip ? Colors.purple : Colors.orange,
              _showVip && !isUserVip,
              time,
              isVipTheme: _showVip,
            ),
          );
        }),
        if (allTimes.every(
            (t) => viewModel.getPredictionForTime(t, isVip: _showVip) == null))
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "No predictions available for today yet.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _predictionCard(String title, Map<String, dynamic> data, Color color,
      bool isLocked, String time,
      {bool isVipTheme = false}) {
    final List<dynamic> numbers = data['predictionNumbers'] ?? [];
    final Color baseColor = isVipTheme ? Colors.purple : color;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isVipTheme ? const Color(0xFFF3E5F5) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: baseColor.withValues(alpha: 0.8))),
              if (!isLocked && numbers.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyToClipboard(numbers.join(", ")),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLocked)
            _buildLockedState()
          else
            Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: numbers
                    .map((n) => _buildLotteryBall(n.toString(), baseColor))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLotteryBall(String n, Color color) {
    return Container(
      width: 45,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(n,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: color)),
    );
  }

  Widget _buildLockedState() {
    return Column(
      children: [
        const Icon(Icons.lock_outline, color: Colors.purple, size: 30),
        const SizedBox(height: 8),
        const Text("VIP Numbers Locked",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => context.push('/vip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("UNLOCK", style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _timeSlotBtn(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap,
      {bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text("Maahvi Lottery Result",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 10),
        Text("© 2024-2025 All Rights Reserved",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 30),
      ],
    );
  }
}
