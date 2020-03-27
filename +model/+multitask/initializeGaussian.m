function parameter = initializeGaussian(parameterSize,fan_in)
    parameter = sqrt(2/fan_in).*randn(parameterSize, 'double');
    %parameter = -sqrt(2/fan_in)+ 2*sqrt(2/fan_in).*rand(parameterSize, 'single');% .* 0.01;

    %parameter = randn(parameterSize, 'double').* 0.01;

end