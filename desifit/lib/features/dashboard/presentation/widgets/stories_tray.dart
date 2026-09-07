import 'package:flutter/material.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/theme/theme.dart';
import '../screens/story_viewer_screen.dart';

/// Horizontal fitness-stories tray; tapping a story opens the viewer.
class StoriesTray extends StatelessWidget {
  final AppState state;
  const StoriesTray({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.translate('FITNESS STORIES'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.stories.length,
            itemBuilder: (context, idx) {
              final story = state.stories[idx];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Semantics(
                  button: true,
                  label: state.translate(
                    story.isRead ? 'Read fitness story: {title}' : 'Unread fitness story: {title}',
                    name: story.title,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryViewerScreen(initialIndex: idx),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: story.isRead
                                  ? [Colors.grey.shade400, Colors.grey.shade600]
                                  : [AppColors.primary, AppColors.primaryContainer],
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              story.avatarText,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: story.isRead ? Colors.grey : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
