# MP3 Compression Script
# Usage: .\compress-mp3.ps1 -InputFile "input.mp3" -Quality "medium"
# Quality options: high (192kbps), medium (128kbps), low (96kbps), verylow (64kbps)

param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("high", "medium", "low", "verylow")]
    [string]$Quality = "medium",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputFile = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$Mono = $false
)

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "Error: File not found '$InputFile'" -ForegroundColor Red
    exit 1
}

# Set bitrate based on quality
$bitrate = switch ($Quality) {
    "high" { "192k" }
    "medium" { "128k" }
    "low" { "96k" }
    "verylow" { "64k" }
}

# Auto-generate output filename if not specified
if ($OutputFile -eq "") {
    $directory = Split-Path $InputFile
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
    $extension = [System.IO.Path]::GetExtension($InputFile)
    $OutputFile = Join-Path $directory "$filename-compressed$extension"
}

# Get original file size
$originalSize = (Get-Item $InputFile).Length / 1MB

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MP3 Compression Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Input file:  $InputFile" -ForegroundColor Yellow
Write-Host "Output file: $OutputFile" -ForegroundColor Yellow
Write-Host "Quality:     $Quality ($bitrate)" -ForegroundColor Yellow
Write-Host "Original size: $([math]::Round($originalSize, 2)) MB" -ForegroundColor Yellow

# Build FFmpeg command
$ffmpegArgs = @(
    "-i", $InputFile,
    "-b:a", $bitrate,
    "-y"  # Overwrite output file
)

# Add mono option if specified
if ($Mono) {
    $ffmpegArgs += @("-ac", "1")
    Write-Host "Audio mode: Mono" -ForegroundColor Yellow
}
else {
    Write-Host "Audio mode: Keep original" -ForegroundColor Yellow
}

$ffmpegArgs += $OutputFile

Write-Host ""
Write-Host "Compressing..." -ForegroundColor Green

# Find FFmpeg executable
$ffmpegPath = Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $ffmpegPath) {
    # Try to find in WinGet packages
    $ffmpegPath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $ffmpegPath) {
    Write-Host ""
    Write-Host "Error: FFmpeg not found. Please restart PowerShell or install FFmpeg." -ForegroundColor Red
    exit 1
}

# Execute FFmpeg
try {
    & $ffmpegPath @ffmpegArgs 2>&1 | Out-Null
    
    # Get compressed file size
    $compressedSize = (Get-Item $OutputFile).Length / 1MB
    $reduction = (1 - ($compressedSize / $originalSize)) * 100
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Compression Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Compressed size: $([math]::Round($compressedSize, 2)) MB" -ForegroundColor Green
    Write-Host "Size reduction:  $([math]::Round($reduction, 1))%" -ForegroundColor Green
    Write-Host "Output file:     $OutputFile" -ForegroundColor Green
    
}
catch {
    Write-Host ""
    Write-Host "Error: Compression failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
