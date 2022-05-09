clearvars;
close all;
clc;

global viewers
viewers = [];

f = figure(1); clf;
f.SizeChangedFcn = @(s, e) on_main_figure_size_changed(s);
f.Name = 'Программный комплекс графического анализа сердечного ритма';

DX = 40;
DY = 60;

fw = f.Position(3);
fh = f.Position(4);

global btn_new btn_new_get_pos patients_table patients_table_get_pos

btn_new_get_pos = @(fw, fh) [ ...
    5,         fh - 35, ...
    200,  30 ...
];
btn_new = uicontrol('Style','PushButton', ...
        'Units','pixels',...
        'String','Открыть новый файл');
btn_new.Position = btn_new_get_pos(fw, fh);
btn_new.Callback = @(s, e) open_new_viewer();

patients_table_get_pos = @(fw, fh) [ ...
    5,         5, ...
    fw-5*2,  fh-5*2 - 40 ...
];
patients_table = uitable( ...
        'Units', 'pixels',...
        'Position', patients_table_get_pos(fw, fh));
patients_table.ColumnEditable = false;
patients_table.ColumnName = { 'Файл данных пациента' };
patients_table.ColumnWidth = {500};
patients_table.Data = cell(0, 1);
patients_table.CellSelectionCallback = @(s, e) on_table_cell_click(e);

%--------------------------- Main figure callbacks ----------------------

function on_main_figure_size_changed(f)
    global patients_table patients_table_get_pos ...
            btn_new btn_new_get_pos
        
    fw = f.Position(3);
    fh = f.Position(4);
    
    patients_table.Position = patients_table_get_pos(fw, fh);
    btn_new.Position = btn_new_get_pos(fw, fh);
end

function open_new_viewer()
    [filename, pathname] = uigetfile({'*.csv','CSV files (*.csv)'}, 'Выберите файл');

    if isfloat(filename) || isfloat(pathname)
        return;
    end
		
    global viewers patients_table
    w = Viewer();
    if ~w.load_file(pathname, filename)
        w.close();
        return;
    end
		
    viewers = [viewers, w];
    w.f.CloseRequestFcn = @(s, e) on_wiever_closed(w);
    data = patients_table.Data;
    if isempty(data)
        data = cell(1, 1);
        data{1, 1} = filename;
    else
        data{end + 1, 1} = filename;
    end
    patients_table.Data = data;
end

function on_table_cell_click(e)
    global viewers
    if size(e.Indices) < 1, return; end
    w_i = e.Indices(1);
    figure(viewers(w_i).f)
end

function on_wiever_closed(w)
    global viewers patients_table
    for n = 1 : length(viewers)
        if viewers(n).f.Number == w.f.Number
            viewers(n) = [];
            data = patients_table.Data;
            data(n, :) = [];
            patients_table.Data = data;
            break;
        end
    end

    close force;
end