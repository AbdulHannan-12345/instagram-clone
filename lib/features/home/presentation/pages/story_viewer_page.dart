import 'package:flutter/material.dart';
import 'package:flutter_test_app/features/home/domain/entities/story_entity.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class StoryViewerPage extends StatefulWidget {
  final List<StoryEntity> stories;

  const StoryViewerPage({super.key, required this.stories});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  Timer? _timer;
  double _progress = 0.0;
  int _currentStoryIndex = 0;
  late AnimationController _imageAnimationController;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _imageAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.01; // 5 seconds total
          // Auto-advance when timer completes
          if (_progress >= 1.0) {
            timer.cancel();
            _nextStory();
          }
        });
      }
    });
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      _animateToStory(_currentStoryIndex + 1);
    } else {
      _timer?.cancel();
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      _animateToStory(_currentStoryIndex - 1);
    }
  }

  void _animateToStory(int index) {
    _imageAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _currentStoryIndex = index;
      });
      _startTimer();
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final currentStory = widget.stories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            // Tap on left side - previous story
            _previousStory();
          } else {
            // Tap on right side - next story
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Story Image with Fade Animation
            FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _imageAnimationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: currentStory.imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Center(
                    child: Icon(
                      Icons.photo,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.photo,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),

            // Static Header - Profile and Progress Bars
            SafeArea(
              child: Column(
                children: [
                  // Progress bars for all stories
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: List.generate(
                        widget.stories.length,
                        (i) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            child: LinearProgressIndicator(
                              value: i < _currentStoryIndex
                                  ? 1.0
                                  : (i == _currentStoryIndex ? _progress : 0.0),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // User info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: currentStory.userImage,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: imageProvider,
                              ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStory.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _getTimeAgo(currentStory.createdAt),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
