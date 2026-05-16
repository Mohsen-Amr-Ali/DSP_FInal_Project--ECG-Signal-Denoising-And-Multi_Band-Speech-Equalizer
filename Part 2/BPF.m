function [b, a] = BPF(lowerBound, upperBound, Fs, order, filterStruct, filterType)
    wp = [lowerBound   upperBound] / (Fs/2);
    wp(1) = max(wp(1), 0.001);
    wp(2) = min(wp(2), 0.999);

    if strcmp(filterStruct, 'IIR')
        bandWidth = wp(2) - wp(1);
        gap = max(bandWidth * 0.2, 0.02);  % 20% of bandwidth, minimum 0.02
        
        ws(1) = max(wp(1) - gap, 0.001);
        ws(2) = min(wp(2) + gap, 0.999);

        % Final safety check
        if ws(1) >= wp(1), ws(1) = max(wp(1) - 0.01, 0.001); end
        if ws(2) <= wp(2), ws(2) = min(wp(2) + 0.01, 0.999); end
        
        %ws = [wp(1)*0.75, wp(2)*1.25];
       

        %ws(1) = max(ws(1), 0.0005);
        %ws(2) = min(ws(2), 0.9995);
        

        switch filterType
            case 'Butterworth'
                [N, wn_out] = buttord(wp, ws, 0.5, 20);
                N = min(N, floor(order/2));
                [b, a] = butter(N, wn_out);

            case 'Chebyshev I'
                [N, wn_out] = cheb1ord(wp, ws, 0.5, 20);
                N = min(N, floor(order/2));
                [b, a] = cheby1(N, 0.5, wn_out);

            case 'Chebyshev II'
                [N, wn_out] = cheb2ord(wp, ws, 0.5, 20);
                N = min(N, floor(order/2));
                [b, a] = cheby2(N, 20, wn_out);
        end
    else  % FIR
        if mod(order, 2) ~= 0
            order = order + 1;
        end
        win = getWindow(order, filterType);
        b = fir1(order, wp, 'bandpass', win);
        a = 1;
    end
end