function [b,a] = BPF(lowerBound,upperBound,Fs,order)
%LPF Summary of this function goes here
%   Detailed explanation goes here
    wp = [lowerBound/(Fs/2) upperBound/(Fs/2)];
    ws = [ max(lowerBound-100,1) upperBound+100 ] /(Fs/2);
    ws(2) = min(ws(2), 0.99); 
    
    [N, wn] = buttord(wp,ws,0.5,20);
    N = min(N,floor(order/2));
    [b,a] = butter(N,wn);

end

