classdef Viewer < handle
    %VIEVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        f
    end
    properties (Access = private)
        Signals, Power_spans_inds, Td, Selected_time_span, RR_max_diff, SS_max_diff,
        RG_ECG_axes, RG_ECG_get_pos,
        RG_ABP_axes, RG_ABP_get_pos,
        POWER_axes, POWER_get_pos,
        tg, tg_get_pos,
        RRScatter_settings, RRScatter_settings_get_pos,
        text_max_diff_RR,  edit_max_diff_RR,
        RRrg_axes, RRrg_axes_get_pos, 
        RRpsd_axes, RRpsd_axes_get_pos, 
        RRscatter, RRscatter_get_pos, 
        SSScatter_settings, SSScatter_settings_get_pos, 
        text_max_diff_SS, edit_max_diff_SS, 
        SSpsd_axes, SSpsd_axes_get_pos, 
        SSscatter, SSscatter_get_pos, 
        EllipseTable, EllipseTable_get_pos, 
        CPSD_axes, CPSD_axes_get_pos, 
        SSrg_axes, SSrg_axes_get_pos, 
        PSDTable, PSDTable_get_pos, 
        PSD_axes_VLF, PSD_axes_get_pos_VLF, 
        PSD_axes_LF, PSD_axes_get_pos_LF, 
        PSD_axes_HF, PSD_axes_get_pos_HF, 
        Ellipses_plots_len, Ellipses_plots_len_get_pos,
        Ellipses_plots_wid, Ellipses_plots_wid_get_pos,
        Ellipses_plots_sq, Ellipses_plots_sq_get_pos,
        Ellipses_plots_Mcp, Ellipses_plots_Mcp_get_pos,
        Ellipses_plots_min, Ellipses_plots_min_get_pos,
        Ellipses_plots_max, Ellipses_plots_max_get_pos,
        Ellipses_plots_range, Ellipses_plots_range_get_pos,
        Ellipses_plots_Mo, Ellipses_plots_Mo_get_pos,
        PSD_axes_legend, Ellipses_plots_legend,
        drag_point_RR_a, drag_point_RR_b, drag_point_RR_center,
        drag_point_SS_a, drag_point_SS_b, drag_point_SS_center,
        h_RR_a, h_RR_b, h_RR_ellipse,
        h_SS_a, h_SS_b, h_SS_ellipse,
    end
    
    methods
        function obj = Viewer()
            obj.f = figure;
            obj.f.Name = '';
						
            obj.RR_max_diff = 5;
            obj.SS_max_diff = 5;
            
            % GUI elements
            DX = 40;
            DY = 60;

            fw = obj.f.Position(3);
            fh = obj.f.Position(4);

            obj.tg_get_pos = @(fw, fh) [ ...
                5,         5, ...
                fw-5*2,  fh-5*2 ...
            ];
            obj.tg = uitabgroup(obj.f, 'Units','pixels');
            obj.tg.Position = obj.tg_get_pos(fw, fh);

            tab_main = uitab(obj.tg);
            tab_main.Title = 'Весь сигнал';

            obj.RG_ECG_get_pos = @(fw, fh) [ ...
                    DX,         DY*3 + (fh - DY*4) / 3 * 2, ...
                    fw - DX*2,  (fh - DY*4) / 3 ...
                ];
            obj.RG_ECG_axes = axes(tab_main, 'Units', 'pixels',...
                    'Position', obj.RG_ECG_get_pos(fw, fh));
            title('Ритмограмма ЭКГ');
            xlabel('Время начала, с');
            ylabel('Длительность, с');

            obj.RG_ABP_get_pos = @(fw, fh) [ ...
                    DX,         DY*2 + (fh - DY*4) / 3 * 1, ...
                    fw - DX*2,  (fh - DY*4) / 3 ...
                ];
            obj.RG_ABP_axes = axes(tab_main, 'Units', 'pixels',...
                    'Position', obj.RG_ABP_get_pos(fw, fh));
            title('Интервалы "систола-систола" АД');
            xlabel('Время начала, с');
            ylabel('Длительность, с');

            obj.POWER_get_pos = @(fw, fh) [ ...
                    DX,         DY*1 + (fh - DY*4) / 3 * 0, ...
                    fw - DX*2,  (fh - DY*4) / 3 ...
                ];
            obj.POWER_axes = axes(tab_main, 'Units', 'pixels',...
                    'Position', obj.POWER_get_pos(fw, fh));
            obj.POWER_axes.ButtonDownFcn = @POWER_axes_click;
            title('Нагрузка');
            xlabel('Время, с');
            ylabel('Мощность, Вт');
						
            %--------------------------- 'Скаттерограмма' tab --------------------------

            tab_ellipse = uitab(obj.tg);
            tab_ellipse.Title = 'Скаттерограмма';

            SETTINGS_WIDTH = 130;

            obj.RRScatter_settings_get_pos = @(fw, fh) [ ...
                            DX,             DY*2 + (fh - DY*3) / 2 * 1, ...
                            SETTINGS_WIDTH-30,  (fh - DY*3) / 2 ...
                    ];
            obj.RRScatter_settings = uipanel( ...
                    tab_ellipse, ...
                    'Units','pixels',...
                    'Position', obj.RRScatter_settings_get_pos(fw, fh), ...
                    'BackGroundColor', [0.93 0.93 0.93]);

            bg = uibuttongroup(obj.RRScatter_settings, ...
                    'Units', 'normalized', ...
                    'Position', [0.05, 0.05, 0.9, 0.9]);
            obj.text_max_diff_RR = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Style', 'text',...
                    'String', 'Максимальная разница интервалов, %',...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 0.5],...
                    'HandleVisibility', 'on');
            obj.edit_max_diff_RR = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Style', 'edit',...
                    'String', sprintf('%.1f', obj.RR_max_diff), ...
                    'Units', 'normalized', ...
                    'Position', [0, 0.5, 1, 0.5],...
                    'HandleVisibility', 'off');

            obj.RRscatter_get_pos = @(fw, fh) [ ...
                            DX + SETTINGS_WIDTH + DX,	...
                            fh - DY - (fh - DY*3)/2 ...
                            (fh - DY*3)/2, ... %(fw - DX*5)/4, ...
                            (fh - DY*3)/2 ...
                    ];
            obj.RRscatter = axes( ...
                            tab_ellipse, ...
                            'Units', 'pixels',...
                            'Position', obj.RRscatter_get_pos(fw, fh), ...
                            'DataAspectRatio', [1, 1, 1]);
            title('Скаттерограмма ритмограммы ЭКГ');
            xlabel('RR_i, с');
            ylabel('RR_{i-1}, с');

            obj.RRrg_axes_get_pos = @(fw, fh) [ ...
                            DX + SETTINGS_WIDTH + DX + (fh - DY*3)/2 + DX, ...
                            DY*2 + (fh - DY*3)/2 * 1, ...
                            (fw - DX - SETTINGS_WIDTH - DX - (fh - DY*3)/2 - DX - DX*2) / 2, ...
                            (fh - DY*3) / 2 ...
                    ];
            obj.RRrg_axes = axes( ...
                            tab_ellipse, ...
                            'Units', 'pixels',...
                            'Position', obj.RRrg_axes_get_pos(fw, fh));
            title('Участок ритмограммы ЭКГ');
            xlabel('Время, с');
            ylabel('Длительность, с');

            obj.SSScatter_settings_get_pos = @(fw, fh) [ ...
                            DX, ...
                            DY + (fh - DY*3) / 2 * 0, ...
                            SETTINGS_WIDTH-30, ...
                            (fh - DY*3) / 2 ...
                    ];
            obj.SSScatter_settings = uipanel( ...
                    tab_ellipse, ...
                    'Units','pixels',...
                    'Position', obj.SSScatter_settings_get_pos(fw, fh), ...
                    'BackGroundColor',[0.93 0.93 0.93]);

            bg = uibuttongroup(obj.SSScatter_settings, ...
                    'Units', 'normalized', ...
                    'Position', [0.05, 0.05, 0.9, 0.9]);
            obj.text_max_diff_SS = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Style', 'text',...
                    'String', 'Максимальная разница интервалов, %', ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 0.5],...
                    'HandleVisibility', 'on');
            obj.edit_max_diff_SS = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Value', 0, ...
                    'Style', 'edit',...
                    'String', sprintf('%.1f', obj.SS_max_diff),...
                    'Units', 'normalized', ...
                    'Position', [0, 0.5, 1, 0.5],...
                    'HandleVisibility', 'off');

            obj.SSscatter_get_pos = @(fw, fh) [ ...
                            DX + SETTINGS_WIDTH + DX,	...
                            DY, ...
                            (fh - DY*3) / 2, ... %(fw - DX*5)/4, ...
                            (fh - DY*3) / 2 ...
                    ];
            obj.SSscatter = axes( ...
                            tab_ellipse, ...
                            'Units', 'pixels',...
                            'Position', obj.SSscatter_get_pos(fw, fh), ...
                            'DataAspectRatio', [1, 1, 1]);
            title('Скаттерограмма ритмограммы АД');
            xlabel('SS_i, с');
            ylabel('SS_{i-1}, с');

            % rg
            obj.SSrg_axes_get_pos = @(fw, fh) [ ...
                            DX + SETTINGS_WIDTH + DX + (fh - DY*3)/2 + DX, ...
                            DY + (fh - DY*3)/2 * 0, ...
                            (fw - DX - SETTINGS_WIDTH - DX - (fh - DY*3)/2 - DX - DX*2) / 2, ...
                            (fh - DY*3) / 2 ...
                    ];
            obj.SSrg_axes = axes( ...
                            tab_ellipse, ...
                            'Units', 'pixels',...
                            'Position', obj.SSrg_axes_get_pos(fw, fh));
            title('Участок интервалов "систола-систола" АД');
            xlabel('Время, с');
            ylabel('Давление, мм.рт.ст');


            obj.EllipseTable_get_pos = @(fw, fh) [ ...
                            DX + SETTINGS_WIDTH + DX + (fh - DY*3)/2 + DX + ...
                            (fw - DX - SETTINGS_WIDTH - DX - (fh - DY*3)/2 - DX - DX*2) / 2 + ...
                            DX,	...
                            DY, ...
                            fw - (...
                            DX + SETTINGS_WIDTH + DX + (fh - DY*3)/2 + DX + ...
                            (fw - DX - SETTINGS_WIDTH - DX - (fh - DY*3)/2 - DX - DX*2) / 2 + ...
                            DX) - DX, ...
                            (fh - DY*2) / 1 ...
                    ];
            obj.EllipseTable = uitable( ...
                            tab_ellipse, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.EllipseTable_get_pos(fw, fh));
            obj.EllipseTable.ColumnEditable = false;
            obj.EllipseTable.ColumnName = { 'Величина', 'ЭКГ', 'АД' };
            Data = cell(8, 3);
            Data{1, 1} = 'Длина облака, мс';
            Data{2, 1} = 'Ширина облака, мс';
            Data{3, 1} = 'Площадь облака, мс^2';
            Data{4, 1} = 'Мср, мс';
            Data{5, 1} = 'RR(SS)_min, мс';
            Data{6, 1} = 'RR(SS)_max, мс';
            Data{7, 1} = 'Размах RR(SS), мс';
            Data{8, 1} = 'Mo, мс';
            obj.EllipseTable.Data = Data;
            obj.EllipseTable.ColumnWidth = 'fit';

            %--------------------------- 'Спектры' tab --------------------------

            tab_psd = uitab(obj.tg);
            tab_psd.Title = 'Спектры';

            obj.RRpsd_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*3 + (fh - DY*4)/3 * 2, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*4) / 3 ...
                    ];
            obj.RRpsd_axes = axes( ...
                            tab_psd, ...
                            'Units', 'pixels',...
                            'Position', obj.RRpsd_axes_get_pos(fw, fh));
            title('Ритмограмма участка');
            xlabel('Частота, Гц');
            ylabel('Оценка СПМ, мс^2/Гц');

            obj.SSpsd_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*2 + (fh - DY*4)/3 * 1, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*4) / 3 ...
                    ];
            obj.SSpsd_axes = axes( ...
                            tab_psd, ...
                            'Units', 'pixels',...
                            'Position', obj.SSpsd_axes_get_pos(fw, fh));
            title('Спектр Уэлча интервалов "систола-систола" АД');
            xlabel('Частота, Гц');
            ylabel('Оценка СПМ, мм.рт.ст.^2/Гц');

            obj.CPSD_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*1 + (fh - DY*4)/3 * 0, ....
                            (fw - DX*3) / 2, ...
                            (fh - DY*4) / 3 ...
                    ];
            obj.CPSD_axes = axes( ...
                            tab_psd, ...
                            'Units', 'pixels',...
                            'Position', obj.CPSD_axes_get_pos(fw, fh));
            title('Кросс-СПМ интервалов "систола-систола" АД и ритмограммы ЭКГ');
            xlabel('Частота, Гц');
            ylabel('Оценка');


            obj.PSDTable_get_pos = @(fw, fh) [ ...
                            DX*2 + (fw - DX*3) / 2,	...
                            DY*1 + (fh - DY*4)/3 * 0, ....
                            (fw - DX*3) / 2, ...
                            fh - DY*2 ...
                    ];
            obj.PSDTable = uitable( ...
                            tab_psd, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.PSDTable_get_pos(fw, fh));
            obj.PSDTable.ColumnEditable = false;
            obj.PSDTable.ColumnName = { 'Величина', 'ЭКГ', 'АД' };
            Data = cell(3, 3);
            Data{1, 1} = 'VLF (0,003..0,04 Гц), мс^2';
            Data{2, 1} = 'LF (0,04..0,15 Гц), мс^2';
            Data{3, 1} = 'HF (0,15..0,4 Гц), мс^2';
            obj.PSDTable.Data = Data;
            obj.PSDTable.ColumnWidth = 'fit';

            %--------------------------- 'Графики' tab --------------------------

            tab_plots = uitab(obj.tg);
            tab_plots.Title = 'Графики';

                DX = 40; DY = 60;
                
                % Длина
                obj.Ellipses_plots_len_get_pos = @(fw, fh) [ ...
                            DX*1 + (fw - DX*5) / 4 * 0,	...
                            fh - DY*1 - (fh - DY*4)/3 * 1, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_len = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_len_get_pos(fw, fh));
                title('Характеристики спектров');
                xlabel('Частота, Гц dsfsdf');
                ylabel('Оценка');

                % Ширина
                obj.Ellipses_plots_wid_get_pos = @(fw, fh) [ ...
                            DX*2 + (fw - DX*5) / 4 * 1,	...
                            fh - DY*1 - (fh - DY*4)/3 * 1, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_wid = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_wid_get_pos(fw, fh));
                title('Характеристики спектров');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % Площадь
                obj.Ellipses_plots_sq_get_pos = @(fw, fh) [ ...
                            DX*3 + (fw - DX*5) / 4 * 2,	...
                            fh - DY*1 - (fh - DY*4)/3 * 1, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_sq = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_sq_get_pos(fw, fh));
                title('Характеристики спектров');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % Мср
                obj.Ellipses_plots_Mcp_get_pos = @(fw, fh) [ ...
                            DX*4 + (fw - DX*5) / 4 * 3,	...
                            fh - DY*1 - (fh - DY*4)/3 * 1, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_Mcp = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_Mcp_get_pos(fw, fh));
                title('Характеристики спектров');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % Мин
                obj.Ellipses_plots_min_get_pos = @(fw, fh) [ ...
                            DX*1 + (fw - DX*5) / 4 * 0,	...
                            fh - DY*2 - (fh - DY*4)/3 * 2, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_min = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_min_get_pos(fw, fh));
                title('Характеристики спектров');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % Макс
                obj.Ellipses_plots_max_get_pos = @(fw, fh) [ ...
                            DX*2 + (fw - DX*5) / 4 * 1,	...
                            fh - DY*2 - (fh - DY*4)/3 * 2, ...
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_max = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_max_get_pos(fw, fh));
                title('Характеристики спектров');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % Размах
                obj.Ellipses_plots_range_get_pos = @(fw, fh) [ ...
                            DX*3 + (fw - DX*5) / 4 * 2,	...
                            fh - DY*2 - (fh - DY*4)/3 * 2, ...
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                obj.Ellipses_plots_range = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_range_get_pos(fw, fh));
                title('Размах');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % Мода
                obj.Ellipses_plots_Mo_get_pos = @(fw, fh) [ ...
                            DX*4 + (fw - DX*5) / 4 * 3,	...
                            fh - DY*2 - (fh - DY*4)/3 * 2, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                % Характеристики спектров
                obj.Ellipses_plots_Mo = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_Mo_get_pos(fw, fh));
                title('Мода');
                xlabel('Частота, Гц');
                ylabel('Оценка');
                
                % VLF
                obj.PSD_axes_get_pos_VLF = @(fw, fh) [ ...
                            DX*1 + (fw - DX*5) / 4 * 0,	...
                            fh - DY*3 - (fh - DY*4)/3 * 3, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];
                obj.PSD_axes_VLF = axes( ...
                                tab_plots, ...
                                'Units', 'pixels',...
                                'Position', obj.PSD_axes_get_pos_VLF(fw, fh));
                title('VLF');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % LF
                obj.PSD_axes_get_pos_LF = @(fw, fh) [ ...
                            DX*2 + (fw - DX*5) / 4 * 1,	...
                            fh - DY*3 - (fh - DY*4)/3 * 3, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];
                obj.PSD_axes_LF = axes( ...
                                tab_plots, ...
                                'Units', 'pixels',...
                                'Position', obj.PSD_axes_get_pos_LF(fw, fh));
                title('LF');
                xlabel('Частота, Гц');
                ylabel('Оценка');

                % HF
                obj.PSD_axes_get_pos_HF = @(fw, fh) [ ...
                            DX*3 + (fw - DX*5) / 4 * 2,	...
                            fh - DY*3 - (fh - DY*4)/3 * 3, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];
                obj.PSD_axes_HF = axes( ...
                                tab_plots, ...
                                'Units', 'pixels',...
                                'Position', obj.PSD_axes_get_pos_HF(fw, fh));
                title('HF');
                xlabel('Частота, Гц');
                ylabel('Оценка');

            
            obj.PSD_axes_legend = [];
            obj.Ellipses_plots_legend = [];
						
						%------------------------- RR scatter ellipse ---------------------------
						
						axes(obj.RRscatter); hold on; grid on;
						obj.drag_point_RR_a = DragPoint(obj.RRscatter, obj.f);
						obj.drag_point_RR_b = DragPoint(obj.RRscatter, obj.f);
						obj.drag_point_RR_center = DragPoint(obj.RRscatter, obj.f);

						obj.h_RR_a = -1;
						obj.h_RR_b = -1;
						obj.h_RR_ellipse = -1;

						%------------------------- SS scatter ellipse ---------------------------

						axes(obj.SSscatter); hold on; grid on;
						obj.drag_point_SS_a = DragPoint(obj.SSscatter, obj.f);
						obj.drag_point_SS_b = DragPoint(obj.SSscatter, obj.f);
						obj.drag_point_SS_center = DragPoint(obj.SSscatter, obj.f);

						obj.h_SS_a = -1;
						obj.h_SS_b = -1;
						obj.h_SS_ellipse = -1;

						%------------------------- Callbacks ---------------------------

						obj.f.WindowButtonMotionFcn = @(s, e) on_f2_mouse_moution(obj);
						obj.f.WindowButtonDownFcn = @(s, e) on_f2_mouse_down(obj);
						obj.f.WindowButtonUpFcn = @(s, e) on_f2_mouse_up(obj);

						obj.f.WindowButtonMotionFcn = @(s, e) on_f2_mouse_moution(obj);
						obj.f.WindowButtonDownFcn = @(s, e) on_f2_mouse_down(obj);
						obj.f.WindowButtonUpFcn = @(s, e) on_f2_mouse_up(obj);
            
						obj.edit_max_diff_SS.Callback = @(s, e) change_intervals_max_diff(obj, s, 'SS');
						obj.edit_max_diff_RR.Callback = @(s, e) change_intervals_max_diff(obj, s, 'RR');
            obj.f.SizeChangedFcn = @(s, e) on_main_figure_size_changed(obj);
        end
    end
    
    methods (Access = public)
			function b = load_file(obj, pathname, filename)
					b = false;

                    path = [pathname, filename];
                    
					obj.Power_spans_inds = [];
					obj.Signals = read_file(path);
					
					if ~obj.check_has_column('Time', 'время'), return; end
					if ~obj.check_has_column('EKG', 'ЭКГ'), return; end
					if ~obj.check_has_column('R_Pik', 'метки R-зубцов ЭКГ'), return; end
					if ~obj.check_has_column('Press', 'давление'), return; end
					if ~obj.check_has_column('Dia', 'метки диастолического давления'), return; end
					if ~obj.check_has_column('Sis', 'метки систолического давления'), return; end
					if ~obj.check_has_column('Sis', 'метки систолического давления'), return; end
					if ~obj.check_has_column('Power', 'мощность'), return; end
					
					if ~obj.check_has_no_NaN_column(obj.Signals.Time, 'Time', 'время'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.EKG, 'EKG', 'ЭКГ'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.R_Pik, 'R_Pik', 'метки R-зубцов ЭКГ'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.Press, 'Press', 'давление'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.Dia, 'Dia', 'метки диастолического давления'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.Sis, 'Sis', 'метки систолического давления'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.Sis, 'Sis', 'метки систолического давления'), return; end
					if ~obj.check_has_no_NaN_column(obj.Signals.Power, 'Power', 'мощность'), return; end
					
					obj.Td = (obj.Signals.Time(2) - obj.Signals.Time(1));
					
					obj.Power_spans_inds = find_power_spans(obj.Td, obj.Signals.Power);
					
					if isempty(obj.Power_spans_inds)
							errordlg( ...
									"В данном файле значения мощности не содержат эпизодов нагрузки", ...
									"Неподходящий формат файла", ...
									"modal");
							obj.Signals = [];
							obj.POWER_axes.ButtonDownFcn = [];
							return;
                    end
                    
                    last_span_end = obj.Power_spans_inds(end, 2);
                    fields_names = fieldnames(obj.Signals);
                    for n = 1 : length(fields_names)
                        field_name = fields_names{n};
                        if strcmp(field_name, 'Name'), continue; end
                        content = obj.Signals.(field_name);
                        obj.Signals.(field_name) = content(1 : last_span_end);
                    end
                    clear content fields_names field_name
					
					obj.f.Name = filename;
					
					obj.draw_ritmograms_and_power(0);
					
					b = obj.count_all_graphics();
			end
			
			function close(obj)
				close(obj.f);
			end
		end
		
    methods (Access = private)
			function on_f2_mouse_moution(obj)
					obj.drag_point_RR_a = obj.drag_point_RR_a.OnMouseMove();
					obj.drag_point_RR_b = obj.drag_point_RR_b.OnMouseMove();
					obj.drag_point_RR_center = obj.drag_point_RR_center.OnMouseMove();
					obj.on_point_drag_RR();
					obj.drag_point_RR_a = obj.drag_point_RR_a.UpdateOldPos();
					obj.drag_point_RR_b = obj.drag_point_RR_b.UpdateOldPos();
					obj.drag_point_RR_center = obj.drag_point_RR_center.UpdateOldPos();
					
					obj.drag_point_SS_a = obj.drag_point_SS_a.OnMouseMove();
					obj.drag_point_SS_b = obj.drag_point_SS_b.OnMouseMove();
					obj.drag_point_SS_center = obj.drag_point_SS_center.OnMouseMove();
					obj.on_point_drag_SS();
					obj.drag_point_SS_a = obj.drag_point_SS_a.UpdateOldPos();
					obj.drag_point_SS_b = obj.drag_point_SS_b.UpdateOldPos();
					obj.drag_point_SS_center = obj.drag_point_SS_center.UpdateOldPos();
			end

			function on_f2_mouse_down(obj)					
					obj.drag_point_RR_a = obj.drag_point_RR_a.OnMouseDown();
					if obj.drag_point_RR_a.IsDragged(), return; end
					
					obj.drag_point_RR_b = obj.drag_point_RR_b.OnMouseDown();
					if obj.drag_point_RR_b.IsDragged(), return; end
					
					obj.drag_point_RR_center = obj.drag_point_RR_center.OnMouseDown();
					if obj.drag_point_RR_center.IsDragged(), return; end
					
					
					obj.drag_point_SS_a = obj.drag_point_SS_a.OnMouseDown();
					if obj.drag_point_SS_a.IsDragged(), return; end
					
					obj.drag_point_SS_b = obj.drag_point_SS_b.OnMouseDown();
					if obj.drag_point_SS_b.IsDragged(), return; end
					
					obj.drag_point_SS_center = obj.drag_point_SS_center.OnMouseDown();
					if obj.drag_point_SS_center.IsDragged(), return; end
			end

			function on_f2_mouse_up(obj)
					obj.drag_point_RR_a = obj.drag_point_RR_a.OnMouseUp();
					obj.drag_point_RR_b = obj.drag_point_RR_b.OnMouseUp();
					obj.drag_point_RR_center = obj.drag_point_RR_center.OnMouseUp();
					
					obj.drag_point_SS_a = obj.drag_point_SS_a.OnMouseUp();
					obj.drag_point_SS_b = obj.drag_point_SS_b.OnMouseUp();
					obj.drag_point_SS_center = obj.drag_point_SS_center.OnMouseUp();
			end

			function on_point_drag_RR(obj)					
                    if ~ishandle(obj.h_RR_a)
                        return
                    end
                    if ~ishandle(obj.h_RR_b)
                        return
                    end
                    if ~ishandle(obj.h_RR_ellipse)
                        return
                    end
					
					if obj.drag_point_RR_a.IsDragged()
							d = (obj.drag_point_RR_a.X + obj.drag_point_RR_a.Y) / 2;
							obj.drag_point_RR_a = obj.drag_point_RR_a.SetPos(d, d);
							
							pa = [obj.drag_point_RR_a.X; obj.drag_point_RR_a.Y];
							pc = [obj.drag_point_RR_center.X; obj.drag_point_RR_center.Y];
							a_pts = [pa, pc + (pc - pa)];  
							obj.h_RR_a.XData = a_pts(1, :);
							obj.h_RR_a.YData = a_pts(2, :);
					elseif obj.drag_point_RR_b.IsDragged()
							db_len = [-1 / sqrt(2); 1 / sqrt(2)]' * [obj.drag_point_RR_b.X; obj.drag_point_RR_b.Y];
							db_x_y = sqrt(db_len^2 / 2);
							db = [-db_x_y; db_x_y];
							
							pc = [obj.drag_point_RR_center.X; obj.drag_point_RR_center.Y];
							pb = pc + db;
							obj.drag_point_RR_b = obj.drag_point_RR_b.SetPos(pb(1), pb(2));
							
							b_pts = [pb, pc + (pc - pb)]; 
							obj.h_RR_b.XData = b_pts(1, :);
							obj.h_RR_b.YData = b_pts(2, :);
					elseif obj.drag_point_RR_center.IsDragged()
							pc = [obj.drag_point_RR_center.X; obj.drag_point_RR_center.Y];
							
							dc_len = [1 / sqrt(2); 1 / sqrt(2)]' * pc;
							dc_x_y = sqrt(dc_len^2 / 2);
							pc_next = [dc_x_y; dc_x_y];
							
							delta_pc = pc_next - [obj.drag_point_RR_center.OldX; obj.drag_point_RR_center.OldY];
							
							obj.drag_point_RR_a = obj.drag_point_RR_a.SetPos( ...
									obj.drag_point_RR_a.OldX + delta_pc(1), ...
									obj.drag_point_RR_a.OldY + delta_pc(2));
							obj.drag_point_RR_b = obj.drag_point_RR_b.SetPos( ...
									obj.drag_point_RR_b.OldX + delta_pc(1), ...
									obj.drag_point_RR_b.OldY + delta_pc(2));
							obj.drag_point_RR_center = obj.drag_point_RR_center.SetPos(pc_next(1), pc_next(2));
							
							obj.h_RR_a.XData = obj.h_RR_a.XData + delta_pc(1);
							obj.h_RR_a.YData = obj.h_RR_a.YData + delta_pc(2);
							
							obj.h_RR_b.XData = obj.h_RR_b.XData + delta_pc(1);
							obj.h_RR_b.YData = obj.h_RR_b.YData + delta_pc(2);
							
							obj.drag_point_RR_a = obj.drag_point_RR_a.MoveToPos();
							obj.drag_point_RR_b = obj.drag_point_RR_b.MoveToPos();
					else
							return;
					end
					
					pa = [obj.drag_point_RR_a.X; obj.drag_point_RR_a.Y];
					pb = [obj.drag_point_RR_b.X; obj.drag_point_RR_b.Y];
					pc = [obj.drag_point_RR_center.X; obj.drag_point_RR_center.Y];
					
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
					obj.h_RR_ellipse.XData = el_pts(1, :);
					obj.h_RR_ellipse.YData = el_pts(2, :);
					
					Data = obj.EllipseTable.Data(1 : 3, 2 : end);
					
					Data{1,1} = 1000 * a * 2; % ell_len
					Data{2,1} = 1000 * b * 2; % ell_wid
					Data{3,1} = 1000 * 1000 * pi * a * b; % square
					
					obj.EllipseTable.Data(1 : 3, 2 : end) = Data;
			end

			function on_point_drag_SS(obj)					
					if ~ishandle(obj.h_SS_a) || ~ishandle(obj.h_SS_b) || ~ishandle(obj.h_SS_ellipse)
							return
					end
					
					if obj.drag_point_SS_a.IsDragged()
							d = (obj.drag_point_SS_a.X + obj.drag_point_SS_a.Y) / 2;
							obj.drag_point_SS_a = obj.drag_point_SS_a.SetPos(d, d);
							
							pa = [obj.drag_point_SS_a.X; obj.drag_point_SS_a.Y];
							pc = [obj.drag_point_SS_center.X; obj.drag_point_SS_center.Y];
							a_pts = [pa, pc + (pc - pa)];  
							obj.h_SS_a.XData = a_pts(1, :);
							obj.h_SS_a.YData = a_pts(2, :);
					elseif obj.drag_point_SS_b.IsDragged()
							db_len = [-1 / sqrt(2); 1 / sqrt(2)]' * [obj.drag_point_SS_b.X; obj.drag_point_SS_b.Y];
							db_x_y = sqrt(db_len^2 / 2);
							db = [-db_x_y; db_x_y];
							
							pc = [obj.drag_point_SS_center.X; obj.drag_point_SS_center.Y];
							pb = pc + db;
							obj.drag_point_SS_b = obj.drag_point_SS_b.SetPos(pb(1), pb(2));
							
							b_pts = [pb, pc + (pc - pb)]; 
							obj.h_SS_b.XData = b_pts(1, :);
							obj.h_SS_b.YData = b_pts(2, :);
					elseif obj.drag_point_SS_center.IsDragged()
							pc = [obj.drag_point_SS_center.X; obj.drag_point_SS_center.Y];
							
							dc_len = [1 / sqrt(2); 1 / sqrt(2)]' * pc;
							dc_x_y = sqrt(dc_len^2 / 2);
							pc_next = [dc_x_y; dc_x_y];
							
							delta_pc = pc_next - [obj.drag_point_SS_center.OldX; obj.drag_point_SS_center.OldY];
							
							obj.drag_point_SS_a = obj.drag_point_SS_a.SetPos( ...
									obj.drag_point_SS_a.OldX + delta_pc(1), ...
									obj.drag_point_SS_a.OldY + delta_pc(2));
							obj.drag_point_SS_b = obj.drag_point_SS_b.SetPos( ...
									obj.drag_point_SS_b.OldX + delta_pc(1), ...
									obj.drag_point_SS_b.OldY + delta_pc(2));
							obj.drag_point_SS_center = obj.drag_point_SS_center.SetPos(pc_next(1), pc_next(2));
							
							obj.h_SS_a.XData = obj.h_SS_a.XData + delta_pc(1);
							obj.h_SS_a.YData = obj.h_SS_a.YData + delta_pc(2);
							
							obj.h_SS_b.XData = obj.h_SS_b.XData + delta_pc(1);
							obj.h_SS_b.YData = obj.h_SS_b.YData + delta_pc(2);
							
							obj.drag_point_SS_a = obj.drag_point_SS_a.MoveToPos();
							obj.drag_point_SS_b = obj.drag_point_SS_b.MoveToPos();
					else
							return;
					end
					
					pa = [obj.drag_point_SS_a.X; obj.drag_point_SS_a.Y];
					pb = [obj.drag_point_SS_b.X; obj.drag_point_SS_b.Y];
					pc = [obj.drag_point_SS_center.X; obj.drag_point_SS_center.Y];
					
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
					obj.h_SS_ellipse.XData = el_pts(1, :);
					obj.h_SS_ellipse.YData = el_pts(2, :);
					
					Data = obj.EllipseTable.Data(1 : 3, 2 : end);
					
					Data{1,2} = 1000 * a * 2; % ell_len
					Data{2,2} = 1000 * b * 2; % ell_wid
					Data{3,2} = 1000 * 1000 * pi * a * b; % square
					
					obj.EllipseTable.Data(1 : 3, 2 : end) = Data;
			end

			function on_main_figure_size_changed(obj)
				fw = obj.f.Position(3);
				fh = obj.f.Position(4);
				
				obj.tg.Position = obj.tg_get_pos(fw, fh);
				obj.RG_ECG_axes.Position = obj.RG_ECG_get_pos(fw, fh);
				obj.RG_ABP_axes.Position = obj.RG_ABP_get_pos(fw, fh);
				obj.POWER_axes.Position = obj.POWER_get_pos(fw, fh);
						
				fw = obj.f.Position(3);
				fh = obj.f.Position(4);
				
				obj.RRrg_axes.Position = obj.RRrg_axes_get_pos(fw, fh);
				obj.RRScatter_settings.Position = obj.RRScatter_settings_get_pos(fw, fh);
				obj.RRscatter.Position = obj.RRscatter_get_pos(fw, fh);
				obj.RRpsd_axes.Position = obj.RRpsd_axes_get_pos(fw, fh);
				
				obj.SSrg_axes.Position = obj.SSrg_axes_get_pos(fw, fh);
				obj.SSScatter_settings.Position = obj.SSScatter_settings_get_pos(fw, fh);
				obj.SSscatter.Position = obj.SSscatter_get_pos(fw, fh);
				obj.SSpsd_axes.Position = obj.SSpsd_axes_get_pos(fw, fh);
				
				obj.EllipseTable.Position = obj.EllipseTable_get_pos(fw, fh);
				obj.CPSD_axes.Position = obj.CPSD_axes_get_pos(fw, fh);
				obj.PSDTable.Position = obj.PSDTable_get_pos(fw, fh);
				
                obj.Ellipses_plots_len.Position = obj.Ellipses_plots_len_get_pos(fw, fh);
                obj.Ellipses_plots_wid.Position = obj.Ellipses_plots_wid_get_pos(fw, fh);
                obj.Ellipses_plots_sq.Position   = obj.Ellipses_plots_sq_get_pos(fw, fh);
                obj.Ellipses_plots_Mcp.Position = obj.Ellipses_plots_Mcp_get_pos(fw, fh);
                obj.Ellipses_plots_min.Position = obj.Ellipses_plots_min_get_pos(fw, fh);
                obj.Ellipses_plots_max.Position = obj.Ellipses_plots_max_get_pos(fw, fh);
                obj.Ellipses_plots_range.Position = obj.Ellipses_plots_range_get_pos(fw, fh);
                obj.Ellipses_plots_Mo.Position   = obj.Ellipses_plots_Mo_get_pos(fw, fh);
                obj.PSD_axes_VLF.Position = obj.PSD_axes_get_pos_VLF(fw, fh);
                obj.PSD_axes_LF.Position = obj.PSD_axes_get_pos_LF(fw, fh);
                obj.PSD_axes_HF.Position = obj.PSD_axes_get_pos_HF(fw, fh);
				
				if ~isempty(obj.PSD_axes_legend)
					obj.PSD_axes_legend.Location = 'best';
				end
				if ~isempty(obj.Ellipses_plots_legend)
					obj.Ellipses_plots_legend.Location = 'best';
				end
		end
		
			function b = count_all_graphics(obj)
                PSD_Datas = zeros(3, 2, size(obj.Power_spans_inds, 1));
                Ellipse_Datas = zeros(8, 2, size(obj.Power_spans_inds, 1));

                for n = 1 : size(obj.Power_spans_inds, 1)
                    n_begin = obj.Power_spans_inds(n, 1);
                    n_end = obj.Power_spans_inds(n, 2);
                    obj.Selected_time_span = [obj.Signals.Time(n_begin), obj.Signals.Time(n_end)];
                    [PSD_Data, Ellipse_Data] = obj.count_for_selected_span('RRSS', false);
                    
                    if isempty(PSD_Data) || isempty(Ellipse_Data)
                        errordlg("Ошибка в структуре файла", "Не все диапазоны мощности имеют размеченные систолы и R-зубцы");
                        b = false;
                        return;
                    end
                    
                    PSD_Datas(:, :, n) = cell2mat(PSD_Data);
                    Ellipse_Datas(:, :, n) = cell2mat(Ellipse_Data);
                end
                
				% [арактеристики спектра
                axes(obj.PSD_axes_VLF); cla; hold on; grid on;
                stem(reshape(PSD_Datas(1, 1, :), 1, 5));
                stem(reshape(PSD_Datas(1, 2, :), 1, 5));
                
                axes(obj.PSD_axes_LF); cla; hold on; grid on;
                stem(reshape(PSD_Datas(2, 1, :), 1, 5));
                stem(reshape(PSD_Datas(2, 2, :), 1, 5));
                
                axes(obj.PSD_axes_HF); cla; hold on; grid on;
                stem(reshape(PSD_Datas(3, 1, :), 1, 5));
                stem(reshape(PSD_Datas(3, 2, :), 1, 5));
                obj.PSD_axes_legend = legend(["VLF ЭКГ", "VLF АД", "LF ЭКГ", "LF АД", "HF ЭКГ", "HF АД"], ...
                    'Location', 'best');
                
				% [арактеристики 'ллипсов
                axes(obj.Ellipses_plots_len); cla; hold on; grid on;        
                stem(reshape(Ellipse_Datas(1, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(1, 2, :), 1, 5));
                
                axes(obj.Ellipses_plots_wid); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(2, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(2, 2, :), 1, 5));

                axes(obj.Ellipses_plots_sq); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(3, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(3, 2, :), 1, 5));

                axes(obj.Ellipses_plots_Mcp); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(4, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(4, 2, :), 1, 5));

                axes(obj.Ellipses_plots_min); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(5, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(5, 2, :), 1, 5));

                axes(obj.Ellipses_plots_max); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(6, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(6, 2, :), 1, 5));

                axes(obj.Ellipses_plots_range); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(7, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(7, 2, :), 1, 5));

                axes(obj.Ellipses_plots_Mo); cla; grid on; hold on;        
                stem(reshape(Ellipse_Datas(8, 1, :), 1, 5));
                stem(reshape(Ellipse_Datas(8, 2, :), 1, 5));
                
                obj.Ellipses_plots_legend = legend([ ...
                    "Длина облака ЭКГ, мс",     "Длина облака АД, мс", ...
                    "Ширина облака ЭКГ, мс",    "Ширина облака АД, мс", ...
                    "Площадь облака ЭКГ, мс^2", "Площадь облака АД, мс^2", ...
                    "Мср ЭКГ, мс",              "Мср АД, мс", ...
                    "RR(SS)_min ЭКГ, мс",       "RR(SS)_min АД, мс", ...
                    "RR(SS)_max ЭКГ, мс",       "RR(SS)_max АД, мс", ...
                    "Размах RR(SS) ЭКГ, мс",    "Размах RR(SS) АД, мс", ...
                    "Mo ЭКГ, мс",               "Mo АД, мс" ...
                ], ...
                    'Location', 'best', 'NumColumns', 5);

                n_begin = obj.Power_spans_inds(n, 1);
                n_end = obj.Power_spans_inds(n, 2);
                obj.Selected_time_span = [obj.Signals.Time(n_begin), obj.Signals.Time(n_end)];
                obj.draw_ritmograms_and_power(1);
                obj.count_for_selected_span('RRSS', true);
                
                b = true;
			end

			function b = check_has_column(obj, name, ui_name)
					b = isfield(obj.Signals, name);
					if ~b
							errordlg( ...
									sprintf("В данном файле нет столбца '%s' (%s)", name, ui_name), ...
									"Неподходящий формат файла", ...
									"modal");
							obj.Signals = [];
							obj.POWER_axes.ButtonDownFcn = [];
					end
			end

			function b = check_has_no_NaN_column(obj, column, name, ui_name)
					b = sum(~isnan(column));
					if ~b
							errordlg( ...
									sprintf("В данном файле столбец '%s' (%s) имеет значения NaN", name, ui_name), ...
									"Неподходящий формат файла", ...
									"modal");
							obj.Signals = [];
							obj.POWER_axes.ButtonDownFcn = [];
					end
			end

			function draw_ritmograms_and_power(obj, selected_t_span_ind)
					[RRx, RRy, SSx, SSy] = calc_ritmogramms( ...
							obj.Signals, ...
							[obj.Signals.Time(1), obj.Signals.Time(end)], ...
							obj.RR_max_diff, ...
							obj.SS_max_diff);

					axes(obj.RG_ECG_axes); cla; hold on; grid on;
					stem(RRx, RRy, '.');

					axes(obj.RG_ABP_axes); cla; hold on; grid on;
					stem(SSx, SSy, '.');

					axes(obj.POWER_axes); cla reset; hold on; grid on;
					h = plot(obj.Signals.Time, obj.Signals.Power);
					h.HitTest = 'off';
					xlabel('Время, с');
					ylabel('Мощность, Вт');
					
					for span_ind = 1 : size(obj.Power_spans_inds, 1)
							span_t_inds = obj.Power_spans_inds(span_ind, :);
							t1 = obj.Signals.Time(span_t_inds(1));
							t2 = obj.Signals.Time(span_t_inds(2));
							
							if span_ind == selected_t_span_ind
									span_FaceColor = [1, 1, 0, 0.2];
							else
									span_FaceColor = [0, 1, 0, 0.2];
							end
							
							h = rectangle('Position', [t1, min(obj.Signals.Power), t2 - t1, max(obj.Signals.Power)], ...
											'Curvature', 0, ...
											'FaceColor', span_FaceColor, ...
											'EdgeColor', [0, 1, 0, 1]);
							h.HitTest = 'off';
							
							clear t1 t2 span_FaceColor
					end
					
					obj.POWER_axes.ButtonDownFcn = @(s, e) POWER_axes_click(obj, e);
			end

			function POWER_axes_click(obj, e)					
					if isempty(obj.Signals)
							return;
					end
					
					axes(obj.POWER_axes);
					
					x = num2ruler(e.IntersectionPoint(1), obj.POWER_axes.XAxis);
					
					time_ind = round(x / obj.Td);
					
					obj.Selected_time_span = [];
					
					for span_ind = 1 : size(obj.Power_spans_inds, 1)
							n_begin = obj.Power_spans_inds(span_ind, 1);
							n_end = obj.Power_spans_inds(span_ind, 2);
							if n_begin <= time_ind && time_ind <= n_end
									obj.Selected_time_span = [obj.Signals.Time(n_begin), obj.Signals.Time(n_end)];
									obj.draw_ritmograms_and_power(span_ind);
									break;
							end
					end
							
					obj.count_for_selected_span('RRSS', true);
			end

			function change_intervals_max_diff(obj, s, signal_name)
					value = str2double(s.String);
					if isnan(value) || value < 0 || value > 100
							errordlg('Необходимо ввести дробное число от 0 до 1');
							return;
					end
					
					if strcmp(signal_name, 'RR')
							obj.RR_max_diff = value / 100;
					elseif strcmp(signal_name, 'SS')
							obj.SS_max_diff = value / 100;
					else
							assert(false);
					end
					
					obj.count_for_selected_span(signal_name, true);
			end

        function [PSD_Data, Ellipse_Data] = count_for_selected_span(obj, to_recount, do_plotting)									
            if isempty(obj.Selected_time_span)
                PSD_Data = [];
                Ellipse_Data = [];
                return;
            end

            if do_plotting
                obj.text_max_diff_RR.Enable = 'on';
                obj.edit_max_diff_RR.Enable = 'on';
                obj.text_max_diff_SS.Enable = 'on';
                obj.edit_max_diff_SS.Enable = 'on';
            end

            t = obj.Signals.Time;

            t_span = t(t >= obj.Selected_time_span(1) & t <= obj.Selected_time_span(2));

            [RRx, RRy, SSx, SSy, RRx_old, RRy_old, SSx_old, SSy_old] = calc_ritmogramms( ...
                    obj.Signals, ...
                    t_span, ...
                    obj.RR_max_diff, ...
                    obj.SS_max_diff);
                
            if isempty(RRx) || isempty(RRy) || isempty(SSx) || isempty(SSy)
                PSD_Data = [];
                Ellipse_Data = [];
                return;
            end

            [RRpsd_f, RRpsd, SSpsd_f, SSpsd, CPSD, CPSD_f, RR_VLF, RR_LF, RR_HF, SS_VLF, SS_LF, SS_HF] = calc_psd_welch_an_cpsd( ...
                    t_span, RRx, RRy, SSx, SSy);

            Ellipse_Data = obj.EllipseTable.Data(:, 2 : end);

            if contains(to_recount, 'RR')
                [sc_x, sc_y, el_x, el_y, el_params_RR, ax, ay, bx, by, x0, y0] = calc_scatter_ellipse(RRy);

                if do_plotting
                    axes(obj.RRrg_axes); cla; hold on; grid on;
                    stem(RRx_old, RRy_old, '.');
                    stem(RRx, RRy, '.');
                    xlabel('Время, с');
                    ylabel('Длительность, с');

                    axes(obj.RRpsd_axes); cla; hold on; grid on;
                    plot(RRpsd_f, RRpsd);

                    axes(obj.RRscatter); cla; hold on; grid on;
                    plot(RRy_old(1 : end - 1), RRy_old(2 : end), '.k');
                    plot(RRy(1 : end - 1), RRy(2 : end), 'ob');
                    plot(sc_x, sc_y, '.b');
                    obj.h_RR_a = plot(ax, ay, 'c', 'LineWidth', 2);
                    obj.h_RR_b = plot(bx, by, 'm', 'LineWidth', 2);
                    obj.h_RR_ellipse = plot(el_x, el_y, 'r', 'LineWidth', 2);

                    obj.drag_point_RR_a = obj.drag_point_RR_a.Draw(ax(end), ay(end));
                    obj.drag_point_RR_b = obj.drag_point_RR_b.Draw(bx(end), by(end));
                    obj.drag_point_RR_center = obj.drag_point_RR_center.Draw(x0, y0);    

                    range_x = max(sc_x) - min(sc_x);
                    range_y = max(sc_y) - min(sc_y);
                    range = max(range_x, range_y);

                    xlim([min(sc_x) - range * 0.4, min(sc_x) + range * 1.4]);
                    ylim([min(sc_y) - range * 0.4, min(sc_y) + range * 1.4]);
                end

                Ellipse_Data{1, 1} = 1000 * el_params_RR.ell_len;
                Ellipse_Data{2, 1} = 1000 * el_params_RR.ell_wid;
                Ellipse_Data{3, 1} = 1000 * 1000 * el_params_RR.square;
                Ellipse_Data{4, 1} = 1000 * el_params_RR.m_sr;
                Ellipse_Data{5, 1} = 1000 * el_params_RR.interv_min;
                Ellipse_Data{6, 1} = 1000 * el_params_RR.interv_max;
                Ellipse_Data{7, 1} = 1000 * el_params_RR.interv_range;
                Ellipse_Data{8, 1} = 1000 * el_params_RR.mo;
            end

            if contains(to_recount, 'SS')
                [sc_x, sc_y, el_x, el_y, el_params_SS, ax, ay, bx, by, x0, y0] = calc_scatter_ellipse(SSy);

                if do_plotting
                    axes(obj.SSrg_axes); cla; hold on; grid on;
                    stem(SSx_old, SSy_old, '.');
                    stem(SSx, SSy, '.');
                    xlabel('Время, с');
                    ylabel('Длительность, с');

                    axes(obj.SSpsd_axes); cla; hold on; grid on;
                    plot(SSpsd_f, SSpsd);

                    axes(obj.CPSD_axes); cla; hold on; grid on;
                    plot(CPSD_f, CPSD);

                    axes(obj.SSscatter); cla; hold on; grid on;
                    plot(SSy_old(1 : end - 1), SSy_old(2 : end), '.k');
                    plot(SSy(1 : end - 1), SSy(2 : end), 'ob');
                    plot(sc_x, sc_y, '.b');
                    obj.h_SS_a = plot(ax, ay, 'c', 'LineWidth', 2);
                    obj.h_SS_b = plot(bx, by, 'm', 'LineWidth', 2);
                    obj.h_SS_ellipse = plot(el_x, el_y, 'r', 'LineWidth', 2);

                    obj.drag_point_SS_a = obj.drag_point_SS_a.Draw(ax(end), ay(end));
                    obj.drag_point_SS_b = obj.drag_point_SS_b.Draw(bx(end), by(end));
                    obj.drag_point_SS_center = obj.drag_point_SS_center.Draw(x0, y0);   

                    range_x = max(sc_x) - min(sc_x);
                    range_y = max(sc_y) - min(sc_y);
                    range = max(range_x, range_y);

                    xlim([min(sc_x) - range * 0.4, min(sc_x) + range * 1.4]);
                    ylim([min(sc_y) - range * 0.4, min(sc_y) + range * 1.4]);
                end

                Ellipse_Data{1, 2} = 1000 * el_params_SS.ell_len;
                Ellipse_Data{2, 2} = 1000 * el_params_SS.ell_wid;
                Ellipse_Data{3, 2} = 1000 * 1000 * el_params_SS.square;
                Ellipse_Data{4, 2} = 1000 * el_params_SS.m_sr;
                Ellipse_Data{5, 2} = 1000 * el_params_SS.interv_min;
                Ellipse_Data{6, 2} = 1000 * el_params_SS.interv_max;
                Ellipse_Data{7, 2} = 1000 * el_params_SS.interv_range;
                Ellipse_Data{8, 2} = 1000 * el_params_SS.mo;
            end

            if do_plotting
                obj.EllipseTable.Data(:, 2 : end) = Ellipse_Data;
            end

            PSD_Data = obj.PSDTable.Data(:, 2 : end);
            PSD_Data{1, 1} = RR_VLF;
            PSD_Data{1, 2} = SS_VLF;
            PSD_Data{2, 1} = RR_LF;
            PSD_Data{2, 2} = SS_LF;
            PSD_Data{3, 1} = RR_HF;
            PSD_Data{3, 2} = SS_HF;

            if do_plotting
                obj.PSDTable.Data(:, 2 : end) = PSD_Data;
                obj.PSDTable.ColumnWidth = 'fit';
            end
        end
    end
end

