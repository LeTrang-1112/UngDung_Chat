<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\NhomChatController;
use App\Http\Controllers\YeuCauKetBanController;
use App\Http\Controllers\TinNhanController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\NguoiDungController;

Route::prefix('nguoidung')->group(function () {
    Route::get('/{soDienthoai}', [NguoiDungController::class, 'getUserByPhone']);
    Route::post('/login', [NguoiDungController::class, 'login']);
    Route::post('/register', [NguoiDungController::class, 'register']);
    Route::put('/{maNguoidung}', [NguoiDungController::class, 'updateUser']);
    Route::get('user/{id}', [NguoiDungController::class, 'getUserById']);
    Route::post('/logout', [NguoiDungController::class, 'logout']);

});
Route::prefix('tinnhan')->group(function () {
    Route::post('/create', [TinNhanController::class, 'create']);
    Route::get('/conversations/{userId}', [TinNhanController::class, 'getConversations']);
    Route::get('/last/{id}', [TinNhanController::class, 'getLastMessageOfUser']);

    Route::get('/getall', [TinNhanController::class, 'getAll']);
    Route::get('/{id}', [TinNhanController::class, 'getMessage']);
    Route::get('/messages/{maNguoigui}/{maNguoinhan}', [TinNhanController::class, 'getMessagesBetweenUsers']);
    Route::put('/{id}/read', [TinNhanController::class, 'markAsRead']);
    Route::delete('/xoa/{id}', [TinNhanController::class, 'deleteMessage']);
    Route::put('/thuhoi/{id}', [TinNhanController::class, 'thuHoiMessage']);

    Route::post('/search', [TinNhanController::class, 'searchMessages']);
    Route::post('/image', [TinNhanController::class, 'sendImage']);//Lỗi
    Route::post('/recall/{id}', [TinNhanController::class, 'recallMessage']);
});
