print("Client/main.lua is loaded!")

local ESX = exports['es_extended']:getSharedObject()
local isUICurrentlyShown = false

-- Error handler for gang creation
RegisterNetEvent('esx_creategang:creationError')
AddEventHandler('esx_creategang:creationError', function(errorMessage)
    SendNUIMessage({
        type = 'creationError',
        message = errorMessage
    })
end)

-- Callback to hide the Gang Creator UI
RegisterNUICallback('esx_creategang:hideGangCreator', function()
    print("Received hideGangCreator Callback in Lua")
    if isUICurrentlyShown then
        SetNuiFocus(false, false)
        isUICurrentlyShown = false
    end
end)

-- Callback when the form is submitted
RegisterNUICallback('esx_creategang:submitForm', function(data, cb)
    print("Received submitForm NUI Callback.")
    
    -- Register the gang
    TriggerServerEvent('esx_creategang:registerGang', data.gangName)

    -- Iterate over the roles and add them (excluding the Boss role)
    for _, role in ipairs(data.roles) do
        if role.role ~= "Boss (you)" then
            TriggerServerEvent('esx_creategang:addGangGrade', data.gangName, role.role, role.role, role.salary)
        end
    end

    cb('OK')
end)

-- Event to set player's gang data
RegisterNetEvent('esx_creategang:setGang')
AddEventHandler('esx_creategang:setGang', function(gang, grade, gangData)
    ESX.PlayerData.gang = gang
    ESX.PlayerData.gangGrade = grade
    ESX.PlayerData.gangData = gangData
end)

-- Command to open the gang registration form
RegisterCommand("registergang", function()
    if not isUICurrentlyShown then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "toggleShow",
            view = "gangCreator"
        })
        isUICurrentlyShown = true
    end
end, false)
