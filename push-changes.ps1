# Git Auto Commit and Push Script
# Usage: Run .\push-changes.ps1 in PowerShell

Write-Host "Starting Git commit and push..." -ForegroundColor Green

# Find Git executable
$gitPaths = @(
    "C:\Program Files\Git\cmd\git.exe",
    "C:\Program Files (x86)\Git\cmd\git.exe",
    "git.exe"
)

$gitExe = $null
foreach ($path in $gitPaths) {
    if (Test-Path $path) {
        $gitExe = $path
        break
    }
    # Try to find in PATH
    $found = Get-Command $path -ErrorAction SilentlyContinue
    if ($found) {
        $gitExe = $found.Path
        break
    }
}

if (-not $gitExe) {
    Write-Host "Error: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git first: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Add Git to PATH for this session
$gitDir = Split-Path -Parent $gitExe
if ($env:Path -notlike "*$gitDir*") {
    $env:Path = "$gitDir;$env:Path"
}

# Check if Git is available
try {
    $gitVersion = git --version
    Write-Host "Git version: $gitVersion" -ForegroundColor Cyan
} catch {
    Write-Host "Error: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git first: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Switch to project directory
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectPath
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Cyan

# Step 1: Add all changes
Write-Host "`nStep 1: Adding all changes..." -ForegroundColor Yellow
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: git add failed" -ForegroundColor Red
    exit 1
}
Write-Host "All changes added" -ForegroundColor Green

# Step 2: Check if there are changes to commit
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "`nNo changes to commit" -ForegroundColor Yellow
    exit 0
}

# Step 3: Commit changes
Write-Host "`nStep 2: Committing changes..." -ForegroundColor Yellow
$commitMessage = "Auto-commit: Complete Task 1 - Fix localStorage error handling

- Create Storage utility module for unified localStorage management
- Add comprehensive error handling (QuotaExceededError, SecurityError)
- Implement auto-cleanup of oldest save slots
- Add recursion limit to prevent infinite loops
- Optimize performance by reducing duplicate localStorage calls
- Replace all localStorage calls (20 locations)
- 100% error handling coverage"

git commit -m $commitMessage
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: git commit failed" -ForegroundColor Red
    exit 1
}
Write-Host "Changes committed" -ForegroundColor Green

# Step 4: Push to remote repository
Write-Host "`nStep 3: Pushing to remote repository..." -ForegroundColor Yellow
$branch = git branch --show-current
Write-Host "Current branch: $branch" -ForegroundColor Cyan

git push origin $branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: git push failed" -ForegroundColor Red
    Write-Host "Hint: You may need to set up remote repository or configure authentication" -ForegroundColor Yellow
    exit 1
}
Write-Host "Changes pushed to remote repository" -ForegroundColor Green

Write-Host "`nAll operations completed!" -ForegroundColor Green
