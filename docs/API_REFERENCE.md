# API Reference - Face Recognition Attendance System

## 📚 Daftar Isi
1. [Supabase API](#supabase-api)
2. [Local Data Sources](#local-data-sources)
3. [Use Cases](#use-cases)
4. [BLoC Events & States](#bloc-events--states)
5. [Utility Functions](#utility-functions)

---

## 🌐 Supabase API

### AttendanceRemoteDataSource

Bertanggung jawab untuk semua operasi database melalui Supabase.

#### Methods

##### `registerUser(String name, List<double> embedding)`
Mendaftarkan user baru dengan nama dan face embedding.

**Parameters:**
- `name` (String): Nama lengkap user
- `embedding` (List<double>): Face embedding 192 dimensi

**Returns:** `Future<UserModel>`

**Throws:** `ServerException` jika gagal

**Example:**
```dart
final user = await remoteDataSource.registerUser(
  'John Doe',
  [0.123, 0.456, ...], // 192 values
);
```

---

##### `getAllUsers()`
Mengambil semua user yang terdaftar.

**Returns:** `Future<List<UserModel>>`

**Throws:** `ServerException` jika gagal

**Example:**
```dart
final users = await remoteDataSource.getAllUsers();
```

---

##### `getUserById(String userId)`
Mengambil user berdasarkan ID.

**Parameters:**
- `userId` (String): UUID user

**Returns:** `Future<UserModel>`

**Throws:** `ServerException` jika tidak ditemukan

**Example:**
```dart
final user = await remoteDataSource.getUserById('uuid-here');
```

---

##### `deleteUser(String userId)`
Menghapus user (cascade delete attendance logs).

**Parameters:**
- `userId` (String): UUID user

**Returns:** `Future<void>`

**Throws:** `ServerException` jika gagal

**Example:**
```dart
await remoteDataSource.deleteUser('uuid-here');
```

---

##### `saveAttendanceLog(String userId, double matchScore)`
Menyimpan log presensi.

**Parameters:**
- `userId` (String): UUID user
- `matchScore` (double): Euclidean distance score

**Returns:** `Future<AttendanceLogModel>`

**Throws:** `ServerException` jika gagal

**Example:**
```dart
final log = await remoteDataSource.saveAttendanceLog(
  'user-uuid',
  0.85,
);
```

---

##### `getAttendanceLogs()`
Mengambil semua log presensi dengan join user data.

**Returns:** `Future<List<AttendanceLogModel>>`

**Throws:** `ServerException` jika gagal

**Example:**
```dart
final logs = await remoteDataSource.getAttendanceLogs();
```

---

##### `getAttendanceLogsByUserId(String userId)`
Mengambil log presensi untuk user tertentu.

**Parameters:**
- `userId` (String): UUID user

**Returns:** `Future<List<AttendanceLogModel>>`

**Throws:** `ServerException` jika gagal

**Example:**
```dart
final logs = await remoteDataSource.getAttendanceLogsByUserId('uuid');
```

---

## 💾 Local Data Sources

### FaceLocalDataSource

Bertanggung jawab untuk operasi ML lokal (face detection & recognition).

#### Methods

##### `extractEmbedding(XFile imageFile)`
Ekstraksi face embedding dari foto.

**Parameters:**
- `imageFile` (XFile): File foto dari camera

**Returns:** `Future<List<double>>` - 192 dimensional embedding

**Throws:** `CacheException` jika gagal

**Process:**
1. Load image dari file
2. Detect face menggunakan ML Kit
3. Crop face region
4. Resize ke 112x112
5. Normalize pixel values
6. Run inference dengan TFLite
7. Return embedding vector

**Example:**
```dart
final embedding = await localDataSource.extractEmbedding(xFile);
// Returns: [0.123, 0.456, ..., 0.789] (192 values)
```

---

##### `compareEmbeddings(List<double> embedding1, List<double> embedding2)`
Menghitung Euclidean distance antara dua embedding.

**Parameters:**
- `embedding1` (List<double>): Embedding pertama
- `embedding2` (List<double>): Embedding kedua

**Returns:** `double` - Distance score (0.0 - ~2.0)

**Formula:**
```
distance = √(Σ(e1[i] - e2[i])²)
```

**Example:**
```dart
final distance = await localDataSource.compareEmbeddings(
  userEmbedding,
  capturedEmbedding,
);
// Returns: 0.85
```

---

##### `saveThreshold(double threshold)`
Menyimpan threshold ke SharedPreferences.

**Parameters:**
- `threshold` (double): Nilai threshold (0.5 - 1.5)

**Returns:** `Future<void>`

**Example:**
```dart
await localDataSource.saveThreshold(1.0);
```

---

##### `getThreshold()`
Mengambil threshold dari SharedPreferences.

**Returns:** `Future<double>` - Default: 1.0

**Example:**
```dart
final threshold = await localDataSource.getThreshold();
// Returns: 1.0
```

---

## 🎯 Use Cases

### RegisterUser

Mendaftarkan user baru.

**Constructor:**
```dart
RegisterUser(AttendanceRepository repository)
```

**Method:**
```dart
Future<Either<Failure, UserEntity>> call(String name, XFile imageFile)
```

**Parameters:**
- `name`: Nama user
- `imageFile`: Foto wajah

**Returns:**
- `Right(UserEntity)` jika sukses
- `Left(Failure)` jika gagal

**Example:**
```dart
final result = await registerUser('John Doe', xFile);
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Success: ${user.name}'),
);
```

---

### AuthenticateUser

Melakukan presensi dengan face recognition.

**Constructor:**
```dart
AuthenticateUser(AttendanceRepository repository)
```

**Method:**
```dart
Future<Either<Failure, Map<String, dynamic>>> call(XFile imageFile)
```

**Parameters:**
- `imageFile`: Foto wajah untuk matching

**Returns:**
```dart
Right({
  'user': UserEntity,
  'distance': double,
  'threshold': double,
})
```

**Example:**
```dart
final result = await authenticateUser(xFile);
result.fold(
  (failure) => print('Not recognized'),
  (data) {
    print('User: ${data['user'].name}');
    print('Score: ${data['distance']}');
  },
);
```

---

### GetAttendanceLogs

Mengambil riwayat presensi.

**Constructor:**
```dart
GetAttendanceLogs(AttendanceRepository repository)
```

**Method:**
```dart
Future<Either<Failure, List<AttendanceLogEntity>>> call()
```

**Returns:**
- `Right(List<AttendanceLogEntity>)` jika sukses
- `Left(Failure)` jika gagal

**Example:**
```dart
final result = await getAttendanceLogs();
result.fold(
  (failure) => print('Error loading logs'),
  (logs) => print('Total logs: ${logs.length}'),
);
```

---

### SaveThreshold

Menyimpan threshold setting.

**Constructor:**
```dart
SaveThreshold(AttendanceRepository repository)
```

**Method:**
```dart
Future<Either<Failure, void>> call(double threshold)
```

**Parameters:**
- `threshold`: Nilai threshold (0.5 - 1.5)

**Example:**
```dart
await saveThreshold(1.2);
```

---

### LoadThreshold

Memuat threshold setting.

**Constructor:**
```dart
LoadThreshold(AttendanceRepository repository)
```

**Method:**
```dart
Future<Either<Failure, double>> call()
```

**Returns:**
- `Right(double)` - Threshold value
- `Left(Failure)` jika gagal

**Example:**
```dart
final result = await loadThreshold();
final threshold = result.getOrElse(() => 1.0);
```

---

## 🔄 BLoC Events & States

### AttendanceEvent

#### `RegisterEvent`
```dart
RegisterEvent(String name, XFile imageFile)
```
Trigger registrasi user baru.

---

#### `AuthenticateEvent`
```dart
AuthenticateEvent(XFile imageFile)
```
Trigger face recognition untuk presensi.

---

#### `LoadLogsEvent`
```dart
LoadLogsEvent()
```
Trigger load attendance logs.

---

#### `LoadUsersEvent`
```dart
LoadUsersEvent()
```
Trigger load semua users.

---

#### `DeleteUserEvent`
```dart
DeleteUserEvent(String userId)
```
Trigger delete user.

---

#### `SaveThresholdEvent`
```dart
SaveThresholdEvent(double threshold)
```
Trigger save threshold setting.

---

#### `LoadThresholdEvent`
```dart
LoadThresholdEvent()
```
Trigger load threshold setting.

---

### AttendanceState

#### Properties

```dart
class AttendanceState {
  final AttendanceStatus status;
  final UserEntity? user;
  final List<AttendanceLogEntity> logs;
  final List<UserEntity> users;
  final String? errorMessage;
  final double? lastDistance;
  final double threshold;
}
```

#### Status Enum

```dart
enum AttendanceStatus {
  initial,      // State awal
  loading,      // Sedang proses
  registered,   // Registrasi sukses
  authenticated,// Presensi sukses
  failure,      // Gagal
  logsLoaded,   // Logs berhasil dimuat
  usersLoaded,  // Users berhasil dimuat
  userDeleted,  // User berhasil dihapus
  thresholdSaved, // Threshold berhasil disimpan
  thresholdLoaded, // Threshold berhasil dimuat
}
```

---

## 🛠️ Utility Functions

### MLKitUtils

#### `rotationIntToImageRotation(int rotation)`
Convert sensor orientation ke InputImageRotation.

**Parameters:**
- `rotation` (int): Sensor orientation (0, 90, 180, 270)

**Returns:** `InputImageRotation`

**Example:**
```dart
final rotation = MLKitUtils.rotationIntToImageRotation(90);
```

---

#### `inputImageFromCameraImage(CameraImage image, CameraDescription camera, InputImageRotation rotation)`
Convert CameraImage ke InputImage untuk ML Kit.

**Parameters:**
- `image`: CameraImage dari stream
- `camera`: CameraDescription
- `rotation`: InputImageRotation

**Returns:** `InputImage`

**Example:**
```dart
final inputImage = MLKitUtils.inputImageFromCameraImage(
  cameraImage,
  frontCamera,
  rotation,
);
```

---

### Image Processing

#### `preprocessImage(img.Image image)`
Preprocess image untuk TFLite model.

**Process:**
1. Resize ke 112x112
2. Convert ke grayscale (optional)
3. Normalize ke [-1, 1]

**Returns:** `List<List<List<List<double>>>>` - 4D tensor

**Example:**
```dart
final input = preprocessImage(faceImage);
// Shape: [1, 112, 112, 3]
```

---

#### `normalizeEmbedding(List<double> embedding)`
L2 normalization untuk embedding.

**Formula:**
```
normalized[i] = embedding[i] / √(Σ(embedding[j]²))
```

**Example:**
```dart
final normalized = normalizeEmbedding(rawEmbedding);
```

---

## 📊 Data Models

### UserModel

```dart
class UserModel {
  final String id;
  final String name;
  final List<double> faceEmbedding;
  final DateTime createdAt;

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  // Convert to Entity
  UserEntity toEntity();
}
```

---

### AttendanceLogModel

```dart
class AttendanceLogModel {
  final String id;
  final String userId;
  final String userName;  // Joined from users table
  final DateTime scanTime;
  final double matchScore;
  final String status;

  // JSON serialization
  factory AttendanceLogModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  // Convert to Entity
  AttendanceLogEntity toEntity();
}
```

---

## 🔐 Error Handling

### Failure Types

#### `ServerFailure`
```dart
ServerFailure(String message)
```
Untuk error dari Supabase/network.

---

#### `CacheFailure`
```dart
CacheFailure(String message)
```
Untuk error dari local storage/ML operations.

---

### Exception Types

#### `ServerException`
```dart
ServerException(String message)
```
Thrown oleh RemoteDataSource.

---

#### `CacheException`
```dart
CacheException(String message)
```
Thrown oleh LocalDataSource.

---

## 📝 Constants

### Face Detection

```dart
const double MIN_FACE_SIZE = 0.15;  // 15% of screen
const double EYE_CLOSED_THRESHOLD = 0.2;
const double EYE_OPEN_THRESHOLD = 0.5;
const double CENTER_TOLERANCE_X = 0.25;  // 25% of width
const double CENTER_TOLERANCE_Y = 0.25;  // 25% of height
```

### Threshold

```dart
const double DEFAULT_THRESHOLD = 1.0;
const double MIN_THRESHOLD = 0.5;
const double MAX_THRESHOLD = 1.5;
```

### Model

```dart
const String MODEL_PATH = 'assets/model/tflite/mobilefacenet.tflite';
const int EMBEDDING_SIZE = 192;
const int INPUT_SIZE = 112;  // 112x112 pixels
```

---

**Last Updated**: 7 Desember 2024
