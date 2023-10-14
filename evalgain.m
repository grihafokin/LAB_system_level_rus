function GAIN = evalgain(steer_True, steer_Est, az3dB, ...
                         tilt_True,  tilt_Est,  el3dB, Gbf)
% КУ
GAIN = 10*log10(sinc(((...
    steer_True - steer_Est)/(1.13*az3dB)).^2))... % КУ в горизонтальной пл.
    + 10*log10(sinc(((...
    tilt_True - tilt_Est)/(1.13*el3dB)).^2))...   % КУ в вертикальной пл.
    + Gbf;
GAIN = real(GAIN);
end