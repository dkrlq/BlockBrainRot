# Definiera variabler
$githubUrl = "https://raw.githubusercontent.com/dkrlq/BlockBrainRot/refs/heads/main/brainrotlist.txt" # Byt ut med rätt URL
$tempHostsPath = "$env:TEMP\hosts_temp.txt"
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
$backupFolder = "$env:SystemRoot\System32\drivers\etc\backups"

# Skapa backup-mapp om den inte finns
if (-Not (Test-Path -Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder | Out-Null
    Copy-Item -Path $hostsFilePath -Destination "$backupFolder\hosts.first-backup" -Force
}

try {
    # Hämta filen från GitHub
    Invoke-WebRequest -Uri $githubUrl -OutFile $tempHostsPath -ErrorAction Stop

    # Skapa säkerhetskopia med dagens datum
    $backupFile = Join-Path -Path $backupFolder -ChildPath ("hosts_" + (Get-Date -Format "yyyyMMdd") + ".bak")
    Copy-Item -Path $hostsFilePath -Destination $backupFile -Force

    # Rensa gamla backup-filer, behåll endast de senaste 5
    Get-ChildItem -Path $backupFolder -Filter "hosts_*.bak" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip 5 |
        Remove-Item -Force

    # Läs innehållet från befintlig och ny hosts-fil
    $existingHosts = Get-Content -Path $hostsFilePath
    $newHosts = Get-Content -Path $tempHostsPath

    # Filtrera ut rader som redan finns i hosts-filen
    $linesToAdd = $newHosts | Where-Object { $_ -notin $existingHosts }

    # Lägg endast till de rader som saknas
    if ($linesToAdd.Count -gt 0) {
        Add-Content -Path $hostsFilePath -Value $linesToAdd
        Write-Output "Hosts-filen har uppdaterats med nya poster."
    } else {
        Write-Output "Inga nya poster behövde läggas till."
    }

} catch {
    Write-Output "Ett fel uppstod: $($_.Exception.Message)"
}

# Rensa temporära filer
if (Test-Path $tempHostsPath) {
    Remove-Item -Path $tempHostsPath -Force
}

# Slutmeddelande
Write-Output "Klart!"
Exit 0
