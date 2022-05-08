function content = read_file(path)
    f_id = fopen(path, 'r');
    
    % Имя пациента и дата снятия сигнала
    content.Name = strtrim(fgetl(f_id));
    % Набор сигналов в файле
    columns = strtrim(fgetl(f_id));
    if columns(end) == ';'
        columns = columns(1 : end - 1);
    end
    
    columns = split(columns, ';', 1);

    fclose(f_id);
    
    % Читаем весь файл
    text = fileread(path);
    
    % находим позиции всех '\n'
    pos = strfind(text, newline);
    
    % берем после второго '\n', то есть с 3-й строки
    text = extractAfter(text, pos(2));
    
    % заменяем запятые в дробных числах на точки, потому что матлаб русофобен
    text = replace(text, ",", ".");
    
    tmp_path = strcat(path, '.txt');
    
    f_id = fopen(tmp_path, 'w');
    fprintf(f_id, '%s', text);
    fclose(f_id);
    
    mat = readmatrix(tmp_path);
    delete(tmp_path); 
    
    for col_num = 1 : length(columns)
        content.(columns{col_num}) =  mat(:, col_num);
    end
    
    content.Time = content.Time ./ 1000;
end

