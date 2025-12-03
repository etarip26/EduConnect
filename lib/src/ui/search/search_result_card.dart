import 'package:flutter/material.dart';
import 'package:test_app/src/core/widgets/app_avatar.dart';

class SearchResultCard extends StatelessWidget {
  final Map item;

  const SearchResultCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item["name"] ?? "Unknown";
    final subjects = (item["subjects"] ?? []).join(", ");
    final classLevel = item["classLevel"] ?? "";
    final city = item["location"]?["city"] ?? "";
    final salary = item["expectedSalaryMin"] != null
        ? "${item["expectedSalaryMin"]} - ${item["expectedSalaryMax"]}"
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          AppAvatar(name: name, radius: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),

                if (subjects.isNotEmpty)
                  Text(
                    "Subjects: $subjects",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                if (classLevel.isNotEmpty)
                  Text(
                    "Class Level: $classLevel",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                if (city.isNotEmpty)
                  Text(
                    "City: $city",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                if (salary.isNotEmpty)
                  Text(
                    "Salary: $salary BDT",
                    style: TextStyle(color: Colors.indigo.shade700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
