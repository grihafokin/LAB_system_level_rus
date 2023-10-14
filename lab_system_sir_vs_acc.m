% имитационная модель формирует лучи в направлении заданных местоположений,
% в которых обслуживаются пользователи; формирование лучей выполняется на
% основе известного местоположения с заданной погрешностью позиционирования
% затем, после развертывания базовых станций и пользовательских устройств 
% UE, имитационная модель выполняет оценку SINR и пропускной способности по
% всем UE в обслуживаемой соте, окруженной шестью сотами
close all; clear all; clc;
% сценарий Dense-Urban-eMBB согласно ITU-R M.2412-0
udn.plot_enable=0;
udn.cell_num=7;               % число сот
udn.sector_num=3;             % число секторов

udn.UE_num=64;                % число устройств на сектор соты
udn.rcell=100;                % радиус соты, м 

udn.radius=10;                % зона ограничения вокруг соты
udn.UE_h = 1.5;               % высота антенны UE, м
udn.gNB_h = 15;               % высота антенны gNB, м
udn.eff_h=udn.gNB_h-udn.UE_h; % эффективная высота, м 
udn.txPowerDBm = 40;          % совокупная мощность передачи (80 МГц), дБм 
udn.txPower=(10.^((udn.txPowerDBm-30)/10)); % перевод дБм в Вт
udn.Am = 25;                  % коэффициент подавления задних лепестков, дБ
udn.SLAv = 20;                % предельный уровень боковых лепестков, дБ  
udn.GdB = 15;                 % коэффициент усиления АР малой соты, дБи
udn.G = 10^(udn.GdB/10);      % коэффициент усиления АР малой соты, раз
udn.Gtx=3;                    % коэффициент усиления элемента АР, дБи 
udn.fc=30 ;                   % несущая частота, ГГц
udn.angle_min=3;              % минимальное значение hpbw, градусы
udn.bw = 80e6;                % ширина полосы 80 МГц
udn.rxNoiseFigure = 5;        % коэффициент шума приемника UE, дБ  
udn.rxNoisePowerdB = ...
    -174 + 10*log10(udn.bw) + udn.rxNoiseFigure - 30;  % мощность шума, дБ
udn.rxNoisePower = 10^(udn.rxNoisePowerdB/10);         % мощность шума, Вт      
udn.nrow = 32;                % число элементов в строке прямоугольной АР
udn.ncol = 32;                % число элементов в столбце прямоугольной АР
 % мощность передачи одного элемента АР, Вт 
udn.txPowerSE = udn.txPower/(udn.nrow*udn.ncol);
udn.Gbf=10*log10(udn.nrow*udn.ncol);   % максимальный КУ при ДО, дБ

acc=[1:1:10];                            % диаметр зоны местоположения UE, м
for i=1:length(acc)
    acc(i)
    udn.accuracy=acc(i);
    % гексагональный сценарий территориального распределения gNB
    [gNB, gNB_cell, gNB_sector]=lab_grid(udn.rcell);
    % сценарий территориального распределения UE_est и UE_true
    [UE_est, UE_tru]=lab_deploy(udn, gNB, gNB_sector);
    % настройка ориентации лучей по местоположениям UE_est и UE_true
    [az_est, el_est, az_tru, el_tru] = lab_link(udn, gNB, UE_est, UE_tru);
    % настройка ширины лучей по местоположениям UE_est и UE_true
    [az_3dB, el_3dB]=lab_hpbw(udn, gNB, UE_est);
    % оценка показателей sinr в направленных радиолиниях
    [SINR_S_est, SINR_S_tru, SINR_SC_est, SINR_SC_tru, ...
        SINR_SCN_est, SINR_SCN_tru, SINR_SCNN_est, SINR_SCNN_tru] = ...
        lab_sinr(udn, gNB, UE_est, UE_tru, ...
        az_est, el_est, az_tru, el_tru, az_3dB, el_3dB);
    % усреднение ширины лучей по местоположениям gNB_UE_link_est  
    az_3dB_mean(i) = mean(mean(cell2mat(az_3dB)));
    el_3dB_mean(i) = mean(mean(cell2mat(el_3dB)));
    % усреднение показателей sdma в радиолиниях gNB_UE_est и gNB_UE_tru   
    SINR_S_est_mean(i) = 10*log10(mean(cell2mat(SINR_S_est)));
    SINR_S_tru_mean(i) = 10*log10(mean(cell2mat(SINR_S_tru)));
    SINR_SC_est_mean(i) = 10*log10(mean(cell2mat(SINR_SC_est)));
    SINR_SC_tru_mean(i) = 10*log10(mean(cell2mat(SINR_SC_tru)));
    SINR_SCN_est_mean(i) = 10*log10(mean(cell2mat(SINR_SCN_est)));
    SINR_SCN_tru_mean(i) = 10*log10(mean(cell2mat(SINR_SCN_tru)));
    SINR_SCNN_est_mean(i) = 10*log10(mean(cell2mat(SINR_SCNN_est)));
    SINR_SCNN_tru_mean(i) = 10*log10(mean(cell2mat(SINR_SCNN_tru)));
end
figure(1);
plot(acc,SINR_S_est_mean,'r-','linewidth',1); hold on;
plot(acc,SINR_S_tru_mean,'r--','linewidth',1); hold on;
plot(acc,SINR_SC_est_mean,'b-','linewidth',1); hold on;
plot(acc,SINR_SC_tru_mean,'b--','linewidth',1); hold on;
plot(acc,SINR_SCN_est_mean,'g-','linewidth',1); hold on;
plot(acc,SINR_SCN_tru_mean,'g--','linewidth',1); hold on;
grid on; axis('tight'); ylabel('SINR, дБ'); xlabel('\sigma, м');
legend('UE_{est} S','UE_{tru} S','UE_{est} S+C','UE_{tru} S+C','UE_{est} S+C+N','UE_{tru} S+C+N'); 

figure(2);
plot(acc,az_3dB_mean,'m-','linewidth',2); hold on;
plot(acc,el_3dB_mean,'g--','linewidth',2); grid on;
axis('tight'); ylabel('HPBW, \circ'); xlabel('\sigma, м');
legend('\phi_{3дБ}','\theta_{3дБ}'); 