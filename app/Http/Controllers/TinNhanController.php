<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\TinNhan;
use App\Models\NguoiDung;
class TinNhanController extends Controller
{
    // Thêm tin nhắn
    public function create(Request $request)
    {
        $validated = $request->validate([
            'noiDung' => 'required|string',
            'maNguoigui' => 'required|integer',
            'maNguoinhan' => 'required|integer',
            'thoiGianGui' => 'required|date',
        ]);
    
        try {
            $tinNhan = TinNhan::create([
                'maNguoigui' => $request->maNguoigui,
                'maNguoinhan' => $request->maNguoinhan,
                'noiDung' => $request->noiDung,
                'loaiTinnhan' => $request->loaiTinnhan ?? 'text',
                'duongDanMedia' => $request->duongDanMedia ?? null,
                'tinNhanNhom' => $request->tinNhanNhom ?? false,
                'thoiGianGui' => $request->thoiGianGui,
                'trangthai' => 'bt', // Mặc định trạng thái là 'bt' (bình thường)
            ]);
    
            return response()->json([
                'success' => true,
                'message' => 'Message sent successfully!',
                'data' => $tinNhan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error while sending message!',
                'error' => $e->getMessage()
            ]);
        }
    }
    

    // Lấy tất cả tin nhắn
    public function getAll()
    {
        $tinNhans = TinNhan::all();
        return response()->json([
            'success' => true,
            'data' => $tinNhans
        ]);
    }

    // Lấy tin nhắn theo ID
    public function getMessage($id)
    {
        $tinNhan = TinNhan::find($id);

        if (!$tinNhan) {
            return response()->json([
                'success' => false,
                'message' => "Message not found with ID: $id"
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $tinNhan
        ]);
    }

    // Lấy tin nhắn giữa hai người
    public function getMessagesBetweenUsers($maNguoigui, $maNguoinhan)
    {
        $tinNhans = TinNhan::where(function ($query) use ($maNguoigui, $maNguoinhan) {
            $query->where('maNguoigui', $maNguoigui)
                  ->where('maNguoinhan', $maNguoinhan)
                  ->where('trangthai', '!=', 'xoa'); // Chỉ loại bỏ tin nhắn có trạng thái "xoa"
        })->orWhere(function ($query) use ($maNguoigui, $maNguoinhan) {
            $query->where('maNguoigui', $maNguoinhan)
                  ->where('maNguoinhan', $maNguoigui)
                  ->where('trangthai', '!=', 'xoa'); // Chỉ loại bỏ tin nhắn có trạng thái "xoa"
        })
        ->orderBy('thoiGianGui', 'asc')
        ->get();
    
        return response()->json([
            'success' => true,
            'data' => $tinNhans
        ]);
    }
    


    // Đánh dấu tin nhắn đã xem
    public function markAsRead($id)
    {
        $tinNhan = TinNhan::find($id);

        if (!$tinNhan) {
            return response()->json([
                'success' => false,
                'message' => "Message not found with ID: $id"
            ]);
        }

        $tinNhan->update(['daXem' => true, 'thoiGianXem' => now()]);

        return response()->json([
            'success' => true,
            'message' => "Message marked as read!",
            'data' => $tinNhan
        ]);
    }

    // Xóa tin nhắn
    public function deleteMessage($id)
    {
        $tinNhan = TinNhan::find($id);
    
        if (!$tinNhan) {
            return response()->json([
                'success' => false,
                'message' => "Message not found with ID: $id"
            ]);
        }
    
        // Kiểm tra trạng thái hiện tại
        if ($tinNhan->trangthai != 'xoa') {
            // In ra trạng thái trước khi cập nhật
            \Log::info("Updating message $id, current status: " . $tinNhan->trangthai);
    
            // Cập nhật trạng thái
            $updated = $tinNhan->update(['trangthai' => 'xoa']);
    
            // Kiểm tra xem việc cập nhật có thành công không
            if ($updated) {
                \Log::info("Message $id successfully updated to 'xoa'");
            } else {
                \Log::error("Failed to update message $id");
            }
        }
    
        return response()->json([
            'success' => true,
            'message' => "Message ID: $id marked as deleted!"
        ]);
    }
    
    
    public function thuHoiMessage($id)
{
    $tinNhan = TinNhan::find($id);

    if (!$tinNhan) {
        return response()->json([
            'success' => false,
            'message' => "Message not found with ID: $id"
        ]);
    }

    // Nếu trạng thái là 'bt', thay đổi thành 'thuhoi' và cập nhật nội dung
    if ($tinNhan->trangthai != 'thuhoi') {
        $tinNhan->update([
            'trangthai' => 'thuhoi',
            'noiDung' => 'Tin nhắn đã được thu hồi'
        ]);
    } 
    // Nếu trạng thái là 'thuhoi', thay đổi thành 'xoa'
    else if ($tinNhan->trangthai != 'xoa') {
        $tinNhan->update(['trangthai' => 'xoa']);
    }

    return response()->json([
        'success' => true,
        'message' => "Message ID: $id marked as deleted or recalled!"
    ]);
}


    // Tìm kiếm tin nhắn theo từ khóa
    public function searchMessages(Request $request)
    {
        $validated = $request->validate([
            'keyword' => 'required|string',
        ]);

        $tinNhans = TinNhan::where('noiDung', 'like', '%' . $request->keyword . '%')
            ->orderBy('thoiGianGui', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $tinNhans
        ]);
    }

    // Gửi hình ảnh
    public function sendImage(Request $request)
    {
        // Kiểm tra và xác thực các tham số
        $validated = $request->validate([
            'maNguoigui' => 'required|integer',
            'maNguoinhan' => 'required|integer',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);
    
        try {
            // Kiểm tra xem tệp có hợp lệ không
            if ($request->hasFile('image') && $request->file('image')->isValid()) {
                // Lưu tệp hình ảnh vào thư mục 'images' trong public
                $imagePath = $request->file('image')->store('images', 'public');
    
                // Tạo tin nhắn với đường dẫn tới hình ảnh đã lưu
                $tinNhan = TinNhan::create([
                    'maNguoigui' => $request->maNguoigui,
                    'maNguoinhan' => $request->maNguoinhan,
                    'noiDung' => 'Image message',
                    'duongDanMedia' => $imagePath, // Lưu đường dẫn tệp hình ảnh vào trường duongDanMedia
                    'thoiGianGui' => now(),
                    'loaiTinnhan' => $request->loaiTinnhan ?? 'image',
                ]);
    
                return response()->json([
                    'success' => true,
                    'message' => 'Image sent successfully!',
                    'data' => $tinNhan
                ]);
            } else {
                // Nếu không có tệp hoặc tệp không hợp lệ
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid or missing image file.',
                ], 400); // Trả về mã lỗi 400 cho yêu cầu sai
            }
        } catch (\Exception $e) {
            // Nếu có lỗi xảy ra trong quá trình lưu trữ tệp hoặc cơ sở dữ liệu
            return response()->json([
                'success' => false,
                'message' => 'Error while sending image!',
                'error' => $e->getMessage(), // Trả về thông báo lỗi
            ], 500); // Trả về mã lỗi 500 cho lỗi máy chủ
        }
    }
    public function recallMessage($id)
{
    $tinNhan = TinNhan::find($id);

    if (!$tinNhan) {
        return response()->json([
            'success' => false,
            'message' => "Message not found with ID: $id"
        ]);
    }

    // Thay đổi nội dung tin nhắn thành "Tin nhắn đã được thu hồi"
    $tinNhan->update([
        'trangthai' => 'thuhoi',  // Đánh dấu trạng thái là thu hồi
        'noiDung' => 'Tin nhắn đã được thu hồi',  // Thay đổi nội dung tin nhắn
    ]);

    return response()->json([
        'success' => true,
        'message' => "Message ID: $id has been recalled!",
        'data' => $tinNhan
    ]);
}

    public function getConversations($maNguoidung)
    {
        // Lấy tất cả các tin nhắn gửi đi và nhận được bởi người dùng
        $messages = TinNhan::where('maNguoigui', $maNguoidung)
            ->orWhere('maNguoinhan', $maNguoidung)
            ->get();

        // Mảng để lưu các cuộc trò chuyện
        $conversations = [];

        // Duyệt qua tất cả tin nhắn để nhóm theo người gửi và người nhận
        foreach ($messages as $message) {
            // Lấy ID người nhận (nếu người dùng là người gửi, người nhận là người kia)
            $otherUserId = $message->maNguoigui == $maNguoidung ? $message->maNguoinhan : $message->maNguoigui;

            // Nếu người nhận chưa có trong danh sách cuộc trò chuyện
            if (!isset($conversations[$otherUserId])) {
                // Lấy thông tin người nhận
                $recipient = NguoiDung::find($otherUserId);

                // Lấy tin nhắn cuối cùng giữa người dùng và người nhận
                $lastMessage = TinNhan::where(function ($query) use ($maNguoidung, $otherUserId) {
                    $query->where('maNguoigui', $maNguoidung)
                          ->where('maNguoinhan', $otherUserId);
                })
                ->orWhere(function ($query) use ($maNguoidung, $otherUserId) {
                    $query->where('maNguoigui', $otherUserId)
                          ->where('maNguoinhan', $maNguoidung);
                })
                ->latest();
                // Lưu cuộc trò chuyện vào mảng
                $conversations[$otherUserId] = [
                    'maNguoinhan' => $otherUserId,
                    'tenHienthi' => $recipient ? $recipient->tenHienthi : 'Unknown',
                    // 'noiDung' => $lastMessage ? $lastMessage->noiDung : 'No messages',
                    // 'thoiGianGui' => $lastMessage ? $lastMessage->thoiGianGui : 'N/A',
                ];
            }
        }

        // Trả về danh sách cuộc trò chuyện
        return response()->json(['success' => true, 'data' => array_values($conversations)]);
    }
}
