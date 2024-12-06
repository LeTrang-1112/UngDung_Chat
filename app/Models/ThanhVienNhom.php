<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ThanhVienNhom extends Model
{
    protected $table = 'ThanhVienNhom';  // Bảng thành viên nhóm
    protected $fillable = [
        'maNhom', 'maNguoidung', 'thoiGianThamGia', 'quanTriVien'
    ];

    // Quan hệ với người dùng (thành viên)
    public function nguoiDung()
    {
        return $this->belongsTo(NguoiDung::class, 'maNguoidung');
    }

    // Quan hệ với nhóm
    public function nhomChat()
    {
        return $this->belongsTo(NhomChat::class, 'maNhom');
    }
}
