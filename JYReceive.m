clear all;
close all;
instrreset;
disp('Press Ctrl+C to stop collecting data!')
s=serial('com5','baudrate',115200) ;fopen(s) ;%Open Com Port   �뽫COM19���ɵ���ʶ�𵽵�COM�ڣ�������115000���ɴ�������Ӧ�Ĳ�����
f = 20;%DataFrequce
t=0;
cnt = 1;
aa=[0 0 0];
ww=[0 0 0];
AA = [0 0 0];
tt = 0;
a=[0 0 0]';
w=[0 0 0]';
A=[0 0 0]';
while(1)
    Head = fread(s,1,'uint8');
    if (Head~=uint8(85))
        continue;
    end   
    Head = fread(s,1,'uint8');
    switch(Head)
        case 97
            a = fread(s,3,'int16')/32768*16 ;
            w = fread(s,3,'int16')/32768*2000 ;   
            A = fread(s,3,'int16')/32768*180;
            aa=[aa;a'];
            ww = [ww;w'];
            AA = [AA;A'];
            tt = [tt;t];
             if (cnt>(f/5)) %Plot in low frequce, 
                subplot(3,1,1);plot(tt,aa);title(['Acceleration = ' num2str(a') 'g']);ylabel('g');
                subplot(3,1,2);plot(tt,ww);title(['Gyro = ' num2str(w') '��/s']);ylabel('��/s');
                subplot(3,1,3);plot(tt,AA);title(['Angle = ' num2str(A') '��']);ylabel('��');              
                cnt=0;
                drawnow;
                if (size(aa,1)>5*f)%clear history data
                    aa = aa(f:5*f,:);
                    ww = ww(f:5*f,:);
                    AA = AA(f:5*f,:);
                    tt = tt(f:5*f,:);
                 end
             end
            cnt=cnt+1;
            t=t+0.01;
    end 
        
            End = fread(s,3,'uint8');
end
fclose(s);