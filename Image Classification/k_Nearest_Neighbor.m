function [prediction,conf_matrix] = k_Nearest_Neighbor(train_image_features, ...
    train_labels, test_image_features, categories, neighbors_count)
    %
    fprintf('Start prediction process... \n');
    train_N = size(train_image_features, 1);
    test_N = size(test_image_features, 1);
    prediction = cell(test_N, 1);
    prediction_nums = zeros(test_N, 1);
    K = neighbors_count;
    for i=1:test_N

        distances = zeros(train_N,1);
        for j=1:train_N
            distances(j) = vl_alldist2...
            (test_image_features(i,:)', train_image_features(j,:)', 'l2');
        end    
        [~, idx] = sort(distances);
        % get neighbors ... % first 20 nearst neighbors will be chosen.
        k_labels = cell(K, 1);
        for j=1:K
            k_labels(j) = train_labels(idx(j));
        end
        % take index of the labels..
        k_labels_numbers = labels_numbers(k_labels, categories);
        % see which label was the most mentioned
        occurances = zeros(K, 1);
        for j = 1:K
            occurances(j) = sum(k_labels_numbers == k_labels_numbers(j));
        end
        [~, index] = ismember(max(occurances), occurances);
        % shorten above code by using fitcknn
        
        %
        prediction{i} = k_labels{index};
        prediction_nums(i) = k_labels_numbers(index);
    end
    
    % Confusion matrix ...
        % construct confusion matrix
    prediction_nums = reshape(prediction_nums(:),100,8)';
    conf_matrix = zeros(length(categories), length(categories));
    for i = 1:length(categories) % rows
        for j = 1:length(categories) % coloumn
            conf_matrix(i,j) = sum(prediction_nums(i,:)==j);
        end
    end
end