import 'package:flutter/material.dart';
import 'package:test_app/src/core/services/review_service.dart';
import 'package:get_it/get_it.dart';

class ReviewsPage extends StatefulWidget {
  final String? teacherId;
  final String? teacherName;
  final String? teacherAvatar;

  const ReviewsPage({
    Key? key,
    this.teacherId,
    this.teacherName,
    this.teacherAvatar,
  }) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late ReviewService _reviewService;
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic> ratingStats = {'averageRating': 0.0, 'totalReviews': 0};
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _reviewService = ReviewService(apiClient: GetIt.instance());
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (widget.teacherId != null) {
        // Viewing other teacher's reviews
        final teacherReviews = await _reviewService.getTeacherReviews(
          widget.teacherId!,
        );
        final rating = await _reviewService.getTeacherRating(widget.teacherId!);

        setState(() {
          reviews = teacherReviews;
          ratingStats = rating;
          _isLoading = false;
        });
      } else {
        // Viewing my reviews received (as teacher)
        final myReviews = await _reviewService.getMyReceivedReviews();
        setState(() {
          reviews = myReviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reviews: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showLeaveReviewDialog() async {
    if (widget.teacherId == null) return;

    final ratingController = TextEditingController();
    final commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Leave a Review for ${widget.teacherName ?? 'Teacher'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rating stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating.round()
                            ? Icons.star
                            : Icons.star_outline,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 12),
                Text(
                  'Rating: ${rating.round()} / 5',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                // Comment field
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this teacher...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please add a comment')),
                  );
                  return;
                }

                try {
                  await _reviewService.addTeacherReview(
                    teacherId: widget.teacherId!,
                    rating: rating.toInt(),
                    comment: commentController.text.trim(),
                  );

                  Navigator.pop(context);
                  setState(() => _hasReviewed = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review submitted successfully!')),
                  );
                  _loadReviews();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.teacherId != null
              ? '${widget.teacherName} - Reviews'
              : 'My Reviews Received',
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, textAlign: TextAlign.center))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Rating summary for viewing teacher reviews
                  if (widget.teacherId != null) ...[
                    Container(
                      width: double.infinity,
                      color: Colors.blue.shade50,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Average rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...List.generate(5, (index) {
                                final avgRating =
                                    ratingStats['averageRating']?.toDouble() ??
                                    0.0;
                                return Icon(
                                  index < avgRating.round()
                                      ? Icons.star
                                      : Icons.star_outline,
                                  color: Colors.amber,
                                  size: 24,
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${ratingStats['averageRating']?.toStringAsFixed(1) ?? '0.0'} out of 5',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${ratingStats['totalReviews'] ?? 0} reviews',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 12),
                          if (!_hasReviewed)
                            ElevatedButton.icon(
                              icon: Icon(Icons.rate_review),
                              label: Text('Leave a Review'),
                              onPressed: _showLeaveReviewDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  // Reviews list
                  if (reviews.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            widget.teacherId != null
                                ? 'No reviews yet'
                                : 'No reviews received yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        final rating = review['rating'] ?? 0;
                        final comment = review['comment'] ?? '';
                        final createdAt = review['createdAt'] ?? '';
                        final studentName =
                            review['studentName'] ??
                            review['student']?['fullName'] ??
                            'Student';
                        final studentAvatar =
                            review['student']?['profilePicture'] ?? '';

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Reviewer info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: studentAvatar.isNotEmpty
                                          ? NetworkImage(studentAvatar)
                                          : null,
                                      child: studentAvatar.isEmpty
                                          ? Icon(Icons.person)
                                          : null,
                                      radius: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (createdAt.isNotEmpty)
                                            Text(
                                              _formatDate(createdAt),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Rating stars
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < rating
                                          ? Icons.star
                                          : Icons.star_outline,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                                SizedBox(height: 8),
                                // Comment
                                Text(
                                  comment,
                                  style: TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          return '${diff.inMinutes} minutes ago';
        }
        return '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
