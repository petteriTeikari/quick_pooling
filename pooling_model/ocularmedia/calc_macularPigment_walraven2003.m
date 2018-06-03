function [mp_density, mp_density_norm] = calc_macularPigment_walraven2003(lambdaLimits, lambda_res)

    % The model derived by by Walraven [1] as referred by Zagers and van
    % Norren (2004) [2]; and van de Kraats and van Norren (2008) [3].
    
    % INPUTS:
    %
    %   lambdaLimits  2-element vector where the first "lambda(1)" is the
    %                 minimum wavelength in the created template and second
    %                 value "lambda(2)" is the maximum wavelength of the
    %                 created vector. Wavelengths are given in nanometers
    %
    %   lambda_res    the spectral resolution of the created template in
    %                 nanometers
    %
    % OUTPUTS:
    %

    %
    % EXAMPLE OF USE:
    %
    %   macularPigmentOD = createMacularTemplate([380 780], 1)
    %
    % REFERENCES:
    %
    %   [1] P. L. Walraven, CIE Rep. TC 1-36, Draft 7
    %
    %   [2] Niels P. A. Zagers and Dirk van Norren, “Absorption of the eye 
    %       lens and macular pigment derived from the reflectance of cone photoreceptors,” 
    %       Journal of the Optical Society of America A 21, no. 12 (December 1, 2004): 2257-2268.
    %       http://dx.doi.org/10.1364/JOSAA.21.002257
    % 
    %   [3] Jan van de Kraats and Dirk van Norren, “Directional and nondirectional 
    %       spectral reflection from the human fovea,” 
    %       Journal of Biomedical Optics 13, no. 2 (March 0, 2008): 024010-13.
    %       http://dx.doi.org/10.1117/1.2899151
    
    % create the wavelength vector
    lambda  = (linspace(lambdaLimits(1), lambdaLimits(2), (((lambdaLimits(2)-lambdaLimits(1)) / lambda_res) + 1)) )';
    
    % create the scalar vector needed for vectorized version of the
    % template creation
    ones436 = 436 * ones(length(lambda(:,1)), 1);
    ones480 = 480 * ones(length(lambda(:,1)), 1); 
    ones458 = 458 * ones(length(lambda(:,1)), 1);
    ones457 = 457 * ones(length(lambda(:,1)), 1);    
    
    % create the template using the given equation [1] and for the
    % wavelengths specified just above  
    opticalDensity =  (0.32 .* exp(-0.0012 .* ((ones436 - lambda) .^ 2))) ... 
                   + (0.32 .* exp(-0.0012 .* ((ones480 - lambda) .^ 2)))...
                   - (0.123 .* exp(-0.0012 .* ((ones458 - lambda) .^ 2))) ...
                   + (0.12042 .* exp(-0.006 .* ((ones457 - lambda) .^ 2)));

   % assign the results to output variable   
   mp_density = opticalDensity;
   
   % normalize to unity at 460 nm                
   mp_density_norm = mp_density / max(mp_density);   
   
        % if you want to normalize to unity at 460 nm just multiply the created
        % template with a scalar f_norm which was set to 1/0.35 by Zagers and
        % van Norren [2].   
            % f_norm = 1 / 0.35;
            % template(:,1) = template(:,1);
            % templatem(:,2) = f_norm * template(:,2);
    
    
    
    
    
    
    
    
    
    
