%% GET PATHS
function [train_image_paths, test_image_paths, train_labels, test_labels]...
    = get_path(data_path, categories, num_train_per_categories)
    % 
    fprintf('Starting read training files and testing files \n');
    num_categories = length(categories); 
    % PATH
    train_image_paths = cell(num_categories * num_train_per_categories, 1);
    test_image_paths  = cell(num_categories * num_train_per_categories, 1);
    % LABELS
    train_labels = cell(num_categories * num_train_per_categories, 1);
    test_labels  = cell(num_categories * num_train_per_categories, 1);
    for i=1:num_categories
       images = dir( fullfile(data_path, 'train', categories{i}, '*.jpg'));
       % take 100 training images ..
       for j=1:num_train_per_categories
           train_image_paths{(i-1)*num_train_per_categories + j} = ...
               fullfile(data_path, 'train', categories{i}, images(j).name);
           train_labels{(i-1)*num_train_per_categories + j} = categories{i};
       end
       % take 100 testing image 
       images = dir( fullfile(data_path, 'test', categories{i}, '*.jpg'));
       for j=1:num_train_per_categories
           test_image_paths{(i-1)*num_train_per_categories + j} = ...
               fullfile(data_path, 'test', categories{i}, images(j).name);
           test_labels{(i-1)*num_train_per_categories + j} = categories{i};
       end
   end
end