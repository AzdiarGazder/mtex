function F = shapeFactor( grains )
% calculates the shape factor of the grain-polygon, without Holes
%
% define as
%
% $$ F = \frac{P}{EP} $$,
%
% where $P$ is the <grain2d.perimeter.html perimeter> and  $EP$ is the
% <grain2d.equivalentPerimeter.html equivalent perimeter>.
%
% Input
%  p - @grain2d
%
% Output
%  F    - shape factor
%
% See also
% polygon/aspectRatio polygon/equivalentPerimeter polygon/perimeter


F = perimeter(grains)./equivalentPerimeter(grains);

