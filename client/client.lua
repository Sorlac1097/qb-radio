QBCore = nil
local radioMenu = false
local isLoggedIn = false
local r = false
local RadioChannel = 0

Citizen.CreateThread(function()
  while QBCore == nil do
    TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
    Citizen.Wait(20)
  end
end)

function toggleRadio(toggle)
  radioMenu = toggle
  SetNuiFocus(radioMenu, radioMenu)
  if radioMenu then
    PhonePlayIn()
    SendNUIMessage({
      type = "open"
    })
  else
    PhonePlayOut()
    SendNUIMessage({
      type = "close"
    })
  end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

AddEventHandler("onClientResourceStart", function(resName)
	if GetCurrentResourceName() ~= resName and "pma-voice" ~= resName then
		return
	end
  if isLoggedIn then
    while QBCore == nil do
      Citizen.Wait(20)
    end
    leaveradio()
  end
end)

Citizen.CreateThread(function()
  while true do
    if isLoggedIn then
      if r then
        QBCore.Functions.TriggerCallback('qb-radio:server:GetItem', function(hasItem)
          if not hasItem then
            if RadioChannel ~= 0 then
              leaveradio()
            end
          end
        end,"radio")
      end
    end
    Citizen.Wait(1000)
  end
end)

function connecttoradio(channel)
  RadioChannel = channel
  if r then
    exports["pma-voice"]:setRadioChannel(0)
  else
    r = true
    exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
  end
  exports["pma-voice"]:setRadioChannel(channel)
  if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
    QBCore.Functions.Notify(Config.messages['joined_to_radio'] ..channel.. ' MHz </b>', 'success')
  else
    QBCore.Functions.Notify(Config.messages['joined_to_radio'] ..channel.. '.00 MHz </b>', 'success')
  end
end

function leaveradio()
  RadioChannel = 0
  r = false
  exports["pma-voice"]:setRadioChannel(0)
  exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
  QBCore.Functions.Notify(Config.messages['you_leave'] , 'error')
end

RegisterNUICallback('joinRadio', function(data, cb)
  local rchannel = tonumber(data.channel)
  if rchannel ~= nil then
    if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
      if rchannel ~= RadioChannel then
        if rchannel <= Config.RestrictedChannels then
          local xPlayer = QBCore.Functions.GetPlayerData()
          if (xPlayer.job.name == 'police' or xPlayer.job.name == 'ems' or xPlayer.job.name == 'doctor') and xPlayer.job.onduty then
            connecttoradio(rchannel)
          else
            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
          end
        else
          connecttoradio(rchannel)
        end
      else
        QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
      end
    else
      QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
    end
  else
    QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
  end
end)

RegisterNUICallback('leaveRadio', function(data, cb)
  if RadioChannel == 0 then
    QBCore.Functions.Notify(Config.messages['not_on_radio'], 'error')
  else
    leaveradio()
  end
end)

RegisterNUICallback('escape', function(data, cb)
  toggleRadio(false)
end)

RegisterNetEvent('qb-radio:use')
AddEventHandler('qb-radio:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('qb-radio:onRadioDrop')
AddEventHandler('qb-radio:onRadioDrop', function()
  if RadioChannel ~= 0 then
    leaveradio()
  end
end)

function SplitStr(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function IsRadioOn()
  return r
end

exports("IsRadioOn", IsRadioOn)

RegisterCommand('r', function(source, args, rawCommand)
rchannel = tonumber(args[1])
if rchannel ~= nil then
  if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
    if rchannel ~= RadioChannel then
      if rchannel <= Config.RestrictedChannels then
        local xPlayer = QBCore.Functions.GetPlayerData()
        if (xPlayer.job.name == 'police' or xPlayer.job.name == 'ems' or xPlayer.job.name == 'doctor') and xPlayer.job.onduty then
          connecttoradio(rchannel)
        else
          QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
        end
      else
        connecttoradio(rchannel)
      end
    else
      QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
    end
  else
    QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
  end
else
  QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
end
end,false)