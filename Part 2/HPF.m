function [b,a] = HPF(lowerBound,upperBound,Fs,order)
%LPF Summary of this function goes here
%   Detailed explanation goes here
    wp = lowerBound / (Fs / 2);
    ws = max(lowerBound - 100 , 1) / (Fs / 2);

    [N, wn] = buttord(wp,ws,0.5,20);
    N = min(N,order);
    [b,a] = butter(N,wn,'high');

end

