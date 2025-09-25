^!Space::
{
    if WinExist("PSPAL")
        WinActivate
    else
        Run "wt.exe -p PSPAL"
}