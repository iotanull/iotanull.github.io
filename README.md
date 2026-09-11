# IO — Hugo personal website

This repository publishes [iotanull.github.io](https://iotanull.github.io/) with Hugo 0.165.0 Extended, PaperMod, and GitHub Actions. The public site is intentionally text-first. Demonstration articles, books, and artwork placeholders are clearly labeled and should be replaced with real material.

## Website structure

- `content/articles/` — article page bundles and the Articles filters
- `content/books/` — one page bundle per original work or translation
- `data/topics.yaml` — optional editorial descriptions and primary-subject settings
- `data/artworks.yaml` — the curated Art gallery manifest
- `static/books/pdfs/` — downloadable PDFs
- `static/books/covers/` — optional shared cover files; bundle-specific covers are preferred
- `static/images/art/` — gallery thumbnails and full-size artwork
- `layouts/` — custom editorial templates and shortcodes
- `assets/css/extended/custom.css` — design tokens and site styling
- `assets/js/` — minimal navigation, search, citation, and lightbox scripts
- `hugo.yaml` — identity, navigation, portfolio URL, taxonomy, and publishing settings

PaperMod is a Git submodule at `themes/PaperMod/`. Do not edit files inside it; all customizations live in this repository's own `layouts/` and `assets/` directories.

## Adding a specialized article

Create a page bundle such as `content/articles/my-research-note/index.md`:

```yaml
---
title: "My Research Note"
date: 2026-09-11
description: "A concise summary for listings and search."
articleType: "specialized"
topics: ["Mathematics", "Geometry"]
draft: false
math: true
toc: true
abstract: "Optional abstract text."
citation: "Optional plain-text citation."
bibtex: |
  @article{example,
    title={My Research Note}
  }
---
```

Place article-specific images beside `index.md` and reference them with the `figure` or `widefigure` shortcodes.

## Adding a general article

Create `content/articles/my-essay/index.md` and use:

```yaml
---
title: "My Essay"
date: 2026-09-11
description: "A concise summary."
dek: "An optional narrative subtitle."
articleType: "general"
topics: ["Physics", "Philosophy of Science"]
draft: false
math: false
toc: false
cover:
  image: "hero.jpg"
  alt: "Meaningful description of the hero image"
  caption: "Optional caption"
---
```

Put `hero.jpg` in the same page bundle. Omit the entire `cover` block when no hero is needed.

## Adding topics

Add topic names to an article's `topics` list. Hugo automatically creates the directory entry and page at `/topics/topic-name/`.

To add a short editorial description or mark a topic as a primary subject, edit `data/topics.yaml`:

```yaml
algebraic-geometry:
  title: "Algebraic Geometry"
  description: "A short optional description."
  primary: false
```

## Adding an original book

Create `content/books/book-slug/index.md` with `role: "original"`:

```yaml
---
title: "Book Title"
role: "original"
author: "Author Name"
date: 2026-01-01
publisher: "Publisher"
isbn: "Optional ISBN"
pages: 240
language: "English"
description: "Short description."
cover: "cover.jpg"
pdf: "/books/pdfs/book-file.pdf"
topics: ["Mathematics"]
draft: false
---
```

Put the cover beside `index.md`. Omit fields that are not available; blank labels are never rendered.

## Adding a translation

Use the same page-bundle pattern with `role: "translation"` and add the relevant source metadata:

```yaml
role: "translation"
originalTitle: "Original title"
author: "Original author"
translator: "IO"
originalLanguage: "Source language"
language: "English"
```

## Adding a book PDF

Copy the file into `static/books/pdfs/` and set the book's `pdf` field to `/books/pdfs/filename.pdf`. Check each file before committing:

```powershell
Get-ChildItem static/books/pdfs -File | Sort-Object Length -Descending | Select-Object Name,Length
```

Keep every individual Git-tracked file safely below GitHub's 100 MiB object limit. If a PDF is near or above that limit, publish only that file as a GitHub Release asset and use its release URL in `pdf`. Do not add Git LFS unless the repository strategy is deliberately changed.

## Adding or replacing art

Put thumbnails and full-size images in `static/images/art/`, then edit `data/artworks.yaml`:

```yaml
- id: "work-slug"
  title: "Work title"
  year: "2026"
  medium: "Ink on paper"
  thumb: "/images/art/work-thumb.jpg"
  image: "/images/art/work-full.jpg"
```

The gallery is designed for 16–20 entries. The included entries are neutral placeholders, not claimed artworks.

## Setting the external portfolio URL

Edit `params.portfolioURL` in `hugo.yaml`:

```yaml
params:
  portfolioURL: "https://your-portfolio.example/"
```

Leave it empty until a real portfolio URL is available.

## Running locally

Clone submodules, install Hugo 0.165.0 Extended, and run:

```powershell
git submodule update --init --recursive
hugo server --disableFastRender
```

The local workspace used to create this site also contains an ignored portable binary, so on this machine this exact command works:

```powershell
.\.tools\hugo\hugo.exe server --cacheDir .hugo_cache --disableFastRender
```

## Publishing

1. Edit content or data.
2. Commit the changes.
3. Push `main` to GitHub.
4. GitHub Actions builds and deploys the site automatically.

The production workflow is `.github/workflows/deploy.yml`. Do not commit `public/`; it is generated during deployment.
