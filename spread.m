%æ tín hi?u liên t?c
function [out] = spread(data, code)

% ************************************************ * ***************
% data: chu?i d? li?u ð?u vào
% code: chu?i m? tr?i r?ng
% out: chu?i d? li?u ð?u ra sau tr?i ph?
% ************************************************ * ***************

switch nargin
case { 0 , 1 }                                  % N?u s? lý?ng tham s? ð?u vào không chính xác, m?t l?i s? ðý?c hi?n th?
    error('thi?u tham s? ð?u vào');
end

[hn,vn] = size(data);
[hc,vc] = size(code);

if hn > hc                                      % N?u s? lý?ng m? tr?i r?ng ít hõn chu?i d? li?u ð?u vào ðý?c tr?i, nó s? d?n ð?n l?i
    error('Thi?u chu?i m? m? r?ng');
end

out = zeros(hn,vn*vc);

for ii=1:hn
    out(ii,:) = reshape(code(ii,:).'*data(ii,:),1,vn*vc);
end

%******************************** k?t thúc file ********************************
