local Framework = (Configuration.FrameWork or 'auto'):lower()
local Core = nil

local function DetectFramework()
    if Framework ~= 'auto' then return end

    if GetResourceState('qbx_core') == 'started' then
        Framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
    else
        print('^1[Buty-Carwash] No supported framework found.^0')
    end
end

local function GetCore()
    DetectFramework()

    if Framework == 'esx' then
        Configuration.CoreFolderName = Configuration.CoreFolderName ~= '' and Configuration.CoreFolderName or 'es_extended'
        Core = exports[Configuration.CoreFolderName]:getSharedObject()
    elseif Framework == 'qbcore' then
        Configuration.CoreFolderName = Configuration.CoreFolderName ~= '' and Configuration.CoreFolderName or 'qb-core'
        Core = exports[Configuration.CoreFolderName]:GetCoreObject()
    elseif Framework == 'qbox' then
        Configuration.CoreFolderName = Configuration.CoreFolderName ~= '' and Configuration.CoreFolderName or 'qbx_core'
        Core = exports[Configuration.CoreFolderName]
    end
end

GetCore()

if Framework == 'esx' then
    Core.RegisterServerCallback('buty:getMoney', function(source, cb, Type)
        local xPlayer = Core.GetPlayerFromId(source)
        local packageIndex = tonumber(Type)
        local price = packageIndex and tonumber(Configuration.Prices[packageIndex]) or nil

        if not xPlayer or not price or price < 0 then
            cb(false)
            return
        end

        if xPlayer.getMoney() >= price then
            xPlayer.removeMoney(price)
            cb(true)
        elseif xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)
            cb(true)
        else
            cb(false)
        end
    end)

elseif Framework == 'qbcore' then
    Core.Functions.CreateCallback('buty:getMoney', function(source, cb, Type)
        local Player = Core.Functions.GetPlayer(source)
        local packageIndex = tonumber(Type)
        local price = packageIndex and tonumber(Configuration.Prices[packageIndex]) or nil

        if not Player or not price or price < 0 then
            cb(false)
            return
        end

        local cash = Player.Functions.GetMoney('cash')
        local bank = Player.Functions.GetMoney('bank')

        if cash >= price then
            Player.Functions.RemoveMoney('cash', price)
            cb(true)
        elseif bank >= price then
            Player.Functions.RemoveMoney('bank', price)
            cb(true)
        else
            cb(false)
        end
    end)

elseif Framework == 'qbox' then
    lib.callback.register('buty:getMoney', function(source, Type)
        local packageIndex = tonumber(Type)
        local price = packageIndex and tonumber(Configuration.Prices[packageIndex]) or nil

        if not price or price < 0 then
            return false
        end

        local cash = exports.qbx_core:GetMoney(source, 'cash') or 0
        local bank = exports.qbx_core:GetMoney(source, 'bank') or 0

        if cash >= price then
            exports.qbx_core:RemoveMoney(source, 'cash', price, 'carwash-payment')
            return true
        elseif bank >= price then
            exports.qbx_core:RemoveMoney(source, 'bank', price, 'carwash-payment')
            return true
        end

        return false
    end)
end