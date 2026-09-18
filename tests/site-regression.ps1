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
$baseLayout = Get-Content -Raw (Join-Path $projectRoot 'layouts\baseof.html')
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
Assert-SiteCondition ([regex]::Matches($socialBlock, 'class="social-icon"').Count -eq 4) 'All four homepage links use the same social icon wrapper.'
Assert-SiteCondition ($homeLayout.Contains('resources.Get "icons/email.svg"')) 'Homepage loads the provided Email SVG asset.'
Assert-SiteCondition ($homeLayout.Contains('resources.Get "icons/rss.svg"')) 'Homepage loads the provided RSS SVG asset.'
Assert-SiteCondition ($homeLayout.Contains('focusable="false" fill="currentColor" viewBox="0 0 24 24"')) 'GitHub declares its filled-logo behavior explicitly.'

foreach ($iconName in @('email', 'rss')) {
  $iconAssetPath = Join-Path $projectRoot "assets\icons\$iconName.svg"
  Assert-SiteCondition (Test-Path $iconAssetPath) "Provided $iconName.svg is installed in the Hugo asset pipeline."
  if (Test-Path $iconAssetPath) {
    $iconAsset = Get-Content -Raw $iconAssetPath
    Assert-SiteCondition ($iconAsset.Contains('viewBox="0 0 24 24"')) "$iconName.svg keeps the supplied viewBox."
    Assert-SiteCondition ($iconAsset.Contains('currentColor')) "$iconName.svg inherits the shared icon color."
    Assert-SiteCondition ($iconAsset.Contains('fill="none"')) "$iconName.svg remains stroke-only."
    Assert-SiteCondition (-not $iconAsset.Contains('800px')) "$iconName.svg has no obsolete fixed presentation dimensions."
    if ($iconName -eq 'email') {
      Assert-SiteCondition ($iconAsset.Contains('M4 7.00005L10.2 11.65')) 'email.svg keeps the supplied envelope geometry.'
    } else {
      Assert-SiteCondition ($iconAsset.Contains('M4 11C6.38695 11')) 'rss.svg keeps the supplied feed geometry.'
    }
  }
}

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

$pageWidthToken = [regex]::Match($customCss, '--page-max-width:\s*60rem')
Assert-SiteCondition $pageWidthToken.Success 'Standard pages share one 60rem maximum-width token.'
Assert-SiteCondition ($customCss.Contains('--topic-max-width: 62rem')) 'Topics retains its specialized 62rem width token.'
Assert-SiteCondition ($customCss.Contains('.page-shell')) 'Standard pages use the shared page-shell class.'
Assert-SiteCondition ($customCss.Contains('.topic-shell')) 'Topics pages use the specialized topic-shell class.'
Assert-SiteCondition ($customCss.Contains('.art-shell')) 'Art has an explicit protected shell class.'
Assert-SiteCondition ($baseLayout.Contains('page-shell')) 'The base layout assigns the standard page shell centrally.'
Assert-SiteCondition ($baseLayout.Contains('topic-shell')) 'The base layout assigns the Topics shell centrally.'
Assert-SiteCondition ($baseLayout.Contains('art-shell')) 'The base layout assigns the Art shell centrally.'

$socialSvgRule = [regex]::Match($customCss, '(?s)\.social-icon svg\s*\{([^}]*)\}')
Assert-SiteCondition ($socialSvgRule.Success -and -not $socialSvgRule.Groups[1].Value.Contains('fill:')) 'Shared icon sizing does not override stroke-only SVG fill behavior.'

$notFoundRule = [regex]::Match($customCss, '(?s)\.not-found\s*\{([^}]*)\}')
Assert-SiteCondition ($notFoundRule.Success -and $notFoundRule.Groups[1].Value.Contains('position: static')) 'Custom 404 content resets PaperMod absolute positioning.'
Assert-SiteCondition ($notFoundRule.Success -and $notFoundRule.Groups[1].Value.Contains('display: block')) 'Custom 404 content participates in the shared page flow.'

$shellExpectations = @(
  @{ Path = 'index.html'; Class = 'page-shell'; Label = 'Home' },
  @{ Path = 'articles\index.html'; Class = 'page-shell'; Label = 'Articles' },
  @{ Path = 'articles\the-quiet-birth-of-quanta\index.html'; Class = 'page-shell'; Label = 'Article detail' },
  @{ Path = 'books\index.html'; Class = 'page-shell'; Label = 'Books' },
  @{ Path = 'books\causality-and-chance\index.html'; Class = 'page-shell'; Label = 'Book detail' },
  @{ Path = 'archive\index.html'; Class = 'page-shell'; Label = 'Archive' },
  @{ Path = 'search\index.html'; Class = 'page-shell'; Label = 'Search' },
  @{ Path = '404.html'; Class = 'page-shell'; Label = '404' },
  @{ Path = 'topics\index.html'; Class = 'topic-shell'; Label = 'Topics' },
  @{ Path = 'topics\physics\index.html'; Class = 'topic-shell'; Label = 'Topic detail' },
  @{ Path = 'art\index.html'; Class = 'art-shell'; Label = 'Art' }
)
foreach ($expectation in $shellExpectations) {
  $pagePath = Join-Path $publicRoot $expectation.Path
  $pageHtml = if (Test-Path $pagePath) { Get-Content -Raw $pagePath } else { '' }
  Assert-SiteCondition ($pageHtml.Contains("class=`"main $($expectation.Class)`"")) "$($expectation.Label) uses the expected outer shell."
}

Assert-SiteCondition ($customCss.Contains('grid-template-columns: repeat(4, minmax(0, 1fr))')) 'Desktop Art grid remains four columns.'
Assert-SiteCondition ($customCss.Contains('grid-template-columns: repeat(3, minmax(0, 1fr))')) 'Tablet Art grid remains three columns.'
Assert-SiteCondition ($customCss.Contains('grid-template-columns: repeat(2, minmax(0, 1fr))')) 'Mobile Art grid remains two columns.'

if ($regressionFailures.Count -gt 0) {
  throw "Site regression checks failed: $($regressionFailures.Count)"
}

Write-Host 'All site regression checks passed.'
