<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\NguoiDung;
use Illuminate\Support\Facades\Hash;

class NguoiDungController extends Controller
{
    // Lấy thông tin người dùng theo số điện thoại
    public function getUserByPhone($soDienthoai)
{
    $nguoiDung = NguoiDung::where('soDienthoai', $soDienthoai)->first();

    if ($nguoiDung) {
        return response()->json([
            'success' => true,
            'data'    => $nguoiDung
        ]);
    } else {
        return response()->json([
            'success' => false,
            'message' => 'User not found!'
        ]);
    }
}


    public function login(Request $request)
    {
        $validated = $request->validate([
            'soDienthoai' => 'required|string',
            'matkhauMahoa' => 'required|string', // Sử dụng 'matkhauMahoa' thay vì 'matkhauMahoaMahoa'
        ]);

        // Tìm người dùng với số điện thoại
        $nguoiDung = NguoiDung::where('soDienthoai', $request->soDienthoai)->first();

        // Kiểm tra xem người dùng có tồn tại không và mật khẩu có đúng không
        if (!$nguoiDung || $request->matkhauMahoa !== $nguoiDung->matkhauMahoa) { 
            // So sánh mật khẩu trực tiếp
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials!' 
            ]);
        }

        $nguoiDung->trangThai = 'Online';
        $nguoiDung->save();

        return response()->json([
            'success' => true,
            'message' => 'Login successful!',
            'data' => $nguoiDung
        ]);
    }


    // Đăng ký người dùng mới
    public function register(Request $request)
{
    // Validate dữ liệu đầu vào
    $validated = $request->validate([
        'soDienthoai' => 'required|unique:nguoidung|digits:10', // Kiểm tra số điện thoại duy nhất và đúng định dạng
        'matkhauMahoa' => 'required|string|min:6', // Kiểm tra mật khẩu có ít nhất 6 ký tự
        'tenHienthi' => 'nullable|string|max:100', // Kiểm tra tên hiển thị
        'anhDaiDien' => 'nullable|string|max:255', // Kiểm tra avatar
        'trangThai' => 'nullable|string|max:255', // Kiểm tra trạng thái
    ]);

    try {
        // Tạo người dùng mới
        $nguoiDung = NguoiDung::create([
            'soDienthoai' => $request->soDienthoai,
            'matkhauMahoa' => $request->matkhauMahoa,
            'tenHienthi' => $request->tenHienthi,
            'anhDaiDien' => $request->anhDaiDien,
            'trangThai' => $request->trangThai,
            'thoiGianTao' => now(), 
        ]);
        

        return response()->json([
            'success' => true,
            'message' => 'Registration successful!',
            'data' => $nguoiDung
        ]);
    } catch (\Exception $e) {
        // Nếu có lỗi khi tạo người dùng (ví dụ: lỗi cơ sở dữ liệu)
        return response()->json([
            'success' => false,
            'message' => 'Registration failed. ' . $e->getMessage()
        ], 500); // Trả về mã lỗi 500 cho lỗi server
    }
}


    // Cập nhật thông tin người dùng
    public function updateUser(Request $request, $maNguoidung)
    {
        $validated = $request->validate([
            'tenHienthi' => 'nullable|string|max:100',
            'anhDaiDien' => 'nullable|string|max:255',
            'trangThai' => 'nullable|string|max:255',
        ]);

        $nguoiDung = NguoiDung::find($maNguoidung);

        if (!$nguoiDung) {
            return response()->json([
                'success' => false,
                'message' => 'User not found!'
            ]);
        }

        $nguoiDung->update([
            'tenHienthi' => $request->tenHienthi,
            'anhDaiDien' => $request->anhDaiDien,
            'trangThai' => $request->trangThai,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully!',
            'data' => $nguoiDung
        ]);
    }
    public function getUserById($id)
    {
        // Tìm người dùng theo ID
        $nguoiDung = NguoiDung::find($id);

        // Kiểm tra xem người dùng có tồn tại không
        if (!$nguoiDung) {
            return response()->json([
                'success' => false,
                'message' => 'User not found!'
            ]);
        }

        // Trả về dữ liệu người dùng
        return response()->json([
            'success' => true,
            'message' => 'User found successfully!',
            'data' => $nguoiDung
        ]);
    }
    public function logout(Request $request)
    {
        $nguoiDung = NguoiDung::where('soDienthoai', $request->soDienthoai)->first();

        if (!$nguoiDung) {
            return response()->json([
                'success' => false,
                'message' => 'User not found!'
            ]);
        }

        // Cập nhật trạng thái của người dùng thành "Offline"
        $nguoiDung->trangThai = 'Offline';
        $nguoiDung->save();

        return response()->json([
            'success' => true,
            'message' => 'User logged out successfully!'
        ]);
    }

}
