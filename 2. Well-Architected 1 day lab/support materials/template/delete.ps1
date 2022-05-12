$rgBase="waflab001";
$rgdev="${rgBase}dev";
$rgprod="${rgBase}prod";

Write-Output "Start Deleting dev rg"
$jobs = @(Start-job { az group delete -n $args -y } -ArgumentList $rgdev)

Write-Output "Delete backup vaults"
$vaults=$(az backup vault list -g $rgprod --query [].name -o tsv)
foreach ($vault in $vaults) {
    az backup vault backup-properties set --soft-delete-feature-state Disable -n $vault -g $rgprod
    az backup vault delete -n $vault -g $rgprod -y --force
}
Write-Output "Delete production rg"
$jobs += Start-job { az group delete -n $args -y } -ArgumentList $rgprod

Wait-Job -Job $jobs

Receive-Job -Job $jobs