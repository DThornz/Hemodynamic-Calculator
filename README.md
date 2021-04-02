# GOA Calculator

## This code was made to work with MATLAB R2020b and requires the Image Processing Toolbox work properly.

## What is GOA?

If you look in literature regarding aortic valve size and hemodynamic health there is a popular term that is used called the Aortic Valve Area (AVA) and it is a measure of the workable flow area of the aortic valve and is measured by either Doppler echocardiography, catherterization or CT/Echo planimetry. However, each of these methods finds a parameter that is unique from the others: Doppler finds the effective valve area (EOA), catherization finds the Gorlin area, and CT/Echo planimetry finds the geometric valve area (GOA). All of these parameters have been referred to as AVA but they rarely ever match each other except in idealized cases.

The GOA is one of the easiest metrics to calculate as it is solely dependent on having access to a planar image of the valve.

### More information regarding GOA, EOA, and Gorlin's Area can be found in the reference given below.

1. [Garcia D, Kadem L. What do you mean by aortic valve area: geometric orifice area, effective orifice area, or Gorlin area? J Heart Valve Dis. 2006 Sep;15(5):601-8. PMID: 17044363.](https://pubmed.ncbi.nlm.nih.gov/17044363/)

## What does this code do?

Given an input planar image of valve (example: aortic) the code will find the geometric orifice area (GOA) in cm<sup>2</sup> and output an the mask of the region along with an overlay using the original image. You must know at least one real world dimension of your image, either via a scale bar or knowledge of geometric dimensions (leaflet length, annular diameter, etc). Final output examples are shown below.

### Original
<a href="url"><img src="https://github.com/DThornz/GOA_Calculator/blob/main/Exported%20Image%20Results/Original.png" align="center" height="500" width="500" ></a>


### Mask
<a href="url"><img src="https://github.com/DThornz/GOA_Calculator/blob/main/Exported%20Image%20Results/Masked_Img.png" align="center" height="500" width="500" ></a>


### Overlay
<a href="url"><img src="https://github.com/DThornz/GOA_Calculator/blob/main/Exported%20Image%20Results/Overlay.png" align="center" height="500" width="500" ></a>

## How does it do it?

Given a starting image there are a number of image processing steps done before a computer vision section of the code extracts the GOA regions, these are:

1. Image contrasting (imadjust)
2. Image blurring (imgaussfilt)
3. Graph cut (laznsapping)
4. Flood fill (graydiffweight/imsegfmm)
5. Invert mask (imcomplement)
6. Active contour (activecontour)
7. Binarization (imbinarize)
8. Area Extraction (bwarea)

[Details on the mathematics and usage of each step can be found in the MATLAB documentation.](https://www.mathworks.com/help/images/)

[Feel free to fork this on GitHub](https://github.com/DThornz/GOA_Calculator/fork)








