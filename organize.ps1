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

        $isGenuineChange = $true
        if (Test-Path $destPath) {
            $oldHash = (Get-FileHash -Path $destPath -Algorithm SHA256).Hash
            $newHash = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
            $isGenuineChange = ($oldHash -ne $newHash)
        }

        Move-Item -Path $_.FullName -Destination $destPath -Force

        if ($isGenuineChange) {
            $datesDb[$slug] = (Get-Date).ToString('yyyy-MM-dd')
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

# 4. Build tracker data for index.html
$trackerData = @()
foreach ($s in $allFiles) {
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
    $history = if ($datesDb.ContainsKey($s.Slug)) { @($datesDb[$s.Slug] | Sort-Object) } else { @() }
    $latestDate = if ($history.Count -gt 0) { $history[-1] } else { "" }
    $trackerData += [PSCustomObject]@{
        num = $s.Num
        title = (Get-Culture).TextInfo.ToTitleCase($s.Title)
        tags = $tags
        difficulty = $difficulty
        path = $s.Path
        date = $latestDate
        timesSolved = $history.Count
        history = $history
    }
}

$dataJson = if ($trackerData.Count -gt 0) { @($trackerData | Sort-Object num) | ConvertTo-Json -Compress } else { "[]" }

$easyCount = ($trackerData | Where-Object { $_.difficulty -eq "Easy" }).Count
$medCount = ($trackerData | Where-Object { $_.difficulty -eq "Medium" }).Count
$hardCount = ($trackerData | Where-Object { $_.difficulty -eq "Hard" }).Count

# 5. Build index.html
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
.wrap{max-width:1400px;margin:0 auto}
.mono{font-family:'IBM Plex Mono',ui-monospace,monospace}
header{margin-bottom:1.5rem}
.count{font-size:2.25rem;font-weight:600;letter-spacing:-0.02em}
.count span{font-size:1rem;font-weight:400;color:var(--muted);margin-left:.5rem}
.breakdown{display:flex;gap:1.25rem;margin-top:.5rem;font-size:.85rem}
.breakdown span{color:var(--muted)}
.breakdown b{font-weight:500}
.dot{display:inline-block;width:7px;height:7px;border-radius:50%;margin-right:.4rem;vertical-align:middle}

.heatmap-section{margin-bottom:1rem}
.heatmap-wrap{display:flex;gap:6px}
.day-labels{display:flex;flex-direction:column;gap:3px;font-size:.65rem;color:var(--muted);padding-top:16px}
.day-labels span{height:10px;line-height:10px}
.heatmap-main{overflow-x:auto}
.month-row{display:flex;gap:3px;margin-bottom:4px;height:12px}
.month-label{width:10px;flex-shrink:0;font-size:.65rem;color:var(--muted);white-space:nowrap;overflow:visible}
.heatmap{display:flex;gap:3px}
.week{display:flex;flex-direction:column;gap:3px}
.day{width:10px;height:10px;border-radius:2px;background:var(--panel);border:1px solid var(--border);cursor:pointer}
.day[data-level="1"]{background:#3a3020;border-color:#3a3020}
.day[data-level="2"]{background:#6b5528;border-color:#6b5528}
.day[data-level="3"]{background:#a5822f;border-color:#a5822f}
.day[data-level="4"]{background:var(--accent);border-color:var(--accent)}
.day.selected{outline:2px solid var(--accent);outline-offset:1px}
.legend{display:flex;align-items:center;gap:4px;margin-top:.5rem;font-size:.7rem;color:var(--muted)}
.legend .day{width:9px;height:9px;cursor:default}
#date-filter-indicator{font-size:.8rem;color:var(--accent);margin-top:.4rem;cursor:pointer;display:none}

.summary{display:flex;flex-wrap:wrap;gap:1.75rem;margin:0 0 1.5rem;padding:1rem 0;border-top:1px solid var(--border);border-bottom:1px solid var(--border)}
.summary-block h3{font-size:.75rem;color:var(--muted);font-weight:500;margin:0 0 .4rem}
.summary-block .val{font-size:1.1rem}
.tag-list{display:flex;flex-wrap:wrap;gap:.4rem;max-width:none}
.tag-pill{background:var(--panel);border:1px solid var(--border);border-radius:3px;padding:.15rem .55rem;font-size:.78rem;color:var(--muted)}

.controls{display:flex;flex-wrap:wrap;gap:.6rem;margin:0 0 1rem}
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
  .summary{gap:1.25rem}
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

<div class="heatmap-section">
  <div class="heatmap-wrap">
    <div class="day-labels"><span></span><span>Mon</span><span></span><span>Wed</span><span></span><span>Fri</span><span></span></div>
    <div class="heatmap-main">
      <div class="month-row" id="month-row"></div>
      <div class="heatmap" id="heatmap"></div>
    </div>
  </div>
  <div class="legend">
    <span>Less</span>
    <div class="day" data-level="0"></div>
    <div class="day" data-level="1"></div>
    <div class="day" data-level="2"></div>
    <div class="day" data-level="3"></div>
    <div class="day" data-level="4"></div>
    <span>More</span>
    <span style="margin-left:.75rem"><b id="active-days" class="mono">0</b> active days</span>
  </div>
  <div id="date-filter-indicator"></div>
</div>

<div class="summary">
  <div class="summary-block"><h3>Current streak</h3><div class="val mono" id="current-streak">-</div></div>
  <div class="summary-block"><h3>Longest streak</h3><div class="val mono" id="longest-streak">-</div></div>
  <div class="summary-block"><h3>Best day</h3><div class="val mono" id="best-day">-</div></div>
  <div class="summary-block" style="flex:1;min-width:220px"><h3>Top tags</h3><div class="tag-list" id="top-tags"></div></div>
</div>

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
<th data-key="timesSolved" tabindex="0">Times</th>
<th data-key="date" tabindex="0">Last Solved</th>
<th>Solution</th>
</tr></thead><tbody id="body"></tbody></table>
</div>

<script>
const data = $dataJson;
let sortKey = "num", sortAsc = true;
let selectedDate = null;

const dayCounts = {};
data.forEach(function(d){ if (d.date) dayCounts[d.date] = (dayCounts[d.date]||0)+1; });

function fmt(d){
  const y = d.getFullYear();
  const m = String(d.getMonth()+1).padStart(2,'0');
  const day = String(d.getDate()).padStart(2,'0');
  return y + '-' + m + '-' + day;
}
const today = new Date(); today.setHours(0,0,0,0);
const start = new Date(today); start.setDate(start.getDate() - 370);
while (start.getDay() !== 0) start.setDate(start.getDate()-1);

const monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
let cur = new Date(start), weeksHtml = "", monthHtml = "", prevMonth = -1;
while (cur <= today) {
  const weekStart = new Date(cur);
  const m = weekStart.getMonth();
  if (m !== prevMonth) {
    monthHtml += "<div class='month-label'>" + monthNames[m] + "</div>";
    prevMonth = m;
  } else {
    monthHtml += "<div class='month-label'></div>";
  }

  let colHtml = "<div class='week'>";
  for (let i=0;i<7;i++){
    if (cur > today) {
      colHtml += "<div class='day' style='visibility:hidden'></div>";
    } else {
      const key = fmt(cur);
      const count = dayCounts[key]||0;
      let level = 0;
      if (count>=1) level=1; if(count>=3) level=2; if(count>=6) level=3; if(count>=10) level=4;
      colHtml += "<div class='day' data-level='" + level + "' data-date='" + key + "' title='" + key + ": " + count + " solved'></div>";
    }
    cur.setDate(cur.getDate()+1);
  }
  weeksHtml += colHtml + "</div>";
}
document.getElementById("heatmap").innerHTML = weeksHtml;
document.getElementById("month-row").innerHTML = monthHtml;
document.getElementById("active-days").textContent = Object.keys(dayCounts).length;

const sortedDates = Object.keys(dayCounts).sort();
let longest=0, streak=0, prevDate=null;
sortedDates.forEach(function(ds){
  const d=new Date(ds);
  streak = (prevDate && (d-prevDate)/86400000===1) ? streak+1 : 1;
  longest = Math.max(longest, streak);
  prevDate = d;
});
let currentStreak = 0;
if (sortedDates.length) {
  currentStreak = 1;
  for (let i=sortedDates.length-1;i>0;i--){
    const d1=new Date(sortedDates[i]), d0=new Date(sortedDates[i-1]);
    if ((d1-d0)/86400000===1) currentStreak++; else break;
  }
}
const bestDay = Object.entries(dayCounts).sort(function(a,b){return b[1]-a[1];})[0];
document.getElementById("longest-streak").textContent = longest + (longest===1?" day":" days");
document.getElementById("current-streak").textContent = currentStreak + (currentStreak===1?" day":" days");
document.getElementById("best-day").textContent = bestDay ? bestDay[1] + " on " + bestDay[0] : "-";

const tagCounts = {};
data.forEach(function(d){ (d.tags||"").split(",").map(function(t){return t.trim();}).filter(Boolean).forEach(function(t){ tagCounts[t]=(tagCounts[t]||0)+1; }); });
document.getElementById("top-tags").innerHTML = Object.entries(tagCounts).sort(function(a,b){return b[1]-a[1];}).slice(0,8)
  .map(function(p){ return "<span class='tag-pill'>" + p[0] + " . " + p[1] + "</span>"; }).join("");

const tagSet = new Set();
data.forEach(function(d){ (d.tags||"").split(",").map(function(t){return t.trim();}).filter(Boolean).forEach(function(t){ tagSet.add(t); }); });
const tagFilter = document.getElementById("tagFilter");
Array.from(tagSet).sort().forEach(function(t){ const o=document.createElement("option"); o.textContent=t; tagFilter.appendChild(o); });

function updateHeaderState() {
  document.querySelectorAll("th[data-key]").forEach(function(th){ th.classList.toggle("active", th.dataset.key === sortKey); });
}
const filterIndicator = document.getElementById("date-filter-indicator");
function render() {
  const q = document.getElementById("search").value.toLowerCase();
  const diff = document.getElementById("diffFilter").value;
  const tag = tagFilter.value;
  let rows = data.filter(function(d){
    return (d.title.toLowerCase().includes(q) || (d.tags||"").toLowerCase().includes(q)) &&
    (!diff || d.difficulty === diff) &&
    (!tag || (d.tags||"").split(",").map(function(t){return t.trim();}).includes(tag)) &&
    (!selectedDate || d.date === selectedDate);
  });
  rows.sort(function(a,b){ const v = a[sortKey] > b[sortKey] ? 1 : -1; return sortAsc ? v : -v; });
  document.getElementById("count-line").textContent = rows.length + " of " + data.length;
  document.getElementById("body").innerHTML = rows.map(function(d){
    return "<tr>" +
      "<td data-label='#' class='num mono'>" + d.num + "</td>" +
      "<td data-label='Problem'>" + d.title + "</td>" +
      "<td data-label='Difficulty' class='diff " + d.difficulty + "'>" + d.difficulty + "</td>" +
      "<td data-label='Tags' class='tags mono'>" + (d.tags||"") + "</td>" +
      "<td data-label='Times' class='mono'>" + d.timesSolved + "</td>" +
      "<td data-label='Last Solved' class='mono' title='" + (d.history||[]).join(', ') + "'>" + (d.date||"-") + "</td>" +
      "<td data-label='Solution'><a href='" + d.path + "'>open</a></td>" +
      "</tr>";
  }).join("");
  updateHeaderState();
  if (selectedDate) {
    filterIndicator.style.display = "block";
    filterIndicator.textContent = "Showing " + selectedDate + " only (click to clear)";
  } else {
    filterIndicator.style.display = "none";
  }
}
document.getElementById("search").addEventListener("input", render);
document.getElementById("diffFilter").addEventListener("change", render);
tagFilter.addEventListener("change", render);
document.querySelectorAll("th[data-key]").forEach(function(th){
  const activate = function(){
    if (sortKey === th.dataset.key) sortAsc = !sortAsc; else { sortKey = th.dataset.key; sortAsc = true; }
    render();
  };
  th.addEventListener("click", activate);
  th.addEventListener("keydown", function(e){ if (e.key === "Enter" || e.key === " ") { e.preventDefault(); activate(); } });
});
document.querySelectorAll(".day[data-date]").forEach(function(cell){
  cell.addEventListener("click", function(){
    const d = cell.dataset.date;
    if (selectedDate === d) {
      selectedDate = null;
      cell.classList.remove("selected");
    } else {
      document.querySelectorAll(".day.selected").forEach(function(c){ c.classList.remove("selected"); });
      selectedDate = d;
      cell.classList.add("selected");
    }
    render();
  });
});
filterIndicator.addEventListener("click", function(){
  selectedDate = null;
  document.querySelectorAll(".day.selected").forEach(function(c){ c.classList.remove("selected"); });
  render();
});
render();
</script>
</body></html>
"@

$trackerHtml | Set-Content "index.html"