# myelintools
Created by Marta Di Fabrizio, Laboratory of Biological Electron Microscopy (LBEM), 

Institute of Physics, School of Basic sciences, EPFL, Lausanne, Switzerland, and

Department of Fundamental Microbiology, Faculty of Biology and Medicine, University of Lausanne, Switzerland.

Myelin sheaths and axons were segmented in Fiji using the semi-automated SAMJ-IJ plugin (https://github.com/segment-anything-models-java/SAMJ-IJ) with manual prompts and manually refined where needed. Custom Fiji macros were used to automate myelin label saving and myelin thickness calculation using the Fiji built-in function Local Thickness (complete process). Average thickness values were automatically extracted from every  myelin sheath with custom routines in Matlab R2023a. The g-ratio was calculated in Matlab R2023a from myelin sheaths from each donor processed for EM using the formula: 

```math
g-ratio = \sqrt{ \frac{Axon Area}{ Axon+Myelin area} } 
```


as the axon shape was often irregular. 
EM myelin sheath images with folds were excluded for the calculation of the g-ratio.

