-- Variabel Global agar bisa dibaca oleh script AutoSpam nanti
_G.KD_SpamText = "Jual Script Premium GTPS di KD Group!"
local selectedScript = "AUTO SPAM"

function OnDraw()
    -- Tema Warna KD Group
    ImGui.PushStyleColor(ImGuiCol_WindowBg, 0.05, 0.05, 0.08, 0.95)
    ImGui.PushStyleColor(ImGuiCol_TitleBg, 0.0, 0.3, 0.7, 1.0)
    ImGui.PushStyleColor(ImGuiCol_Button, 0.9, 0.5, 0.0, 1.0)
    
    ImGui.Begin("🚀 PROJECT BY KD - PREMIUM HUB", true)
    ImGui.Columns(2)
    ImGui.SetColumnWidth(0, 200)
    
    ImGui.TextColored(1.0, 0.6, 0.0, 1.0, "🔍 MENU SCRIPT")
    ImGui.Separator()
    
    if ImGui.Selectable("AUTO SPAM", selectedScript == "AUTO SPAM") then selectedScript = "AUTO SPAM" end
    
    ImGui.NextColumn()
    
    ImGui.TextColored(0.0, 0.8, 1.0, 1.0, "⚙️ SETTING: " .. selectedScript)
    ImGui.Separator()
    
    if selectedScript == "AUTO SPAM" then
        ImGui.Text("Spam Text:")
        -- Input UI yang akan mengubah variabel teks secara real-time
        _G.KD_SpamText = ImGui.InputText("##spamteks", _G.KD_SpamText)
        
        ImGui.Spacing()
        
        -- INI KUNCINYA: AutoSpam.lua HANYA dipanggil kalau tombol ini diklik
        if ImGui.Button("▶ START SPAM", 150, 30) then
            LogToConsole("`2[KD Group] `9Mengunduh dan menjalankan modul Auto Spam...")
            local scriptUrl = "https://raw.githubusercontent.com/projectbykd-jpg/KD-GROUP/main/Scripts/AutoSpam.lua"
            load(MakeRequest(scriptUrl, "GET").content)()
        end
    end
    
    ImGui.End()
    ImGui.PopStyleColor(3)
end

AddCallback("UI_Render", "OnDraw", OnDraw)
