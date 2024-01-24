function Backup-Server {
  Write-ServerMsg "Creating Backup."
  #Create backup name from date and time
  $BackupName = Get-TimeStamp

  #Check if it's friday (Sunday is 0)
  if ((Get-Date -UFormat %u) -eq 5) {
    $Type = "Weekly"
    $Limit = (Get-Date).AddDays( - ($Backups.Weeks * 7))
  }
  else {
    $Type = "Daily"
    $Limit = (Get-Date).AddDays(-$Backups.Days)
  }

  #Check if Backups Destination directory exist and create it.
  if (-not (Test-Path -Path "$($Backups.Path)\$Type" -PathType "Container" -ErrorAction SilentlyContinue)) {
    $null = New-Item -Path "$($Backups.Path)\$Type" -ItemType "directory" -ErrorAction SilentlyContinue
  }
  #Check if Backups Source directory exist and create it.
  if (-not (Test-Path -Path $Backups.Saves -PathType "Container" -ErrorAction SilentlyContinue)) {
    $null = New-Item -Path $Backups.Saves -ItemType "directory" -ErrorAction SilentlyContinue
  }

#Run Backup
try {
  if ($Backups.Exclusions -ne "()") {
    Write-ServerMsg "Server Backup Exclusions: $($Backups.Exclusions)"
  }
  if ($Global.Exclusions -ne "()") {
    Write-ServerMsg "Global Backup Exclusions: $($Global.Exclusions)"
  }
  # Define the filter to exclude certain files from the backup
  $ExcludeFilter = {
    $_.Name -notmatch $Backups.Exclusions -and $_.Extension -notin $Global.Exclusions
  }

  # Get all files that should be included in the backup
  $FilesToBackup = Get-ChildItem -Path $Backups.Saves -Recurse | Where-Object $ExcludeFilter

  # Create a temporary directory
  $TempDirectory = New-Item -ItemType Directory -Path "$($Backups.Path)\$Type\$((Get-Item $Backups.Saves).Name)"

  # Copy each file to the temporary directory while preserving the directory structure
  foreach ($File in $FilesToBackup) {
    $Destination = $File.FullName.Replace($Backups.Saves, "$($TempDirectory)\")
    $DestinationDirectory = Split-Path -Path $Destination -Parent
    if (-not (Test-Path -Path $DestinationDirectory)) {
      New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
    }
    Copy-Item -Path $File.FullName -Destination $Destination
  }

  # Compress the temporary directory into a zip archive using the specified compression options
  Compress-Archive -Path $TempDirectory -DestinationPath "$($Backups.Path)\$Type\$BackupName.zip" -CompressionLevel 'Fastest'

  # Remove the temporary directory
  Remove-Item -Path $TempDirectory -Force -Recurse
}
catch {
  Exit-WithError -ErrorMsg "Unable to backup server."
}

  Write-ServerMsg "Backup Created : $BackupName.zip"

  #Delete old backups
  Write-ServerMsg "Deleting old backups."
  $null = Get-ChildItem -Path "$($Backups.Path)\$Type" -Recurse -Force |
  Where-Object { -not ($_.PSIsContainer) -and $_.LastWriteTime -lt $Limit } |
  Remove-Item -Force
}

Export-ModuleMember -Function Backup-Server