import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test_app/features/home/domain/entities/post_entity.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_bloc.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_event.dart';
import 'package:flutter_test_app/features/home/presentation/widgets/comments_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class PostWidget extends StatefulWidget {
  final PostEntity post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  void initState() {
    super.initState();
  }

  String _getTimeAgo(String createdAtString) {
    if (createdAtString.isEmpty) {
      return 'now';
    }

    try {
      final createdAt = DateTime.parse(createdAtString);
      return timeago.format(createdAt, locale: 'en_short');
    } catch (e) {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        SizedBox(
          width: double.infinity,
          height: 400,
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  fit: BoxFit.cover,
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

              // Header Overlay
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.post.userImage,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ✅ Flexible instead of Expanded
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'posted ${_getTimeAgo(widget.post.createdAt.toIso8601String())}',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), // Post Image
        // Actions
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const SizedBox.shrink();
            }

            final currentUserId = authState.user.uid;
            final isLiked = widget.post.likes.contains(currentUserId);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      context.read<PostBloc>().add(
                        LikePostEvent(
                          postId: widget.post.id,
                          userId: currentUserId,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            CommentsBottomSheet(post: widget.post),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        // Likes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${widget.post.likes.length} likes',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 4),
        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' ${widget.post.description}',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Comments Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CommentsBottomSheet(post: widget.post),
              );
            },
            child: Text(
              widget.post.comments.isEmpty
                  ? 'Be the first to comment'
                  : 'View all ${widget.post.comments.length} comments',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
