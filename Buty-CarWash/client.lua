local ESX = nil
local QBCore = nil
local trigger = nil

local Framework = (Configuration.FrameWork or 'auto'):lower()

if Framework == 'auto' then
    if GetResourceState('qbx_core') == 'started' then
        Framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
    end
end

if Framework == 'esx' then
    Configuration.CoreFolderName = Configuration.CoreFolderName ~= '' and Configuration.CoreFolderName or 'es_extended'
    ESX = exports[Configuration.CoreFolderName]:getSharedObject()

    trigger = function(name, cb, ...)
        ESX.TriggerServerCallback(name, cb, ...)
    end
elseif Framework == 'qbcore' then
    Configuration.CoreFolderName = Configuration.CoreFolderName ~= '' and Configuration.CoreFolderName or 'qb-core'
    QBCore = exports[Configuration.CoreFolderName]:GetCoreObject()

    trigger = function(name, cb, ...)
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end
elseif Framework == 'qbox' then
    trigger = function(name, cb, ...)
        local result = lib.callback.await(name, false, ...)
        cb(result)
    end
end

local Type = nil
local fov_max = 90.0
local fov_min = 1.0
local fov = (fov_max + fov_min) * 0.5
local npccreated = {}
local animDict = "weapons@first_person@aim_rng@generic@projectile@shared@core"
local animDict2 = "mini@strip_club@private_dance@part3"
local animName2 = "priv_dance_p3"
local animName = "idlerng_med"
local particleDict = "scr_bike_business"
local particleName = "scr_bike_spraybottle_spray"
local done = 0

RegisterNUICallback("exit", function(data)
    if Type == nil then
        washing = false
        EndCam()
        FreezeEntityPosition(PlayerPedId(), false)
        FreezeEntityPosition(vehicle, false)
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "ui",
            status = false,
        })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "ui",
            status = false,
        })
    end
    DisplayRadar(true)
end)

Citizen.CreateThread(function()
    for i, v in ipairs(Locations) do
        carwash = AddBlipForCoord(v.Coord)
        SetBlipSprite(carwash, 100)
        SetBlipColour(carwash, 57)
        SetBlipScale(carwash, 0.8)
        SetBlipAsShortRange(carwash, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('CAR WASH')
        EndTextCommandSetBlipName(carwash)
    end
    while true do
        local ped = PlayerPedId()
        local pedcoord = GetEntityCoords(ped)
        vehicle = GetPlayersLastVehicle(ped)
        local esta = false
        for i, v in ipairs(Locations) do
            local dist = #(pedcoord - v.Coord)
            if dist < 20 and not washing then
                esta = true
                sleep = 0
                DrawMarker(23, v.Coord.x, v.Coord.y, v.Coord.z - 0.50, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 4.0, 4.0, 4.0, 10,
                    228, 255, 100, 0, 1, 2, 0, 0)
            end
            if dist < 1.5 and IsPedInAnyVehicle(ped, false) and not washing then
                esta = true
                hintToDisplay("~b~[E]~wu~ ~w~Wash Car", v.Coord)
                sleep = 0
                local isDriving = IsPedInAnyVehicle(PlayerPedId(), false)
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if IsControlJustReleased(0, 38) and isDriving and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                    washing = true
                    FreezeEntityPosition(ped, true)
                    FreezeEntityPosition(vehicle, true)
                    DoScreenFadeOut(1000)
                    Citizen.Wait(1000)
                    SetEntityCoords(vehicle, v.Coord)
                    SetEntityHeading(vehicle, 323.56)
                    DisplayRadar(false)
                    Wait(500)
                    DoScreenFadeIn(1000)
                    local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                    local x, y, z = px + GetEntityForwardX(vehicle) * 1.3, py + GetEntityForwardY(vehicle) * 5.4,
                        pz + 0.12
                    camCoords = vector3(x, y, z)
                    local rx = GetEntityRotation(vehicle, 2)
                    camRotation = rx + vector3(-2.0, 0.0, -132)
                    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords, camRotation, GetGameplayCamFov())
                    SetCamActive(cam, true)
                    RenderScriptCams(true, true, 3000, true, false)
                    Wait(2600)
                    SetNuiFocus(true, true)
                    SendNUIMessage({ type = "ui", status = true })
                end
            end
            if not esta then
                sleep = 1000
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNUICallback("wash", function(data)
    local ped = PlayerPedId()
    local vehicle = GetPlayersLastVehicle(ped)

    Type = data.type

    local price = Configuration.Prices[tonumber(Type)]
    local pedcoord = GetEntityCoords(ped)
    local vehcoord = GetEntityCoords(vehicle)

    if not trigger then
        SendNotification('Carwash framework callback is not loaded.')

        FreezeEntityPosition(ped, false)
        FreezeEntityPosition(vehicle, false)
        SetNuiFocus(false, false)

        SendNUIMessage({
            type = 'ui',
            status = false
        })

        EndCam()

        Type = nil
        washing = false
        done = 0

        return
    end

    trigger('buty:getMoney', function(money)
        if not money then
            FreezeEntityPosition(ped, false)
            FreezeEntityPosition(vehicle, false)
            EndCam()

            Type = nil
            washing = false
            done = 0

            SendNotification("You don't have enough money")
            return
        end

        SendNotification("You have paid correctly, wait for them to clean your vehicle.")

        if Type == "1" then
            for _, location in ipairs(Locations) do
                local dist = #(pedcoord - location.Coord)

                if dist < 20 then
                    for _, npcData in ipairs(location.Npc['BASIC']) do
                        local modelHash = GetHashKey(npcData.model)

                        RequestModel(modelHash)
                        while not HasModelLoaded(modelHash) do
                            Wait(1)
                        end

                        npcData.npc = CreatePed(5, modelHash, vehcoord.x, vehcoord.y + 4.5, vehcoord.z, 1, true, true)

                        SetEntityInvincible(npcData.npc, true)
                        SetBlockingOfNonTemporaryEvents(npcData.npc, true)

                        local prop = CreateObject("prop_blox_spray", 0, 0, 0, true, true, true)

                        AttachEntityToEntity(
                            prop,
                            npcData.npc,
                            GetPedBoneIndex(npcData.npc, 28422),
                            0.05,
                            -0.05,
                            -0.05,
                            260.0,
                            160.0,
                            0.0,
                            true,
                            true,
                            false,
                            true,
                            0,
                            true
                        )

                        local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                        local x, y, z = px + GetEntityForwardX(vehicle) * 0.5, py + GetEntityForwardY(vehicle) * 9.9,
                            pz + 2.82

                        camCoords = vector3(x, y, z)

                        local rx = GetEntityRotation(vehicle, 2)

                        camRotation = rx + vector3(-22.0, 0.0, -145)

                        SetCamParams(cam, camCoords, camRotation, GetGameplayCamFov(), 3000)
                        SetCamActive(cam, true)
                        RenderScriptCams(true, true, 5000, true, false)

                        RequestAnimDict(animDict)
                        while not HasAnimDictLoaded(animDict) do
                            Wait(100)
                        end

                        TaskPlayAnim(npcData.npc, animDict, animName, 1.0, -1, -1, 50, 0, false, false, false)

                        Progress(24000, "Spraying cleaning fluid...")

                        for i = 1, #npcData.steps do
                            local boneIndex = GetEntityBoneIndexByName(vehicle, npcData.steps[i])
                            local position = GetWorldPositionOfEntityBone(vehicle, boneIndex)

                            TaskGoToCoordAnyMeans(npcData.npc, position, 0.1, 0, 0, 786603, 0)

                            Wait(2000)

                            TaskTurnPedToFaceCoord(npcData.npc, GetEntityCoords(vehicle), 5000)

                            Wait(1500)

                            local heading = GetEntityHeading(npcData.npc)

                            RequestNamedPtfxAsset(particleDict)
                            while not HasNamedPtfxAssetLoaded(particleDict) do
                                Wait(100)
                            end

                            UseParticleFxAssetNextCall(particleDict)

                            local particleEffect = StartParticleFxLoopedOnEntity(
                                particleName,
                                prop,
                                0.2,
                                0.002,
                                0.0,
                                0.0,
                                heading,
                                160.0,
                                6.0,
                                false,
                                false,
                                false
                            )

                            Wait(1000)

                            StopParticleFxLooped(particleEffect, false)

                            local dirtLevel = GetVehicleDirtLevel(vehicle)
                            SetVehicleDirtLevel(vehicle, dirtLevel - 1)
                        end

                        SetVehicleDirtLevel(vehicle, 0.0)
                        WashDecalsFromVehicle(vehicle, 1.0)

                        FreezeEntityPosition(ped, false)
                        FreezeEntityPosition(vehicle, false)

                        ClearPedSecondaryTask(npcData.npc)
                        DeleteEntity(prop)
                        EndCam()

                        if DoesEntityExist(npcData.npc) then
                            TaskWanderStandard(npcData.npc, 10.0, 10)
                        end

                        Type = nil
                        washing = false
                    end
                end
            end
        elseif Type == "2" then
            for _, location in ipairs(Locations) do
                local dist = #(pedcoord - location.Coord)

                if dist < 20 then
                    for _, npcData in ipairs(location.Npc['STANDARD']) do
                        for stage = 1, 2 do
                            local modelHash = GetHashKey(npcData.model)

                            RequestModel(modelHash)
                            while not HasModelLoaded(modelHash) do
                                Wait(1)
                            end

                            npcData.npc = CreatePed(5, modelHash, vehcoord.x, vehcoord.y + 4.5, vehcoord.z, 1, true, true)

                            SetEntityInvincible(npcData.npc, true)
                            SetBlockingOfNonTemporaryEvents(npcData.npc, true)

                            local prop = nil

                            if done == 0 then
                                prop = CreateObject("prop_blox_spray", 0, 0, 0, true, true, true)

                                AttachEntityToEntity(
                                    prop,
                                    npcData.npc,
                                    GetPedBoneIndex(npcData.npc, 28422),
                                    0.05,
                                    -0.05,
                                    -0.05,
                                    260.0,
                                    160.0,
                                    0.0,
                                    true,
                                    true,
                                    false,
                                    true,
                                    0,
                                    true
                                )

                                RequestAnimDict(animDict)
                                while not HasAnimDictLoaded(animDict) do
                                    Wait(100)
                                end

                                TaskPlayAnim(npcData.npc, animDict, animName, 1.0, -1, -1, 50, 0, false, false, false)

                                Progress(24000, "Spraying cleaning fluid...")

                                local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                                local x, y, z = px + GetEntityForwardX(vehicle) * 0.5,
                                    py + GetEntityForwardY(vehicle) * 9.9, pz + 2.82

                                camCoords = vector3(x, y, z)

                                local rx = GetEntityRotation(vehicle, 2)

                                camRotation = rx + vector3(-22.0, 0.0, -145)

                                SetCamParams(cam, camCoords, camRotation, GetGameplayCamFov(), 3000)
                                SetCamActive(cam, true)
                                RenderScriptCams(true, true, 5000, true, false)
                            elseif done == 1 then
                                Progress(22000, "Carefully wiping the entire car bodywork...")
                            end

                            for i = 1, #npcData.steps do
                                local boneIndex = GetEntityBoneIndexByName(vehicle, npcData.steps[i])
                                local position = GetWorldPositionOfEntityBone(vehicle, boneIndex)

                                TaskGoToCoordAnyMeans(npcData.npc, position, 0.1, 0, 0, 786603, 0)

                                Wait(2000)

                                TaskTurnPedToFaceCoord(npcData.npc, GetEntityCoords(vehicle), 5000)

                                Wait(1500)

                                local heading = GetEntityHeading(npcData.npc)

                                if done == 0 then
                                    RequestNamedPtfxAsset(particleDict)
                                    while not HasNamedPtfxAssetLoaded(particleDict) do
                                        Wait(100)
                                    end

                                    UseParticleFxAssetNextCall(particleDict)

                                    local particleEffect = StartParticleFxLoopedOnEntity(
                                        particleName,
                                        prop,
                                        0.2,
                                        0.002,
                                        0.0,
                                        0.0,
                                        heading,
                                        160.0,
                                        6.0,
                                        false,
                                        false,
                                        false
                                    )

                                    Wait(1000)

                                    StopParticleFxLooped(particleEffect, false)
                                else
                                    TaskStartScenarioInPlace(npcData.npc, "WORLD_HUMAN_MAID_CLEAN", 0, true)

                                    Wait(1000)
                                end

                                if i == #npcData.steps then
                                    local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                                    local x, y, z = px + GetEntityForwardX(vehicle) * -9.5,
                                        py + GetEntityForwardY(vehicle) * -2.9, pz + 2.82

                                    camCoords = vector3(x, y, z)

                                    local rx = GetEntityRotation(vehicle, 2)

                                    camRotation = rx + vector3(-22.0, 0.0, -35)

                                    SetCamParams(cam, camCoords, camRotation, GetGameplayCamFov(), 3000)
                                    SetCamActive(cam, true)
                                    RenderScriptCams(true, true, 5000, true, false)
                                end

                                local dirtLevel = GetVehicleDirtLevel(vehicle)
                                SetVehicleDirtLevel(vehicle, dirtLevel - 1)
                            end

                            if DoesEntityExist(npcData.npc) then
                                TaskWanderStandard(npcData.npc, 10.0, 10)
                                ClearPedSecondaryTask(npcData.npc)
                            end

                            if prop and DoesEntityExist(prop) then
                                DeleteEntity(prop)
                            end

                            done = done + 1
                        end

                        SetVehicleDirtLevel(vehicle, 0.0)
                        WashDecalsFromVehicle(vehicle, 1.0)

                        FreezeEntityPosition(ped, false)
                        FreezeEntityPosition(vehicle, false)

                        EndCam()

                        Type = nil
                        washing = false
                        done = 0
                    end
                end
            end
        elseif Type == "3" then
            for _, location in ipairs(Locations) do
                local dist = #(pedcoord - location.Coord)

                if dist < 20 then
                    for _, npcData in ipairs(location.Npc['STANDARD']) do
                        for stage = 1, 3 do
                            local modelHash = GetHashKey('s_m_y_baywatch_01')

                            RequestModel(modelHash)
                            while not HasModelLoaded(modelHash) do
                                Wait(1)
                            end

                            npcData.npc = CreatePed(5, modelHash, vehcoord.x - 3.4, vehcoord.y + 4.5, vehcoord.z, 1, true,
                                true)

                            SetEntityInvincible(npcData.npc, true)
                            SetBlockingOfNonTemporaryEvents(npcData.npc, true)

                            local prop = nil

                            if done == 0 then
                                prop = CreateObject("prop_blox_spray", 0, 0, 0, true, true, true)

                                AttachEntityToEntity(
                                    prop,
                                    npcData.npc,
                                    GetPedBoneIndex(npcData.npc, 28422),
                                    0.05,
                                    -0.05,
                                    -0.05,
                                    260.0,
                                    160.0,
                                    0.0,
                                    true,
                                    true,
                                    false,
                                    true,
                                    0,
                                    true
                                )

                                RequestAnimDict(animDict)
                                while not HasAnimDictLoaded(animDict) do
                                    Wait(100)
                                end

                                TaskPlayAnim(npcData.npc, animDict, animName, 1.0, -1, -1, 50, 0, false, false, false)

                                local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                                local x, y, z = px + GetEntityForwardX(vehicle) * 0.5,
                                    py + GetEntityForwardY(vehicle) * 9.9, pz + 2.82

                                camCoords = vector3(x, y, z)

                                local rx = GetEntityRotation(vehicle, 2)

                                camRotation = rx + vector3(-22.0, 0.0, -145)

                                SetCamParams(cam, camCoords, camRotation, GetGameplayCamFov(), 3000)
                                SetCamActive(cam, true)
                                RenderScriptCams(true, true, 5000, true, false)

                                Progress(24000, "Spraying cleaning fluid...")
                            elseif done == 1 then
                                Progress(22000, "Carefully wiping the entire car bodywork...")
                            elseif done == 2 then
                                local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                                local x, y, z = px + GetEntityForwardX(vehicle) * 0.5,
                                    py + GetEntityForwardY(vehicle) * 9.9, pz + 2.82

                                camCoords = vector3(x, y, z)

                                local rx = GetEntityRotation(vehicle, 2)

                                camRotation = rx + vector3(-22.0, 0.0, -145)

                                SetCamParams(cam, camCoords, camRotation, GetGameplayCamFov(), 3000)
                                SetCamActive(cam, true)
                                RenderScriptCams(true, true, 5000, true, false)

                                Progress(50000, "Doing a little dance to charge you more for the premium service...")
                            end

                            for i = 1, #npcData.steps do
                                local boneIndex = GetEntityBoneIndexByName(vehicle, npcData.steps[i])
                                local position = GetWorldPositionOfEntityBone(vehicle, boneIndex)

                                if done ~= 2 then
                                    TaskGoToCoordAnyMeans(npcData.npc, position, 0.1, 0, 0, 786603, 0)

                                    Wait(2200)

                                    TaskTurnPedToFaceCoord(npcData.npc, GetEntityCoords(vehicle), 5000)

                                    Wait(1300)
                                end

                                if i == #npcData.steps then
                                    local px, py, pz = table.unpack(GetEntityCoords(vehicle))
                                    local x, y, z = px + GetEntityForwardX(vehicle) * -9.5,
                                        py + GetEntityForwardY(vehicle) * -2.9, pz + 2.82

                                    camCoords = vector3(x, y, z)

                                    local rx = GetEntityRotation(vehicle, 2)

                                    camRotation = rx + vector3(-22.0, 0.0, -35)

                                    SetCamParams(cam, camCoords, camRotation, GetGameplayCamFov(), 3000)
                                    SetCamActive(cam, true)
                                    RenderScriptCams(true, true, 5000, true, false)
                                end

                                if done == 0 then
                                    local heading = GetEntityHeading(npcData.npc)

                                    RequestNamedPtfxAsset(particleDict)
                                    while not HasNamedPtfxAssetLoaded(particleDict) do
                                        Wait(100)
                                    end

                                    UseParticleFxAssetNextCall(particleDict)

                                    local particleEffect = StartParticleFxLoopedOnEntity(
                                        particleName,
                                        prop,
                                        0.2,
                                        0.002,
                                        0.0,
                                        0.0,
                                        heading,
                                        160.0,
                                        6.0,
                                        false,
                                        false,
                                        false
                                    )

                                    Wait(1000)

                                    StopParticleFxLooped(particleEffect, false)
                                elseif done == 1 then
                                    TaskStartScenarioInPlace(npcData.npc, "WORLD_HUMAN_MAID_CLEAN", 0, true)
                                    Wait(1000)
                                    ClearPedTasks(npcData.npc)
                                end

                                local dirtLevel = GetVehicleDirtLevel(vehicle)
                                SetVehicleDirtLevel(vehicle, dirtLevel - 1)
                            end

                            if done == 2 then
                                if DoesEntityExist(npcData.npc) then
                                    ClearPedTasksImmediately(npcData.npc)
                                    DeletePed(npcData.npc)
                                end

                                local stripperList = Configuration.PremiumDancePeds or {
                                    's_f_y_stripper_01',
                                    's_f_y_stripper_02'
                                }

                                local stripperModel = GetHashKey(stripperList[math.random(#stripperList)])

                                RequestModel(stripperModel)
                                while not HasModelLoaded(stripperModel) do
                                    Wait(0)
                                end

                                local offset = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, 1.0, -0.7)

                                local stripper = CreatePed(
                                    4,
                                    stripperModel,
                                    offset.x,
                                    offset.y,
                                    offset.z,
                                    GetEntityHeading(vehicle),
                                    true,
                                    true
                                )

                                SetEntityInvincible(stripper, true)
                                SetBlockingOfNonTemporaryEvents(stripper, true)
                                FreezeEntityPosition(stripper, true)
                                SetEntityCoords(stripper, offset.x, offset.y, offset.z, false, false, false, true)

                                TaskTurnPedToFaceEntity(stripper, vehicle, 1000)

                                Wait(1000)

                                AnimationInfinite(
                                    "mini@strip_club@private_dance@part2",
                                    "priv_dance_p2",
                                    stripper
                                )

                                Wait(50000)

                                ClearPedTasksImmediately(stripper)
                                DeletePed(stripper)
                                SetModelAsNoLongerNeeded(stripperModel)
                            else
                                if DoesEntityExist(npcData.npc) then
                                    TaskWanderStandard(npcData.npc, 10.0, 10)
                                    ClearPedSecondaryTask(npcData.npc)
                                end
                            end

                            if prop and DoesEntityExist(prop) then
                                DeleteEntity(prop)
                            end

                            done = done + 1
                        end

                        SetVehicleDirtLevel(vehicle, 0.0)
                        WashDecalsFromVehicle(vehicle, 1.0)

                        FreezeEntityPosition(ped, false)
                        FreezeEntityPosition(vehicle, false)

                        EndCam()

                        Type = nil
                        washing = false
                        done = 0
                    end
                end
            end
        end
    end, Type, price)
end)


setblip = function(name, coords)
    if name == "help" then
        help = AddBlipForCoord(coords[1], coords[2], coords[3])
        SetBlipSprite(help, 1)
        SetBlipColour(help, 50)
        SetBlipScale(help, 0.4)
        SetBlipAsShortRange(help, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(name)
        EndTextCommandSetBlipName(help)
        SetBlipRoute(help, true)
        SetBlipRouteColour(help, 29)
    elseif name == "ends" then
        ends = AddBlipForCoord(coords[1], coords[2], coords[3])
        SetBlipSprite(ends, 1)
        SetBlipColour(ends, 50)
        SetBlipScale(ends, 0.4)
        SetBlipAsShortRange(ends, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(name)
        EndTextCommandSetBlipName(ends)
        SetBlipRoute(ends, true)
        SetBlipRouteColour(ends, 29)
    end
end

function EndCam()
    ClearFocus()

    RenderScriptCams(false, true, 1000, true, false)
    DestroyCam(cam, false)

    cam = nil
end

function hintToDisplay(text, coords)
    local dist = Vdist(coords.x, coords.y, coords.z, GetEntityCoords(PlayerPedId(-1)))
    if dist < 1.5 then
        DrawText3Ds(coords.x, coords.y, coords.z + 1.05, text, 0, 0.1, 0.1, 255)
    else
        DrawText3Ds(coords.x, coords.y, coords.z + 1.05, text, 0, 0.1, 0.1, 100)
    end
end

function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

AnimationInfinite = function(anim, anim2, jugador)
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(jugador, anim, anim2, 8.0, -8.0, -1, 1, 0, false, false, false)
end

LoadAnimDict = function(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

SendNotification = function(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)

    DrawNotification(false, false)
end

Progress = function(time, text)
    if Configuration.Progress == 'ox_lib' then
        CreateThread(function()
            lib.progressBar({
                duration = time,
                label = text,
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                }
            })
        end)

        return
    end

    if Configuration.Progress == 'buty-progress' then
        exports['Buty-Progress']:ShowProgress(
            time,
            text,
            nil,
            {
                background = 'linear-gradient(20.5deg, #00E4FF 9.83%, rgba(172, 65, 222, 0) 93.95%)',
                color = '#00C1FF'
            }
        )
    end
end
