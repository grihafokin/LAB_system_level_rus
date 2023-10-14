function [UE_est, UE_true]=lab_deploy(udn, gNB, gNB_sector)
% формирование массивов координат gNB_UE_est и gNB_UE_true
UE_est{udn.cell_num,udn.sector_num}=[];
UE_true{1,udn.sector_num}=[];
for j=1:udn.cell_num % цикл по числу сот
    for i=1:udn.sector_num % цикл по числу секторов
        for k=1:udn.UE_num % цикл по числу пользовательских устройств
            if i==1 % сектор 1
                theta=30:0.1:150;
            elseif i==2 % сектор 2
                theta=150:0.1:270;
            elseif i==3 % сектор 3
                theta=-90:0.1:30;
            end
            % для радиолиний UE_est во всех сотах модели сети
            c1=0;
            while c1<1
                key1 = randi([1, length(theta)]);
                % выбор r1 между 0-90 и добавление udn.radius
                r1=((udn.rcell-udn.radius)*rand(1,1))+udn.radius;
                theta1=theta(key1);
                % преобразование в прямоугольную СК
                x1=gNB(j,1)+r1*cosd(theta1);
                y1=gNB(j,2)+r1*sind(theta1);
                xy1=[x1,y1];
                if isinterior(gNB_sector{j,i}, xy1)==1
                    c1=1;
                    UE_est1 = xy1;
                end
            end % while c1<1
            UE_est{j,i}=[UE_est{j,i}; UE_est1];
            if j==1 % для радиолиний gNB_UE_link_true в осблуживающей соте
                c2=0;
                while c2<1 
                    % для равномерного распределения
                    ru2 = (udn.accuracy/2)*sqrt(rand(1,1));
                    theta2 = 2*pi*rand(1,1);
                    x2=UE_est1(1)+ru2*cos(theta2);
                    y2=UE_est1(2)+ru2*sin(theta2);
                    xy2=[x2,y2];
                    % проверка нахождения внутри сектора 
                    if isinterior(gNB_sector{1,i}, xy2)==1
                        c2=1;
                        UE_true2 = xy2;
                    end
                end % while c2<1
                UE_true{j,i}=[UE_true{j,i};UE_true2];
            end % if j==1 
        end % цикл по числу пользовательских устройств
    end % цикл по числу секторов 
end % цикл по числу сот

if udn.plot_enable==1 
    for i=1:udn.cell_num
        plot(gNB_sector{i,1}); hold on;
        plot(gNB_sector{i,2}); hold on;
        plot(gNB_sector{i,3}); hold on; axis equal;
        for j=1:udn.sector_num
            for k=1:udn.UE_num
                plot(UE_est{i,j}(k,1),...
                    UE_est{i,j}(k,2),'b.'); hold on;
                if i==1
                    plot(UE_true{i,j}(k,1),...
                        UE_true{i,j}(k,2),'r.'); hold on;
                end
            end
        end
    end
end
end