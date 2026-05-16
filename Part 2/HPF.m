function [b, a] = HPF(lowerBound, upperBound, Fs, order, filterType, windowType, iirType)
    wn = lowerBound / (Fs/2);
    wn = max(wn, 0.01);

    if strcmp(filterType, 'IIR')
        ws = max((lowerBound - 100) / (Fs/2), 0.01);
        
        switch iirType
            case 'Butterworth'
                [N, wn_out] = buttord(wn, ws, 0.5, 20);
                N = min(N, order);
                [b, a] = butter(N, wn_out, 'high');

            case 'Chebyshev I'
                [N, wn_out] = cheb1ord(wn, ws, 0.5, 20);
                N = min(N, order);
                [b, a] = cheby1(N, 0.5, wn_out, 'high');

            case 'Chebyshev II'
                [N, wn_out] = cheb2ord(wn, ws, 0.5, 20);
                N = min(N, order);
                [b, a] = cheby2(N, 20, wn_out, 'high');
        end
    else  % FIR
        win = getWindow(order, windowType);
        b = fir1(order, wn, 'high', win);
        a = 1;
    end
end