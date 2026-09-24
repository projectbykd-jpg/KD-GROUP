-- ========================================================
-- PROJECT BY KD - SCRIPT HUB (FIXED AUTO-WALK & POS GUARD)
-- ========================================================

-- Variabel Status & Konfigurasi Global
_G.KD_SpamRunning = false
_G.KD_SpamText = _G.KD_SpamText or "Beli Script Premium di KD Group!"
_G.KD_SpamDelay = _G.KD_SpamDelay or 3500
_G.KD_TargetWorld = _G.KD_TargetWorld or ""
_G.KD_TargetX = _G.KD_TargetX or nil
_G.KD_TargetY = _G.KD_TargetY or nil

-- 1. Helper Pembaca Data Dialog
function GetValue(packet, key)
    for line in packet:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^|]+)|(.*)$")
        if k == key then return v end
    end
    return nil
end

-- 2. Helper Pembaca Koordinat Akurat Bothax
function GetCurrentPos()
    local me = (type(GetLocal) == "function" and GetLocal()) or (type(getLocal) == "function" and getLocal())
    if not me then return 0, 0 end

    -- Cek format Tile langsung
    if me.tile_x and me.tile_y then return me.tile_x, me.tile_y end
    if me.tileX and me.tileY then return me.tileX, me.tileY end

    -- Cek format Vektor Objek (Standar Bothax Android)
    local rawX, rawY = nil, nil
    if type(me.pos) == "userdata" or type(me.pos) == "table" then
        rawX, rawY = me.pos.x, me.pos.y
    elseif me.pos_x and me.pos_y then
        rawX, rawY = me.pos_x, me.pos_y
    elseif me.x and me.y then
        rawX, rawY = me.x, me.y
    end

    if rawX and rawY then
        return math.floor(rawX / 32), math.floor(rawY / 32)
    end

    return 0, 0
end

-- 3. Helper Pembaca Nama World
function GetCurrentWorldName()
    local w = (type(GetWorld) == "function" and GetWorld()) or (type(getWorld) == "function" and getWorld())
    if w and w.name and w.name ~= "" then
        return w.name
    end
    return _G.KD_TargetWorld or ""
end

-- 4. Helper Delay & Navigasi Berjalan (Dukungan Huruf Kecil & Besar)
function SafeSleep(ms)
    if type(sleep) == "function" then
        sleep(ms)
    elseif type(Sleep) == "function" then
        Sleep(ms)
    end
end

function SafeMove(tx, ty)
    if type(findPath) == "function" then
        findPath(tx, ty)
    elseif type(FindPath) == "function" then
        FindPath(tx, ty)
    elseif type(move) == "function" then
        move(tx, ty)
    elseif type(Move) == "function" then
        Move(tx, ty)
    end
end

-- 5. TAMPILAN MENU UTAMA
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

-- 6. TAMPILAN PENGATURAN SPAM & POSISI
function ShowSpamMenu()
    local statusText = _G.KD_SpamRunning and "`2SEDANG BERJALAN``" or "`4BERHENTI (OFF)``"
    local tw = _G.KD_TargetWorld ~= "" and _G.KD_TargetWorld or "BELUM DIKUNCI"
    local posText = (_G.KD_TargetX and _G.KD_TargetY) and ("X: " .. _G.KD_TargetX .. ", Y: " .. _G.KD_TargetY) or "BELUM DISET"

    local d = "set_default_color|`o\n" ..
              "add_label_with_icon|big|`wKD HUB - AUTO SPAM & POS GUARD``|left|11550|\n" ..
              "add_spacer|small|\n" ..
              "add_textbox|`9Status: " .. statusText .. "|left|\n" ..
              "add_textbox|`oWorld: `2" .. tw .. " `o| Pos Kunci: `2" .. posText .. "``|left|\n" ..
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

-- 7. THREAD EKSEKUSI AUTO SPAM, POS GUARD & AUTO RECONNECT
function StartSpamLoop()
    if _G.KD_SpamRunning then return end
    _G.KD_SpamRunning = true
    LogToConsole("`2[KD Group] `aAuto Spam & Pos Guard Berjalan!")

    local function spamWorker()
        while _G.KD_SpamRunning do
            local currentWorld = GetCurrentWorldName()

            -- A. Auto-Rejoin jika keluar/DC dari World
            if _G.KD_TargetWorld ~= "" and currentWorld:upper() ~= _G.KD_TargetWorld:upper() then
                LogToConsole("`4[KD Group] `oTerlempar dari world! Menghubungkan ulang ke: " .. _G.KD_TargetWorld)
                SendPacket(3, "action|join_request\nname|" .. _G.KD_TargetWorld .. "\ninvitedWorld|0")
                SafeSleep(4000)
            else
                -- B. Pos Guard: Cek apakah karakter bergeser dari koordinat target
                if _G.KD_TargetX and _G.KD_TargetY then
                    local myX, myY = GetCurrentPos()
                    if myX ~= _G.KD_TargetX or myY ~= _G.KD_TargetY then
                        SafeMove(_G.KD_TargetX, _G.KD_TargetY)
                        SafeSleep(800) -- Beri waktu karakter untuk melangkah kembali
                    end
                end

                -- C. Kirim Pesan Chat
                local msg = _G.KD_SpamText or "KD Group on Top!"
                SendPacket(2, "action|input\n|text|" .. msg)

                -- D. Jeda Waktu
                local dly = tonumber(_G.KD_SpamDelay) or 3500
                SafeSleep(dly)
            end
        end
        LogToConsole("`4[KD Group] `cAuto Spam telah dimatikan.")
    end

    -- Eksekusi Thread
    if type(run_thread) == "function" then
        run_thread(spamWorker)
    elseif type(make_thread) == "function" then
        make_thread(spamWorker)
    elseif type(RunThread) == "function" then
        RunThread(spamWorker)
    else
        local co = coroutine.create(function()
            local ok, err = pcall(spamWorker)
            if not ok then
                LogToConsole("`4[KD Error] Loop error: " .. tostring(err))
            end
        end)
        coroutine.resume(co)
    end
end

-- 8. HOOK PAKET INTERAKSI
function KD_PacketHook(type, packet)
    -- Deteksi Emote Senyum untuk membuka menu
    if type == 2 and packet:find("action|action") and (packet:find("emote") or packet:find("cheer")) then
        ShowMainMenu()
        return true
    end

    -- Perintah Chat Cadangan (/kd atau /menu)
    if type == 2 and packet:find("action|input") then
        local chat = packet:match("text|(/%w+)")
        if chat == "/kd" or chat == "/menu" then
            ShowMainMenu()
            return true
        end
    end

    -- Menu Utama Hub
    if type == 2 and packet:find("dialog_name|kd_hub") then
        if packet:find("buttonClicked|menu_spam") then
            ShowSpamMenu()
            return true
        elseif packet:find("buttonClicked|menu_bfg") or packet:find("buttonClicked|menu_casino") then
            LogToConsole("`4[KD Group] `oFitur ini sedang dalam pengerjaan!")
            ShowMainMenu()
            return true
        end
    end

    -- Menu Auto Spam
    if type == 2 and packet:find("dialog_name|kd_spam_menu") then
        local inputTxt = GetValue(packet, "cfg_text")
        local inputDly = GetValue(packet, "cfg_delay")
        if inputTxt and inputTxt ~= "" then _G.KD_SpamText = inputTxt end
        if inputDly and tonumber(inputDly) then _G.KD_SpamDelay = tonumber(inputDly) end

        -- Tangkap Posisi & World Otomatis
        if packet:find("buttonClicked|btn_grab_pos") then
            local wx, wy = GetCurrentPos()
            local ww = GetCurrentWorldName()
            _G.KD_TargetWorld = ww
            _G.KD_TargetX = wx
            _G.KD_TargetY = wy
            LogToConsole("`2[KD Group] `aPosisi Terkunci! World: `w" .. ww .. " `a(X: `w" .. wx .. "`a, Y: `w" .. wy .. "`a)")
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

        -- Back
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
