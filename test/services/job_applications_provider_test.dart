import 'package:flutter_test/flutter_test.dart';
import 'package:CareerPilot/services/job_applications_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';

void main() {
  late JobApplicationsProvider provider;
  late SupabaseClient mockClient;
  late MockSupabaseHttpClient mockHttpClient;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();

    mockClient = SupabaseClient(
      'https://test.supabase.co',
      'test-anon-key',
      httpClient: mockHttpClient,
    );
  });

   setUp(() {
    provider = JobApplicationsProvider(client: mockClient);
  });

  tearDown(() {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('fetchJobApplications', () {
        test('successfully fetches and parses applications to JobApplication model', () async {
      // Arrange - Insert mock data into mock Supabase database
      // This simulates the data that exists in the 'job_applications' table
      await mockClient.from('job_applications').insert([
        {
          'id': '1',
          'user_id': 'user-123',
          'company_name': 'Tech Corp',
          'title': 'Software Engineer',
          'description': 'Develop software solutions.',
          'job_link': 'https://techcorp.com/jobs/1',
          'created_at': '2024-10-17T10:00:00Z',
          'application_status': 'applied',
        },
        {
          'id': '2',
          'user_id': 'user-123',
          'company_name': 'Biz Inc',
          'title': 'Product Manager',
          'description': 'Manage product lifecycle.',
          'job_link': 'https://bizinc.com/careers/pm',
          'created_at': '2024-10-16T09:30:00Z',
          'application_status': 'interviewing',
        },
      ]);

      // Act - Call provider's fetchApplications method
      await provider.fetchApplications();

      // Assert - Verify applications parsed correctly to JobApplication model
      expect(provider.applications.length, 2);
      
      // Verify first application fields
      expect(provider.applications[0].id, '1');
      expect(provider.applications[0].title, 'Software Engineer');
      expect(provider.applications[0].companyName, 'Tech Corp');
      expect(provider.applications[0].description, 'Develop software solutions.');
      expect(provider.applications[0].jobLink, 'https://techcorp.com/jobs/1');
      expect(provider.applications[0].applicationStatus, 'applied');
      
      // Verify second application fields
      expect(provider.applications[1].id, '2');
      expect(provider.applications[1].title, 'Product Manager');
      expect(provider.applications[1].companyName, 'Biz Inc');
      expect(provider.applications[1].applicationStatus, 'interviewing');

      // Verify provider state flags following lazy loading pattern
      expect(provider.hasInitiallyFetched, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasData, isTrue);
    });
  });

  group('deleteApplication', () {
    test('Delete application based on id', () async {
      await mockClient.from('job_applications').insert([
        {
          'id': '1',
          'user_id': 'user-123',
          'company_name': 'Tech Corp',
          'title': 'Software Engineer',
          'description': 'Develop software solutions.',
          'job_link': 'https://techcorp.com/jobs/1',
          'created_at': '2024-10-17T10:00:00Z',
          'application_status': 'applied',
        }
      ]);

      await provider.fetchApplications();
      await provider.deleteApplication('1');

      expect(provider.errorMessage, isNull);
      expect(provider.applications.length, equals(0));
    });

    test('Try to delete non-existing application', () async {
      await mockClient.from('job_applications').insert([
        {
          'id': '1',
          'user_id': 'user-123',
          'company_name': 'Tech Corp',
          'title': 'Software Engineer',
          'description': 'Develop software solutions.',
          'job_link': 'https://techcorp.com/jobs/1',
          'created_at': '2024-10-17T10:00:00Z',
          'application_status': 'applied',
        }
      ]);

      await provider.fetchApplications();
      await provider.deleteApplication('5');

      expect(provider.applications.length, equals(1));
    });

    test('Handle network errors during deletion', () async {
      await mockClient.from('job_applications').insert([
        {
          'id': '1',
          'user_id': 'user-123',
          'company_name': 'Tech Corp',
          'title': 'Software Engineer',
          'description': 'Develop software solutions.',
          'job_link': 'https://techcorp.com/jobs/1',
          'created_at': '2024-10-17T10:00:00Z',
          'application_status': 'applied',
        }
      ]);

      await provider.fetchApplications();

      mockHttpClient.reset();

      await provider.deleteApplication('1');

      expect(provider.errorMessage, isNotNull);
      expect(provider.applications.length, equals(1));
    });
  });
}