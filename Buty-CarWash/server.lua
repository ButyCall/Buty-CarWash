if Configuration.FrameWork == 'esx' then 
    if Configuration.CoreFolderName == "" then Configuration.CoreFolderName = 'es_extended' end
    ESX = exports[Configuration.CoreFolderName]:getSharedObject()

    ESX.RegisterServerCallback('buty:getMoney', function(source,cb,Type, price)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            cb(true)
        elseif xPlayer.getAccount("bank").money >= price then
            xPlayer.removeAccountMoney("bank", price)
            cb(true)
        else
            cb(false)
        end 
    end)

elseif Configuration.FrameWork == 'qbcore' then 
    if Configuration.CoreFolderName == "" then Configuration.CoreFolderName = 'qb-core' end
    QBCore = exports[Configuration.CoreFolderName]:GetCoreObject()

    QBCore.Functions.CreateCallback('buty:getMoney', function(source,cb,Type, price)
        local xPlayer = QBCore.Functions.GetPlayer(source)
        local currentCash = xPlayer.Functions.GetMoney('cash')
        local currentBank = xPlayer.Functions.GetMoney('bank')
        if currentBank >= price then
            xPlayer.Functions.RemoveMoney('bank', price)
            cb(true)
        elseif currentCash >= price then
            xPlayer.Functions.RemoveMoney('cash', price)
            cb(true)
        else
            cb(false)
        end
    end)

end