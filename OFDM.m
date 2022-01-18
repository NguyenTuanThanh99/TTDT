clc;
clear;
%% Cài ð?t tham s?

N_sc = 52;% s? sóng mang ph? c?a h? th?ng (không bao g?m sóng mang DC)
N_fft = 64;% ð? dài FFT
N_cp = 16;% Ð? dài ti?n t? theo chu k?, ti?n t? theo chu k?
N_symbo = N_fft + N_cp;% 1 ð? dài k? hi?u OFDM ð?y ð?
N_c = 53;% ch?a t?ng s? sóng mang ph? c?a sóng mang DC, s? sóng mang
M = 4;% QPSK
SNR = 0: 1: 25;% SNR mô ph?ng
N_frm = 10;% S? lý?ng khung h?nh mô ph?ng, khung h?nh theo t?ng t? l? tín hi?u trên nhi?u
Nd = 6;% S? lý?ng k? hi?u OFDM có trong m?i khung
P_f_inter = 6;% kho?ng th?i gian th? nghi?m
data_station = [];% v? trí thí ði?m
L = 7;% ð? dài ràng bu?c m? ch?p
tblen = 6 * L;% ð? sâu v?t n?t ngý?c c?a b? gi?i m? Viterbi
stage = 3;% m th? t? c?a tr?nh t?
ptap1 = [1 3];% m phýõng th?c k?t n?i thanh ghi tr?nh t?
regi1 = [1 1 1];% m giá tr? ban ð?u c?a thanh ghi tr?nh t?


%% t?o d? li?u bãng t?n cõ s?
P_data=randi([0 1],1,N_sc*Nd*N_frm);


%% m? hóa kênh (m? ph?c h?p ho?c xen k?)
% Convolational Code: M? phi tuy?n s?a l?i chuy?n ti?p
% Xen k?: T?i ða hóa s? phân tán c?a các l?i liên t?c
trellis = poly2trellis(7,[133 171]);       %(2,1,7)% (2,1,7) m? hóa ch?p
code_data=convenc(P_data,trellis);


%% Ði?u ch? qpsk
data_temp1 = reshape (code_data, log2 (M), [])'; % Nhóm 2 bit cho m?i nhóm, M = 4
data_temp2 = bi2de (data_temp1);% nh? phân thành th?p phân
modu_data = pskmod (data_temp2, M, pi / M);% ði?u ch? QPSK
% H?nh (1);
scatterplot (modu_data), grid;% bi?u ð? ch?m sao (b?n c?ng có th? s? d?ng hàm bi?u ð? cho ph?n th?c)

%% tr?i ph?
% ——————————————————————————————————————————————————— —— ——————%
% Bãng thông t?n s? b? chi?m b?i tín hi?u truy?n thông tr?i ph? l?n hõn nhi?u so v?i bãng thông t?i thi?u c?n thi?t cho thông tin ðý?c truy?n
% Theo ð?nh l? Shannon, truy?n thông tr?i ph? là s? d?ng công ngh? truy?n d?n bãng thông r?ng ð? ð?i l?y l?i ích c?a t? l? tín hi?u trên nhi?u, ðây là ? tý?ng cõ b?n và cõ s? l? thuy?t c?a truy?n thông tr?i ph?.
% Tr?i ph? là s?n ph?m bên trong c?a m?t lo?t các t? m? tr?c giao và tín hi?u ði?u ch? bãng t?n cõ s?
% Sau tr?i ph?, t?n s? k? thu?t s? tr? thành m l?n so v?i ban ð?u. S? chip = 2 (s? k? hi?u) * m (h? s? tr?i r?ng)
% ——————————————————————————————————————————————————— —— ——————%
code = mseq(stage,ptap1,regi1,N_sc);     % T?o m? lây lan
code = code * 2 - 1;         % Chuy?n ð?i 1, 0 thành 1, -1
modu_data=reshape(modu_data,N_sc,length(modu_data)/N_sc);
spread_data = spread(modu_data,code);        % tr?i ph?
spread_data=reshape(spread_data,[],1);

%% chèn thí ði?m
P_f = 3 + 3 * 1i;% t?n s? thí ði?m
P_f_station = [1: P_f_inter: N_fft];% v? trí hoa tiêu (v? trí hoa tiêu r?t quan tr?ng, t?i sao?)
pilot_num=length(P_f_station)% s? phi công

for img=1:N_fft                        % d? li?u v? trí
    if mod(img,P_f_inter)~=1          % mod (a, b) là ph?n c?n l?i c?a phép chia a cho b
        data_station=[data_station,img];
    end
end
data_row=length(data_station);
data_col=ceil(length(spread_data)/data_row);

pilot_seq=ones(pilot_num,data_col)*P_f;% ðýa phi công vào ma tr?n
data=zeros(N_fft,data_col);%% Ð?t trý?c toàn b? ma tr?n
data(P_f_station(1:end),:)=pilot_seq;% Ði theo hàng pilot_seq t?ng hàng

if data_row*data_col>length(spread_data)
    data2=[spread_data;zeros(data_row*data_col-length(spread_data),1)];% Ði?n vào ma tr?n d? li?u, ði?n 0 là t?n s? sóng mang ?o ~
end;

%% chuy?n ð?i n?i ti?p sang song song
data_seq=reshape(data2,data_row,data_col);
data(data_station(1:end),:)=data_seq;%K?t h?p thí ði?m v?i d? li?u

%% IFFT
ifft_data=ifft(data); 

%% Chèn kho?ng b?o v?, ti?n t? theo chu k?
Tx_cd=[ifft_data(N_fft-N_cp+1:end,:);ifft_data];% Thêm s? N_cp ? cu?i ifft lên phía trý?c

%% song song v?i chuy?n ð?i n?i ti?p
Tx_data=reshape(Tx_cd,[],1);% do nhu c?u truy?n t?i

%% qua kênh multi-rayleigh ho?c tín hi?u qua kênh AWGN)
 Ber=zeros(1,length(SNR));
 Ber2=zeros(1,length(SNR));
for jj=1:length(SNR)
    rx_channel=awgn(Tx_data,SNR(jj),'measured');% Thêm ti?ng ?n tr?ng Gaussian
%% chuy?n ð?i n?i ti?p sang song song
    Rx_data1=reshape(rx_channel,N_fft+N_cp,[]);
    
%% lo?i b? kho?ng th?i gian b?o v?, ti?n t? theo chu k?
    Rx_data2=Rx_data1(N_cp+1:end,:);

%% FFT
    fft_data=fft(Rx_data2);
    
%% Ý?c tính và n?i suy kênh (cân b?ng)
    data3=fft_data(1:N_fft,:); 
    Rx_pilot=data3(P_f_station(1:end),:); % Ð? nh?n ðý?c thí ði?m
    h=Rx_pilot./pilot_seq; 
    H=interp1( P_f_station(1:end)',h,data_station(1:end)','linear','extrap');%????????????????????????????????????????????????????????

%% kênh s?a
    data_aftereq=data3(data_station(1:end),:)./H;
%% song song v?i chuy?n ð?i n?i ti?p
    data_aftereq=reshape(data_aftereq,[],1);
    data_aftereq=data_aftereq(1:length(spread_data));
    data_aftereq=reshape(data_aftereq,N_sc,length(data_aftereq)/N_sc);
    
%% ð? ð?c
    demspread_data = despread(data_aftereq,code);      % d? li?u ð? xem l?i
    
%% gi?i ði?u ch? QPSK
    demodulation_data=pskdemod(demspread_data,M,pi/M);    
    De_data1 = reshape(demodulation_data,[],1);
    De_data2 = de2bi(De_data1);
    De_Bit = reshape(De_data2',1,[]);

%% (h?y xen k?)
%%Gi?i m? kênh %% (gi?i m? Viterbi)
    trellis = poly2trellis(7,[133 171]);
    rx_c_de = vitdec(De_Bit,trellis,tblen,'trunc','hard');   % phán ðoán khó

%% Tính t? l? l?i bit
    [err,Ber2(jj)] = biterr(De_Bit(1:length(code_data)),code_data);% bit t? l? l?i trý?c khi gi?i m?
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