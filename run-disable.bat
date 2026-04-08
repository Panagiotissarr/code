@echo off
title System Lockdown
echo Disabling Run dialog...

:: Disable Run dialog via registry
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f

:: Restart Explorer to apply the policy
taskkill /f /im explorer.exe
start explorer.exe

echo Closing all user applications...

taskkill /f /im chrome.exe        2>nul
taskkill /f /im firefox.exe       2>nul
taskkill /f /im msedge.exe        2>nul
taskkill /f /im notepad.exe       2>nul
taskkill /f /im code.exe          2>nul
taskkill /f /im discord.exe       2>nul
taskkill /f /im spotify.exe       2>nul
taskkill /f /im steam.exe         2>nul
taskkill /f /im vlc.exe           2>nul
taskkill /f /im winrar.exe        2>nul
taskkill /f /im 7zfm.exe          2>nul
taskkill /f /im taskmgr.exe       2>nul
taskkill /f /im mspaint.exe       2>nul
taskkill /f /im wordpad.exe       2>nul
taskkill /f /im outlook.exe       2>nul
taskkill /f /im teams.exe         2>nul
taskkill /f /im slack.exe         2>nul
taskkill /f /im obs64.exe         2>nul
taskkill /f /im brave.exe         2>nul
taskkill /f /im opera.exe         2>nul
taskkill /f /im vivaldi.exe       2>nul
taskkill /f /im thor.exe          2>nul
taskkill /f /im figma.exe         2>nul
taskkill /f /im notion.exe        2>nul
taskkill /f /im zoom.exe          2>nul
taskkill /f /im telegram.exe      2>nul
taskkill /f /im whatsapp.exe      2>nul
taskkill /f /im skype.exe         2>nul
taskkill /f /im onedrive.exe      2>nul
taskkill /f /im dropbox.exe       2>nul
taskkill /f /im foobar2000.exe    2>nul
taskkill /f /im wmplayer.exe      2>nul
taskkill /f /im mpv.exe           2>nul
taskkill /f /im potplayer.exe     2>nul
taskkill /f /im greenshot.exe     2>nul
taskkill /f /im sharex.exe        2>nul
taskkill /f /im everything.exe    2>nul
taskkill /f /im powertoys.exe     2>nul
taskkill /f /im gimp-2.10.exe     2>nul
taskkill /f /im inkscape.exe      2>nul
taskkill /f /im blender.exe       2>nul
taskkill /f /im fl.exe            2>nul
taskkill /f /im audacity.exe      2>nul
taskkill /f /im word.exe          2>nul
taskkill /f /im excel.exe         2>nul
taskkill /f /im powerpnt.exe      2>nul
taskkill /f /im winword.exe       2>nul
taskkill /f /im onenote.exe       2>nul
taskkill /f /im postman.exe       2>nul
taskkill /f /im insomnia.exe      2>nul
taskkill /f /im dbeaver.exe       2>nul
taskkill /f /im HeidiSQL.exe      2>nul

:: Skipping: Terminal (cmd, powershell, windowsterminal) and Calculator (calc)

echo Done!
pause
