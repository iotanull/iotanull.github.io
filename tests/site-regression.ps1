param(
  [string]$PublicDir = (Join-Path $PSScriptRoot '..\public')
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$publicRoot = (Resolve-Path $PublicDir).Path
$regressionFailures = @()

function Assert-SiteCondition {
  param(
    [bool]$Condition,
    [string]$Message
  )

  if ($Condition) {
    Write-Host "PASS: $Message"
  } else {
    $script:regressionFailures += $Message
    Write-Host "FAIL: $Message"
  }
}

$homeLayout = Get-Content -Raw (Join-Path $projectRoot 'layouts\home.html')
$artLayout = Get-Content -Raw (Join-Path $projectRoot 'layouts\art\list.html')
$lightboxScript = Get-Content -Raw (Join-Path $projectRoot 'assets\js\art-lightbox.js')
$customCss = Get-Content -Raw (Join-Path $projectRoot 'assets\css\extended\custom.css')
$homeHtml = Get-Content -Raw (Join-Path $publicRoot 'index.html')

$socialBlock = [regex]::Match($homeLayout, '(?s)<nav class="home-socials".*?</nav>').Value
$socialLabels = [regex]::Matches($socialBlock, 'aria-label="([^"]+)"') |
  ForEach-Object { $_.Groups[1].Value } |
  Where-Object { $_ -ne 'Social links' }
Assert-SiteCondition (($socialLabels -join '|') -eq 'GitHub|Email|ArtStation|RSS feed') 'Homepage social order is GitHub, Email, ArtStation, RSS.'
Assert-SiteCondition ($homeHtml.Contains('mailto:iotamail@protonmail.com')) 'Homepage contains the requested email link.'

$artstationAssetPath = Join-Path $projectRoot 'assets\icons\artstation.svg'
Assert-SiteCondition (Test-Path $artstationAssetPath) 'Provided ArtStation asset is installed in the Hugo asset pipeline.'
if (Test-Path $artstationAssetPath) {
  $artstationAsset = Get-Content -Raw $artstationAssetPath
  Assert-SiteCondition ($artstationAsset.Contains('currentColor')) 'ArtStation SVG inherits the shared icon color.'
  Assert-SiteCondition ($artstationAsset.Contains('M0 23.63l2.703 4.672')) 'ArtStation SVG keeps the supplied logo geometry.'
}

$faviconPath = Join-Path $projectRoot 'static\facicon.svg'
Assert-SiteCondition (Test-Path $faviconPath) 'Provided facicon.svg is installed under static.'
Assert-SiteCondition (-not (Test-Path (Join-Path $projectRoot 'static\favicon.svg'))) 'Obsolete favicon.svg has been removed.'
Assert-SiteCondition ($homeHtml.Contains('/facicon.svg')) 'Generated head references the provided SVG favicon.'

Assert-SiteCondition (-not $artLayout.Contains('lightbox-placeholder')) 'Lightbox number-panel markup is absent.'
Assert-SiteCondition (-not $lightboxScript.Contains('placeholder')) 'Lightbox script no longer manages the number panel.'
Assert-SiteCondition (-not $lightboxScript.Contains('const number')) 'Lightbox script no longer creates artwork numbers.'
Assert-SiteCondition (-not $customCss.Contains('.lightbox-placeholder')) 'Lightbox number-panel styles are absent.'
$lightboxStageRule = [regex]::Match($customCss, '(?s)\.lightbox-stage\s*\{([^}]*)\}')
Assert-SiteCondition ($lightboxStageRule.Success -and $lightboxStageRule.Groups[1].Value.Contains('box-sizing: border-box')) 'Lightbox stage includes padding inside its viewport height.'

$homeTitleRule = [regex]::Match($customCss, '(?s)\.home-intro h1\s*\{([^}]*)\}')
Assert-SiteCondition $homeTitleRule.Success 'Homepage title has a scoped reset rule.'
if ($homeTitleRule.Success) {
  $homeTitleDeclarations = $homeTitleRule.Groups[1].Value
  Assert-SiteCondition (-not [regex]::IsMatch($homeTitleDeclarations, 'font-size|font-weight|line-height|letter-spacing')) 'Homepage title inherits the standard page-H1 typography.'
}

Assert-SiteCondition ($customCss.Contains('margin-inline: auto')) 'Constrained non-Art columns use responsive horizontal centering.'
Assert-SiteCondition ($customCss.Contains('.page-intro:not(.art-intro)')) 'Page-intro centering explicitly exempts the Art page.'
Assert-SiteCondition ($customCss.Contains('grid-template-columns: repeat(4, minmax(0, 1fr))')) 'Desktop Art grid remains four columns.'
Assert-SiteCondition ($customCss.Contains('grid-template-columns: repeat(3, minmax(0, 1fr))')) 'Tablet Art grid remains three columns.'
Assert-SiteCondition ($customCss.Contains('grid-template-columns: repeat(2, minmax(0, 1fr))')) 'Mobile Art grid remains two columns.'

if ($regressionFailures.Count -gt 0) {
  throw "Site regression checks failed: $($regressionFailures.Count)"
}

Write-Host 'All site regression checks passed.'
