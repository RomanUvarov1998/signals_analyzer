function [RRpsd_f, RRpsd, SSpsd_f, SSpsd, CPSD, CPSD_f] = calc_psd_welch_an_cpsd(t, RRx, RRy, SSx, SSy)
    w = 100;
    noverlap = round(w .* 0.5);
    nfft = 128;
    
    Fs = 4; % Hz
    Ts = 1 / Fs; % sec
    t_interp = min([RRx; SSx]) : Ts : max([RRx; SSx]);
    
    % Переводим сек в мс
    RRx = RRx .* 1000;
    RRy = RRy .* 1000;
    SSx = SSx .* 1000;
    SSy = SSy .* 1000;
    t_interp = t_interp .* 1000;
    % Переводим Гц в кГц
    Fs = Fs .* 1000;
    
    % Интерполяция ритмограммы для промежутка времени от начала первого
    % RR-интервала до конца последнего RR-интервала
    % параметр сглаживания выбран равным 1, потому что при нем кривая идет через все точки
    pol_info = csaps(RRx, RRy, 1);
    RR_int = ppval(pol_info, t_interp);
    
    pol_info = csaps(SSx, SSy, 1);
    SS_int = ppval(pol_info, t_interp);
    
%     figure(3); clf; tiledlayout(2, 1);
%     
%     nexttile; cla; hold on; grid on;
%     stem(RRx, RRy);
%     plot(t_interp, RR_int);
%     
%     nexttile; cla; hold on; grid on;
%     stem(SSx, SSy);
%     plot(t_interp, SS_int);
    
    % Убираем постоянную составляющую и линейный тренд
    RR_int = detrend(RR_int);
    SS_int = detrend(SS_int);
    
    if length(RR_int) < w
        w = length(RR_int);
    end
    if length(SS_int) < w
        w = length(SS_int);
    end
    
    % СПМ Уэлча
    [RRpsd, RRpsd_f] = pwelch(RR_int, w, noverlap, nfft, Fs);
    [SSpsd, SSpsd_f] = pwelch(SS_int, w, noverlap, nfft, Fs);
    
    % Кросс-СПМ
    [CPSD, CPSD_f] = cpsd(RR_int, SS_int, w, noverlap, nfft, Fs);
    
    % Кросс СПМ возвращается в виде комплексных чисел, берем от них амплитуду
    CPSD = abs(CPSD);
    
    % Переводим мГц обратнов в Гц
    RRpsd_f = RRpsd_f ./ 1000;
    SSpsd_f = SSpsd_f ./ 1000;
    CPSD_f = CPSD_f ./ 1000;
end