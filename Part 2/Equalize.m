function [X,updatedSignal,Fs,t,filters] = Equalize(fileName,bands,gains,order)
%EQUALIZE Summary of this function goes here
%   Detailed explanation goes here
    [X,Fs] = audioread(fileName);
    X = X(:,1);
    t = (0:length(X)-1) / Fs;
    
    %bands = [0 100 300 800 2000 5000 10000 20000];
    %gains = [0 0 0 20 20 0 0];
    
    filters = {};
    updatedSignal = zeros(size(X));
    
    for i = 2:length(bands)
        if i == 2
            [b, a] = LPF(bands(i-1),bands(i),Fs,order);
        elseif i == length(bands)
            [b, a] = HPF(bands(i-1),bands(i),Fs,order);
        else
            [b, a] = BPF(bands(i-1),bands(i),Fs,order);
        end
        fprintf('Band %d-%d Hz: order = %d\n', bands(i-1), bands(i), length(a)-1);
        filters{i-1} = struct('b', b, 'a', a,'low', bands(i-1), 'high', bands(i));  
        y = filtfilt(b,a,X) * 10^(gains(i-1) / 20);
        updatedSignal = updatedSignal + y;
    end

end

