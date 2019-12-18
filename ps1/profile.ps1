$global:Profile_ScriptTimings = @{ }

$duration = Measure-Command { . "$PSScriptRoot\profile.inner.ps1" }

$global:Profile_ScriptTimings["profile.ps1"] = $duration