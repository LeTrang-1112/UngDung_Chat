class User {
  final int id;
  final String phoneNumber; // Số điện thoại
  final String hashedPassword; // Mật khẩu đã mã hóa
  final String displayName; // Tên hiển thị
  final String profileImage; // Đường dẫn ảnh đại diện
  final String status; // Trạng thái cá nhân
  final DateTime createdAt; // Thời gian tạo tài khoản
  final DateTime? lastAccess; // Thời gian truy cập lần cuối

  User({
    required this.id,
    required this.phoneNumber,
    required this.hashedPassword,
    required this.displayName,
    required this.profileImage,
    required this.status,
    required this.createdAt,
    this.lastAccess,
  });

  // Phương thức để chuyển đổi đối tượng thành Map để lưu vào cơ sở dữ liệu
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'SoDienThoai': phoneNumber,
      'MatKhauMaHoa': hashedPassword,
      'TenHienThi': displayName,
      'AnhDaiDien': profileImage,
      'TrangThai': status,
      'ThoiGianTao': createdAt.toIso8601String(),
      'LanTruyCapCuoi': lastAccess?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, phoneNumber: $phoneNumber, displayName: $displayName, profileImage: $profileImage, status: $status, createdAt: $createdAt, lastAccess: $lastAccess}';
  }
}
