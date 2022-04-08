<#
    .SYNOPSIS
    Used the M365 Call Flow Visualizer Script to create a seperate Markdown file for each top level voice app and creates a Markdown file which includes all the other markdown files.

    .DESCRIPTION
    Searches for auto attendants and call queues which have at least one phone number assigned. It then runs the M365 Call flow visualizer for each top level voice app. A seperate Markdown file is created for each call flow. Each call flow Markdown file is added to a
    single Markdown file so that all call flows can be rendered on one page.

    Author:             Martin Heusser
    Version:            1.0.1
    Revision:
        05.01.2022      Creation
        12.01.2022      Migrate from MSOnline to Microsoft.Graph

#>

. .\Functions\Connect-M365CFV.ps1

. Connect-M365CFV

$VoiceApps = @()

$AllAutoAttendants = Get-CsAutoAttendant | Where-Object {$_.ApplicationInstances -notlike ""}

$AllCallQueues = Get-CsCallQueue | Where-Object {$_.ApplicationInstances -notlike ""}

foreach ($AutoAttendant in $AllAutoAttendants) {

    $ResourceAccounts = $AutoAttendant.ApplicationInstances

    foreach ($ResourceAccount in $ResourceAccounts) {

        $ResourceAccountCheck = Get-CsOnlineApplicationInstance -Identity $ResourceAccount

        if ($ResourceAccountCheck.PhoneNumber) {

            $VoiceApps += $AutoAttendant.Identity

        }

    }
    
}

foreach ($CallQueue in $AllCallQueues) {

    $ResourceAccounts = $CallQueue.ApplicationInstances

    foreach ($ResourceAccount in $ResourceAccounts) {

        $ResourceAccountCheck = Get-CsOnlineApplicationInstance -Identity $ResourceAccount

        if ($ResourceAccountCheck.PhoneNumber) {

            $VoiceApps += $CallQueue.Identity

        }

    }
    
}

if (!(Test-Path -Path .\Output)) {

    New-Item -Path .\Output -ItemType Directory

}

Set-Content -Path ".\Output\TopLevelVoiceApps.md" -Value "# Call Flow Diagrams"

foreach ($VoiceAppIdentity in $VoiceApps) {

    . .\M365CallFlowVisualizerV2.ps1 -Identity $VoiceAppIdentity -Theme dark -CustomFilePath ".\Output" -ShowCqAgentPhoneNumbers -ExportAudioFiles -ExportTTSGreetings -ShowAudioFileName -ShowTTSGreetingText

    $MarkdownInclude = "[!include[$($VoiceAppFileName)]($(($VoiceAppFileName).Replace(" ","_"))_CallFlow$fileExtension)]"

    Add-Content -Path ".\Output\TopLevelVoiceApps.md" -Value $MarkdownInclude

}
