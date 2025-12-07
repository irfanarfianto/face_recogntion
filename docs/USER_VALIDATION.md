# User Validation Before Attendance

## 🔒 Overview

Sistem sekarang memvalidasi apakah ada user terdaftar sebelum mengizinkan akses ke halaman absensi. Ini mencegah error dan memberikan user experience yang lebih baik.

---

## ✅ Implementasi

### 1. **HomePage Changes**

**Sebelum:**
```dart
class HomePage extends StatelessWidget {
  // Langsung navigate ke AttendancePage
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AttendancePage(),
    ),
  ),
}
```

**Sesudah:**
```dart
class HomePage extends StatefulWidget {
  // Validasi dulu sebelum navigate
  onTap: () => _handleAttendance(context),
}
```

---

### 2. **Validation Logic**

```dart
Future<void> _handleAttendance(BuildContext context) async {
  // 1. Load users dari database
  context.read<AttendanceBloc>().add(LoadUsersEvent());
  
  // 2. Wait untuk state update
  await Future.delayed(const Duration(milliseconds: 300));
  
  if (!mounted) return;
  
  final state = context.read<AttendanceBloc>().state;
  
  // 3. Check apakah ada user terdaftar
  if (state.users.isEmpty) {
    _showNoUsersDialog(context);  // ❌ Tampilkan dialog
  } else {
    Navigator.push(...);           // ✅ Navigate ke attendance
  }
}
```

---

### 3. **User-Friendly Dialog**

```dart
void _showNoUsersDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.person_off, size: 48, color: Colors.orange),
      title: Text('Belum Ada User Terdaftar'),
      content: Text(
        'Silakan daftarkan wajah terlebih dahulu sebelum melakukan absensi.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            // Langsung navigate ke RegisterPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(),
              ),
            );
          },
          icon: Icon(Icons.person_add),
          label: Text('Daftar Sekarang'),
        ),
      ],
    ),
  );
}
```

---

## 🎯 User Flow

### Scenario 1: Ada User Terdaftar ✅

```
User tap "Absen"
    ↓
Load users dari database
    ↓
Check: users.length > 0? → YES
    ↓
Navigate ke AttendancePage
    ↓
User bisa scan wajah
```

### Scenario 2: Belum Ada User ❌

```
User tap "Absen"
    ↓
Load users dari database
    ↓
Check: users.length > 0? → NO
    ↓
Show dialog "Belum Ada User Terdaftar"
    ↓
User pilih:
  - "Batal" → Kembali ke HomePage
  - "Daftar Sekarang" → Navigate ke RegisterPage
```

---

## 🔍 Technical Details

### State Management

**HomePage sekarang StatefulWidget:**
```dart
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load users saat page dibuka
    context.read<AttendanceBloc>().add(LoadUsersEvent());
  }
}
```

**Kenapa StatefulWidget?**
- ✅ Bisa call `initState()` untuk pre-load users
- ✅ Bisa track `mounted` state
- ✅ Better lifecycle management

---

### BLoC Integration

**Events:**
```dart
// Trigger load users
context.read<AttendanceBloc>().add(LoadUsersEvent());
```

**State:**
```dart
// Check users list
final state = context.read<AttendanceBloc>().state;
if (state.users.isEmpty) {
  // No users
}
```

---

## 🎨 UI/UX Improvements

### Dialog Design

**Visual Elements:**
- 🎨 **Icon**: `Icons.person_off` (orange) - Clear visual indicator
- 📝 **Title**: "Belum Ada User Terdaftar" - Clear message
- 💬 **Content**: Helpful instruction
- 🔘 **Actions**: Two clear options

**Button Hierarchy:**
- **TextButton** ("Batal") - Secondary action
- **FilledButton** ("Daftar Sekarang") - Primary action with icon

---

## ⚡ Performance Considerations

### Delay Strategy

```dart
await Future.delayed(const Duration(milliseconds: 300));
```

**Why 300ms?**
- ✅ Enough time for BLoC to update state
- ✅ Not too long to feel laggy
- ✅ Prevents race conditions

**Alternative Approach (Better):**
```dart
// Using BlocListener instead of delay
BlocListener<AttendanceBloc, AttendanceState>(
  listener: (context, state) {
    if (state.status == AttendanceStatus.usersLoaded) {
      if (state.users.isEmpty) {
        _showNoUsersDialog(context);
      } else {
        Navigator.push(...);
      }
    }
  },
)
```

---

## 🐛 Edge Cases Handled

### 1. **Widget Disposed During Async**
```dart
if (!mounted) return;
```
Prevents error jika user navigate away sebelum async selesai.

### 2. **Empty Database**
```dart
if (state.users.isEmpty) {
  _showNoUsersDialog(context);
}
```
Gracefully handle no users case.

### 3. **Network/Database Error**
```dart
// BLoC handles error state
if (state.status == AttendanceStatus.failure) {
  // Show error message
}
```

---

## 🔄 Future Improvements

### 1. **Better Loading State**
```dart
// Show loading indicator while checking
if (state.status == AttendanceStatus.loading) {
  return CircularProgressIndicator();
}
```

### 2. **Cache Users**
```dart
// Don't reload every time
if (state.users.isNotEmpty && !needsRefresh) {
  // Use cached data
}
```

### 3. **Optimistic Navigation**
```dart
// Navigate immediately, show error if no users
Navigator.push(...).then((_) {
  if (noUsers) {
    Navigator.pop();
    showDialog(...);
  }
});
```

---

## 📊 Benefits

### 1. **Better UX** ✅
- Clear error message
- Helpful guidance
- Quick action to register

### 2. **Prevent Errors** ✅
- No crash when no users
- No confusing empty state
- Graceful degradation

### 3. **User Guidance** ✅
- Direct path to solution
- Clear next steps
- Reduced friction

---

## 🧪 Testing

### Test Cases

**Test 1: No Users**
```dart
testWidgets('shows dialog when no users', (tester) async {
  // Setup: Empty users list
  when(mockBloc.state).thenReturn(
    AttendanceState(users: []),
  );
  
  // Act: Tap Absen button
  await tester.tap(find.text('Absen'));
  await tester.pumpAndSettle();
  
  // Assert: Dialog shown
  expect(find.text('Belum Ada User Terdaftar'), findsOneWidget);
});
```

**Test 2: Has Users**
```dart
testWidgets('navigates when users exist', (tester) async {
  // Setup: Users exist
  when(mockBloc.state).thenReturn(
    AttendanceState(users: [mockUser]),
  );
  
  // Act: Tap Absen button
  await tester.tap(find.text('Absen'));
  await tester.pumpAndSettle();
  
  // Assert: Navigated to AttendancePage
  expect(find.byType(AttendancePage), findsOneWidget);
});
```

**Test 3: Dialog Actions**
```dart
testWidgets('dialog actions work correctly', (tester) async {
  // Show dialog
  await tester.tap(find.text('Absen'));
  await tester.pumpAndSettle();
  
  // Test "Batal"
  await tester.tap(find.text('Batal'));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsNothing);
  
  // Test "Daftar Sekarang"
  await tester.tap(find.text('Absen'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Daftar Sekarang'));
  await tester.pumpAndSettle();
  expect(find.byType(RegisterPage), findsOneWidget);
});
```

---

## 📝 Summary

### What Changed:
- ✅ HomePage: StatelessWidget → StatefulWidget
- ✅ Added user validation before attendance
- ✅ Added helpful dialog for no users case
- ✅ Direct navigation to RegisterPage

### Impact:
- ✅ **Better UX**: Clear guidance for users
- ✅ **Prevent Errors**: No crash on empty database
- ✅ **Improved Flow**: Smooth onboarding experience

### Files Modified:
- `lib/features/attendance/presentation/pages/home_page.dart`

---

**Last Updated**: 7 Desember 2024
**Version**: 1.1.0
