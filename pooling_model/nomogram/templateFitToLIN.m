function fit = templateFitToLIN(fit)
    fit.specOut      = 10 .^ fit.specOut;
    fit.pointsFitted = 10 .^ fit.pointsFitted;

    