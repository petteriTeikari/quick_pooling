function lambda_indices = extractIndices(lambda, lambda_full)

    % SUBFUNCTION to get indices if data points are used for the model
    lambda_indices = zeros(length(lambda),1);

    for jk = 1 : length(lambda)
        lambda_indices(jk) = find(lambda(jk) == lambda_full);
    end  