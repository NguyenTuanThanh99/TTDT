% T�n hi?u r?i r?c
function out = despread(data, code)

% ************************************************ * ***************
% data: chu?i d? li?u �?u v�o
% code: chu?i m? tr?i r?ng ��?c s? d?ng �? �?c l?i
% out: xem l?i chu?i d? li?u �?u ra
% ************************************************ * ***************

switch nargin                          % N?u s? l�?ng tham s? �?u v�o kh�ng ch�nh x�c, m?t l?i s? ��?c hi?n th?
case { 0 , 1 }
    error('thi?u tham s? �?u v�o');
end

[hn,vn] = size(data);
[hc,vc] = size(code);                  

out    = zeros(hc,vn/vc);                  

for ii=1:hc
    xx=reshape(data(ii,:),vc,vn/vc);
    out(ii,:)= code(ii,:)*xx/vc;
end

%******************************** k?t th�c file ********************************
