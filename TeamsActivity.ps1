$filepath="$env:APPDATA\Microsoft\Teams\logs.txt"

$folder = "$env:APPDATA\Microsoft\Teams\" # Enter the root path you want to monitor. 
$filter = 'logs.txt'  # You can enter a wildcard filter here. 
 
# In the following line, you can change 'IncludeSubdirectories to $true if required.                           
$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'}

do{
$result = $fsw.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 1000)

# Set language variables below
$lgAvailable = "Available"
$lgBusy = "Busy"
$lgOnThePhone = "On the phone"
$lgAway = "Away"
$lgBeRightBack = "Be right back"
$lgDoNotDisturb = "Do not disturb"
$lgPresenting = "Presenting"
$lgFocusing = "Focusing"
$lgInAMeeting = "In a meeting"
$lgOffline = "Offline"
$lgNotInACall = "Not in a call"
$lgInACall = "In a call"

$TeamsStatus = Get-Content -Path "$env:APPDATA\Microsoft\Teams\logs.txt" -Tail 1000 | Select-String -Pattern `
  'Setting the taskbar overlay icon -',`
  'StatusIndicatorStateService: Added' | Select-Object -Last 1

$TeamsActivity = Get-Content -Path "$env:APPDATA\Microsoft\Teams\logs.txt" -Tail 1000 | Select-String -Pattern `
  'Resuming daemon App updates',`
  'Pausing daemon App updates',`
  'SfB:TeamsNoCall',`
  'SfB:TeamsPendingCall',`
  'SfB:TeamsActiveCall',`
  'name: desktop_call_state_change_send, isOngoing' | Select-Object -Last 1

  $TeamsProcess = Get-Process -Name Teams -ErrorAction SilentlyContinue
If ($null -ne $TeamsProcess) {
    If($TeamsStatus -eq $null){ }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgAvailable*" -or `
        $TeamsStatus -like "*StatusIndicatorStateService: Added Available*" -or `
        $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Available -> NewActivity*") {
        $Status = $lgAvailable

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgBusy*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Busy*" -or `
            $TeamsStatus -like "*Setting the taskbar overlay icon - $lgOnThePhone*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added OnThePhone*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Busy -> NewActivity*") {
        $Status = $lgBusy

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgAway*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Away*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Away -> NewActivity*") {
        $Status = $lgAway

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgBeRightBack*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added BeRightBack*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: BeRightBack -> NewActivity*") {
        $Status = $lgBeRightBack

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgDoNotDisturb *" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added DoNotDisturb*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: DoNotDisturb -> NewActivity*") {
        $Status = $lgDoNotDisturb

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgFocusing*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Focusing*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Focusing -> NewActivity*") {
        $Status = $lgFocusing

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgPresenting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Presenting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: Presenting -> NewActivity*") {
        $Status = $lgPresenting

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgInAMeeting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added InAMeeting*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added NewActivity (current state: InAMeeting -> NewActivity*") {
        $Status = $lgInAMeeting

    }
    ElseIf ($TeamsStatus -like "*Setting the taskbar overlay icon - $lgOffline*" -or `
            $TeamsStatus -like "*StatusIndicatorStateService: Added Offline*") {
        $Status = $lgOffline

    }

    If($TeamsActivity -eq $null){ }
    ElseIf ($TeamsActivity -like "*Resuming daemon App updates*" -or `
        $TeamsActivity -like "*SfB:TeamsNoCall*" -or `
        $TeamsActivity -like "*name: desktop_call_state_change_send, isOngoing: false*") {
        $Activity = $lgNotInACall
        $ActivityIcon = $iconNotInACall

    }
    ElseIf ($TeamsActivity -like "*Pausing daemon App updates*" -or `
        $TeamsActivity -like "*SfB:TeamsActiveCall*" -or `
        $TeamsActivity -like "*name: desktop_call_state_change_send, isOngoing: true*") {
        $Activity = $lgInACall
        $ActivityIcon = $iconInACall

    }
}
# Set status to Offline when the Teams application is not running
Else {
        $Status = $lgOffline
        $Activity = $lgNotInACall
        $ActivityIcon = $iconNotInACall

}

if($Status -ne $lastStatus){
    $CurrDate = Get-Date
    $Content = [PSCustomObject]@{Date=$CurrDate; Status=$Status; Activity=$Activity} | Export-Csv -Path D:\teams.csv -NoTypeInformation -Append
$lastStatus = $Status
Write-Host "Publishing Status: " + $Status
}

if($Activity -ne $lastActivity){
$Content = [PSCustomObject]@{Date=$CurrDate; Status=$Status; Activity=$Activity} | Export-Csv -Path D:\teams.csv -NoTypeInformation -Append
$lastActivity = $Activity
Write-Host "Publishing Activity: " + $Activity
}
Start-Sleep -Seconds (1)
} while($true)
