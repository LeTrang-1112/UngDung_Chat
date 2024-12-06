<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NhomChat extends Model
{
    protected $table = 'nhomchat';  // Bảng nhóm chat
    protected $primaryKey = 'maNhom';  // Khóa chính là maNhom
    public $incrementing = false;  // Nếu maNhom không phải là auto-increment
    protected $fillable = [
        'tenNhom', 'maQuanTriVien', 'thoiGianTao'
    ];

    // Quan hệ với thành viên nhóm
    public function thanhVienNhom()
    {
        return $this->hasMany(ThanhVienNhom::class, 'maNhom');
    }

    // Quan hệ với người quản trị viên
    public function quanTriVien()
    {
        return $this->belongsTo(NguoiDung::class, 'maQuanTriVien');
    }
}
