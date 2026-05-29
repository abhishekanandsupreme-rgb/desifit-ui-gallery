import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/openrouter_service.dart';
import '../../../../core/ads/ad_service.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({Key? key}) : super(key: key);

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String _typingCoachName = '';

  @override
  void initState() {
    super.initState();
    AdService.loadRewardedAd();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(AppState state) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (state.isAiChatLimitReached) {
      _showRewardedAdModal(context, state);
      return;
    }

    _messageController.clear();
    state.addChatMessage(true, text, senderName: 'User');
    state.incrementAiChatCount();
    _scrollToBottom();

    // Select a random coach name
    final experts = ['Ravi', 'Amit', 'Joseph', 'Tom'];
    final randomExpert = (List<String>.from(experts)..shuffle()).first;

    setState(() {
      _isTyping = true;
      _typingCoachName = randomExpert;
    });

    // Random simulated network delay between 10 and 15 seconds to feel like a real human typing
    final randomDelaySeconds = 10 + Random().nextInt(6);
    await Future.delayed(Duration(seconds: randomDelaySeconds));

    // Get response from OpenRouter
    final reply = await OpenRouterService.getCoachResponse(state.chatHistory, expertName: randomExpert);

    if (mounted) {
      state.addChatMessage(false, reply, senderName: randomExpert);
      setState(() {
        _isTyping = false;
        _typingCoachName = '';
      });
      _scrollToBottom();
    }
  }

  void _showHireCoachDialog(BuildContext context) {
    final goalController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Hire a Personal Coach',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
              color: AppColors.primary,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get an elite coach assigned to you for weekly video calls, custom diet plans, and daily check-ins.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: goalController,
                    decoration: InputDecoration(
                      labelText: 'Your Fitness Goal (e.g., Fat Loss)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your fitness goal' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your contact number' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _showSuccessDialog(context);
                }
              },
              child: const Text(
                'Submit Request',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our senior personal coach will contact you within 24 hours to schedule your onboarding call.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Great', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportResponseDialog(BuildContext context, ChatMessage msg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Report AI Response?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Do you find this response inaccurate, inappropriate, or unsafe? Your feedback helps train our systems.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Log/simulate reporting to developer / database
                debugPrint('AI Response flagged: "${msg.message}" by sender ${msg.senderName}');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Thank you. This response has been reported for review.',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: const Text(
                'Report',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRewardedAdModal(BuildContext context, AppState state) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Premium Access',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Unlock Premium Expert Consultation by watching a quick video!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.4,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          AdService.showRewardedAd(
                            onUserEarnedReward: (reward) {
                              state.unlockAiChat();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Congratulations! Free expert messages unlocked!',
                                    style: TextStyle(fontFamily: 'Inter'),
                                  ),
                                  backgroundColor: AppColors.secondary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            onAdDismissed: () {},
                          );
                        },
                        child: const Text(
                          'WATCH VIDEO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpertAvatar(String name, {double radius = 16, double iconSize = 16}) {
    Color bgColor = Colors.grey;
    IconData icon = Icons.person;

    if (name == 'Ravi') {
      bgColor = const Color(0xFFA43700); // Saffron
      icon = Icons.fitness_center;
    } else if (name == 'Amit') {
      bgColor = const Color(0xFF1B6D24); // Leaf Green
      icon = Icons.restaurant_menu;
    } else if (name == 'Joseph') {
      bgColor = Colors.blue.shade800; // Calisthenics
      icon = Icons.accessibility_new;
    } else if (name == 'Tom') {
      bgColor = Colors.amber.shade800; // Fat Loss
      icon = Icons.flash_on;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }

  Color _getExpertColor(String name) {
    if (name == 'Ravi') return const Color(0xFFA43700);
    if (name == 'Amit') return const Color(0xFF1B6D24);
    if (name == 'Joseph') return Colors.blue.shade800;
    if (name == 'Tom') return Colors.amber.shade800;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // Auto-scroll on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Screen Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Chat with Experts',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'DesiFit Professional Fitness & Diet Panel',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                // Hire a Personal Coach Banner Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primaryContainer.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_ind_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hire a Personal Coach',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryContainer,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Get 1-on-1 personalized training, custom diets & weekly calls.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _showHireCoachDialog(context),
                        child: const Text(
                          'HIRE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // AI Disclaimer Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.translate('Guru Bheem says: This chat is powered by AI. Advice is for educational purposes only; consult a doctor before starting any physical program.'),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey[700],
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
              ],
            ),
          ),

          // Message Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: state.chatHistory.length,
              itemBuilder: (context, index) {
                final msg = state.chatHistory[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _buildExpertAvatar(_typingCoachName, radius: 12, iconSize: 12),
                    const SizedBox(width: 8),
                    Text(
                      '$_typingCoachName is typing...',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Input Deck
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 104.0, top: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(state),
                      decoration: const InputDecoration(
                        hintText: 'Ask experts about training, diets or tips...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: () => _sendMessage(state),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final bool isUser = msg.isUser;
    
    String roleTag = 'Fitness Expert';
    if (!isUser) {
      if (msg.senderName == 'Ravi') roleTag = 'Strength Coach';
      if (msg.senderName == 'Amit') roleTag = 'Dietitian';
      if (msg.senderName == 'Joseph') roleTag = 'Calisthenics Expert';
      if (msg.senderName == 'Tom') roleTag = 'Fat Loss Coach';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildExpertAvatar(msg.senderName),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${msg.senderName} • $roleTag',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant.withOpacity(0.8),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showReportResponseDialog(context, msg),
                          child: Icon(
                            Icons.flag_outlined,
                            size: 13,
                            color: AppColors.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surfaceContainerLow,
                    border: isUser
                        ? null
                        : Border(
                            bottom: BorderSide(
                              color: _getExpertColor(msg.senderName),
                              width: 2.5,
                            ),
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.onSurface,
                      fontSize: 14,
                      height: 1.4,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: Provider.of<AppState>(context, listen: false).currentUser?.photoUrl.isNotEmpty == true
                  ? NetworkImage(Provider.of<AppState>(context, listen: false).currentUser!.photoUrl)
                  : null,
              child: Provider.of<AppState>(context, listen: false).currentUser?.photoUrl.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person, color: AppColors.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}
