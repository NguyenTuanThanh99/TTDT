clc;
clear;
%% C�i �?t tham s?

N_sc = 52;% s? s�ng mang ph? c?a h? th?ng (kh�ng bao g?m s�ng mang DC)
N_fft = 64;% �? d�i FFT
N_cp = 16;% �? d�i ti?n t? theo chu k?, ti?n t? theo chu k?
N_symbo = N_fft + N_cp;% 1 �? d�i k? hi?u OFDM �?y �?
N_c = 53;% ch?a t?ng s? s�ng mang ph? c?a s�ng mang DC, s? s�ng mang
M = 4;% QPSK
SNR = 0: 1: 25;% SNR m� ph?ng
N_frm = 10;% S? l�?ng khung h?nh m� ph?ng, khung h?nh theo t?ng t? l? t�n hi?u tr�n nhi?u
Nd = 6;% S? l�?ng k? hi?u OFDM c� trong m?i khung
P_f_inter = 6;% kho?ng th?i gian th? nghi?m
data_station = [];% v? tr� th� �i?m
L = 7;% �? d�i r�ng bu?c m? ch?p
tblen = 6 * L;% �? s�u v?t n?t ng�?c c?a b? gi?i m? Viterbi
stage = 3;% m th? t? c?a tr?nh t?
ptap1 = [1 3];% m ph��ng th?c k?t n?i thanh ghi tr?nh t?
regi1 = [1 1 1];% m gi� tr? ban �?u c?a thanh ghi tr?nh t?


%% t?o d? li?u b�ng t?n c� s?
P_data=randi([0 1],1,N_sc*Nd*N_frm);


%% m? h�a k�nh (m? ph?c h?p ho?c xen k?)
% Convolational Code: M? phi tuy?n s?a l?i chuy?n ti?p
% Xen k?: T?i �a h�a s? ph�n t�n c?a c�c l?i li�n t?c
trellis = poly2trellis(7,[133 171]);       %(2,1,7)% (2,1,7) m? h�a ch?p
code_data=convenc(P_data,trellis);


%% �i?u ch? qpsk
data_temp1 = reshape (code_data, log2 (M), [])'; % Nh�m 2 bit cho m?i nh�m, M = 4
data_temp2 = bi2de (data_temp1);% nh? ph�n th�nh th?p ph�n
modu_data = pskmod (data_temp2, M, pi / M);% �i?u ch? QPSK
% H?nh (1);
scatterplot (modu_data), grid;% bi?u �? ch?m sao (b?n c?ng c� th? s? d?ng h�m bi?u �? cho ph?n th?c)

%% tr?i ph?
% ��������������������������������������������������� �� ������%
% B�ng th�ng t?n s? b? chi?m b?i t�n hi?u truy?n th�ng tr?i ph? l?n h�n nhi?u so v?i b�ng th�ng t?i thi?u c?n thi?t cho th�ng tin ��?c truy?n
% Theo �?nh l? Shannon, truy?n th�ng tr?i ph? l� s? d?ng c�ng ngh? truy?n d?n b�ng th�ng r?ng �? �?i l?y l?i �ch c?a t? l? t�n hi?u tr�n nhi?u, ��y l� ? t�?ng c� b?n v� c� s? l? thuy?t c?a truy?n th�ng tr?i ph?.
% Tr?i ph? l� s?n ph?m b�n trong c?a m?t lo?t c�c t? m? tr?c giao v� t�n hi?u �i?u ch? b�ng t?n c� s?
% Sau tr?i ph?, t?n s? k? thu?t s? tr? th�nh m l?n so v?i ban �?u. S? chip = 2 (s? k? hi?u) * m (h? s? tr?i r?ng)
% ��������������������������������������������������� �� ������%
code = mseq(stage,ptap1,regi1,N_sc);     % T?o m? l�y lan
code = code * 2 - 1;         % Chuy?n �?i 1, 0 th�nh 1, -1
modu_data=reshape(modu_data,N_sc,length(modu_data)/N_sc);
spread_data = spread(modu_data,code);        % tr?i ph?
spread_data=reshape(spread_data,[],1);

%% ch�n th� �i?m
P_f = 3 + 3 * 1i;% t?n s? th� �i?m
P_f_station = [1: P_f_inter: N_fft];% v? tr� hoa ti�u (v? tr� hoa ti�u r?t quan tr?ng, t?i sao?)
pilot_num=length(P_f_station)% s? phi c�ng

for img=1:N_fft                        % d? li?u v? tr�
    if mod(img,P_f_inter)~=1          % mod (a, b) l� ph?n c?n l?i c?a ph�p chia a cho b
        data_station=[data_station,img];
    end
end
data_row=length(data_station);
data_col=ceil(length(spread_data)/data_row);

pilot_seq=ones(pilot_num,data_col)*P_f;% ��a phi c�ng v�o ma tr?n
data=zeros(N_fft,data_col);%% �?t tr�?c to�n b? ma tr?n
data(P_f_station(1:end),:)=pilot_seq;% �i theo h�ng pilot_seq t?ng h�ng

if data_row*data_col>length(spread_data)
    data2=[spread_data;zeros(data_row*data_col-length(spread_data),1)];% �i?n v�o ma tr?n d? li?u, �i?n 0 l� t?n s? s�ng mang ?o ~
end;

%% chuy?n �?i n?i ti?p sang song song
data_seq=reshape(data2,data_row,data_col);
data(data_station(1:end),:)=data_seq;%K?t h?p th� �i?m v?i d? li?u

%% IFFT
ifft_data=ifft(data); 

%% Ch�n kho?ng b?o v?, ti?n t? theo chu k?
Tx_cd=[ifft_data(N_fft-N_cp+1:end,:);ifft_data];% Th�m s? N_cp ? cu?i ifft l�n ph�a tr�?c

%% song song v?i chuy?n �?i n?i ti?p
Tx_data=reshape(Tx_cd,[],1);% do nhu c?u truy?n t?i

%% qua k�nh multi-rayleigh ho?c t�n hi?u qua k�nh AWGN)
 Ber=zeros(1,length(SNR));
 Ber2=zeros(1,length(SNR));
for jj=1:length(SNR)
    rx_channel=awgn(Tx_data,SNR(jj),'measured');% Th�m ti?ng ?n tr?ng Gaussian
%% chuy?n �?i n?i ti?p sang song song
    Rx_data1=reshape(rx_channel,N_fft+N_cp,[]);
    
%% lo?i b? kho?ng th?i gian b?o v?, ti?n t? theo chu k?
    Rx_data2=Rx_data1(N_cp+1:end,:);

%% FFT
    fft_data=fft(Rx_data2);
    
%% �?c t�nh v� n?i suy k�nh (c�n b?ng)
    data3=fft_data(1:N_fft,:); 
    Rx_pilot=data3(P_f_station(1:end),:); % �? nh?n ��?c th� �i?m
    h=Rx_pilot./pilot_seq; 
    H=interp1( P_f_station(1:end)',h,data_station(1:end)','linear','extrap');%????????????????????????????????????????????????????????

%% k�nh s?a
    data_aftereq=data3(data_station(1:end),:)./H;
%% song song v?i chuy?n �?i n?i ti?p
    data_aftereq=reshape(data_aftereq,[],1);
    data_aftereq=data_aftereq(1:length(spread_data));
    data_aftereq=reshape(data_aftereq,N_sc,length(data_aftereq)/N_sc);
    
%% �? �?c
    demspread_data = despread(data_aftereq,code);      % d? li?u �? xem l?i
    
%% gi?i �i?u ch? QPSK
    demodulation_data=pskdemod(demspread_data,M,pi/M);    
    De_data1 = reshape(demodulation_data,[],1);
    De_data2 = de2bi(De_data1);
    De_Bit = reshape(De_data2',1,[]);

%% (h?y xen k?)
%%Gi?i m? k�nh %% (gi?i m? Viterbi)
    trellis = poly2trellis(7,[133 171]);
    rx_c_de = vitdec(De_Bit,trellis,tblen,'trunc','hard');   % ph�n �o�n kh�

%% T�nh t? l? l?i bit
    [err,Ber2(jj)] = biterr(De_Bit(1:length(code_data)),code_data);% bit t? l? l?i tr�?c khi gi?i m?
    [err, Ber(jj)] = biterr(rx_c_de(1:length(P_data)),P_data);% bit t? l? l?i sau khi gi?i m?

end
 figure(2);
 semilogy(SNR,Ber2,'b-s');
 hold on;
 semilogy(SNR,Ber,'r-o');
 hold on;
 legend('dieu che QPSK, truoc khi giai ma tich chap (vs trai pho) ',' dieu che QPSK, sau khi giai ma tich chap (vs trai pho)');
 hold on;
 xlabel('SNR');
 ylabel('BER');
 title('duong cong ti le loi bit trong kenh AWGN');

 figure(3)
 subplot(2,1,1);
 x=0:1:30;
 stem(x,P_data(1:31));
 ylabel('bien do');
 title('du lieu gui (vi du gui 30 du lieu dau tien)');
 legend('dieu che QPSK, truoc khi giai ma tich chap (vs trai pho)');

 subplot(2,1,2);
 x=0:1:30;
 stem(x,rx_c_de(1:31));
 ylabel('bien do');
 title('nhan du lieu (vi du gui 30 du lieu dau tien)');
 legend('dieu che QPSK, sau khi giai ma tich chap (vs trai pho)');