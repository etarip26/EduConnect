import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/matches_service.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/review_service.dart';

class MyMatchesTab extends StatefulWidget {
  const MyMatchesTab({super.key});

  @override
  State<MyMatchesTab> createState() => _MyMatchesTabState();
}

class _MyMatchesTabState extends State<MyMatchesTab> {
  final matchesService = GetIt.instance<MatchesService>();
  final reviewService = GetIt.instance<ReviewService>();
  final auth = GetIt.instance<AuthService>();

  bool loading = true;
  List matches = [];

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    setState(() => loading = true);
    try {
      final res = await matchesService.getMyMatches();
      setState(() => matches = res);
    } catch (e) {
      print("Error loading matches: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading matches: $e")),
        );
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : matches.isEmpty
            ? _emptyState()
            : RefreshIndicator(
                onRefresh: loadMatches,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (_, i) => _matchCard(matches[i]),
                ),
              );
  }

  Widget _matchCard(Map<String, dynamic> match) {
    final teacher = match['teacherId'] ?? {};
    final post = match['tuitionId'] ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Column(
        children: [
          // TEACHER INFO
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        (teacher['name']?.toString().toUpperCase()[0] ?? 'T'),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher['name'] ?? 'Teacher',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            teacher['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (teacher['phone'] != null)
                            Text(
                              teacher['phone'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // TUITION POST INFO
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'] ?? 'Tuition',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class: ${post['classLevel'] ?? ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (post['subjects'] is List && post['subjects'].isNotEmpty)
                        Text(
                          'Subjects: ${(post['subjects'] as List).join(", ")}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (post['salaryMin'] != null && post['salaryMax'] != null)
                        Text(
                          'Salary: ${post['salaryMin']} - ${post['salaryMax']} BDT',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showReviewDialog(match),
                    icon: const Icon(Icons.star),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDemoBookingDialog(match),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book Demo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(Map<String, dynamic> match) {
    final teacherId = match['teacherId']?['_id'] ?? match['teacherId'];
    final ratingController = TextEditingController();
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Review Teacher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rating:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    Icons.star,
                    color: i < selectedRating ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedRating = i + 1;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ratingController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await reviewService.addTeacherReview(
                  teacherId: teacherId,
                  rating: selectedRating,
                  comment: ratingController.text.trim(),
                  matchId: match['_id'],
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted successfully!')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showDemoBookingDialog(Map<String, dynamic> match) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Book Demo Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Select Date',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  dateController.text =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Select Time',
                prefixIcon: Icon(Icons.access_time),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  timeController.text =
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (dateController.text.isEmpty || timeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select date and time')),
                );
                return;
              }
              // TODO: Implement demo session booking API call
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo session booked! Teacher will confirm soon.'),
                ),
              );
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Matches Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find and apply for tuitions to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
