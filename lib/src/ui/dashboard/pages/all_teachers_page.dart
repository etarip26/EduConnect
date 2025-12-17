import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllTeachersPage extends StatefulWidget {
  const AllTeachersPage({Key? key}) : super(key: key);

  @override
  State<AllTeachersPage> createState() => _AllTeachersPageState();
}

class _AllTeachersPageState extends State<AllTeachersPage> {
  List<dynamic> teachers = [];
  List<dynamic> filteredTeachers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'rating'; // rating, name, experience

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      setState(() => _isLoading = true);
      // For now, return empty list - backend doesn't have getTeachers endpoint
      // In production, fetch from: GET /api/teachers or similar
      setState(() {
        teachers = [];
        filteredTeachers = [];
        _isLoading = false;
        _sortTeachers();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading teachers: $e')));
    }
  }

  void _filterTeachers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        filteredTeachers = teachers;
      } else {
        filteredTeachers = teachers
            .where(
              (teacher) =>
                  (teacher['fullName'] ?? '').toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  (teacher['subjects'] ?? []).toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
      _sortTeachers();
    });
  }

  void _sortTeachers() {
    switch (_sortBy) {
      case 'name':
        filteredTeachers.sort(
          (a, b) => (a['fullName'] ?? '').compareTo(b['fullName'] ?? ''),
        );
        break;
      case 'experience':
        filteredTeachers.sort(
          (a, b) => (b['yearsOfExperience'] ?? 0).compareTo(
            a['yearsOfExperience'] ?? 0,
          ),
        );
        break;
      case 'rating':
      default:
        filteredTeachers.sort(
          (a, b) =>
              (b['averageRating'] ?? 0).compareTo(a['averageRating'] ?? 0),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Teachers'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _filterTeachers,
                    decoration: InputDecoration(
                      hintText: 'Search by name or subject...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                // Sort options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Sort by:',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              label: Text('Rating'),
                              value: 'rating',
                            ),
                            ButtonSegment(label: Text('Name'), value: 'name'),
                            ButtonSegment(
                              label: Text('Experience'),
                              value: 'experience',
                            ),
                          ],
                          selected: {_sortBy},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _sortBy = newSelection.first;
                              _sortTeachers();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Teachers list
                if (filteredTeachers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No teachers available'
                                : 'No teachers found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: filteredTeachers.length,
                      itemBuilder: (context, index) {
                        final teacher = filteredTeachers[index];
                        return _buildTeacherCard(teacher);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final name = teacher['fullName'] ?? 'Unknown';
    final avatar = teacher['profilePicture'] ?? '';
    final rating = (teacher['averageRating'] ?? 0.0).toDouble();
    final experience = teacher['yearsOfExperience'] ?? 0;
    final subjects = (teacher['subjects'] as List?)?.join(', ') ?? '';

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to teacher profile
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('View $name profile')));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Experience
              if (experience > 0)
                Text(
                  '$experience yrs exp',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              // Subjects
              if (subjects.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      subjects,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                ),
              // Message button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.mail, size: 14),
                  label: const Text('Message', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Message $name')));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
