function steer = evalsteer(sector_id, UE_Loc, gNB_Loc)
% evalsteer вычисляет угол направления steer на точку местоположения UE_Loc 
% в прямоугольной системе координат с центром в точке базовой станции 
% gNB_Loc относительно бисектрисы сектора с идентификатором sector_id:
% в секторе 1 биссектриса = 90°, 
% в секторе 2 биссектриса = 210°, 
% в секторе 3 биссектриса = 330°.
angle = atan2d(UE_Loc(1,2)-gNB_Loc(1,2), UE_Loc(1,1)-gNB_Loc(1,1)); 
sign=0;
% отображение угла в положительном диапазоне 0-360°
if angle<0
    angle= 360+angle;
    sign=1;
end
% в секторе 1 биссектриса = 90°:
if sector_id ==1
    if  angle> 270 && sign==1
        angle = angle - 360;
    end
    steer= 90-angle;  
% в секторе 2 биссектриса = 210°:
elseif sector_id ==2
    if  angle < 30 
        angle = 360 + angle;
    end
    steer = 210-angle;
% в секторе 3 биссектриса = 330°:
elseif sector_id ==3
    if  angle < 150 && sign==0
        angle=360+angle;
    end
    steer = 330-angle;
end
end 