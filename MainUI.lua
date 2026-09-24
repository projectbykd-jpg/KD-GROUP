-- ==========================================
-- PROJECT BY KD - MAIN HUB (BOTHAX COMPATIBLE)
-- ==========================================

-- 1. Fungsi Parser untuk membaca isi data dialog
function GetDialogValue(packet, key)
    for line in packet:gmatch("[^\r\n]+") do
        local k, v = line:match("^([^|]+)|(.*)$")
        if k == key then return v end
    end
    return nil
end

-- 2. Fungsi untuk memunculkan Panel Pengaturan KD Group
function ShowKDMenu()
    local defaultText = _G.KD_SpamText or "Beli Script Premium hanya di KD Group!"
    local defaultDelay = _G.KD_SpamDelay or "3500"

    local dialog = "set_default_color|`o\n" ..
                   "add_label_with_icon|big|`wPROJECT BY KD - SCRIPT HUB``|left|11550|\n" ..
                   "add_spacer|small|\n" ..
                   "add_textbox|`9Silakan atur konfigurasi Auto Spam di bawah ini:|left|\n" ..
                   "add_text_input|cfg_text|Pesan Spam:|" .. defaultText .. "|50|\n" ..
                   "add_text_input|cfg_delay|Delay (ms):|" .. defaultDelay .. "|5|\n" ..
                   "add_spacer|small|\n" ..
                   "end_dialog|kd_menu|Batal|▶ JALANKAN SPAM|\n" ..
                   "add_quick_exit|"

    local var = {}
    var[0] = "OnDialogRequest"
    var[1] = dialog
    var.netid = -1
    SendVariantList(var)
end

-- 3. Fungsi Hook Penangkap Klik & Input dari Panel
local function OnSendPacketHook(type, packet)
    if type == 2 and packet:find("dialog_name|kd_menu") then
        -- Jika tombol "▶ JALANKAN SPAM" ditekan
        if packet:find("buttonClicked|▶ JALANKAN SPAM") then
            -- Ambil data yang diketik user di form
            local customText = GetDialogValue(packet, "cfg_text")
            local customDelay = tonumber(GetDialogValue(packet, "cfg_delay")) or 3500

            -- Simpan ke variabel global
            _G.KD_SpamText = customText
            _G.KD_SpamDelay = customDelay

            LogToConsole("`2[KD Group] `9Mengunduh modul AutoSpam dari GitHub...")

            -- Eksekusi file modular dari GitHub kamu
            local url = "https://raw.githubusercontent.com/projectbykd-jpg/KD-GROUP/main/Scripts/AutoSpam.lua"
            load(MakeRequest(url, "GET").content)()

            return true -- Blokir paket agar server GT tidak bingung
        end
    end
    return false
end

-- 4. Pasang Hook sesuai sistem Bothax
if type(hook) == "function" then
    hook("sendpacket", OnSendPacketHook)
elseif type(AddHook) == "function" then
    AddHook("OnSendPacket", "KD_Hook", OnSendPacketHook)
end

-- Tampilkan panelnya di layar HP
ShowKDMenu()
