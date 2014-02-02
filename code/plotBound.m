function [vargout] = plotBound(bound, color, theta)
% PLOTBOUND() plot the bounding box with an orientation angle theta

if nargin < 3
    theta = 0;
else
    theta  =  pi / 2 - theta * pi / 180;
end
    rotMat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
    xCoord = [-bound(3)/2, bound(3)/2, bound(3)/2, -bound(3)/2];
    yCoord = [-bound(4)/2, -bound(4)/2, bound(4)/2, bound(4)/2];
    box    = [xCoord; yCoord];
    rotBox = bsxfun(@plus, rotMat * box, [bound(1) + bound(3)/2; bound(2) + bound(4)/2]);
    rotBox = [rotBox, rotBox(:, 1)];
    plot(rotBox(1, :), rotBox(2, :),[color '-'],'LineWidth',2);
end