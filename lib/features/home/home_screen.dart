import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maahvi/data/models/result_model.dart';
import 'package:maahvi/features/home/home_viewmodel.dart';
import 'package:maahvi/features/state/state_viewmodel.dart';
import 'package:maahvi/features/subscription/vip_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _predictionKey = GlobalKey();

  // Admin secret tap logic
  int _tapCount = 0;
  DateTime? _firstTapTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    await context.read<StateViewModel>().fetchStateData('nagaland');
    if (!mounted) return;
    await context.read<HomeViewModel>().fetchHomeData();
  }

  void _scrollToPrediction() {
    final context = _predictionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void _shareApp() {
    const String appLink = "https://www.maahvi.com";
    Share.share("Dear Lottery রেজাল্ট দেখতে অ্যাপটি ডাউনলোড করুন: $appLink");
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

  void _handleAdminTap() {
    final now = DateTime.now();
    if (_firstTapTime == null ||
        now.difference(_firstTapTime!) > const Duration(seconds: 3)) {
      _tapCount = 1;
      _firstTapTime = now;
    } else {
      _tapCount++;
    }

    if (_tapCount >= 5) {
      _tapCount = 0;
      _firstTapTime = null;
      context.push('/admin-login');
    }
  }

  void _navigateToResult(BuildContext context, String query) {
    final stateVM = context.read<StateViewModel>();
    try {
      final r = stateVM.results.firstWhere(
          (res) => res.drawTime.toUpperCase().contains(query.toUpperCase()));
      context.push('/result/${r.id}');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No $query result found.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: GestureDetector(
          onTap: _handleAdminTap,
          child: const Text(
            'Maahvi Lottery Result',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: _shareApp),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            height: 65,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _navItem('Home', Colors.blue.shade700,
                    onTap: () => context.go('/')),
                _navItem('🔮 Predictions', Colors.orange.shade900,
                    onTap: _scrollToPrediction),
                _navItem('1:00 PM Result', Colors.red.shade700,
                    onTap: () => _navigateToResult(context, "1 PM")),
                _navItem('6:00 PM Result', Colors.red.shade700,
                    onTap: () => _navigateToResult(context, "6 PM")),
                _navItem('8:00 PM Result', Colors.red.shade700,
                    onTap: () => _navigateToResult(context, "8 PM")),
                _navItem('VIP Member', Colors.purple.shade700,
                    onTap: () => context.push('/vip')),
                _navItem('Today Result', Colors.green.shade700,
                    onTap: () => context.go('/today-result')),
                _navItem('Old Result', Colors.orange.shade700,
                    onTap: () => context.push('/old-results/nagaland')),
                _navItem('📥 Result Download', Colors.blueGrey.shade700,
                    onTap: () => context.push('/old-results/nagaland')),
              ],
            ),
          ),
        ),
      ),
      body: Consumer3<StateViewModel, HomeViewModel, VipViewModel>(
        builder: (context, stateVM, homeVM, vipVM, child) {
          if (stateVM.isLoading && stateVM.results.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 45,
                      horizontal:
                          MediaQuery.of(context).size.width > 600 ? 40 : 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(stateVM),
                      const SizedBox(height: 60),
                      const _SectionTitle(title: "📢 SPONSORED ADS"),
                      _buildPromoGallery(homeVM.ads),
                      const SizedBox(height: 60),
                      const _SectionTitle(title: "📄 TODAY'S LATEST RESULTS"),
                      if (stateVM.results.isNotEmpty)
                        ...stateVM.results.map((res) => _buildA4ResultPage(res))
                      else
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text("Waiting for draw results..."))),
                      const SizedBox(height: 60),
                      _SectionTitle(
                          key: _predictionKey,
                          title: "🔮 TODAY'S EXPERT GUESSING"),
                      _buildPredictionsStepByStep(
                          stateVM.predictions, vipVM.isVip),
                      const SizedBox(height: 60),
                      _buildDetailedInfoSection(),
                      const SizedBox(height: 70),
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

  Widget _buildHeaderSection(StateViewModel stateVM) {
    return Center(
      child: Column(
        children: [
          Text('Lottery Sambad Today',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 600 ? 48 : 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildHeroButton('1:00 PM Result', const Color(0xFFC62828),
                  onTap: () => _navigateToResult(context, "1 PM")),
              _buildHeroButton('6:00 PM Result', const Color(0xFFC62828),
                  onTap: () => _navigateToResult(context, "6 PM")),
              _buildHeroButton('8:00 PM Result', const Color(0xFFC62828),
                  onTap: () => _navigateToResult(context, "8 PM")),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildHeroButton('Dhankeasri', const Color(0xFFFBC02D),
                  textColor: Colors.black,
                  onTap: () => _navigateToResult(context, "Dhankeasri")),
              _buildHeroButton('Refresh', const Color(0xFFE67E22),
                  onTap: _refreshData),
              _buildHeroButton('Result Download', const Color(0xFF37474F),
                  onTap: () {
                if (stateVM.results.isNotEmpty) {
                  _launchURL(stateVM.results.first.pdfUrl);
                } else {
                  context.push('/old-results/nagaland');
                }
              }),
            ],
          ),
          const SizedBox(height: 40),
          // App Download Banner
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icon/app_icon.png',
                        height: 40,
                        errorBuilder: (c, e, s) => const Icon(Icons.android,
                            color: Colors.green, size: 30)),
                    const SizedBox(width: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Maahvi Lottery Android App",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Fastest result & daily prediction",
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _downloadAPK,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  child: const Text("DOWNLOAD APK"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton.icon(
              onPressed: _scrollToPrediction,
              icon: const Icon(Icons.psychology, size: 28),
              label: const Text("GOTO TODAY'S PREDICTIONS 🔮",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsStepByStep(List<dynamic> predictions, bool isVip) {
    final times = ['1 PM', '6 PM', '8 PM', 'Dhankeasri'];
    List<Widget> timeSections = [];

    for (var time in times) {
      final freePred = predictions.firstWhere((p) {
        bool pIsVip =
            (p['isVip'] == true || p['isVip'] == 'true' || p['isVip'] == 1);
        return p['drawTime'].toString().toUpperCase().contains(time) && !pIsVip;
      }, orElse: () => null);
      final vipPred = predictions.firstWhere((p) {
        bool pIsVip =
            (p['isVip'] == true || p['isVip'] == 'true' || p['isVip'] == 1);
        return p['drawTime'].toString().toUpperCase().contains(time) && pIsVip;
      }, orElse: () => null);

      if (freePred != null || vipPred != null) {
        timeSections.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Guessing for $time (${(freePred ?? vipPred)['date']})",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey)),
                const SizedBox(height: 15),
                if (freePred != null)
                  _predictionBox("FREE ACCESS", freePred, Colors.orange, false),
                if (freePred != null && vipPred != null)
                  const SizedBox(height: 15),
                if (vipPred != null)
                  _predictionBox("VIP SPECIAL", vipPred, Colors.purple, !isVip),
              ],
            ),
          ),
        );
      }
    }

    return timeSections.isEmpty
        ? const Center(
            child: Padding(
                padding: EdgeInsets.all(40),
                child: Text("No predictions available for today.")))
        : Column(children: timeSections);
  }

  Widget _predictionBox(
      String label, Map<String, dynamic> data, Color color, bool isLocked) {
    final List<dynamic> numbers = data['predictionNumbers'] ?? [];
    if (!isLocked && numbers.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLocked
            ? color.withValues(alpha: 0.04)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(isLocked ? Icons.lock : Icons.check_circle,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: isLocked
                ? Column(
                    children: [
                      const Icon(Icons.lock_person,
                          size: 50, color: Colors.purple),
                      const Text("VIP EXPERT GUESSING",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () => context.push('/vip'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white),
                          child: const Text("Unlock Now (Free Activation)")),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("TARGET NUMBERS",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontSize: 13,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 15),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 15,
                        runSpacing: 10,
                        children: numbers
                            .map((n) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: color.withValues(alpha: 0.4))),
                                  child: Text(n.toString(),
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: color)),
                                ))
                            .toList(),
                      ),
                      if (data['analysis'] != null &&
                          data['analysis'].toString().isNotEmpty) ...[
                        const Divider(height: 30),
                        Text(data['analysis'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic)),
                      ]
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildA4ResultPage(ResultModel result) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 850),
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ]),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(15),
                color: Colors.red.shade900,
                width: double.infinity,
                child: const Text("LOTTERY SAMBAD OFFICIAL RESULT",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold))),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(result.drawName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("Time: ${result.drawTime}\nDate: ${result.date}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold)),
                  const Divider(height: 30, thickness: 2),
                  if (result.imageUrl != null)
                    Image.network(result.imageUrl!, fit: BoxFit.contain),
                  const SizedBox(height: 30),
                  if (result.pdfUrl != null && result.pdfUrl!.isNotEmpty)
                    ElevatedButton.icon(
                        onPressed: () => _launchURL(result.pdfUrl),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("DOWNLOAD OFFICIAL PDF"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)))
                ]))
          ],
        ),
      ),
    );
  }

  Widget _buildPromoGallery(List<dynamic> homeAds) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: homeAds.isEmpty
                ? [const Text("No active ads")]
                : homeAds
                    .map((ad) => _promoItem(ad['title'] ?? '', ad['mediaUrl'],
                        link: ad['linkUrl']))
                    .toList()));
  }

  Widget _promoItem(String title, String? imageUrl, {String? link}) {
    return InkWell(
        onTap: () => _launchURL(link),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              Container(
                  width: 300,
                  height: 170,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl), fit: BoxFit.cover)
                          : null,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10)
                      ]),
                  child: imageUrl == null
                      ? const Icon(Icons.image, color: Colors.grey, size: 50)
                      : null),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
            ])));
  }

  Widget _navItem(String title, Color color, {VoidCallback? onTap}) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: ElevatedButton(
            onPressed: onTap ?? () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold))));
  }

  Widget _buildHeroButton(String text, Color color,
      {Color textColor = Colors.white, VoidCallback? onTap}) {
    return SizedBox(
        width: MediaQuery.of(context).size.width > 400 ? 320 : double.infinity,
        height: 60,
        child: ElevatedButton(
            onPressed: onTap ?? () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: textColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18))));
  }

  Widget _buildDetailedInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lottery Sambad Result",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Lottery Sambad today result. As you know, lottery sambad draw held three times a day. You may check your daily lottery result right over here. Lottery Sambad 1:00 PM, 6:00 PM & 8:00 PM result. Stay tuned to check daily lottery sambad result. Lottery sambad also dealing with the bumper lotteries as well. You can check here weekly Bi Monthly and Monthly lottery draws result right here on this page.",
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 30),
        _buildScheduleTable("1:00 PM Draw Schedule & Name", [
          ["Month", "Days", "Draw Names"],
          ["April 27 2026", "Monday", "Dear Dwarka"],
          ["April 28 2026", "Tuesday", "Dear Godavari"],
          ["April 29 2026", "Wednesday", "Dear Indus"],
          ["April 30 2026", "Thursday", "Dear Mahandi"],
          ["May 1 2026", "Friday", "Dear Meghna"],
          ["May 2 2026", "Saturday", "Dear Narmada"],
          ["", "Sunday", "Dear Yamuna"],
        ]),
        const SizedBox(height: 30),
        _buildScheduleTable("6:00 PM Draw Schedule & Name", [
          ["Date", "Days", "Draw Names"],
          ["April 27 2026", "Monday", "Dear Blitzen"],
          ["April 28 2026", "Tuesday", "Dear Comet"],
          ["April 29 2026", "Wednesday", "Dear Cupid"],
          ["April 30 2026", "Thursday", "Dear Dancer"],
          ["May 1 2026", "Friday", "Dear Dasher"],
          ["May 2 2026", "Saturday", "Dear Donner"],
          ["", "Sunday", "Dear Vixen"],
        ]),
        const SizedBox(height: 30),
        _buildScheduleTable("8:00 PM Draw Schedule & Name", [
          ["Date", "Days", "Draw Names"],
          ["April 27 2026", "Monday", "Dear Finch"],
          ["April 28 2026", "Tuesday", "Dear Goose"],
          ["April 29 2026", "Wednesday", "Dear Pelican"],
          ["April 30 2026", "Thursday", "Dear Sandpiper"],
          ["May 1 2026", "Friday", "SeaGull"],
          ["May 2 2026", "Saturday", "Dear Stork"],
          ["", "Sunday", "Dear Toucan"],
        ]),
        const SizedBox(height: 40),
        _infoSection("Sikkim state lotteries result today",
            "Sikkim lottery result today. Click on the link above to Download and view Sikkim lottery result online. Sikkim today lottery result PDF online."),
        _infoSection("Nagaland state lottery result today",
            "Nagaland lottery result today. Click on the link above to Download and view Nagaland state lotteries result online."),
        _infoSection("West bengal state lottery",
            "Check west Bengal state lottery today result 6:00 PM online. West bengal old as well as today lottery draw result will be updated here on this page."),
        const SizedBox(height: 40),
        const Text("FAQ",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _faqItem("Is Nagaland State lottery real?",
            "Yes its 100% real. Nagaland state lottery owned and regulate by the Nagaland and established in 1972."),
        _faqItem("How much time will it take to get money?",
            "It will take three days after submission of all required documents alongwith original winning ticket."),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            "Disclaimer: All information on this website is provided for general reference and informational purposes only.",
            style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _infoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
      ],
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Q: $question",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          const SizedBox(height: 5),
          Text("A: $answer", style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(String title, List<List<String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey.shade300),
            children: rows.asMap().entries.map((entry) {
              int idx = entry.key;
              List<String> cells = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: idx == 0 ? Colors.grey.shade200 : Colors.white,
                ),
                children: cells
                    .map((cell) => Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            cell,
                            style: TextStyle(
                              fontWeight: idx == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                        ))
                    .toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const Text('Lottery Sambad Information',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text('© 2024 Maahvi Lottery. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 16, color: Colors.black54),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _launchURL("mailto:maahvi.official@gmail.com"),
                child: const Text(
                  'maahvi.official@gmail.com',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Row(children: [
          Container(width: 6, height: 30, color: Colors.red.shade900),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          )
        ]));
  }
}
