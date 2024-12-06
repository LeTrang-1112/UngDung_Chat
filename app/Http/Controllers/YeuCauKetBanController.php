<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\YeuCauKetBan;

class YeuCauKetBanController extends Controller
{
    // Tạo yêu cầu kết bạn
    public function create(Request $request)
    {
        $validated = $request->validate([
            'maNguoiGui'   => 'required|integer',
            'maNguoiNhan'  => 'required|integer',
        ]);

        try {
            $yeuCau = YeuCauKetBan::create([
                'maNguoiGui'  => $request->maNguoiGui,
                'maNguoiNhan' => $request->maNguoiNhan,
                'trangThai'   => $request->trangThai ?? 'choXuLy',  // Default to 'choXuLy'
            ]);

            return response()->json([
                'success'   => true,
                'message'   => 'Request sent successfully!',
                'data'      => $yeuCau
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success'   => false,
                'message'   => 'Error while sending request!',
                'error'     => $e->getMessage()
            ]);
        }
    }

    // Lấy tất cả yêu cầu kết bạn
    public function getAll()
    {
        $yeuCaus = YeuCauKetBan::all();
        return response()->json([
            'success'   => true,
            'data'      => $yeuCaus
        ]);
    }

    // Lấy yêu cầu kết bạn theo ID
    public function getRequest($id)
{
    $yeuCau = YeuCauKetBan::where('maYeuCau', $id)->first();

    if (empty($yeuCau)) {
        return response()->json([
            'success'   => false,
            'message'   => "Request not found with ID: $id"
        ]);
    }

    return response()->json([
        'success'   => true,
        'data'      => $yeuCau
    ]);
}


    // Cập nhật trạng thái yêu cầu kết bạn
    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'trangThai' => 'required|string|in:choXuLy,chapNhan,tuChoi',
        ]);
    
        $yeuCau = YeuCauKetBan::where('maYeuCau', $id)->first();
    
        if (empty($yeuCau)) {
            return response()->json([
                'success'   => false,
                'message'   => "Request not found with ID: $id"
            ]);
        }
    
        $yeuCau->update(['trangThai' => $request->trangThai]);
    
        return response()->json([
            'success'   => true,
            'message'   => "Request status updated successfully!",
            'data'      => $yeuCau
        ]);
    }
    

    // Xóa yêu cầu kết bạn
    public function delete($id)
{
    $yeuCau = YeuCauKetBan::where('maYeuCau', $id)->first();

    if (empty($yeuCau)) {
        return response()->json([
            'success'   => false,
            'message'   => "Request not found with ID: $id"
        ]);
    }

    $yeuCau->delete();

    return response()->json([
        'success'   => true,
        'message'   => "Deleted request ID: $id successfully!"
    ]);
}

}
