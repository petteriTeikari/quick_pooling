# Quick Pooling model for Photoreceptor Contributions

## Implementation

This repository implements couple of photoreception models in the Quick Pooling model ([Quick 1974](https://www.ncbi.nlm.nih.gov/pubmed/4453110)) framework. I use the melatonin suppression data as demo data for this ([Thapan et al. 2001](https://dx.doi.org/10.1111%2Fj.1469-7793.2001.t01-1-00261.x), [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001)). [Thapan et al. 2001](https://dx.doi.org/10.1111%2Fj.1469-7793.2001.t01-1-00261.x) used a shorter light duration (30 min) for their melatonin suppression study compared to [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001) who used longer duration (90 min exposure). Based on the PLR results by ([McDougal and Gamlin, 2010](https://dx.doi.org/10.1016%2Fj.visres.2009.10.012)), one could hypothesize that [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001) will show greater melanopsin contribution to the melatonin suppression.

This hypothesis of increased melanopsin contribution in the longer duration of [Brainard et al. 2001](https://doi.org/10.1523/JNEUROSCI.21-16-06405.2001) seems to be supoprted by the model (no statistics done). The latest opponent  opponent model from the PLR paper by [Woelders et al. (2018)](https://doi.org/10.1073/pnas.1716281115) (see further below) was used for this (while note that the circuit driving melatonin suppression might not be the same as for PLR).

![Init fit](https://github.com/petteriTeikari/quick_pooling/blob/master/R_figures_out/parameter_evolution.png "Init fit")

The opponent model from [Woelders et al. (2018)](https://doi.org/10.1073/pnas.1716281115) is able to follow the melatonin data quite well:

![Init fit](https://github.com/petteriTeikari/quick_pooling/blob/master/R_figures_out/model_fit_comparison.png "Init fit")

_Note that the model fits seem to overlap probably due to optimization issues with `fmincon` and further playing around could be done with the optimization algorithm_ Or you can try just brute force [Genetic Algorithms](https://github.com/estsauver/GAOT) as used in my other project for [Spectral Separability](https://github.com/petteriTeikari/spectralSeparability) for reducing spectral crosstalk between multiphoton dyes.

See the following line in `poolingModel_main.m`:

```matlab
optimOpt = optimset(optimOpt, 'Algorithm', 'interior-point');
```

### Retinal circuit driving the melatonin suppression?

![Init fit](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/retinalCircuit.png "Init fit")

_See [the build-up](https://www.dropbox.com/s/696l35u8aspquwp/reaMelatonin_manuscript.pdf?dl=0f) on how this was imagined back in 2013_

## To use

To clone:

`git clone  --recurse-submodules https://github.com/petteriTeikari/quick_pooling`

To pull and update:

`git pull && git submodule update --recursive --remote`

### MATLAB: Quick Pooling model

To run the main script in MATLAB that does the fitting with `fmincon`:

Run `TRY_melatonin_models_for_CUSTOM_data.m`

#### Detailed MATLAB instructions

For some more detailed walk-through of the rather patchy **[Matlab code in the Wiki](https://github.com/petteriTeikari/quick_pooling/wiki/Matlab-implementation-details)**

### R: Analysis and prettier plotting of the results

Run `plot_matlab_fitting.R`

#### Detailed R instructions

**TODO!**

## The models implemented

### **1) SIMPLE** 

as described in ([McDougal and Gamlin, 2010](https://dx.doi.org/10.1016%2Fj.visres.2009.10.012)) for pupillometric (PLR) study to investigate the relative contribution of melanopsin to pupillary light response.

![Simple model](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_simple.png "Simple model")

### **2) Kurtenbach et al.(1999): Spectral Opponency**

[Kurtenbach et al. (1999)](http://dx.doi.org/10.1364/JOSAA.16.001541) demonstrated some color opponency "compound action spectra" for trichromatic, deuteranopic and protanopic individuals:

![Opponent Kurtenbach 1999](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_opponent1999.png "Opponent Kurtenbach 1999")

### **3) Spitschan et al. (2014): PLR and spectral opponency revisited**

[Spitschan et al. (2014)](https://dx.doi.org/10.1073/pnas.1400942111): **S = Melanopsin + (MWS+LWS) - SWS** *+Rods (PT)* 

![Opponent Spitschan 2014](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_opponent2014.jpg "Opponent Spitschan 2014")

### **4) Woelders et al. (2018): PLR and spectral opponency revisited**

[Woelders et al. (2018)](https://doi.org/10.1073/pnas.1716281115): **S = Melanopsin -MWS +LWS - SWS** *+Rods (PT)* 

![Opponent Wolders 2018](https://github.com/petteriTeikari/quick_pooling/blob/master/data_out_from_matlab/custom_opponent2018.png "Opponent Wolders 2018")


## Some further theory

### McDougal and Gamlin (2010): No Spectral Opponency

[McDougal and Gamlin (2010)](https://doi.org/10.1016/j.visres.2009.10.012) modeled the PLR dynamics using the Quick pooling model ([Quick (1974)](https://doi.org/10.1007/BF00271628))

![Model](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/mcdougalGamlin2010_quickPoolingModel.png "Model")

![Idea](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/mcdougalGamlin2010_quickPoolingIdea.png "Idea")

_Illustration of the effect of changing the curve fitting parameters of Eq. (4) on the composite spectral sensitivity derived from the combination of rod and cone spectral sensitivities. Panels A, C, and E demonstrate the effect of changing the value of the parameter k in Eq. (4) to 1 (A), 2 (C), and 100 (E). Panels B, D, and F demonstrate the effect of changing the relative contribution of the rod and cone signals on the spectral sensitivity of the overlying function, by setting c = 0.5r (B), c = 0.1r (D), and c = 0.03r (F)._

![Results](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/mcdougalGamlin2010_quickPoolingResults.png "Results")

_Relative contribution of the rod, cone, and melanopsin photoresponse to the spectral sensitivity of the PLR over time. The time course of light adaptation of the rod (■), cone (♦), and melanopsin (●) photoresponses while maintaining a half maximal PLR with (A) no background present, (B) a 50 td adapting background, and (C) a three-quarter maximal PLR with a 50 td adapting background. Light adaptation was calculated by the combining the difference in absolute irradiance necessary to maintain these responses with the change in relative contribution of each of the photoresponses to the composite spectral sensitivity function generated for each duration condition of each of the three experiments (see Section 2.4 for details). Each point is relative to the most sensitive photoresponse at the shortest duration condition. The smooth line through each data set is the best fit of a three parameter single exponential decay function to the data._

![Results Table](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/mcdougalGamlin2010_quickPoolingResultsTable.png "Results Table")

### Kurtenbach et al.(1999): Spectral Opponency

[Kurtenbach et al. (1999)](http://dx.doi.org/10.1364/JOSAA.16.001541) demonstrated some color opponency "compound action spectra" for trichromatic, deuteranopic and protanopic individuals:

![Trichromatic](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/kurtenbach1999_trichromatic.png "Trichromatic")

![deuteranopic](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/kurtenbach1999_deuteranopic.png "Deuteranopic")

![protanopic](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/kurtenbach1999_protanopic.png "Protanopic")

### Enter the "notches" and "bumps"

From : _"[Krastel, Alexandridis, and Gertz (1985)](https://doi.org/10.1159/000309536) provided the **first evidence that the pupillary system has access to a "color opponent" visual process**. Krastel et al. showed that the pupillary action spectrum for chromatic flashes on a steady-white background was virtually identical to the spectral sensitivity curve obtained psychophysically under the same stimulus conditions. That is, the action spectrum has **three prominent lobes** with maxima in a long, middle, and short wavelength region and has a **prominent dip** in sensitivity near 570 nm, resembling what visual psychophysicists call the **"Sloan notch"** (see also [Schwartz 2002](https://doi.org/10.1046/j.1475-1313.2000.00535.x), [Calkins et al. 1992](https://doi.org/10.1016/0042-6989(92)90098-4))."_

From Petteri Teikari's PhD thesis: 
[Spectral modulation of melanopsin responses : role of
melanopsin bistability in pupillary light reflex](https://tel.archives-ouvertes.fr/file/index/docid/999326/filename/TH2012_Teikari_Petteri_ii.pdf)

[![Sloan Notch](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/teikari2012_thesis_sloanNotch.png "Sloan Notch")](https://tel.archives-ouvertes.fr/file/index/docid/999326/filename/TH2012_Teikari_Petteri_ii.pdf)

### Kimura and Young (1995)

[Kimura and Young (1995)](http://dx.doi.org/10.1016/0042-6989(94)00188-R)

![Sloan Notch](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/kimuraYoung1995_sloanNotch.png "Sloan Notch")

_Action spectra derived from the ON, OFF, and steady-state portions of the pupillary response waveform. **(A) Action spectra for individual observers**. The ON action spectra for all observers are plotted in actual quantal sensitivity (reciprocal quanta sec -t deg-2). The psychophysical spectral sensitivity curve (bold solid lines) and other action spectra, however, were shifted vertically to illustrate their similarities and differences. The OFF and steady-state spectra for observer A were shifted by + 0.2 and -0.45, respectively. The steady-state spectrum for observer J was shifted by -0.65. The psychophysical spectral sensitivity curve, OFF and the steady-state spectra for observer M were shifted by -0.5, +0.2 and
-0.3, respectively. Thee action spectra derived from the **high criterion ON amplitude** and from the **steady-state amplitudes**  can be reasonably described as a **linear sum** of the quantized scotopic and photopic luminous efficiency functions. The relative weights for the photopic function were 49% for observer A, 13% for observer J, and 20% for observer M. **Alternatively**, the two action spectra can be described as a **linear sum of the LWS-,MWS-, and SWS-cone spectra** (thin dotted line; Smith & Pokorny, 1975). The relative weights for LWS- and MWS-cones were 30% and 37% for observer A, 3% and 41% for observer J, and 14% and 20% for observer M, respectively._

### Adhikari et al. (2016): Reproducing McDougal and Gamlin's findings

[Adhikari et al. (2016)](https://doi.org/10.1371/journal.pone.0161175)

_Here, we evaluated the **photoreceptor contributions** to the early phase post-illumination persistent response (PIPR, 0.6 s to 5.0 s) by measuring the spectral sensitivity of the criterion PIPR amplitude in response to 1 s light pulses at five narrowband stimulus wavelengths (409, 464, 508, 531 and 592 nm). The retinal irradiance producing a criterion PIPR was normalised to the peak and fitted by either a single photopigment nomogram or the combined melanopsin and rhodopsin spectral nomograms with the +L+M cone photopic luminous efficiency (Vλ) function._

![Init fit](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/journal.pone.0161175.g006.PNG "Init fit")

### Gooley et al. (2010): Showing similar time-dependency for melatonin suppression when comparing 460 nm to 555 nm

[Gooley et al. (2010)](http://doi.org/10.1126/scitranslmed.3000741)

_Dose-response curves for melatonin suppression and circadian phase resetting were constructed in subjects exposed to blue (460 nm) or green (555 nm) light near the onset of nocturnal melatonin secretion. At the **beginning of the intervention** (Q1), 555-nm light was equally effective as 460-nm light at suppressing melatonin, suggesting a significant contribution from the three-cone visual system (lamba max = 555 nm). During the light exposure, however, the spectral sensitivity to 555-nm light **decayed exponentially** relative to 460-nm light (last time point the Q4)._

![Init fit](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/gooley2010_melatoninSuppressionTimeDependency.png "Init fit")

### Stabio et al. (2018): M5 Color Opponency

The M5 Cell: A Color-Opponent Intrinsically Photosensitive Retinal Ganglion Cell
_Maureen E. Stabio, Shai Sabbah, Lauren E. Quattrochi, Marissa C. Ilardi, P. Michelle Fogerson, Megan L. Leyrer, Min Tae Kim, Inkyu Kim, Matthew Schiel, Jordan M. Renna, Kevin L. Briggman, David M. Berson_

[Stabio et al. (2018)](https://doi.org/10.1016/j.neuron.2017.11.030)

_Serial electron microscopic reconstructions revealed that **M5 cells receive selective UV-opsin drive** from **Type 9 cone bipolar cells** but also **mixed cone signals from bipolar Types 6, 7, and 8**. Recordings suggest that both excitation and inhibition are driven by the ON channel and that **chromatic opponency results from M-cone-driven** surround inhibition mediated by wide-field spiking GABAergic amacrine cells. We show that M5 cells send axons to the dLGN and are thus positioned to provide chromatic signals to visual cortex. These findings underscore that melanopsin's influence extends beyond unconscious reflex functions to encompass cortical vision, perhaps including the **perception of color**._

![Init fit](https://github.com/petteriTeikari/quick_pooling/blob/master/images_biblio/stabio2018_M5.png "Init fit")
