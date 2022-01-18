%� t�n hi?u li�n t?c
function [out] = spread(data, code)

% ************************************************ * ***************
% data: chu?i d? li?u �?u v�o
% code: chu?i m? tr?i r?ng
% out: chu?i d? li?u �?u ra sau tr?i ph?
% ************************************************ * ***************

switch nargin
case { 0 , 1 }                                  % N?u s? l�?ng tham s? �?u v�o kh�ng ch�nh x�c, m?t l?i s? ��?c hi?n th?
    error('thi?u tham s? �?u v�o');
end

[hn,vn] = size(data);
[hc,vc] = size(code);

if hn > hc                                      % N?u s? l�?ng m? tr?i r?ng �t h�n chu?i d? li?u �?u v�o ��?c tr?i, n� s? d?n �?n l?i
    error('Thi?u chu?i m? m? r?ng');
end

out = zeros(hn,vn*vc);

for ii=1:hn
    out(ii,:) = reshape(code(ii,:).'*data(ii,:),1,vn*vc);
end

%******************************** k?t th�c file ********************************
