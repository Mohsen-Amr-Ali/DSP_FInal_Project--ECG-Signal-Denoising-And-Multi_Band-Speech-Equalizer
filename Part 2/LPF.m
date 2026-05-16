function [b,a] = LPF(lowerBound,upperBound,Fs,order)
%LPF Summary of this function goes here
%   Detailed explanation goes here
    wp = upperBound / (Fs / 2);
    ws = (upperBound + 100) / (Fs / 2);

    [N, wn] = buttord(wp,ws,0.5,20);
    N = min(N,order);
    [b,a] = butter(N,wn,'low');

end

