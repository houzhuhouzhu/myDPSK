if 1
clear
clc
datalength = 128; %数据长度
sourceData=fix(rand(1,datalength)*2);%消息码
SNR = 0 %信噪比 dB

% diffCode0=DPSK_change_code(sourceData,datalength)    测试用  %码元变换（绝对码变成相对码）只要和前面不一样就是变 
diffCode=[];
for n=1:datalength                                    %对应的一个参考电位是0
    if n == 1
        if sourceData(n) == 0                       
            diffCode=[-1,diffCode];                    %对应的一个参考码是-1
        end
        if sourceData(n) == 1
            diffCode=[1,diffCode];
        end
    end
    if n >1
        if sourceData(n) == sourceData(n-1) 
            diffCode=[diffCode,diffCode(n-1)];   
        end
        if sourceData(n) ~= sourceData(n-1) 
            diffCode=[diffCode,-1*diffCode(n-1)];   
        end
    end
end
%diffCode 调试用实际不用
%PSK调制   一个码元有2个载波周期 设置采样率为Fs  T=1/Fs; 载波频率为FcFc=50;
Fs=300;
T=1/Fs;
PSKdata=[];
t=linspace(0,4*pi,Fs);
Fc=50;
for n=1:datalength
    temp=cos(50*2*pi*t);
    PSKdata=[PSKdata,diffCode(n)*temp];
end
subplot(2,1,1)
plot(PSKdata);
title("数据源")
subplot(2,1,2)
PSKdata=awgn(PSKdata,SNR);
plot(PSKdata);
title("噪声干扰")

%解调
%PSKdemodulation=[];
%带通滤波器;   
load('bpf1.mat');
%PSKdata=conv(PSKdata,bpf1);

%低通滤波器
Coswc=[];
for i=1:datalength
    Coswc=[Coswc,cos(50*2*pi*t)];
end
PSKdata = PSKdata.*Coswc;
figure,subplot(2,1,1)
plot(PSKdata);
title("相干载波乘法")
load('lpf2.mat');
subplot(2,1,2)
PSKdata=conv(PSKdata,lpf2);
plot(PSKdata);
title("低通滤波")
PSKrecedata=[];
for i=1:datalength 
    temp = PSKdata(Fs*i);
    if temp>0
        temp =1;
    end
       if temp<0
        temp =-1;
       end
    
      if temp==0
        temp =0;
      end
    
    PSKrecedata=[PSKrecedata,temp];
end

% PSKrecedata
 PeNum=diffCode-PSKrecedata;
 Pe=length(find(PeNum))/datalength                %误码率

end
if 1
 clear
    PE=[];
    for k = -50:50
        datalength = 256; %数据长度
        sourceData=fix(rand(1,datalength)*2);%消息码
        SNR = k; %信噪比 dB
        diffCode=[];
        for n=1:datalength                                    %对应的一个参考电位是0
            if n == 1
                if sourceData(n) == 0                       
                    diffCode=[-1,diffCode];                    %对应的一个参考码是-1
                end
                if sourceData(n) == 1
                    diffCode=[1,diffCode];
                end
            end
            if n >1
                if sourceData(n) == sourceData(n-1) 
                    diffCode=[diffCode,diffCode(n-1)];   
                end
                if sourceData(n) ~= sourceData(n-1) 
                    diffCode=[diffCode,-1*diffCode(n-1)];   
                end
            end
        end
        Fs=300;
        T=1/Fs;
        PSKdata=[];
        t=linspace(0,4*pi,Fs);
        Fc=50;
        for n=1:datalength
            temp=cos(50*2*pi*t);
            PSKdata=[PSKdata,diffCode(n)*temp];
        end
        PSKdata=awgn(PSKdata,SNR);
        %解调
        %PSKdemodulation=[];
        %带通滤波器;   
        load('bpf1.mat');
        %PSKdata=conv(PSKdata,bpf1);

        %低通滤波器
        Coswc=[];
        for i=1:datalength
            Coswc=[Coswc,cos(50*2*pi*t)];
        end
        PSKdata = PSKdata.*Coswc;
        load('lpf2.mat');
        PSKdata=conv(PSKdata,lpf2);
        PSKrecedata=[];
        for i=1:datalength 
            temp = PSKdata(Fs*i);
            if temp>0
                temp =1;
            end
               if temp<0
                temp =-1;
               end

              if temp==0
                temp =0;
              end

            PSKrecedata=[PSKrecedata,temp];
        end
        % PSKrecedata
         PeNum=diffCode-PSKrecedata;
         Pe=length(find(PeNum))/datalength;              %误码率
         PE=[PE,Pe];
    end
    r = -50:50;
   figure, plot(r,PE)
   hold on;
   r=10.^(0.1*r);
   plot(-50:50,0.5*erfc(sqrt(r)));
   legend('仿真不同信噪比下的误码率','理论信噪比下的误码率');
   xlabel("信噪比 单位 dB");
   ylabel("误码率");
   grid on;
end




