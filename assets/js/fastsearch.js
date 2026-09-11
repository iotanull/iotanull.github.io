import * as params from '@params';

const input = document.getElementById('searchInput');
const resultsList = document.getElementById('searchResults');
const status = document.getElementById('search-status');
let fuse;

const options = {
  isCaseSensitive: params.fuseOpts?.iscasesensitive ?? false,
  shouldSort: params.fuseOpts?.shouldsort ?? true,
  threshold: params.fuseOpts?.threshold ?? 0.3,
  distance: params.fuseOpts?.distance ?? 1000,
  minMatchCharLength: params.fuseOpts?.minmatchcharlength ?? 2,
  ignoreLocation: true,
  keys: params.fuseOpts?.keys ?? ['title', 'summary', 'content', 'topics', 'kind']
};

const clear = (message = 'Search articles, books, and topics.') => {
  resultsList.innerHTML = '';
  status.textContent = message;
};

const render = (query, matches) => {
  resultsList.innerHTML = '';
  if (!matches.length) {
    status.textContent = `No results for ‘${query}’.`;
    return;
  }
  status.textContent = `${matches.length} result${matches.length === 1 ? '' : 's'} for ‘${query}’. Use the arrow keys to move through results.`;
  const fragment = document.createDocumentFragment();
  matches.forEach(({ item }) => {
    const li = document.createElement('li');
    const link = document.createElement('a');
    const heading = document.createElement('strong');
    const summary = document.createElement('span');
    const meta = document.createElement('small');
    link.href = item.permalink;
    heading.textContent = item.title;
    summary.textContent = item.summary || '';
    meta.textContent = item.kind ? item.kind.replace(/^./, (letter) => letter.toUpperCase()) : '';
    link.append(heading, summary, meta);
    li.appendChild(link);
    fragment.appendChild(li);
  });
  resultsList.appendChild(fragment);
};

const search = () => {
  const query = input.value.trim();
  if (!query) return clear();
  const limit = params.fuseOpts?.limit ?? 12;
  render(query, fuse ? fuse.search(query, { limit }) : []);
};

window.addEventListener('load', async () => {
  if (!input || !resultsList) return;
  try {
    const response = await fetch('../index.json');
    if (!response.ok) throw new Error(`Search index returned ${response.status}`);
    fuse = new Fuse(await response.json(), options);
    input.disabled = false;
  } catch (error) {
    console.error(error);
    status.textContent = 'Search is temporarily unavailable.';
  }
});

let timer;
input?.addEventListener('input', () => {
  window.clearTimeout(timer);
  timer = window.setTimeout(search, 100);
});

input?.addEventListener('keydown', (event) => {
  if (event.key !== 'ArrowDown') return;
  const first = resultsList.querySelector('a');
  if (first) { event.preventDefault(); first.focus(); }
});

resultsList?.addEventListener('keydown', (event) => {
  if (!['ArrowDown', 'ArrowUp'].includes(event.key)) return;
  const links = [...resultsList.querySelectorAll('a')];
  const index = links.indexOf(document.activeElement);
  if (index < 0) return;
  event.preventDefault();
  if (event.key === 'ArrowDown') (links[index + 1] || input).focus();
  else (links[index - 1] || input).focus();
});
