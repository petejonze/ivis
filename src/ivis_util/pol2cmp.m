function cmp=pol2cmp(th)
% POL2CMP	Polar coordinate angle to compass reading
% Converts regular matlab angles (counterclockwise radians with zero at
% x-axis) to compass reading (clockwise degrees with zero at north).
%
% cmp = pol2cmp(th)
%
% th	= input of polar coordinate angle in radians
% cmp	= compass reading (0-360)
%
% EXAMPLE: You have current or wind velocities in u (east) and v (north),
% and want to find the compass reading. The magnitude and angle in polar
% coordinates is found by [TH,R] = CART2POL(u,v). The compass reading can
% then be found by CMP = POL2CMP(th).
% 
% See also CART2POL POL2CART

%Time-stamp:<Last updated on 02/09/23 at 15:39:49 by even@gfi.uib.no>
%File:<d:/home/matlab/pol2cmp.m>

cmp=pi/2-th;			% flip and rotate 90 deg

idx = cmp<0;
cmp(idx)=cmp(idx)+2*pi;	% convert negative results (range 0-2pi)

cmp=cmp*180/pi;			% convert to degrees for compass out
