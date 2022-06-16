function [RRpsd_f, RRpsd, SSpsd_f, SSpsd, DDpsd_f, DDpsd, CPSD, CPSD_f, RR_VLF, RR_LF, RR_HF, SS_VLF, SS_LF, SS_HF, DD_VLF, DD_LF, DD_HF] = calc_psd_welch_an_cpsd(t, RRx, RRy, SSx, SSy, DDx, DDy)
    nfft = 500;
    
    Fs = 4; % Hz
    Ts = 1 / Fs; % sec
    t_interp = min([RRx; SSx; DDx]) : Ts : max([RRx; SSx; DDx]);

    RRx = RRx .* 1000;
    RRy = RRy .* 1000;
    SSx = SSx .* 1000;
	DDx = DDx .* 1000;
    t_interp = t_interp .* 1000;

    pol_info = csaps(RRx, RRy, 1);
    RR_int = ppval(pol_info, t_interp);
    
    pol_info = csaps(SSx, SSy, 1);
    SS_int = ppval(pol_info, t_interp);
	
	pol_info = csaps(DDx, DDy, 1);
    DD_int = ppval(pol_info, t_interp);

    RR_int = detrend(RR_int);
    SS_int = detrend(SS_int);
	DD_int = detrend(DD_int);
    
    % Применение окна
    window = tukeywin(length(t_interp), 0.25);
    
    % СПМ периодограммным методом
    [RRpsd, RRpsd_f] = periodogram(RR_int, window, nfft, Fs);
    [SSpsd, SSpsd_f] = periodogram(SS_int, window, nfft, Fs);
	[DDpsd, DDpsd_f] = periodogram(DD_int, window, nfft, Fs);

    w = 100;
    
    % Коррекция размера окна
    if length(RR_int) < w
        w = length(RR_int);
    end
    if length(SS_int) < w
        w = length(SS_int);
    end
	if length(DD_int) < w
        w = length(DD_int);
    end

    noverlap = round(w .* 0.5);
    [CPSD, CPSD_f] = cpsd(RR_int, SS_int, w, noverlap, nfft, Fs);
    
    CPSD = abs(CPSD);
    

    df = RRpsd_f(2) - RRpsd_f(1);    
    RR_VLF = sum(RRpsd(0.003 <= RRpsd_f & RRpsd_f <= 0.04)) .* df;
    RR_LF = sum(RRpsd(0.04 <= RRpsd_f & RRpsd_f <= 0.15)) .* df;
    RR_HF = sum(RRpsd(0.15 <= RRpsd_f & RRpsd_f <= 0.4)) .* df;
    
    df = SSpsd_f(2) - SSpsd_f(1);   
    SS_VLF = sum(SSpsd(0.003 <= SSpsd_f & SSpsd_f <= 0.04)) .* df;
    SS_LF = sum(SSpsd(0.04 <= SSpsd_f & SSpsd_f <= 0.15)) .* df;
    SS_HF = sum(SSpsd(0.15 <= SSpsd_f & SSpsd_f <= 0.4)) .* df;
    
    df = DDpsd_f(2) - DDpsd_f(1);   
	DD_VLF = sum(DDpsd(0.003 <= DDpsd_f & DDpsd_f <= 0.04)) .* df;
    DD_LF = sum(DDpsd(0.04 <= DDpsd_f & DDpsd_f <= 0.15)) .* df;
    DD_HF = sum(DDpsd(0.15 <= DDpsd_f & DDpsd_f <= 0.4)) .* df;
end