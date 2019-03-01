%===================================================
% Machine Vision and Cognitive Robotics (376.054)
% Exercise 3:  Object recognition with SIFT & Generalized Hough Transform
% Michal Staniaszek, 2017
% Automation & Control Institute, TU Wien
%
% Tutors: machinevision@acin.tuwien.ac.at
%===================================================
% Plot SIFT matches between two images, given the computed frames and
% matches of descriptors.
%
% If the two images differ in size, the one which is smaller in the
% vertical dimension will be displayed on the right.
%
% im1: first image
% im2: second image
% frames1: frames computed on first image
% frames2: frames computed on second image
% matches: matches computed between the frames
% display: options are points or frames. Points will draw points at
% descriptor locations, whereas frames will draw the orientation and scale
% as well.
% colour: options are random or default, default shows lines in green,
% random sets each line to a different colour from the parula colourmap
function plot_matches(im1, im2, frames1, frames2, matches, display, colour)
if nargin < 6
    display = 'points';
end
if nargin < 7
    colour = 'default';
end


if size(im2, 1) > size(im1, 1)
    % swap images if im2 has more rows than im1
    tmp = frames1;
    frames1 = frames2;
    frames2 = tmp;
    tmp = im1;
    im1 = im2;
    im2 = tmp;
end

% Adapted from vl_demo_sift_match.m
% pad out the second image with zeros to match the number of rows in the
% first
imshow(cat(2, im1, [im2;zeros(size(im1,1)-size(im2,1), size(im2,2))]));

xa = frames1(1,matches(1,:));
xb = frames2(1,matches(2,:)) + size(im1,2);
ya = frames1(2,matches(1,:));
yb = frames2(2,matches(2,:));

hold on;
h = line([xa; xb], [ya; yb]);
nmatches = size(matches,2);
if strcmp(colour, 'default')
    set(h,'linewidth', 1, 'color', 'g')
elseif strcmp(colour, 'random')
    colours = cell(nmatches,1);
    c_vals = hsv(nmatches);
    c_vals = c_vals(randperm(nmatches),:);
    for i=1:nmatches
        colours{i} = c_vals(i,:);
    end
    set(h,'linewidth', 1)
    set(h,{'color'}, colours);
else
    sprintf('Unknown colour display setting %s', colour)
end


im1_match_frames = frames1(:,matches(1,:));
frames2(1,:) = frames2(1,:) + size(im1,2);
im2_match_frames = frames2(:,matches(2,:));

hold on;
if strcmp(display, 'points')
    im1_sc = scatter(im1_match_frames(1,:),im1_match_frames(2,:),'og');
    im2_sc = scatter(im2_match_frames(1,:),im2_match_frames(2,:),'og');
elseif strcmp(display, 'frames')
    vl_plotframe(im1_match_frames);
    vl_plotframe(im2_match_frames);
    axis image off;
else
    sprintf('Unknown display argument %s', display)
end
hold off;

end

