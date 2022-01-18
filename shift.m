function [outregi] = shift(inregi,shiftr)

% ************************************************ * ***************
% inrege: chu?i �?u v�o
% shiftr: s? bit �? xoay sang ph?i
% outregi: chu?i �?u ra
% ************************************************ * ***************
v  = length(inregi);
outregi = inregi;

shiftr = rem(shiftr,v);

if shiftr > 0
    outregi(:,1:shiftr) = inregi(:,v-shiftr+1:v);    % thay �?i theo chu k?
    outregi(:,1+shiftr:v) = inregi(:,1:v-shiftr);
elseif shiftr < 0
    outregi(:,1:v+shiftr) = inregi(:,1-shiftr:v);
    outregi(:,v+shiftr+1:v) = inregi(:,1:-shiftr);
end

%******************************** k?t th�c file ********************************
