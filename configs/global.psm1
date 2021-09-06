$GlobalDetails = @{
    #7zip
    SevenZip = ".\tools\7z\7za.exe"

    #mcrcon
    Mcrcon = ".\tools\mcrcon\mcrcon.exe"

    #SteamCMD
    SteamCMD = ".\tools\SteamCMD\steamcmd.exe"

    #Path of the logs folder.
    LogFolder = ".\logs"

    #Number of days to keep server logs
    Days = 30

    #Console Output Text Color
    FgColor = "Green"

    #Console Output Text Color for sections
    SectionColor = "Blue"

    #Console Output Background Color
    BgColor = "Black"
}

#Create the object
$Global = New-Object -TypeName PsObject -Property $GlobalDetails

Export-ModuleMember -Variable "Global"