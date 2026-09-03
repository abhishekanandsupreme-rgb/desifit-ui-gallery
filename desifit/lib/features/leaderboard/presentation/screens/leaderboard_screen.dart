import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Leaderboard Data
    final List<Map<String, dynamic>> leaderboard = [
      {'rank': 1, 'name': 'Aman Sharma', 'status': 'Sattu Samrat', 'xp': 1240, 'isMe': false},
      {'rank': 2, 'name': 'Rahul Verma', 'status': 'Sattu Senapati', 'xp': 1050, 'isMe': false},
      {'rank': 3, 'name': 'Rohan Das (You)', 'status': 'Sattu Shishya', 'xp': 850, 'isMe': true},
      {'rank': 4, 'name': 'Karan Malhotra', 'status': 'Sattu Shishya', 'xp': 720, 'isMe': false},
      {'rank': 5, 'name': 'Vikram Singh', 'status': 'Jugaad Master', 'xp': 610, 'isMe': false},
      {'rank': 6, 'name': 'Amit Patel', 'status': 'Novice Cook', 'xp': 430, 'isMe': false},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jugaad Leaderboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Compete with hostel mates in budget gains.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // My Current Rank Card (Bento Style)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.emoji_events, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SATTU SHISHYA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Rohan Das',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '850 XP • Rank #3 of 42',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '+50 XP',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Ranking Title
            Text(
              'Top Sattu Samrats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Leaderboard List (No borders/dividers - background shifts)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                final bool isMe = user['isMe'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? AppColors.primary.withValues(alpha: 0.08) 
                        : (index % 2 == 0 ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(16),
                    border: isMe 
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Rank number
                      SizedBox(
                        width: 28,
                        child: Text(
                          '#${user['rank']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: user['rank'] <= 3 ? AppColors.primary : Colors.grey[500],
                          ),
                        ),
                      ),
                      // Avatar
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Icon(Icons.person, size: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // Name & Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              user['status'].toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // XP
                      Text(
                        '${user['xp']} XP',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
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
