$(document).ready(function() {
    const SUPERSET_BASE_URL = "http://vmi3040316.contaboserver.net:18088";
    const ES_PROXY = "/api/es";                    // proxied through nginx → elasticsearch:9200
    const ES_AUTH = "Basic " + btoa("elastic:thanhtinh@Pass123");

    const dashboards = [
        { id: 1, title: "Hospital Operations",  path: "/superset/dashboard/p/QMR9p1g47ea/?standalone=true", icon: "fa-hospital" },
        { id: 2, title: "Hospital Corporate",   path: "/superset/dashboard/p/2x584dD41aK/?standalone=true", icon: "fa-users" },
        { id: 3, title: "Hospital Financial",   path: "/superset/dashboard/p/g1vZ3RJ3MLe/?standalone=true", icon: "fa-chart-bar" },
    ];

    const $dashboardList     = $('#dashboard-list');
    const $iframe            = $('#dashboard-frame');
    const $welcomeMessage    = $('#welcome-message');
    const $currentTitle      = $('#current-dashboard-title');
    const $esContainer       = $('#elasticsearch-container');
    const $esItem            = $('#elasticsearch-item');

    // ── Render dashboard sidebar ──────────────────────────────────────────────
    dashboards.forEach(dashboard => {
        const $item = $('<a>', {
            class: 'list-group-item list-group-item-action dashboard-item',
            html: `<i class="fas ${dashboard.icon}"></i> ${dashboard.title}`
        });
        $item.on('click', function() {
            activateItem($(this), dashboard.title);
            $welcomeMessage.addClass('d-none');
            $esContainer.addClass('d-none');
            $iframe.removeClass('d-none').css('opacity', '0.5').attr('src', SUPERSET_BASE_URL + dashboard.path);
            $iframe.one('load', function() { $(this).css('opacity', '1'); });
        });
        $dashboardList.append($item);
    });

    // ── ES Search sidebar item ────────────────────────────────────────────────
    $esItem.on('click', function() {
        activateItem($(this), "Elasticsearch & Kibana Portal");
        $welcomeMessage.addClass('d-none');
        $iframe.addClass('d-none').attr('src', '');
        $esContainer.removeClass('d-none');
        // Auto-load all docs on first open
        if ($('#search-results-list').data('loaded') !== true) {
            performSearch();
        }
    });

    // ── Kibana sidebar item ───────────────────────────────────────────────────
    const KIBANA_URL = "http://vmi3040316.contaboserver.net:5601/";
    $('#kibana-item').on('click', function() {
        activateItem($(this), "Kibana — Analytics & Discover");
        $welcomeMessage.addClass('d-none');
        $esContainer.addClass('d-none');
        $iframe.removeClass('d-none').css('opacity', '0.5').attr('src', KIBANA_URL);
        $iframe.one('load', function() { $(this).css('opacity', '1'); });
    });

    // ── "Mở Kibana trong Portal" button ──────────────────────────────────────
    $(document).on('click', '#btn-open-kibana-portal', function() {
        activateItem($('#kibana-item'), "Kibana — Analytics & Discover");
        $esContainer.addClass('d-none');
        $iframe.removeClass('d-none').css('opacity', '0.5').attr('src', KIBANA_URL);
        $iframe.one('load', function() { $(this).css('opacity', '1'); });
        Swal.fire({
            title: 'Đang tải Kibana...',
            text: 'Đăng nhập: elastic / thanhtinh@Pass123',
            icon: 'info', toast: true, position: 'top-end',
            showConfirmButton: false, timer: 3500, timerProgressBar: true,
            background: '#0f4c81', color: '#fff'
        });
    });

    // ── Password toggle ───────────────────────────────────────────────────────
    $('#toggle-password-btn').on('click', function() {
        const $pw = $('#kibana-password');
        const isPw = $pw.attr('type') === 'password';
        $pw.attr('type', isPw ? 'text' : 'password');
        $(this).html(`<i class="far ${isPw ? 'fa-eye-slash' : 'fa-eye'}"></i>`);
    });

    // ── Search triggers ───────────────────────────────────────────────────────
    $('#btn-search-es').on('click', performSearch);
    $('#search-query').on('keypress', function(e) { if (e.which === 13) performSearch(); });

    // ── Core search function — always hits real ES via nginx proxy ────────────
    function performSearch() {
        const query         = $('#search-query').val().trim();
        const selectedIndex = $('#search-index').val();
        const $list         = $('#search-results-list');
        const $metrics      = $('#search-metrics');
        const indexPath     = selectedIndex === '_all' ? '*' : selectedIndex;

        $list.html(`
            <div class="text-center py-5">
                <div class="spinner-border text-primary mb-3" role="status"><span class="visually-hidden">Loading...</span></div>
                <p class="text-muted fw-semibold">Đang truy vấn Elasticsearch...</p>
                <small class="text-muted">Index: <code>${selectedIndex}</code></small>
            </div>
        `);
        $metrics.html('<span class="text-muted">Đang tải...</span>');

        const dslQuery = query
            ? { query: { multi_match: { query: query, fields: ["*"], fuzziness: "AUTO" } }, size: 50, track_total_hits: true }
            : { query: { match_all: {} }, size: 50, track_total_hits: true };

        const t0 = performance.now();

        $.ajax({
            url: `${ES_PROXY}/${indexPath}/_search`,
            type: 'POST',
            contentType: 'application/json',
            headers: { "Authorization": ES_AUTH },
            data: JSON.stringify(dslQuery),
            success: function(res) {
                const ms   = (performance.now() - t0).toFixed(0);
                const hits = res.hits?.hits ?? [];
                const total = res.hits?.total?.value ?? hits.length;

                $list.data('loaded', true);
                $metrics.html(`Tìm thấy <strong>${total.toLocaleString()}</strong> tài liệu — trả về <strong>${hits.length}</strong>, thời gian <strong>${ms}ms</strong>`);

                if (hits.length === 0) {
                    $list.html(`
                        <div class="text-center py-5 text-muted border rounded bg-white" style="border-radius:8px;">
                            <i class="fas fa-search-minus fs-1 mb-3 text-secondary" style="opacity:.4;"></i>
                            <p class="mb-0">Không tìm thấy tài liệu nào${query ? ` cho từ khóa <strong>"${$('<div>').text(query).html()}"</strong>` : ''}.</p>
                            <small class="text-muted">Index <code>${selectedIndex}</code> có thể chưa có dữ liệu. Chạy Spark job để đồng bộ.</small>
                        </div>
                    `);
                    return;
                }
                renderResults(hits, $list);
            },
            error: function(xhr) {
                const ms  = (performance.now() - t0).toFixed(0);
                const msg = xhr.responseJSON?.error?.reason ?? xhr.statusText ?? 'Unknown error';
                $metrics.html(`<span class="text-danger"><i class="fas fa-exclamation-circle me-1"></i>Lỗi kết nối</span>`);
                $list.html(`
                    <div class="alert alert-danger border-0 p-4" style="border-radius:12px;">
                        <h5 class="alert-heading fw-bold mb-3">
                            <i class="fas fa-exclamation-triangle me-2"></i>Không thể kết nối Elasticsearch
                        </h5>
                        <p class="mb-1">URL: <code>${ES_PROXY}/${indexPath}/_search</code></p>
                        <p class="mb-3">Lỗi: <code>${$('<div>').text(msg).html()}</code></p>
                        <hr>
                        <p class="mb-1 fw-bold">Kiểm tra:</p>
                        <ol class="small mb-0">
                            <li>Container <code>elasticsearch</code> đang chạy: <code>docker start elasticsearch</code></li>
                            <li>Container <code>bi-portal</code> đang ở đúng network <code>elastic-net</code></li>
                            <li>Index <code>${selectedIndex}</code> tồn tại: chạy Spark job để đồng bộ dữ liệu</li>
                        </ol>
                    </div>
                `);
            }
        });
    }

    // ── Render result cards ───────────────────────────────────────────────────
    function renderResults(hits, $container) {
        $container.empty();

        hits.forEach(hit => {
            const idx = hit._index;
            const s   = hit._source;
            let html  = '';

            // Dynamically pick display name from common field name patterns
            const patientName = s.ten_nb || s.ten_benh_nhan || s.ho_ten || s.name || s.full_name || '';
            const serviceName = s.ten_dichvu || s.ten_dich_vu || s.name || s.service_name || '';
            const staffName   = s.ten_nhan_vien || s.ho_ten || s.name || '';

            if (idx.includes('benh_nhan')) {
                html = `
                <div class="card border-0 shadow-sm bg-white" style="border-left:4px solid #0d6efd;border-radius:8px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-primary-subtle text-primary mb-1 small">Bệnh nhân</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(patientName)}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.ma_nb || hit._id)}</span>
                        </div>
                        ${renderFields(s, ['ngay_sinh','gioi_tinh','so_dien_thoai','dia_chi','nhom_mau','tien_su_benh','ten_nb_khong_dau'])}
                    </div>
                </div>`;

            } else if (idx.includes('dich_vu')) {
                html = `
                <div class="card border-0 shadow-sm bg-white" style="border-left:4px solid #ffc107;border-radius:8px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-warning-subtle mb-1 small" style="color:#664d03;">Dịch vụ</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(serviceName)}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.code_dichvu || hit._id)}</span>
                        </div>
                        ${renderFields(s, ['loai_dichvu','khoa_thuc_hien','don_gia','thoi_gian_co_kq'])}
                    </div>
                </div>`;

            } else if (idx.includes('dot_dieu_tri')) {
                html = `
                <div class="card border-0 shadow-sm bg-white" style="border-left:4px solid #198754;border-radius:8px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-success-subtle text-success mb-1 small">Đợt Điều trị</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(patientName || 'Hồ sơ bệnh án')}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.ma_benh_an || hit._id)}</span>
                        </div>
                        ${renderFields(s, ['ma_nb','khoa_dieu_tri','bac_si_dieu_tri','ngay_vao','ngay_ra','chan_doan','tinh_trang'])}
                    </div>
                </div>`;

            } else if (idx.includes('nhan_vien')) {
                html = `
                <div class="card border-0 shadow-sm bg-white" style="border-left:4px solid #0dcaf0;border-radius:8px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-info-subtle text-info mb-1 small" style="color:#055160!important;">Nhân viên y tế</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(staffName)}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.code_nhan_vien || hit._id)}</span>
                        </div>
                        ${renderFields(s, ['chuc_vu','khoa_phong','so_dien_thoai','email','hoc_vi'])}
                    </div>
                </div>`;

            } else {
                // Generic fallback — show all fields as key-value
                html = `
                <div class="card border-0 shadow-sm bg-white" style="border-left:4px solid #6c757d;border-radius:8px;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="badge bg-secondary-subtle text-secondary small">${esc(idx)}</span>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(hit._id)}</span>
                        </div>
                        ${renderFields(s, Object.keys(s).slice(0, 10))}
                    </div>
                </div>`;
            }

            $container.append(html);
        });
    }

    // ── Helper: render key-value field rows ───────────────────────────────────
    function renderFields(source, keys) {
        const rows = keys
            .filter(k => source[k] !== undefined && source[k] !== null && source[k] !== '')
            .map(k => {
                const label = k.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
                const val   = esc(String(source[k]));
                return `<div class="col-sm-6 col-lg-4"><strong>${label}:</strong> <span class="text-secondary">${val}</span></div>`;
            });
        return rows.length ? `<div class="row g-1 small mt-1">${rows.join('')}</div>` : '';
    }

    // ── Helper: escape HTML ───────────────────────────────────────────────────
    function esc(str) {
        return $('<div>').text(str ?? '').html();
    }

    // ── Helper: set active sidebar item + navbar title ────────────────────────
    function activateItem($el, title) {
        $('.dashboard-item').removeClass('active');
        $el.addClass('active');
        $('#current-dashboard-title').text(title);
    }

    // ── Login notification ────────────────────────────────────────────────────
    if (!sessionStorage.getItem('login_notified')) {
        Swal.fire({
            title: 'Welcome Back!',
            text: 'You have successfully logged into the BI Portal.',
            icon: 'success', toast: true, position: 'top-end',
            showConfirmButton: false, timer: 3000, timerProgressBar: true,
            background: '#1a1a1a', color: '#fff'
        });
        sessionStorage.setItem('login_notified', 'true');
    }

    // ── Sidebar toggle ────────────────────────────────────────────────────────
    $("#menu-toggle").click(function(e) {
        e.preventDefault();
        $("body").toggleClass("sb-sidenav-toggled");
    });
});
