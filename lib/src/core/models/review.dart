class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  final String id;
  final num rating;
  final String comment;
  final String reviewerName;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      rating: (json['rating'] ?? 0) as num,
      comment: (json['comment'] ?? '') as String,
      reviewerName: (json['reviewerName'] ?? '') as String,
    );
  }
}
