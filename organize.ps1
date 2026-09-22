Set-Location "$PSScriptRoot"

# 1. Migrate already-bucketed flat files into their own problem subfolder
Get-ChildItem -Path . -Directory | Where-Object { $_.Name -match '^\d{4}-\d{4}$' } | ForEach-Object {
    $rangeDir = $_.FullName
    Get-ChildItem -Path $rangeDir -Filter "*.java" -File | ForEach-Object {
        if ($_.Name -match '^(\d{4})-(.+)\.java$') {
            $problemFolder = "$($matches[1])-$($matches[2])"
            $destDir = Join-Path $rangeDir $problemFolder
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Move-Item -Path $_.FullName -Destination (Join-Path $destDir $_.Name) -Force
        }
    }
}

# 2. Rename + bucket any new top-level files into range/problem subfolder
Get-ChildItem -Path . -Filter "*.java" -File | ForEach-Object {
    if ($_.Name -match '^(\d+)\.(.+)\.java$') {
        $problemNum = [int]$matches[1]
        $slug = ($matches[2].ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
        $paddedNum = $problemNum.ToString('0000')
        $newName = "$paddedNum-$slug.java"

        $rangeStart = [math]::Floor(($problemNum - 1) / 100) * 100 + 1
        $rangeEnd = $rangeStart + 99
        $rangeFolder = "{0:0000}-{1:0000}" -f $rangeStart, $rangeEnd
        $problemFolder = "$paddedNum-$slug"
        $destDir = Join-Path $rangeFolder $problemFolder

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        Move-Item -Path $_.FullName -Destination (Join-Path $destDir $newName) -Force
    }
}

# 3. Rebuild the solutions table in README.md, paginated by range folder, with tags
$tagsMap = @{}
if (Test-Path "tags.json") {
    $tagsJson = Get-Content "tags.json" -Raw | ConvertFrom-Json
    $tagsJson.PSObject.Properties | ForEach-Object { $tagsMap[$_.Name] = $_.Value }
}

$allFiles = Get-ChildItem -Path . -Recurse -Filter "*.java" -File |
    Where-Object { $_.Directory.Parent.Name -match '^\d{4}-\d{4}$' } |
    ForEach-Object {
        if ($_.Name -match '^(\d{4})-(.+)\.java$') {
            [PSCustomObject]@{
                Num   = [int]$matches[1]
                Slug  = $matches[2]
                Title = ($matches[2] -replace '-', ' ')
                Range = $_.Directory.Parent.Name
                Path  = "$($_.Directory.Parent.Name)/$($_.Directory.Name)/$($_.Name)"
            }
        }
    }

$rangeGroups = $allFiles | Group-Object Range | Sort-Object { [int]($_.Name -split '-')[0] }

$sections = @()
foreach ($group in $rangeGroups) {
    $rows = $group.Group | Sort-Object Num
    $lines = @("| # | Problem | Tags | Solution |", "|---|---------|------|----------|")
    foreach ($s in $rows) {
        $titleCased = (Get-Culture).TextInfo.ToTitleCase($s.Title)
        $tags = if ($tagsMap.ContainsKey($s.Slug)) { $tagsMap[$s.Slug] } else { "" }
        $lines += "| $($s.Num) | $titleCased | $tags | [$($s.Path)]($($s.Path)) |"
    }
    $sections += "<details>`n<summary>$($group.Name) ($($rows.Count) solved)</summary>`n`n$($lines -join "`n")`n`n</details>"
}

$startMarker = "<!-- SOLUTIONS-TABLE-START -->"
$endMarker   = "<!-- SOLUTIONS-TABLE-END -->"
$newBlock    = "$startMarker`n$($sections -join "`n`n")`n$endMarker"

$totalStart = "<!-- TOTAL-SOLVED -->"
$totalEnd   = "<!-- /TOTAL-SOLVED -->"
$totalLine  = "$totalStart$($allFiles.Count) problems solved$totalEnd"

if (-not (Test-Path "README.md")) {
    "# LeetCode Solutions`n`n$totalLine`n`n$newBlock" | Set-Content "README.md"
} else {
    $readme = Get-Content "README.md" -Raw

    $tStart = $readme.IndexOf($totalStart)
    $tEnd = $readme.IndexOf($totalEnd)
    if ($tStart -ge 0 -and $tEnd -ge 0) {
        $readme = $readme.Substring(0, $tStart) + $totalLine + $readme.Substring($tEnd + $totalEnd.Length)
    } else {
        $readme = "$totalLine`n`n$readme"
    }

    $sStart = $readme.IndexOf($startMarker)
    $sEnd = $readme.IndexOf($endMarker)
    if ($sStart -ge 0 -and $sEnd -ge 0) {
        $readme = $readme.Substring(0, $sStart) + $newBlock + $readme.Substring($sEnd + $endMarker.Length)
    } else {
        $readme += "`n`n$newBlock"
    }

    $readme | Set-Content "README.md"
}