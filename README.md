# Quick Pooling model for Photoreceptor Contributions

## Implementation

This repository implements couple of photoreception models in the Quick Pooling model ([Quick 1974](https://www.ncbi.nlm.nih.gov/pubmed/4453110)) framework. I use the melatonin suppression data as demo data for this ([Thapan et al. 2001](https://dx.doi.org/10.1111%2Fj.1469-7793.2001.t01-1-00261.x), [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001)). [Thapan et al. 2001](https://dx.doi.org/10.1111%2Fj.1469-7793.2001.t01-1-00261.x) used a shorter light duration (30 min) for their melatonin suppression study compared to [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001) who used longer duration (90 min exposure). Based on the PLR results by ([McDougal and Gamlin, 2010](https://dx.doi.org/10.1016%2Fj.visres.2009.10.012)), one could hypothesize that [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001) will show greater melanopsin contribution to the melatonin suppression.

### The models implemented

1) **SIMPLE** as described in ([McDougal and Gamlin, 2010](https://dx.doi.org/10.1016%2Fj.visres.2009.10.012)) for pupillometric (PLR) study to investigate the relative contribution of melanopsin to pupillary light response.

Inline-style: 
![Simple model](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_simple.png "Simple model")

2) 

Inline-style: 
![Opponent Kurtenbach 1999](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_opponent1999.png "Opponent Kurtenbach 1999")

3) 

Inline-style: 
![Opponent Spitschan 2014](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_opponent2014.jpg "Opponent Spitschan 2014")

4) 

Inline-style: 
![Opponent Wolders 2018](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_opponent2018.png "Opponent Wolders 2018")

## To use

To clone:

`git clone  --recurse-submodules https://github.com/petteriTeikari/quick_pooling`

To pull and update:

`git pull && git submodule update --recursive --remote`

To run the main script:

Run `TRY_melatonin_models_for_CUSTOM_data.m`

