import 'package:flutter_test/flutter_test.dart';
import 'package:career_pilot/services/jobapplication_service.dart';
import 'package:career_pilot/models/job_application.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late MockSupabaseHttpClient mockHttpClient;
  late SupabaseClient mockClient;
  late JobApplicationService service;
  const testUserId = 'test-user-123';

  final mockData1 = {
    'id': '1',
    'user_id': testUserId,
    'company_name': 'Tech Corp',
    'title': 'Software Engineer',
    'description': 'Great job',
    'job_link': 'https://example.com',
    'created_at': '2024-01-01T10:00:00Z',
    'application_status': 'applied',
  };
  final mockData2 = {
    'id': '2',
    'user_id': testUserId,
    'company_name': 'Startup Inc',
    'title': 'Backend Developer',
    'description': 'Cool startup',
    'job_link': 'https://startup.com',
    'created_at': '2024-01-02T10:00:00Z',
    'application_status': 'interview',
  };

  setUp(() {
    mockHttpClient = MockSupabaseHttpClient();
    mockClient = SupabaseClient(
      'https://test.supabase.co',
      'test-anon-key',
      httpClient: mockHttpClient,
    );
    service = JobApplicationService(
      client: mockClient,
      userIdProvider: () => testUserId,
    );
  });

  tearDown(() {
    mockHttpClient.reset();
  });

  group('Cache Behavior', () {
    test('initial cache is null', () async {
      await mockClient.from('job_applications').insert(mockData1);
      final apps = await service.applications;
      expect(apps, hasLength(1));
    });

    test('cache is populated after first fetch', () async {
      await mockClient.from('job_applications').insert(mockData1);
      
      final apps = await service.applications;
      expect(apps, hasLength(1));
      expect(apps.first.companyName, 'Tech Corp');
    });

    test('subsequent access returns cached data without DB hit', () async {
      await mockClient.from('job_applications').insert(mockData1);
      
      final firstFetch = await service.applications;
      
      await mockClient.from('job_applications').insert(mockData2);
      
      final secondFetch = await service.applications;

      expect(firstFetch.length, 1);
      expect(secondFetch.length, 1);
    });

    test('refresh() fetches new data from database', () async {
      await mockClient.from('job_applications').insert(mockData1);
      await service.applications;
      expect((await service.applications).first.companyName, 'Tech Corp');

      await mockClient
          .from('job_applications')
          .update({'company_name': 'Tech Corp Updated'})
          .eq('id', '1');
      
      await service.refresh();
      
      expect((await service.applications).first.companyName, 'Tech Corp Updated');
    });

    test('resetCache clears cache forcing next access to fetch', () async {
      await mockClient.from('job_applications').insert(mockData1);
      await service.applications;
      
      service.resetCache();
      
      await mockClient.from('job_applications').insert(mockData2);
      
      final apps = await service.applications;
      expect(apps, hasLength(2));
    });
  });

  group('Fetching Applications', () {
    test('successful fetch returns list of applications', () async {
      await mockClient.from('job_applications').insert([mockData1, mockData2]);
      final applications = await service.applications;
      expect(applications, hasLength(2));
      expect(applications.any((app) => app.companyName == 'Tech Corp'), isTrue);
      expect(applications.any((app) => app.companyName == 'Startup Inc'), isTrue);
    });

    test('empty response returns empty list', () async {
      final applications = await service.applications;
      expect(applications, isEmpty);
    });

    test('returns immutable list', () async {
      await mockClient.from('job_applications').insert(mockData1);
      final applications = await service.applications;
      
      expect(
        () => applications.add(
          JobApplication(
            id: '999',
            userId: testUserId,
            companyName: 'Test',
            title: 'Test',
            description: 'Test',
            jobLink: 'https://test.com',
            createdAt: DateTime.now(),
            applicationStatus: 'applied',
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('Adding Applications', () {
    test('successfully adds application and updates cache', () async {
      final newApp = JobApplication(
        id: '',
        userId: testUserId,
        companyName: 'New Corp',
        title: 'Developer',
        description: 'New job',
        jobLink: 'https://new.com',
        createdAt: DateTime.now(),
        applicationStatus: 'not applied',
      );

      final mockInsertData = {
        'id': '3',
        'user_id': testUserId,
        'company_name': 'New Corp',
        'title': 'Developer',
        'description': 'New job',
        'job_link': 'https://new.com',
        'created_at': newApp.createdAt.toIso8601String(),
        'application_status': 'not applied',
      };
      
      await mockClient.from('job_applications').insert(mockInsertData);
      
      final apps = await service.applications;
      expect(apps, hasLength(1));
      expect(apps.first.companyName, 'New Corp');

      final dbData = await mockClient
          .from('job_applications')
          .select()
          .eq('company_name', 'New Corp');
      expect(dbData, hasLength(1));
      expect(dbData.first['company_name'], 'New Corp');
    });

    test('adds application to beginning of cached list', () async {
      await mockClient.from('job_applications').insert(mockData1);
      await service.applications;

      final newAppData = {
        'id': '3',
        'user_id': testUserId,
        'company_name': 'Newest Corp',
        'title': 'Developer',
        'description': 'Newest job',
        'job_link': 'https://newest.com',
        'created_at': DateTime.now().toIso8601String(),
        'application_status': 'not applied',
      };

      await mockClient.from('job_applications').insert(newAppData);
      
      await service.refresh();

      final cachedApps = await service.applications;
      expect(cachedApps, hasLength(2));
      expect(cachedApps.any((app) => app.companyName == 'Newest Corp'), isTrue);
      expect(cachedApps.any((app) => app.companyName == 'Tech Corp'), isTrue);
    });

    test('adding when cache is null does not crash', () async {
      final newAppData = {
        'id': '3',
        'user_id': testUserId,
        'company_name': 'New Corp',
        'title': 'Developer',
        'description': 'New job',
        'job_link': 'https://new.com',
        'created_at': DateTime.now().toIso8601String(),
        'application_status': 'not applied',
      };

      await mockClient.from('job_applications').insert(newAppData);

      final dbData = await mockClient
          .from('job_applications')
          .select()
          .eq('company_name', 'New Corp');
      expect(dbData, hasLength(1));
    });
  });

  group('Deleting Applications', () {
    test('successfully deletes application and removes from cache', () async {
      await mockClient.from('job_applications').insert([mockData1, mockData2]);
      await service.applications;
      
      final cachedBefore = await service.applications;
      expect(cachedBefore, hasLength(2));

      await service.deleteApplication('1');

      final cachedAfter = await service.applications;
      expect(cachedAfter, hasLength(1));
      expect(cachedAfter.first.id, '2');

      final dbData = await mockClient.from('job_applications').select();
      expect(dbData, hasLength(1));
      expect(dbData.first['id'], '2');
    });

    test('deleting when cache is null does not crash', () async {
      await mockClient.from('job_applications').insert(mockData1);

      await service.deleteApplication('1');

      final dbData = await mockClient.from('job_applications').select();
      expect(dbData, isEmpty);
    });

    test('deletes correct application from cache', () async {
      await mockClient.from('job_applications').insert([mockData1, mockData2]);
      await service.applications;

      await service.deleteApplication('2');

      final cachedApps = await service.applications;
      expect(cachedApps, hasLength(1));
      expect(cachedApps.first.id, '1');
      expect(cachedApps.first.companyName, 'Tech Corp');
    });
  });

  group('Error Handling', () {
    setUp(() {
      mockHttpClient = MockSupabaseHttpClient(
        postgrestExceptionTrigger: (schema, table, data, type) {
          if (table == 'job_applications') {
            if (type == RequestType.select) {
              throw const PostgrestException(message: 'Select failed');
            }
            if (type == RequestType.insert) {
              throw const PostgrestException(message: 'Insert failed');
            }
            if (type == RequestType.delete) {
              throw const PostgrestException(message: 'Delete failed');
            }
          }
        },
      );
      mockClient = SupabaseClient(
        'https://test.supabase.co',
        'test-anon-key',
        httpClient: mockHttpClient,
      );
      service = JobApplicationService(
        client: mockClient,
        userIdProvider: () => testUserId,
      );
    });

    test('fetch throws error on Supabase failure', () async {
      expect(
        () => service.applications,
        throwsA(isA<PostgrestException>()),
      );
    });

    test('refresh throws error on Supabase failure', () async {
      expect(
        () => service.refresh(),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('add throws error on Supabase failure', () async {
      final newApp = JobApplication(
        id: '1',
        userId: testUserId,
        companyName: 'Tech Corp',
        title: 'Software Engineer',
        description: 'Great job',
        jobLink: 'https://example.com',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        applicationStatus: 'applied',
      );
      expect(
        () => service.addApplication(newApp),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('delete throws error on Supabase failure', () async {
      expect(
        () => service.deleteApplication('1'),
        throwsA(isA<PostgrestException>()),
      );
    });
  });
}

