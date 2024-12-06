<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TinNhan extends Model
{
    protected $table = 'tinnhan'; // Tên bảng trong cơ sở dữ liệu
    protected $primaryKey = 'maTinnhan'; // Khóa chính của bảng
    public $incrementing = true; // Sử dụng tự động tăng cho khóa chính
    protected $keyType = 'int'; // Kiểu dữ liệu của khóa chính là integer
    public $timestamps = false;
    // Các thuộc tính có thể gán giá trị
    protected $fillable = [
        'maNguoigui',
        'maNguoinhan',
        'noiDung',
        'loaiTinnhan',
        'duongDanMedia',
        'tinNhanNhom',
        'thoiGianGui',
        'daXem',
        'thoiGianXem',
        'trangthai'
    ];

    // Các quan hệ (nếu có)
    public function nguoiGui()
    {
        return $this->belongsTo(User::class, 'maNguoigui');
    }

    public function nguoiNhan()
    {
        return $this->belongsTo(User::class, 'maNguoinhan');
    }
}
