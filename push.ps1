Set-Location "$PSScriptRoot"

# 1. Fetch tags for any problems not yet cached
python "$PSScriptRoot\fetch_tags.py"

# 2. Organize files and rebuild README (tags.json is now current)
& "$PSScriptRoot\organize.ps1"

# 3. Commit the tooling itself if it's never been tracked / has changed
$toolingFiles = @("push.ps1", "organize.ps1", "fetch_tags.py", "leetcode_sync.py", ".gitignore") | Where-Object { Test-Path $_ }
$toolingChanged = git status --porcelain --untracked-files=all -- $toolingFiles
if ($toolingChanged) {
    git add $toolingFiles
    git commit -m "Update automation scripts"
}

$changes = git status --porcelain --untracked-files=all | Where-Object { $_ -match '\.java$' }
$readmeChanged = git status --porcelain --untracked-files=all | Where-Object { $_ -match 'README\.md$' }
$tagsChanged = git status --porcelain --untracked-files=all | Where-Object { $_ -match 'tags\.json$' }

if (-not $changes -and -not $readmeChanged -and -not $tagsChanged) {
    Write-Host "No changes to commit."
    exit 0
}

# Load fresh solve history and tags (organize.ps1 already updated these this run)
$datesLookup = @{}
if (Test-Path "solve_dates.json") {
    $datesJson = Get-Content "solve_dates.json" -Raw | ConvertFrom-Json
    $datesJson.PSObject.Properties | ForEach-Object { $datesLookup[$_.Name] = @($_.Value) }
}

$tagsLookup = @{}
if (Test-Path "tags.json") {
    $tagsJson = Get-Content "tags.json" -Raw | ConvertFrom-Json
    $tagsJson.PSObject.Properties | ForEach-Object { $tagsLookup[$_.Name] = $_.Value }
}

foreach ($line in $changes) {
    $filePath = $line.Substring(3).Trim().Trim('"')
    $fileName = Split-Path $filePath -Leaf

    if ($fileName -match '^(\d{4})-(.+)\.java$') {
        $num = $matches[1]
        $slug = $matches[2]
        $title = (Get-Culture).TextInfo.ToTitleCase(($slug -replace '-', ' '))

        $timesSolved = 0
        if ($datesLookup.ContainsKey($slug)) {
            $timesSolved = @($datesLookup[$slug]).Count
        }

        $difficulty = ""
        $meta = $tagsLookup[$slug]
        if ($meta -ne $null -and $meta.PSObject.Properties.Name -contains "difficulty") {
            $difficulty = $meta.difficulty
        }
        $diffSuffix = if ($difficulty) { " ($difficulty)" } else { "" }

        if ($timesSolved -le 1) {
            $message = "Solved $num`: $title$diffSuffix"
        } else {
            $message = "Re-solved $num`: $title$diffSuffix - attempt $timesSolved"
        }
    } else {
        $message = "Update $fileName"
    }

    git add $filePath
    git commit -m $message
}

$readmeTagsFiles = @("README.md", "tags.json", "index.html", "solve_dates.json") | Where-Object { Test-Path $_ }
if (($readmeChanged -or $tagsChanged) -and $readmeTagsFiles) {
    git add $readmeTagsFiles
    git commit -m "Update solutions table and tags"
}

git push origin main