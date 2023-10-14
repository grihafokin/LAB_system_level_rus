function [az_3dB, el_3dB] = lab_hpbw(udn, gNB_loc, UE_est)
% формирование массивов ширины луча 
% по азимуту и углу места в радиолиниях UE_est
az_3dB{udn.cell_num,udn.sector_num}=[];
el_3dB{udn.cell_num,udn.sector_num}=[];
for j=1:udn.cell_num % цикл по числу сот
    for i=1:udn.sector_num % цикл по числу секторов
        for k=1:udn.UE_num % цикл по числу пользовательских устройств
            gNB_locj=[gNB_loc(j,1), gNB_loc(j,2)];
            UE_loc_est=[UE_est{j,i}(k,1), UE_est{j,i}(k,2)];
            dist2D_est=norm(UE_loc_est-gNB_locj);          % 2D 
            rc=udn.accuracy/2; % радиус окружности 
            % вычисление az3dB для покрытия зоны неопределенности МП
            % координаты точек пересечения двух окружностей
            [xout,yout]=circcirc(gNB_locj(1,1), gNB_locj(1,2),...
                dist2D_est, UE_loc_est(1), UE_loc_est(2),rc); 
            p1=[xout(1,1),yout(1,1)];
            p2=[xout(1,2),yout(1,2)];
            dp1=norm(gNB_locj-p1); % расстояние точки-центр  
            dp2=norm(gNB_locj-p2); % расстояние точки-центр  
            dpp=norm(p1-p2);
            % эффективное расстояние от центра 
            dp1_eff=sqrt((dp1^2)+(udn.eff_h^2));
            dp2_eff=sqrt((dp2^2)+(udn.eff_h^2));
            az3dB=acosd(((dp1_eff^2)+...
                (dp2_eff^2)-(dpp^2))/(2*dp1_eff*dp2_eff));
            if az3dB < udn.angle_min
                az3dB = udn.angle_min;
            end
            % вычисление el3dB для покрытия зоны неопределенности МП
            theta = 0 : 0.01 : 2*pi; % length(theta) = 629
            xc = UE_loc_est(1) + rc*cos(theta);
            yc = UE_loc_est(2) + rc*sin(theta);
            % вычисл. самой ближней и самой дальней точки окружности от gNB
            near=dist2D_est;
            far=near;
            for n=1:length(xc)       % length(theta) = 629
                point=[xc(1,n) yc(1,n)];
                tmp=norm(gNB_locj-point);
                if tmp<near
                    near=tmp;
                    nearestp=point;
                end
                if tmp>far
                    far=tmp;
                    farthest=point;
                end
            end
            dpp=norm(farthest-nearestp); % расстояние точка-точка 
            % эффективное расстояние от центра
            near_eff=sqrt((near^2)+(udn.eff_h^2));
            far_eff=sqrt((far^2)+(udn.eff_h^2));
            el3dB=acosd(((near_eff^2)+...
                (far_eff^2)-(dpp^2))/(2*near_eff*far_eff));
            if el3dB < udn.angle_min
                el3dB = udn.angle_min;
            end
            % сохранение всех углов каждой точки МП            
            az_3dB{j,i}=[az_3dB{j,i};az3dB];
            el_3dB{j,i}=[el_3dB{j,i};el3dB];
        end % цикл по числу пользовательских устройств 
    end % цикл по числу секторов
end % цикл по числу сот 
end