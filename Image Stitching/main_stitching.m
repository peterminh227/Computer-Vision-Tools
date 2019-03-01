clc
close all
clear
addpath('../vlfeat-0.9.21/toolbox')
vl_setup
tic
%%%% PARAMETERS %%%%
scene = 'campus';
type = 'jpg';
%%%%%%%%%%%%%%%%%%%%
pic_num = 5;
H = {}; 
orig_img = {};
min_X = []; max_X = [];
min_Y = []; max_Y = [];
for i=1:pic_num-1
    fprintf('Process picture number %d:\n',i);    
[~,inv_best_tform, im_store] = ...
    get_transform(i,i+1, scene,type);
    % transform Hi to H_i+1
    H{i} = inv_best_tform;
    if (i==pic_num-1)
        orig_img{i} = im_store{1};
        orig_img{i+1} = im_store{2};
    else
        orig_img{i} = im_store{1};
    end
end
ref_image = ceil(pic_num/2); %orig_img{ref_image}
temp = combnk(1:pic_num,2); % take the compination
% find the combination
comb = temp(find(any(temp==ref_image,2)),:);
comb = flipud(comb);
HH = H; % copy structure... %
% calculate transformation matrix..
for ii = 1:size(comb,1)
    comb_row = comb(ii,:);
    rot_image_index = comb_row(~(comb_row == ref_image));
    if rot_image_index > ref_image
        % inverse here
        trans_matrix = eye(3);
        for jj=ref_image:rot_image_index-1
            trans_matrix = trans_matrix*H{jj}.T;
        end
        HH{ii}.T = inv(trans_matrix);
        %rot_image{ii} = imwarp...
        %    (orig_img{rot_image_index},...
        %    H{pic_num},'OutputView',imref2d([size_X,size_Y]));
        % do the forward transform here..
        %get corner
        corner = [0 0 size(orig_img{rot_image_index},2)...
            size(orig_img{rot_image_index},2);...
                0 size(orig_img{rot_image_index},1) ...
                0 size(orig_img{rot_image_index},1)];
            
        [X,Y] =  transformPointsForward(HH{ii},corner(1,:),corner(2,:));
        min_X = [min_X min(X)]; max_X = [max_X max(X)];
        min_Y = [min_Y min(Y)]; max_Y = [max_Y max(Y)];
    else
        % normal multiplication here
        trans_matrix = eye(3);
        for jj=rot_image_index:ref_image-1
            trans_matrix = trans_matrix*H{jj}.T;
        end
        HH{ii}.T = trans_matrix;
        corner = [0 0 size(orig_img{rot_image_index},2)...
            size(orig_img{rot_image_index},2);...
                0 size(orig_img{rot_image_index},1) ...
                0 size(orig_img{rot_image_index},1)];
        [X,Y] =  transformPointsForward(HH{ii},corner(1,:),corner(2,:));
        min_X = [min_X min(X)]; max_X = [max_X max(X)];
        min_Y = [min_Y min(Y)]; max_Y = [max_Y max(Y)];
    end
end
%
size_X = ceil(max(max_X) - min(min_X));
size_Y = ceil(max(max_Y) - min(min_Y));
% 
xLimits = [min(min_X) max(max_X)];
yLimits = [min(min_Y) max(max_Y)];
% create rot_image and alpha_blend
a = 0;
alpha{1} = zeros(size(orig_img{1}));
alpha{1}([1,size(orig_img{1},1)],:) = 1;
alpha{1}(:,[1,size(orig_img{1},2)]) = 1;
alpha{1} = bwdist(alpha{1});
alpha{1} = alpha{1}./max(alpha{1}(:));
alpha{1} = double(alpha{1});
for iii = 1:pic_num
    if (iii==ref_image)
        continue;
    else
        a = a + 1;
        rot_image{a} = imwarp...
                (orig_img{iii},...
                HH{a},'OutputView',imref2d([size_Y,size_X], xLimits, yLimits));
        % normalization here: 
        
        alpha_blend{a} = imwarp...
                (alpha{1},...
                HH{a},'OutputView',imref2d([size_Y,size_X], xLimits, yLimits));
    end
end
HH{pic_num} = HH{1};
HH{pic_num}.T = eye(3);
rot_image{pic_num} = imwarp...
            (orig_img{ref_image},...
            HH{pic_num},'OutputView',imref2d([size_Y,size_X],xLimits, yLimits));
%
alpha{pic_num} = alpha{1};
alpha_blend{pic_num} = imwarp...
                (alpha{1},...
                HH{pic_num},'OutputView',imref2d([size_Y,size_X], xLimits, yLimits));
 
%        
panorama = double(rot_image{1}).*alpha_blend{1};
panaroma_withoutalpha = rot_image{1};
sum_alpha = alpha_blend{1};
for i =2:pic_num
    panorama = panorama + double(rot_image{i}).*alpha_blend{i};
    sum_alpha = sum_alpha + alpha_blend{i};
    panaroma_withoutalpha = panaroma_withoutalpha +  rot_image{i};
end
% final step:
toc
panorama = panorama./sum_alpha;
figure(100)
imshow(uint8(panorama))
figure(101)
imshow(panaroma_withoutalpha)

% Supportive function
    function [best_tform,inv_best_tform, img_store] = ...
        get_transform(image1_nr,image2_nr, scene,type)
        path = sprintf('data/%s%01d.%s',scene, image1_nr, type);
        test_im1 = imread(path);
        img_store{1} = test_im1;
        test_im1_gray = double(rgb2gray(test_im1))/255.0 ;
        path = sprintf('data/%s%01d.%s',scene, image2_nr, type);
        test_im2 = imread(path);
        img_store{2} = test_im2;
        test_im2_gray = double(rgb2gray(test_im2))/255.0 ;
        test_im1_gray=test_im1_gray-min(test_im1_gray(:));
        test_im1_gray=test_im1_gray/max(test_im1_gray(:));
        test_im2_gray=test_im2_gray-min(test_im2_gray(:));
        test_im2_gray=test_im2_gray/max(test_im2_gray(:));
            
        %fprintf('Computing frames and descriptors...\n') ;
        [frames1,descr1] = vl_sift(single(test_im1_gray));
        [frames2,descr2] = vl_sift(single(test_im2_gray));
        % plot calculated SIFT descriptors
        %figure(1) ; clf ;
        %subplot(1,2,1) ; imagesc(test_im1) ; colormap gray ;
        %hold on ;
        %h=vl_plotframe(frames1) ; set(h,'LineWidth',2,'Color','g') ;
        %subplot(1,2,2) ; imagesc(test_im2) ; colormap gray ;
        %hold on ;
        %h=vl_plotframe(frames2) ; set(h,'LineWidth',2,'Color','g') ;
        %hold off
        %fprintf('Computing matches...\n') ;
        % By passing to integers we greatly enhance the matching speed (we use
        % the scale factor 512 as Lowe, but it could be even larger without
        % overflow)
        descr1=uint8(512*descr1);
        descr2=uint8(512*descr2);
        matches=vl_ubcmatch(descr1, descr2, 1.5);
        % plot successful matches between images
        %figure(2); clf;
        %plot_matches(test_im1_gray,test_im2_gray,frames1, frames2, matches, 'points', 'random');
        % RANSAC algorithm
        N = 1000;
        best_inliers_count = 0;
        threshold = 5;
        fprintf('Computing matches...\n') ;
        for i = 1:N
            count = 0;
            inliers = [];
            % take 4 matches
            points = matches(:, randperm(size(matches,2),4));
            img1_location = frames1(1:2,points(1,:));
            img2_location = frames2(1:2,points(2,:));
            %try
            if (~is_nonrobust(img1_location)) && (~is_nonrobust(img2_location))
                tform = fitgeotrans(img2_location',img1_location','projective');
                [X,Y] =  transformPointsForward(tform,frames2(1,:),frames2(2,:));
                % speed up the code: 
                d = sqrt((frames1(1,matches(1,:)) - X(1,matches(2,:))).^2 + ...
                        (frames1(2,matches(1,:)) - Y(1,matches(2,:))).^2);
                count = sum(d<threshold);
                inliers = [inliers matches(:,find(d<threshold))];
                
                
                if (count > best_inliers_count)
                    best_inliers_count = count;
                    best_inliers = inliers;
                end
            end 
        end

        % re-calculate best_tform
        img1_location = frames1(1:2,best_inliers(1,:));
        img2_location = frames2(1:2,best_inliers(2,:));
        best_tform = fitgeotrans(img2_location',img1_location','projective');
        inv_best_tform = fitgeotrans(img1_location',img2_location','projective');
    end
    function r = is_nonrobust(X) 
         % r = 1 if points are co-linear, 0 otherwise
         p1 = X(:,1); p2 = X(:,2); p3 = X(:,3); p4 = X(:,4);
         r1 = norm(cross2D(p2-p1,p3-p1)) < eps;
         r2 = norm(cross2D(p2-p1,p4-p1)) < eps;
         r3 = norm(cross2D(p3-p2,p4-p2)) < eps;
         r = (r1 | r2 | r3 );
    end
    function z = cross2D(a,b)
        z = a(1)*b(2) - b(1)*a(2);
    end

