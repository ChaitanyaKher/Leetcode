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

# 2. Rename + bucket any new top-level files into range/problem subfolder, record solve dates
$datesDb = @{}
if (Test-Path "solve_dates.json") {
  $datesJson = Get-Content "solve_dates.json" -Raw | ConvertFrom-Json
  $datesJson.PSObject.Properties | ForEach-Object {
    $datesDb[$_.Name] = @($_.Value)
  }
}

Get-ChildItem -Path . -Filter "*.java" -File | ForEach-Object {
    if ($_.Name -match '^(\d+)[.\-](.+)\.java$') {
        $problemNum = [int]$matches[1]
        $slug = ($matches[2].ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
        $paddedNum = $problemNum.ToString('0000')
        $newName = "$paddedNum-$slug.java"

        $rangeStart = [math]::Floor(($problemNum - 1) / 100) * 100 + 1
        $rangeEnd = $rangeStart + 99
        $rangeFolder = "{0:0000}-{1:0000}" -f $rangeStart, $rangeEnd
        $problemFolder = "$paddedNum-$slug"
        $destDir = Join-Path $rangeFolder $problemFolder
        $destPath = Join-Path $destDir $newName

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        Move-Item -Path $_.FullName -Destination $destPath -Force

        $today = (Get-Date).ToString('yyyy-MM-dd')
        if (-not $datesDb.ContainsKey($slug)) {
            $datesDb[$slug] = @($today)
        } elseif ($datesDb[$slug] -notcontains $today) {
            $datesDb[$slug] = @($datesDb[$slug]) + $today
        }
    }
}

$datesDb | ConvertTo-Json | Set-Content "solve_dates.json"

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
    $meta = $tagsMap[$s.Slug]
    $tags = if ($meta -ne $null -and $meta.PSObject.Properties.Name -contains "tags") { $meta.tags } elseif ($meta -is [string]) { $meta } else { "" }
    $lines += "| $($s.Num) | $titleCased | $tags | [$($s.Path)]($($s.Path)) |"
  }
  $sections += "<details>`n<summary>$($group.Name) ($($rows.Count) solved)</summary>`n`n$($lines -join "`n")`n`n</details>"
}

$startMarker = "<!-- SOLUTIONS-TABLE-START -->"
$endMarker = "<!-- SOLUTIONS-TABLE-END -->"
$newBlock = "$startMarker`n$($sections -join "`n`n")`n$endMarker"

$totalStart = "<!-- TOTAL-SOLVED -->"
$totalEnd = "<!-- /TOTAL-SOLVED -->"
$totalLine = "$totalStart$($allFiles.Count) problems solved$totalEnd"

if (-not (Test-Path "README.md")) {
  "# LeetCode Solutions`n`n$totalLine`n`n$newBlock" | Set-Content "README.md"
}
else {
  $readme = Get-Content "README.md" -Raw

  $tStart = $readme.IndexOf($totalStart)
  $tEnd = $readme.IndexOf($totalEnd)
  if ($tStart -ge 0 -and $tEnd -ge 0) {
    $readme = $readme.Substring(0, $tStart) + $totalLine + $readme.Substring($tEnd + $totalEnd.Length)
  }
  else {
    $readme = "$totalLine`n`n$readme"
  }

  $sStart = $readme.IndexOf($startMarker)
  $sEnd = $readme.IndexOf($endMarker)
  if ($sStart -ge 0 -and $sEnd -ge 0) {
    $readme = $readme.Substring(0, $sStart) + $newBlock + $readme.Substring($sEnd + $endMarker.Length)
  }
  else {
    $readme += "`n`n$newBlock"
  }

  $readme | Set-Content "README.md"
}

# 4. Build tracker data for index.html (manual JSON construction - avoids PowerShell's array/JSON quirks)
function ConvertTo-JsonStringSafe($s) {
    if ($null -eq $s) { return '""' }
    $escaped = [string]$s
    $escaped = $escaped -replace '\\', '\\\\'
    $escaped = $escaped -replace '"', '\"'
    $escaped = $escaped -replace "`r", ''
    $escaped = $escaped -replace "`n", '\n'
    return '"' + $escaped + '"'
}

$jsonItems = @()
foreach ($s in ($allFiles | Sort-Object Num)) {
    $meta = $tagsMap[$s.Slug]
    $tags = ""
    $difficulty = ""
    if ($meta -ne $null) {
        if ($meta.PSObject.Properties.Name -contains "tags") {
            $tags = $meta.tags
            $difficulty = $meta.difficulty
        } elseif ($meta -is [string]) {
            $tags = $meta
        }
    }

    $rawHistory = $datesDb[$s.Slug]
    $historyList = New-Object System.Collections.ArrayList
    if ($rawHistory -ne $null) {
        foreach ($item in @($rawHistory)) {
            [void]$historyList.Add([string]$item)
        }
    }
    $historyList = @($historyList | Sort-Object)

    $latestDate = ""
    if ($historyList.Count -gt 0) {
        $latestDate = $historyList[$historyList.Count - 1]
    }

    $title = (Get-Culture).TextInfo.ToTitleCase(($s.Title))
    $historyJsonParts = @($historyList | ForEach-Object { ConvertTo-JsonStringSafe $_ })
    $historyJson = "[" + ($historyJsonParts -join ",") + "]"

    $jsonItems += '{"num":' + $s.Num + `
        ',"title":' + (ConvertTo-JsonStringSafe $title) + `
        ',"tags":' + (ConvertTo-JsonStringSafe $tags) + `
        ',"difficulty":' + (ConvertTo-JsonStringSafe $difficulty) + `
        ',"path":' + (ConvertTo-JsonStringSafe $s.Path) + `
        ',"date":' + (ConvertTo-JsonStringSafe $latestDate) + `
        ',"timesSolved":' + $historyList.Count + `
        ',"history":' + $historyJson + '}'
}
$dataJson = "[" + ($jsonItems -join ",") + "]"

$trackerData = @()
foreach ($s in $allFiles) {
    $rawHistory = $datesDb[$s.Slug]
    $count = 0
    if ($rawHistory -ne $null) { $count = @($rawHistory).Count }
    $trackerData += [PSCustomObject]@{ difficulty = if ($tagsMap[$s.Slug].difficulty) { $tagsMap[$s.Slug].difficulty } else { "" } }
}


$easyCount = ($trackerData | Where-Object { $_.difficulty -eq "Easy" }).Count
$medCount = ($trackerData | Where-Object { $_.difficulty -eq "Medium" }).Count
$hardCount = ($trackerData | Where-Object { $_.difficulty -eq "Hard" }).Count

# 5. Build index.html from template.html
$template    = Get-Content "$PSScriptRoot\template.html" -Raw -Encoding UTF8
$sheets      = Get-Content "$PSScriptRoot\sheets.json" -Raw -Encoding UTF8
$trackerHtml = $template.Replace('/*__DATA__*/[]', $dataJson).Replace('/*__SHEETS__*/[]', $sheets)
Set-Content -Path "$PSScriptRoot\index.html" -Value $trackerHtml -Encoding UTF8