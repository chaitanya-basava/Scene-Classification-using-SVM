function descriptors = image_descriptors(image)

    L = 2;
    l0_d = 256;
    l1_d = 128;
    l2_d = 64;

    % Resize to 256x256
    M = [l0_d, l0_d];
    scaling = max([M(1)/size(image,1) M(2)/size(image,2)]);

    %scaling = M/min([size(img,1) size(img,2)]);

    newsize = round([size(image,1) size(image,2)]*scaling);
    image = imresize(image, newsize, 'bilinear');

    [nr nc cc] = size(image);

    sr = floor((nr-M(1))/2);
    sc = floor((nc-M(2))/2);

    image = image(sr+1:sr+M(1), sc+1:sc+M(2),:);

    % L = [0, 1, 2]

    % Descriptors at lev
    % descriptors = 128 x num_features_found
    % locations = 2 x num_features_found

    % l = 0
    l0_descriptors = level_descriptors(image, 0, l0_d);

    % l = 1
    l1_descriptors = level_descriptors(image, 1, l1_d);
    % subtract duplicate descriptors
    l1_descriptors = setdiff(l1_descriptors', l0_descriptors', 'rows')';
    
    % l = 2
    l2_descriptors = level_descriptors(image, 2, l2_d);
    l2_descriptors = setdiff(l2_descriptors', l1_descriptors', 'rows')';

    % Weight the levels and combine
    descriptors = [l0_descriptors .* 1/4, l1_descriptors .* 1/4, l2_descriptors .* 1/2];
    %descriptors = [l0_descriptors];
    
end