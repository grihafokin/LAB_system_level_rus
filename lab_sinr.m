function [SINR_S_est, SINR_S_tru, SINR_SC_est, SINR_SC_tru, ...
    SINR_SCN_est, SINR_SCN_tru, SINR_SCNN_est, SINR_SCNN_tru] = ...
    lab_sinr(udn, gNB, UE_est, UE_tru, ...
    az_est, el_est, az_tru, el_tru, az_3dB, el_3dB)
Am=udn.Am; SLAv=udn.SLAv; Gbf=udn.Gbf;

%% вычисление SINR в радиолиниях gNB_UE_est и gNB_UE_tru
for i=1:udn.sector_num % цикл по числу секторов i
    j=1; % индекс первой - центральной обслуживаюшей базовой станции gNB
    for k=1:udn.UE_num % цикл по числу пользовательских устройств k
        %% мощность полезного сигнала SOI в радиолинии gNB_UE_est
        % ДНА в горизонтальной и вертикальной плоскости по ширине луча hpbw       
        ARP_SOI_est = evalbarp(...
            az_est{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k), Am, ...
            el_est{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), SLAv);
        % вычисление коэффициента усиления полезного сигнала SOI за счет ДО
        BF_SOI_est = evalgain(...
            az_est{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k),...
            el_est{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), Gbf);
        % координаты точки UE_est, потери РРВ
        gNB_SOI=[gNB(j,1),gNB(j,2)];
        UE_loc_est = [UE_est{j,i}(k,1),UE_est{j,i}(k,2)]; 
        PL_SOI_est = evalfrisp(gNB_SOI, UE_loc_est, udn.eff_h, udn.fc);
        % мощность полезного сигнала SOI
        P_SOI_est = udn.txPowerDBm + udn.Gtx - ...
            PL_SOI_est + ARP_SOI_est + BF_SOI_est;
        P_SOI_est = 10^(P_SOI_est/10); % из дБ в линейные единицы измерения
        
        % инициализация массивов помех SNOI в радиолиниях gNB_UE_est
        P_SNOI_S_est=[]; % массив 1×(UE_num-1) помех внутри одного сектора
        P_SNOI_C_est=[]; % массив 1×(2×UE_num) помех между секторами соты 
        P_SNOI_N_est=[]; % массив 1×(6×3×UE_num) помех между сотами сети

        %% мощность полезного сигнала SOI в радиолинии gNB_UE_tru
        % ДНА в горизонтальной и вертикальной плоскости по ширине луча hpbw
        ARP_SOI_tru = evalbarp(...
            az_tru{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k), Am, ...
            el_tru{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), SLAv);
        % вычисление коэффициента усиления полезного сигнала SOI за счет ДО
        BF_SOI_tru = evalgain(...
            az_tru{j,i}(k), az_est{j,i}(k), az_3dB{j,i}(k),...
            el_tru{j,i}(k), el_est{j,i}(k), el_3dB{j,i}(k), Gbf);
        % координаты точки UE_tru, потери РРВ
        UE_loc_tru = [UE_tru{j,i}(k,1),UE_tru{j,i}(k,2)]; 
        PL_SOI_tru = evalfrisp(gNB_SOI, UE_loc_tru, udn.eff_h, udn.fc);
        % мощность полезного сигнала SOI
        P_SOI_tru=udn.txPowerDBm + udn.Gtx - ...
            PL_SOI_tru + ARP_SOI_tru + BF_SOI_tru;
        P_SOI_tru = 10^(P_SOI_tru/10); % из дБ в линейные единицы измер.
        % инициализация массивов помех SNOI в радиолиниях gNB_UE_tru
        P_SNOI_S_tru=[]; % массив 1×63 помех внутри одного сектора
        P_SNOI_C_tru=[]; % массив 1×128 помех между секторами внутри соты 
        P_SNOI_N_tru=[]; % массив 1×1152 (1152/128=9)помех м/д сотами сети

        %% мощность помех SNOI_S внутри одного сектора
        for m=1:udn.UE_num % цикл по UE с индексами m~=k 
            if m~=k 
                %% мощность помех SNOI_S в радиолинии gNB_UE_est
                % ДНА в горизонтальной/вертикальной плоскости по hpbw               
                ARP_SNOI_S_est = evalbarp(...
                    az_est{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m), Am, ...
                    el_est{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), SLAv);
                % вычисление КУ помех SNOI_S внутри одного сектора при ДО
                BF_SNOI_S_est = evalgain(...
                    az_est{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m),...
                    el_est{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), Gbf);
                % вычисление помех внутри сектора  
                I_SNOI_S_est = udn.txPowerDBm + udn.Gtx - ...
                    PL_SOI_est + ARP_SNOI_S_est + BF_SNOI_S_est;
                I_SNOI_S_est = 10^(I_SNOI_S_est/10); % из дБ в линейные ед.
                P_SNOI_S_est = [P_SNOI_S_est, I_SNOI_S_est];
                %% мощность помех SNOI_S в радиолинии gNB_UE_tru 
                % ДНА в горизонтальной/вертикальной плоскости по hpbw
                ARP_SNOI_S_tru = evalbarp(...
                    az_tru{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m), Am, ...
                    el_tru{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), SLAv);
                % вычисление КУ помех SNOI_S внутри одного сектора при ДО
                BF_SNOI_S_tru = evalgain(...
                    az_tru{j,i}(k), az_est{j,i}(m), az_3dB{j,i}(m),...
                    el_tru{j,i}(k), el_est{j,i}(m), el_3dB{j,i}(m), Gbf);
                % вычисление помех внутри сектора  
                I_SNOI_S_tru =udn.txPowerDBm + udn.Gtx - ...
                    PL_SOI_tru + ARP_SNOI_S_tru + BF_SNOI_S_tru; 
                I_SNOI_S_tru = 10^(I_SNOI_S_tru/10); % из дБ в линейные ед.
                P_SNOI_S_tru = [P_SNOI_S_tru, I_SNOI_S_tru];
            end 
        end 
        
        %% мощность помех SNOI_C между секторами внутри одной соты 
        for l=1:udn.sector_num % цикл по секторам внутри одной соты 
            if l~=i % цикл по секторам с индексами l~=i 
                for m=1:udn.UE_num  % цикл по UE с индексами m
                    %% мощность помех SNOI_C в радиолинии gNB_UE_est
                    % вычисление направления steer_est
                    steer_SNOI_C_est = evalsteer(l, UE_loc_est, gNB_SOI);
                    % ДНА по ширине луча gNB_UE_hpbw_est                   
                    ARP_SNOI_C_est = evalbarp(...
                        steer_SNOI_C_est, az_est{j,l}(m), az_3dB{j,l}(m), Am, ... 
                        el_est{j,i}(k), el_est{j,l}(m), el_3dB{j,l}(m), SLAv);
                    % КУ помех между секторами внутри одной соты за счет ДО
                    BF_SNOI_C_est = evalgain(...
                        steer_SNOI_C_est, el_est{j,l}(m), az_3dB{j,l}(m),...
                        el_est{j,i}(k), el_est{j,l}(m),  el_3dB{j,l}(m), Gbf);
                    % вычисление помех между секторами внутри одной соты 
                    I_SNOI_C_est = udn.txPowerDBm + udn.Gtx - ...
                        PL_SOI_est + ARP_SNOI_C_est + BF_SNOI_C_est;
                    I_SNOI_C_est = 10^(I_SNOI_C_est/10); % из дБ в лин. ед.
                    P_SNOI_C_est = [P_SNOI_C_est, I_SNOI_C_est];
                    %% мощность помех SNOI_C в радиолинии gNB_UE_tru
                    % вычисление направления steer_SNOI_C_tru
                    steer_SNOI_C_tru = evalsteer(l, UE_loc_tru, gNB_SOI); 
                    % ДНА по ширине луча gNB_UE_hpbw_est
                    ARP_SNOI_C_tru = evalbarp(...
                        steer_SNOI_C_tru, el_est{j,l}(m), az_3dB{j,l}(m), Am, ... 
                        el_tru{j,i}(k), el_est{j,l}(m),  el_3dB{j,l}(m), SLAv);
                    % вычисление КУ помех между секторами соты за счет ДО
                    BF_SNOI_C_tru = evalgain(...
                        steer_SNOI_C_tru, az_est{j,l}(m), az_3dB{j,l}(m),...
                        el_tru{j,i}(k), el_est{j,l}(m),  el_3dB{j,l}(m), Gbf); 
                    % вычисление помех между секторами внутри одной соты 
                    I_SNOI_C_tru=udn.txPowerDBm + udn.Gtx -... 
                        PL_SOI_tru + ARP_SNOI_C_tru + BF_SNOI_C_tru;
                    I_SNOI_C_tru = 10^(I_SNOI_C_tru/10); % из дБ в лин. ед.
                    P_SNOI_C_tru = [P_SNOI_C_tru, I_SNOI_C_tru];
                end 
            end 
        end
        
        %% мощность помех SNOI_N между сотами сети
        for n=2:udn.cell_num        % цикл по 6 gNB кроме центральной
            for l=1:udn.sector_num  % цикл по секторам с индексами l
                for m=1:udn.UE_num  % цикл по UE с индексами m
                    % координаты текущей gNB_SNOI_N
                    gNB_SNOI_N=[gNB(n,1),gNB(n,2)]; 
                    %% мощность помех SNOI_N в радиолинии gNB_UE_est
                    % 2D расстояние в р/л между gNB_SNOI_N и UE_loc_est 
                    d2D_SNOI_N_est=norm(UE_loc_est - gNB_SNOI_N);   
                    % 3D расстояние в р/л между gNB_SNOI_N и UE_loc_est
                    d3D_SNOI_N_est=sqrt((udn.eff_h)^2 + (d2D_SNOI_N_est)^2);
                    % угол наклона в р/л между gNB_SNOI_N и UE_loc_est
                    tilt_SNOI_N_est=atan2d(udn.eff_h, d3D_SNOI_N_est); 
                    % угол ориентации в р/л между gNB_SNOI_N и UE_loc_est
                    steer_SNOI_N_est=evalsteer(l,UE_loc_est,gNB_SNOI_N); 
                    % ДНА в горизонтальной/вертикальной плоскости по hpbw
                    ARP_SNOI_N_est = evalbarp(...
                        steer_SNOI_N_est, az_est{n,l}(m), az_3dB{n,l}(m), Am, ... 
                        tilt_SNOI_N_est, el_est{n,l}(m),  el_3dB{n,l}(m), SLAv);
                    % вычисление КУ помех между сотами за счет ДО                   
                    BF_SNOI_N_est = evalgain(...
                        steer_SNOI_N_est, az_est{n,l}(m), az_3dB{n,l}(m),...
                        tilt_SNOI_N_est, el_est{n,l}(m),  el_3dB{n,l}(m), Gbf);
                    % вычисление потерь РРВ
                    PL_SNOI_N_est=21*log10(d3D_SNOI_N_est) +...
                        32.4 + 20*log10(udn.fc);
                    % вычисление помех между сотами сети
                    I_SNOI_N_est=udn.txPowerDBm + udn.Gtx - ...
                        PL_SNOI_N_est + ARP_SNOI_N_est + BF_SNOI_N_est;
                    I_SNOI_N_est = 10^(I_SNOI_N_est/10); % из дБ в лин. ед.
                    P_SNOI_N_est = [P_SNOI_N_est, I_SNOI_N_est]; 
                    %% мощность помех SNOI_N в радиолинии gNB_UE_tru
                    % 2D расстояние в р/л между gNB_SNOI_N и UE_loc_tru
                    d2D_SNOI_N_tru=norm(UE_loc_tru - gNB_SNOI_N); 
                    % 3D расстояние в р/л между gNB_SNOI_N и UE_loc_tru
                    d3D_SNOI_N_tru=sqrt((udn.eff_h)^2 + (d2D_SNOI_N_tru)^2);
                    % угол наклона в р/л между gNB_SNOI_N и UE_loc_tru
                    tilt_SNOI_N_tru=atan2d(udn.eff_h, d3D_SNOI_N_tru);
                    % угол ориентации в р/л между gNB_SNOI_N и UE_loc_tru
                    steer_SNOI_N_tru = evalsteer(l, UE_loc_tru, gNB_SNOI_N);
                    % ДНА в горизонтальной/вертикальной плоскости по hpbw
                    ARP_SNOI_N_tru = evalbarp(...
                        steer_SNOI_N_tru, az_est{n,l}(m), az_3dB{n,l}(m), Am, ... 
                        tilt_SNOI_N_tru, el_est{n,l}(m),  el_3dB{n,l}(m), SLAv);
                    % вычисление КУ помех между сотами за счет ДО
                    BF_SNOI_N_tru = evalgain(...
                        steer_SNOI_N_tru, az_est{n,l}(m), az_3dB{n,l}(m),...
                        tilt_SNOI_N_tru, el_est{n,l}(m),  el_3dB{n,l}(m), Gbf);
                    % вычисление потерь РРВ
                    PL_SNOI_N_tru=21*log10(d3D_SNOI_N_tru) +...
                        32.4 + 20*log10(udn.fc);
                    % вычисление помех между сотами сети
                    I_SNOI_N_tru=udn.txPowerDBm + udn.Gtx - ...
                        PL_SNOI_N_tru + ARP_SNOI_N_tru + BF_SNOI_N_tru;
                    I_SNOI_N_tru = 10^(I_SNOI_N_tru/10); % из дБ в лин. ед.
                    P_SNOI_N_tru = [P_SNOI_N_tru, I_SNOI_N_tru]; 
                end
            end 
        end 
        %% вычисление SINR
        % мощность помех SNOI_S внутри одного сектора
        SINR_S_est{1,i}(k) = P_SOI_est/(sum(P_SNOI_S_est));
        SINR_S_tru{1,i}(k) = P_SOI_tru/(sum(P_SNOI_S_tru)); 
        % мощность помех SNOI_S внутри одного сектора + 
        % мощность помех SNOI_C между секторами внутри одной соты 
        SINR_SC_est{1,i}(k) = P_SOI_est/(sum(P_SNOI_S_est)+sum(P_SNOI_C_est));
        SINR_SC_tru{1,i}(k) = P_SOI_tru/(sum(P_SNOI_S_tru)+sum(P_SNOI_C_tru)); 
        % мощность помех SNOI_S внутри одного сектора + 
        % мощность помех SNOI_C между секторами внутри одной соты +
        % мощность помех SNOI_N между сотами сети
        SINR_SCN_est{1,i}(k) = P_SOI_est/(sum(P_SNOI_S_est)+...
            sum(P_SNOI_C_est) + sum(P_SNOI_N_est));  
        SINR_SCN_tru{1,i}(k) = P_SOI_tru/(sum(P_SNOI_S_tru)+...
            sum(P_SNOI_C_tru)+sum(P_SNOI_N_tru));  
        % мощность помех SNOI_S внутри одного сектора + 
        % мощность помех SNOI_C между секторами внутри одной соты +
        % мощность помех SNOI_N между сотами сети + шум
        SINR_SCNN_est{1,i}(k) = P_SOI_est / (sum(P_SNOI_S_est)+...
            sum(P_SNOI_C_est) + sum(P_SNOI_N_est) + udn.rxNoisePower);
        SINR_SCNN_tru{1,i}(k) = P_SOI_tru / (sum(P_SNOI_S_tru)+...
            sum(P_SNOI_C_tru)+sum(P_SNOI_N_tru) + udn.rxNoisePower);
    end % цикл по числу пользовательских устройств k
end % цикл по числу секторов i
end