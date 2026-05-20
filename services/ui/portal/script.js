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
    
    let searchHits = []; // Cache search hits for click-to-view details

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
                searchHits = hits; // Cache hits for modal detail viewing
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

    // ── Translation & Formatter Helpers ────────────────────────────────────────
    const FIELD_LABELS = {
        id: "ID tài liệu",
        active: "Trạng thái",
        gioi_tinh: "Giới tính",
        email: "Email",
        ngay_sinh: "Ngày sinh",
        so_dien_thoai: "Số điện thoại",
        
        // Patient index (idx_benh_nhan)
        nb_thong_tin_id: "ID thông tin NB",
        ma_nb: "Mã người bệnh",
        ten_nb: "Tên người bệnh",
        ten_nb_khong_dau: "Tên không dấu",

        // Service index (idx_dich_vu)
        code_dichvu: "Mã dịch vụ",
        ten: "Tên dịch vụ",
        ten_tuong_duong: "Tên tương đương",
        viet_tat: "Viết tắt",
        gia_bao_hiem: "Giá bảo hiểm",
        gia_khong_bao_hiem: "Giá không bảo hiểm",
        loai_dich_vu: "Loại dịch vụ",

        // Episode index (idx_dot_dieu_tri)
        cap_cuu: "Cấp cứu",
        doi_tuong: "Đối tượng",
        doi_tuong_kcb: "Đối tượng KCB",
        kham_suc_khoe: "Khám sức khỏe",
        khoa_id: "Khoa điều trị (ID)",
        khoa_tiep_don_id: "Khoa tiếp đón (ID)",
        loai_benh_an_id: "Loại bệnh án (ID)",
        loai_doi_tuong_id: "Loại đối tượng (ID)",
        ma_benh_an: "Mã bệnh án",
        ma_ho_so: "Mã hồ sơ",
        so_bao_hiem_xa_hoi: "Số BHXH",
        so_ngay_dieu_tri: "Số ngày điều trị",
        so_phoi: "Số phôi",
        thoi_gian_lap_benh_an: "Thời gian lập bệnh án",
        thoi_gian_ra_vien: "Thời gian ra viện",
        thoi_gian_vao_vien: "Thời gian vào viện",
        trang_thai: "Trạng thái điều trị",
        uu_tien: "Diện ưu tiên",

        // Staff index (idx_nhan_vien)
        code_nhan_vien: "Mã nhân viên",
        chung_chi: "Chứng chỉ hành nghề",
        ds_chuyen_khoa_id: "Mã chuyên khoa (DS)"
    };

    const FIELD_ICONS = {
        id: "fa-fingerprint",
        active: "fa-toggle-on",
        gioi_tinh: "fa-venus-mars",
        email: "fa-envelope",
        ngay_sinh: "fa-calendar-alt",
        so_dien_thoai: "fa-phone",
        nb_thong_tin_id: "fa-id-card",
        ma_nb: "fa-user-tag",
        ten_nb: "fa-user",
        ten_nb_khong_dau: "fa-keyboard",
        code_dichvu: "fa-barcode",
        ten: "fa-file-medical",
        ten_tuong_duong: "fa-file-signature",
        viet_tat: "fa-font",
        gia_bao_hiem: "fa-hand-holding-usd",
        gia_khong_bao_hiem: "fa-dollar-sign",
        loai_dich_vu: "fa-tags",
        cap_cuu: "fa-ambulance",
        doi_tuong: "fa-users-cog",
        doi_tuong_kcb: "fa-file-invoice",
        kham_suc_khoe: "fa-heartbeat",
        khoa_id: "fa-clinic-medical",
        khoa_tiep_don_id: "fa-sign-in-alt",
        loai_benh_an_id: "fa-folder-open",
        loai_doi_tuong_id: "fa-user-shield",
        ma_benh_an: "fa-file-alt",
        ma_ho_so: "fa-briefcase-medical",
        so_bao_hiem_xa_hoi: "fa-shield-alt",
        so_ngay_dieu_tri: "fa-hourglass-half",
        so_phoi: "fa-scroll",
        thoi_gian_lap_benh_an: "fa-clock",
        thoi_gian_ra_vien: "fa-door-open",
        thoi_gian_vao_vien: "fa-door-closed",
        trang_thai: "fa-info-circle",
        uu_tien: "fa-star",
        code_nhan_vien: "fa-id-badge",
        chung_chi: "fa-certificate",
        ds_chuyen_khoa_id: "fa-laptop-medical"
    };

    function formatValue(key, val) {
        if (val === null || val === undefined || val === '') return '<em class="text-muted">Chưa cập nhật</em>';

        if (key === 'gia_bao_hiem' || key === 'gia_khong_bao_hiem') {
            return `<strong class="text-success">${formatCurrency(val)}</strong>`;
        }
        
        if (key === 'gioi_tinh') {
            const numVal = parseInt(val, 10);
            if (numVal === 1 || String(val).toLowerCase() === 'nam') {
                return `<span class="badge bg-primary-subtle text-primary"><i class="fas fa-mars me-1"></i>Nam</span>`;
            }
            if (numVal === 2 || String(val).toLowerCase() === 'nữ' || String(val).toLowerCase() === 'nu') {
                return `<span class="badge bg-danger-subtle text-danger"><i class="fas fa-venus me-1"></i>Nữ</span>`;
            }
            return `<span class="badge bg-secondary-subtle text-secondary"><i class="fas fa-genderless me-1"></i>${esc(val)}</span>`;
        }

        if (key === 'active') {
            const isActive = val === true || val === 'true' || val === 1 || val === '1' || val === 'Active';
            return isActive 
                ? `<span class="badge bg-success-subtle text-success"><i class="fas fa-check-circle me-1"></i>Đang hoạt động</span>`
                : `<span class="badge bg-danger-subtle text-danger"><i class="fas fa-times-circle me-1"></i>Ngưng hoạt động</span>`;
        }

        if (key === 'cap_cuu' || key === 'uu_tien' || key === 'kham_suc_khoe') {
            const isTrue = val === true || val === 'true' || val === 1 || val === '1' || String(val).toLowerCase() === 'yes';
            return isTrue 
                ? `<span class="badge bg-danger-subtle text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Có</span>`
                : `<span class="badge bg-light text-muted">Không</span>`;
        }

        if (key.includes('thoi_gian') || key.includes('ngay_sinh')) {
            return `<span class="text-dark"><i class="far fa-clock me-1 text-muted"></i>${formatDateTime(val)}</span>`;
        }

        return esc(String(val));
    }

    function formatCurrency(value) {
        const num = parseFloat(value);
        if (isNaN(num)) return value;
        return num.toLocaleString('vi-VN') + ' ₫';
    }

    function formatDateTime(value) {
        if (!value) return '';
        try {
            const date = new Date(value);
            if (!isNaN(date.getTime())) {
                if (String(value).length <= 10 && /^\d{4}-\d{2}-\d{2}$/.test(String(value))) {
                    return date.toLocaleDateString('vi-VN');
                }
                return date.toLocaleString('vi-VN', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                });
            }
        } catch(e) {}
        return value;
    }

    // ── Render result cards ───────────────────────────────────────────────────
    function renderResults(hits, $container) {
        $container.empty();

        hits.forEach((hit, i) => {
            const idx = hit._index;
            const s   = hit._source;
            let html  = '';

            if (idx.includes('benh_nhan')) {
                html = `
                <div class="card border-0 shadow-sm bg-white result-card" data-index="${i}" style="border-left:4px solid #0d6efd; border-radius:8px; cursor:pointer;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-primary-subtle text-primary mb-1 small"><i class="fas fa-user-injured me-1"></i>Bệnh nhân</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(s.ten_nb)}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.ma_nb || hit._id)}</span>
                        </div>
                        <div class="row g-2 small mt-1">
                            <div class="col-sm-6"><strong>Số điện thoại:</strong> <span class="text-secondary">${esc(s.so_dien_thoai || 'Chưa cập nhật')}</span></div>
                            <div class="col-sm-6"><strong>ID thông tin NB:</strong> <span class="text-secondary font-monospace">${esc(s.nb_thong_tin_id || '')}</span></div>
                        </div>
                    </div>
                </div>`;

            } else if (idx.includes('dich_vu')) {
                html = `
                <div class="card border-0 shadow-sm bg-white result-card" data-index="${i}" style="border-left:4px solid #ffc107; border-radius:8px; cursor:pointer;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-warning-subtle mb-1 small" style="color:#664d03;"><i class="fas fa-stethoscope me-1"></i>Dịch vụ</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(s.ten)}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.code_dichvu || hit._id)}</span>
                        </div>
                        <div class="row g-2 small mt-1">
                            <div class="col-sm-6"><strong>Loại dịch vụ:</strong> <span class="badge bg-light text-dark">${esc(s.loai_dich_vu || 'Khác')}</span></div>
                            <div class="col-sm-6"><strong>Trạng thái:</strong> ${formatValue('active', s.active)}</div>
                            <div class="col-sm-6"><strong>Giá BH:</strong> ${formatValue('gia_bao_hiem', s.gia_bao_hiem)}</div>
                            <div class="col-sm-6"><strong>Giá tự nguyện:</strong> ${formatValue('gia_khong_bao_hiem', s.gia_khong_bao_hiem)}</div>
                        </div>
                    </div>
                </div>`;

            } else if (idx.includes('dot_dieu_tri')) {
                html = `
                <div class="card border-0 shadow-sm bg-white result-card" data-index="${i}" style="border-left:4px solid #198754; border-radius:8px; cursor:pointer;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-success-subtle text-success mb-1 small"><i class="fas fa-notes-medical me-1"></i>Đợt điều trị</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(s.ten_nb || 'Hồ sơ điều trị')}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.ma_benh_an || hit._id)}</span>
                        </div>
                        <div class="row g-2 small mt-1">
                            <div class="col-sm-6 col-md-4"><strong>Mã NB:</strong> <span class="text-secondary">${esc(s.ma_nb || '')}</span></div>
                            <div class="col-sm-6 col-md-4"><strong>Giới tính:</strong> ${formatValue('gioi_tinh', s.gioi_tinh)}</div>
                            <div class="col-sm-6 col-md-4"><strong>Cấp cứu:</strong> ${formatValue('cap_cuu', s.cap_cuu)}</div>
                            <div class="col-sm-6 col-md-4"><strong>Vào viện:</strong> ${formatValue('thoi_gian_vao_vien', s.thoi_gian_vao_vien)}</div>
                            <div class="col-sm-6 col-md-4"><strong>Số ngày ĐT:</strong> <span class="text-dark fw-bold">${esc(s.so_ngay_dieu_tri || '0')} ngày</span></div>
                            <div class="col-sm-6 col-md-4"><strong>Đối tượng:</strong> <span class="badge bg-info-subtle text-dark">${esc(s.doi_tuong || 'Không rõ')}</span></div>
                        </div>
                    </div>
                </div>`;

            } else if (idx.includes('nhan_vien')) {
                html = `
                <div class="card border-0 shadow-sm bg-white result-card" data-index="${i}" style="border-left:4px solid #0dcaf0; border-radius:8px; cursor:pointer;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <div>
                                <span class="badge bg-info-subtle text-info mb-1 small" style="color:#055160!important;"><i class="fas fa-user-md me-1"></i>Nhân viên y tế</span>
                                <h6 class="fw-bold text-dark mb-0">${esc(s.ten)}</h6>
                            </div>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(s.code_nhan_vien || hit._id)}</span>
                        </div>
                        <div class="row g-2 small mt-1">
                            <div class="col-sm-6"><strong>Chứng chỉ:</strong> <span class="text-secondary">${esc(s.chung_chi || 'Không có')}</span></div>
                            <div class="col-sm-6"><strong>Trạng thái:</strong> ${formatValue('active', s.active)}</div>
                            <div class="col-sm-6"><strong>Email:</strong> <span class="text-secondary">${esc(s.email || 'Chưa cập nhật')}</span></div>
                            <div class="col-sm-6"><strong>Giới tính:</strong> ${formatValue('gioi_tinh', s.gioi_tinh)}</div>
                        </div>
                    </div>
                </div>`;

            } else {
                html = `
                <div class="card border-0 shadow-sm bg-white result-card" data-index="${i}" style="border-left:4px solid #6c757d; border-radius:8px; cursor:pointer;">
                    <div class="card-body p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="badge bg-secondary-subtle text-secondary small">${esc(idx)}</span>
                            <span class="badge bg-secondary-subtle text-secondary font-monospace small">${esc(hit._id)}</span>
                        </div>
                        <div class="row g-2 small mt-1">
                            <div class="col-12"><strong>Nội dung:</strong> <span class="text-secondary font-monospace">${esc(JSON.stringify(s).substring(0, 150))}...</span></div>
                        </div>
                    </div>
                </div>`;
            }

            $container.append(html);
        });
    }

    // ── Show detailed modal ──────────────────────────────────────────────────
    function showDetailsModal(hit) {
        const idx = hit._index;
        const s   = hit._source;

        let headerColor = '#0d6efd';
        let indexIcon = 'fa-user-injured';
        let indexTitle = 'Thông Tin Bệnh Nhân';

        if (idx.includes('dich_vu')) {
            headerColor = '#e0a800'; 
            indexIcon = 'fa-stethoscope';
            indexTitle = 'Thông Tin Dịch Vụ';
        } else if (idx.includes('dot_dieu_tri')) {
            headerColor = '#198754';
            indexIcon = 'fa-notes-medical';
            indexTitle = 'Chi Tiết Đợt Điều Trị';
        } else if (idx.includes('nhan_vien')) {
            headerColor = '#0dcaf0';
            indexIcon = 'fa-user-md';
            indexTitle = 'Thông Tin Nhân Viên Y Tế';
        }

        // Build the fields grid dynamically
        let fieldsHtml = '<div class="row g-3">';
        const keys = Object.keys(s);
        keys.forEach(k => {
            const val = s[k];
            const label = FIELD_LABELS[k] || k.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
            const icon = FIELD_ICONS[k] || 'fa-info-circle';
            const formatted = formatValue(k, val);
            
            fieldsHtml += `
            <div class="col-md-6">
                <div class="p-2 border-bottom d-flex align-items-start h-100">
                    <div class="text-muted me-3 mt-1" style="width: 20px; text-align: center;">
                        <i class="fas ${icon}"></i>
                    </div>
                    <div>
                        <small class="text-muted d-block fw-semibold mb-0" style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;">${esc(label)}</small>
                        <div class="text-dark fw-medium mt-0" style="font-size: 0.95rem;">${formatted}</div>
                    </div>
                </div>
            </div>`;
        });
        fieldsHtml += '</div>';

        const modalHtml = `
        <div class="text-start">
            <!-- Banner Header -->
            <div class="p-4 rounded-top mb-4 text-white d-flex align-items-center justify-content-between" style="background: linear-gradient(135deg, ${headerColor}, #1f2937); margin: -1.25rem -1.25rem 1.5rem -1.25rem; border-radius: 8px 8px 0 0;">
                <div class="d-flex align-items-center">
                    <div class="rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 50px; height: 50px; background: rgba(255,255,255,0.2);">
                        <i class="fas ${indexIcon} fs-4"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-0 text-white">${esc(indexTitle)}</h5>
                        <small class="text-white-50">Index: <code>${esc(idx)}</code> | ID: <code>${esc(hit._id)}</code></small>
                    </div>
                </div>
                <span class="badge bg-light text-dark font-monospace">${esc(s.ma_nb || s.code_dichvu || s.code_nhan_vien || s.ma_benh_an || 'DOC')}</span>
            </div>

            <!-- Navigation Tabs -->
            <ul class="nav nav-pills nav-fill mb-3 bg-light p-1 rounded-pill" id="modal-detail-tabs" role="tablist" style="font-size: 0.9rem;">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active rounded-pill fw-semibold" id="tab-info" data-bs-toggle="pill" data-bs-target="#panel-info" type="button" role="tab" aria-controls="panel-info" aria-selected="true">
                        <i class="fas fa-info-circle me-1"></i>Thông tin chi tiết
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link rounded-pill fw-semibold" id="tab-json" data-bs-toggle="pill" data-bs-target="#panel-json" type="button" role="tab" aria-controls="panel-json" aria-selected="false">
                        <i class="fas fa-code me-1"></i>Raw JSON
                    </button>
                </li>
            </ul>

            <!-- Tab Content -->
            <div class="tab-content pt-2" id="modal-detail-content">
                <div class="tab-pane fade show active" id="panel-info" role="tabpanel" aria-labelledby="tab-info">
                    <div class="card border-0 bg-light p-3" style="border-radius: 12px; max-height: 400px; overflow-y: auto;">
                        ${fieldsHtml}
                    </div>
                </div>
                <div class="tab-pane fade" id="panel-json" role="tabpanel" aria-labelledby="tab-json">
                    <div class="position-relative">
                        <button class="btn btn-sm btn-outline-secondary position-absolute top-0 end-0 m-2" onclick="navigator.clipboard.writeText($('#raw-json-block').text()); Swal.fire({toast:true,position:'top-end',icon:'success',title:'Copied!',showConfirmButton:false,timer:1200,background:'#1a1a1a',color:'#fff'})">
                            <i class="far fa-copy me-1"></i>Copy
                        </button>
                        <pre class="bg-dark text-light p-3 rounded" style="max-height: 400px; overflow-y: auto; font-size: 0.85rem; font-family: SFMono-Regular, Menlo, Monaco, Consolas, monospace;"><code id="raw-json-block" class="language-json">${esc(JSON.stringify(hit, null, 2))}</code></pre>
                    </div>
                </div>
            </div>
        </div>
        `;

        Swal.fire({
            html: modalHtml,
            width: '800px',
            showCloseButton: true,
            showConfirmButton: false,
            background: '#fff',
            customClass: {
                popup: 'rounded-4 shadow-lg border-0 p-3'
            }
        });
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

    // Bind click events on result cards to show detail modal
    $(document).on('click', '.result-card', function() {
        const idx = $(this).data('index');
        if (searchHits[idx]) {
            showDetailsModal(searchHits[idx]);
        }
    });

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
