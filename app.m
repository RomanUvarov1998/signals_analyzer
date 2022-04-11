clearvars;
% close all;
clc;
    
global  Signals Power_spans_inds Td Selected_time_span
Signals = [];
Power_spans_inds = [];
Td = [];
Selected_time_span = [];

%--------------------------- Main figure --------------------------

global  Load_btn Load_btn_get_pos ...
        RG_ECG_axes RG_ECG_get_pos ...
        RG_ABP_axes RG_ABP_get_pos ...
        POWER_axes POWER_get_pos
    
f = figure(1); clf;
f.SizeChangedFcn = @on_main_figure_size_changed;

DX = 40;
DY = 60;

fw = f.Position(3);
fh = f.Position(4);

Load_btn_get_pos = @(fw, fh) [ ...
    DX,         fh - 40, ...
    80,  40 ...
];
Load_btn = uicontrol('Style','PushButton', ...
        'Units','pixels',...
        'String','Загрузить');
Load_btn.Position = Load_btn_get_pos(fw, fh);
Load_btn.Callback = @on_load_btn_click;


RG_ECG_get_pos = @(fw, fh) [ ...
        DX,         DY*3 + (fh - DY*4) / 3 * 2, ...
        fw - DX*2,  (fh - DY*4) / 3 ...
    ];
RG_ECG_axes = axes('Units', 'pixels',...
        'Position', RG_ECG_get_pos(fw, fh));
title('Ритмограмма ЭКГ');
xlabel('Время, с');
ylabel('Длительность, с');

RG_ABP_get_pos = @(fw, fh) [ ...
        DX,         DY*2 + (fh - DY*4) / 3 * 1, ...
        fw - DX*2,  (fh - DY*4) / 3 ...
    ];
RG_ABP_axes = axes('Units', 'pixels',...
        'Position', RG_ABP_get_pos(fw, fh));
title('Ритмограмма АД');
xlabel('Время, с');
ylabel('Длительность, с');

POWER_get_pos = @(fw, fh) [ ...
        DX,         DY*1 + (fh - DY*4) / 3 * 0, ...
        fw - DX*2,  (fh - DY*4) / 3 ...
    ];
POWER_axes = axes('Units', 'pixels',...
        'Position', POWER_get_pos(fw, fh));
POWER_axes.ButtonDownFcn = @POWER_axes_click;
title('Нагрузка');
xlabel('Время, с');
ylabel('Мощность, Вт');

%--------------------------- Additional figure --------------------------

global  RRScatter_settings RRScatter_settings_get_pos ...
        rb_RR_100 rb_RR_95 ...
        RRpsd_axes RRpsd_axes_get_pos ...
        RRscatter RRscatter_get_pos ...
        SSScatter_settings SSScatter_settings_get_pos ...
        rb_SS_100 rb_SS_95 ...
        SSpsd_axes SSpsd_axes_get_pos ...
        SSscatter SSscatter_get_pos ...
        EllipseTable EllipseTable_get_pos ...
        CPSD_axes CPSD_axes_get_pos

f2 = figure(2); clf;
f2.SizeChangedFcn = @on_additional_figure_size_changed;
SETTINGS_WIDTH = 130;

RRScatter_settings_get_pos = @(fw, fh) [ ...
        DX,             DY*3 + (fh - DY*4) / 3 * 2, ...
        SETTINGS_WIDTH,  (fh - DY*4) / 3 ...
    ];
RRScatter_settings = uipanel( ...
    'Units','pixels',...
    'Position', RRScatter_settings_get_pos(fw, fh), ...
    'BackGroundColor', [0.93 0.93 0.93]);

bg = uibuttongroup(RRScatter_settings, ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.05*2+0.75/2, 0.9, 0.75/2], ...
    'SelectionChangedFcn', @(s, e) count_for_selected_span());
rb_RR_100 = uicontrol(bg, ...
    'Enable', 'off', ...
    'Value', 1, ...
    'Style', 'radiobutton',...
    'String', '100% точек',...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 0.5],...
    'HandleVisibility', 'on');
rb_RR_95 = uicontrol(bg, ...
    'Enable', 'off', ...
    'Value', 0, ...
    'Style', 'radiobutton',...
    'String', '95% точек',...
    'Units', 'normalized', ...
    'Position', [0, 0.5, 1, 0.5],...
    'HandleVisibility', 'off');

RRscatter_get_pos = @(fw, fh) [ ...
        DX + SETTINGS_WIDTH + DX,	...
        fh - DY - (fh - DY*4)/3 ...
        (fh - DY*4)/3, ... %(fw - DX*5)/4, ...
        (fh - DY*4)/3 ...
    ];
RRscatter = axes('Units', 'pixels',...
        'Position', RRscatter_get_pos(fw, fh), ...
        'DataAspectRatio', [1, 1, 1]);
title('Скаттерограмма ритмограммы ЭКГ');
xlabel('RR_i, мВ');
ylabel('RR_i-1, мВ');

RRpsd_axes_get_pos = @(fw, fh) [ ...
        DX + SETTINGS_WIDTH + DX + (fw - DX*5)/4 + DX,	...
        fh - DY - (fh - DY*4)/3 ...
        fw - DX*4 - (fw - DX*5)/4 - SETTINGS_WIDTH, ...
        (fh - DY*4) / 3 ...
    ];
RRpsd_axes = axes('Units', 'pixels',...
        'Position', RRpsd_axes_get_pos(fw, fh));
title('Спектр Уэлча ритмограммы ЭКГ');
xlabel('Частота, Гц');
ylabel('Оценка СПМ, мВ^2');


SSScatter_settings_get_pos = @(fw, fh) [ ...
        DX, ...
        DY*2 + (fh - DY*4) / 3 * 1, ...
        SETTINGS_WIDTH, ...
        (fh - DY*4) / 3 ...
    ];
SSScatter_settings = uipanel( ...
    'Units','pixels',...
    'Position', SSScatter_settings_get_pos(fw, fh), ...
    'BackGroundColor',[0.93 0.93 0.93]);

bg = uibuttongroup(SSScatter_settings, ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.05*2+0.75/2, 0.9, 0.75/2], ...
    'SelectionChangedFcn', @(s, e) count_for_selected_span());
rb_SS_100 = uicontrol(bg, ...
    'Enable', 'off', ...
    'Value', 1, ...
    'Style', 'radiobutton',...
    'String', '100% точек',...
    'Units', 'normalized', ...
    'Position', [0, 0, 1, 0.5],...
    'HandleVisibility', 'on');
rb_SS_95 = uicontrol(bg, ...
    'Enable', 'off', ...
    'Value', 0, ...
    'Style', 'radiobutton',...
    'String', '95% точек',...
    'Units', 'normalized', ...
    'Position', [0, 0.5, 1, 0.5],...
    'HandleVisibility', 'off');

SSscatter_get_pos = @(fw, fh) [ ...
        DX + SETTINGS_WIDTH + DX,	...
        DY*2 + (fh - DY*4)/3 * 1, ...
        (fh - DY*4)/3, ... %(fw - DX*5)/4, ...
        (fh - DY*4) / 3 ...
    ];
SSscatter = axes('Units', 'pixels',...
        'Position', SSscatter_get_pos(fw, fh), ...
        'DataAspectRatio', [1, 1, 1]);
title('Скаттерограмма ритмограммы АД');
xlabel('SS_i, мВ');
ylabel('SS_i-1, мВ');

SSpsd_axes_get_pos = @(fw, fh) [ ...
        DX + SETTINGS_WIDTH + DX + (fw - DX*5)/4 + DX,	...
        DY*2 + (fh - DY*4) / 3 * 1, ...
        fw - DX*4 - (fw - DX*5)/4 - SETTINGS_WIDTH, ...
        (fh - DY*4) / 3 ...
    ];
SSpsd_axes = axes('Units', 'pixels',...
        'Position', SSpsd_axes_get_pos(fw, fh));
title('Спектр Уэлча ритмограммы АД');
xlabel('Частота, Гц');
ylabel('Оценка СПМ, мВ^2');


EllipseTable_get_pos = @(fw, fh) [ ...
        DX,	...
		DY*1 + (fh - DY*4) / 3 * 0, ...
        SETTINGS_WIDTH + DX + (fw - DX*5)/4, ...
		(fh - DY*4) / 3 ...
    ];
EllipseTable = uitable('Units', 'pixels',...
        'Position', EllipseTable_get_pos(fw, fh));
EllipseTable.ColumnEditable = false;
EllipseTable.ColumnName = { 'ЭКГ', 'АД' };
EllipseTable.RowName = [ ...
    "Длина облака, с"; ...
    "Ширина облака, с"; ...
    "Площадь облака, с"; ...
    "Мср, с";
    "RR(SS)_min, с"; ...
    "RR(SS)_max, с"; ...
    "Размах RR(SS), с"; ...
    "Mo, с" ...
];
EllipseTable.ColumnWidth = 'fit';

CPSD_axes_get_pos = @(fw, fh) [ ...
        DX + SETTINGS_WIDTH + DX + (fw - DX*5)/4 + DX,	...
        DY*1 + (fh - DY*4) / 3 * 0, ...
        fw - DX*4 - (fw - DX*5)/4 - SETTINGS_WIDTH, ...
        (fh - DY*4) / 3 ...
    ];
CPSD_axes = axes('Units', 'pixels',...
        'Position', CPSD_axes_get_pos(fw, fh));
title('Кросс-СПМ ритмограмм АД и ЭКГ');
xlabel('Частота, Гц');
ylabel('Оценка СПМ, мВ^2');

global drag_point_RR_a drag_point_RR_b drag_point_RR_center

axes(RRscatter); hold on; grid on;
drag_point_RR_a = DragPoint(0.5, 0.5, RRscatter, f2, @on_point_drag_RR);
drag_point_RR_b = DragPoint(0.5, 0.6, RRscatter, f2, @on_point_drag_RR);
drag_point_RR_center = DragPoint(0.5, 0.7, RRscatter, f2, @on_point_drag_RR);

f2.WindowButtonMotionFcn = @on_f2_mouse_moution;
f2.WindowButtonDownFcn = @on_f2_mouse_down;
f2.WindowButtonUpFcn = @on_f2_mouse_up;

global h_RR_a h_RR_b h_RR_ellipse
h_RR_a = -1;
h_RR_b = -1;
h_RR_ellipse = -1;

%--------------------------- Main figure callbacks ----------------------

function on_f2_mouse_moution(~, ~)
    global drag_point_RR_a drag_point_RR_b drag_point_RR_center
    drag_point_RR_a = drag_point_RR_a.OnMouseMove();
    drag_point_RR_b = drag_point_RR_b.OnMouseMove();
    drag_point_RR_center = drag_point_RR_center.OnMouseMove();
    on_point_drag_RR();
    drag_point_RR_a = drag_point_RR_a.UpdateOldPos();
    drag_point_RR_b = drag_point_RR_b.UpdateOldPos();
    drag_point_RR_center = drag_point_RR_center.UpdateOldPos();
end

function on_f2_mouse_down(~, ~)
    global drag_point_RR_a drag_point_RR_b drag_point_RR_center
    
    drag_point_RR_a = drag_point_RR_a.OnMouseDown();
    if drag_point_RR_a.IsDragged(), return; end
    
    drag_point_RR_b = drag_point_RR_b.OnMouseDown();
    if drag_point_RR_b.IsDragged(), return; end
    
    drag_point_RR_center = drag_point_RR_center.OnMouseDown();
    if drag_point_RR_center.IsDragged(), return; end
end

function on_f2_mouse_up(~, ~)
    global drag_point_RR_a drag_point_RR_b drag_point_RR_center
    drag_point_RR_a = drag_point_RR_a.OnMouseUp();
    drag_point_RR_b = drag_point_RR_b.OnMouseUp();
    drag_point_RR_center = drag_point_RR_center.OnMouseUp();
end

function on_point_drag_RR()
    global drag_point_RR_a drag_point_RR_b drag_point_RR_center
    global h_RR_a h_RR_b h_RR_ellipse
    
    if ~ishandle(h_RR_a) || ~ishandle(h_RR_b) || ~ishandle(h_RR_ellipse)
        return
    end
    
    if drag_point_RR_a.IsDragged()
        d = (drag_point_RR_a.X + drag_point_RR_a.Y) / 2;
        drag_point_RR_a = drag_point_RR_a.SetPos(d, d);
        
        pa = [drag_point_RR_a.X; drag_point_RR_a.Y];
        pc = [drag_point_RR_center.X; drag_point_RR_center.Y];
        a_pts = [pa, pc + (pc - pa)];  
        h_RR_a.XData = a_pts(1, :);
        h_RR_a.YData = a_pts(2, :);
        
        disp('a');
    elseif drag_point_RR_b.IsDragged()
        db_len = [-1 / sqrt(2); 1 / sqrt(2)]' * [drag_point_RR_b.X; drag_point_RR_b.Y];
        db_x_y = sqrt(db_len^2 / 2);
        db = [-db_x_y; db_x_y];
        
        pc = [drag_point_RR_center.X; drag_point_RR_center.Y];
        pb = pc + db;
        drag_point_RR_b = drag_point_RR_b.SetPos(pb(1), pb(2));
        
        b_pts = [pb, pc + (pc - pb)]; 
        h_RR_b.XData = b_pts(1, :);
        h_RR_b.YData = b_pts(2, :);
        
        disp('b');
    elseif drag_point_RR_center.IsDragged()
        pc = [drag_point_RR_center.X; drag_point_RR_center.Y];
        
        dc_len = [1 / sqrt(2); 1 / sqrt(2)]' * pc;
        dc_x_y = sqrt(dc_len^2 / 2);
        pc_next = [dc_x_y; dc_x_y];
        
        delta_pc = pc_next - [drag_point_RR_center.OldX; drag_point_RR_center.OldY];
        
        drag_point_RR_a = drag_point_RR_a.SetPos( ...
            drag_point_RR_a.OldX + delta_pc(1), ...
            drag_point_RR_a.OldY + delta_pc(2));
        drag_point_RR_b = drag_point_RR_b.SetPos( ...
            drag_point_RR_b.OldX + delta_pc(1), ...
            drag_point_RR_b.OldY + delta_pc(2));
        drag_point_RR_center = drag_point_RR_center.SetPos(pc_next(1), pc_next(2));
        
        h_RR_a.XData = h_RR_a.XData + delta_pc(1);
        h_RR_a.YData = h_RR_a.YData + delta_pc(2);
        
        h_RR_b.XData = h_RR_b.XData + delta_pc(1);
        h_RR_b.YData = h_RR_b.YData + delta_pc(2);
        
        drag_point_RR_a = drag_point_RR_a.MoveToPos();
        drag_point_RR_b = drag_point_RR_b.MoveToPos();
        
        disp('c');
    else
        return;
    end
    
    pa = [drag_point_RR_a.X; drag_point_RR_a.Y];
    pb = [drag_point_RR_b.X; drag_point_RR_b.Y];
    pc = [drag_point_RR_center.X; drag_point_RR_center.Y];
    
    a = sqrt(sum((pa - pc) .^ 2));
    b = sqrt(sum((pb - pc) .^ 2));
    
    el_x = linspace(-a, a, 1000);
    el_y = b .* (1 - (el_x ./ a) .^ 2) .^ 0.5;
    
    el_x = [el_x, flip(el_x)];
    el_y = [el_y, -flip(el_y)];
    
    theta = 45;
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    
    el_pts = [el_x; el_y];
    el_pts = R * el_pts + pc;
    h_RR_ellipse.XData = el_pts(1, :);
    h_RR_ellipse.YData = el_pts(2, :);
    
    global EllipseTable
    Data = EllipseTable.Data;
    
    Data{1,1} = a * 2; % ell_len
    Data{2,1} = b * 2; % ell_wid
    Data{3,1} = pi * a * b; % square
    
    EllipseTable.Data = Data;
end

function on_main_figure_size_changed(s, ~)
    global  Load_btn Load_btn_get_pos ...
            RG_ECG_axes RG_ECG_get_pos ...
            RG_ABP_axes RG_ABP_get_pos ...
            POWER_axes POWER_get_pos
    
    f = s;
        
    fw = f.Position(3);
    fh = f.Position(4);
    
    Load_btn.Position = Load_btn_get_pos(fw, fh);
    RG_ECG_axes.Position = RG_ECG_get_pos(fw, fh);
    RG_ABP_axes.Position = RG_ABP_get_pos(fw, fh);
    POWER_axes.Position = POWER_get_pos(fw, fh);
end

function on_load_btn_click(~, ~)
    global Signals Power_spans_inds Td
    
%     [filename, pathname]= uigetfile({'*.csv','CSV files (*.csv)'}, 'Выберите файл');
% 
%     if isfloat(filename) || isfloat(pathname)
%         return
%     end
% 
%     path = [pathname, filename];
    
    path = 'C:\Users\Роман\Dropbox\_Мага 1\Сем 4\Халтура\Ангелина\task_3\Experimental_Data\Обструкция\Хорионовская_15-03-18(17-01-58)_All.csv';

    Signals = read_file(path);
    
    Td = (Signals.Time(2) - Signals.Time(1));
    
    Power_spans_inds = find_power_spans(Td, Signals.Power);
    
    draw_ritmograms_and_power(0);
end

function draw_ritmograms_and_power(selected_t_span_ind)
    global Signals Power_spans_inds RG_ECG_axes RG_ABP_axes POWER_axes

    [RRx, RRy, SSx, SSy] = calc_ritmogramms(Signals);

    axes(RG_ECG_axes); cla; hold on; grid on;
    stem(RRx, RRy);

    axes(RG_ABP_axes); cla; hold on; grid on;
    stem(SSx, SSy);

    axes(POWER_axes); cla reset; hold on; grid on;
    h = plot(Signals.Time, Signals.Power);
    h.HitTest = 'off';
    
    for span_ind = 1 : size(Power_spans_inds, 1)
        span_t_inds = Power_spans_inds(span_ind, :);
        t1 = Signals.Time(span_t_inds(1));
        t2 = Signals.Time(span_t_inds(2));
        
        if span_ind == selected_t_span_ind
            span_FaceColor = [1, 1, 0, 0.2];
        else
            span_FaceColor = [0, 1, 0, 0.2];
        end
        
        h = rectangle('Position', [t1, min(Signals.Power), t2 - t1, max(Signals.Power)], ...
                'Curvature', 0, ...
                'FaceColor', span_FaceColor, ...
                'EdgeColor', [0, 1, 0, 1]);
        h.HitTest = 'off';
        
        clear t1 t2 span_FaceColor
    end
    
    POWER_axes.ButtonDownFcn = @POWER_axes_click;
end

function POWER_axes_click(~, e)
    global Signals POWER_axes Power_spans_inds Td Selected_time_span
    
    if ~exist('Signals', 'var') || isempty(Signals)
        return;
    end
    
    axes(POWER_axes);
    
    x = num2ruler(e.IntersectionPoint(1), POWER_axes.XAxis);
    
    time_ind = round(x / Td);
    
    Selected_time_span = [];
    
    for span_ind = 1 : size(Power_spans_inds, 1)
        n_begin = Power_spans_inds(span_ind, 1);
        n_end = Power_spans_inds(span_ind, 2);
        if n_begin <= time_ind && time_ind <= n_end
            Selected_time_span = [Signals.Time(n_begin), Signals.Time(n_end)];
            draw_ritmograms_and_power(span_ind);
            break;
        end
    end
    
    count_for_selected_span();
end

function count_for_selected_span()
    global  drag_point_RR_a drag_point_RR_b drag_point_RR_center ...
            h_RR_a h_RR_b h_RR_ellipse ...
            rb_RR_100 rb_RR_95 rb_SS_100 rb_SS_95 ...
            Signals ...
            Selected_time_span ...
            RRscatter SSscatter ...
            RRpsd_axes SSpsd_axes CPSD_axes ...
            EllipseTable 
    
    if isempty(Selected_time_span)
        return;
    end
    
    rb_RR_100.Enable = 'on';
    rb_RR_95.Enable = 'on';
    rb_SS_100.Enable = 'on';
    rb_SS_95.Enable = 'on';
    
    if rb_RR_100.Value == 1
        dots_percentage_RR = 1.00;
    elseif rb_RR_95.Value == 1
        dots_percentage_RR = 0.95;
    else
        assert(false);
    end
    
    if rb_SS_100.Value == 1
        dots_percentage_SS = 1.00;
    elseif rb_SS_95.Value == 1
        dots_percentage_SS = 0.95;
    else
        assert(false);
    end
    
    t = Signals.Time;
    
    t_span = t(t >= Selected_time_span(1) & t <= Selected_time_span(2));
    
    [RRx, RRy, SSx, SSy] = calc_ritmogramms(Signals, t_span);
    
    [RRpsd_f, RRpsd, SSpsd_f, SSpsd, CPSD, CPSD_f] = calc_psd_welch_an_cpsd( ...
        t_span, RRx, RRy, SSx, SSy);
    
    axes(RRpsd_axes); cla; hold on; grid on;
    plot(RRpsd_f, RRpsd);
    
    axes(SSpsd_axes); cla; hold on; grid on;
    plot(SSpsd_f, SSpsd);
    
    axes(CPSD_axes); cla; hold on; grid on;
    plot(CPSD_f, CPSD);
    
    axes(RRscatter); cla; hold on; grid on;
    [sc_x, sc_y, el_x, el_y, el_params_RR, ax, ay, bx, by, x0, y0] = calc_scatter_ellipse(RRy, dots_percentage_RR);
    plot(sc_x, sc_y, '*b');
    h_RR_a = plot(ax, ay, 'c', 'LineWidth', 2);
    h_RR_b = plot(bx, by, 'm', 'LineWidth', 2);
    h_RR_ellipse = plot(el_x, el_y, 'r', 'LineWidth', 2);
    
    drag_point_RR_a = drag_point_RR_a.Draw(ax(end), ay(end));
    drag_point_RR_b = drag_point_RR_b.Draw(bx(end), by(end));
    drag_point_RR_center = drag_point_RR_center.Draw(x0, y0);    
    
    range_x = max(sc_x) - min(sc_x);
    range_y = max(sc_y) - min(sc_y);
    range = max(range_x, range_y);
    
    xlim([min(sc_x) - range * 0.4, min(sc_x) + range * 1.4]);
    ylim([min(sc_y) - range * 0.4, min(sc_y) + range * 1.4]);
    
    axes(SSscatter); cla; hold on; grid on;
    [sc_x, sc_y, el_x, el_y, el_params_SS, ax, ay, bx, by] = calc_scatter_ellipse(SSy, dots_percentage_SS);
    plot(sc_x, sc_y, '*b');
    plot(ax, ay, 'c', 'LineWidth', 2);
    plot(bx, by, 'm', 'LineWidth', 2);
    plot(el_x, el_y, 'r', 'LineWidth', 2);
    
    range_x = max(sc_x) - min(sc_x);
    range_y = max(sc_y) - min(sc_y);
    range = max(range_x, range_y);
    
    xlim([min(sc_x) - range * 0.4, min(sc_x) + range * 1.4]);
    ylim([min(sc_y) - range * 0.4, min(sc_y) + range * 1.4]);
    
    EllipseTable.Data = { ...
        el_params_RR.ell_len, 		el_params_SS.ell_len; ...
        el_params_RR.ell_wid, 		el_params_SS.ell_wid; ...
        el_params_RR.square, 		el_params_SS.square; ...
        el_params_RR.m_sr, 			el_params_SS.m_sr; ...
        el_params_RR.interv_min, 	el_params_SS.interv_min; ...
        el_params_RR.interv_max, 	el_params_SS.interv_max; ...
        el_params_RR.interv_range, 	el_params_SS.interv_range; ...
        el_params_RR.mo, 			el_params_SS.mo; ...
    };
end

%--------------------------- Additional figure callbacks ----------------

function on_additional_figure_size_changed(s, ~)
    global  RRScatter_settings RRScatter_settings_get_pos ...
            SSScatter_settings SSScatter_settings_get_pos ...
            RRpsd_axes RRpsd_axes_get_pos ...
            SSpsd_axes SSpsd_axes_get_pos ...
            RRscatter RRscatter_get_pos ...
            SSscatter SSscatter_get_pos ... 
            EllipseTable EllipseTable_get_pos ...
            CPSD_axes CPSD_axes_get_pos
    
    f = s;
        
    fw = f.Position(3);
    fh = f.Position(4);
    
    RRScatter_settings.Position = RRScatter_settings_get_pos(fw, fh);
    RRscatter.Position = RRscatter_get_pos(fw, fh);
    RRpsd_axes.Position = RRpsd_axes_get_pos(fw, fh);
    
    SSScatter_settings.Position = SSScatter_settings_get_pos(fw, fh);
    SSscatter.Position = SSscatter_get_pos(fw, fh);
    SSpsd_axes.Position = SSpsd_axes_get_pos(fw, fh);
    
    EllipseTable.Position = EllipseTable_get_pos(fw, fh);
    CPSD_axes.Position = CPSD_axes_get_pos(fw, fh);
end
