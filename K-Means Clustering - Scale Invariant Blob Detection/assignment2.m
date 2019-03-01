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

imageNames = {'simple.PNG','future.jpg','mm.jpg'};
%imageNames = {'simple.PNG'};
%imageNames = {'future.jpg'};
showIntermediateResults = false; % only for debugging
showFinalResult = true;
useGlobalColormap = false; % only for debugging
n_dims = 3; % feature vector dimensions (either 3 or 5)
n_clusters = 4; % number of clusters
epsilon = 1E-3;

figure_n = 0;
global_colormap = imresize(colormap('parula'),[n_clusters 3],'nearest');

assert(n_clusters >= 1);
assert(n_dims ==3 || n_dims == 5);

for i=1:length(imageNames)
    
    % ----------------------------------------
    % Initialization Step
    % ----------------------------------------
    
    clear Info;
    
    display(['Processing "',imageNames{i},'"']);
    I = double(imread(['images/',imageNames{i}])); % load RGB image from file
    [X,Y] = meshgrid(1:size(I,2), 1:size(I,1)); % [X,Y] = pixel coordinates
    x3 = reshape(I,[size(I,1)*size(I,2),size(I,3)]); % create 3D feature vector [R G B]
    x5 = [x3 reshape([X Y],[size(I,1)*size(I,2),2])]; % create 5D feature vector [R G B X Y]

    x = [];
    switch n_dims
        case 3
            x = x3;
        case 5
            x = x5;
        otherwise
            error('Invalid number of feature vector dimensions.');
    end

    assert(size(x,2) == n_dims);
    n_samples = size(x,1);

    % normalize feature vector
    x = x - min(x,2); %?
    
    x = x ./ repmat(max(x,[],1), n_samples,1);
    
    % choose initial centroid locations
    % Ck(k,:) = 1 x n_dims feature vector
    Ck = zeros(n_clusters, n_dims);

    % first centroid is the median feature vector
    Ck(1,:) = median(x,1);
    
    for k=2:n_clusters
        % place additional centroids at maximum euclidean distance 
        % from existing centroids
        dist2 = zeros(n_samples, k-1);
        for j=1:(k-1)
            
            
            dist2(:,j) = sum((repmat(Ck(j,:),n_samples,1)-x).^2,2).^2;
        end
        size(dist2)
        dist2 = sum(dist2,2);
        dist2_argmax = find(dist2==max(dist2));
        Ck(k,:) = x(dist2_argmax(1),:);
        
    end

    % ----------------------------------------
    % Iteration Steps
    % ----------------------------------------

    iteration = 0; % current iteration
    maxIteration = 100; % maximum number of iterations
    keepGoing = true;
  
    while iteration < maxIteration

        iteration = iteration + 1;

        % Assign all data points to their nearest cluster centroids
        J = [];
      
        for j=1:k
            J(:,j) = sum((x - Ck(j,:)).^2,2);
        end
      
        [J_min, J_argmin] = min(J,[],2); % J_argmin stores the cluster assignment

        % J = distortion measure, sum of the squares of the distances of 
        %     each data point to its assigned cluster centroid
        J = sum(J_min);
      
        Info{iteration}.J = J;
        %display(['Iteration ',num2str(iteration),': J=',num2str(J,6)]);
       
        
        if(iteration > 1)
            
            J_ratio = Info{iteration-1}.J / J;
            %display(['Iteration ',num2str(iteration),': J0/J1 = ',num2str(J_ratio,6)]);
            if(J_ratio < (1.0 + epsilon))
                maxIteration = iteration;
                display(['Stopping after ',num2str(maxIteration),' iteration(s).']);
            end
            
        end

        % Compute the new cluster centroids as the mean of all data points
        % assigned to that cluster:    
        for j=1:k
            idx = find(J_argmin == j);
            if(~isempty(idx))
                Ck(j,:) = mean(x(idx,:),1);
            end
        end


        if(showIntermediateResults || iteration == maxIteration)
            
            % compute colormap (for coloring all pixels of a cluster 
            % with their mean color values)
            for j=1:k
                Info{iteration}.custom_colormap(j,:) = mean(x3(J_argmin==j,:),1);
            end
            
            Info{iteration}.Ck = Ck;
            Info{iteration}.iteration = iteration;
            Info{iteration}.I = reshape(J_argmin,[size(I,1),size(I,2),1]);
        end
        
    end %  while iteration < maxIteration


    if(showIntermediateResults)
        n = ceil(sqrt(length(Info)));
        for j=1:length(Info)
            figure_n  = figure_n +1;
            figure(figure_n);
            subplot(n,n,Info{j}.iteration);
            if(useGlobalColormap)
                imshow(Info{j}.I, global_colormap);
            else
                imshow(Info{j}.I, uint8(Info{j}.custom_colormap));
            end
            title(['i=',num2str(j)]);
        end
    end

    if(showFinalResult)
        figure_n  = figure_n +1;
        figure(figure_n);
        j = length(Info);
        if(useGlobalColormap)
            imshow(Info{j}.I, global_colormap);
        else
            imshow(Info{j}.I, uint8(Info{j}.custom_colormap));
        end
        title(['# iterations: ',num2str(j)]);
    end

end % for i=1:length(imageNames)