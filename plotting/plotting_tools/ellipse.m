function h = ellipse(r,a,b,varargin)
% annotate an ellipse in a spherical plot
%
% Input
%  r        -  @rotation i.e. matrix of three orthogonal vectors specifying ellipse position
%  a,b      -  long/short half axes of ellipse in radian

rho=(0:1:360)*degree;

h = gobjects(1,length(r));
for i = 1:length(r)

    % distances of points on ellipse from origin
    theta= a(i)*b(i)./(sqrt((a(i)*cos(rho)).^2 + (b(i)*sin(rho)).^2));

    % generate vectors
    c  = vector3d('theta',theta,'rho',rho);

    % rotate c around to final position
     c=rotate(c,r(i));
  
    % plot ellipse
    h(i) = line(c,varargin{:},'hold','add2all');
  
end

if nargout == 0, clear h;end
