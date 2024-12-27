# Ange URL till filen på GitHub och spara som lokal fil
$githubUrl = "https://github.com/dkrlq/BlockBrainRot/raw/refs/heads/main/brainrot.ps1"
$localFile = "$env:SYSTEMDRIVE\script.ps1"

# Ladda ner filen från GitHub
Invoke-WebRequest -Uri $githubUrl -OutFile $localFile

# Definiera Scheduled Task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-noprofile -executionpolicy bypass -File $localFile"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Hours 1)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Namn på uppgiften
$taskName = "GitHubScriptUpdater"

# Skapa den schemalagda uppgiften
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

Write-Output "Scheduled Task '$taskName' has been created to run every hour."
