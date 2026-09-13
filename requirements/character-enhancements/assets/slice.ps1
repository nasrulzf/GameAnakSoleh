Add-Type -AssemblyName System.Drawing

$src = "D:\source\Game\GameAnakSoleh\requirements\character-enhancements\assets\character.jpeg"
$outDir = "D:\source\Game\GameAnakSoleh\assets\images\characters"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$colWidth = 282.5
# Batas atas/bawah tiap baris TIDAK dipatok manual (teks label "Diam",
# "Berjalan 1", dst tidak selalu pas di kelipatan 224px -- kadang meluber
# beberapa puluh piksel ke baris berikutnya tergantung panjang kata).
# Sebagai gantinya, tiap kolom dipindai vertikal utuh untuk menemukan 4
# "gugusan" piksel gelap yang tinggi (>60px = badan karakter), dipisahkan
# oleh celah putih bersih -- ini otomatis melewati teks caption yang jauh
# lebih pendek, dan akurat per kolom karena panjang tiap caption berbeda.
function Get-CharacterRuns($bmp, $xStart, $xEnd) {
  $h = $bmp.Height
  $darkCounts = New-Object int[] $h
  for ($y = 0; $y -lt $h; $y++) {
    $dark = 0
    for ($x = $xStart; $x -lt $xEnd; $x += 3) {
      $c = $bmp.GetPixel($x, $y)
      if ($c.R -lt 200 -and $c.G -lt 200 -and $c.B -lt 200) { $dark++ }
    }
    $darkCounts[$y] = $dark
  }
  $runs = @()
  $inRun = $false
  $runStart = 0
  $zeroCount = 0
  for ($y = 0; $y -lt $h; $y++) {
    if ($darkCounts[$y] -ge 2) {
      if (-not $inRun) { $inRun = $true; $runStart = $y }
      $zeroCount = 0
    } elseif ($inRun) {
      $zeroCount++
      if ($zeroCount -ge 5) {
        $runs += @{ start = $runStart; end = ($y - $zeroCount) }
        $inRun = $false
        $zeroCount = 0
      }
    }
  }
  if ($inRun) { $runs += @{ start = $runStart; end = ($h - 1) } }
  return @($runs | Where-Object { ($_.end - $_.start) -gt 60 })
}

$rows = @(
  @{ idx = 0; name = "boy_right" },
  @{ idx = 1; name = "boy_left" },
  @{ idx = 2; name = "girl_right" },
  @{ idx = 3; name = "girl_left" }
)
$cols = @(
  @{ idx = 0; name = "idle" },
  @{ idx = 1; name = "walk1" },
  @{ idx = 2; name = "walk2" },
  @{ idx = 3; name = "jump" }
)

$srcImg = [System.Drawing.Image]::FromFile($src)
$srcBmp = New-Object System.Drawing.Bitmap($srcImg)

function Convert-ToTransparent($bmp) {
  $w = $bmp.Width
  $h = $bmp.Height
  $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $stride = $data.Stride
  $bytes = New-Object byte[] ($stride * $h)
  [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)

  $visited = New-Object bool[] ($w * $h)
  $queue = New-Object System.Collections.Generic.Queue[int]

  function IsWhiteAt($bytes, $stride, $x, $y) {
    $o = $y * $stride + $x * 4
    return ($bytes[$o + 2] -ge 235 -and $bytes[$o + 1] -ge 235 -and $bytes[$o] -ge 235)
  }

  for ($x = 0; $x -lt $w; $x++) {
    foreach ($y in 0, ($h - 1)) {
      $idx = $y * $w + $x
      if (-not $visited[$idx] -and (IsWhiteAt $bytes $stride $x $y)) {
        $visited[$idx] = $true
        $queue.Enqueue($idx)
      }
    }
  }
  for ($y = 0; $y -lt $h; $y++) {
    foreach ($x in 0, ($w - 1)) {
      $idx = $y * $w + $x
      if (-not $visited[$idx] -and (IsWhiteAt $bytes $stride $x $y)) {
        $visited[$idx] = $true
        $queue.Enqueue($idx)
      }
    }
  }

  while ($queue.Count -gt 0) {
    $idx = $queue.Dequeue()
    $cx = $idx % $w
    $cy = [int]($idx / $w)
    $neighbors = @(
      @{ x = $cx - 1; y = $cy }, @{ x = $cx + 1; y = $cy },
      @{ x = $cx; y = $cy - 1 }, @{ x = $cx; y = $cy + 1 }
    )
    foreach ($n in $neighbors) {
      if ($n.x -lt 0 -or $n.x -ge $w -or $n.y -lt 0 -or $n.y -ge $h) { continue }
      $nIdx = $n.y * $w + $n.x
      if ($visited[$nIdx]) { continue }
      if (IsWhiteAt $bytes $stride $n.x $n.y) {
        $visited[$nIdx] = $true
        $queue.Enqueue($nIdx)
      }
    }
  }

  # Dilasi 2 iterasi: piksel terang (>=200) yang bertetangga dengan area
  # transparan ikut ditransparankan, supaya cincin abu-abu bekas kompresi
  # JPEG di tepi karakter tidak menempel sebagai halo putih kotor.
  for ($iter = 0; $iter -lt 2; $iter++) {
    $toAdd = New-Object System.Collections.Generic.List[int]
    for ($y = 0; $y -lt $h; $y++) {
      for ($x = 0; $x -lt $w; $x++) {
        $idx = $y * $w + $x
        if ($visited[$idx]) { continue }
        $o = $idx * 4
        $bright = ($bytes[$o] + $bytes[$o + 1] + $bytes[$o + 2]) / 3
        if ($bright -lt 200) { continue }
        $adjTransparent = $false
        foreach ($d in @(@{dx=-1;dy=0}, @{dx=1;dy=0}, @{dx=0;dy=-1}, @{dx=0;dy=1})) {
          $nx = $x + $d.dx; $ny = $y + $d.dy
          if ($nx -lt 0 -or $nx -ge $w -or $ny -lt 0 -or $ny -ge $h) { continue }
          if ($visited[$ny * $w + $nx]) { $adjTransparent = $true; break }
        }
        if ($adjTransparent) { $toAdd.Add($idx) }
      }
    }
    foreach ($idx in $toAdd) { $visited[$idx] = $true }
  }

  for ($i = 0; $i -lt ($w * $h); $i++) {
    if ($visited[$i]) {
      $o = $i * 4
      $bytes[$o + 3] = 0
    }
  }

  [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $data.Scan0, $bytes.Length)
  $bmp.UnlockBits($data)
  return $visited
}

function Get-ContentBounds($bmp) {
  $w = $bmp.Width; $h = $bmp.Height
  $rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
  $data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $stride = $data.Stride
  $bytes = New-Object byte[] ($stride * $h)
  [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
  $bmp.UnlockBits($data)

  $minX = $w; $maxX = -1; $minY = $h; $maxY = -1
  for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
      $o = $y * $stride + $x * 4
      if ($bytes[$o + 3] -gt 10) {
        if ($x -lt $minX) { $minX = $x }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($y -gt $maxY) { $maxY = $y }
      }
    }
  }
  if ($maxX -lt 0) { return $null }
  return @{ x = $minX; y = $minY; w = ($maxX - $minX + 1); h = ($maxY - $minY + 1) }
}

# Beberapa sel menyatu dengan teks caption tetangganya karena celah putih
# di antara keduanya terlalu tipis (2-4px, di bawah ambang deteksi celah)
# -- baik ekor caption baris sebelumnya yang nempel di atas karakter
# (top override), maupun caption milik baris itu sendiri yang nempel di
# bawah kaki karakter (bottom override). Nilainya diukur langsung dari
# piksel sumber (lihat riwayat analisis).
$manualTopOverride = @{ "jump_1" = 248; "jump_2" = 470 }
$manualBottomOverride = @{ "idle_3" = 870; "walk1_3" = 869; "walk2_3" = 869 }

foreach ($col in $cols) {
  $x = [int](70 + $col.idx * $colWidth)
  $x1 = [int]($x + $colWidth)
  $runs = Get-CharacterRuns $srcBmp $x $x1
  Write-Output "col $($col.name): found $($runs.Count) runs -> $(($runs | ForEach-Object { "$($_.start)-$($_.end)" }) -join ', ')"
  if ($runs.Count -ne 4) {
    throw "Expected 4 character runs for column $($col.name), got $($runs.Count)"
  }
  foreach ($row in $rows) {
    $run = $runs[$row.idx]
    $overrideKey = "$($col.name)_$($row.idx)"
    if ($manualTopOverride.ContainsKey($overrideKey)) {
      $top = $manualTopOverride[$overrideKey]
    } else {
      $top = $run.start
    }
    if ($manualBottomOverride.ContainsKey($overrideKey)) {
      $bottom = $manualBottomOverride[$overrideKey]
    } else {
      $bottom = $run.end
    }
    $contentH = ($bottom - $top + 1)
    $rect = New-Object System.Drawing.Rectangle($x, $top, [int]$colWidth, $contentH)
    $cell = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($cell)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($srcBmp, (New-Object System.Drawing.Rectangle(0, 0, $rect.Width, $rect.Height)), $rect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    Convert-ToTransparent $cell | Out-Null
    $bounds = Get-ContentBounds $cell
    $pad = 3
    $bx = [Math]::Max(0, $bounds.x - $pad)
    $by = [Math]::Max(0, $bounds.y - $pad)
    $bw = [Math]::Min($cell.Width - $bx, $bounds.w + $pad * 2)
    $bh = [Math]::Min($cell.Height - $by, $bounds.h + $pad * 2)
    $finalBmp = New-Object System.Drawing.Bitmap($bw, $bh, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g2 = [System.Drawing.Graphics]::FromImage($finalBmp)
    $g2.DrawImage($cell, (New-Object System.Drawing.Rectangle(0, 0, $bw, $bh)), (New-Object System.Drawing.Rectangle($bx, $by, $bw, $bh)), [System.Drawing.GraphicsUnit]::Pixel)
    $g2.Dispose()

    $outPath = Join-Path $outDir "$($row.name)_$($col.name).png"
    $finalBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $finalBmp.Dispose()
    $cell.Dispose()
    Write-Output "saved $outPath ($bw x $bh)"
  }
}

$srcBmp.Dispose()
$srcImg.Dispose()
