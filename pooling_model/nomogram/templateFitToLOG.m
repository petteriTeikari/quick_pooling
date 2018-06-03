function fit = templateFitToLOG(fit)

    fit.specOut      = log10(fit.specOut);
    fit.pointsFitted = log10(fit.pointsFitted);

    