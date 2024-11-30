import 'package:demo_database/model/ChatModel.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
//thư viện mã hóa pass
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DogProvider {
  late Database database;

  Future open() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }
    database = await openDatabase(
      join(await getDatabasesPath(), 'chat_database.db'),
      // ignore: void_checks
      onCreate: (db, version) {
        return Future.wait([
          db.execute('CREATE TABLE NguoiDung ('
              'MaNguoiDung INTEGER PRIMARY KEY AUTOINCREMENT, '
              'SoDienThoai NVARCHAR(15) UNIQUE NOT NULL, '
              'MatKhauMaHoa NVARCHAR(255) NOT NULL, '
              'TenHienThi NVARCHAR(100), '
              'AnhDaiDien NVARCHAR(255), '
              'TrangThai NVARCHAR(255), '
              'ThoiGianTao DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'LanTruyCapCuoi DATETIME'
              ')'),
          db.execute('CREATE TABLE DanhBa ('
              'MaDanhBa INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNguoiDung INTEGER, '
              'MaBan INTEGER, '
              'ThoiGianTao DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung), '
              'FOREIGN KEY (MaBan) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE TinNhan ('
              'MaTinNhan INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNguoiGui INTEGER, '
              'MaNguoiNhan INTEGER, '
              'NoiDung NVARCHAR(MAX), '
              'TinNhanNhom BIT, '
              'ThoiGianGui DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'DaXem BIT DEFAULT 0, '
              'ThoiGianXem DATETIME, '
              'FOREIGN KEY (MaNguoiGui) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE NhomChat ('
              'MaNhom INTEGER PRIMARY KEY AUTOINCREMENT, '
              'TenNhom NVARCHAR(100), '
              'MaQuanTriVien INTEGER, '
              'ThoiGianTao DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'FOREIGN KEY (MaQuanTriVien) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE ThanhVienNhom ('
              'MaThanhVienNhom INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNhom INTEGER, '
              'MaNguoiDung INTEGER, '
              'ThoiGianThamGia DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'QuanTriVien BIT DEFAULT 0, '
              'FOREIGN KEY (MaNhom) REFERENCES NhomChat(MaNhom), '
              'FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE CuocGoi ('
              'MaCuocGoi INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNguoiGoi INTEGER, '
              'MaNguoiNhan INTEGER, '
              'LoaiCuocGoi NVARCHAR(50), '
              'ThoiGianBatDau DATETIME, '
              'ThoiGianKetThuc DATETIME, '
              'FOREIGN KEY (MaNguoiGoi) REFERENCES NguoiDung(MaNguoiDung), '
              'FOREIGN KEY (MaNguoiNhan) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE ThongBao ('
              'MaThongBao INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNguoiDung INTEGER, '
              'NoiDung NVARCHAR(MAX), '
              'DaDoc BIT DEFAULT 0, '
              'ThoiGianTao DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'ThoiGianDoc DATETIME, '
              'FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE YeuCauKetBan ('
              'MaYeuCau INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNguoiGui INTEGER, '
              'MaNguoiNhan INTEGER, '
              'TrangThai NVARCHAR(50) DEFAULT \'cho_xu_ly\', '
              'ThoiGianYeuCau DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'ThoiGianPhanHoi DATETIME, '
              'FOREIGN KEY (MaNguoiGui) REFERENCES NguoiDung(MaNguoiDung), '
              'FOREIGN KEY (MaNguoiNhan) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE TrangThai ('
              'MaTrangThai INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaNguoiDung INTEGER, '
              'NoiDung NVARCHAR(MAX), '
              'DuongDanPhuongTien NVARCHAR(MAX), '
              'ThoiGianTao DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'ThoiGianHetHan DATETIME DEFAULT DATEADD(HOUR, 24, CURRENT_TIMESTAMP), '
              'QuyenRiengTu NVARCHAR(50) DEFAULT \'cong_khai\', '
              'FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
          db.execute('CREATE TABLE LuotXemTrangThai ('
              'MaLuotXem INTEGER PRIMARY KEY AUTOINCREMENT, '
              'MaTrangThai INTEGER, '
              'MaNguoiDung INTEGER, '
              'ThoiGianXem DATETIME DEFAULT CURRENT_TIMESTAMP, '
              'FOREIGN KEY (MaTrangThai) REFERENCES TrangThai(MaTrangThai), '
              'FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)'
              ')'),
        ]);
      },
      version: 1,
    );
  }

  Future<int?> addUser(String soDienThoai) async {
    try {
      final List<Map<String, dynamic>> existingUser = await database.query(
        'NguoiDung',
        where: 'SoDienThoai = ?',
        whereArgs: [soDienThoai],
      );

      if (existingUser.isNotEmpty) {
        print('Số điện thoại này đã tồn tại.');
        return null;
      }

      Map<String, dynamic> userData = {
        'SoDienThoai': soDienThoai,
        'MatKhauMaHoa': hashPassword('default_password'),
        'TenHienThi': 'Người dùng mới',
        'AnhDaiDien': '',
        'TrangThai': 'active',
      };

      return await database.insert(
        'NguoiDung',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Lỗi khi thêm người dùng: $e');
      return null;
    }
  }

//UPDATE NGƯỜI DÙNG
  Future<void> updateUser(int userId,
      {String? phoneNumber,
      String? password,
      String? displayName,
      String? imagePath}) async {
    // Tạo bản cập nhật
    Map<String, dynamic> updateData = {};

    if (phoneNumber != null) {
      updateData['SoDienThoai'] = phoneNumber; // Cập nhật số điện thoại nếu có
    }

    if (password != null) {
      updateData['MatKhauMaHoa'] =
          password; // Cập nhật mật khẩu đã mã hóa nếu có
    }

    if (displayName != null) {
      updateData['TenHienThi'] = displayName; // Cập nhật tên hiển thị nếu có
    }

    if (imagePath != null) {
      updateData['AnhDaiDien'] =
          imagePath; // Cập nhật đường dẫn ảnh đại diện nếu có
    }

    // Kiểm tra xem có dữ liệu để cập nhật không
    if (updateData.isNotEmpty) {
      await database.update(
        'NguoiDung', // Tên bảng
        updateData, // Dữ liệu cần cập nhật
        where: 'MaNguoiDung = ?', // Điều kiện
        whereArgs: [userId], // Tham số điều kiện
      );
    }
  }

//KIỂM TRA ĐĂNG NHẬP
  Future<Map<String, dynamic>?> checkUserCredentials(
      String phoneNumber, String password) async {
    // Mã hóa mật khẩu để so sánh
    String hashedPassword =
        hashPassword(password); // Bạn cần có một hàm mã hóa mật khẩu

    // Truy vấn cơ sở dữ liệu để tìm tài khoản
    final List<Map<String, dynamic>> result = await database.query(
      'NguoiDung', // Tên bảng
      where: 'SoDienThoai = ? AND MatKhauMaHoa = ?', // Điều kiện
      whereArgs: [phoneNumber, hashedPassword], // Tham số điều kiện
    );

    // Kiểm tra xem có kết quả không
    if (result.isNotEmpty) {
      return result.first; // Trả về thông tin người dùng nếu tìm thấy
    }

    return null; // Trả về null nếu không tìm thấy tài khoản
  }

  //hàm chuyển đổi pass
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Chuyển đổi mật khẩu thành bytes
    var digest = sha256.convert(bytes); // Mã hóa với SHA-256
    return digest.toString(); // Trả về chuỗi hash
  }

//HÀM LẤY RA 1 TÀI KHOẢN
  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    final List<Map<String, dynamic>> result = await database.query(
      'NguoiDung',
      where: 'SoDienThoai = ?',
      whereArgs: [phoneNumber],
    );

    if (result.isNotEmpty) {
      return result.first; // Trả về thông tin người dùng nếu tìm thấy
    }

    return null; // Trả về null nếu không tìm thấy tài khoản
  }

//DANH SÁCH TIN NHẮN
  Future<List<Map<String, dynamic>>> getAllMessagesForFriends(
      int userId) async {
    // Lấy danh sách bạn bè của người dùng
    final List<Map<String, dynamic>> friends = await database.query(
      'DanhBa',
      where: 'MaNguoiDung = ?',
      whereArgs: [userId],
    );

    // Lấy danh sách ID của bạn bè
    List<int> friendIds =
        friends.map((friend) => friend['MaBan'] as int).toList();

    // Nếu không có bạn bè nào, trả về danh sách rỗng
    if (friendIds.isEmpty) {
      return [];
    }

    // Lấy tất cả tin nhắn của bạn bè
    final List<Map<String, dynamic>> messages = await database.query(
      'TinNhan',
      where:
          'MaNguoiGui IN (${friendIds.join(',')}) OR MaNguoiNhan IN (${friendIds.join(',')})',
    );

    return messages; // Trả về danh sách tin nhắn của tất cả bạn bè
  }

//HÀM LẤY RA TẤT CẢ TIN NHẮN TỪ 1 NGƯỜI
  Future<List<Map<String, dynamic>>> getMessagesBetweenUsers(
      int currentUserId, int friendUserId) async {
    // Lấy tất cả tin nhắn giữa người dùng hiện tại và bạn
    final List<Map<String, dynamic>> messages = await database.query(
      'TinNhan',
      where:
          '(MaNguoiGui = ? AND MaNguoiNhan = ?) OR (MaNguoiGui = ? AND MaNguoiNhan = ?)',
      whereArgs: [currentUserId, friendUserId, friendUserId, currentUserId],
      orderBy: 'ThoiGianGui ASC', // Sắp xếp theo thời gian gửi
    );

    return messages; // Trả về danh sách tin nhắn
  }

//LẤY RA THÔNG TIN CẢ BẠN BÈ
  Future<List<Map<String, dynamic>>> getFriendsInfo(int userId) async {
    // Lấy danh sách ID bạn bè từ bảng DanhBa
    final List<Map<String, dynamic>> friendsIds = await database.query(
      'DanhBa',
      where: 'MaNguoiDung = ?',
      whereArgs: [userId],
    );

    // Lấy thông tin chi tiết của từng bạn bè
    List<Map<String, dynamic>> friendsInfo = [];

    for (var friend in friendsIds) {
      int friendId = friend['MaBan']; // ID bạn bè
      final List<Map<String, dynamic>> friendDetails = await database.query(
        'NguoiDung',
        where: 'MaNguoiDung = ?',
        whereArgs: [friendId],
      );

      // Thêm thông tin bạn bè vào danh sách
      if (friendDetails.isNotEmpty) {
        friendsInfo.add(friendDetails.first); // Lấy thông tin của bạn bè
      }
    }

    return friendsInfo; // Trả về danh sách thông tin bạn bè
  }

//HÀM GỬI YÊU CẦU KẾT BẠN
  Future<void> sendFriendRequest(int senderId, int receiverId) async {
    // Kiểm tra xem yêu cầu đã tồn tại hay chưa
    final List<Map<String, dynamic>> existingRequest = await database.query(
      'YeuCauKetBan',
      where: 'MaNguoiGui = ? AND MaNguoiNhan = ?',
      whereArgs: [senderId, receiverId],
    );

    if (existingRequest.isNotEmpty) {
      print('Bạn đã gửi yêu cầu kết bạn cho người này rồi.');
      return; // Nếu đã gửi yêu cầu, không làm gì thêm
    }

    // Thêm yêu cầu kết bạn vào bảng YeuCauKetBan
    await database.insert(
      'YeuCauKetBan',
      {
        'MaNguoiGui': senderId,
        'MaNguoiNhan': receiverId,
        'TrangThai': 'cho_xu_ly', // Trạng thái yêu cầu
        'ThoiGianYeuCau':
            DateTime.now().toIso8601String(), // Thời gian gửi yêu cầu
      },
    );

    print('Đã gửi yêu cầu kết bạn thành công.');
  }

//HÀM XỬ LÝ YÊU CẦU KẾT BẠN
  Future<void> respondToFriendRequest(int requestId, bool accept) async {
    if (accept) {
      // Lấy thông tin yêu cầu
      final request = await database.query(
        'YeuCauKetBan',
        where: 'MaYeuCau = ?',
        whereArgs: [requestId],
      );

      if (request.isNotEmpty) {
        Object? senderId = request.first['MaNguoiGui'];
        Object? receiverId = request.first['MaNguoiNhan'];

        // Thêm bạn bè vào danh bạ
        await database.insert(
          'DanhBa',
          {
            'MaNguoiDung': receiverId,
            'MaBan': senderId,
            'ThoiGianTao':
                DateTime.now().toIso8601String(), // Thời gian thêm vào danh bạ
          },
        );

        // Cập nhật trạng thái yêu cầu
        await database.update(
          'YeuCauKetBan',
          {'TrangThai': 'da_chap_nhan'}, // Cập nhật trạng thái
          where: 'MaYeuCau = ?',
          whereArgs: [requestId],
        );

        print('Đã chấp nhận yêu cầu kết bạn thành công.');
      }
    } else {
      // Cập nhật trạng thái yêu cầu là đã từ chối
      await database.update(
        'YeuCauKetBan',
        {'TrangThai': 'tu_choi'}, // Cập nhật trạng thái
        where: 'MaYeuCau = ?',
        whereArgs: [requestId],
      );

      print('Đã từ chối yêu cầu kết bạn.');
    }
  }
}
