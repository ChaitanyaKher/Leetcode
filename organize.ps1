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

$trackerHtml = @"
<!DOCTYPE html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>LeetCode Tracker</title>
<style>
*{box-sizing:border-box}
body{font-family:sans-serif;margin:1.5rem;background:#0d1117;color:#c9d1d9}
h1{font-size:1.4rem}
.controls{display:flex;flex-wrap:wrap;gap:.75rem;margin-bottom:1rem}
input,select{padding:.6rem;background:#161b22;color:#c9d1d9;border:1px solid #30363d;border-radius:4px;font-size:1rem;flex:1;min-width:140px}
table{width:100%;border-collapse:collapse}
th,td{padding:.5rem;text-align:left;border-bottom:1px solid #30363d}
th{cursor:pointer;user-select:none;white-space:nowrap}
a{color:#58a6ff}
.Easy{color:#3fb950}.Medium{color:#d29922}.Hard{color:#f85149}
#count{margin-bottom:1rem;color:#8b949e}

@media (max-width: 640px) {
  body{margin:1rem}
  .controls{flex-direction:column}
  input,select{width:100%}
  thead{display:none}
  table, tbody, tr, td{display:block;width:100%}
  tr{border:1px solid #30363d;border-radius:6px;margin-bottom:.75rem;padding:.5rem;background:#161b22}
  td{border:none;padding:.3rem .2rem;display:flex;justify-content:space-between;gap:1rem}
  td::before{content:attr(data-label);font-weight:600;color:#8b949e}
}
</style></head>
<body>
<h1>LeetCode Tracker</h1>
<div id="count"></div>
<div class="controls">
<input id="search" placeholder="Search title or tag...">
<select id="diffFilter"><option value="">All Difficulties</option><option>Easy</option><option>Medium</option><option>Hard</option></select>
<select id="tagFilter"><option value="">All Tags</option></select>
</div>
<table id="tbl"><thead><tr>
<th data-key="num">#</th><th data-key="title">Problem</th><th data-key="difficulty">Difficulty</th><th data-key="tags">Tags</th><th>Solution</th>
</tr></thead><tbody id="body"></tbody></table>
<script>
const data = $dataJson;
let sortKey = "num", sortAsc = true;
const tagSet = new Set();
data.forEach(d => (d.tags||"").split(",").map(t=>t.trim()).filter(Boolean).forEach(t=>tagSet.add(t)));
const tagFilter = document.getElementById("tagFilter");
[...tagSet].sort().forEach(t => { const o=document.createElement("option"); o.textContent=t; tagFilter.appendChild(o); });

function render() {
  const q = document.getElementById("search").value.toLowerCase();
  const diff = document.getElementById("diffFilter").value;
  const tag = tagFilter.value;
  let rows = data.filter(d =>
    (d.title.toLowerCase().includes(q) || (d.tags||"").toLowerCase().includes(q)) &&
    (!diff || d.difficulty === diff) &&
    (!tag || (d.tags||"").split(",").map(t=>t.trim()).includes(tag))
  );
  rows.sort((a,b) => {
    const v = a[sortKey] > b[sortKey] ? 1 : -1;
    return sortAsc ? v : -v;
  });
  document.getElementById("count").textContent = rows.length + " problems";
  document.getElementById("body").innerHTML = rows.map(d =>
    `<tr>`+
    `<td data-label="#">`+d.num+`</td>`+
    `<td data-label="Problem">`+d.title+`</td>`+
    `<td data-label="Difficulty" class="`+d.difficulty+`">`+d.difficulty+`</td>`+
    `<td data-label="Tags">`+(d.tags||"")+`</td>`+
    `<td data-label="Solution"><a href="`+d.path+`">view</a></td>`+
    `</tr>`
  ).join("");
}
document.getElementById("search").addEventListener("input", render);
document.getElementById("diffFilter").addEventListener("change", render);
tagFilter.addEventListener("change", render);
document.querySelectorAll("th[data-key]").forEach(th => th.addEventListener("click", () => {
  const key = th.dataset.key;
  if (sortKey === key) sortAsc = !sortAsc; else { sortKey = key; sortAsc = true; }
  render();
}));
render();
</script>
</body></html>
"@

$trackerHtml | Set-Content "tracker.html"