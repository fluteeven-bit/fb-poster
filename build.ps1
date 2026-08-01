# 從 index.html 產生 artifact.html
# Artifact 發布時會自己包上 <!doctype html><head></head><body>，
# 所以這裡把外殼剝掉，只留 <title> / <style> / 內容 / <script>。
# 用法： powershell -ExecutionPolicy Bypass -File build.ps1

$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $dir 'index.html'
$out = Join-Path $dir 'artifact.html'

$html = [IO.File]::ReadAllText($src, [Text.UTF8Encoding]::new($false))

# 保留 <title> 之後、</script> 之前的全部內容
$start = $html.IndexOf('<title>')
$end   = $html.LastIndexOf('</script>')
if ($start -lt 0 -or $end -lt 0) { throw "index.html 結構不符預期，找不到 <title> 或 </script>" }
$body = $html.Substring($start, $end - $start + '</script>'.Length)

# 移除中間的 </head> 與 <body> 標籤
$body = $body -replace '(?m)^\s*</head>\s*$', ''
$body = $body -replace '(?m)^\s*<body>\s*$', ''
$body = $body.Trim() + "`n"

[IO.File]::WriteAllText($out, $body, [Text.UTF8Encoding]::new($false))

$kb = [math]::Round((Get-Item $out).Length / 1KB, 1)
Write-Output "artifact.html 已更新（$kb KB）"
