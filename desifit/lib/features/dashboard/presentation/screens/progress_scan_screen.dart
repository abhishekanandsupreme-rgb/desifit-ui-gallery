import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/network/analytics_service.dart';
import '../widgets/guest_prompt_widget.dart';

class ProgressScanScreen extends StatefulWidget {
  const ProgressScanScreen({super.key});

  @override
  State<ProgressScanScreen> createState() => _ProgressScanScreenState();
}

class _ProgressScanScreenState extends State<ProgressScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  ProgressPhoto? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logEvent('screen_view', {'screen_name': 'progress_scan'});
    
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScanning(AppState state) async {
    _scanController.repeat(reverse: true);
    
    // Simulate base64 image payload (using a premium silhouette mock)
    const mockBase64Image = 'silhouette_mock_data';
    
    await state.captureProgressPhoto(mockBase64Image);
    
    _scanController.stop();
    setState(() {
      _selectedPhoto = state.progressPhotos.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final photoList = state.progressPhotos;
    
    // Default to show latest photo in details
    if (_selectedPhoto == null && photoList.isNotEmpty) {
      _selectedPhoto = photoList.last;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Progress Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Silhouette & Laser Scan Simulator
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Silhouette Graphic
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: state.isAnalyzingPhoto ? 0.8 : 0.4,
                        child: const Icon(
                          Icons.accessibility_new_rounded,
                          size: 160,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      if (!state.isAnalyzingPhoto)
                        const Text(
                          'Ready for daily visual scan',
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),

                  // Laser scanning lines
                  if (state.isAnalyzingPhoto)
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 280),
                          painter: _ScanGridPainter(progress: _scanAnimation.value),
                        );
                      },
                    ),

                  // Blur & Scanning Indicator
                  if (state.isAnalyzingPhoto)
                    Container(
                      color: Colors.black.withValues(alpha: 0.1),
                      child: Center(
                        child: Card(
                          color: Colors.black.withValues(alpha: 0.75),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'AI ANALYZING BODY...',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scan Action Button
            ElevatedButton.icon(
              onPressed: state.isAnalyzingPhoto ? null : () => _startScanning(state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              label: Text(
                state.isAnalyzingPhoto ? 'COMPUTING AI METRICS...' : 'SIMULATE CAMERA PROGRESS SCAN',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),

            // Analysis Panel Detail
            if (_selectedPhoto != null) ...[
              Text(
                'AI ANALYSIS REPORT - ${_selectedPhoto!.dateStr.toUpperCase()}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 12),

              // Metrics Dashboard Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Body Fat',
                      '${_selectedPhoto!.bodyFat}%',
                      Icons.opacity,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Vascularity',
                      '${_selectedPhoto!.vascularity}/10',
                      Icons.bolt,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Symmetry',
                      '${_selectedPhoto!.symmetryScore}%',
                      Icons.scale_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      'Posture',
                      '${_selectedPhoto!.postureScore}%',
                      Icons.align_horizontal_center_rounded,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Coach Bheem Speech Bubble
              Text(
                'COACH BHEEM\'S FEEDBACK',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text('💪', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guru Bheem Says:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedPhoto!.feedback,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Photo Timeline History
            Text(
              'PROGRESS TIMELINE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 12),
            if (photoList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No photo logs found. Scan your first photo!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              SizedBox(
                height: 96,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: photoList.length,
                  itemBuilder: (context, idx) {
                    final photo = photoList[idx];
                    final isSelected = _selectedPhoto?.id == photo.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPhoto = photo;
                        });
                      },
                      onLongPress: () {
                        _showDeleteConfirm(context, state, photo.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant.withValues(alpha: 0.2),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.dateStr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Fat: ${photo.bodyFat}%',
                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      if (state.isGuest)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(24.0),
            child: const Center(
              child: GuestPromptWidget(
                title: '🔒 Unlock AI Progress Scanner',
                description: 'Scan your physique, track posture correctness, calculate symmetry metrics, and log your progress visuals over time. Sign in with Google to get started!',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Delete Photo?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this scan entry from your timeline?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                state.deleteProgressPhoto(id);
                Navigator.pop(context);
                setState(() {
                  _selectedPhoto = null;
                });
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter to draw laser grid scanning animation
class _ScanGridPainter extends CustomPainter {
  final double progress;

  _ScanGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.15)
      ..strokeWidth = 0.8;
    
    // Draw vertical grid lines
    final int cols = 8;
    final double colWidth = size.width / cols;
    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(
        Offset(i * colWidth, 0),
        Offset(i * colWidth, size.height),
        gridPaint,
      );
    }

    // Draw horizontal grid lines
    final int rows = 6;
    final double rowHeight = size.height / rows;
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, i * rowHeight),
        Offset(size.width, i * rowHeight),
        gridPaint,
      );
    }

    // Draw laser scan beam
    final double beamY = size.height * progress;
    final laserPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.5;
    
    final glowPaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.3)
      ..strokeWidth = 12.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(Offset(0, beamY), Offset(size.width, beamY), glowPaint);
    canvas.drawLine(Offset(0, beamY), Offset(size.width, beamY), laserPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
