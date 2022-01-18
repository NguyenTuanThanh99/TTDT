% Tín hi?u r?i r?c
function out = despread(data, code)

% ************************************************ * ***************
% data: chu?i d? li?u ð?u vào
% code: chu?i m? tr?i r?ng ðý?c s? d?ng ð? ð?c l?i
% out: xem l?i chu?i d? li?u ð?u ra
% ************************************************ * ***************

switch nargin                          % N?u s? lý?ng tham s? ð?u vào không chính xác, m?t l?i s? ðý?c hi?n th?
case { 0 , 1 }
    error('thi?u tham s? ð?u vào');
end

[hn,vn] = size(data);
[hc,vc] = size(code);                  

out    = zeros(hc,vn/vc);                  

for ii=1:hc
    xx=reshape(data(ii,:),vc,vn/vc);
    out(ii,:)= code(ii,:)*xx/vc;
end

%******************************** k?t thúc file ********************************
