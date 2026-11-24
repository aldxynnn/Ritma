<#
.SYNOPSIS
Creates git-ignored env/dev.json for RITMA using ONLY Supabase Project URL and Publishable/Anon Key.
NEVER supply sb_secret_* or service_role keys to Flutter client configuration.
#>

param(
  [string]$DefaultProjectUrl = 'https://ysgdtyexzmliidpiiarh.supabase.co'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$targetPath = Join-Path $repoRoot 'env\dev.json'

Write-Host 'RITMA — Supabase Cloud Local Environment Setup' -ForegroundColor Cyan
Write-Host 'Only public client credentials are accepted (never enter service_role or sb_secret_* keys).' -ForegroundColor Yellow

$urlInput = Read-Host "Supabase Project URL [$DefaultProjectUrl]"
$supabaseUrl = if ([string]::IsNullOrWhiteSpace($urlInput)) { $DefaultProjectUrl } else { $urlInput.Trim() }

if (-not $supabaseUrl.StartsWith('https://')) {
  throw 'Supabase Project URL must start with https://'
}

$keyInput = Read-Host 'Supabase Publishable Key (sb_publishable_...)'
$publishableKey = $keyInput.Trim()

if ([string]::IsNullOrWhiteSpace($publishableKey)) {
  throw 'Publishable key cannot be empty.'
}

if ($publishableKey.StartsWith('sb_secret_') -or $publishableKey -match 'service_role') {
  throw 'Security error: Secret/service_role keys must NEVER be written into Flutter env/dev.json.'
}

$envDir = Split-Path -Parent $targetPath
if (-not (Test-Path $envDir)) {
  New-Item -ItemType Directory -Path $envDir | Out-Null
}

$payload = [ordered]@{
  APP_ENV              = 'dev'
  APP_NAME             = 'RITMA'
  SUPABASE_URL         = $supabaseUrl
  SUPABASE_ANON_KEY    = $publishableKey
  ENABLE_DEBUG_LOGGING = 'true'
  ENABLE_DEMO_MODE     = 'false'
}

$json = $payload | ConvertTo-Json -Depth 2
Set-Content -Path $targetPath -Value $json -Encoding UTF8

Write-Host "Wrote git-ignored configuration to $targetPath" -ForegroundColor Green
Write-Host 'Run Flutter against Supabase Cloud with:' -ForegroundColor Cyan
Write-Host '  flutter run --dart-define-from-file=env/dev.json'
