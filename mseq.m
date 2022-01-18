
function [mout] = mseq(n, taps, inidata, num)

% ************************************************ * ***************
% n: b?c n c?a d?y m
% taps: v? tr� k?t n?i c?a thanh ghi ph?n h?i
% inidata: chu?i gi� tr? ban �?u c?a thanh ghi
% num: s? m tr?nh t? �? xu?t
% mout: xu?t ra m d?y, n?u num> 1, m?i h�ng l� m d?y
% ************************************************ * ***************


mout = zeros(num,2^n-1);
fpos = zeros(n,1);

fpos(taps) = 1;

for ii=1:2^n-1
    
    mout(1,ii) = inidata(n);                        % Gi� tr? �?u ra c?a thanh ghi
    temp        = mod(inidata*fpos,2);              % T�nh to�n d? li?u ph?n h?i
    
    inidata(2:n) = inidata(1:n-1);                  % shift ��ng k? m?t l?n
    inidata(1)     = temp;                          % c?p nh?t gi� tr? c?a ��ng k? �?u ti�n     
    
end

if num > 1                                         % N?u b?n mu?n xu?t nhi?u chu?i m, h?y t?o m chu?i kh�c
    for ii=2:num
        mout(ii,:) = shift(mout(ii-1,:),1);
    end
end
