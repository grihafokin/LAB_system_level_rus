function ARP = evalbarp(steer_True, steer_Est, az3dB, Am, ...
                        tilt_True, tilt_Est, el3dB, SLAv)
% ДНА в горизонтальной плоскости
A_H = 12*(((steer_True-steer_Est)/az3dB).^2); 
A_H=-(min(A_H,Am));
% ДНА в вертикальной плоскости
A_V=12*(((tilt_True-tilt_Est)/el3dB).^2);
A_V=-(min(A_V,SLAv)); 
% совокупная ДНА
ARP = A_H + A_V; 
ARP(ARP<-Am) = - Am; % дБ
end