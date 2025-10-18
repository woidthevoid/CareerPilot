# CareerPilot AI Coding Guidelines

## Project Overview
CareerPilot is a Flutter job application tracker that helps users manage their job search. The app uses Supabase for authentication and database operations, targeting iOS/macOS platforms with Material Design using FlexColorScheme.

## Architecture Patterns

### State Management
- **Provider Pattern**: Uses `ChangeNotifierProvider` for state management
- **Two main providers**: `JobApplicationsProvider` and `UserProfileProvider` in `/lib/services/`
- **Provider setup**: Both providers are initialized in `main.dart` via `MultiProvider`
- **State access**: Use `context.read<Provider>()` for actions, `Consumer<Provider>` for UI updates

### Navigation & Authentication
- **GoRouter**: Declarative routing with authentication guards in `main.dart`
- **Auth flow**: Automatic redirects based on `Supabase.instance.client.auth.currentSession`
- **Routes**: `/login` → `/dashboard` flow with session-based redirects
- **Logout pattern**: Call `Supabase.instance.client.auth.signOut()` then reset providers

### Data Layer
- **Supabase client**: Direct database operations via `SupabaseClient` in providers
- **Models**: Simple data classes in `/lib/models/` (no serialization methods)
- **Tables**: `job_applications` and `profiles` with user_id foreign keys
- **Error handling**: Providers expose `errorMessage` and `isLoading` states

## Key Conventions

### File Organization
```
lib/
├── main.dart                    # App entry point, routing, theme
├── models/                      # Data models (JobApplication, UserProfile)
├── screens/                     # Full-screen views
├── services/                    # Provider classes for state management
└── widgets/                     # Reusable UI components
```

### Provider Pattern Implementation
- **Lazy loading**: Providers fetch data only once with `hasInitiallyFetched` flag
- **Refresh pattern**: Expose both `fetch()` and `refresh()` methods
- **Reset pattern**: Providers have `reset()` method for logout cleanup
- **Error states**: Use `_setError()` helper to update error state and notify listeners

### UI Patterns
- **Theme**: FlexColorScheme with indigo scheme (`FlexScheme.indigo`)
- **Loading states**: Show `CircularProgressIndicator` with descriptive text
- **Cards**: Use Material Card widgets with rounded corners and elevation
- **Dialogs**: Material AlertDialog with warning icons for destructive actions
- **Status indicators**: Color-coded status chips with icons (`_getStatusColor()`, `_getStatusIcon()`)

### Database Patterns
- **Supabase queries**: Use `.select()`, `.insert()`, `.delete()` with explicit column names
- **User context**: Always filter by current user: `.eq('user_id', user.id)`
- **DateTime handling**: Store as ISO strings, parse with `DateTime.tryParse()`
- **Error handling**: Wrap Supabase calls in try-catch, set provider error state

## Development Workflow

### Adding New Features
1. **Models**: Create data class in `/lib/models/`
2. **Provider**: Add provider in `/lib/services/` following the established pattern
3. **UI**: Create widgets in `/lib/widgets/` or screens in `/lib/screens/`
4. **Integration**: Wire up in `main.dart` MultiProvider if needed

### Common Operations
- **New screens**: Add GoRoute in `main.dart` router configuration
- **Supabase operations**: Use existing provider patterns with proper error handling
- **External links**: Use `url_launcher` package with `canLaunchUrl` checks
- **Date formatting**: Use `intl` package for consistent date display

### Testing Considerations
- **Mockito**: Available for mocking (`mockito: ^5.5.1`)
- **Test structure**: Tests in `/test/` directory (models and services subdirectories exist)
- **Provider testing**: Mock Supabase client, test state changes and error conditions

## Critical Dependencies
- `supabase_flutter`: Primary backend integration
- `provider`: State management
- `go_router`: Navigation with auth guards
- `flex_color_scheme`: Consistent theming
- `url_launcher`: External link handling

## Platform Specifics
- **Target platforms**: iOS and macOS (Android support exists but not primary focus)
- **Icons**: Uses Cupertino icons for iOS-style interface
- **Material + Cupertino**: Hybrid approach with Material components but iOS-appropriate styling