% имитационная модель формирует лучи в направлении заданных местоположений,
% в которых обслуживаются пользователи; формирование лучей выполняется на
% основе известного местоположения с заданной погрешностью позиционирования
% затем, после развертывания базовых станций и пользовательских устройств 
% UE, имитационная модель выполняет оценку SINR по всем UE в обслуживаемой 
% соте, окруженной шестью другими сотами, являющимися источниками помех
close all; clear all; clc;
% сценарий Dense-Urban-eMBB согласно ITU-R M.2412-0
udn.plot_enable=0;
udn.cell_num=7;               % число сот
udn.sector_num=3;             % число секторов

udn.UE_num=64;                % число устройств на сектор соты
udn.rcell=100;                % радиус соты, м 
udn.accuracy=10;              % диаметр зоны местоположения UE, м

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

% гексагональный сценарий территориального распределения gNB
[gNB, gNB_cell, gNB_sector]=lab_grid(udn.rcell);

% сценарий территориального распределения UE_loc_est и UE_loc_true
[UE_est, UE_tru]=lab_deploy(udn, gNB, gNB_sector);

% направленные радиолинии gNB_UE_est и gNB_UE_tru
[az_est, el_est, az_tru, el_tru] = lab_link(udn, gNB, UE_est, UE_tru);

% настройка ширины луча HPBW по местоположениям gNB_UE_est
[az_3dB, el_3dB]=lab_hpbw(udn, gNB, UE_est);
 
% оценка показателей sinr в радиолиниях gNB_UE_est и gNB_UE_tru
 [SINR_S_est, SINR_S_tru, SINR_SC_est, SINR_SC_tru, ...
    SINR_SCN_est, SINR_SCN_tru, SINR_SCNN_est, SINR_SCNN_tru] = ...
    lab_sinr(udn, gNB, UE_est, UE_tru, ...
    az_est, el_est, az_tru, el_tru, az_3dB, el_3dB);

udn.accuracy
SINR_S_est_mean = 10*log10(mean(cell2mat(SINR_S_est)))
SINR_S_tru_mean = 10*log10(mean(cell2mat(SINR_S_tru)))
SINR_SC_est_mean = 10*log10(mean(cell2mat(SINR_SC_est)))
SINR_SC_tru_mean = 10*log10(mean(cell2mat(SINR_SC_tru)))
SINR_SCN_est_mean = 10*log10(mean(cell2mat(SINR_SCN_est)))
SINR_SCN_tru_mean = 10*log10(mean(cell2mat(SINR_SCN_tru)))
% SINR_SCNN_est_mean = 10*log10(mean(cell2mat(SINR_SCNN_est)))
% SINR_SCNN_tru_mean = 10*log10(mean(cell2mat(SINR_SCNN_tru)))