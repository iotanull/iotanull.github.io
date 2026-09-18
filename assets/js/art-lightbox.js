const dialog = document.getElementById('art-lightbox');
const thumbs = [...document.querySelectorAll('.art-thumb')];
const image = dialog?.querySelector('.lightbox-image');
const title = dialog?.querySelector('#lightbox-title');
const details = dialog?.querySelector('.lightbox-caption p');
const closeButton = dialog?.querySelector('.lightbox-close');
const prevButton = dialog?.querySelector('.lightbox-prev');
const nextButton = dialog?.querySelector('.lightbox-next');
let current = 0;
let trigger = null;
let touchStart = null;

const render = (index) => {
  current = (index + thumbs.length) % thumbs.length;
  const thumb = thumbs[current];
  const src = thumb.dataset.image;
  title.textContent = thumb.dataset.title || '';
  details.textContent = [thumb.dataset.year, thumb.dataset.medium].filter(Boolean).join(' · ');
  if (src && !src.endsWith('/')) {
    image.src = src;
    image.alt = thumb.dataset.title || 'Artwork';
    image.hidden = false;
  } else {
    image.removeAttribute('src');
    image.alt = '';
    image.hidden = true;
  }
};

const open = (index, source) => {
  trigger = source;
  render(index);
  dialog.showModal();
  closeButton.focus();
};

const close = () => dialog.close();
thumbs.forEach((thumb, index) => thumb.addEventListener('click', () => open(index, thumb)));
closeButton?.addEventListener('click', close);
prevButton?.addEventListener('click', () => render(current - 1));
nextButton?.addEventListener('click', () => render(current + 1));

dialog?.addEventListener('click', (event) => {
  if (event.target === dialog) close();
});
dialog?.addEventListener('close', () => trigger?.focus());
dialog?.addEventListener('keydown', (event) => {
  if (event.key === 'ArrowLeft') { event.preventDefault(); render(current - 1); }
  if (event.key === 'ArrowRight') { event.preventDefault(); render(current + 1); }
});
dialog?.addEventListener('touchstart', (event) => { touchStart = event.changedTouches[0].clientX; }, { passive: true });
dialog?.addEventListener('touchend', (event) => {
  if (touchStart === null) return;
  const delta = event.changedTouches[0].clientX - touchStart;
  if (Math.abs(delta) > 55) render(current + (delta < 0 ? 1 : -1));
  touchStart = null;
}, { passive: true });
