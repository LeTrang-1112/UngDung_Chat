<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NguoiDung extends Model
{
    use HasFactory;

    // Đảm bảo tên bảng đúng
    protected $table = 'nguoidung';  

    // Xác định khóa chính
    protected $primaryKey = 'maNguoidung';  
    public $timestamps = false;
    // Các thuộc tính có thể gán
    protected $fillable = [
        'soDienthoai', 
        'matkhauMahoa',
        'tenHienthi',
        'anhDaiDien',
        'trangThai',
        'lanTruyCapCuoi'
    ];

    // Mỗi người dùng có thể có nhiều nhóm chat
    public function nhomChats()
    {
        return $this->belongsToMany(NhomChat::class, 'ThanhVienNhom', 'maNguoidung', 'maNhom');
    }

    // Mỗi người dùng có thể có nhiều tin nhắn trong nhóm chat
    public function tinNhan()
    {
        return $this->hasMany(TinNhan::class, 'maNguoidung');
    }

    // // Mã hóa mật khẩu khi người dùng được tạo
    // public static function boot()
    // {
    //     parent::boot();

    //     static::creating(function ($nguoiDung) {
    //         if ($nguoiDung->matkhauMahoa) {
    //             $nguoiDung->matkhauMahoa = bcrypt($nguoiDung->matkhauMahoa);  // Mã hóa mật khẩu
    //         }
    //     });
    // }
}
