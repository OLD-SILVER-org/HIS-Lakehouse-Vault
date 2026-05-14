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
