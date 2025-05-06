Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
trap {
    Write-Output "ERROR: $_"
    Write-Output (($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1')
    Exit 1
}



# set password when requested.
if (Test-Path env:RUNNER_PASSWORD) {
    Write-Output "Setting the $env:USERNAME user password..."
    net user $env:USERNAME $env:RUNNER_PASSWORD
    if ($?) {
    Write-Output "Password for user $($env:USERNAME) has been updated successfully."
    } else {
     Write-Output "Failed to update the password for user $($env:USERNAME)."
    }
}

Write-Output 'Running frpc...'
./frp/frpc -c frpc-windows-2.ini 2>&1 | Select-Object {$_ -replace '[0-9\.]+:6969','***:6969'}; cmd /c exit 0
