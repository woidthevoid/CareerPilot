import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:career_pilot/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, AuthResponse, User, Session])
void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late AuthService authService;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(mockClient.auth).thenReturn(mockAuth);
    authService = AuthService(client: mockClient);
  });

  group('AuthService - Sign In', () {
    test('returns null on successful login', () async {
      final mockUser = MockUser();
      final mockSession = MockSession();
      final mockResponse = MockAuthResponse();

      when(mockResponse.user).thenReturn(mockUser);
      when(mockResponse.session).thenReturn(mockSession);
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockResponse);

      final result = await authService.signIn('test@example.com', 'test123');

      expect(result, isNull);
      verify(mockAuth.signInWithPassword(
        email: 'test@example.com',
        password: 'test123',
      )).called(1);
    });

    test('returns "Login failed" when user is null', () async {
      final mockResponse = MockAuthResponse();
      when(mockResponse.user).thenReturn(null);
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockResponse);

      final result = await authService.signIn('test@example.com', 'test123');

      expect(result, 'Login failed');
    });

    test('returns error message on AuthException', () async {
      const errorMessage = 'Invalid login credentials';
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(AuthException(errorMessage));

      final result = await authService.signIn('wrong@example.com', 'wrongpass');

      expect(result, errorMessage);
    });

    test('returns generic error on unexpected exception', () async {
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Network error'));

      final result = await authService.signIn('test@example.com', 'test123');

      expect(result, startsWith('Unexpected error:'));
    });

    test('handles empty email', () async {
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(AuthException('Email is required'));

      final result = await authService.signIn('', 'password123');

      expect(result, 'Email is required');
    });

    test('handles empty password', () async {
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(AuthException('Password is required'));

      final result = await authService.signIn('test@example.com', '');

      expect(result, 'Password is required');
    });
  });

  group('AuthService - Sign Out', () {
    test('successfully signs out', () async {
      when(mockAuth.signOut()).thenAnswer((_) async => Future.value());

      await authService.signOut();

      verify(mockAuth.signOut()).called(1);
    });

    test('throws exception on sign out error', () async {
      when(mockAuth.signOut()).thenThrow(Exception('Network error'));

      expect(
        () => authService.signOut(),
        throwsException,
      );
    });
  });

  group('AuthService - Error Handling', () {
    test('differentiates between AuthException and general Exception',
        () async {
      when(mockAuth.signInWithPassword(
        email: 'auth@example.com',
        password: 'pass',
      )).thenThrow(AuthException('Auth specific error'));

      final authResult = await authService.signIn('auth@example.com', 'pass');
      expect(authResult, 'Auth specific error');

      when(mockAuth.signInWithPassword(
        email: 'general@example.com',
        password: 'pass',
      )).thenThrow(Exception('General error'));

      final generalResult =
          await authService.signIn('general@example.com', 'pass');
      expect(generalResult, contains('Unexpected error:'));
    });

    test('handles multiple consecutive errors', () async {
      when(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(AuthException('First error'));

      final result1 = await authService.signIn('test@example.com', 'test123');
      final result2 = await authService.signIn('test@example.com', 'test123');

      expect(result1, 'First error');
      expect(result2, 'First error');
      verify(mockAuth.signInWithPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(2);
    });
  });
}
