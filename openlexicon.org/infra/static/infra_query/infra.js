/* Lexique Infra - interface (équivalent du côté client de l'app Shiny) */
(function () {
  'use strict';

  const $app = $('#app');
  const queryUrl = $app.data('query-url');
  const csrf = document.querySelector('[name=csrfmiddlewaretoken]').value;

  let dt = null;          // instance DataTables courante
  let columns = [];       // colonnes de la dernière réponse
  const selected = new Set();   // codes de colonnes affichées (persiste d'une requête à l'autre)
  const known = new Set();      // codes déjà vus

  /* ------------------------------------------------------------ Quick how-to */
  $('#btn-helper').on('click', function () {
    const box = $('#helper_box');
    const hide = box.is(':visible');
    box.slideToggle(150);
    $(this).text(hide ? 'Show Quick How-To' : 'Hide Quick How-To');
  });

  /* ------------------------------------------------------------ Go! activé seulement si du texte */
  const $items = $('#items'), $go = $('#go');
  $items.on('input', () => $go.prop('disabled', $items.val().trim() === ''));

  new bootstrap.Popover(document.getElementById('opt-neighbors-help'), { container: 'body', sanitize: false });

  /* Tooltips des en-têtes de colonnes (délégués : les th sont recréés par DataTables) */
  new bootstrap.Tooltip(document.getElementById('result'), {
    selector: 'th[data-bs-title]',
    placement: 'top', container: 'body', trigger: 'hover'
  });

  /* ------------------------------------------------------------ occupé / libre */
  function setBusy(on) {
    $('#busy').toggleClass('d-none', !on);
    $('button, input, textarea').prop('disabled', on);
    if (!on) $go.prop('disabled', $items.val().trim() === '');
  }

  function showMessage(html, kind) {
    $('#message').removeClass('d-none alert-danger alert-secondary alert-warning')
      .addClass('alert alert-' + kind).html(html);
  }
  function hideMessage() { $('#message').addClass('d-none').empty(); }
  const esc = s => $('<div>').text(s).html();

  /* ------------------------------------------------------------ requête */
  $go.on('click', async function () {
    hideMessage();
    const options = $('#opt-neighbors').is(':checked') ? ['neighbors'] : [];
    setBusy(true);
    try {
      const resp = await fetch(queryUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRFToken': csrf },
        body: JSON.stringify({ items: $items.val(), options: options })
      });
      const data = await resp.json();
      if (!resp.ok) throw new Error(data.error || ('HTTP ' + resp.status));
      render(data, options);
    } catch (err) {
      showMessage(esc(err.message), 'danger');
    } finally {
      setBusy(false);
    }
  });

  /* ------------------------------------------------------------ rendu du tableau */
  function render(data, options) {
    columns = data.columns;

    // Comme dans l'app Shiny : les colonnes nouvelles sont cochées ; les colonnes de voisins
    // sont (ré)ajoutées à chaque fois que l'option est cochée.
    columns.forEach(c => {
      if (c.code === '_item') return;
      if (!known.has(c.code)) { known.add(c.code); selected.add(c.code); }
    });
    if (options.includes('neighbors')) { selected.add('_nb_neighbors'); selected.add('_neighbors'); }
    else { selected.delete('_nb_neighbors'); selected.delete('_neighbors'); known.delete('_nb_neighbors'); known.delete('_neighbors'); }

    let info = '<b>' + data.n_words + '</b> word(s), <b>' + data.n_pseudowords + '</b> pseudoword(s).';
    if (data.ignored.length) {
      info += ' Ignored (punctuation): ' + data.ignored.map(esc).join(', ') + '.';
    }
    showMessage(info, data.ignored.length ? 'warning' : 'secondary');

    if (dt) { dt.destroy(); dt = null; }
    $('.table-responsive-wrapper').empty()
      .append('<table id="infra" class="table table-striped table-sm table-hover nowrap w-100"></table>');
    $('#result').removeClass('d-none');

    dt = $('#infra').DataTable({
      data: data.rows,
      columns: columns.map((c, i) => ({
        title: c.name,
        visible: i === 0 || selected.has(c.code),
        defaultContent: ''
      })),
      pageLength: 20,
      lengthMenu: [20, 100, 500, 1000],
      scrollX: true,
      dom: "<'row'<'col-12'l>><'row'<'col-12'tr>><'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
      initComplete: function () { decorateHeaders(this.api()); }
    });

    buildColumnChooser();
  }

  /* Infobulles + champs de filtre par colonne (regex autorisées) dans les en-têtes */
  function decorateHeaders(api) {
    columns.forEach((c, i) => {
      const th = api.column(i).header();
      if (c.description) th.setAttribute('data-bs-title', c.description);
      const input = $('<input type="search" class="form-control form-control-sm col-search" placeholder="Filter">');
      input.on('click mousedown keydown', e => e.stopPropagation());
      input.on('input', function () {
        try {
          new RegExp(this.value);
          this.classList.remove('is-invalid');
          api.column(i).search(this.value, true, false, true).draw();
        } catch (e) { this.classList.add('is-invalid'); }
      });
      $(th).append(input);
    });
  }

  /* ------------------------------------------------------------ choix des colonnes */
  function buildColumnChooser() {
    const $list = $('#columns-list').empty();
    columns.forEach((c, i) => {
      if (i === 0) return;
      const id = 'col-' + i;
      $list.append(
        $('<div class="form-check">').attr('data-name', c.name.toLowerCase())
          .append($('<input class="form-check-input" type="checkbox">').attr({ id: id, 'data-idx': i })
            .prop('checked', selected.has(c.code)))
          .append($('<label class="form-check-label">').attr('for', id).text(c.name)));
    });
    $('#columns-block').removeClass('d-none');
    $('#columns-filter').val('');
    updateColumnLabel();
  }

  function updateColumnLabel() {
    $('#columns-label').text(selected.size + ' columns out of ' + (columns.length - 1) + ' selected');
  }

  function setColumn(idx, on) {
    const code = columns[idx].code;
    if (on) selected.add(code); else selected.delete(code);
    dt.column(idx).visible(on, false);
  }

  $('#columns-list').on('change', 'input', function () {
    setColumn(+this.dataset.idx, this.checked);
    dt.columns.adjust().draw(false);
    updateColumnLabel();
  });

  $('#columns-filter').on('input', function () {
    const q = this.value.trim().toLowerCase();
    $('#columns-list .form-check').each(function () {
      $(this).toggle(this.dataset.name.indexOf(q) !== -1);
    });
  });

  function bulk(on) {
    $('#columns-list .form-check:visible input').each(function () {
      this.checked = on;
      setColumn(+this.dataset.idx, on);
    });
    dt.columns.adjust().draw(false);
    updateColumnLabel();
  }
  $('#columns-all').on('click', () => bulk(true));
  $('#columns-none').on('click', () => bulk(false));

  /* ------------------------------------------------------------ export (lignes filtrées, colonnes affichées) */
  function exportMatrix() {
    const idxs = dt.columns().indexes().toArray().filter(i => dt.column(i).visible());
    const header = idxs.map(i => columns[i].name);
    const rows = dt.rows({ search: 'applied', order: 'applied' }).data().toArray()
      .map(r => idxs.map(i => r[i]));
    return [header].concat(rows);
  }

  function stamp() {
    const d = new Date(), p = n => String(n).padStart(2, '0');
    return d.getFullYear() + '-' + p(d.getMonth() + 1) + '-' + p(d.getDate()) + ' ' +
      d.getHours() + '-' + d.getMinutes() + '-' + d.getSeconds();   // même format que l'app Shiny
  }

  $('#dl-xlsx').on('click', function () {
    const ws = XLSX.utils.aoa_to_sheet(exportMatrix());
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Infra');
    XLSX.writeFile(wb, 'Infra-query-' + stamp() + '.xlsx');
  });

  $('#dl-tsv').on('click', function () {
    const clean = v => (v === null || v === undefined ? '' : String(v).replace(/[\t\r\n]+/g, ' '));
    const text = exportMatrix().map(r => r.map(clean).join('\t')).join('\n');
    const url = URL.createObjectURL(new Blob([text], { type: 'text/tab-separated-values;charset=utf-8' }));
    const a = document.createElement('a');
    a.href = url; a.download = 'Infra-query-' + stamp() + '.tsv';
    document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  });
})();
