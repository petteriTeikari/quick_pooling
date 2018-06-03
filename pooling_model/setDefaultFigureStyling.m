function style = setDefaultFigureStyling()

    % Styling
    style.fontName = 'NeueHaasGroteskDisp Pro Lt';
    style.fontBaseSize = 9;
    style.fontLabelWeight = 'bold';        

    % FIGURE autosave options
    style.imgOutRes       = '-r300'; % dpi
    style.imgOutAntiAlias = '-a2';   % '-a0' least, '-a4' maximum
    style.imgOutautoSavePlot = 1;    
           
    % line plot colors, RGB-colors (divided by 255)
    style.colorGray = [0 0 0];
    style.colorPlot(1,:) = [0 0 0];
    style.colorPlot(2,:) = [0 1 1];
    style.colorPlot(3,:) = [0.87 0.49 0];
    style.colorPlot(4) = style.colorPlot(2);