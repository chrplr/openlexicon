/* UniPseudo front-end (vanilla JS + jQuery/DataTables for the tables). */
(function () {
  'use strict';

  const cfg = JSON.parse(document.getElementById('unipseudo-config').textContent);
  const $ = window.jQuery;
  const byId = (id) => document.getElementById(id);
  const csrf = document.querySelector('input[name=csrfmiddlewaretoken]').value;

  const els = {
    length: byId('up-length'), algorithm: byId('up-algorithm'), language: byId('up-language'),
    gramGroup: byId('up-gram-group'), gram: byId('up-gram'), useDb: byId('up-use-db'),
    dbHelp: byId('up-db-help'), words: byId('up-words'), n: byId('up-n'), go: byId('up-go'),
    info: byId('up-info'), error: byId('up-error'), warning: byId('up-warning'),
    importBox: byId('up-import-box'), toggleImport: byId('up-toggle-import'),
    filterBox: byId('up-filter-box'), toggleFilters: byId('up-toggle-filters'),
    spinner: byId('up-spinner'),
  };
  const filterSelects = Array.from(document.querySelectorAll('[data-filter]'));

  const state = { langDetail: null, tables: { simple: null, detail: null }, subLen: 2 };

  // ------------------------------------------------------------------ helpers
  const esc = (s) => String(s).replace(/[&<>"']/g, (c) => (
    { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const span = (cls, s) => (s ? `<span class="${cls}">${esc(s)}</span>` : '');

  async function request(url, options) {
    const res = await fetch(url, options);
    let data = null;
    try { data = await res.json(); } catch (e) { /* not JSON */ }
    if (!res.ok) throw new Error((data && data.error) || `Request failed (${res.status})`);
    return data;
  }
  const postJSON = (url, payload) => request(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-CSRFToken': csrf },
    body: JSON.stringify(payload),
  });

  // Disable the interface while something is running (like shinybusy in the R app)
  let busyCount = 0;
  async function busy(fn) {
    busyCount += 1;
    els.spinner.hidden = false;
    document.querySelectorAll('button, input, select, textarea').forEach((e) => { e.dataset.wasDisabled = e.disabled ? '1' : ''; e.disabled = true; });
    try { return await fn(); } finally {
      busyCount -= 1;
      if (busyCount === 0) {
        els.spinner.hidden = true;
        document.querySelectorAll('button, input, select, textarea').forEach((e) => { e.disabled = e.dataset.wasDisabled === '1'; });
      }
    }
  }

  function showError(msg) { els.error.textContent = msg || ''; els.error.hidden = !msg; }
  function showWarning(msg) { els.warning.textContent = msg || ''; els.warning.hidden = !msg; }

  // ------------------------------------------------------------ help popovers
  function initHelp(button) {
    new bootstrap.Popover(button, {
      html: true, trigger: 'click', placement: 'right', container: 'body',
      content: () => button.dataset.help || '',
    });
  }
  document.querySelectorAll('.up-help').forEach(initHelp);
  document.addEventListener('click', (e) => {
    if (e.target.closest('.up-help') || e.target.closest('.popover')) return;
    document.querySelectorAll('.up-help').forEach((b) => { const p = bootstrap.Popover.getInstance(b); if (p) p.hide(); });
  });

  // ---------------------------------------------------------------- toggles
  function toggle(button, box, showLabel, hideLabel) {
    button.addEventListener('click', () => {
      box.hidden = !box.hidden;
      button.innerHTML = `<b>${box.hidden ? showLabel : hideLabel}</b>`;
    });
  }
  toggle(els.toggleImport, els.importBox, 'Show Word Import Tool', 'Hide Word Import Tool');
  toggle(els.toggleFilters, els.filterBox, 'Show Constraints', 'Hide Constraints');

  // ------------------------------------------------------- length -> algorithm
  function updateAlgorithms() {
    const info = cfg.algorithms[els.length.value];
    els.algorithm.innerHTML = info.allowed.map((a) => `<option value="${a}">${a}</option>`).join('');
    els.algorithm.value = info.default;
  }
  els.length.addEventListener('change', updateAlgorithms);
  updateAlgorithms();

  // ------------------------------------------------------ language selection
  // One language = one database (chosen server-side, see services.get_database_for_language).
  async function onLanguageChange() {
    const language = els.language.value;
    state.langDetail = null;
    els.words.value = '';
    els.gram.innerHTML = '';
    els.gramGroup.hidden = true;
    els.useDb.disabled = true;
    els.dbHelp.hidden = true;
    filterSelects.forEach((s) => { s.value = ''; });
    showError('');
    if (!language) return;

    let canUseDb = false;
    await busy(async () => {
      try {
        const d = await request(`${cfg.urls.language}?${new URLSearchParams({ language })}`);
        state.langDetail = d;
        filterSelects.forEach((s) => { s.value = d.presets[s.dataset.filter] != null ? String(d.presets[s.dataset.filter]) : ''; });
        if (!d.database) {
          showError(`No word database is available for ${language}: paste your own words in "Words to use".`);
          return;
        }
        let tip = `<span>Words will be selected from the <b>${esc(d.database.name)}</b> database.`;
        if (d.database.info) tip += `<div>${d.database.info}</div>`;
        if (d.database.website) tip += `<p><a href="${esc(d.database.website)}" target="_blank" rel="noopener">Website</a></p>`;
        els.dbHelp.dataset.help = tip + '</span>';
        els.dbHelp.hidden = false;
        canUseDb = true;
        if (d.gram_classes.length) {
          els.gram.innerHTML = ['<option value="">(all)</option>']
            .concat(d.gram_classes.map((g) => `<option value="${esc(g)}">${esc(g)}</option>`)).join('');
          els.gramGroup.hidden = false;
        }
        await loadWords();
      } catch (e) { showError(e.message); }
    });
    els.useDb.disabled = !canUseDb; // after busy(), which restores the previous disabled state
  }
  els.language.addEventListener('change', onLanguageChange);
  if (els.language.value) onLanguageChange(); // language preselected by the server (English)

  async function loadWords() {
    const language = els.language.value;
    if (!language || !state.langDetail || !state.langDetail.database) return;
    const q = new URLSearchParams({ language, length: els.length.value, gram_class: els.gram.value });
    const data = await request(`${cfg.urls.words}?${q}`);
    els.words.value = data.words.join('\n');
  }
  els.useDb.addEventListener('click', () => busy(async () => {
    showError('');
    try { await loadWords(); } catch (e) { showError(e.message); }
  }));

  // ------------------------------------------------------------ rendering
  // Word k (1-based) of a pseudoword: grey word, red = letters actually used.
  function renderSource(word, k, L) {
    let html;
    if (k === 1) {
      html = span('up-red', word.slice(0, L)) + esc(word.slice(L));
    } else {
      html = esc(word.slice(0, k - 1)) + span('up-orange', word.slice(k - 1, k + L - 2))
        + span('up-red', word.slice(k + L - 2, k + L - 1)) + esc(word.slice(k + L - 1));
    }
    return `<span class="up-grey">${html}</span>`;
  }

  function buildTable(key, selector, columns, data, extra) {
    if (state.tables[key]) { state.tables[key].destroy(); $(selector).empty(); }
    state.tables[key] = $(selector).DataTable(Object.assign({
      data, columns, orderCellsTop: true, order: [], // keep the (random) generation order; headers still sort on click
      pageLength: 20, lengthMenu: [20, 100, 500, 1000],
      dom: 'lrtip', stateSave: false,
      initComplete: function () {
        const api = this.api();
        const $tr = $('<tr class="filters"></tr>').appendTo($(api.table().header()));
        api.columns().every(function () {
          const col = this;
          const $in = $('<input type="text" class="form-control form-control-sm" placeholder="Filter (regex)">');
          $('<th></th>').append($in).appendTo($tr);
          $in.on('input keyup change', () => {
            const v = $in.val();
            try { new RegExp(v); } catch (e) { return; }  // ignore incomplete regex
            col.search(v, true, false, false).draw();
          });
        });
      },
    }, extra || {}));
  }

  function renderResults(res) {
    const L = res.subLen;
    state.subLen = L;
    const rows = res.rows;
    const withHtml = (render) => ({ render: (d, type) => (type === 'display' ? render(d) : d) });

    const redWord = (d) => span('up-red', d);
    buildTable('simple', '#up-table-simple',
      [Object.assign({ title: 'Pseudoword', className: 'dt-center' }, withHtml(redWord))],
      rows.map((r) => [r.p]));

    const width = rows.length ? rows[0].s.length : 0;
    const columns = [Object.assign({ title: 'Pseudoword', className: 'dt-center' }, withHtml(redWord))];
    for (let k = 1; k <= width; k += 1) {
      columns.push(Object.assign({ title: `Word.${k}`, className: 'dt-center' }, withHtml((d) => renderSource(d, k, L))));
    }
    buildTable('detail', '#up-table-detail', columns, rows.map((r) => [r.p].concat(r.s)), { scrollX: false });

    byId('up-dl-simple').hidden = !rows.length;
    byId('up-dl-detail').hidden = !rows.length;
  }

  // ----------------------------------------------------------------- Go!
  els.go.addEventListener('click', () => busy(async () => {
    showError(''); showWarning('');
    els.info.textContent = 'Generating...';
    const filters = {};
    filterSelects.forEach((s) => { filters[s.dataset.filter] = s.value; });
    try {
      const res = await postJSON(cfg.urls.generate, {
        n: els.n.value, length: els.length.value, algorithm: els.algorithm.value,
        language: els.language.value, words: els.words.value, filters,
      });
      els.info.textContent = res.info;
      showWarning(res.warning);
      renderResults(res);
    } catch (e) {
      els.info.textContent = '';
      showError(e.message);
    }
  }));

  // Tables built inside a hidden tab need their column widths recomputed
  document.addEventListener('shown.bs.tab', () => {
    Object.values(state.tables).forEach((t) => { if (t) t.columns.adjust(); });
  });

  // -------------------------------------------------------------- downloads
  document.querySelectorAll('[data-dl]').forEach((btn) => btn.addEventListener('click', () => busy(async () => {
    const detail = btn.dataset.detail === '1';
    const table = state.tables[detail ? 'detail' : 'simple'];
    if (!table) return;
    const rows = table.rows({ search: 'applied' }).data().toArray();
    if (!rows.length) return;
    try {
      const res = await fetch(cfg.urls.download, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRFToken': csrf },
        body: JSON.stringify({
          format: btn.dataset.dl, detail, rows,
          tz: Intl.DateTimeFormat().resolvedOptions().timeZone,
        }),
      });
      if (!res.ok) throw new Error('Download failed.');
      const blob = await res.blob();
      const name = /filename="([^"]+)"/.exec(res.headers.get('Content-Disposition') || '');
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = name ? name[1] : 'pseudowords.' + btn.dataset.dl;
      document.body.appendChild(a); a.click(); a.remove();
      setTimeout(() => URL.revokeObjectURL(a.href), 5000);
    } catch (e) { showError(e.message); }
  })));
})();
