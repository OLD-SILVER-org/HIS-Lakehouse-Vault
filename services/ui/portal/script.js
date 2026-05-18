$(document).ready(function() {
    const SUPERSET_BASE_URL = "http://vmi3040316.contaboserver.net:18088";
    
    // Quản lý danh sách dashboard tập trung
    const dashboards = [
        {
            id: 1,
            title: "Hospital Operations",
            path: "/superset/dashboard/p/QMR9p1g47ea/?standalone=true",
            icon: "fa-hospital"
        },
        {
            id: 2,
            title: "Hospital Corporate",
            path: "/superset/dashboard/p/2x584dD41aK/?standalone=true",
            icon: "fa-users"
        },
        {
            id: 3,
            title: "Hospital Financial",
            path: "/superset/dashboard/p/g1vZ3RJ3MLe/?standalone=true",
            icon: "fa-chart-bar"
        },
    ];

    const $dashboardList = $('#dashboard-list');
    const $iframe = $('#dashboard-frame');
    const $welcomeMessage = $('#welcome-message');
    const $currentTitle = $('#current-dashboard-title');
    const $elasticsearchContainer = $('#elasticsearch-container');
    const $elasticsearchItem = $('#elasticsearch-item');

    // Quản lý dữ liệu Mock phong phú cho chế độ Demo
    const mockData = {
        idx_benh_nhan: [
            {
                ma_nb: "BN20260001",
                ten_benh_nhan: "Nguyễn Văn Anh",
                ngay_sinh: "15/08/1984",
                gioi_tinh: "Nam",
                so_dien_thoai: "0912345678",
                dia_chi: "Hai Bà Trưng, Hà Nội",
                nhom_mau: "O+",
                tien_su_benh: "Tăng huyết áp vô căn, Đái tháo đường Type 2"
            },
            {
                ma_nb: "BN20260002",
                ten_benh_nhan: "Trần Thị Bình",
                ngay_sinh: "02/11/1992",
                gioi_tinh: "Nữ",
                so_dien_thoai: "0987654321",
                dia_chi: "Quận 1, TP. Hồ Chí Minh",
                nhom_mau: "A-",
                tien_su_benh: "Dị ứng Aspirin, Hen phế quản nhẹ"
            },
            {
                ma_nb: "BN20260003",
                ten_benh_nhan: "Phạm Hồng Cường",
                ngay_sinh: "25/04/1975",
                gioi_tinh: "Nam",
                so_dien_thoai: "0905123456",
                dia_chi: "Hải Châu, Đà Nẵng",
                nhom_mau: "B+",
                tien_su_benh: "Viêm dạ dày mãn tính, Rối loạn lipid máu"
            },
            {
                ma_nb: "BN20260004",
                ten_benh_nhan: "Lê Minh Dương",
                ngay_sinh: "19/01/2001",
                gioi_tinh: "Nam",
                so_dien_thoai: "0934888999",
                dia_chi: "Ninh Kiều, Cần Thơ",
                nhom_mau: "AB+",
                tien_su_benh: "Khỏe mạnh, không có tiền sử bệnh lý nền"
            },
            {
                ma_nb: "BN20260005",
                ten_benh_nhan: "Hoàng Thanh Hương",
                ngay_sinh: "30/09/1988",
                gioi_tinh: "Nữ",
                so_dien_thoai: "0918777666",
                dia_chi: "Hồng Bàng, Hải Phòng",
                nhom_mau: "O-",
                tien_su_benh: "Suy giáp đang điều trị ổn định"
            }
        ],
        idx_dich_vu: [
            {
                code_dichvu: "DV0001",
                ten_dichvu: "Khám bệnh lâm sàng tổng quát",
                loai_dichvu: "Khám bệnh",
                don_gia: "150,000 VND",
                khoa_thuc_hien: "Khoa Khám Bệnh",
                thoi_gian_co_kq: "Liền sau khám"
            },
            {
                code_dichvu: "DV0002",
                ten_dichvu: "Công thức máu toàn bộ (CBC 24 thông số)",
                loai_dichvu: "Xét nghiệm máu",
                don_gia: "120,000 VND",
                khoa_thuc_hien: "Khoa Xét Nghiệm Huyết học",
                thoi_gian_co_kq: "30 - 45 phút"
            },
            {
                code_dichvu: "DV0003",
                ten_dichvu: "Chụp X-Quang ngực thẳng kỹ thuật số",
                loai_dichvu: "Chẩn đoán hình ảnh",
                don_gia: "250,000 VND",
                khoa_thuc_hien: "Khoa Chẩn Đoán Hình Ảnh",
                thoi_gian_co_kq: "15 - 20 phút"
            },
            {
                code_dichvu: "DV0004",
                ten_dichvu: "Siêu âm tim màu doppler 4D",
                loai_dichvu: "Chẩn đoán chức năng",
                don_gia: "450,000 VND",
                khoa_thuc_hien: "Khoa Tim Mạch",
                thoi_gian_co_kq: "20 phút"
            },
            {
                code_dichvu: "DV0005",
                ten_dichvu: "Sinh hóa máu: Glucose, Ure, Creatinin",
                loai_dichvu: "Xét nghiệm sinh hóa",
                don_gia: "180,000 VND",
                khoa_thuc_hien: "Khoa Xét Nghiệm Hóa sinh",
                thoi_gian_co_kq: "45 phút"
            }
        ],
        idx_dot_dieu_tri: [
            {
                ma_benh_an: "BA-2026-00921",
                ma_nb: "BN20260001",
                ten_benh_nhan: "Nguyễn Văn Anh",
                khoa_dieu_tri: "Khoa Nội Tổng Hợp",
                ngay_vao: "10/05/2026",
                ngay_ra: "15/05/2026",
                chan_doan: "Cơn tăng huyết áp khẩn cấp / Đái tháo đường tuýp II kiểm soát kém",
                tinh_trang: "Đã xuất viện, huyết áp mục tiêu ổn định",
                bac_si_dieu_tri: "BS.CKII. Phạm Minh Trí"
            },
            {
                ma_benh_an: "BA-2026-00922",
                ma_nb: "BN20260003",
                ten_benh_nhan: "Phạm Hồng Cường",
                khoa_dieu_tri: "Khoa Tiêu Hóa",
                ngay_vao: "12/05/2026",
                ngay_ra: "Đang điều trị",
                chan_doan: "Xuất huyết tiêu hóa cao do loét dạ dày tiến triển Forrest IIb",
                tinh_trang: "Tỉnh táo, mạch huyết áp ổn định, đang theo dõi sát phân và dịch vị",
                bac_si_dieu_tri: "ThS.BS. Lê Hoàng Nam"
            },
            {
                ma_benh_an: "BA-2026-00923",
                ma_nb: "BN20260002",
                ten_benh_nhan: "Trần Thị Bình",
                khoa_dieu_tri: "Khoa Hô Hấp",
                ngay_vao: "14/05/2026",
                ngay_ra: "17/05/2026",
                chan_doan: "Cơn hen phế quản cấp mức độ trung bình / Trào ngược dạ dày thực quản",
                tinh_trang: "Cắt cơn hen hoàn toàn, thở êm, phổi phế nang rõ rệt",
                bac_si_dieu_tri: "BS. Nguyễn Thị Vân"
            }
        ],
        idx_nhan_vien: [
            {
                code_nhan_vien: "NV00101",
                ten_nhan_vien: "Phạm Minh Trí",
                chuc_vu: "Bác sĩ Trưởng khoa",
                khoa_phong: "Khoa Nội Tổng Hợp",
                so_dien_thoai: "0903999888",
                email: "tri.pm@hospital.vn",
                hoc_vi: "BS.CKII - Chuyên ngành Nội Tim Mạch"
            },
            {
                code_nhan_vien: "NV00102",
                ten_nhan_vien: "Lê Hoàng Nam",
                chuc_vu: "Bác sĩ Điều trị",
                khoa_phong: "Khoa Tiêu Hóa",
                so_dien_thoai: "0912111222",
                email: "nam.lh@hospital.vn",
                hoc_vi: "Thạc sĩ Y khoa - Chuyên ngành Tiêu hóa gan mật"
            },
            {
                code_nhan_vien: "NV00201",
                ten_nhan_vien: "Nguyễn Thị Vân",
                chuc_vu: "Bác sĩ Điều trị",
                khoa_phong: "Khoa Hô Hấp",
                so_dien_thoai: "0945666777",
                email: "van.nt@hospital.vn",
                hoc_vi: "Bác sĩ Nội Trú - Chuyên ngành Hô hấp"
            },
            {
                code_nhan_vien: "NV00305",
                ten_nhan_vien: "Hoàng Thu Thủy",
                chuc_vu: "Điều dưỡng trưởng",
                khoa_phong: "Khoa Khám Bệnh",
                so_dien_thoai: "0978222333",
                email: "thuy.ht@hospital.vn",
                hoc_vi: "Cử nhân Điều dưỡng"
            }
        ]
    };

    // Render dashboard list
    dashboards.forEach(dashboard => {
        const $item = $('<a>', {
            class: 'list-group-item list-group-item-action dashboard-item',
            html: `<i class="fas ${dashboard.icon}"></i> ${dashboard.title}`
        });

        $item.on('click', function() {
            // Update active state
            $('.dashboard-item').removeClass('active');
            $(this).addClass('active');

            // Update title
            $currentTitle.text(dashboard.title);

            // Load iframe and effect
            $welcomeMessage.addClass('d-none');
            $elasticsearchContainer.addClass('d-none');
            
            // show frame and update url
            $iframe.removeClass('d-none').attr('src', SUPERSET_BASE_URL + dashboard.path);
            
            // Optional: add load animation
            $iframe.css('opacity', '0.5');
            $iframe.on('load', function() {
                $(this).css('opacity', '1');
            });
        });

        $dashboardList.append($item);
    });

    // Handle Elasticsearch Click
    $elasticsearchItem.on('click', function() {
        // Update active state
        $('.dashboard-item').removeClass('active');
        $(this).addClass('active');

        // Update title
        $currentTitle.text("Elasticsearch & Kibana Portal");

        // Hide iframe and welcome, show ES search dashboard
        $welcomeMessage.addClass('d-none');
        $iframe.addClass('d-none');
        $elasticsearchContainer.removeClass('d-none');
    });

    // Password Visibility Toggle for Kibana Credentials
    $('#toggle-password-btn').on('click', function() {
        const $pw = $('#kibana-password');
        const isPw = $pw.attr('type') === 'password';
        $pw.attr('type', isPw ? 'text' : 'password');
        $(this).html(`<i class="far ${isPw ? 'fa-eye-slash' : 'fa-eye'}"></i>`);
    });

    // Connection Switch Status Handler
    $('#search-mode-switch').on('change', function() {
        const isDemo = $(this).is(':checked');
        const $status = $('#connection-status');
        if (isDemo) {
            $status.removeClass('bg-success-subtle text-success border-success-subtle bg-danger-subtle text-danger border-danger-subtle')
                   .addClass('bg-warning-subtle text-warning border border-warning-subtle')
                   .html('<i class="fas fa-circle text-warning me-1"></i> Demo Mode');
        } else {
            $status.removeClass('bg-warning-subtle text-warning border-warning-subtle')
                   .addClass('bg-success-subtle text-success border border-success-subtle')
                   .html('<i class="fas fa-circle text-success me-1"></i> Real ES Mode');
        }
    });

    // Search Action Handler
    $('#btn-search-es').on('click', performSearch);
    $('#search-query').on('keypress', function(e) {
        if (e.which === 13) {
            performSearch();
        }
    });

    function performSearch() {
        const query = $('#search-query').val().trim().toLowerCase();
        const selectedIndex = $('#search-index').val();
        const isDemo = $('#search-mode-switch').is(':checked');
        const $resultsList = $('#search-results-list');
        const $metrics = $('#search-metrics');

        $resultsList.html(`
            <div class="text-center py-5">
                <div class="spinner-border text-primary mb-3" role="status"></div>
                <p class="text-muted">Đang truy vấn dữ liệu từ hệ thống...</p>
            </div>
        `);

        const startTime = performance.now();

        if (isDemo) {
            setTimeout(() => {
                let results = [];
                const indicesToSearch = selectedIndex === '_all' 
                    ? Object.keys(mockData) 
                    : [selectedIndex];

                indicesToSearch.forEach(idx => {
                    if (mockData[idx]) {
                        mockData[idx].forEach(item => {
                            let isMatch = false;
                            if (!query) {
                                isMatch = true;
                            } else {
                                for (const key in item) {
                                    if (item[key].toString().toLowerCase().includes(query)) {
                                        isMatch = true;
                                        break;
                                    }
                                }
                            }

                            if (isMatch) {
                                results.push({
                                    _index: idx,
                                    _source: item
                                });
                            }
                        });
                    }
                });

                const endTime = performance.now();
                const duration = (endTime - startTime).toFixed(1);

                $metrics.html(`Tìm thấy <strong>${results.length}</strong> kết quả trong <strong>${duration}ms</strong>`);

                if (results.length === 0) {
                    $resultsList.html(`
                        <div class="text-center py-5 text-muted border rounded bg-white" style="border-radius: 8px;">
                            <i class="fas fa-search-minus fs-1 mb-3 text-secondary" style="opacity: 0.5;"></i>
                            <p class="mb-0">Không tìm thấy kết quả nào phù hợp với từ khóa <strong>"${query}"</strong>.</p>
                            <span class="small text-muted">Vui lòng thử từ khóa khác hoặc chọn Index khác.</span>
                        </div>
                    `);
                    return;
                }

                renderResults(results, $resultsList);
            }, 300);
        } else {
            const host = window.location.hostname;
            const esPort = "9200";
            const esUrl = `http://${host}:${esPort}/${selectedIndex === '_all' ? '*' : selectedIndex}/_search`;
            
            const dslQuery = query 
                ? {
                    query: {
                        multi_match: {
                            query: query,
                            fields: ["*"],
                            fuzziness: "AUTO"
                        }
                    },
                    size: 50
                  }
                : {
                    query: {
                        match_all: {}
                    },
                    size: 50
                  };

            $.ajax({
                url: esUrl,
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(dslQuery),
                headers: {
                    "Authorization": "Basic " + btoa("elastic:thanhtinh@Pass123")
                },
                success: function(response) {
                    const endTime = performance.now();
                    const duration = (endTime - startTime).toFixed(1);
                    
                    const hits = response.hits ? response.hits.hits : [];
                    $metrics.html(`Tìm thấy <strong>${hits.length}</strong> kết quả thực tế trong <strong>${duration}ms</strong>`);

                    if (hits.length === 0) {
                        $resultsList.html(`
                            <div class="text-center py-5 text-muted border rounded bg-white" style="border-radius: 8px;">
                                <i class="fas fa-search-minus fs-1 mb-3 text-secondary" style="opacity: 0.5;"></i>
                                <p class="mb-0">Không tìm thấy tài liệu thực tế nào phù hợp trong Elasticsearch.</p>
                                <span class="small text-muted">Dữ liệu từ Spark có thể chưa được đồng bộ vào Index này. Hãy đồng bộ bằng Spark.</span>
                            </div>
                        `);
                        return;
                    }

                    renderResults(hits, $resultsList);
                },
                error: function(xhr, status, error) {
                    const endTime = performance.now();
                    const duration = (endTime - startTime).toFixed(1);
                    $metrics.html(`<span class="text-danger">Lỗi kết nối</span>`);

                    $resultsList.html(`
                        <div class="alert alert-danger border-0 p-4" style="border-radius: 12px;">
                            <h5 class="alert-heading fw-bold mb-3"><i class="fas fa-exclamation-triangle me-2"></i> Lỗi kết nối trực tiếp đến Elasticsearch (CORS / Network)</h5>
                            <p class="mb-2">Hệ thống ghi nhận lỗi kết nối đến API Elasticsearch tại địa chỉ: <code>http://${host}:${esPort}</code></p>
                            <hr class="my-3">
                            <h6 class="fw-bold mb-2">Nguyên nhân có thể bao gồm:</h6>
                            <ul class="small mb-3">
                                <li><strong>Chưa bật CORS trên Elasticsearch:</strong> Elasticsearch 8 mặc định chặn yêu cầu HTTP trực tiếp từ các cổng/domain khác chạy trên trình duyệt (CORS policy).</li>
                                <li><strong>Cổng 9200 bị chặn:</strong> Firewall VPS hoặc dịch vụ Elasticsearch chưa mở cổng kết nối cho IP công cộng của bạn.</li>
                            </ul>
                            <h6 class="fw-bold mb-2">Giải pháp xử lý nhanh:</h6>
                            <ol class="small mb-0">
                                <li><strong>Sử dụng Demo Mode:</strong> Bật nút switch <em>"Chế độ Demo / Mock Search"</em> ở trên để chạy giả lập tìm kiếm dữ liệu mẫu vô cùng mượt mà.</li>
                                <li><strong>Sử dụng Kibana:</strong> Click nút <strong>"Truy cập Kibana UI"</strong> ở góc phải. Kibana được định tuyến an toàn qua reverse proxy Caddy (không lo lỗi CORS) giúp bạn tìm kiếm, truy vấn đầy đủ mọi index.</li>
                            </ol>
                        </div>
                    `);
                }
            });
        }
    }

    function renderResults(hits, $container) {
        $container.empty();

        hits.forEach(hit => {
            const index = hit._index;
            const source = hit._source;
            let cardHtml = '';

            if (index === 'idx_benh_nhan') {
                cardHtml = `
                    <div class="card border-0 shadow-sm bg-white" style="border-left: 4px solid #0d6efd; border-radius: 8px;">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <span class="badge bg-primary-subtle text-primary mb-1 small">Bệnh nhân</span>
                                    <h6 class="fw-bold text-dark mb-0">${source.ten_benh_nhan}</h6>
                                </div>
                                <span class="badge bg-secondary-subtle text-secondary font-monospace small">${source.ma_nb}</span>
                            </div>
                            <div class="row g-2 small text-secondary">
                                <div class="col-md-3"><strong>Ngày sinh:</strong> ${source.ngay_sinh}</div>
                                <div class="col-md-3"><strong>Giới tính:</strong> ${source.gioi_tinh}</div>
                                <div class="col-md-3"><strong>Nhóm máu:</strong> <span class="badge bg-danger-subtle text-danger">${source.nhom_mau || 'O+'}</span></div>
                                <div class="col-md-3"><strong>SĐT:</strong> ${source.so_dien_thoai}</div>
                                <div class="col-12 mt-1.5"><strong>Địa chỉ:</strong> ${source.dia_chi}</div>
                                ${source.tien_su_benh ? `<div class="col-12 mt-1.5 text-danger small"><i class="fas fa-heartbeat me-1"></i> <strong>Tiền sử:</strong> ${source.tien_su_benh}</div>` : ''}
                            </div>
                        </div>
                    </div>
                `;
            } else if (index === 'idx_dich_vu') {
                cardHtml = `
                    <div class="card border-0 shadow-sm bg-white" style="border-left: 4px solid #ffc107; border-radius: 8px;">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <span class="badge bg-warning-subtle text-warning mb-1 small" style="color: #664d03 !important;">Dịch vụ</span>
                                    <h6 class="fw-bold text-dark mb-0">${source.ten_dichvu}</h6>
                                </div>
                                <span class="badge bg-secondary-subtle text-secondary font-monospace small">${source.code_dichvu}</span>
                            </div>
                            <div class="row g-2 small text-secondary">
                                <div class="col-md-4"><strong>Phân loại:</strong> ${source.loai_dichvu}</div>
                                <div class="col-md-4"><strong>Khoa phụ trách:</strong> ${source.khoa_thuc_hien}</div>
                                <div class="col-md-4"><strong>Trả kết quả:</strong> ${source.thoi_gian_co_kq || 'Tức thời'}</div>
                                <div class="col-12 mt-2"><h6 class="fw-bold text-success mb-0"><i class="fas fa-tags me-1"></i>Đơn giá: ${source.don_gia}</h6></div>
                            </div>
                        </div>
                    </div>
                `;
            } else if (index === 'idx_dot_dieu_tri') {
                cardHtml = `
                    <div class="card border-0 shadow-sm bg-white" style="border-left: 4px solid #198754; border-radius: 8px;">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <span class="badge bg-success-subtle text-success mb-1 small">Đợt Điều trị</span>
                                    <h6 class="fw-bold text-dark mb-0">${source.ten_benh_nhan || 'Hồ sơ bệnh án'}</h6>
                                </div>
                                <span class="badge bg-secondary-subtle text-secondary font-monospace small">${source.ma_benh_an}</span>
                            </div>
                            <div class="row g-2 small text-secondary">
                                <div class="col-md-4"><strong>Mã bệnh nhân:</strong> ${source.ma_nb}</div>
                                <div class="col-md-4"><strong>Khoa điều trị:</strong> ${source.khoa_dieu_tri}</div>
                                <div class="col-md-4"><strong>Bác sĩ phụ trách:</strong> ${source.bac_si_dieu_tri}</div>
                                <div class="col-md-6"><strong>Ngày nhập viện:</strong> ${source.ngay_vao}</div>
                                <div class="col-md-6"><strong>Ngày xuất viện:</strong> <span class="badge ${source.ngay_ra === 'Đang điều trị' ? 'bg-success text-white' : 'bg-secondary-subtle text-dark'}">${source.ngay_ra}</span></div>
                                <div class="col-12 mt-1.5 text-dark fw-bold"><strong>Chẩn đoán bệnh chính:</strong> ${source.chan_doan}</div>
                                <div class="col-12 mt-1 text-muted small"><i class="fas fa-notes-medical me-1"></i><strong>Tình trạng lâm sàng:</strong> ${source.tinh_trang}</div>
                            </div>
                        </div>
                    </div>
                `;
            } else if (index === 'idx_nhan_vien') {
                cardHtml = `
                    <div class="card border-0 shadow-sm bg-white" style="border-left: 4px solid #0dcaf0; border-radius: 8px;">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <span class="badge bg-info-subtle text-info mb-1 small" style="color: #055160 !important;">Nhân viên y tế</span>
                                    <h6 class="fw-bold text-dark mb-0">${source.ten_nhan_vien}</h6>
                                </div>
                                <span class="badge bg-secondary-subtle text-secondary font-monospace small">${source.code_nhan_vien}</span>
                            </div>
                            <div class="row g-2 small text-secondary">
                                <div class="col-md-6"><strong>Trình độ / Học vị:</strong> ${source.hoc_vi || 'Đại học'}</div>
                                <div class="col-md-6"><strong>Chức vụ đảm nhiệm:</strong> ${source.chuc_vu}</div>
                                <div class="col-md-6"><strong>Khoa công tác:</strong> ${source.khoa_phong}</div>
                                <div class="col-md-6"><strong>Điện thoại:</strong> ${source.so_dien_thoai}</div>
                                <div class="col-12 mt-1.5"><strong>Email làm việc:</strong> ${source.email}</div>
                            </div>
                        </div>
                    </div>
                `;
            } else {
                cardHtml = `
                    <div class="card border-0 shadow-sm bg-white" style="border-left: 4px solid #6c757d; border-radius: 8px;">
                        <div class="card-body p-3">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <div>
                                    <span class="badge bg-secondary-subtle text-secondary mb-1 small">${index}</span>
                                    <h6 class="fw-bold text-dark mb-0">Tài liệu ID: ${hit._id}</h6>
                                </div>
                            </div>
                            <pre class="bg-light rounded p-2 small mb-0 font-monospace" style="max-height: 150px; overflow: auto;">${JSON.stringify(source, null, 2)}</pre>
                        </div>
                    </div>
                `;
            }

            $container.append(cardHtml);
        });
    }

    // Login Success Notification
    if (!sessionStorage.getItem('login_notified')) {
        Swal.fire({
            title: 'Welcome Back!',
            text: 'You have successfully logged into the BI Portal.',
            icon: 'success',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true,
            background: '#1a1a1a',
            color: '#fff'
        });
        sessionStorage.setItem('login_notified', 'true');
    }

    // Toggle Sidebar
    $("#menu-toggle").click(function(e) {
        e.preventDefault();
        $("body").toggleClass("sb-sidenav-toggled");
    });
});
