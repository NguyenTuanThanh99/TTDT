
function [mout] = mseq(n, taps, inidata, num)

% ************************************************ * ***************
% n: b?c n c?a d?y m
% taps: v? trí k?t n?i c?a thanh ghi ph?n h?i
% inidata: chu?i giá tr? ban ð?u c?a thanh ghi
% num: s? m tr?nh t? ð? xu?t
% mout: xu?t ra m d?y, n?u num> 1, m?i hàng là m d?y
% ************************************************ * ***************


mout = zeros(num,2^n-1);
fpos = zeros(n,1);

fpos(taps) = 1;

for ii=1:2^n-1
    
    mout(1,ii) = inidata(n);                        % Giá tr? ð?u ra c?a thanh ghi
    temp        = mod(inidata*fpos,2);              % Tính toán d? li?u ph?n h?i
    
    inidata(2:n) = inidata(1:n-1);                  % shift ðãng k? m?t l?n
    inidata(1)     = temp;                          % c?p nh?t giá tr? c?a ðãng k? ð?u tiên     
    
end

if num > 1                                         % N?u b?n mu?n xu?t nhi?u chu?i m, h?y t?o m chu?i khác
    for ii=2:num
        mout(ii,:) = shift(mout(ii-1,:),1);
    end
end
