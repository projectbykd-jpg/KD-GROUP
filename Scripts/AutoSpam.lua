-- ==========================================
-- KD GROUP - MODULE: AUTO SPAM
-- ==========================================

-- Pengaturan dasar (Nanti bisa dihubungkan agar teksnya diambil dari input UI)
local spamText = "Jual Script Premium GTPS Terpercaya hanya di KD Group!"
local spamDelay = 3500 -- Delay 3.5 detik (3500 milidetik) agar tidak kena auto-mute

-- Menampilkan notifikasi di console/chat box in-game
LogToConsole("`2[KD Group] `9Modul Auto Spam Berhasil Diunduh dan Berjalan!")

-- Fungsi utama untuk melakukan spam
function StartSpamming()
    while true do
        -- SendPacket(2, ...) adalah fungsi Bothax/Powerkuy untuk mengirim pesan chat
        SendPacket(2, "action|input\n|text|" .. spamText)
        
        -- Sleep WAJIB ada di dalam loop (while true) agar game tidak freeze/crash
        Sleep(spamDelay) 
    end
end

-- Mengeksekusi fungsi spam
StartSpamming()
