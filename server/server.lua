QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

QBCore.Functions.CreateUseableItem("radio", function(source, item)
  TriggerClientEvent('qb-radio:use', source)
end)
