%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   VU Computer Vision (2018W)
%   Exercise Part - Assignments I
%
%   Group 13-15 03
%   Pintaric Thomas, Vu Minh Nhat, Lassnig Jakob
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;

searchRadius = 15;
cropImages = true;

colorChannels = ['R','G','B'];
imageNames = {'00125v','00149v','00153v','00351v','00398v','01112v'};
showFigure = 2; % either 0 (=disable) or the imageNames index.

for i=1:length(imageNames)
    
    display(['Processing image stack ',imageNames{i},'_*.jpg']);
    
    I_u = []; % unregistered images
    for channel=1:length(colorChannels)
        I_u(:,:,channel) = imread(['images/',...
                           imageNames{i},'_',...
                           colorChannels(channel),...
                           '.jpg']);
        I_u(:,:,channel) = I_u(:,:,channel) ./ 255;
    end
   
    I_r = []; % registered images
    I_r(:,:,1) = I_u(:,:,1);

    crop.h = [0 0]; % horizontal cropping [left right]
    crop.v = [0 0]; % vertical cropping   [top bottom]
    
    correlationCoefficients = [];
    
    for channel=2:size(I_u,3)
        for shiftRows=(-searchRadius):1:searchRadius
            for shiftCols=(-searchRadius):1:searchRadius
                
                correlationCoefficients(shiftRows+searchRadius+1, shiftCols+searchRadius+1) = ...
                    corr2(I_r(:,:,1),circshift(I_u(:,:,channel),[shiftRows shiftCols]));
            end
        end
        
        
        [rowMax,colMax] = find(correlationCoefficients == max(correlationCoefficients(:)));
        t = [rowMax(1)-searchRadius-1 colMax(1)-searchRadius-1];

        display([colorChannels(channel),' shift_xy = [',num2str(t(2)),...
            ' ,',num2str(t(1)),'], correlation coefficient: ',...
            num2str(max(correlationCoefficients(:)))]);
        
        I_r(:,:,channel) = circshift(I_u(:,:,channel), t);
        
        crop.h = max(crop.h, [t(1) -t(1)]);
        crop.v = max(crop.v, [t(2) -t(2)]);
        
        imwrite(correlationCoefficients, ['output/', imageNames{i},'_corr_',colorChannels(channel),'.jpg'], 'Quality', 100);
        if(showFigure == i)
            subplot(1,3,channel-1), imshow(correlationCoefficients, []);
            xticks([1 searchRadius+1 2*searchRadius+1])
            xticklabels({num2str(-searchRadius),'0',num2str(searchRadius)});
            yticks([1 searchRadius+1 2*searchRadius+1])
            yticklabels({num2str(-searchRadius),'0',num2str(searchRadius)});
            title(['corr2(',colorChannels(1),', circshift(',colorChannels(channel),', [X Y]) response']);
            xlabel('X shift (in pixels)');
            ylabel('Y shift (in pixels)');
            axis on
        end
        
    end
    
        I_rc = I_r(1+crop.h(1):size(I_r,1)-crop.h(2),...
                   1+crop.v(1):size(I_r,2)-crop.v(2),:);
               
        imwrite(I_r,  ['output/', imageNames{i},'_RGB.jpg'], 'Quality', 100);
        imwrite(I_rc, ['output/', imageNames{i},'_RGB_cropped.jpg'], 'Quality', 100);

        if(showFigure == i)
            subplot(1,3,3), subimage(I_rc);
            title(['Registered image stack (cropped)']);
            axis off
        end
end
