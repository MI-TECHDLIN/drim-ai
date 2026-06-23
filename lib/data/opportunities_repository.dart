import '../core/app_config.dart';
import '../core/supabase_client.dart';
import '../models/job_listing.dart';

class OpportunitiesRepository {
  Future<List<JobListing>> fetchJobs(String jobTitle) async {
    if (!AppConfig.isConfigured) return _fallback(jobTitle);

    try {
      final response = await supabase.functions.invoke(
        'fetch-opportunities',
        body: {'jobTitle': jobTitle},
      );

      if (response.data == null) return _fallback(jobTitle);

      final data = response.data as Map<String, dynamic>;
      final listingsJson = data['listings'] as List<dynamic>;

      return listingsJson
          .map((e) => JobListing.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _fallback(jobTitle);
    }
  }

  List<JobListing> _fallback(String jobTitle) {
    final now = DateTime.now();
    return [
      JobListing(
        title: 'Senior $jobTitle',
        company: 'TechFlow Systems',
        location: 'Remote / London',
        salary: '£55k – 70k',
        url: 'https://www.linkedin.com/jobs',
        description: 'Join our team to build products used by millions.',
        postedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      JobListing(
        title: jobTitle,
        company: 'Creative Pulse',
        location: 'Manchester, UK',
        salary: '£40k – 50k',
        url: 'https://www.linkedin.com/jobs',
        description:
            'Award-winning team looking for a passionate professional.',
        postedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
      ),
      JobListing(
        title: 'Junior $jobTitle',
        company: 'Fintech Hub',
        location: 'Lagos, Nigeria',
        salary: '₦800k – 1.2M',
        url: 'https://www.linkedin.com/jobs',
        description: 'Growing fintech team looking for talented individuals.',
        postedAt: now.subtract(const Duration(hours: 24)).toIso8601String(),
      ),
    ];
  }
}
