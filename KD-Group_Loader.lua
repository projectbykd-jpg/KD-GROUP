-- ==========================================
-- LOADER PREMIUM BY KD GROUP
-- ==========================================
local url = "https://raw.githubusercontent.com/projectbykd-jpg/KD-GROUP/main/MainScript.lua"

-- Eksekusi file dari GitHub (Gunakan salah satu fungsi di bawah tergantung executor)
-- Standar fungsi Bothax/Powerkuy:
load(MakeRequest(url, "GET").content)()

-- Atau jika executornya khusus mewajibkan fungsi LoadEncrypt:
-- LoadEncrypt(MakeRequest(url, "GET").content)
