# Page Width and Social Icons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Normalize the supplied homepage social icons and align every standard page through one 960px outer shell while preserving the specialized Topics and Art widths.

**Architecture:** Standard layouts receive a shared `.page-shell` wrapper governed by one `--page-max-width: 60rem` token. Topics uses a separate `.topic-shell` at its existing 62rem measure, while Art remains directly on the existing 74rem `.main` canvas. Readable prose and compact controls remain optional inner measures rather than competing outer page containers.

**Tech Stack:** Hugo templates, Hugo asset pipeline, CSS, PowerShell regression checks, browser automation, GitHub Pages.

**Spec:** `C:/Users/Nemesis/.codex/attachments/f2c9427f-d061-436a-a7f4-28aaf1d50235/pasted-text.txt`

## Global Constraints

- Preserve all content, routes, typography, cards, Books, Archive, Search, Art gallery/lightbox, Topics, themes, and deployment.
- Do not edit the PaperMod theme.
- Standard page max width is exactly `60rem` (960px) through one token.
- Topics retains a specialized `62rem` shell; Art retains the existing `74rem` canvas and 4/3/2-column responsive grid.
- Homepage icon order remains GitHub, Email, ArtStation, RSS.
- Use the supplied `email.svg`, `rss.svg`, and existing supplied `artstation.svg`, all inheriting `currentColor`.
- Verify at 390px, 768px, 1024px, and 1440px with no horizontal overflow.

---

### Task 1: Encode the layout and asset contract

**Files:**
- Modify: `tests/site-regression.ps1`

**Interfaces:**
- Consumes: current Hugo layouts, CSS, and generated `public` pages.
- Produces: regression assertions for installed assets, shared icon markup, shared shell use, exception shells, and preserved Art rules.

- [x] **Step 1: Write failing assertions**

Add assertions requiring `assets/icons/email.svg`, `assets/icons/rss.svg`, four `.social-icon` wrappers, `--page-max-width: 60rem`, `.page-shell`, `.topic-shell`, and the expected shell in representative generated pages. Assert Art has no standard/topic shell.

- [x] **Step 2: Run the regression script**

Run: `pwsh -File tests/site-regression.ps1`

Expected: FAIL because the new assets and shell contract do not exist yet.

### Task 2: Install and normalize social icons

**Files:**
- Create: `assets/icons/email.svg`
- Create: `assets/icons/rss.svg`
- Modify: `layouts/home.html`
- Modify: `assets/css/extended/custom.css`

**Interfaces:**
- Consumes: supplied SVG paths and Hugo `resources.Get`.
- Produces: four equal `.social-icon` boxes containing 20px SVGs with inherited theme color.

- [x] **Step 1: Copy supplied SVG geometry into project assets**

Retain each `viewBox="0 0 24 24"`, remove fixed 800px dimensions and generator comments, and replace black strokes with `currentColor` without altering paths.

- [x] **Step 2: Replace generated Email and RSS markup**

Load `icons/email.svg` and `icons/rss.svg` with `resources.Get`, keeping accessible labels and link destinations unchanged.

- [x] **Step 3: Normalize all icon boxes**

Make each anchor a 32px target and each `.social-icon`/nested SVG exactly 20px, centered with one shared color, hover, and focus behavior.

### Task 3: Implement shared and exception shells

**Files:**
- Modify: `layouts/home.html`
- Modify: `layouts/articles/list.html`
- Modify: `layouts/articles/single.html`
- Modify: `layouts/books/list.html`
- Modify: `layouts/books/single.html`
- Modify: `layouts/archives.html`
- Modify: `layouts/search.html`
- Modify: `layouts/404.html`
- Modify: `layouts/taxonomy.html`
- Modify: `layouts/term.html`
- Modify: `assets/css/extended/custom.css`

**Interfaces:**
- Consumes: `.main` as the 74rem site canvas.
- Produces: `.page-shell` at 60rem for standard pages and `.topic-shell` at 62rem for Topics family.

- [x] **Step 1: Wrap standard layouts**

Place each standard page header and primary content under one `.page-shell`; place entire article/book detail page in that shell.

- [x] **Step 2: Wrap Topics layouts**

Place the taxonomy header/directory and topic-detail header/list under `.topic-shell`.

- [x] **Step 3: Preserve Art markup**

Leave `layouts/art/list.html` unchanged and ensure no general selector constrains it.

- [x] **Step 4: Replace competing outer max-width rules**

Add `--page-max-width: 60rem`, style `.page-shell`/`.topic-shell`, and remove centered outer widths from home intro/recent writing, list/card containers, Books, Archive, Search, and 404. Keep `--read-width` only for prose, abstracts, article headers/body/footer, and other intentional inner measures.

- [x] **Step 5: Run build and regression checks**

Run: `G:/IOBlog/.tools/hugo/hugo.exe --gc --minify --printPathWarnings --cacheDir G:/IOBlog/.hugo_cache`

Run: `pwsh -File tests/site-regression.ps1`

Expected: build succeeds and all checks pass.

### Task 4: Browser verification and deployment

**Files:**
- Verify only; fix the files above if evidence reveals a regression.

**Interfaces:**
- Consumes: local production build and deployed GitHub Pages site.
- Produces: measured alignment/width evidence, clean Git diff, pushed commit, successful deployment.

- [x] **Step 1: Verify representative pages locally**

At 390px, 768px, 1024px, and 1440px, measure shell width, left edges, icon dimensions/colors, Art grid columns, and `scrollWidth <= innerWidth` for Home, Articles, article detail, Books, book detail, Archive, Topics, topic detail, Search, 404, and Art.

- [x] **Step 2: Inspect the final diff**

Run `git diff --check`, `git diff --stat`, and review `git diff` to confirm only intentional changes.

- [x] **Step 3: Re-run fresh verification**

Run the Hugo build and regression script again immediately before committing.

- [ ] **Step 4: Commit and push**

Commit with `Normalize page widths and social icons`, then push `main` to `origin`.

- [ ] **Step 5: Monitor and verify production**

Wait for the GitHub Pages workflow to succeed, then repeat key production checks at `https://iotanull.github.io/`.
