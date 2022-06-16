classdef Viewer < handle
    %VIEVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        f
    end
    properties (Access = private)
        Signals, Power_spans_inds, Td, Selected_time_span, RR_max_diff, SS_max_diff,DD_max_diff
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
		DDScatter_settings, DDScatter_settings_get_pos, 
        text_max_diff_SS, edit_max_diff_SS, 
		text_max_diff_DD, edit_max_diff_DD,
        SSpsd_axes, SSpsd_axes_get_pos, 
		DDpsd_axes, DDpsd_axes_get_pos,
        SSscatter, SSscatter_get_pos, 
		DDscatter, DDscatter_get_pos, 
        EllipseTable, EllipseTable_get_pos, 
        CPSD_axes, CPSD_axes_get_pos, 
        SSrg_axes, SSrg_axes_get_pos, 
		DDrg_axes, DDrg_axes_get_pos,
        PSDTableRR, PSDTableRR_get_pos, 
        PSDTableSS, PSDTableSS_get_pos, 
        PSDTableDD, PSDTableDD_get_pos, 
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
        IndicatorsTableRR, IndicatorsTableRR_get_pos,
        IndicatorsTableSS, IndicatorsTableSS_get_pos,
        IndicatorsTableDD, IndicatorsTableDD_get_pos,
        ExportBtn, ExportBtn_get_pos,
        PSD_axes_legend, Ellipses_plots_legend,
        drag_point_RR_a, drag_point_RR_b, drag_point_RR_center,
        drag_point_SS_a, drag_point_SS_b, drag_point_SS_center,
        drag_point_DD_a, drag_point_DD_b, drag_point_DD_center,
        h_RR_a, h_RR_b, h_RR_ellipse,
        h_SS_a, h_SS_b, h_SS_ellipse,
        h_DD_a, h_DD_b, h_DD_ellipse,
    end
    
    methods
        function obj = Viewer()
            obj.f = figure;
            obj.f.Name = '';
						
            obj.RR_max_diff = 5;
            obj.SS_max_diff = 1;
            obj.DD_max_diff = 1;
			
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
            ylabel('Давление, мм рт. ст.');

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

            % RR
						
            tab_scatter = uitab(obj.tg);
            tab_scatter.Title = 'Скаттерограмма';

            SETTINGS_WIDTH = 0.2*fw;
         
            DX = 5;
            DY = 5;
						DY_UP = 40;
			
            obj.RRScatter_settings_get_pos = @(fw, fh) [ ...
							DX, ...            
							DY*3 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 2 + 60 + 60, ...
							SETTINGS_WIDTH,...  
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.RRScatter_settings = uipanel( ...
                    tab_scatter, ...
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
							DX + SETTINGS_WIDTH + DX + 40,	...
							DY*3 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 2 + 60 + 60, ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.RRscatter = axes( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'Position', obj.RRscatter_get_pos(fw, fh), ...
                            'DataAspectRatio', [1, 1, 1]);
            title('Скаттерограмма ЭКГ');
            xlabel('RR_i, с');
            ylabel('RR_{i-1}, с');

            obj.RRrg_axes_get_pos = @(fw, fh) [ ...
							DX + SETTINGS_WIDTH + DX + 40 + (fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 + DX + 40,	...
							DY*3 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 2 + 60 + 60, ...
							(fw - DX - SETTINGS_WIDTH - DX - 40 - (fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 - DX - 40 - DX*2 - 10) / 2, ...  
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.RRrg_axes = axes( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'Position', obj.RRrg_axes_get_pos(fw, fh));
            title('Участок ритмограммы ЭКГ');
            xlabel('Время, с');
            ylabel('Длительность, с');
            
            % SS
            
            obj.SSScatter_settings_get_pos = @(fw, fh) [ ...
							DX, ...            
							DY*2 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 1 + 60, ...
							SETTINGS_WIDTH,...  
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.SSScatter_settings = uipanel( ...
                    tab_scatter, ...
                    'Units','pixels',...
                    'Position', obj.SSScatter_settings_get_pos(fw, fh), ...
                    'BackGroundColor',[0.93 0.93 0.93]);

            bg = uibuttongroup(obj.SSScatter_settings, ...
                    'Units', 'normalized', ...
                    'Position', [0.05, 0.05, 0.9, 0.9]);
            obj.text_max_diff_SS = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Style', 'text',...
                    'String', 'Порядок медианного фильтра', ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 0.5],...
                    'HandleVisibility', 'on');
            obj.edit_max_diff_SS = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Value', 0, ...
                    'Style', 'edit',...
                    'String', sprintf('%i', obj.SS_max_diff),...
                    'Units', 'normalized', ...
                    'Position', [0, 0.5, 1, 0.5],...
                    'HandleVisibility', 'off');

            obj.SSscatter_get_pos = @(fw, fh) [ ...
							DX + SETTINGS_WIDTH + DX + 40,	...
							DY*2 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 1 + 60, ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.SSscatter = axes( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'Position', obj.SSscatter_get_pos(fw, fh), ...
                            'DataAspectRatio', [1, 1, 1]);
            title(["Cкатерограмма значений поударного", "систалического давления"]);
            xlabel('SS_i, с');
            ylabel('SS_{i-1}, с');
						
            obj.SSrg_axes_get_pos = @(fw, fh) [ ...
							DX + SETTINGS_WIDTH + DX + 40 + (fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 + DX + 40,	...
							DY*2 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 1 - 15 + 60, ...
							(fw - DX - SETTINGS_WIDTH - DX - 40 - (fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 - DX - 40 - DX*2 - 10) / 2, ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.SSrg_axes = axes( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'Position', obj.SSrg_axes_get_pos(fw, fh));
            title('Участок интервалов "систола-систола" АД');
            xlabel('Время, с');
            ylabel('Давление, мм.рт.ст');
			
            % DD
            
            obj.DDScatter_settings_get_pos = @(fw, fh) [ ...
							DX, ...            
							DY*1 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 0, ...
							SETTINGS_WIDTH,...  
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.DDScatter_settings = uipanel( ...
                    tab_scatter, ...
                    'Units','pixels',...
                    'Position', obj.DDScatter_settings_get_pos(fw, fh), ...
                    'BackGroundColor',[0.93 0.93 0.93]);

            bg = uibuttongroup(obj.DDScatter_settings, ...
                    'Units', 'normalized', ...
                    'Position', [0.05, 0.05, 0.9, 0.9]);
            obj.text_max_diff_DD = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Style', 'text',...
                    'String', 'Порядок медианного фильтра', ...
                    'Units', 'normalized', ...
                    'Position', [0, 0, 1, 0.5],...
                    'HandleVisibility', 'on');
            obj.edit_max_diff_DD = uicontrol(bg, ...
                    'Enable', 'off', ...
                    'Value', 0, ...
                    'Style', 'edit',...
                    'String', sprintf('%i', obj.DD_max_diff),...
                    'Units', 'normalized', ...
                    'Position', [0, 0.5, 1, 0.5],...
                    'HandleVisibility', 'off');

            obj.DDscatter_get_pos = @(fw, fh) [ ...
							DX + SETTINGS_WIDTH + DX + 40,	...
							DY*1 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 0, ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.DDscatter = axes( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'Position', obj.DDscatter_get_pos(fw, fh), ...
                            'DataAspectRatio', [1, 1, 1]);
            title(["Скатерограмма значений поударного", "диасталического давления"]);
            xlabel('DD_i, с');
            ylabel('DD_{i-1}, с');
						
            obj.DDrg_axes_get_pos = @(fw, fh) [ ...
							DX + SETTINGS_WIDTH + DX + 40 + (fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 + DX + 40,	...
							DY*1 + (fh - DY*4 - DY_UP - 15 - 60 - 60)/3 * 0, ...
							(fw - DX - SETTINGS_WIDTH - DX - 40 - (fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 - DX - 40 - DX*2 - 10) / 2, ... 
							(fh - DY*4 - DY_UP - 15 - 60 - 60) / 3 ...
						];
            obj.DDrg_axes = axes( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'Position', obj.DDrg_axes_get_pos(fw, fh));
            title('Участок интервалов "диаистола-диастола" АД');
            xlabel('Время, с');
            ylabel('Давление, мм.рт.ст');

						% table

            obj.EllipseTable_get_pos = @(fw, fh) [ ...
							DX + SETTINGS_WIDTH + DX + 40 + (fh - DY*4 - DY_UP) / 3 + DX + 40 + (fw - DX - SETTINGS_WIDTH - DX - 40 - (fh - DY*4 - DY_UP) / 3 - DX - 40 - DX*2 - 10) / 2 + DX,	...
							DY*1 + (fh - DY*4 - DY_UP)/3 * 0, ...
							(fw - DX - SETTINGS_WIDTH - DX - 40 - (fh - DY*4 - DY_UP) / 3 - DX - 40 - DX*2 - 10) / 2, ... 
							(fh - DY*2 - DY_UP - 15) ...
						];
            obj.EllipseTable = uitable( ...
                            tab_scatter, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.EllipseTable_get_pos(fw, fh));
            obj.EllipseTable.ColumnEditable = false;
            obj.EllipseTable.ColumnName = { 'Величина', 'ЭКГ', 'АД' };
            Data = cell(8, 4);
            Data{1, 1} = 'Длина облака, мс';
            Data{2, 1} = 'Ширина облака, мс';
            Data{3, 1} = 'Площадь облака, мс^2';
            Data{4, 1} = 'Мср, мс';
            Data{5, 1} = 'RR(SS)_{min}, мс';
            Data{6, 1} = 'RR(SS)_{max}, мс';
            Data{7, 1} = 'Размах RR(SS), мс';
            Data{8, 1} = 'Mo, мс';
            obj.EllipseTable.Data = Data;
            obj.EllipseTable.ColumnWidth = 'auto';

            %--------------------------- 'Спектры' tab --------------------------

            tab_spec = uitab(obj.tg);
            tab_spec.Title = 'Спектры';
            
            DX = 40;
            DY = 60;
            
						% RR
						
            obj.RRpsd_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*4 + (fh - DY*5)/4 * 3, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.RRpsd_axes = axes( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'Position', obj.RRpsd_axes_get_pos(fw, fh));
            title('Ритмограмма участка');
            xlabel('Частота, Гц');
            ylabel('Оценка СПМ, мс^2/Гц');
						
            obj.PSDTableRR_get_pos = @(fw, fh) [ ...
                            DX + (fw - DX*3)/2 + DX,	...
                            DY*4 + (fh - DY*5)/4 * 3, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.PSDTableRR = uitable( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.PSDTableRR_get_pos(fw, fh));
            obj.PSDTableRR.ColumnEditable = false;
            obj.PSDTableRR.ColumnName = { 'Величина', 'Значение для R-R интервалов, мс^2' };
            Data = cell(3, 2);
            Data{1, 1} = 'VLF (0,003..0,04 Гц), мс^2';
            Data{2, 1} = 'LF (0,04..0,15 Гц), мс^2';
            Data{3, 1} = 'HF (0,15..0,4 Гц), мс^2';
            obj.PSDTableRR.Data = Data;
            obj.PSDTableRR.ColumnWidth = { 200, 320 };
            
						% SS

            obj.SSpsd_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*3 + (fh - DY*5) / 4 * 2, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.SSpsd_axes = axes( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'Position', obj.SSpsd_axes_get_pos(fw, fh));
            title('Спектр Уэлча интервалов "систола-систола" АД');
            xlabel('Частота, Гц');
            ylabel('Оценка СПМ, мм.рт.ст.^2/Гц');

            obj.PSDTableSS_get_pos = @(fw, fh) [ ...
                            DX + (fw - DX*3)/2 + DX,	...
                            DY*3 + (fh - DY*5) / 4 * 2, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.PSDTableSS = uitable( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.PSDTableSS_get_pos(fw, fh));
            obj.PSDTableSS.ColumnEditable = false;
            obj.PSDTableSS.ColumnName = { 'Величина', 'Значение для систолического АД, (мм.рт.ст.)^2/Гц' };
            Data = cell(3, 2);
            Data{1, 1} = 'VLF (0,003..0,04 Гц), мс^2';
            Data{2, 1} = 'LF (0,04..0,15 Гц), мс^2';
            Data{3, 1} = 'HF (0,15..0,4 Гц), мс^2';
            obj.PSDTableSS.Data = Data;
            obj.PSDTableSS.ColumnWidth = { 200, 320 };
            
						% DD

            obj.DDpsd_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*2 + (fh - DY*5) / 4 * 1, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.DDpsd_axes = axes( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'Position', obj.DDpsd_axes_get_pos(fw, fh));
            title('Спектр Уэлча интервалов "диаистола-диаистола" АД');
            xlabel('Частота, Гц');
            ylabel('Оценка СПМ, мм.рт.ст.^2/Гц');

            obj.PSDTableDD_get_pos = @(fw, fh) [ ...
                            DX + (fw - DX*3)/2 + DX,	...
                            DY*2 + (fh - DY*5) / 4 * 1, ...
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.PSDTableDD = uitable( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.PSDTableDD_get_pos(fw, fh));
            obj.PSDTableDD.ColumnEditable = false;
            obj.PSDTableDD.ColumnName = { 'Величина', 'Значение для диастолического АД, (мм.рт.ст.)^2/Гц' };
            Data = cell(3, 2);
            Data{1, 1} = 'VLF (0,003..0,04 Гц), мс^2';
            Data{2, 1} = 'LF (0,04..0,15 Гц), мс^2';
            Data{3, 1} = 'HF (0,15..0,4 Гц), мс^2';
            obj.PSDTableDD.Data = Data;
            obj.PSDTableDD.ColumnWidth = { 200, 320 };
						

            obj.CPSD_axes_get_pos = @(fw, fh) [ ...
                            DX,	...
                            DY*1 + (fh - DY*5) / 4 * 0, ....
                            (fw - DX*3) / 2, ...
                            (fh - DY*5) / 4 ...
                    ];
            obj.CPSD_axes = axes( ...
                            tab_spec, ...
                            'Units', 'pixels',...
                            'Position', obj.CPSD_axes_get_pos(fw, fh));
            title('Кросс-СПМ интервалов "систола-систола" АД и ритмограммы ЭКГ');
            xlabel('Частота, Гц');
            ylabel('Оценка');

            %--------------------------- 'Таблица показателей' tab --------------------------

            tab_tabl = uitab(obj.tg);
            tab_tabl.Title = 'Таблица показателей';
						
            DX = 10;
            DY = 10;
            
            %IndicatorsTable RR
						
            obj.IndicatorsTableRR_get_pos = @(fw, fh) [ ...
                            DX*1 + (fw - DX*2) / 2 * 0, ...
                            DY*3 + (fh - DY*8 - 30)/3 * 2 + 30, ....
                            (fw - DX*3) / 1, ...
                            (fh - DY*8 - 30) / 3, ...
                    ];
            obj.IndicatorsTableRR = uitable( ...
                            tab_tabl, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.IndicatorsTableRR_get_pos(fw, fh));
            obj.IndicatorsTableRR.ColumnEditable = false;
            obj.IndicatorsTableRR.RowName = { '', '', '', '', '' };
            obj.IndicatorsTableRR.ColumnName = { ...
							'№ этапа', ...
							'Ширина облака, мс', ...
							'Длина облака, мс', ...
							'Mo, мс', ...
							'Размах RR, мс', ...
							'RR мин, мс', ...
							'RR макс, мс', ...
							'Площадь облака, мс^2', ...
							'Мср, мс', ...
							'VLF, мс^2', ...
							'LF, мс^2', ...
							'HF, мс^2', ...
						};
            Data = cell(5, 11);
            Data{1, 1} = '1';
            Data{2, 1} = '2';
            Data{3, 1} = '3';
            Data{4, 1} = '4';
            Data{5, 1} = '5';
            obj.IndicatorsTableRR.Data = Data;
            obj.IndicatorsTableRR.ColumnWidth = 'fit';
            
            %IndicatorsTable SS
						
            obj.IndicatorsTableSS_get_pos = @(fw, fh) [ ...
                            DX*1 + (fw - DX*2) / 2 * 0, ...
                            DY*2 + (fh - DY*8 - 30)/3 * 1 + 30, ....
                            (fw - DX*3) / 1, ...
                            (fh - DY*8 - 30) / 3, ...
                    ];
            obj.IndicatorsTableSS = uitable( ...
                            tab_tabl, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.IndicatorsTableSS_get_pos(fw, fh));
            obj.IndicatorsTableSS.ColumnEditable = false;
            obj.IndicatorsTableSS.RowName = { '', '', '', '', '', '' };
            obj.IndicatorsTableSS.ColumnName = { ...
							'№ этапа', ...
							'Ширина облака, мм рт. ст.', ...
							'Длина облака, мм рт. ст.', ...
							'Mo, мм рт. ст.', ...
							'Размах SS, мм рт. ст.', ...
							'SS мин, мм рт. ст.', ...
							'SS макс, мм рт. ст.', ...
							'Площадь облака, (мм рт. ст.)^2', ...
							'Мср, мм рт. ст.', ...
							'VLF, (мм рт. ст.)^2', ...
							'LF, (мм рт. ст.)^2', ...
							'HF, (мм рт. ст.)^2', ...
						};
            Data = cell(5, 11);
            Data{1, 1} = '1';
            Data{2, 1} = '2';
            Data{3, 1} = '3';
            Data{4, 1} = '4';
            Data{5, 1} = '5';
            obj.IndicatorsTableSS.Data = Data;
            obj.IndicatorsTableSS.ColumnWidth = 'fit';
            
            %IndicatorsTable DD
						
            obj.IndicatorsTableDD_get_pos = @(fw, fh) [ ...
                            DX*1 + (fw - DX*2) / 2 * 0, ...
                            DY*1 + (fh - DY*8 - 30)/3 * 0 + 30, ....
                            (fw - DX*3) / 1, ...
                            (fh - DY*8 - 30) / 3, ...
                    ];
            obj.IndicatorsTableDD = uitable( ...
                            tab_tabl, ...
                            'Units', 'pixels',...
                            'FontSize',  10, ...
                            'Position', obj.IndicatorsTableDD_get_pos(fw, fh));
            obj.IndicatorsTableDD.ColumnEditable = false;
            obj.IndicatorsTableDD.RowName = { '', '', '', '', '', '' };
            obj.IndicatorsTableDD.ColumnName = { ...
							'№ этапа', ...
							'Ширина облака, мм рт. ст.', ...
							'Длина облака, мм рт. ст.', ...
							'Mo, мм рт. ст.', ...
							'DD, мм рт. ст.', ...
							'DD мин, мм рт. ст.', ...
							'DD макс, мм рт. ст.', ...
							'Площадь облака, (мм рт. ст.)^2', ...
							'Мср, мм рт. ст.', ...
							'VLF, (мм рт. ст.)^2', ...
							'LF, (мм рт. ст.)^2', ...
							'HF, (мм рт. ст.)^2', ...
						};
            Data = cell(5, 11);
            Data{1, 1} = '1';
            Data{2, 1} = '2';
            Data{3, 1} = '3';
            Data{4, 1} = '4';
            Data{5, 1} = '5';
            obj.IndicatorsTableDD.Data = Data;
            obj.IndicatorsTableDD.ColumnWidth = 'fit';
						
						obj.ExportBtn_get_pos = @(fw, fh) [ ...
                            fw - 250 - DX*2, ...
                            DY*1 + (fh - DY*8)/3 * 0, ....
                            250, ...
                            25, ...
                    ];						
						obj.ExportBtn = uicontrol( ...
							tab_tabl, ...
							'Units', 'pixels', ...
							'Style', 'pushbutton', ...
							'String', 'Экспортировать в xlsx', ...
              'Position', obj.ExportBtn_get_pos(fw, fh));
							
            
            %--------------------------- 'Графики' tab --------------------------

            tab_plots = uitab(obj.tg);
            tab_plots.Title = 'Графики';

                DX = 100; DY = 80;
                
                % Длина
                obj.Ellipses_plots_len_get_pos = @(fw, fh) [ ...
                            DX*1 + (fw - DX*5) / 4 * 0,	... % Х у ни;него левого угла
                            fh - DY*1 - (fh - DY*4)/3 * 1, .... % У у ни;него левого угла
                            (fw - DX*5) / 4, ... % Ширна
                            (fh - DY*4) / 3 ... % Высота
                ];

                obj.Ellipses_plots_len = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_len_get_pos(fw, fh));
                
                obj.Ellipses_plots_len.XTick = [1 2 3 4 5];
                
                title('Длина эллипса скатерограммы ЭКГ');
                xlabel('Номер этапа нагрузки');
                ylabel('Длина, мс');

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
                obj.Ellipses_plots_wid.XTick = [1 2 3 4 5];
                title('Ширина эллипса скатерограммы ЭКГ');
                xlabel('Номер этапа нагрузки');
                ylabel('Ширина, мс');

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
                obj.Ellipses_plots_sq.XTick = [1 2 3 4 5];
                title('Площадь облака ЭКГ');
                xlabel('Номер этапа нагрузки');
                ylabel('Площадь, мс^2');

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
                
                obj.Ellipses_plots_Mcp.XTick = [1 2 3 4 5];
                title('Mcp');
                xlabel('Номер этапа нагрузки');
                ylabel('Mcp, мс');

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
                
                obj.Ellipses_plots_min.XTick = [1 2 3 4 5];
                title('Минимальные значения R-R интервалов');
                xlabel('Номер этапа нагрузки');
                ylabel('RR_{min} мс');

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
                
                obj.Ellipses_plots_max.XTick = [1 2 3 4 5];
                title('Максимальные значения R-R интервалов');
                xlabel('Номер этапа нагрузки');
                ylabel('RR_{max}, мс');

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
                
                obj.Ellipses_plots_range.XTick = [1 2 3 4 5];
                title('Размах R-R интервалов');
                xlabel('Номер этапа нагрузки');
                ylabel('Размах, мс');

                % Мода
                obj.Ellipses_plots_Mo_get_pos = @(fw, fh) [ ...
                            DX*4 + (fw - DX*5) / 4 * 3,	...
                            fh - DY*2 - (fh - DY*4)/3 * 2, ....
                            (fw - DX*5) / 4, ...
                            (fh - DY*4) / 3 ...
                ];

                
                obj.Ellipses_plots_Mo = axes( ...
                    tab_plots, ...
                    'Units', 'pixels',...
                    'Position', obj.Ellipses_plots_Mo_get_pos(fw, fh));
                
                obj.Ellipses_plots_Mo.XTick = [1 2 3 4 5];
                title('Мода');
                xlabel('Номер этапа нагрузки');
                ylabel('Mo ЭКГ, мс');
                
                
                % Характеристики спектров
                
                % VLF
                obj.PSD_axes_get_pos_VLF = @(fw, fh) [ ...
                            DX*1 + (fw - DX*5) / 4 * 0,	...
                            fh - DY*3 - (fh - DY*4)/3 * 3, ....
                            (fw - DX*4) / 3, ...
                            (fh - DY*4) / 3 ...
                ];
                obj.PSD_axes_VLF = axes( ...
                                tab_plots, ...
                                'Units', 'pixels',...
                                'Position', obj.PSD_axes_get_pos_VLF(fw, fh));
                            
                obj.PSD_axes_VLF.XTick = [1 2 3 4 5];
                title('VLF');
                xlabel('Номер этапа нагрузки');
                ylabel('Значение мощности, мс^2/Гц');

                % LF
                obj.PSD_axes_get_pos_LF = @(fw, fh) [ ...
                            DX*2 + (fw - DX*4) / 3 * 1,	...
                            fh - DY*3 - (fh - DY*4)/3 * 3, ....
                            (fw - DX*4) / 3, ...
                            (fh - DY*4) / 3 ...
                ];
                obj.PSD_axes_LF = axes( ...
                                tab_plots, ...
                                'Units', 'pixels',...
                                'Position', obj.PSD_axes_get_pos_LF(fw, fh));
                            
                obj.PSD_axes_LF.XTick = [1 2 3 4 5];            
                title('LF');
                xlabel('Номер этапа нагрузки');
                ylabel('Значение мощности, мс^2/Гц');

                % HF
                obj.PSD_axes_get_pos_HF = @(fw, fh) [ ...
                            DX*3 + (fw - DX*4) / 3 * 2,	...
                            fh - DY*3 - (fh - DY*4)/3 * 3, ....
                            (fw - DX*4) / 3,  ...
                            (fh - DY*4) / 3 ...
                ];
                obj.PSD_axes_HF = axes( ...
                                tab_plots, ...
                                'Units', 'pixels',...
                                'Position', obj.PSD_axes_get_pos_HF(fw, fh));
                            
                obj.PSD_axes_HF.XTick = [1 2 3 4 5];
                title('HF');
                xlabel('Номер этапа нагрузки');
                ylabel('Значение мощности, мс^2/Гц');

            
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
                        
                        %------------------------- DD scatter ellipse ---------------------------

						axes(obj.DDscatter); hold on; grid on;
						obj.drag_point_DD_a = DragPoint(obj.DDscatter, obj.f);
						obj.drag_point_DD_b = DragPoint(obj.DDscatter, obj.f);
						obj.drag_point_DD_center = DragPoint(obj.DDscatter, obj.f);

						obj.h_DD_a = -1;
						obj.h_DD_b = -1;
						obj.h_DD_ellipse = -1;

						%------------------------- Callbacks ---------------------------

						obj.f.WindowButtonMotionFcn = @(s, e) on_f2_mouse_moution(obj);
						obj.f.WindowButtonDownFcn = @(s, e) on_f2_mouse_down(obj);
						obj.f.WindowButtonUpFcn = @(s, e) on_f2_mouse_up(obj);

						obj.f.WindowButtonMotionFcn = @(s, e) on_f2_mouse_moution(obj);
						obj.f.WindowButtonDownFcn = @(s, e) on_f2_mouse_down(obj);
						obj.f.WindowButtonUpFcn = @(s, e) on_f2_mouse_up(obj);
                        
						obj.f.WindowButtonMotionFcn = @(s, e) on_f2_mouse_moution(obj);
						obj.f.WindowButtonDownFcn = @(s, e) on_f2_mouse_down(obj);
						obj.f.WindowButtonUpFcn = @(s, e) on_f2_mouse_up(obj);
            
						obj.edit_max_diff_RR.Callback = @(s, e) change_intervals_max_diff(obj, s, 'RR');
						obj.edit_max_diff_SS.Callback = @(s, e) change_intervals_max_diff(obj, s, 'SS');
						obj.edit_max_diff_DD.Callback = @(s, e) change_intervals_max_diff(obj, s, 'DD');
						
						obj.ExportBtn.Callback = @(s, e) on_export_btn_click(obj);
						
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
					
					obj.drag_point_DD_a = obj.drag_point_DD_a.OnMouseMove();
					obj.drag_point_DD_b = obj.drag_point_DD_b.OnMouseMove();
					obj.drag_point_DD_center = obj.drag_point_DD_center.OnMouseMove();
					obj.on_point_drag_DD();
					obj.drag_point_DD_a = obj.drag_point_DD_a.UpdateOldPos();
					obj.drag_point_DD_b = obj.drag_point_DD_b.UpdateOldPos();
					obj.drag_point_DD_center = obj.drag_point_DD_center.UpdateOldPos();
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
					
					
					obj.drag_point_DD_a = obj.drag_point_DD_a.OnMouseDown();
					if obj.drag_point_DD_a.IsDragged(), return; end
					
					obj.drag_point_DD_b = obj.drag_point_DD_b.OnMouseDown();
					if obj.drag_point_DD_b.IsDragged(), return; end
					
					obj.drag_point_DD_center = obj.drag_point_DD_center.OnMouseDown();
					if obj.drag_point_DD_center.IsDragged(), return; end
			end

			function on_f2_mouse_up(obj)
					obj.drag_point_RR_a = obj.drag_point_RR_a.OnMouseUp();
					obj.drag_point_RR_b = obj.drag_point_RR_b.OnMouseUp();
					obj.drag_point_RR_center = obj.drag_point_RR_center.OnMouseUp();
					
					obj.drag_point_SS_a = obj.drag_point_SS_a.OnMouseUp();
					obj.drag_point_SS_b = obj.drag_point_SS_b.OnMouseUp();
					obj.drag_point_SS_center = obj.drag_point_SS_center.OnMouseUp();
					
					obj.drag_point_DD_a = obj.drag_point_DD_a.OnMouseUp();
					obj.drag_point_DD_b = obj.drag_point_DD_b.OnMouseUp();
					obj.drag_point_DD_center = obj.drag_point_DD_center.OnMouseUp();
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
			
			function on_point_drag_DD(obj)					
					if ~ishandle(obj.h_DD_a) || ~ishandle(obj.h_DD_b) || ~ishandle(obj.h_DD_ellipse)
							return
					end
					
					if obj.drag_point_DD_a.IsDragged()
							d = (obj.drag_point_DD_a.X + obj.drag_point_DD_a.Y) / 2;
							obj.drag_point_DD_a = obj.drag_point_DD_a.SetPos(d, d);
							
							pa = [obj.drag_point_DD_a.X; obj.drag_point_DD_a.Y];
							pc = [obj.drag_point_DD_center.X; obj.drag_point_DD_center.Y];
							a_pts = [pa, pc + (pc - pa)];  
							obj.h_DD_a.XData = a_pts(1, :);
							obj.h_DD_a.YData = a_pts(2, :);
					elseif obj.drag_point_DD_b.IsDragged()
							db_len = [-1 / sqrt(2); 1 / sqrt(2)]' * [obj.drag_point_DD_b.X; obj.drag_point_DD_b.Y];
							db_x_y = sqrt(db_len^2 / 2);
							db = [-db_x_y; db_x_y];
							
							pc = [obj.drag_point_DD_center.X; obj.drag_point_DD_center.Y];
							pb = pc + db;
							obj.drag_point_DD_b = obj.drag_point_DD_b.SetPos(pb(1), pb(2));
							
							b_pts = [pb, pc + (pc - pb)]; 
							obj.h_DD_b.XData = b_pts(1, :);
							obj.h_DD_b.YData = b_pts(2, :);
					elseif obj.drag_point_DD_center.IsDragged()
							pc = [obj.drag_point_DD_center.X; obj.drag_point_DD_center.Y];
							
							dc_len = [1 / sqrt(2); 1 / sqrt(2)]' * pc;
							dc_x_y = sqrt(dc_len^2 / 2);
							pc_next = [dc_x_y; dc_x_y];
							
							delta_pc = pc_next - [obj.drag_point_DD_center.OldX; obj.drag_point_DD_center.OldY];
							
							obj.drag_point_DD_a = obj.drag_point_DD_a.SetPos( ...
									obj.drag_point_DD_a.OldX + delta_pc(1), ...
									obj.drag_point_DD_a.OldY + delta_pc(2));
							obj.drag_point_DD_b = obj.drag_point_DD_b.SetPos( ...
									obj.drag_point_DD_b.OldX + delta_pc(1), ...
									obj.drag_point_DD_b.OldY + delta_pc(2));
							obj.drag_point_DD_center = obj.drag_point_DD_center.SetPos(pc_next(1), pc_next(2));
							
							obj.h_DD_a.XData = obj.h_DD_a.XData + delta_pc(1);
							obj.h_DD_a.YData = obj.h_DD_a.YData + delta_pc(2);
							
							obj.h_DD_b.XData = obj.h_DD_b.XData + delta_pc(1);
							obj.h_DD_b.YData = obj.h_DD_b.YData + delta_pc(2);
							
							obj.drag_point_DD_a = obj.drag_point_DD_a.MoveToPos();
							obj.drag_point_DD_b = obj.drag_point_DD_b.MoveToPos();
					else
							return;
					end
					
					pa = [obj.drag_point_DD_a.X; obj.drag_point_DD_a.Y];
					pb = [obj.drag_point_DD_b.X; obj.drag_point_DD_b.Y];
					pc = [obj.drag_point_DD_center.X; obj.drag_point_DD_center.Y];
					
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
					obj.h_DD_ellipse.XData = el_pts(1, :);
					obj.h_DD_ellipse.YData = el_pts(2, :);
					
					Data = obj.EllipseTable.Data(1 : 3, 2 : end);
					
					Data{1,3} = 1000 * a * 2; % ell_len
					Data{2,3} = 1000 * b * 2; % ell_wid
					Data{3,3} = 1000 * 1000 * pi * a * b; % square
					
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
				
				obj.DDrg_axes.Position = obj.DDrg_axes_get_pos(fw, fh);
				obj.DDScatter_settings.Position = obj.DDScatter_settings_get_pos(fw, fh);
				obj.DDscatter.Position = obj.DDscatter_get_pos(fw, fh);
				obj.DDpsd_axes.Position = obj.DDpsd_axes_get_pos(fw, fh);
				
				obj.EllipseTable.Position = obj.EllipseTable_get_pos(fw, fh);
				obj.CPSD_axes.Position = obj.CPSD_axes_get_pos(fw, fh);
				obj.PSDTableRR.Position = obj.PSDTableRR_get_pos(fw, fh);
				obj.PSDTableSS.Position = obj.PSDTableSS_get_pos(fw, fh);
				obj.PSDTableDD.Position = obj.PSDTableDD_get_pos(fw, fh);
				
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
				
				
				obj.IndicatorsTableRR.Position = obj.IndicatorsTableRR_get_pos(fw, fh);
				obj.IndicatorsTableSS.Position = obj.IndicatorsTableSS_get_pos(fw, fh);
				obj.IndicatorsTableDD.Position = obj.IndicatorsTableDD_get_pos(fw, fh);
				obj.ExportBtn.Position = obj.ExportBtn_get_pos(fw, fh);
				
				if ~isempty(obj.PSD_axes_legend)
					obj.PSD_axes_legend.Location = 'best';
				end
				if ~isempty(obj.Ellipses_plots_legend)
					obj.Ellipses_plots_legend.Location = 'best';
				end
		end
		
			function b = count_all_graphics(obj)
                PSD_Datas = zeros(3, 3, size(obj.Power_spans_inds, 1));
                Ellipse_Datas = zeros(8, 3, size(obj.Power_spans_inds, 1));

                for n = 1 : size(obj.Power_spans_inds, 1)
                    n_begin = obj.Power_spans_inds(n, 1);
                    n_end = obj.Power_spans_inds(n, 2);
                    obj.Selected_time_span = [obj.Signals.Time(n_begin), obj.Signals.Time(n_end)];
                    [PSD_Data, Ellipse_Data] = obj.count_for_selected_span('RRSSDD', false);
                    
                    if isempty(PSD_Data) || isempty(Ellipse_Data)
                        errordlg("Ошибка в структуре файла", "Не все диапазоны мощности имеют размеченные систолы и R-зубцы");
                        b = false;
                        return;
                    end
                    
                    PSD_Datas(:, :, n) = cell2mat(PSD_Data);
                    Ellipse_Datas(:, :, n) = cell2mat(Ellipse_Data);
                end
                
								% заполнение больших таблиц
								
								% ====== RR =========
								% ell_wid
								obj.IndicatorsTableRR.Data{1, 2} = Ellipse_Datas(2, 1, 1);
								obj.IndicatorsTableRR.Data{2, 2} = Ellipse_Datas(2, 1, 2);
								obj.IndicatorsTableRR.Data{3, 2} = Ellipse_Datas(2, 1, 3);
								obj.IndicatorsTableRR.Data{4, 2} = Ellipse_Datas(2, 1, 4);
								obj.IndicatorsTableRR.Data{5, 2} = Ellipse_Datas(2, 1, 5);
								
								% ell_len
								obj.IndicatorsTableRR.Data{1, 3} = Ellipse_Datas(1, 1, 1);
								obj.IndicatorsTableRR.Data{2, 3} = Ellipse_Datas(1, 1, 2);
								obj.IndicatorsTableRR.Data{3, 3} = Ellipse_Datas(1, 1, 3);
								obj.IndicatorsTableRR.Data{4, 3} = Ellipse_Datas(1, 1, 4);
								obj.IndicatorsTableRR.Data{5, 3} = Ellipse_Datas(1, 1, 5);
								
								% mo
								obj.IndicatorsTableRR.Data{1, 4} = Ellipse_Datas(8, 1, 1);
								obj.IndicatorsTableRR.Data{2, 4} = Ellipse_Datas(8, 1, 2);
								obj.IndicatorsTableRR.Data{3, 4} = Ellipse_Datas(8, 1, 3);
								obj.IndicatorsTableRR.Data{4, 4} = Ellipse_Datas(8, 1, 4);
								obj.IndicatorsTableRR.Data{5, 4} = Ellipse_Datas(8, 1, 5);
								
								% interv_range
								obj.IndicatorsTableRR.Data{1, 5} = Ellipse_Datas(7, 1, 1);
								obj.IndicatorsTableRR.Data{2, 5} = Ellipse_Datas(7, 1, 2);
								obj.IndicatorsTableRR.Data{3, 5} = Ellipse_Datas(7, 1, 3);
								obj.IndicatorsTableRR.Data{4, 5} = Ellipse_Datas(7, 1, 4);
								obj.IndicatorsTableRR.Data{5, 5} = Ellipse_Datas(7, 1, 5);
								
								% interv_min
								obj.IndicatorsTableRR.Data{1, 6} = Ellipse_Datas(5, 1, 1);
								obj.IndicatorsTableRR.Data{2, 6} = Ellipse_Datas(5, 1, 2);
								obj.IndicatorsTableRR.Data{3, 6} = Ellipse_Datas(5, 1, 3);
								obj.IndicatorsTableRR.Data{4, 6} = Ellipse_Datas(5, 1, 4);
								obj.IndicatorsTableRR.Data{5, 6} = Ellipse_Datas(5, 1, 5);
								
								% interv_max
								obj.IndicatorsTableRR.Data{1, 7} = Ellipse_Datas(6, 1, 1);
								obj.IndicatorsTableRR.Data{2, 7} = Ellipse_Datas(6, 1, 2);
								obj.IndicatorsTableRR.Data{3, 7} = Ellipse_Datas(6, 1, 3);
								obj.IndicatorsTableRR.Data{4, 7} = Ellipse_Datas(6, 1, 4);
								obj.IndicatorsTableRR.Data{5, 7} = Ellipse_Datas(6, 1, 5);
								
								% square
								obj.IndicatorsTableRR.Data{1, 8} = Ellipse_Datas(3, 1, 1);
								obj.IndicatorsTableRR.Data{2, 8} = Ellipse_Datas(3, 1, 2);
								obj.IndicatorsTableRR.Data{3, 8} = Ellipse_Datas(3, 1, 3);
								obj.IndicatorsTableRR.Data{4, 8} = Ellipse_Datas(3, 1, 4);
								obj.IndicatorsTableRR.Data{5, 8} = Ellipse_Datas(3, 1, 5);
								
								% m_sr
								obj.IndicatorsTableRR.Data{1, 9} = Ellipse_Datas(4, 1, 1);
								obj.IndicatorsTableRR.Data{2, 9} = Ellipse_Datas(4, 1, 2);
								obj.IndicatorsTableRR.Data{3, 9} = Ellipse_Datas(4, 1, 3);
								obj.IndicatorsTableRR.Data{4, 9} = Ellipse_Datas(4, 1, 4);
								obj.IndicatorsTableRR.Data{5, 9} = Ellipse_Datas(4, 1, 5);
								
								% VLF
								obj.IndicatorsTableRR.Data{1, 10} = PSD_Datas(1, 1, 1);
								obj.IndicatorsTableRR.Data{2, 10} = PSD_Datas(1, 1, 2);
								obj.IndicatorsTableRR.Data{3, 10} = PSD_Datas(1, 1, 3);
								obj.IndicatorsTableRR.Data{4, 10} = PSD_Datas(1, 1, 4);
								obj.IndicatorsTableRR.Data{5, 10} = PSD_Datas(1, 1, 5);
								
								% LF
								obj.IndicatorsTableRR.Data{1, 11} = PSD_Datas(2, 1, 1);
								obj.IndicatorsTableRR.Data{2, 11} = PSD_Datas(2, 1, 2);
								obj.IndicatorsTableRR.Data{3, 11} = PSD_Datas(2, 1, 3);
								obj.IndicatorsTableRR.Data{4, 11} = PSD_Datas(2, 1, 4);
								obj.IndicatorsTableRR.Data{5, 11} = PSD_Datas(2, 1, 5);
								
								% HF
								obj.IndicatorsTableRR.Data{1, 12} = PSD_Datas(3, 1, 1);
								obj.IndicatorsTableRR.Data{2, 12} = PSD_Datas(3, 1, 2);
								obj.IndicatorsTableRR.Data{3, 12} = PSD_Datas(3, 1, 3);
								obj.IndicatorsTableRR.Data{4, 12} = PSD_Datas(3, 1, 4);
								obj.IndicatorsTableRR.Data{5, 12} = PSD_Datas(3, 1, 5);
								
								
								% ====== SS =========
								% ell_wid
								obj.IndicatorsTableSS.Data{1, 2} = Ellipse_Datas(2, 2, 1);
								obj.IndicatorsTableSS.Data{2, 2} = Ellipse_Datas(2, 2, 2);
								obj.IndicatorsTableSS.Data{3, 2} = Ellipse_Datas(2, 2, 3);
								obj.IndicatorsTableSS.Data{4, 2} = Ellipse_Datas(2, 2, 4);
								obj.IndicatorsTableSS.Data{5, 2} = Ellipse_Datas(2, 2, 5);
								
								% ell_len
								obj.IndicatorsTableSS.Data{1, 3} = Ellipse_Datas(1, 2, 1);
								obj.IndicatorsTableSS.Data{2, 3} = Ellipse_Datas(1, 2, 2);
								obj.IndicatorsTableSS.Data{3, 3} = Ellipse_Datas(1, 2, 3);
								obj.IndicatorsTableSS.Data{4, 3} = Ellipse_Datas(1, 2, 4);
								obj.IndicatorsTableSS.Data{5, 3} = Ellipse_Datas(1, 2, 5);
								
								% mo
								obj.IndicatorsTableSS.Data{1, 4} = Ellipse_Datas(8, 2, 1);
								obj.IndicatorsTableSS.Data{2, 4} = Ellipse_Datas(8, 2, 2);
								obj.IndicatorsTableSS.Data{3, 4} = Ellipse_Datas(8, 2, 3);
								obj.IndicatorsTableSS.Data{4, 4} = Ellipse_Datas(8, 2, 4);
								obj.IndicatorsTableSS.Data{5, 4} = Ellipse_Datas(8, 2, 5);
								
								% interv_range
								obj.IndicatorsTableSS.Data{1, 5} = Ellipse_Datas(7, 2, 1);
								obj.IndicatorsTableSS.Data{2, 5} = Ellipse_Datas(7, 2, 2);
								obj.IndicatorsTableSS.Data{3, 5} = Ellipse_Datas(7, 2, 3);
								obj.IndicatorsTableSS.Data{4, 5} = Ellipse_Datas(7, 2, 4);
								obj.IndicatorsTableSS.Data{5, 5} = Ellipse_Datas(7, 2, 5);
								
								% interv_min
								obj.IndicatorsTableSS.Data{1, 6} = Ellipse_Datas(5, 2, 1);
								obj.IndicatorsTableSS.Data{2, 6} = Ellipse_Datas(5, 2, 2);
								obj.IndicatorsTableSS.Data{3, 6} = Ellipse_Datas(5, 2, 3);
								obj.IndicatorsTableSS.Data{4, 6} = Ellipse_Datas(5, 2, 4);
								obj.IndicatorsTableSS.Data{5, 6} = Ellipse_Datas(5, 2, 5);
								
								% interv_max
								obj.IndicatorsTableSS.Data{1, 7} = Ellipse_Datas(6, 2, 1);
								obj.IndicatorsTableSS.Data{2, 7} = Ellipse_Datas(6, 2, 2);
								obj.IndicatorsTableSS.Data{3, 7} = Ellipse_Datas(6, 2, 3);
								obj.IndicatorsTableSS.Data{4, 7} = Ellipse_Datas(6, 2, 4);
								obj.IndicatorsTableSS.Data{5, 7} = Ellipse_Datas(6, 2, 5);
								
								% square
								obj.IndicatorsTableSS.Data{1, 8} = Ellipse_Datas(3, 2, 1);
								obj.IndicatorsTableSS.Data{2, 8} = Ellipse_Datas(3, 2, 2);
								obj.IndicatorsTableSS.Data{3, 8} = Ellipse_Datas(3, 2, 3);
								obj.IndicatorsTableSS.Data{4, 8} = Ellipse_Datas(3, 2, 4);
								obj.IndicatorsTableSS.Data{5, 8} = Ellipse_Datas(3, 2, 5);
								
								% m_sr
								obj.IndicatorsTableSS.Data{1, 9} = Ellipse_Datas(4, 2, 1);
								obj.IndicatorsTableSS.Data{2, 9} = Ellipse_Datas(4, 2, 2);
								obj.IndicatorsTableSS.Data{3, 9} = Ellipse_Datas(4, 2, 3);
								obj.IndicatorsTableSS.Data{4, 9} = Ellipse_Datas(4, 2, 4);
								obj.IndicatorsTableSS.Data{5, 9} = Ellipse_Datas(4, 2, 5);
								
								% VLF
								obj.IndicatorsTableSS.Data{1, 10} = PSD_Datas(1, 2, 1);
								obj.IndicatorsTableSS.Data{2, 10} = PSD_Datas(1, 2, 2);
								obj.IndicatorsTableSS.Data{3, 10} = PSD_Datas(1, 2, 3);
								obj.IndicatorsTableSS.Data{4, 10} = PSD_Datas(1, 2, 4);
								obj.IndicatorsTableSS.Data{5, 10} = PSD_Datas(1, 2, 5);
								
								% LF
								obj.IndicatorsTableSS.Data{1, 11} = PSD_Datas(2, 2, 1);
								obj.IndicatorsTableSS.Data{2, 11} = PSD_Datas(2, 2, 2);
								obj.IndicatorsTableSS.Data{3, 11} = PSD_Datas(2, 2, 3);
								obj.IndicatorsTableSS.Data{4, 11} = PSD_Datas(2, 2, 4);
								obj.IndicatorsTableSS.Data{5, 11} = PSD_Datas(2, 2, 5);
								
								% HF
								obj.IndicatorsTableSS.Data{1, 12} = PSD_Datas(3, 2, 1);
								obj.IndicatorsTableSS.Data{2, 12} = PSD_Datas(3, 2, 2);
								obj.IndicatorsTableSS.Data{3, 12} = PSD_Datas(3, 2, 3);
								obj.IndicatorsTableSS.Data{4, 12} = PSD_Datas(3, 2, 4);
								obj.IndicatorsTableSS.Data{5, 12} = PSD_Datas(3, 2, 5);
								
								% ====== DD =========
								% ell_wid
								obj.IndicatorsTableDD.Data{1, 2} = Ellipse_Datas(2, 3, 1);
								obj.IndicatorsTableDD.Data{2, 2} = Ellipse_Datas(2, 3, 2);
								obj.IndicatorsTableDD.Data{3, 2} = Ellipse_Datas(2, 3, 3);
								obj.IndicatorsTableDD.Data{4, 2} = Ellipse_Datas(2, 3, 4);
								obj.IndicatorsTableDD.Data{5, 2} = Ellipse_Datas(2, 3, 5);
								
								% ell_len
								obj.IndicatorsTableDD.Data{1, 3} = Ellipse_Datas(1, 3, 1);
								obj.IndicatorsTableDD.Data{2, 3} = Ellipse_Datas(1, 3, 2);
								obj.IndicatorsTableDD.Data{3, 3} = Ellipse_Datas(1, 3, 3);
								obj.IndicatorsTableDD.Data{4, 3} = Ellipse_Datas(1, 3, 4);
								obj.IndicatorsTableDD.Data{5, 3} = Ellipse_Datas(1, 3, 5);
								
								% mo
								obj.IndicatorsTableDD.Data{1, 4} = Ellipse_Datas(8, 3, 1);
								obj.IndicatorsTableDD.Data{2, 4} = Ellipse_Datas(8, 3, 2);
								obj.IndicatorsTableDD.Data{3, 4} = Ellipse_Datas(8, 3, 3);
								obj.IndicatorsTableDD.Data{4, 4} = Ellipse_Datas(8, 3, 4);
								obj.IndicatorsTableDD.Data{5, 4} = Ellipse_Datas(8, 3, 5);
								
								% interv_range
								obj.IndicatorsTableDD.Data{1, 5} = Ellipse_Datas(7, 3, 1);
								obj.IndicatorsTableDD.Data{2, 5} = Ellipse_Datas(7, 3, 2);
								obj.IndicatorsTableDD.Data{3, 5} = Ellipse_Datas(7, 3, 3);
								obj.IndicatorsTableDD.Data{4, 5} = Ellipse_Datas(7, 3, 4);
								obj.IndicatorsTableDD.Data{5, 5} = Ellipse_Datas(7, 3, 5);
								
								% interv_min
								obj.IndicatorsTableDD.Data{1, 6} = Ellipse_Datas(5, 3, 1);
								obj.IndicatorsTableDD.Data{2, 6} = Ellipse_Datas(5, 3, 2);
								obj.IndicatorsTableDD.Data{3, 6} = Ellipse_Datas(5, 3, 3);
								obj.IndicatorsTableDD.Data{4, 6} = Ellipse_Datas(5, 3, 4);
								obj.IndicatorsTableDD.Data{5, 6} = Ellipse_Datas(5, 3, 5);
								
								% interv_max
								obj.IndicatorsTableDD.Data{1, 7} = Ellipse_Datas(6, 3, 1);
								obj.IndicatorsTableDD.Data{2, 7} = Ellipse_Datas(6, 3, 2);
								obj.IndicatorsTableDD.Data{3, 7} = Ellipse_Datas(6, 3, 3);
								obj.IndicatorsTableDD.Data{4, 7} = Ellipse_Datas(6, 3, 4);
								obj.IndicatorsTableDD.Data{5, 7} = Ellipse_Datas(6, 3, 5);
								
								% square
								obj.IndicatorsTableDD.Data{1, 8} = Ellipse_Datas(3, 3, 1);
								obj.IndicatorsTableDD.Data{2, 8} = Ellipse_Datas(3, 3, 2);
								obj.IndicatorsTableDD.Data{3, 8} = Ellipse_Datas(3, 3, 3);
								obj.IndicatorsTableDD.Data{4, 8} = Ellipse_Datas(3, 3, 4);
								obj.IndicatorsTableDD.Data{5, 8} = Ellipse_Datas(3, 3, 5);
								
								% m_sr
								obj.IndicatorsTableDD.Data{1, 9} = Ellipse_Datas(4, 3, 1);
								obj.IndicatorsTableDD.Data{2, 9} = Ellipse_Datas(4, 3, 2);
								obj.IndicatorsTableDD.Data{3, 9} = Ellipse_Datas(4, 3, 3);
								obj.IndicatorsTableDD.Data{4, 9} = Ellipse_Datas(4, 3, 4);
								obj.IndicatorsTableDD.Data{5, 9} = Ellipse_Datas(4, 3, 5);
								
								% VLF
								obj.IndicatorsTableDD.Data{1, 10} = PSD_Datas(1, 3, 1);
								obj.IndicatorsTableDD.Data{2, 10} = PSD_Datas(1, 3, 2);
								obj.IndicatorsTableDD.Data{3, 10} = PSD_Datas(1, 3, 3);
								obj.IndicatorsTableDD.Data{4, 10} = PSD_Datas(1, 3, 4);
								obj.IndicatorsTableDD.Data{5, 10} = PSD_Datas(1, 3, 5);
								
								% LF
								obj.IndicatorsTableDD.Data{1, 11} = PSD_Datas(2, 3, 1);
								obj.IndicatorsTableDD.Data{2, 11} = PSD_Datas(2, 3, 2);
								obj.IndicatorsTableDD.Data{3, 11} = PSD_Datas(2, 3, 3);
								obj.IndicatorsTableDD.Data{4, 11} = PSD_Datas(2, 3, 4);
								obj.IndicatorsTableDD.Data{5, 11} = PSD_Datas(2, 3, 5);
								
								% HF
								obj.IndicatorsTableDD.Data{1, 12} = PSD_Datas(3, 3, 1);
								obj.IndicatorsTableDD.Data{2, 12} = PSD_Datas(3, 3, 2);
								obj.IndicatorsTableDD.Data{3, 12} = PSD_Datas(3, 3, 3);
								obj.IndicatorsTableDD.Data{4, 12} = PSD_Datas(3, 3, 4);
								obj.IndicatorsTableDD.Data{5, 12} = PSD_Datas(3, 3, 5);
								
				% характеристики спектра
                axes(obj.PSD_axes_VLF); cla; hold on; grid on; 
                stem(reshape(PSD_Datas(1, 1, :), 1, 5),'filled');
                %stem(reshape(PSD_Datas(1, 2, :), 1, 5));
                
                axes(obj.PSD_axes_LF); cla; hold on; grid on;
                stem(reshape(PSD_Datas(2, 1, :), 1, 5),'filled');
                %stem(reshape(PSD_Datas(2, 2, :), 1, 5));
                
                axes(obj.PSD_axes_HF); cla; hold on; grid on;
                stem(reshape(PSD_Datas(3, 1, :), 1, 5),'filled');
                %stem(reshape(PSD_Datas(3, 2, :), 1, 5));
                %obj.PSD_axes_legend = legend(["VLF ЭКГ", "VLF АД", "LF ЭКГ", "LF АД", "HF ЭКГ", "HF АД"], ...
                    %'Location', 'best');
                
				% характеристики эллипсов
                axes(obj.Ellipses_plots_len); cla; hold on; grid on;        
                stem(reshape(Ellipse_Datas(1, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(1, 2, :), 1, 5));
                
                axes(obj.Ellipses_plots_wid); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(2, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(2, 2, :), 1, 5));

                axes(obj.Ellipses_plots_sq); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(3, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(3, 2, :), 1, 5));

                axes(obj.Ellipses_plots_Mcp); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(4, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(4, 2, :), 1, 5));

                axes(obj.Ellipses_plots_min); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(5, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(5, 2, :), 1, 5));

                axes(obj.Ellipses_plots_max); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(6, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(6, 2, :), 1, 5));

                axes(obj.Ellipses_plots_range); cla; grid on; hold on;
                stem(reshape(Ellipse_Datas(7, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(7, 2, :), 1, 5));

                axes(obj.Ellipses_plots_Mo); cla; grid on; hold on;        
                stem(reshape(Ellipse_Datas(8, 1, :), 1, 5),'filled');
                %stem(reshape(Ellipse_Datas(8, 2, :), 1, 5));
                
%                 obj.Ellipses_plots_legend = legend([ ...
%                     "Длина облака ЭКГ, мс",     
%                     "Ширина облака ЭКГ, мс",    
%                     "Площадь облака ЭКГ, мс^2", 
%                     "Мср ЭКГ, мс",              
%                     "RR(SS)_min ЭКГ, мс",       
%                     "RR(SS)_max ЭКГ, мс",       
%                     "Размах RR(SS) ЭКГ, мс",    
%                     "Mo ЭКГ, мс",               
%                 ], ...
%                     'Location', 'best', 'NumColumns', 5);

				...

                n_begin = obj.Power_spans_inds(n, 1);
                n_end = obj.Power_spans_inds(n, 2);
                obj.Selected_time_span = [obj.Signals.Time(n_begin), obj.Signals.Time(n_end)];
                obj.draw_ritmograms_and_power(1);
                obj.count_for_selected_span('RRSSDD', true);
                
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
							obj.SS_max_diff, ...
							obj.DD_max_diff);

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
									obj.count_for_selected_span('RRSSDD', true);
									break;
							end
					end	
			end

			function change_intervals_max_diff(obj, s, signal_name)
					value = str2double(s.String);
					if isnan(value)
							errordlg('Необходимо ввести число');
							return;
					end
					
					if strcmp(signal_name, 'RR')
							if value < 0 || value > 100
									errordlg('Необходимо ввести дробное число от 0 до 100');
									return;
							end
							obj.RR_max_diff = value / 100;
					elseif strcmp(signal_name, 'SS')
							if value < 0 || value > 10
									errordlg('Необходимо ввести целое число от 0 до 10');
									return;
							end
							obj.SS_max_diff = value;
					elseif strcmp(signal_name, 'DD')
							if value < 0 || value > 10
									errordlg('Необходимо ввести целое число от 0 до 10');
									return;
							end
							obj.DD_max_diff = value;
					else
							assert(false);
					end
					
					obj.count_for_selected_span(signal_name, true);
			end

        function on_export_btn_click(obj)
            [file, path] = uiputfile('*.xlsx', 'Экспорт', [obj.Signals.Name, ' export']);
            
            if isfloat(file) || isfloat(path)
                return;
            end
            
            filename = [path, file];
        
            range = 'A1:L6';
						
            writetable( ...
                table( ...
                    obj.IndicatorsTableRR.Data(1 : 5, 1), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 2), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 3), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 4), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 5), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 6), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 7), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 8), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 9), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 10), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 11), ...
                    obj.IndicatorsTableRR.Data(1 : 5, 12), ...
                    'VariableNames', { ...
											'№ этапа', ...
											'Ширина облака, мс', ...
											'Длина облака, мс', ...
											'Mo, мс', ...
											'Размах RR, мс', ...
											'RR мин мс', ...
											'RR макс мс', ...
											'Площадь облака, мс^2', ...
											'Мср, мс', ...
											'VLF', ...
											'LF', ...
											'HF', ...
									} ...
                ), ...
                filename, ...
                'Sheet', 'RR', ...
                'Range', range);
						
            writetable( ...
                table( ...
                    obj.IndicatorsTableSS.Data(1 : 5, 1), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 2), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 3), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 4), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 5), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 6), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 7), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 8), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 9), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 10), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 11), ...
                    obj.IndicatorsTableSS.Data(1 : 5, 12), ...
                    'VariableNames', { ...
											'№ этапа', ...
											'Ширина облака, мм рт. ст.', ...
											'Длина облака, мм рт. ст.', ...
											'Mo, мм рт. ст.', ...
											'Размах SS, мм рт. ст.', ...
											'SS мин, мм рт. ст.', ...
											'SS макс, мм рт. ст.', ...
											'Площадь облака, (мм рт. ст.)^2', ...
											'Мср, мм рт. ст.', ...
											'VLF, (мм рт. ст.)^2', ...
											'LF, (мм рт. ст.)^2', ...
											'HF, (мм рт. ст.)^2', ...
									} ...
                ), ...
                filename, ...
                'Sheet', 'SS', ...
                'Range', range);
						
            writetable( ...
                table( ...
                    obj.IndicatorsTableDD.Data(1 : 5, 1), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 2), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 3), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 4), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 5), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 6), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 7), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 8), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 9), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 10), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 11), ...
                    obj.IndicatorsTableDD.Data(1 : 5, 12), ...
                    'VariableNames', { ...
											'№ этапа', ...
											'Ширина облака, мм рт. ст.', ...
											'Длина облака, мм рт. ст.', ...
											'Mo, мм рт. ст.', ...
											'Размах SS, мм рт. ст.', ...
											'SS мин, мм рт. ст.', ...
											'SS макс, мм рт. ст.', ...
											'Площадь облака, (мм рт. ст.)^2', ...
											'Мср, мм рт. ст.', ...
											'VLF, (мм рт. ст.)^2', ...
											'LF, (мм рт. ст.)^2', ...
											'HF, (мм рт. ст.)^2', ...
									} ...
                ), ...
                filename, ...
                'Sheet', 'DD', ...
                'Range', range);
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
				obj.text_max_diff_DD.Enable = 'on';
                obj.edit_max_diff_DD.Enable = 'on';
            end

            t = obj.Signals.Time;

            t_span = t(t >= obj.Selected_time_span(1) & t <= obj.Selected_time_span(2));

            [RRx, RRy, SSx, SSy, DDx, DDy, RRx_old, RRy_old, SSx_old, SSy_old, DDx_old, DDy_old] = calc_ritmogramms( ...
                    obj.Signals, ...
                    t_span, ...
                    obj.RR_max_diff, ...
                    obj.SS_max_diff,...
                    obj.DD_max_diff);
                
            if isempty(RRx) || isempty(RRy) || isempty(SSx) || isempty(SSy) || isempty(DDx) || isempty(DDy)
                PSD_Data = [];
                Ellipse_Data = [];
                return;
            end

            [RRpsd_f, RRpsd, SSpsd_f, SSpsd, DDpsd_f, DDpsd, CPSD, CPSD_f, RR_VLF, RR_LF, RR_HF, SS_VLF, SS_LF, SS_HF, DD_VLF, DD_LF, DD_HF] = calc_psd_welch_an_cpsd( ...
                    t_span, RRx, RRy, SSx, SSy, DDx, DDy);

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
                    obj.h_RR_a = plot(ax, ay, 'c', 'LineWidth', 2);
                    obj.h_RR_b = plot(bx, by, 'm', 'LineWidth', 2);
                    obj.h_RR_ellipse = plot(el_x, el_y, 'r', 'LineWidth', 2);

                    obj.drag_point_RR_a = obj.drag_point_RR_a.Draw(ax(end), ay(end));
                    obj.drag_point_RR_b = obj.drag_point_RR_b.Draw(bx(end), by(end));
                    obj.drag_point_RR_center = obj.drag_point_RR_center.Draw(x0, y0);    

                    range = max(RRy_old) - min(RRy_old);

                    xlim([min(RRy_old) - range * 0.4, min(RRy_old) + range * 1.4]);
                    ylim([min(RRy_old) - range * 0.4, min(RRy_old) + range * 1.4]);
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
                    xlabel('Давление, мм рт. ст.');
                    ylabel('Давление, мм рт. ст.');

                    axes(obj.SSpsd_axes); cla; hold on; grid on;
                    plot(SSpsd_f, SSpsd);

                    axes(obj.CPSD_axes); cla; hold on; grid on;
                    plot(CPSD_f, CPSD);

                    axes(obj.SSscatter); cla; hold on; grid on;
                    plot(SSy_old(1 : end - 1), SSy_old(2 : end), '.k');
                    plot(SSy(1 : end - 1), SSy(2 : end), 'ob');
                    obj.h_SS_a = plot(ax, ay, 'c', 'LineWidth', 2);
                    obj.h_SS_b = plot(bx, by, 'm', 'LineWidth', 2);
                    obj.h_SS_ellipse = plot(el_x, el_y, 'r', 'LineWidth', 2);

                    obj.drag_point_SS_a = obj.drag_point_SS_a.Draw(ax(end), ay(end));
                    obj.drag_point_SS_b = obj.drag_point_SS_b.Draw(bx(end), by(end));
                    obj.drag_point_SS_center = obj.drag_point_SS_center.Draw(x0, y0);   

                    range = max(SSy_old) - min(SSy_old);

                    xlim([min(SSy_old) - range * 0.4, min(SSy_old) + range * 1.4]);
                    ylim([min(SSy_old) - range * 0.4, min(SSy_old) + range * 1.4]);
                end

                Ellipse_Data{1, 2} = el_params_SS.ell_len;
                Ellipse_Data{2, 2} = el_params_SS.ell_wid;
                Ellipse_Data{3, 2} = el_params_SS.square;
                Ellipse_Data{4, 2} = el_params_SS.m_sr;
                Ellipse_Data{5, 2} = el_params_SS.interv_min;
                Ellipse_Data{6, 2} = el_params_SS.interv_max;
                Ellipse_Data{7, 2} = el_params_SS.interv_range;
                Ellipse_Data{8, 2} = el_params_SS.mo;
            end
			
			if contains(to_recount, 'DD')
                [sc_x, sc_y, el_x, el_y, el_params_DD, ax, ay, bx, by, x0, y0] = calc_scatter_ellipse(DDy);

                if do_plotting
                    axes(obj.DDrg_axes); cla; hold on; grid on;
                    stem(DDx_old, DDy_old, '.b');
                    stem(DDx, DDy, '.r');
                    xlabel('Давление, мм рт. ст.');
                    ylabel('Давление, мм рт. ст.');

                    axes(obj.DDpsd_axes); cla; hold on; grid on;
                    plot(DDpsd_f, DDpsd);

                    axes(obj.CPSD_axes); cla; hold on; grid on;
                    plot(CPSD_f, CPSD);

                    axes(obj.DDscatter); cla; hold on; grid on;
                    plot(DDy_old(1 : end - 1), DDy_old(2 : end), '.k');
                    plot(DDy(1 : end - 1), DDy(2 : end), 'ob');
                    obj.h_DD_a = plot(ax, ay, 'c', 'LineWidth', 2);
                    obj.h_DD_b = plot(bx, by, 'm', 'LineWidth', 2);
                    obj.h_DD_ellipse = plot(el_x, el_y, 'r', 'LineWidth', 2);

                    obj.drag_point_DD_a = obj.drag_point_DD_a.Draw(ax(end), ay(end));
                    obj.drag_point_DD_b = obj.drag_point_DD_b.Draw(bx(end), by(end));
                    obj.drag_point_DD_center = obj.drag_point_DD_center.Draw(x0, y0);   

                    range = max(DDy_old) - min(DDy_old);

                    xlim([min(DDy_old) - range * 0.4, min(DDy_old) + range * 1.4]);
                    ylim([min(DDy_old) - range * 0.4, min(DDy_old) + range * 1.4]);
                end

                Ellipse_Data{1, 3} = el_params_DD.ell_len;
                Ellipse_Data{2, 3} = el_params_DD.ell_wid;
                Ellipse_Data{3, 3} = el_params_DD.square;
                Ellipse_Data{4, 3} = el_params_DD.m_sr;
                Ellipse_Data{5, 3} = el_params_DD.interv_min;
                Ellipse_Data{6, 3} = el_params_DD.interv_max;
                Ellipse_Data{7, 3} = el_params_DD.interv_range;
                Ellipse_Data{8, 3} = el_params_DD.mo;
            end
			
            if do_plotting
                obj.EllipseTable.Data(:, 2 : end) = Ellipse_Data;
            end
						
						PSD_Data = cell(3, 3);

            PSD_Data{1, 1} = RR_VLF;
            PSD_Data{2, 1} = RR_LF;
            PSD_Data{3, 1} = RR_HF;
						
            PSD_Data{1, 2} = SS_VLF;
            PSD_Data{2, 2} = SS_LF;
            PSD_Data{3, 2} = SS_HF;
						
            PSD_Data{1, 3} = DD_VLF;
            PSD_Data{2, 3} = DD_LF;
            PSD_Data{3, 3} = DD_HF;

            if do_plotting
                obj.PSDTableRR.Data(:, 2) = PSD_Data(:, 1);
                obj.PSDTableRR.ColumnWidth = 'fit';
								
                obj.PSDTableSS.Data(:, 2) = PSD_Data(:, 2);
                obj.PSDTableSS.ColumnWidth = 'fit';
								
                obj.PSDTableDD.Data(:, 2) = PSD_Data(:, 3);
                obj.PSDTableDD.ColumnWidth = 'fit';
            end
        end
    end
end

