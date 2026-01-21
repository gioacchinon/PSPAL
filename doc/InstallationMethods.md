# Installation Methods 

## Generic
> installer [`install/generic.ps1`](/install/generic.ps1)

### Steps
1. **Download/Clone the Repository** 
   - Clone this repository to a location of your choice (e.g., `C:\Tools\PSPAL` or `D:\PowerShell\PSPAL`)
   - Alternatively, download the ZIP file and extract it

	> the location will be referred below, in this document, as `{PSPal root}`

2. **Set Environment Variable (Optional but Recommended)**
   - Create an environment variable `PSPAL_HOME` pointing to your installation directory
   - This makes it easier to reference the location in scripts and helps with updates
   - **Windows**: Right-click "This PC" → Properties → Advanced system settings → Environment Variables

3. **Load into PowerShell Profile**
   - Open your PowerShell profile: `notepad $PROFILE` (create if it doesn't exist)
   - Add the following line to dot-source PSPAL:
     ```powershell
     . "{PSPal root}\PROFILE.ps1"
     ```
   - Save and restart PowerShell

4. **Verify Installation**
   - Check that PSPAL functions are available: `Get-Command -Module PSPAL` or test a known alias
   - If commands aren't recognized, check your `$PROFILE` path is correct

### Tips
- Keep PSPAL in a location without spaces to avoid path issues
- Back up your original PowerShell `$PROFILE` before modifying it
- You can test the profile in a new PowerShell window without restarting

---

## Windows Terminal

> installer [`install/wt.ps1`](/install/generic.ps1) with `ForWindowsTerminal` set to `true`

### Manual Steps

1. **Copy PSPAL to Your Preferred Location**
   - Choose a directory (e.g., `C:\Tools\PSPAL`)
   - Copy the entire PSPAL folder there
   - *(Recommended)* Save the path in an environment variable (e.g. `PSPAL_HOME`) for easy reference in scripts

		> the location will be referred below, in this document, as `{PSPal root}`

2. **Configure Windows Terminal Profile**~
   - Open Windows Terminal Settings (Ctrl + ,)
	- Under `Profiles` click `Add a new profile`, then `+ New empty profile` 
	- Set `Command Line` to 'pwsh.exe', or locate powershell executable, `icon` to '{PSPal root}\icons\icon.ico'

	- Click `Open JSON file` one the lower left
   - Locate your PowerShell profile in the JSON
   - Add the environment variable to your profile configuration:
     ```json
     {
       "environment": {
         "WT_PROFILE_NAME": "PSPal"
       }
     }
     ```
   - Save and close settings

3. **Set Up PowerShell Profile with Conditional Loading**
   - Open your PowerShell profile: `notepad $PROFILE`
   - *(Recommended)* Use a conditional approach based on the `WT_PROFILE_NAME` environment variable:
     ```powershell
     # Load PSPAL only when running in Windows Terminal with the PSPal profile
     if ($env:WT_PROFILE_NAME -eq "PSPal") {
       . "{PSPal root}\PROFILE.ps1"
     }
     ```
   - Alternatively, dot-source directly (simpler but loads in all contexts):
     ```powershell
     . "{PSPal root}\PROFILE.ps1"
     ```

4. **Optional: Add AutoHotkey to Startup** (Recommended)
   - Add the compiled `ahk/PSPAL.exe` to your Windows Startup folder:
     - Press `Win + R`, type `shell:startup`, and press Enter
     - Copy the compiled AHK executable to this folder
   - This enables keyboard shortcuts and automations globally, even outside PowerShell

	> if u edit the .ahk you'll need to compile it again, in this case refer to [Auto Hot Key Documentation](https://www.autohotkey.com/docs/v2/)

5. **Finalize and Test**
   - Close and reopen Windows Terminal
   - Test PSPAL functions: try an alias or custom command
   - Configure additional settings in `SETTINGS.ps1` and `ALIASES.ps1` as needed

### Tips
- Use the conditional `WT_PROFILE_NAME` approach to load PSPAL only in specific terminal profiles, keeping other PowerShell instances clean
- Store the PSPAL path in `PSPAL_HOME` environment variable for consistency across scripts
- If the AutoHotkey script conflicts with other tools, you can skip step 4 and enable it selectively
- Test changes in a new terminal window without closing your current one to avoid losing work
- For troubleshooting, run `$PROFILE` to check the loaded profile path, or `Test-Path $PROFILE` to verify it exists

---

## Troubleshooting

**Functions not loading?**
- Verify the path in `$PROFILE` is correct: `cat $PROFILE`
- Check file permissions on the PSPAL directory
- Ensure PSPAL.ps1 and PROFILE.ps1 exist in your installation directory

**Environment variable not recognized?**
- After setting an environment variable, restart PowerShell or restart Windows for system-level variables
- Use `$env:PSPAL_HOME` to verify it's set in PowerShell

**Conflicts with other tools?**
- If PSPAL aliases override your existing commands, adjust `ALIASES.ps1`
- Use the Windows Terminal conditional loading (step 3 above) to isolate PSPAL to specific profiles