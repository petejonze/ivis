%  Ellipse adds ellipses to the current plot
% 
%  ELLIPSE(ra,rb,ang,x0,y0) adds an ellipse with semimajor axis of ra,
%  a semimajor axis of radius rb, a semimajor axis of ang, centered at
%  the point x0,y0.
% 
%  The length of ra, rb, and ang should be the same.
%  If ra is a vector of length L and x0,y0 scalars, L ellipses
%  are added at point x0,y0.
%  If ra is a scalar and x0,y0 vectors of length M, M ellipse are with the same
%  radii are added at the points x0,y0.
%  If ra, x0, y0 are vectors of the same length L=M, M ellipses are added.
%  If ra is a vector of length L and x0, y0 are  vectors of length
%  M~=L, L*M ellipses are added, at each point x0,y0, L ellipses of radius ra.
% 
%  ELLIPSE(ra,rb,ang,x0,y0,C)
%  adds ellipses of color C. C may be a string ('r','b',...) or the RGB value.
%  If no color is specified, it makes automatic use of the colors specified by
%  the axes ColorOrder property. For several circles C may be a vector.
% 
%  ELLIPSE(ra,rb,ang,x0,y0,C,Nb), Nb specifies the number of points
%  used to draw the ellipse. The default value is 300. Nb may be used
%  for each ellipse individually.
% 
%  h=ELLIPSE(...) returns the handles to the ellipses.
% 
%  as a sample of how ellipse works, the following produces a red ellipse
%  tipped up at a 45 deg axis from the x axis
%  ellipse(1,2,pi/8,1,1,'r')
% 
%  note that if ra=rb, ELLIPSE plots a circle
% 
%
