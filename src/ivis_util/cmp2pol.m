function theta=cmp2pol(cmp)
    cmp = -cmp+90;			% flip and rotate 90 deg
    theta = (pi/180)*cmp; % ALT: deg2rad(cmp);
end