if selectedScript == "AUTO SPAM" then
        ImGui.Text("Spam Text:")
        -- ImGui.InputText("##spamteks", "Beli di KD Group!")
        
        ImGui.Spacing()
        -- Saat tombol ditekan, dia menarik file AutoSpam.lua dari GitHub
        if ImGui.Button("▶ START SPAM", 150, 30) then
            LogToConsole("`2[KD Group] `9Mengunduh modul Auto Spam...")
            local scriptUrl = "https://raw.githubusercontent.com/projectbykd-jpg/KD-GROUP/main/Scripts/AutoSpam.lua"
            load(MakeRequest(scriptUrl, "GET").content)()
        end
        
    elseif selectedScript == "AUTO BFG" then
        ImGui.Text("Pengaturan Block:")
        
        ImGui.Spacing()
        -- Saat tombol ditekan, dia menarik file AutoBFG.lua dari GitHub
        if ImGui.Button("▶ START BFG", 150, 30) then
            LogToConsole("`2[KD Group] `9Mengunduh modul Auto BFG...")
            local scriptUrl = "https://raw.githubusercontent.com/projectbykd-jpg/KD-GROUP/main/Scripts/AutoBFG.lua"
            load(MakeRequest(scriptUrl, "GET").content)()
        end
    end
