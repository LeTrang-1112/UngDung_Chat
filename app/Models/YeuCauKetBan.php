<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class YeuCauKetBan extends Model
{
    protected $table = 'yeucauketban'; // Tên bảng
    protected $primaryKey = 'maYeuCau'; // Khóa chính của bảng
    public $incrementing = false; // Nếu không sử dụng auto-increment
    protected $keyType = 'integer'; // Kiểu dữ liệu của khóa chính (integer, string, ...)

    protected $fillable = [
        'maNguoiGui', 'maNguoiNhan', 'trangThai', 'thoiGianTao'
    ];
}
