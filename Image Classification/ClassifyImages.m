function [conf_matrix,predicted_labels] = ...
    ClassifyImages(test_image_paths, ~, train_image_features, ...
    train_labels,sift_vocab, categories, neighbors_count, sift_steps)
    fprintf('Start classifying test image... \n');
    % Build database for the trained one.
    knn_class = ...
    fitcknn(train_image_features,train_labels,'NumNeighbors',neighbors_count);%
    % take features of the test image
    test_image_features = ...
        BuildKNN(test_image_paths, sift_steps, sift_vocab);
    predicted_labels = predict(knn_class, test_image_features);
    % construct confusion matrix
    predicted_labels_num = labels_numbers(predicted_labels, categories);
    predicted_labels_num = reshape(predicted_labels_num(:),100,8)';
    conf_matrix = zeros(length(categories), length(categories));
    for i = 1:length(categories) % rows
        for j = 1:length(categories) % coloumn
            conf_matrix(i,j) = sum(predicted_labels_num(i,:)==j);
        end
    end
end