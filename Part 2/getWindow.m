function win = getWindow(order, windowType)
    switch lower(windowType)
        case 'hamming'
            win = hamming(order + 1);
        case 'hanning'
            win = hanning(order + 1);
        case 'blackman'
            win = blackman(order + 1);
        otherwise
            win = hamming(order + 1);   % default
    end
end