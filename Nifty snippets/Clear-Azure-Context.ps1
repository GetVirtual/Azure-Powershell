# Quick solution for error:
# "Can´t select certain subscriptions with Set-AzContext or Select-AzSubscription"

Get-AzureRmContext | Remove-AzureRmContext -Force

Disconnect-AzAccount