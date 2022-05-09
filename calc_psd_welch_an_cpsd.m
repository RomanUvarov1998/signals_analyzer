function [RRpsd_f, RRpsd, SSpsd_f, SSpsd, CPSD, CPSD_f, RR_VLF, RR_LF, RR_HF, SS_VLF, SS_LF, SS_HF] = calc_psd_welch_an_cpsd(t, RRx, RRy, SSx, SSy)
    nfft = 500;
    
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
    
    % Применение окна
    window = tukeywin(length(t_interp), 0.25);
    
    % СПМ периодограммным методом
    [RRpsd, RRpsd_f] = periodogram(RR_int, window, nfft, Fs);
    [SSpsd, SSpsd_f] = periodogram(SS_int, window, nfft, Fs);
    
%     % СПМ Уэлча
%     [RRpsd, RRpsd_f] = pwelch(RR_int, w, noverlap, nfft, Fs);
%     [SSpsd, SSpsd_f] = pwelch(SS_int, w, noverlap, nfft, Fs);
    
    % Кросс-СПМ
    w = 100;
    
    % Коррекция размера окна
    if length(RR_int) < w
        w = length(RR_int);
    end
    if length(SS_int) < w
        w = length(SS_int);
    end

    noverlap = round(w .* 0.5);
    [CPSD, CPSD_f] = cpsd(RR_int, SS_int, w, noverlap, nfft, Fs);
    
    % Кросс СПМ возвращается в виде комплексных чисел, берем от них амплитуду
    CPSD = abs(CPSD);
    
    % Переводим мГц обратнов в Гц
    RRpsd_f = RRpsd_f ./ 1000;
    SSpsd_f = SSpsd_f ./ 1000;
    CPSD_f = CPSD_f ./ 1000;
		
    RR_VLF = sum(RRpsd(0.003 <= RRpsd_f & RRpsd_f <= 0.04));
    RR_LF = sum(RRpsd(0.04 <= RRpsd_f & RRpsd_f <= 0.15));
    RR_HF = sum(RRpsd(0.15 <= RRpsd_f & RRpsd_f <= 0.4));
    SS_VLF = sum(SSpsd(0.003 <= SSpsd_f & SSpsd_f <= 0.04));
    SS_LF = sum(SSpsd(0.04 <= SSpsd_f & SSpsd_f <= 0.15));
    SS_HF = sum(SSpsd(0.15 <= SSpsd_f & SSpsd_f <= 0.4));
end