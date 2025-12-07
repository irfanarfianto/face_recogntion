# Developer Guide - Face Recognition Attendance System

## 📋 Daftar Isi
1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [Development Workflow](#development-workflow)
4. [Best Practices](#best-practices)
5. [Testing](#testing)
6. [Debugging](#debugging)
7. [Performance Optimization](#performance-optimization)
8. [Contributing](#contributing)

---

## 🚀 Getting Started

### Development Environment Setup

#### 1. Install Flutter
```bash
# Download Flutter SDK dari flutter.dev
# Extract dan tambahkan ke PATH

# Verify installation
flutter doctor
```

#### 2. IDE Setup

**VS Code (Recommended)**
```bash
# Install extensions
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

**Android Studio**
- Install Flutter plugin
- Install Dart plugin

#### 3. Clone & Setup
```bash
git clone <repo-url>
cd test_face_recognition
flutter pub get
```

#### 4. Run Development Server
```bash
# Hot reload enabled
flutter run

# Specific device
flutter run -d <device-id>

# Debug mode dengan verbose
flutter run -v
```

---

## 📁 Project Structure

### Clean Architecture Layers

```
lib/
├── core/                           # Shared utilities
│   ├── error/
│   │   └── failures.dart          # Error abstraction
│   ├── theme/
│   │   └── app_theme.dart         # App theming
│   └── utils/
│       └── ml_kit_utils.dart      # ML Kit helpers
│
├── features/
│   └── attendance/
│       ├── data/                   # Data Layer
│       │   ├── datasources/
│       │   │   ├── attendance_remote_data_source.dart
│       │   │   └── face_local_data_source.dart
│       │   ├── models/
│       │   │   ├── attendance_log_model.dart
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── attendance_repository_impl.dart
│       │
│       ├── domain/                 # Domain Layer
│       │   ├── entities/
│       │   │   ├── attendance_log_entity.dart
│       │   │   └── user_entity.dart
│       │   ├── repositories/
│       │   │   └── attendance_repository.dart
│       │   └── usecases/
│       │       ├── authenticate_user.dart
│       │       ├── register_user.dart
│       │       └── ...
│       │
│       └── presentation/           # Presentation Layer
│           ├── bloc/
│           │   ├── attendance_bloc.dart
│           │   ├── attendance_event.dart
│           │   └── attendance_state.dart
│           ├── pages/
│           │   └── ...
│           └── widgets/
│               └── ...
│
├── injection_container.dart        # Dependency Injection
└── main.dart                       # Entry point
```

### Dependency Flow

```
Presentation → Domain → Data
    ↓           ↓        ↓
  Widgets    Use Cases  Data Sources
    ↓           ↓        ↓
   BLoC    Repositories Models
```

**Rules:**
- ✅ Presentation can depend on Domain
- ✅ Domain can depend on nothing (pure business logic)
- ✅ Data can depend on Domain
- ❌ Domain cannot depend on Presentation or Data
- ❌ Data cannot depend on Presentation

---

## 🔄 Development Workflow

### 1. Adding a New Feature

#### Step 1: Define Entity (Domain Layer)
```dart
// lib/features/attendance/domain/entities/new_entity.dart
class NewEntity extends Equatable {
  final String id;
  final String name;

  const NewEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
```

#### Step 2: Create Model (Data Layer)
```dart
// lib/features/attendance/data/models/new_model.dart
class NewModel extends NewEntity {
  const NewModel({
    required String id,
    required String name,
  }) : super(id: id, name: name);

  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  NewEntity toEntity() {
    return NewEntity(id: id, name: name);
  }
}
```

#### Step 3: Update Repository Interface (Domain)
```dart
// lib/features/attendance/domain/repositories/attendance_repository.dart
abstract class AttendanceRepository {
  // ... existing methods
  
  Future<Either<Failure, NewEntity>> getNewEntity(String id);
}
```

#### Step 4: Implement Repository (Data)
```dart
// lib/features/attendance/data/repositories/attendance_repository_impl.dart
@override
Future<Either<Failure, NewEntity>> getNewEntity(String id) async {
  try {
    final model = await remoteDataSource.getNewEntity(id);
    return Right(model.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

#### Step 5: Create Use Case (Domain)
```dart
// lib/features/attendance/domain/usecases/get_new_entity.dart
class GetNewEntity {
  final AttendanceRepository repository;

  GetNewEntity(this.repository);

  Future<Either<Failure, NewEntity>> call(String id) async {
    return await repository.getNewEntity(id);
  }
}
```

#### Step 6: Add BLoC Event
```dart
// lib/features/attendance/presentation/bloc/attendance_event.dart
class LoadNewEntityEvent extends AttendanceEvent {
  final String id;

  const LoadNewEntityEvent(this.id);

  @override
  List<Object?> get props => [id];
}
```

#### Step 7: Add BLoC State
```dart
// lib/features/attendance/presentation/bloc/attendance_state.dart
// Add to AttendanceState class
final NewEntity? newEntity;

// Add to copyWith
AttendanceState copyWith({
  // ... existing
  NewEntity? newEntity,
}) {
  return AttendanceState(
    // ... existing
    newEntity: newEntity ?? this.newEntity,
  );
}
```

#### Step 8: Handle Event in BLoC
```dart
// lib/features/attendance/presentation/bloc/attendance_bloc.dart
on<LoadNewEntityEvent>(_onLoadNewEntity);

Future<void> _onLoadNewEntity(
  LoadNewEntityEvent event,
  Emitter<AttendanceState> emit,
) async {
  emit(state.copyWith(status: AttendanceStatus.loading));
  
  final result = await getNewEntity(event.id);
  
  result.fold(
    (failure) => emit(state.copyWith(
      status: AttendanceStatus.failure,
      errorMessage: failure.message,
    )),
    (entity) => emit(state.copyWith(
      status: AttendanceStatus.newEntityLoaded,
      newEntity: entity,
    )),
  );
}
```

#### Step 9: Register Dependencies
```dart
// lib/injection_container.dart
void init() {
  // Use Cases
  sl.registerLazySingleton(() => GetNewEntity(sl()));
  
  // ... rest of setup
}
```

#### Step 10: Use in UI
```dart
// lib/features/attendance/presentation/pages/new_page.dart
BlocBuilder<AttendanceBloc, AttendanceState>(
  builder: (context, state) {
    if (state.status == AttendanceStatus.loading) {
      return CircularProgressIndicator();
    }
    
    if (state.newEntity != null) {
      return Text(state.newEntity!.name);
    }
    
    return SizedBox();
  },
)
```

---

### 2. Modifying Existing Features

#### Best Practices:
1. **Always update tests** when changing logic
2. **Maintain backward compatibility** when possible
3. **Update documentation** for API changes
4. **Follow existing patterns** in the codebase

#### Example: Adding a field to User

```dart
// 1. Update Entity
class UserEntity {
  final String id;
  final String name;
  final String email; // NEW
  // ...
}

// 2. Update Model
class UserModel {
  final String email; // NEW
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // ...
      email: json['email'] ?? '', // Handle null for old data
    );
  }
}

// 3. Update Database Schema
ALTER TABLE users ADD COLUMN email TEXT;

// 4. Update UI to display/input email
```

---

## 🎯 Best Practices

### 1. Code Style

#### Naming Conventions
```dart
// Classes: PascalCase
class UserEntity {}

// Variables/Functions: camelCase
final userName = 'John';
void getUserById() {}

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3;

// Private members: _prefixed
String _privateField;
void _privateMethod() {}
```

#### File Naming
```
snake_case.dart
user_entity.dart
attendance_repository.dart
```

#### Import Organization
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// 4. Project imports
import 'package:test_face_recognition/core/error/failures.dart';
import 'package:test_face_recognition/features/attendance/domain/entities/user_entity.dart';
```

---

### 2. Error Handling

#### Always use Either for operations that can fail
```dart
// ❌ Bad
Future<UserEntity> getUser(String id) async {
  try {
    return await api.getUser(id);
  } catch (e) {
    throw Exception(e);
  }
}

// ✅ Good
Future<Either<Failure, UserEntity>> getUser(String id) async {
  try {
    final user = await api.getUser(id);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

#### Handle errors in UI
```dart
result.fold(
  (failure) {
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failure.message)),
    );
  },
  (data) {
    // Success handling
  },
);
```

---

### 3. State Management

#### Use BLoC for complex state
```dart
// ✅ Good: BLoC for business logic
class AttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        // UI based on state
      },
    );
  }
}
```

#### Use StatefulWidget for local UI state
```dart
// ✅ Good: StatefulWidget for simple UI state
class ExpandableCard extends StatefulWidget {
  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    // UI with local state
  }
}
```

---

### 4. Widget Composition

#### Extract reusable widgets
```dart
// ❌ Bad: Everything in one widget
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 100 lines of UI code...
        ],
      ),
    );
  }
}

// ✅ Good: Extracted widgets
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(),
          ContentWidget(),
          FooterWidget(),
        ],
      ),
    );
  }
}
```

---

### 5. Async Operations

#### Always check mounted before setState
```dart
Future<void> loadData() async {
  final data = await api.getData();
  
  if (!mounted) return; // ✅ Check before setState
  
  setState(() {
    _data = data;
  });
}
```

#### Use async/await instead of .then()
```dart
// ❌ Bad
void loadUser() {
  getUserById('123').then((user) {
    setState(() => _user = user);
  });
}

// ✅ Good
Future<void> loadUser() async {
  final user = await getUserById('123');
  if (!mounted) return;
  setState(() => _user = user);
}
```

---

## 🧪 Testing

### Unit Tests

#### Testing Use Cases
```dart
// test/features/attendance/domain/usecases/register_user_test.dart
void main() {
  late RegisterUser useCase;
  late MockAttendanceRepository mockRepository;

  setUp(() {
    mockRepository = MockAttendanceRepository();
    useCase = RegisterUser(mockRepository);
  });

  test('should register user successfully', () async {
    // Arrange
    final user = UserEntity(id: '1', name: 'John');
    when(mockRepository.registerUser(any, any))
        .thenAnswer((_) async => Right(user));

    // Act
    final result = await useCase('John', mockImageFile);

    // Assert
    expect(result, Right(user));
    verify(mockRepository.registerUser('John', any));
  });
}
```

#### Testing BLoC
```dart
// test/features/attendance/presentation/bloc/attendance_bloc_test.dart
void main() {
  late AttendanceBloc bloc;
  late MockRegisterUser mockRegisterUser;

  setUp(() {
    mockRegisterUser = MockRegisterUser();
    bloc = AttendanceBloc(registerUser: mockRegisterUser);
  });

  blocTest<AttendanceBloc, AttendanceState>(
    'emits [loading, registered] when RegisterEvent succeeds',
    build: () {
      when(mockRegisterUser(any, any))
          .thenAnswer((_) async => Right(testUser));
      return bloc;
    },
    act: (bloc) => bloc.add(RegisterEvent('John', mockFile)),
    expect: () => [
      AttendanceState(status: AttendanceStatus.loading),
      AttendanceState(
        status: AttendanceStatus.registered,
        user: testUser,
      ),
    ],
  );
}
```

### Widget Tests

```dart
// test/features/attendance/presentation/pages/home_page_test.dart
void main() {
  testWidgets('HomePage displays title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomePage()),
    );

    expect(find.text('Face Attendance'), findsOneWidget);
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full registration flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Tap register button
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    // Enter name
    await tester.enterText(find.byType(TextField), 'John Doe');
    
    // Tap save
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Berhasil'), findsOneWidget);
  });
}
```

---

## 🐛 Debugging

### Flutter DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Logging

#### Use proper log levels
```dart
import 'dart:developer' as developer;

// Debug info
developer.log('User registered', name: 'attendance');

// Warnings
developer.log('Threshold too low', level: 900);

// Errors
developer.log('Failed to load', error: e, stackTrace: st);
```

### Debugging BLoC

```dart
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('Event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('Transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}

// In main.dart
void main() {
  Bloc.observer = AppBlocObserver();
  runApp(MyApp());
}
```

### Performance Profiling

```bash
# Profile app performance
flutter run --profile

# Analyze build times
flutter run --trace-startup

# Check for jank
flutter run --enable-software-rendering
```

---

## ⚡ Performance Optimization

### 1. Widget Optimization

#### Use const constructors
```dart
// ✅ Good
const Text('Hello');
const SizedBox(height: 16);
```

#### Avoid rebuilds with const
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [  // ✅ const list
        HeaderWidget(),
        FooterWidget(),
      ],
    );
  }
}
```

### 2. Image Optimization

#### Resize images before processing
```dart
// Resize to model input size
final resized = img.copyResize(
  image,
  width: 112,
  height: 112,
);
```

#### Cache network images
```dart
// Use cached_network_image for remote images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
);
```

### 3. List Optimization

#### Use ListView.builder for long lists
```dart
// ✅ Good: Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
);

// ❌ Bad: All items built at once
ListView(
  children: items.map((item) => ListTile(title: Text(item))).toList(),
);
```

### 4. State Management Optimization

#### Use BlocSelector for specific rebuilds
```dart
// ✅ Good: Only rebuilds when threshold changes
BlocSelector<AttendanceBloc, AttendanceState, double>(
  selector: (state) => state.threshold,
  builder: (context, threshold) {
    return Text('Threshold: $threshold');
  },
);

// ❌ Bad: Rebuilds on any state change
BlocBuilder<AttendanceBloc, AttendanceState>(
  builder: (context, state) {
    return Text('Threshold: ${state.threshold}');
  },
);
```

---

## 🤝 Contributing

### Git Workflow

#### Branch Naming
```
feature/add-user-profile
bugfix/fix-camera-crash
hotfix/critical-security-fix
refactor/clean-architecture
```

#### Commit Messages
```
feat: add user profile page
fix: resolve camera initialization crash
refactor: extract camera widgets
docs: update API documentation
test: add unit tests for RegisterUser
```

### Pull Request Process

1. **Create feature branch**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "feat: add my feature"
   ```

3. **Push to remote**
   ```bash
   git push origin feature/my-feature
   ```

4. **Create Pull Request**
   - Describe changes
   - Link related issues
   - Add screenshots if UI changes

5. **Code Review**
   - Address reviewer comments
   - Update PR as needed

6. **Merge**
   - Squash commits if needed
   - Delete branch after merge

---

## 📚 Resources

### Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [BLoC Library](https://bloclibrary.dev)

### Learning
- [Flutter Codelabs](https://flutter.dev/docs/codelabs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://www.didierboelens.com/2018/08/reactive-programming-streams-bloc/)

---

**Last Updated**: 7 Desember 2024
