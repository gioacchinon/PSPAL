
!Space::
{
    if WinExist("PSPAL")
        WinActivate
    else
        Run "wt.exe -w _quake -p PSPAL"
}

^!Space::
{
    Run "wt.exe -p PSPAL"
}