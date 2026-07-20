[CmdletBinding()]
param(
    [ValidateSet("bootstrap", "build", "upload")]
    [string]$Action = "build",

    [ValidateSet("esp32s3-ospi", "esp32s3-qspi")]
    [string]$Profile = "esp32s3-ospi",

    [string]$Port
)

$ErrorActionPreference = "Stop"

$cliCommand = Get-Command arduino-cli -CommandType Application -ErrorAction SilentlyContinue
if ($cliCommand) {
    $arduinoCli = $cliCommand.Source
}
else {
    $installedCli = "C:\Program Files\Arduino CLI\arduino-cli.exe"
    if (-not (Test-Path -LiteralPath $installedCli)) {
        throw "arduino-cli was not found. Install it with: winget install --id ArduinoSA.CLI -e"
    }
    $arduinoCli = $installedCli
}

$sketchDirectory = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\ats-mini")).Path

function Invoke-ArduinoCli {
    param([string[]]$CliArguments)

    & $arduinoCli @CliArguments
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

if ($Action -eq "bootstrap") {
    Invoke-ArduinoCli -CliArguments @("lib", "update-index")
    $Action = "build"
}

if ($Action -eq "build") {
    Invoke-ArduinoCli -CliArguments @(
        "compile",
        "--profile", $Profile,
        "--export-binaries",
        "--warnings", "all",
        $sketchDirectory
    )
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Port)) {
    throw "A serial port is required for upload (for example, COM3)."
}

Invoke-ArduinoCli -CliArguments @(
    "upload",
    "--profile", $Profile,
    "--port", $Port,
    $sketchDirectory
)
