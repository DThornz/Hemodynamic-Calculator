# TAWSS and OSI Calculator

## This code was made to work with MATLAB R2020b 

## What is TAWSS and OSI?

If you look in literature regarding aortic valve size and hemodynamic health there is a popular term that is used called the Aortic Valve Area (AVA) and it is a measure of the workable flow area of the aortic valve and is measured by either Doppler echocardiography, catherterization or CT/Echo planimetry. However, each of these methods finds a parameter that is unique from the others: Doppler finds the effective valve area (EOA), catherization finds the Gorlin area, and CT/Echo planimetry finds the geometric valve area (GOA). All of these parameters have been referred to as AVA but they rarely ever match each other except in idealized cases.

The GOA is one of the easiest metrics to calculate as it is solely dependent on having access to a planar image of the valve.

### More information regarding TAWSS and OSI can be found in the reference given below.

1. [Garcia D, Kadem L. What do you mean by aortic valve area: geometric orifice area, effective orifice area, or Gorlin area? J Heart Valve Dis. 2006 Sep;15(5):601-8. PMID: 17044363.](https://pubmed.ncbi.nlm.nih.gov/17044363/)

## What does this code do?

It processes Fluent exported ASCII data for Wall Shear Stress and XYZ Wall Shear Stresses and then reports back the TAWSS and OSI along with a plot of the surface.

## How does it do it?

For each time step it iterates across all nodes and does a temporal integral from 0 to T. The formulas used are the standard TAWSS and OSI formulas:

### TAWSS

<a href="url"><img src="https://github.com/DThornz/TAWSS-and-OSI-Calculator/blob/main/TAWSS_Eq.jpg" align="center" height="500" width="500" ></a>

### OSI

<a href="url"><img src="https://github.com/DThornz/TAWSS-and-OSI-Calculator/blob/main/OSI_Eq.jpg" align="center" height="500" width="500" ></a>


[Feel free to fork this on GitHub](https://github.com/DThornz/TAWSS-and-OSI-Calculator/fork)








