function [b, a] = LPF(lowerBound, upperBound, Fs, order, filterStruct, filterType)
    wn = upperBound / (Fs/2);
    wn = min(wn, 0.99);

    if strcmp(filterStruct, 'IIR')
        ws = min((upperBound + 100) / (Fs/2), 0.99);
        if ws <= wn
            ws = min(wn + 0.005, 0.99);
        end
        switch filterType
            case 'Butterworth'
                [N, wn_out] = buttord(wn, ws, 0.5, 20);
                N = min(N, order);
                [b, a] = butter(N, wn_out, 'low');

            case 'Chebyshev I'
                [N, wn_out] = cheb1ord(wn, ws, 0.5, 20);
                N = min(N, order);
                [b, a] = cheby1(N, 0.5, wn_out, 'low');

            case 'Chebyshev II'
                [N, wn_out] = cheb2ord(wn, ws, 0.5, 20);
                N = min(N, order);
                [b, a] = cheby2(N, 20, wn_out, 'low');
        end
    else
        win = getWindow(order, filterType);
        b = fir1(order, wn, 'low', win);
        a = 1;
    end
end