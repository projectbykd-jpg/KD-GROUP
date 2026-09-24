LogToConsole("`2[KD Group] `9Auto Spam Aktif!")

function StartSpamming()
    while true do
        -- Mengambil teks dari inputan UI (_G.KD_SpamText)
        local textToSend = _G.KD_SpamText or "Spam default"
        
        SendPacket(2, "action|input\n|text|" .. textToSend)
        Sleep(3500) 
    end
end

StartSpamming()
