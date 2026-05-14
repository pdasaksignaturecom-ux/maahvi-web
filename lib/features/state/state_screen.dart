import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maahvi/data/models/result_model.dart';
import 'package:maahvi/features/state/state_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StateScreen extends StatefulWidget {
  final String stateId;
  const StateScreen({super.key, required this.stateId});

  @override
  State<StateScreen> createState() => _StateScreenState();
}

class _StateScreenState extends State<StateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StateViewModel>().fetchStateData(widget.stateId);
    });
  }

  void _downloadAPK() {
    _launchURL("https://www.maahvi.com/maahvi_lottery.apk");
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _viewSpecificResult(String time) {
    final viewModel = context.read<StateViewModel>();
    final targetTime = time.replaceAll(' ', '').toUpperCase();

    ResultModel? found;
    for (var r in viewModel.results) {
      if (r.drawTime.replaceAll(' ', '').toUpperCase().contains(targetTime)) {
        found = r;
        break;
      }
    }

    if (found != null) {
      context.push('/result/${found.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Result for $time is not available yet. Refreshing...")),
      );
      viewModel.fetchStateData(widget.stateId);
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText =
        widget.stateId == 'kerala' ? 'Kerala Lottery' : 'Lottery Sambad';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          '$titleText Result',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Container(
            height: 55,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _navItem('Home', Colors.blue, onTap: () => context.go('/')),
                _navItem('1 PM Result', Colors.red,
                    onTap: () => _viewSpecificResult('1:00 PM')),
                _navItem('6 PM Result', Colors.red,
                    onTap: () => _viewSpecificResult('6:00 PM')),
                _navItem('8 PM Result', Colors.red,
                    onTap: () => _viewSpecificResult('8:00 PM')),
                _navItem('Today Result', Colors.green,
                    onTap: () => context.go('/today-result')),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<StateViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.results.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchStateData(widget.stateId),
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 850),
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  child: Column(
                    children: [
                      Text(
                        '$titleText Today Result',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 25),

                      // Uniform Download Banner
                      _buildDownloadBanner(),

                      const SizedBox(height: 30),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        runSpacing: 15,
                        children: [
                          _buildActionButton(
                              '1:00 PM Result', const Color(0xFFC62828),
                              onTap: () => _viewSpecificResult('1:00 PM')),
                          _buildActionButton(
                              '6:00 PM Result', const Color(0xFFC62828),
                              onTap: () => _viewSpecificResult('6:00 PM')),
                          _buildActionButton(
                              '8:00 PM Result', const Color(0xFFC62828),
                              onTap: () => _viewSpecificResult('8:00 PM')),
                          _buildActionButton(
                              'Refresh Results', const Color(0xFFE67E22),
                              onTap: () =>
                                  viewModel.fetchStateData(widget.stateId)),
                        ],
                      ),

                      const SizedBox(height: 40),

                      if (viewModel.predictions.isNotEmpty)
                        _buildPredictionBox(viewModel.predictions.first),

                      const SizedBox(height: 20),

                      if (viewModel.results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text("Waiting for results update...",
                              style: TextStyle(fontSize: 16)),
                        )
                      else
                        ...viewModel.results
                            .map((result) => _buildResultSection(result)),

                      const SizedBox(height: 60),
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

  Widget _buildDownloadBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.android, color: Colors.green, size: 28),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Maahvi Lottery App",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("Fastest Results", style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _downloadAPK,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            child: const Text("DOWNLOAD APK", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, Color color, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ActionChip(
        onPressed: onTap ?? () {},
        backgroundColor: color.withValues(alpha: 0.1),
        label: Text(title,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        side: BorderSide(color: color),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, {VoidCallback? onTap}) {
    return SizedBox(
      width: 180,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap ?? () {},
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  Widget _buildPredictionBox(Map<String, dynamic> prediction) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        border: Border.all(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text("🔮 TODAY'S GUESSING",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 18)),
          const Divider(),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: (prediction['predictionNumbers'] as List? ?? [])
                .map((n) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.green.shade200),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(n.toString(),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(ResultModel result) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7), topRight: Radius.circular(7))),
            child: Text("${result.drawName} - ${result.drawTime}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text("Draw Date: ${result.date}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                if (result.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(result.imageUrl!, fit: BoxFit.contain),
                  ),
                const SizedBox(height: 20),
                if (result.pdfUrl != null && result.pdfUrl!.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(result.pdfUrl),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('DOWNLOAD OFFICIAL PDF'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
