-- ========================================================
-- PROJECT BY KD - SCRIPT HUB (AUTO-POS, AUTO-DC & HUD BUTTON)
-- ========================================================

-- Variabel Konfigurasi & Status
_G.KD_SpamRunning = false
_G.KD_SpamText = _G.KD_SpamText or "Beli Script Premium di KD Group!"
_G.KD_SpamDelay = _G.KD_SpamDelay or 3500
_G.KD_TargetWorld = _G.KD_TargetWorld or ""
_G.KD_TargetX = _G.KD_TargetX or 0
_G.KD_TargetY = _G.KD_TargetY or 0

-- 1. Helper: Pembaca Nilai Dialog
function GetValue(packet, key)
    for line in packet:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^|]+)|(.*)$")
        if k == key then return v end
    end
    return nil
end

-- 2. Helper: Pembaca Koordinat & World
function GetCurrentPos()
    local me = GetLocal()
    if not me then return 0, 0 end
    local x = me.tile_x or (me.pos_x and math.floor(me.pos_x / 32)) or (me.x and math.floor(me.x / 32)) or 0
    local y = me.tile_y or (me.pos_y and math.floor(me.pos_y / 32)) or (me.y and math.floor(me.y / 32)) or 0
    return x, y
end

function GetCurrentWorldName()
    if GetWorld and GetWorld() and GetWorld().name then
        return GetWorld().name
    end
    return _G.KD_TargetWorld or ""
end

-- 3. Helper: Delay & Pathfind Aman (Anti-Crash Bothax)
function SafeSleep(ms)
    if type(sleep) == "function" then
        sleep(ms)
    elseif type(Sleep) == "function" then
        Sleep(ms)
    end
end

function SafeMove(x, y)
    if type(FindPath) == "function" then
        FindPath(x, y)
    elseif type(Move) == "function" then
        Move(x, y)
    end
end

-- 4. TAMPILAN MENU UTAMA
function ShowMainMenu()
    local statusSpam = _G.KD_SpamRunning and "[AKTIF]" or "[OFF]"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wPROJECT BY KD - SCRIPT HUB``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Pilih script yang ingin kamu gunakan:|left|\n" ..
              "add_spacer|small|\n" ..
              "add_button|menu_spam|1. Auto Spam & Pos Guard " .. statusSpam .. "|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_button|menu_bfg|2. Auto BFG (Coming Soon)|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_button|menu_casino|3. Auto Casino (Coming Soon)|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_textbox|`oTekan `2Tombol Emote (Senyum) `odi layar untuk buka menu.|left|\n" ..
              "add_quick_exit|\n" ..
              "end_dialog|kd_hub|Tutup||\n"

    SendVariantList({[0] = "OnDialogRequest", [1] = d, netid = -1})
end

-- 5. TAMPILAN PENGATURAN AUTO SPAM & POSISI
function ShowSpamMenu()
    local statusText = _G.KD_SpamRunning and "`2SEDANG BERJALAN``" or "`4BERHENTI (OFF)``"
    local tw = _G.KD_TargetWorld ~= "" and _G.KD_TargetWorld or "BELUM DIKUNCI"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wKD HUB - AUTO SPAM & POS GUARD``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Status: " .. statusText .. "|left|\n" ..
              "add_textbox|`oWorld Terkunci: `2" .. tw .. " `o| Pos: `2X: " .. tostring(_G.KD_TargetX) .. ", Y: " .. tostring(_G.KD_TargetY) .. "``|left|\n" ..
              "add_spacer|small|\n" ..
              "add_button|btn_grab_pos|[ AMBIL POSISI & WORLD OTOMATIS ]|noflags|0|0|\n" ..
              "add_textbox| |left|\n" ..
              "add_text_input|cfg_text|Pesan Chat:|" .. (_G.KD_SpamText or "") .. "|40|\n" ..
              "add_spacer|small|\n" ..
              "add_text_input|cfg_delay|Delay (ms):|" .. tostring(_G.KD_SpamDelay or 3500) .. "|6|\n" ..
              "add_spacer|small|\n"

    if _G.KD_SpamRunning then
        d = d .. "add_button|btn_stop_spam|[ STOP ] Matikan Auto Spam|noflags|0|0|\n"
    else
        d = d .. "add_button|btn_start_spam|[ START ] Jalankan Auto Spam|noflags|0|0|\n"
    end

    d = d .. "add_textbox| |left|\n" ..
             "add_button|btn_back_hub|<< Kembali ke Menu Utama|noflags|0|0|\n" ..
             "add_quick_exit|\n" ..
             "end_dialog|kd_spam_menu|Tutup||\n"

    SendVariantList({[0] = "OnDialogRequest", [1] = d, netid = -1})
end

-- 6. LOGIKA AUTO SPAM, POS GUARD & ANTI-DC
function StartSpamLoop()
    if _G.KD_SpamRunning then return end
    _G.KD_SpamRunning = true
    LogToConsole("`2[KD Group] `aAuto Spam & Pos Guard aktif! Tekan tombol Emote untuk STOP.")

    local function spamWorker()
        while _G.KD_SpamRunning do
            local currentWorld = GetCurrentWorldName()

            -- A. Auto-Rejoin World jika DC / Terlempar
            if _G.KD_TargetWorld ~= "" and currentWorld:upper() ~= _G.KD_TargetWorld:upper() then
                LogToConsole("`4[KD Group] `oWorld tidak sesuai! Masuk kembali ke: " .. _G.KD_TargetWorld)
                SendPacket(3, "action|join_request\nname|" .. _G.KD_TargetWorld .. "\ninvitedWorld|0")
                SafeSleep(4000)
            else
                -- B. Auto-Return ke Pos X, Y jika bergeser / dipukul
                if _G.KD_TargetX > 0 and _G.KD_TargetY > 0 then
                    local myX, myY = GetCurrentPos()
                    if myX ~= _G.KD_TargetX or myY ~= _G.KD_TargetY then
                        SafeMove(_G.KD_TargetX, _G.KD_TargetY)
                        SafeSleep(600)
                    end
                end

                -- C. Kirim Pesan Chat Spam
                local msg = _G.KD_SpamText or "KD Group on Top!"
                SendPacket(2, "action|input\n|text|" .. msg)

                -- D. Jeda Waktu
                local dly = tonumber(_G.KD_SpamDelay) or 3500
                SafeSleep(dly)
            end
        end
        LogToConsole("`4[KD Group] `cAuto Spam telah berhenti.")
    end

    -- Eksekusi Thread dengan penanganan error
    if type(run_thread) == "function" then
        run_thread(spamWorker)
    elseif type(RunThread) == "function" then
        RunThread(spamWorker)
    elseif type(thread) == "function" then
        thread(spamWorker)
    else
        local co = coroutine.create(function()
            local ok, err = pcall(spamWorker)
            if not ok then
                LogToConsole("`4[KD Error] Loop terhenti: " .. tostring(err))
            end
        end)
        coroutine.resume(co)
    end
end

-- 7. HOOK PAKET (DETEKSI KLIK TOMBOL & TOMBOL EMOTE DI LAYAR)
function KD_PacketHook(type, packet)
    -- A. Deteksi Tekan Tombol Emote di layar HP untuk buka menu
    if type == 2 and packet:find("action|action") and (packet:find("emote") or packet:find("cheer")) then
        ShowMainMenu()
        return true
    end

    -- B. Cadangan Buka Menu via Chat (/kd, /menu, atau /cheer)
    if type == 2 and packet:find("action|input") then
        local chat = packet:match("text|(/%w+)")
        if chat == "/kd" or chat == "/menu" or chat == "/cheer" or chat == "/smile" then
            ShowMainMenu()
            return true
        end
    end

    -- C. Respon Klik di Menu Utama (Hub)
    if type == 2 and packet:find("dialog_name|kd_hub") then
        if packet:find("buttonClicked|menu_spam") then
            ShowSpamMenu()
            return true
        elseif packet:find("buttonClicked|menu_bfg") or packet:find("buttonClicked|menu_casino") then
            LogToConsole("`4[KD Group] `oFitur ini sedang disiapkan!")
            ShowMainMenu()
            return true
        end
    end

    -- D. Respon Klik di Menu Auto Spam
    if type == 2 and packet:find("dialog_name|kd_spam_menu") then
        local inputTxt = GetValue(packet, "cfg_text")
        local inputDly = GetValue(packet, "cfg_delay")
        if inputTxt and inputTxt ~= "" then _G.KD_SpamText = inputTxt end
        if inputDly and tonumber(inputDly) then _G.KD_SpamDelay = tonumber(inputDly) end

        -- Ambil Posisi dan World Otomatis
        if packet:find("buttonClicked|btn_grab_pos") then
            local wx, wy = GetCurrentPos()
            local ww = GetCurrentWorldName()
            _G.KD_TargetWorld = ww
            _G.KD_TargetX = wx
            _G.KD_TargetY = wy
            LogToConsole("`2[KD Group] `aPosisi Terkunci! World: " .. ww .. " (X: " .. wx .. ", Y: " .. wy .. ")")
            ShowSpamMenu()
            return true
        end

        -- Start Spam
        if packet:find("buttonClicked|btn_start_spam") then
            StartSpamLoop()
            return true
        end

        -- Stop Spam
        if packet:find("buttonClicked|btn_stop_spam") then
            _G.KD_SpamRunning = false
            ShowSpamMenu()
            return true
        end

        -- Kembali
        if packet:find("buttonClicked|btn_back_hub") then
            ShowMainMenu()
            return true
        end
    end

    return false
end

-- Registrasi Hook
if type(AddHook) == "function" then
    AddHook("OnSendPacket", "KD_Hook", KD_PacketHook)
elseif type(hook) == "function" then
    hook("sendpacket", KD_PacketHook)
end

-- Tampilkan Menu Pertama Kali
ShowMainMenu()
