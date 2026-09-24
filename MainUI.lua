-- ========================================================
-- PROJECT BY KD - SCRIPT HUB (CLEAN UI & SINGLE ROW FIX)
-- ========================================================

-- Variabel Status & Konfigurasi Global
_G.KD_SpamRunning = false
_G.KD_SpamText = _G.KD_SpamText or "Beli Script Premium di KD Group!"
_G.KD_SpamDelay = _G.KD_SpamDelay or 3500

-- Fungsi Parser untuk membaca nilai input dialog
function GetValue(packet, key)
    for line in packet:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^|]+)|(.*)$")
        if k == key then return v end
    end
    return nil
end

-- 1. TAMPILAN MENU UTAMA (LIST SCRIPT VERTIKAL RAPI)
function ShowMainMenu()
    local statusSpam = _G.KD_SpamRunning and "[AKTIF]" or "[OFF]"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wPROJECT BY KD - SCRIPT HUB``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Pilih script yang ingin kamu gunakan:|left|\n" ..
              "add_spacer|small|\n" ..
              "add_button|menu_spam|1. Auto Spam Chat " .. statusSpam .. "|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_button|menu_bfg|2. Auto BFG (Coming Soon)|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_button|menu_casino|3. Auto Casino (Coming Soon)|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_textbox|`oBuka menu: Ketik `2/kd `oatau `2Wrench karaktermu``.|left|\n" ..
              "add_quick_exit|\n" ..
              "end_dialog|kd_hub|Tutup||\n"

    SendVariantList({[0] = "OnDialogRequest", [1] = d, netid = -1})
end

-- 2. TAMPILAN PENGATURAN & KONTROL AUTO SPAM
function ShowSpamMenu()
    local statusText = _G.KD_SpamRunning and "`2SEDANG BERJALAN``" or "`4BERHENTI (OFF)``"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wKD HUB - AUTO SPAM``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Status Script: " .. statusText .. "|left|\n" ..
              "add_spacer|small|\n" ..
              "add_text_input|cfg_text|Pesan Chat:|" .. (_G.KD_SpamText or "") .. "|40|\n" ..
              "add_spacer|small|\n" ..
              "add_text_input|cfg_delay|Delay (ms):|" .. tostring(_G.KD_SpamDelay or 3500) .. "|6|\n" ..
              "add_spacer|small|\n"

    -- Tombol Start/Stop mandiri tanpa kode warna perusak
    if _G.KD_SpamRunning then
        d = d .. "add_button|btn_stop_spam|HENTIKAN AUTO SPAM (STOP)|noflags|0|0|\n"
    else
        d = d .. "add_button|btn_start_spam|JALANKAN AUTO SPAM (START)|noflags|0|0|\n"
    end

    d = d .. "add_textbox| |left|\n" ..
             "add_button|btn_back_hub|Kembali ke Menu Utama|noflags|0|0|\n" ..
             "add_quick_exit|\n" ..
             "end_dialog|kd_spam_menu|Tutup||\n"

    SendVariantList({[0] = "OnDialogRequest", [1] = d, netid = -1})
end

-- 3. RUNNER BACKGROUND THREAD
local function RunThreadSafe(func)
    if type(run_thread) == "function" then
        run_thread(func)
    elseif type(make_thread) == "function" then
        make_thread(func)
    elseif type(CreateThread) == "function" then
        CreateThread(func)
    else
        local co = coroutine.create(func)
        coroutine.resume(co)
    end
end

-- 4. LOGIKA AUTO SPAM
function StartSpamLoop()
    if _G.KD_SpamRunning then return end
    _G.KD_SpamRunning = true
    LogToConsole("`2[KD Group] `aAuto Spam dimulai! Ketuk karaktermu atau ketik /kd untuk STOP.")

    RunThreadSafe(function()
        while _G.KD_SpamRunning do
            local msg = _G.KD_SpamText or "KD Group on Top!"
            local dly = tonumber(_G.KD_SpamDelay) or 3500
            SendPacket(2, "action|input\n|text|" .. msg)
            Sleep(dly)
        end
        LogToConsole("`4[KD Group] `cAuto Spam telah dihentikan.")
    end)
end

-- 5. HOOK KONTROL KLIK, SELF-WRENCH, & CHAT
function KD_PacketHook(type, packet)
    -- Buka menu lewat Wrench karakter sendiri
    if type == 2 and packet:find("action|wrench") then
        local targetNetID = tonumber(packet:match("netid|(%d+)"))
        if targetNetID and GetLocal and GetLocal().netid == targetNetID then
            ShowMainMenu()
            return true
        end
    end

    -- Buka menu lewat Chat /kd atau /menu
    if type == 2 and packet:find("action|input") then
        local chat = packet:match("text|(/%w+)")
        if chat == "/kd" or chat == "/menu" then
            ShowMainMenu()
            return true
        end
    end

    -- Respon Klik di Menu Utama (kd_hub)
    if type == 2 and packet:find("dialog_name|kd_hub") then
        if packet:find("buttonClicked|menu_spam") then
            ShowSpamMenu()
            return true
        elseif packet:find("buttonClicked|menu_bfg") or packet:find("buttonClicked|menu_casino") then
            LogToConsole("`4[KD Group] `oFitur ini sedang disiapkan untuk update berikutnya!")
            ShowMainMenu()
            return true
        end
    end

    -- Respon Klik di Menu Auto Spam (kd_spam_menu)
    if type == 2 and packet:find("dialog_name|kd_spam_menu") then
        local inputTxt = GetValue(packet, "cfg_text")
        local inputDly = GetValue(packet, "cfg_delay")
        if inputTxt and inputTxt ~= "" then _G.KD_SpamText = inputTxt end
        if inputDly and tonumber(inputDly) then _G.KD_SpamDelay = tonumber(inputDly) end

        -- Klik START
        if packet:find("buttonClicked|btn_start_spam") then
            StartSpamLoop()
            return true
        end

        -- Klik STOP
        if packet:find("buttonClicked|btn_stop_spam") then
            _G.KD_SpamRunning = false
            ShowSpamMenu()
            return true
        end

        -- Klik KEMBALI
        if packet:find("buttonClicked|btn_back_hub") then
            ShowMainMenu()
            return true
        end
    end

    return false
end

-- Registrasi Hook ke Bothax
if type(AddHook) == "function" then
    AddHook("OnSendPacket", "KD_Hook", KD_PacketHook)
elseif type(hook) == "function" then
    hook("sendpacket", KD_PacketHook)
end

-- Tampilkan Menu Utama pertama kali saat script di-run
ShowMainMenu()
