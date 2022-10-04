# This function is meant to simplify a check against a DSC pull server. If you do not use the
# default service URL, you will need to adjust accordingly.

$fqdn = 'vm-iac.iiasa.ac.at'

function Verify-DSCPullServer ($fqdn) {
    ([xml](Invoke-WebRequest "https://$($fqdn)/psdscpullserver.svc" | % Content)).service.workspace.collection.href
}

Verify-DSCPullServer $fqdn