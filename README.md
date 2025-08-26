
<!-- README.md is generated from README.Rmd. Please edit that file -->

<div align="center">

<table>

<tr>

<!-- Imagen izquierda -->

<td>

<img src="WETSAT-ML_icon.png" alt="Logo WetSAT-ML" width="120">
</td>

<!-- Texto central -->

<td align="center" style="vertical-align: middle; padding-left: 18px; padding-right: 18px; text-align: center;">

<!-- Nuevo título arriba -->

<span style="font-size: 40px; font-weight: bold; display: block; margin-bottom: 6px;">
WetSAT-ML </span> <!-- Frase original abajo -->
<span style="font-size: 18px;"> <strong>W</strong>etlands flooding
<strong>e</strong>xtent and <strong>t</strong>rends using
<strong>SAT</strong>ellite data and <strong>M</strong>achine
<strong>L</strong>earning </span>
</td>

<!-- Imagen derecha -->

<td>

<img src="LOGO_SEI.png" alt="Logo SEI" width="120">
</td>

</tr>

</table>

</div>

## Methodology

WetSAT-ML (Wetlands flooding extent and trends using SATellite data and
Machine Learning) is an open-source R package developed by SEI Latin
America. It enables monitoring of wetland flooding dynamics using
Sentinel-1 radar imagery combined with machine learning algorithms.

The tool integrates with Google Earth Engine and allows users to:

- Generate wetland flooding extent maps.
- Produce water permanence maps.
- Extract flooded area time series.
- Quantify intra-annual and inter-annual wetland hydrological trends.

<div class="figure" style="text-align: left">

<img src="Methodology.png" alt="Figure 1. WetSAT-ML methodology workflow for generating wetland flooding extent and trends using Sentinel-1 data and machine learning." width="100%" />
<p class="caption">

Figure 1. WetSAT-ML methodology workflow for generating wetland flooding
extent and trends using Sentinel-1 data and machine learning.
</p>

</div>

## Concepts behind the WetSAT-ML tool

WetSAT-ML uses Sentinel-1 Synthetic Aperture Radar (SAR) data to map
water extent, overcoming the limitations of optical data, which often
fail in cloudy or dense vegetation conditions.

The algorithm combines radar backscatter from VV and VH polarizations
with five radar-derived indices:

<div style="font-size:100%; width:100%; margin:auto;">

<table style="width:100%; font-size:100%; table-layout:fixed; word-wrap:break-word;">

<thead>

<tr>

<th style="text-align:center;">

Index
</th>

<th style="text-align:center;">

Formula
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

PR - Polarized Ratio
</td>

<td style="text-align:center;">

$\displaystyle \frac{\sigma^{0}_{VH}}{\sigma^{0}_{VV}}$
</td>

</tr>

<tr>

<td style="text-align:left;">

NDPI - Normalized Difference Polarized Index
</td>

<td style="text-align:center;">

$\displaystyle \frac{\sigma^{0}_{VV} - \sigma^{0}_{VH}}{\sigma^{0}_{VV} + \sigma^{0}_{VH}}$
</td>

</tr>

<tr>

<td style="text-align:left;">

NVHI - Normalized VH Index
</td>

<td style="text-align:center;">

$\displaystyle \frac{\sigma^{0}_{VH}}{\sigma^{0}_{VV} + \sigma^{0}_{VH}}$
</td>

</tr>

<tr>

<td style="text-align:left;">

NVVI - Normalized VV Index
</td>

<td style="text-align:center;">

$\displaystyle \frac{\sigma^{0}_{VV}}{\sigma^{0}_{VV} + \sigma^{0}_{VH}}$
</td>

</tr>

<tr>

<td style="text-align:left;">

RVI - Radar Vegetation Index
</td>

<td style="text-align:center;">

$\displaystyle \frac{4 \cdot \sigma^{0}_{VH}}{\sigma^{0}_{VV} + \sigma^{0}_{VH}}$
</td>

</tr>

</tbody>

</table>

</div>

These indices characterize the scattering behavior of radar signals
under different wetland flooding conditions, enabling pixel-level water
detection.

## Tool functions

The WetSAT-ML package contains four main functions. Each function has
practical examples of usage within the documentation:

| Function | Description |
|----|----|
| **`radar_index_stack`** | Calculates radar-derived indices (PR, NDPI, NVHI, NVVI, RVI) from Sentinel-1 VV and VH backscatter and extracts median index values within a buffer around reference stations. |
| **`train_rf_model`** | Trains a Random Forest classifier using radar-derived indices to detect water presence. Returns the trained model, overall accuracy, and variable importance. |
| **`classify_water_surface`** | Applies the trained Random Forest model to classify water and non-water pixels at the image level. Produces wetland flooding maps and water permanence layers. |
| **`performWS`** | Generates time series of flooded areas, intra-annual and inter-annual flooding trends, and hydroperiod statistics. |

## Installation

You can install the development version of WetSAT-ML from GitHub:

``` r
# install.packages("devtools")
# devtools::install_github("dazamora/WETSAT")
```

## Dataset

The Everglades region is located in southern Florida, and it extends
over an area of 9,150 km2 from the margin of Florida Bay in the south to
the Everglades Agricultural Area (EAA) in the north (Figure 1). The area
supports a diverse mosaic of different wetlands, including freshwater
marshes, swamps, sloughs, and wet prairies (Figure 1a). The area also
presents diverse vegetation communities where the sawgrass (especially
Cladium jamaicense) is the most abundant, interspersed with patches of
shrubs with a mix of swamp and bayhead shrub species, and trees with a
mix of swamp, hammock, and bayhead tree species *Palomino-Ángel,
Wdowinski, and Li (2024)*.

<img src="Study_area.png" width="50%" height="50%" style="display: block; margin: auto;" />

## Example

This is a basic example which shows you how to solve a common problem:

``` r

## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

## Datasets

<img src="README-fig.2-1.png" width="100%" style="display: block; margin: auto;" />

## Disclaimer

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-palomino2024" class="csl-entry">

Palomino-Ángel, Sebastián, Shimon Wdowinski, and Shanshan Li. 2024.
“Wetlands Water Level Measurements from the New Generation of Satellite
Laser Altimeters: Systematic Spatial-Temporal Evaluation of ICESat-2 and
GEDI Missions over the South Florida Everglades.” *Water Resources
Research* 60 (3): e2023WR035422.
https://doi.org/<https://doi.org/10.1029/2023WR035422>.

</div>

</div>
