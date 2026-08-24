# ============================================================
# PowerShell configuration
# ============================================================

# Main configuration loaded whenever PowerShell 7 starts.

# ============================================================
# Appearance
# ============================================================

# Use a softer foreground colour for directories in `ls` / `Get-ChildItem`.
$PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightBlack


# ============================================================
# Shell integration
# ============================================================

# Tell WezTerm the current working directory whenever Starship draws a prompt.
# This lets WezTerm reliably track each pane's current directory.
function Invoke-Starship-PreCommand {
    $currentLocation = $executionContext.SessionState.Path.CurrentLocation

    if ($currentLocation.Provider.Name -eq "FileSystem") {
        $escape = [char]27
        $path = $currentLocation.ProviderPath -replace "\\", "/"

        $osc7 = "$escape]7;file://${env:COMPUTERNAME}/${path}$escape\"
        $Host.UI.Write($osc7)
    }
}


# ============================================================
# Prompt
# ============================================================

# Initialize Starship as the PowerShell prompt.
Invoke-Expression (&starship init powershell)