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

$easyCount = ($trackerData | Where-Object { $_.difficulty -eq "Easy" }).Count
$medCount = ($trackerData | Where-Object { $_.difficulty -eq "Medium" }).Count
$hardCount = ($trackerData | Where-Object { $_.difficulty -eq "Hard" }).Count

$trackerHtml = @"
<!DOCTYPE html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>LeetCode Tracker</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
:root{
  --bg:#111417; --panel:#181c20; --border:#2a2f35;
  --text:#e7e9ec; --muted:#8b9199; --accent:#e3b341;
  --easy:#6fb98f; --medium:#d8a94f; --hard:#d9765f;
}
*{box-sizing:border-box}
body{
  font-family:'Inter',system-ui,sans-serif; margin:0; padding:2.5rem 1.5rem;
  background:var(--bg); color:var(--text); line-height:1.5;
}
.wrap{max-width:920px;margin:0 auto}
.mono{font-family:'IBM Plex Mono',ui-monospace,monospace}
header{margin-bottom:1.75rem}
.count{font-size:2.25rem;font-weight:600;letter-spacing:-0.02em}
.count span{font-size:1rem;font-weight:400;color:var(--muted);margin-left:.5rem}
.breakdown{display:flex;gap:1.25rem;margin-top:.5rem;font-size:.85rem}
.breakdown span{color:var(--muted)}
.breakdown b{font-weight:500}
.dot{display:inline-block;width:7px;height:7px;border-radius:50%;margin-right:.4rem;vertical-align:middle}

.controls{display:flex;flex-wrap:wrap;gap:.6rem;margin:1.5rem 0 1rem}
input,select{
  font-family:inherit;font-size:.9rem;padding:.55rem .7rem;
  background:var(--panel);color:var(--text);border:1px solid var(--border);
  border-radius:3px;flex:1;min-width:130px;
}
input:focus,select:focus,a:focus,th:focus{outline:2px solid var(--accent);outline-offset:1px}
#count-line{color:var(--muted);font-size:.85rem;margin-bottom:.75rem}

table{width:100%;border-collapse:collapse;font-size:.9rem}
th{
  text-align:left;font-weight:500;color:var(--muted);font-size:.8rem;
  padding:.5rem .6rem;border-bottom:1px solid var(--border);cursor:pointer;
  white-space:nowrap;
}
th.active{color:var(--accent)}
td{padding:.6rem;border-bottom:1px solid var(--border);vertical-align:middle}
tr:hover td{background:rgba(227,179,65,0.04)}
.num,.tags{color:var(--muted)}
a{color:var(--text);text-decoration:none;border-bottom:1px solid var(--border)}
a:hover{color:var(--accent);border-color:var(--accent)}
.diff{font-size:.85rem}
.Easy{color:var(--easy)}.Medium{color:var(--medium)}.Hard{color:var(--hard)}

@media (prefers-reduced-motion:no-preference){tr td{transition:background .1s ease}}

@media (max-width:640px){
  body{padding:1.5rem 1rem}
  .controls{flex-direction:column}
  thead{display:none}
  table,tbody,tr,td{display:block;width:100%}
  tr{border:1px solid var(--border);border-radius:4px;margin-bottom:.6rem;padding:.4rem .6rem}
  td{border:none;padding:.3rem 0;display:flex;justify-content:space-between;gap:1rem}
  td::before{content:attr(data-label);color:var(--muted);font-size:.8rem}
}
</style></head>
<body>
<div class="wrap">
<header>
  <div class="count mono">$($trackerData.Count)<span>solved</span></div>
  <div class="breakdown">
    <span><span class="dot" style="background:var(--easy)"></span><b>$easyCount</b> easy</span>
    <span><span class="dot" style="background:var(--medium)"></span><b>$medCount</b> medium</span>
    <span><span class="dot" style="background:var(--hard)"></span><b>$hardCount</b> hard</span>
  </div>
</header>

<div class="controls">
  <input id="search" placeholder="Search title or tag">
  <select id="diffFilter"><option value="">All difficulties</option><option>Easy</option><option>Medium</option><option>Hard</option></select>
  <select id="tagFilter"><option value="">All tags</option></select>
</div>
<div id="count-line"></div>

<table id="tbl"><thead><tr>
<th data-key="num" tabindex="0">#</th>
<th data-key="title" tabindex="0">Problem</th>
<th data-key="difficulty" tabindex="0">Difficulty</th>
<th data-key="tags" tabindex="0">Tags</th>
<th>Solution</th>
</tr></thead><tbody id="body"></tbody></table>
</div>

<script>
const data = $dataJson;
let sortKey = "num", sortAsc = true;
const tagSet = new Set();
data.forEach(d => (d.tags||"").split(",").map(t=>t.trim()).filter(Boolean).forEach(t=>tagSet.add(t)));
const tagFilter = document.getElementById("tagFilter");
[...tagSet].sort().forEach(t => { const o=document.createElement("option"); o.textContent=t; tagFilter.appendChild(o); });

function updateHeaderState() {
  document.querySelectorAll("th[data-key]").forEach(th => {
    th.classList.toggle("active", th.dataset.key === sortKey);
  });
}

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
  document.getElementById("count-line").textContent = rows.length + " of " + data.length;
  document.getElementById("body").innerHTML = rows.map(d =>
    `<tr>`+
    `<td data-label="#" class="num mono">`+d.num+`</td>`+
    `<td data-label="Problem">`+d.title+`</td>`+
    `<td data-label="Difficulty" class="diff `+d.difficulty+`">`+d.difficulty+`</td>`+
    `<td data-label="Tags" class="tags mono">`+(d.tags||"")+`</td>`+
    `<td data-label="Solution"><a href="`+d.path+`">open</a></td>`+
    `</tr>`
  ).join("");
  updateHeaderState();
}

document.getElementById("search").addEventListener("input", render);
document.getElementById("diffFilter").addEventListener("change", render);
tagFilter.addEventListener("change", render);
document.querySelectorAll("th[data-key]").forEach(th => {
  const activate = () => {
    if (sortKey === th.dataset.key) sortAsc = !sortAsc; else { sortKey = th.dataset.key; sortAsc = true; }
    render();
  };
  th.addEventListener("click", activate);
  th.addEventListener("keydown", e => { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); activate(); } });
});
render();
</script>
</body></html>
"@

$trackerHtml | Set-Content "index.html"