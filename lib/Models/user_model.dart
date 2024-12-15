import '../database/database_conn.dart';

class User {
  int? id;
  String name;
  String email;
  String mobile;
  String? preferences;

  User({this.id, required this.name, required this.email, required this.mobile, this.preferences});

  // Convert a User object into a Map
  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'Name': name,
      'Email': email,
      'Mobile': mobile,
      'Preferences': preferences,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['ID'],
      name: map['Name'],
      email: map['Email'],
      mobile: map['Mobile'],
      preferences: map['Preferences'],
    );
  }

  // Database interaction methods
  static final MyDatabaseClass _dbHelper = MyDatabaseClass();

  static Future<int> insertUser(User user) async {
    final db = await _dbHelper.mydbcheck();
    return await db!.insert('Users', user.toMap());
  }

  static Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.mydbcheck();
    final List<Map<String, dynamic>> maps = await db!.query('Users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }
}
