-- ==========================================
-- KD GROUP - AUTO SPAM (TEST 1)
-- ==========================================
local textSpam = "Jual Script GTPS Terpercaya hanya di KD Group!"
local delaySpam = 3500 -- Delay 3.5 detik (3500 ms) agar aman dari auto-mute

-- Menampilkan pesan di console executor saat script jalan
LogToConsole("`2[KD Group] `9Script Auto Spam Aktif!")

-- Looping tanpa batas untuk mengirim chat
while true do
    SendPacket(2, "action|input\n|text|" .. textSpam)
    Sleep(delaySpam)
end
