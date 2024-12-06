<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\NhomChat;

class NhomChatController extends Controller
{
    // Tạo nhóm mới
    public function create(Request $request)
    {
        $validated = $request->validate([
            'tenNhom'      => 'required|string|max:100',
            'maQuanTriVien'=> 'required|integer',
        ]);

        $nhomChat = NhomChat::create([
            'tenNhom'       => $request->tenNhom,
            'maQuanTriVien' => $request->maQuanTriVien,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Group created successfully!',
            'data'    => $nhomChat
        ]);
    }

    // Lấy thông tin nhóm theo ID
    public function getGroup($maNhom)
{
    // Tìm nhóm chat theo maNhom và kèm theo thông tin thành viên nhóm
    $nhomChat = NhomChat::with('thanhVienNhom')->where('maNhom', $maNhom)->first();

    if (!$nhomChat) {
        return response()->json([
            'success' => false,
            'message' => 'Group not found!'
        ]);
    }

    return response()->json([
        'success' => true,
        'data'    => $nhomChat
    ]);
}


    // Lấy tất cả nhóm
    public function getAllGroups()
    {
        $nhomChats = NhomChat::with('thanhVienNhom')->get();

        return response()->json([
            'success' => true,
            'data'    => $nhomChats
        ]);
    }
    public function addMember(Request $request, $maNhom)
{
    $validated = $request->validate([
        'maNguoidung'  => 'required|integer',
        'quanTriVien'  => 'nullable|boolean',
    ]);

    // Tìm nhóm chat theo maNhom
    $nhomChat = NhomChat::find($maNhom);

    if (!$nhomChat) {
        return response()->json([
            'success' => false,
            'message' => 'Group not found!'
        ]);
    }

    $thanhVien = new ThanhVienNhom([
        'maNhom'      => $maNhom,
        'maNguoidung' => $request->maNguoidung,
        'quanTriVien' => $request->quanTriVien ?? 0,
    ]);
    
    $thanhVien->save();

    return response()->json([
        'success' => true,
        'message' => 'Member added successfully!',
        'data'    => $thanhVien
    ]);
}

public function removeMember($maNhom, $maNguoidung)
{
    // Tìm nhóm chat theo maNhom
    $nhomChat = NhomChat::find($maNhom);

    if (!$nhomChat) {
        return response()->json([
            'success' => false,
            'message' => 'Group not found!'
        ]);
    }

    // Tìm thành viên trong nhóm
    $thanhVien = ThanhVienNhom::where('maNhom', $maNhom)
                              ->where('maNguoidung', $maNguoidung)
                              ->first();

    if (!$thanhVien) {
        return response()->json([
            'success' => false,
            'message' => 'Member not found in this group!'
        ]);
    }

    $thanhVien->delete();

    return response()->json([
        'success' => true,
        'message' => 'Member removed successfully!'
    ]);
}
// Lấy danh sách thành viên của nhóm
public function getGroupMembers($maNhom)
{
    $thanhVienNhom = ThanhVienNhom::where('maNhom', $maNhom)->get();

    if ($thanhVienNhom->isEmpty()) {
        return response()->json([
            'success' => false,
            'message' => 'No members found for this group!'
        ]);
    }

    return response()->json([
        'success' => true,
        'data'    => $thanhVienNhom
    ]);
}
// Chỉnh sửa thông tin nhóm
public function updateGroup(Request $request, $maNhom)
{
    $validated = $request->validate([
        'tenNhom' => 'required|string|max:100',
    ]);

    $nhomChat = NhomChat::find($maNhom);

    if (!$nhomChat) {
        return response()->json([
            'success' => false,
            'message' => 'Group not found!'
        ]);
    }

    $nhomChat->update([
        'tenNhom' => $request->tenNhom,
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Group information updated successfully!',
        'data'    => $nhomChat
    ]);
}

    public function getConversations($userId)
    {
        // Lấy tất cả các cuộc trò chuyện của người dùng
        $conversations = Message::where('maNguoigui', $userId)
            ->orWhere('maNguoinhan', $userId)
            ->groupBy('maNguoinhan', 'maNguoigui') // Nhóm theo người nhận và người gửi
            ->latest() // Lấy tin nhắn cuối cùng
            ->get();

        // Tạo mảng để chứa dữ liệu cuộc trò chuyện
        $conversationList = [];

        // Duyệt qua tất cả các tin nhắn và nhóm chúng theo người nhận hoặc người gửi
        foreach ($conversations as $conversation) {
            $recipientId = $conversation->maNguoigui == $userId ? $conversation->maNguoinhan : $conversation->maNguoigui;

            // Lấy thông tin người nhận
            $recipient = User::find($recipientId);

            // Lấy tin nhắn cuối cùng
            $lastMessage = Message::where(function ($query) use ($userId, $recipientId) {
                $query->where('maNguoigui', $userId)
                      ->where('maNguoinhan', $recipientId);
            })
            ->orWhere(function ($query) use ($userId, $recipientId) {
                $query->where('maNguoigui', $recipientId)
                      ->where('maNguoinhan', $userId);
            })
            ->latest()
            ->first();

            // Thêm thông tin cuộc trò chuyện vào mảng
            $conversationList[] = [
                'maNguoinhan' => $recipientId,
                'tenNguoinhan' => $recipient ? $recipient->name : 'Unknown',
                'lastMessage' => $lastMessage ? $lastMessage->noiDung : 'No messages',
                'thoiGianGui' => $lastMessage ? $lastMessage->thoiGianGui : 'N/A',
            ];
        }

        return response()->json(['success' => true, 'data' => $conversationList]);
    }
}
