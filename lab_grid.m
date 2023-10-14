function [gNB, gNB_cell, gNB_sector]=lab_grid(r)
% формирование сценария территориального распределения 
radius = 1; % область, недоступная для UE, исключается из сектора
% формирование гексагональной сетки с центральной сотой gNB в точке (0,0);
% центры соседних 6 сот определяются относительно центральной соты
gNB=[0 0]; % расположение базовой станции обслуживающей центральной соты
for theta=30:60:330
    x= r*sqrt(3)*cosd(theta);
    y= r*sqrt(3)*sind(theta);
    gNB = [gNB; x y];
end
% границы базовых станций обслуживающей соты и соседних сот gNB_cell 
for i=1:length(gNB)
    xc = gNB(i,1);
    yc = gNB(i,2);
    xn = [(r+xc) (r/2+xc) (-r/2+xc) (-r+xc) (-r/2+xc) (r/2+xc) (r+xc)];
    yn = [yc (r*sqrt(3)/2+yc) (r*sqrt(3)/2+yc) ...
        yc (-r*sqrt(3)/2+yc) (-r*sqrt(3)/2+yc) yc];
    gNB_cell{i}=polyshape(xn,yn);
end
% границы секторов базовых станций обслуживающей и соседних сот gNB_sector
for i=1:length(gNB)
    xc = gNB(i,1);
    yc = gNB(i,2);
    % сектор 1
    x1 = [xc+3*r/4 xc+r/2 xc-r/2 xc-3*r/4 xc];
    y1 = [yc+r*sqrt(3)/4 yc+r*sqrt(3)/2 yc+r*sqrt(3)/2 yc+r*sqrt(3)/4 yc];
    % сектор 2
    x2 =[xc-3*r/4 xc-r xc-r/2 xc xc];
    y2 =[yc+r*sqrt(3)/4 yc yc-r*sqrt(3)/2 yc-r*sqrt(3)/2 yc];
    % сектор 3
    x3 =[xc xc+r/2 xc+r xc+3*r/4 xc];
    y3 =[yc-r*sqrt(3)/2 yc-r*sqrt(3)/2 yc yc+r*sqrt(3)/4 yc];
    % область, недоступная для использования UE, исключается из сектора
    th = 0:pi/50:2*pi;
    xunit = radius * cos(th) + xc;
    yunit = radius * sin(th) + yc;
    poly0 = polyshape(xunit(1:end-1),yunit(1:end-1));
    % формирование полных секторов
    poly1 = polyshape(x1,y1);
    poly2 = polyshape(x2,y2);
    poly3 = polyshape(x3,y3);
    % используемая область секторов
    gNB_sector{i,1} = subtract(poly1, poly0);
    gNB_sector{i,2} = subtract(poly2, poly0);
    gNB_sector{i,3} = subtract(poly3, poly0);
end
end