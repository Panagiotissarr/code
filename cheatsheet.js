(function() {
  'use strict';

  const THEME_KEY = 'hub-theme';
  let stored;
  try { stored = localStorage.getItem(THEME_KEY); } catch(e) {}

  // ── Theme ──────────────────────────────────────────────────────────────
  const themeToggle = document.getElementById('themeToggle');
  const themeIcon   = themeToggle?.querySelector('.material-symbols-outlined');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

  function applyTheme(isLight) {
    document.body.classList.toggle('light', isLight);
    try { localStorage.setItem(THEME_KEY, isLight ? 'light' : 'dark'); } catch(e) {}
    document.getElementById('themeColor').content = isLight ? '#ffffff' : '#0d1117';
    if (themeIcon) themeIcon.textContent = isLight ? 'light_mode' : 'dark_mode';
  }

  // Init: prefer stored, else OS preference
  if (stored === 'light' || (!stored && !prefersDark)) {
    applyTheme(true);
  }

  themeToggle?.addEventListener('click', () => {
    applyTheme(!document.body.classList.contains('light'));
  });

  // ── Tab system ─────────────────────────────────────────────────────────
  const tabs = document.querySelectorAll('.tab');
  const panels = {
    git:  document.querySelector('.panel-git'),
    nvim: document.querySelector('.panel-nvim'),
    tmux: document.querySelector('.panel-tmux'),
  };

  function activateTab(name) {
    tabs.forEach(t => {
      const isActive = t.dataset.panel === name;
      t.classList.toggle('active', isActive);
      t.setAttribute('aria-selected', isActive);
    });
    Object.entries(panels).forEach(([key, el]) => {
      if (el) el.classList.toggle('active', key === name);
    });
  }

  tabs.forEach(tab => {
    tab.addEventListener('click', () => activateTab(tab.dataset.panel));
  });

  // ── Search & tag filter (shared logic) ─────────────────────────────────
  function setupSearch({
    searchId, clearId, tagsId, cardsId,
    getSearchText,
    showAllTagLabel,
  }) {
    const searchInput = document.getElementById(searchId);
    const clearBtn    = document.getElementById(clearId);
    const tagsEl      = document.getElementById(tagsId);
    const cardsEl     = document.getElementById(cardsId);
    if (!searchInput || !cardsEl) return;

    const cards = Array.from(cardsEl.querySelectorAll('.card'));
    const tagSet = new Set();
    cards.forEach(card => {
      const tags = (card.dataset.tags || '').split(/[\s,]+/).filter(Boolean);
      tags.forEach(t => tagSet.add(t));
    });
    const allTags = Array.from(tagSet).sort();

    let activeTag = '';

    // Build tag pills
    function renderTags() {
      tagsEl.innerHTML = '';
      const allPill = document.createElement('button');
      allPill.className = 'tag-pill' + (activeTag === '' ? ' active' : '');
      allPill.textContent = showAllTagLabel || 'All';
      allPill.dataset.tag = '';
      allPill.addEventListener('click', () => { activeTag = ''; renderTags(); filter(); });
      tagsEl.appendChild(allPill);

      allTags.forEach(tag => {
        const count = cards.filter(c => (c.dataset.tags || '').split(/[\s,]+/).includes(tag)).length;
        const pill = document.createElement('button');
        pill.className = 'tag-pill';
        if (activeTag === tag) pill.classList.add('active');
        if (count === 0) pill.classList.add('tag-pill-zero');
        pill.textContent = tag + ' (' + count + ')';
        pill.dataset.tag = tag;
        pill.addEventListener('click', () => {
          if (activeTag === tag) { activeTag = ''; }
          else { activeTag = tag; }
          renderTags();
          filter();
        });
        tagsEl.appendChild(pill);
      });
    }

    function filter() {
      const q = getSearchText ? getSearchText(searchInput.value) : searchInput.value.toLowerCase().trim();
      let hasVisible = false;

      cards.forEach(card => {
        const cardTags = (card.dataset.tags || '').split(/[\s,]+/).filter(Boolean);
        const tagMatch = !activeTag || cardTags.includes(activeTag);
        const textMatch = !q || card.textContent.toLowerCase().includes(q);
        const visible = tagMatch && textMatch;
        card.classList.toggle('hidden', !visible);
        if (visible) hasVisible = true;
      });

      clearBtn?.classList.toggle('visible', q.length > 0);

      // Highlight matching text
      cardsEl.querySelectorAll('mark').forEach(m => {
        const parent = m.parentNode;
        parent.replaceChild(document.createTextNode(m.textContent), m);
        parent.normalize();
      });
      if (q) {
        const re = new RegExp('(' + q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
        cards.forEach(card => {
          if (card.classList.contains('hidden')) return;
          const cardHeader = card.querySelector('.card-header');
          if (!cardHeader) return;
          const walker = document.createTreeWalker(card, NodeFilter.SHOW_TEXT, null, false);
          const nodesToReplace = [];
          while (walker.nextNode()) {
            const node = walker.currentNode;
            if (node.parentElement?.closest('.related-commands')) continue;
            if (node.parentElement?.closest('.card-header')) continue;
            if (node.textContent.trim() && re.test(node.textContent)) {
              nodesToReplace.push(node);
            }
            re.lastIndex = 0;
          }
          nodesToReplace.forEach(node => {
            const frag = document.createDocumentFragment();
            let remaining = node.textContent;
            re.lastIndex = 0;
            let lastIdx = 0;
            let match;
            while ((match = re.exec(remaining)) !== null) {
              if (match.index > lastIdx) frag.appendChild(document.createTextNode(remaining.slice(lastIdx, match.index)));
              const m = document.createElement('mark');
              m.textContent = match[0];
              frag.appendChild(m);
              lastIdx = re.lastIndex;
            }
            if (lastIdx < remaining.length) frag.appendChild(document.createTextNode(remaining.slice(lastIdx)));
            node.parentNode.replaceChild(frag, node);
          });
        });
      }
    }

    searchInput.addEventListener('input', filter);
    clearBtn?.addEventListener('click', () => {
      searchInput.value = '';
      filter();
      searchInput.focus();
    });

    renderTags();
    filter();
  }

  // ── Init Git search ────────────────────────────────────────────────────
  setupSearch({
    searchId: 'gitSearch',
    clearId:  'gitClear',
    tagsId:   'gitTags',
    cardsId:  'gitCards',
    showAllTagLabel: 'All Git',
  });

  // ── Init Nvim search ───────────────────────────────────────────────────
  setupSearch({
    searchId: 'nvimSearch',
    clearId:  'nvimClear',
    tagsId:   'nvimTags',
    cardsId:  'nvimCards',
    showAllTagLabel: 'All Nvim',
    getSearchText: (val) => val.replace(/[<>&lt;&gt;]/g, '').toLowerCase().trim(),
  });

  // ── Init Tmux search ───────────────────────────────────────────────────
  setupSearch({
    searchId: 'tmuxSearch',
    clearId:  'tmuxClear',
    tagsId:   'tmuxTags',
    cardsId:  'tmuxCards',
    showAllTagLabel: 'All Tmux',
  });

  // ── Easter eggs ────────────────────────────────────────────────────────
  function setupEasterEgg(btnId, btn2Id, emoji) {
    const btn  = document.getElementById(btnId);
    const btn2 = document.getElementById(btn2Id);
    if (!btn) return;

    function explode(b) {
      if (b.classList.contains('exploding')) return;
      b.classList.remove('reappearing');
      b.classList.add('exploding');
      b.textContent = '';
      setTimeout(() => {
        b.classList.remove('exploding');
        b.classList.add('reappearing');
        b.textContent = emoji;
        setTimeout(() => b.classList.remove('reappearing'), 450);
      }, 550);
    }

    btn.addEventListener('click', () => explode(btn));
    if (btn2) btn2.addEventListener('click', () => explode(btn2));
  }

  // Easter egg: branch (Git), penguin (Nvim), terminal (Tmux)
  // We skip Nvim penguin since its button uses SVG, not emoji
  setupEasterEgg('branchBtn',  'branchBtn2', '🌿');
  // Nvim penguin uses SVG so we handle it differently
  const penguinBtns = ['penguinBtn', 'penguinBtn2'].map(id => document.getElementById(id)).filter(Boolean);
  penguinBtns.forEach(btn => {
    if (!btn) return;
    btn.addEventListener('click', () => {
      if (btn.classList.contains('exploding')) return;
      btn.classList.remove('reappearing');
      btn.classList.add('exploding');
      btn.innerHTML = '';
      setTimeout(() => {
        btn.classList.remove('exploding');
        btn.classList.add('reappearing');
        btn.innerHTML = '<svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z"/></svg>';
        setTimeout(() => btn.classList.remove('reappearing'), 450);
      }, 550);
    });
  });
  setupEasterEgg('termBtn', 'termBtn2', '💻');

  // ── Related-commands toggles ────────────────────────────────────────────
  document.querySelectorAll('.related-toggle').forEach(btn => {
    btn.addEventListener('click', () => {
      const target = document.getElementById(btn.dataset?.target);
      if (target) {
        target.classList.toggle('open');
        btn.querySelector('.material-symbols-outlined').textContent =
          target.classList.contains('open') ? 'expand_less' : 'expand_more';
      }
    });
  });

})();
