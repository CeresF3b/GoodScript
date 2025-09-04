# WARNING: This is a COMPLETELY HARMLESS simulation script for demonstration purposes
# It does NOT actually delete or modify any system files

# ----------------------------
# Load PlaySound from winmm.dll
# ----------------------------
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Sound {
    [DllImport("winmm.dll")]
    public static extern bool PlaySound(string pszSound, IntPtr hmod, uint fdwSound);
}
"@

# Define sound constants
$SND_ALIAS = 0x00010000
$SND_ASYNC = 0x00000001

# Function to play Windows system sounds (no console output)
function Play-SystemSound {
    param([Parameter(Mandatory=$true)][string]$SoundName)
    try {
        [void][Sound]::PlaySound($SoundName, [IntPtr]::Zero, $SND_ALIAS -bor $SND_ASYNC)
    } catch {
        # Silently ignore if the system sound alias is missing
    }
}

# ----------------------------
# Speech (fail-safe)
# ----------------------------
$useVoice = $true
$speech = $null

try {
    Add-Type -AssemblyName System.Speech -ErrorAction Stop
    $speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speech.Volume = 100
    $speech.Rate   = -2
} catch {
    $useVoice = $false
}

# Funzione migliorata per parlare con sincronizzazione
function Say {
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [int]$Rate,
        [switch]$Async
    )
    if (-not $useVoice -or -not $speech) { return }
    
    $previousRate = $speech.Rate
    if ($PSBoundParameters.ContainsKey('Rate')) {
        $speech.Rate = $Rate
    }
    
    if ($Async) {
        $null = $speech.SpeakAsync($Text)
    } else {
        # Usa Speak() sincrono per aspettare che finisca
        $speech.Speak($Text)
    }
    
    # Ripristina il rate precedente
    if ($PSBoundParameters.ContainsKey('Rate')) {
        $speech.Rate = $previousRate
    }
}

# Funzione per aspettare che la voce finisca
function Wait-SpeechComplete {
    if (-not $useVoice -or -not $speech) { return }
    while ($speech.State -eq 'Speaking') {
        Start-Sleep -Milliseconds 100
    }
}

# ----------------------------
# Start of the simulation
# ----------------------------
Play-SystemSound "SystemStart"

Write-Host "`nChecking administrative privileges..." -ForegroundColor Gray
Start-Sleep -Milliseconds 1200
Play-SystemSound "SystemNotification"
Write-Host "[OK] Running with elevated privileges (PID: $PID)" -ForegroundColor Green

Write-Host "`nSystem Information:" -ForegroundColor Cyan
Write-Host "  OS Version: Windows 11 Build 22621.2506" -ForegroundColor Gray
Write-Host "  Architecture: x64" -ForegroundColor Gray
Write-Host "  System Root: C:\Windows" -ForegroundColor Gray
Start-Sleep -Seconds 1

Write-Host "`nInitializing system modules..." -ForegroundColor Yellow
Say -Text "Warning. System modification in progress." -Async
Write-Host "  [+] Loading kernel32.dll..." -ForegroundColor Gray
Play-SystemSound "SystemNotification"
Start-Sleep -Milliseconds 500
Write-Host "  [+] Loading ntdll.dll..." -ForegroundColor Gray
Play-SystemSound "SystemNotification"
Start-Sleep -Milliseconds 500
Write-Host "  [+] Acquiring SeDebugPrivilege..." -ForegroundColor Gray
Play-SystemSound "SystemExclamation"
Wait-SpeechComplete
Start-Sleep -Milliseconds 300

Write-Host "`nDisabling system protections..." -ForegroundColor Yellow
Write-Host "  [*] Windows Defender Real-time Protection: " -NoNewline -ForegroundColor Gray
Start-Sleep -Seconds 1
Write-Host "DISABLED" -ForegroundColor Red
Play-SystemSound "SystemHand"
Say -Text "Security disabled"
Write-Host "  [*] System File Protection (SFP): " -NoNewline -ForegroundColor Gray
Start-Sleep -Milliseconds 800
Write-Host "BYPASSED" -ForegroundColor Red
Play-SystemSound "SystemHand"
Write-Host "  [*] Volume Shadow Copy Service: " -NoNewline -ForegroundColor Gray
Start-Sleep -Milliseconds 600
Write-Host "STOPPED" -ForegroundColor Red
Play-SystemSound "SystemHand"

# Critical system files list
$systemFiles = @{
    "ntoskrnl.exe" = 8453120
    "hal.dll" = 453632
    "kernel32.dll" = 2097152
    "ntdll.dll" = 1839104
    "user32.dll" = 1699840
    "advapi32.dll" = 708608
    "gdi32.dll" = 442368
    "ole32.dll" = 1445888
    "shell32.dll" = 21237760
    "comctl32.dll" = 2179072
    "msvcrt.dll" = 775168
    "wininet.dll" = 4665344
    "ws2_32.dll" = 398848
    "rpcrt4.dll" = 1175552
    "cryptbase.dll" = 31232
    "bcryptprimitives.dll" = 477696
    "sechost.dll" = 494080
    "shlwapi.dll" = 334336
    "setupapi.dll" = 4464128
    "cfgmgr32.dll" = 254464
}

Write-Host "`n" -NoNewline
Write-Host "=================================================================================" -ForegroundColor Red
Play-SystemSound "SystemAsterisk"
Write-Host "WARNING: You are about to delete critical Windows system files from System32" -ForegroundColor Yellow
Write-Host "This action will render Windows completely inoperable and unrecoverable" -ForegroundColor Yellow
Say -Text "Critical warning. System32 deletion imminent." -Async
Write-Host "=================================================================================" -ForegroundColor Red
Write-Host "`nTarget Directory: C:\Windows\System32\" -ForegroundColor White
Write-Host "Total Files to Remove: $($systemFiles.Count)" -ForegroundColor White
Write-Host "Estimated Size: $([math]::Round(($systemFiles.Values | Measure-Object -Sum).Sum / 1MB, 2)) MB" -ForegroundColor White

Wait-SpeechComplete
Start-Sleep -Seconds 1

Write-Host "`n[CRITICAL] Beginning System32 deletion sequence..." -ForegroundColor Red -BackgroundColor DarkRed
Play-SystemSound ".Default"
Say -Text "Deletion sequence initiated"
Write-Host "`nPhase 1: Enumerating critical system files..." -ForegroundColor Cyan
Start-Sleep -Seconds 1

$fileCount   = 0
$totalSize   = 0
$soundCounter = 0

foreach ($file in $systemFiles.GetEnumerator()) {
    $fileCount++
    $totalSize += $file.Value
    $progress = [int](($fileCount / $systemFiles.Count) * 100)

    Write-Progress -Activity "Deleting System32 Files" -Status "Processing: $($file.Key)" -PercentComplete $progress

    Write-Host "[$progress%] " -NoNewline -ForegroundColor DarkCyan
    Write-Host "DELETE " -NoNewline -ForegroundColor Red -BackgroundColor DarkGray
    Write-Host " C:\Windows\System32\$($file.Key)" -NoNewline -ForegroundColor White
    Write-Host " (Size: $([math]::Round($file.Value / 1KB, 2)) KB)" -ForegroundColor DarkGray

    $soundCounter++
    if ($soundCounter % 3 -eq 0) {
        Play-SystemSound "MenuCommand"
    }

    $rand = Get-Random -Maximum 10
    if ($rand -eq 1) {
        Write-Host "       └── ERROR: Handle still in use by PID $(Get-Random -Minimum 1000 -Maximum 9999). Force closing..." -ForegroundColor Yellow
        Play-SystemSound "SystemExclamation"
        Start-Sleep -Milliseconds 300
    }
    elseif ($rand -eq 2) {
        Write-Host "       └── WARNING: Critical dependency detected. Proceeding anyway..." -ForegroundColor Magenta
    }
    elseif ($rand -eq 3) {
        Write-Host "       └── INFO: File locked by SYSTEM. Using low-level NTFS bypass..." -ForegroundColor Cyan
        Start-Sleep -Milliseconds 200
    }

    Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 400)
}

Write-Progress -Activity "Deleting System32 Files" -Completed

Write-Host "`nPhase 2: Registry cleanup..." -ForegroundColor Cyan
Start-Sleep -Seconds 1
Write-Host "  [!] HKLM\SYSTEM\CurrentControlSet\Services - CORRUPTED" -ForegroundColor Red
Play-SystemSound "SystemHand"
Start-Sleep -Milliseconds 500
Write-Host "  [!] HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion - CORRUPTED" -ForegroundColor Red
Play-SystemSound "SystemHand"
Start-Sleep -Milliseconds 500
Write-Host "  [!] HKLM\SOFTWARE\Classes - CORRUPTED" -ForegroundColor Red
Play-SystemSound "SystemHand"

Write-Host "`n[FATAL] System32 deletion completed." -ForegroundColor Red -BackgroundColor DarkRed
Write-Host "[FATAL] Total files removed: $fileCount" -ForegroundColor Red
Write-Host "[FATAL] Total size freed: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Red

Say -Text "System failure. Critical error detected." -Rate -4
Play-SystemSound ".Default"

Start-Sleep -Seconds 2

Write-Host "`n*** STOP: 0x0000007B (0xFFFFF880009A97E8, 0xFFFFFFFFC0000034, 0x0000000000000000, 0x0000000000000000)" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "INACCESSIBLE_BOOT_DEVICE" -ForegroundColor White -BackgroundColor DarkBlue
Play-SystemSound "SystemExit"

Write-Host "`n[ERROR] Windows Boot Manager has encountered a problem." -ForegroundColor Red
Write-Host "[ERROR] Status: 0xc000000f" -ForegroundColor Red
Write-Host "[ERROR] Info: Boot selection failed because a required device is inaccessible." -ForegroundColor Red

Write-Host "`n[SYSTEM] Initiating emergency shutdown to prevent hardware damage..." -ForegroundColor Yellow
Say -Text "Emergency shutdown sequence initiated" -Async
Play-SystemSound "SystemAsterisk"
Wait-SpeechComplete
Start-Sleep -Seconds 1

Write-Host "`nPreparing to shutdown..." -ForegroundColor White
Write-Host "  [*] Terminating running processes..." -ForegroundColor Gray
Play-SystemSound "MenuCommand"
Start-Sleep -Seconds 1
Write-Host "  [*] Flushing disk buffers..." -ForegroundColor Gray
Play-SystemSound "MenuCommand"
Start-Sleep -Milliseconds 800
Write-Host "  [*] Saving system state..." -ForegroundColor Gray
Play-SystemSound "MenuCommand"
Start-Sleep -Milliseconds 600
Write-Host "  [*] Broadcasting shutdown signal..." -ForegroundColor Gray
Play-SystemSound "MenuCommand"
Start-Sleep -Seconds 1

Write-Host "`n[CRITICAL] SYSTEM SHUTDOWN IN:" -ForegroundColor Red -BackgroundColor DarkRed

# Prepara la voce per il countdown
if ($useVoice) {
    $speech.Rate = 1  # Velocità normale per il countdown
}

for ($i = 10; $i -gt 0; $i--) {
    $startTime = Get-Date
    
    Write-Host "`r                              $i SECONDS " -NoNewline -ForegroundColor Yellow -BackgroundColor DarkRed
    
    if ($i -le 5) {
        # Per gli ultimi 5 secondi, pronuncia e suona insieme
        if ($i -eq 5) {
            Say -Text "Five" -Async
        } elseif ($i -eq 4) {
            Say -Text "Four" -Async
        } elseif ($i -eq 3) {
            Say -Text "Three" -Async
        } elseif ($i -eq 2) {
            Say -Text "Two" -Async
        } elseif ($i -eq 1) {
            Say -Text "One" -Async
        }
        Play-SystemSound "SystemExclamation"
    } else {
        Play-SystemSound "MenuCommand"
    }
    
    # Calcola quanto tempo aspettare per arrivare esattamente a 1 secondo
    $elapsed = (Get-Date) - $startTime
    $waitTime = 1000 - $elapsed.TotalMilliseconds
    if ($waitTime -gt 0) {
        Start-Sleep -Milliseconds $waitTime
    }
}

# Ripristina la velocità della voce
if ($useVoice) {
    $speech.Rate = -2
}

Write-Host "`n`n[INTERRUPT] Shutdown sequence aborted by process: exploit.exe" -ForegroundColor Green
Play-SystemSound "SystemNotification"
Say -Text "Shutdown aborted"
Start-Sleep -Milliseconds 500
Write-Host "[OVERRIDE] Administrator bypass detected" -ForegroundColor Green
Play-SystemSound "SystemStart"
Start-Sleep -Seconds 2

Clear-Host

Write-Host "`n`n`n`n`n" -NoNewline
Write-Host "=================================================================================" -ForegroundColor DarkGray
Write-Host "`n" -NoNewline

# Final mocking speech and voice selection (safe)
if ($useVoice) {
    try { $speech.SelectVoice("Microsoft Zira Desktop") } catch { }
}

Play-SystemSound "WindowsLogoff"

Write-Host "  Congratulations." -ForegroundColor Gray
Say -Text "Congratulations. You failed the security test." -Rate -2 -Async
Write-Host "`n  You just executed a random PowerShell script from the internet" -ForegroundColor Gray
Write-Host "  with administrative privileges." -ForegroundColor Gray
Write-Host "`n  In a real scenario, your system would now be:" -ForegroundColor Gray
Wait-SpeechComplete
Write-Host "  - Encrypted by ransomware" -ForegroundColor DarkRed
Start-Sleep -Milliseconds 200
Write-Host "  - Mining cryptocurrency for someone else" -ForegroundColor DarkRed
Start-Sleep -Milliseconds 200
Write-Host "  - Part of a botnet" -ForegroundColor DarkRed
Start-Sleep -Milliseconds 200
Write-Host "  - Completely compromised" -ForegroundColor DarkRed
Start-Sleep -Milliseconds 500
Write-Host "`n  Your cybersecurity awareness score: 0/100" -ForegroundColor Yellow
Say -Text "Security awareness score: zero out of one hundred."
Play-SystemSound "SystemHand"
Write-Host "`n  Perhaps next time you'll think twice before running unknown scripts." -ForegroundColor Gray
Write-Host "  But probably not." -ForegroundColor DarkGray
Write-Host "`n  No files were harmed during this educational experience." -ForegroundColor DarkGray
Write-Host "  Your computer, however, now judges you." -ForegroundColor DarkGray
Write-Host "`n=================================================================================" -ForegroundColor DarkGray
Write-Host "`n`n`n`n`n" -NoNewline

# Aspetta che la voce finisca completamente
Wait-SpeechComplete

# Mantieni la finestra aperta
Write-Host "`n`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Cleanup speech
if ($useVoice -and $speech) {
    $speech.Dispose()
}
