[filename, pathname]= uigetfile({'*.csv','CSV files (*.csv)'}, 'Выберите файл');

if isempty(filename) || isempty(pathname)
    return
end

path = [pathname, filename];

content = read_file(path);

%%

content = read_file('C:\Users\Роман\Dropbox\_Мага 1\Сем 4\Халтура\Ангелина\task_3\Experimental_Data\Обструкция\Хорионовская_15-03-18(17-01-58)_All.csv');

%%

f = figure(1); clf, hold on, grid on;
f.SizeChangedFcn = @on_window_size_changed;
tiledlayout(3, 1);

t = content.Time;

% Вектор флагов R-зубцов переводим в логический формат
RR_inds = logical(content.R_Pik);
% Вектор значений времени для R-зубцов
RR_starts = t(RR_inds);
% Вектор длин RR-интервалов
RR_lenghts = diff(RR_starts); % [R2-R1, R3-R2, R4-R3, ...]
% Последний R-зубец сигнала не является началом следующего RR-интервала (потому что 
% следующего RR-интервала нет), поэтому не берем его
RR_starts = RR_starts(1 : end - 1);

nexttile;
stem(RR_starts, RR_lenghts);
title('Ритмограмма ЭКГ')

ABP_S_inds = logical(content.Sis);
ABP_S_starts = t(ABP_S_inds);
ABP_S_lenghts = diff(ABP_S_starts);
ABP_S_starts = ABP_S_starts(1 : end - 1);

nexttile;
stem(ABP_S_starts, ABP_S_lenghts);
title('Ритмограмма АД')

nexttile;
power = content.Power;
plot(t, power);

function on_window_size_changed(hui, hui2)
    disp(hui);
    disp(hui2);
end