function PL = evalfrisp(gNB_loc, UE_loc, eff_h, fc)
dist2D=norm(gNB_loc-UE_loc);              % 2D 
dist3D=sqrt((eff_h)^2+(dist2D)^2); % 3D
% потери РРВ в радиолинии gNB_loc-UE_loc в условиях LOS, дБ
PL = 32.4 + 21*log10(dist3D) + 20*log10(fc);
end