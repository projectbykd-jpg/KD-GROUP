-- ========================================================
-- PROJECT BY KD - SCRIPT HUB (FULL SYSTEM & LIST)
-- ========================================================

-- Variabel Status & Konfigurasi Global
_G.KD_SpamRunning = false
_G.KD_SpamText = _G.KD_SpamText or "Beli Script Premium di KD Group!"
_G.KD_SpamDelay = _G.KD_SpamDelay or 3500

-- Fungsi Membaca Isi Input Dialog
-- Hook pendeteksi klik karakter sendiri (Self-Wrench) & Chat /kd
function KD_PacketHook(type, packet)
    -- 1. Deteksi Wrench Diri Sendiri (Tinggal klik karaktermu sendiri)
    if type == 2 and packet:find("action|wrench") then
        local targetNetID = tonumber(packet:match("netid|(%d+)"))
        
        -- Cek apakah yang di-wrench adalah diri sendiri
        if targetNetID and GetLocal and GetLocal().netid == targetNetID then
            ShowMainMenu()
            return true -- Blok dialog wrench bawaan game
        end
    end

    -- 2. Cadangan: Buka lewat Chat /kd
    if type == 2 and packet:find("action|input") then
        local chat = packet:match("text|(/%w+)")
        if chat == "/kd" or chat == "/menu" then
            ShowMainMenu()
            return true
        end
    end

    -- Logika tombol dialog tetap berjalan seperti biasa di bawah sini...
    return false
end

-- 1. TAMPILAN MENU UTAMA (LIST SCRIPT)
function ShowMainMenu()
    local statusSpam = _G.KD_SpamRunning and "`2[AKTIF]``" or "`4[OFF]``"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wPROJECT BY KD - SCRIPT HUB``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Pilih script yang ingin kamu gunakan di bawah ini:|left|\n" ..
              "add_spacer|small|\n" ..
              "add_button|menu_spam|📢 Auto Spam Chat " .. statusSpam .. "|noflags|0|0|\n" ..
              "add_button|menu_bfg|⛏️ Auto BFG (`8Coming Soon`o)|noflags|0|0|\n" ..
              "add_button|menu_casino|🎰 Auto Casino (`8Coming Soon`o)|noflags|0|0|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`oKetik `2/kd `odi chat in-game untuk membuka menu ini.|left|\n" ..
              "end_dialog|kd_hub|Tutup||"

    SendVariantList({[0] = "OnDialogRequest", [1] = d, netid = -1})
end

-- 2. TAMPILAN MENU AUTO SPAM (PENGATURAN & KONTROL)
function ShowSpamMenu()
    local statusText = _G.KD_SpamRunning and "`2● SEDANG BERJALAN" or "`4● NON-AKTIF (STOPPED)"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wKD HUB - AUTO SPAM``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Status Script: " .. statusText .. "|left|\n" ..
              "add_spacer|small|\n" ..
              "add_text_input|cfg_text|Pesan Chat:|" .. _G.KD_SpamText .. "|50|\n" ..
              "add_text_input|cfg_delay|Delay (ms):|" .. _G.KD_SpamDelay .. "|6|\n" ..
              "add_spacer|small|\n"

    -- Jika sedang jalan tampilkan tombol STOP, jika mati tampilkan tombol START
    if _G.KD_SpamRunning then
        d = d .. "add_button|btn_stop_spam|⏹ STOP AUTO SPAM|noflags|0|0|\n"
    else
        d = d .. "add_button|btn_start_spam|▶ JALANKAN AUTO SPAM|noflags|0|0|\n"
    end

    d = d .. "add_button|btn_back_hub|⬅ Kembali ke Daftar Script|noflags|0|0|\n" ..
             "end_dialog|kd_spam_menu|Tutup||"

    SendVariantList({[0] = "OnDialogRequest", [1] = d, netid = -1})
end

-- 3. LOGIKA THREAD AUTO SPAM
function StartSpamLoop()
    if _G.KD_SpamRunning then return end
    _G.KD_SpamRunning = true
    LogToConsole("`2[KD Group] `aAuto Spam dimulai! Ketik /kd untuk membuka menu stop.")

    local function spamThread()
        while _G.KD_SpamRunning do
            local msg = _G.KD_SpamText or "KD Group on Top!"
            local dly = tonumber(_G.KD_SpamDelay) or 3500
            SendPacket(2, "action|input\n|text|" .. msg)
            Sleep(dly)
        end
        LogToConsole("`4[KD Group] `cAuto Spam telah dimatikan.")
    end

    if type(run_thread) == "function" then
        run_thread(spamThread)
    else
        local co = coroutine.create(spamThread)
        coroutine.resume(co)
    end
end

-- 4. HOOK PACKET INTERACTION
function KD_PacketHook(type, packet)
    -- Perintah Chat /kd untuk membuka menu
    if type == 2 and packet:find("action|input") then
        local chat = packet:match("text|(/%w+)")
        if chat == "/kd" or chat == "/menu" then
            ShowMainMenu()
            return true
        end
    end

    -- Menangani Klik di Menu Utama (Hub)
    if type == 2 and packet:find("dialog_name|kd_hub") then
        if packet:find("buttonClicked|menu_spam") then
            ShowSpamMenu()
            return true
        elseif packet:find("buttonClicked|menu_bfg") or packet:find("buttonClicked|menu_casino") then
            LogToConsole("`4[KD Group] `oScript ini sedang dalam tahap pengembangan!")
            ShowMainMenu()
            return true
        end
    end

    -- Menangani Klik di Menu Auto Spam
    if type == 2 and packet:find("dialog_name|kd_spam_menu") then
        -- Simpan isi konfigurasi yang baru diketik
        local inputTxt = GetValue(packet, "cfg_text")
        local inputDly = GetValue(packet, "cfg_delay")
        if inputTxt then _G.KD_SpamText = inputTxt end
        if inputDly then _G.KD_SpamDelay = inputDly end

        if packet:find("buttonClicked|btn_start_spam") then
            StartSpamLoop()
            return true
        elseif packet:find("buttonClicked|btn_stop_spam") then
            _G.KD_SpamRunning = false
            return true
        elseif packet:find("buttonClicked|btn_back_hub") then
            ShowMainMenu()
            return true
        end
    end

    return false
end

-- Pendaftaran Hook ke Bothax
if type(AddHook) == "function" then
    AddHook("OnSendPacket", "KDHookSystem", KD_PacketHook)
elseif type(hook) == "function" then
    hook("sendpacket", KD_PacketHook)
end

-- Tampilkan Menu Utama saat pertama kali di-run
ShowMainMenu()
