print("Server/main.lua is loaded!")

local ESX = exports['es_extended']:getSharedObject()

-- Helper function: Checks if a value exists in a table
local function contains(table, val)
    for _, v in ipairs(table) do
        if v == val then 
            return true
        end
    end
    return false
end

-- Register a new gang
RegisterServerEvent('esx_creategang:registerGang')
AddEventHandler('esx_creategang:registerGang', function(gangName, gangLabel)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    print("esx_creategang:registerGang was triggered on the server.")

    if Config.Whitelist and not contains(Config.SteamIdentifiers, identifier) then
        TriggerClientEvent('esx:showNotification', source, 'You are not allowed to create a gang.')
        TriggerClientEvent('esx_creategang:creationError', source, 'You are not allowed to create a gang.')
        return
    end

    if xPlayer.getMoney() < Config.CreationCost then
        TriggerClientEvent('esx:showNotification', source, 'You cannot afford to create a gang.')
        TriggerClientEvent('esx_creategang:creationError', source, 'You cannot afford to create a gang.')
        return
    end

    xPlayer.removeMoney(Config.CreationCost)

    exports.oxmysql:execute('INSERT INTO `gang` (`name`, `label`) VALUES (?, ?)', {gangName, gangLabel}, function(rowsChanged)
        if rowsChanged > 0 then
            exports.oxmysql:scalar('SELECT `id` FROM `gang` WHERE `name` = ?', {gangName}, function(gangId)
                if gangId then
                    exports.oxmysql:execute('INSERT INTO `gang_grades` (`gang_id`, `name`, `label`, `salary`) VALUES (?, ?, ?, ?)', {gangId, 'boss', 'Boss', 5000}, function(rowsChanged)
                        if rowsChanged > 0 then
                            exports.oxmysql:execute('UPDATE `users` SET `gang` = ?, `gang_grade` = ? WHERE `identifier` = ?', {gangName, 'boss', identifier}, function(rowsChanged)
                                if rowsChanged > 0 then
                                    TriggerClientEvent('esx:showNotification', source, 'Gang registered successfully! You are now the boss.')
                                else
                                    TriggerClientEvent('esx:showNotification', source, 'There was an error setting you as the gang boss.')
                                    TriggerClientEvent('esx_creategang:creationError', source, 'There was an error setting you as the gang boss.')
                                end
                            end)
                        else
                            TriggerClientEvent('esx:showNotification', source, 'There was an error creating the boss grade.')
                            TriggerClientEvent('esx_creategang:creationError', source, 'There was an error creating the boss grade.')
                        end
                    end)
                else
                    TriggerClientEvent('esx:showNotification', source, 'Gang not found.')
                    TriggerClientEvent('esx_creategang:creationError', source, 'Gang not found.')
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, 'There was an error registering the gang.')
            TriggerClientEvent('esx_creategang:creationError', source, 'There was an error registering the gang.')
        end
    end)
end)

-- Add a new grade to a gang
RegisterServerEvent('esx_creategang:addGangGrade')
AddEventHandler('esx_creategang:addGangGrade', function(gangName, gradeName, gradeLabel, salary)
    local source = source

    exports.oxmysql:scalar('SELECT `id` FROM `gang` WHERE `name` = ?', {gangName}, function(gangId)
        if gangId then
            exports.oxmysql:execute('INSERT INTO `gang_grades` (`gang_id`, `name`, `label`, `salary`) VALUES (?, ?, ?, ?)', {gangId, gradeName, gradeLabel, salary}, function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent('esx:showNotification', source, 'Gang grade added successfully!')
                else
                    TriggerClientEvent('esx:showNotification', source, 'There was an error adding the grade.')
                    TriggerClientEvent('esx_creategang:creationError', source, 'There was an error adding the grade.')
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', source, 'Gang not found.')
            TriggerClientEvent('esx_creategang:creationError', source, 'Gang not found.')
        end
    end)
end)

-- Fetch a user's gang salary
ESX.RegisterServerCallback('esx_creategang:getUsergangalary', function(source, cb, userIdentifier)
    exports.oxmysql:scalar('SELECT gg.`salary` FROM `users` u JOIN `gang_grades` gg ON u.`gang` = gg.`gang_id` WHERE u.`identifier` = ? AND u.`gang_grade` = gg.`name`', {userIdentifier}, function(salary)
        cb(salary)
    end)
end)

-- Fetch all roles within a gang
ESX.RegisterServerCallback('esx_creategang:getGangRoles', function(source, cb, gangName)
    exports.oxmysql:fetchAll('SELECT `name`, `label`, `salary` FROM `gang_grades` WHERE `gang_id` IN (SELECT `id` FROM `gang` WHERE `name` = ?)', {gangName}, function(roles)
        cb(roles)
    end)
end)
