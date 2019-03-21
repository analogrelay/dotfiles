# Relocate themes
$ThemeSettings.MyThemesLocation = Join-Path $DotFilesPs1Path "themes"

Set-Theme VibrantPrompt

# Use some different symbols
$ThemeSettings.GitSymbols.BranchUntrackedSymbol = [char]0xf005
$ThemeSettings.GitSymbols.BranchIdenticalStatusToSymbol = [char]0xe279

# Configure Colors
$ThemeSettings.Colors.PromptBackgroundColor = "Blue"
$ThemeSettings.Colors.GitLocalChangesColor = "Yellow"