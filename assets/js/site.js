const root = document.documentElement;
const themeButton = document.getElementById('theme-toggle');
const menuButton = document.querySelector('.menu-toggle');
const navActions = document.getElementById('site-menu');
const topLink = document.getElementById('top-link');

const updateThemeLabel = () => {
  if (!themeButton) return;
  const next = root.dataset.theme === 'dark' ? 'light' : 'dark';
  themeButton.setAttribute('aria-label', `Switch to ${next} theme`);
  themeButton.title = `Switch to ${next} theme`;
};

themeButton?.addEventListener('click', () => {
  root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
  localStorage.setItem('pref-theme', root.dataset.theme);
  updateThemeLabel();
});
updateThemeLabel();

menuButton?.addEventListener('click', () => {
  const open = menuButton.getAttribute('aria-expanded') === 'true';
  menuButton.setAttribute('aria-expanded', String(!open));
  navActions?.classList.toggle('is-open', !open);
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape' && navActions?.classList.contains('is-open')) {
    navActions.classList.remove('is-open');
    menuButton?.setAttribute('aria-expanded', 'false');
    menuButton?.focus();
  }
});

document.querySelectorAll('[data-copy-citation]').forEach((button) => {
  button.addEventListener('click', async () => {
    const block = button.closest('.citation-block');
    const text = block?.querySelector('.citation-text')?.textContent?.trim() || block?.querySelector('code')?.textContent?.trim();
    if (!text) return;
    try {
      await navigator.clipboard.writeText(text);
      button.textContent = 'Copied';
      window.setTimeout(() => { button.textContent = 'Copy citation'; }, 1800);
    } catch {
      button.textContent = 'Select citation to copy';
    }
  });
});

const toggleTopLink = () => topLink?.classList.toggle('is-visible', window.scrollY > window.innerHeight);
window.addEventListener('scroll', toggleTopLink, { passive: true });
toggleTopLink();
