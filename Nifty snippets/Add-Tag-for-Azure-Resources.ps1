# Add Tag (Tagname, Tagvalue) to Azure resources (not RG)
# Retain existing tags
# No error check if resource type accepts tags

$RG = "AzureMSDNManagement"
$tagname = "costcenter"
$tagvalue = "msdn-mgmt"

# Connect-AzAccount
# Set-AzContext -SubscriptionName "Visual Studio Enterprise"

$items = Get-AzResource -ResourceGroupName $RG

Foreach ($item in $items)
{
    $tags = (Get-AzResource -ResourceType $item.ResourceType -ResourceGroupName $RG -Name $item.Name).Tags
    
    if ($tags)
    {
        $tags.Add($tagname,$tagvalue)
        Set-AzResource -ResourceId $item.ResourceId -Tag $tags -Force
    }
    else {
        $tags = @{}
        $tags.Add($tagname,$tagvalue)
        Set-AzResource -Tag $tags -ResourceId $item.ResourceId -Force
    }
  
    
}
