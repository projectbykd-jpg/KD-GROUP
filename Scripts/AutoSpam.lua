-- ==========================================
-- KD GROUP - MODULE: AUTO SPAM
-- ==========================================
LogToConsole("`2[KD Group] `aAuto Spam Berjalan Sukses!")

-- Mengambil teks dan delay yang diset oleh user di dialog
local textToSend = _G.KD_SpamText or "KD Group on Top!"
local delayTime = _G.KD_SpamDelay or 3500

function RunSpam()
    while true do
        SendPacket(2, "action|input\n|text|" .. textToSend)
        Sleep(delayTime)
    end
end

RunSpam()
