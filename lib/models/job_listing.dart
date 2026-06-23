class JobListing {
  final String title;
  final String company;
  final String? location;
  final String? salary;
  final String? url;
  final String? description;
  final String? postedAt;

  const JobListing({
    required this.title,
    required this.company,
    this.location,
    this.salary,
    this.url,
    this.description,
    this.postedAt,
  });

  factory JobListing.fromJson(Map<String, dynamic> json) => JobListing(
    title: json['title'] as String? ?? '',
    company: json['company'] as String? ?? '',
    location: json['location'] as String?,
    salary: json['salary'] as String?,
    url: json['url'] as String?,
    description: json['description'] as String?,
    postedAt: json['postedAt'] as String?,
  );

  String get timeAgo {
    if (postedAt == null) return 'Recently';
    final posted = DateTime.tryParse(postedAt!);
    if (posted == null) return 'Recently';
    final diff = DateTime.now().difference(posted);
    if (diff.inHours < 1) return 'Just now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return 'Over a week ago';
  }
}
