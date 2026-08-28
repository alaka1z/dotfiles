# PowerShell 7 profile loaded through the standard $PROFILE

# Use a softer colour for directory names in directory listings
$PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightBlack

# Shortcuts

# Jump to the main configuration directory
function config {
    Set-Location "$HOME\.config"
}

# Reload the PowerShell configuration in the current session
function reload {
    . $PROFILE
}

# WezTerm integration

# Tell WezTerm the current working directory whenever Starship draws a prompt
# This lets WezTerm reliably track each pane's current directory
function Invoke-Starship-PreCommand {
    $currentLocation = $executionContext.SessionState.Path.CurrentLocation

    if ($currentLocation.Provider.Name -eq "FileSystem") {
        $escape = [char]27
        $path = $currentLocation.ProviderPath -replace "\\", "/"

        $osc7 = "$escape]7;file://${env:COMPUTERNAME}/${path}$escape\"
        $Host.UI.Write($osc7)
    }
}

# Prompt

# Initialize Starship as the PowerShell prompt
Invoke-Expression (&starship init powershell)
