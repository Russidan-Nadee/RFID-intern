import 'package:mysql1/mysql1.dart';
import '../../../core/config/app_config.dart';
import '../../../core/exceptions/app_exceptions.dart';

class MySqlDataSource {
  MySqlConnection? _connection;

  // สร้างการเชื่อมต่อกับ MySQL
  Future<MySqlConnection> get connection async {
    if (_connection == null) {
      try {
        print('Connecting to MySQL...');
        final settings = ConnectionSettings(
          host: AppConfig.mysqlHost,
          port: AppConfig.mysqlPort,
          user: AppConfig.mysqlUser,
          password: AppConfig.mysqlPassword,
          db: AppConfig.mysqlDatabase,
        );

        _connection = await MySqlConnection.connect(settings);
        print('Connected to MySQL successfully');
      } catch (e) {
        print('MySQL connection error: $e');
        throw DatabaseException('Failed to connect to MySQL: $e');
      }
    }
    return _connection!;
  }

  // ดึงข้อมูลสินทรัพย์ทั้งหมด (ทุกคอลัมน์)
  Future<List<Map<String, dynamic>>> getAssets() async {
    try {
      final conn = await connection;
      final results = await conn.query('SELECT * FROM assets');

      return results.map((row) {
        // แปลงทุกคอลัมน์เป็น Map แบบ dynamic
        Map<String, dynamic> asset = {};

        // วนลูปผ่านทุกคอลัมน์และเพิ่มลงใน Map
        for (var column in row.fields.keys) {
          // ตรวจสอบว่าค่าเป็น null หรือไม่
          var value = row[column];
          asset[column] = value?.toString() ?? '';
        }

        // เพิ่ม key บางตัวที่จำเป็นสำหรับ AssetModel เพื่อให้แน่ใจว่ามีครบ
        if (!asset.containsKey('id')) asset['id'] = '';
        if (!asset.containsKey('uid')) {
          // ถ้าไม่มี uid ให้ใช้ uuid แทน
          asset['uid'] = asset['uuid'] ?? '';
        }
        if (!asset.containsKey('category')) asset['category'] = '';
        if (!asset.containsKey('status')) asset['status'] = '';
        if (!asset.containsKey('brand')) {
          // ถ้าไม่มี brand ให้ใช้ itemName แทน
          asset['brand'] = asset['itemName'] ?? '';
        }
        if (!asset.containsKey('department')) asset['department'] = '';
        if (!asset.containsKey('date')) {
          // ถ้าไม่มี date ให้ใช้ lastUpdated แทน
          asset['date'] = asset['lastUpdated'] ?? DateTime.now().toString();
        }

        return asset;
      }).toList();
    } catch (e) {
      throw DatabaseException('Error fetching assets from MySQL: $e');
    }
  }

  // ดึงข้อมูลสินทรัพย์ตาม UID (ทุกคอลัมน์)
  Future<Map<String, dynamic>?> getAssetByUid(String uid) async {
    try {
      final conn = await connection;
      final results = await conn.query('SELECT * FROM assets WHERE uuid = ?', [
        uid,
      ]);

      if (results.isEmpty) return null;

      var row = results.first;
      Map<String, dynamic> asset = {};

      // วนลูปผ่านทุกคอลัมน์และเพิ่มลงใน Map
      for (var column in row.fields.keys) {
        var value = row[column];
        asset[column] = value?.toString() ?? '';
      }

      // เพิ่ม key บางตัวที่จำเป็นสำหรับ AssetModel
      if (!asset.containsKey('id')) asset['id'] = '';
      if (!asset.containsKey('uid')) {
        asset['uid'] = asset['uuid'] ?? '';
      }
      if (!asset.containsKey('category')) asset['category'] = '';
      if (!asset.containsKey('status')) asset['status'] = '';
      if (!asset.containsKey('brand')) {
        asset['brand'] = asset['itemName'] ?? '';
      }
      if (!asset.containsKey('department')) asset['department'] = '';
      if (!asset.containsKey('date')) {
        asset['date'] = asset['lastUpdated'] ?? '';
      }

      return asset;
    } catch (e) {
      throw DatabaseException('Error fetching asset by UID from MySQL: $e');
    }
  }

  // อัพเดตสถานะของสินทรัพย์
  Future<bool> updateStatus(String uid, String status) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        'UPDATE assets SET status = ? WHERE uuid = ?',
        [status, uid],
      );

      return result.affectedRows != null && result.affectedRows! > 0;
    } catch (e) {
      throw DatabaseException('Error updating status in MySQL: $e');
    }
  }

  // อัพเดตสินทรัพย์ทั้งหมด
  Future<bool> updateAsset(
    String uid,
    String id,
    String category,
    String brand,
    String department,
    String status,
    String date,
  ) async {
    try {
      final conn = await connection;
      final result = await conn.query(
        'UPDATE assets SET id = ?, category = ?, itemName = ?, department = ?, status = ?, lastUpdated = ? WHERE uuid = ?',
        [id, category, brand, department, status, date, uid],
      );

      return result.affectedRows != null && result.affectedRows! > 0;
    } catch (e) {
      throw DatabaseException('Error updating asset in MySQL: $e');
    }
  }

  // เพิ่มสินทรัพย์ใหม่
  Future<void> insertNewAsset(
    String id,
    String category,
    String brand,
    String department,
    String uid,
    String date,
  ) async {
    try {
      final conn = await connection;
      await conn.query(
        'INSERT INTO assets (id, category, itemName, department, uuid, lastUpdated, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, category, brand, department, uid, date, 'Available'],
      );
    } catch (e) {
      throw DatabaseException('Error inserting data to MySQL: $e');
    }
  }

  // ลบสินทรัพย์ตาม UID
  Future<void> deleteAssetByUid(String uid) async {
    try {
      final conn = await connection;
      await conn.query('DELETE FROM assets WHERE uuid = ?', [uid]);
    } catch (e) {
      throw DatabaseException('Error deleting data from MySQL: $e');
    }
  }

  // ลบสินทรัพย์ทั้งหมด
  Future<void> deleteAllAssets() async {
    try {
      final conn = await connection;
      await conn.query('DELETE FROM assets');
    } catch (e) {
      throw DatabaseException('Error deleting all assets from MySQL: $e');
    }
  }

  // ปิดการเชื่อมต่อ
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
