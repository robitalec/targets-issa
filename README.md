
# `targets` workflow for iSSA with `amt`

## R setup

``` r
options(repos = c(
    ropensci = 'https://ropensci.r-universe.dev',
    tidyverse = 'https://tidyverse.r-universe.dev',
    rspatial = 'https://rspatial.r-universe.dev',
    CRAN = 'https://cloud.r-project.org'))

install.packages(c('data.table', 'amt', 'sf', 'ggplot2', 'raster', 'qs', 'terra' ))
```

## Data setup

Run through `scripts/prep-fisher.R`.

## Run the workflow

``` r
library(targets)
tar_make()
```

    ## qs v0.25.3.
    ## 
    ## Attaching package: ‘renv’
    ## 
    ## The following objects are masked from ‘package:stats’:
    ## 
    ##     embed, update
    ## 
    ## The following objects are masked from ‘package:utils’:
    ## 
    ##     history, upgrade
    ## 
    ## The following objects are masked from ‘package:base’:
    ## 
    ##     load, remove
    ## 
    ## Linking to GEOS 3.9.1, GDAL 3.4.0, PROJ 8.2.0; sf_use_s2() is TRUE
    ## Loading required package: sp
    ## 
    ## Attaching package: ‘sp’
    ## 
    ## The following object is masked from ‘package:amt’:
    ## 
    ##     bbox
    ## 
    ## ✓ skip target lc_file
    ## ✓ skip target popdens_file
    ## ✓ skip target legend_file
    ## ✓ skip target water_file
    ## ✓ skip target elev_file
    ## ✓ skip target locs_raw_file
    ## ✓ skip target lc
    ## ✓ skip target popdens
    ## ✓ skip target legend
    ## ✓ skip target water
    ## ✓ skip target elev
    ## ✓ skip target locs_raw
    ## ✓ skip target locs_prep
    ## ✓ skip branch tracks_fca4f880
    ## ✓ skip branch tracks_3266f1ff
    ## ✓ skip branch tracks_459e55c8
    ## ✓ skip branch tracks_7bf26949
    ## ✓ skip branch tracks_07d6c54a
    ## ✓ skip branch tracks_f495d796
    ## ✓ skip pattern tracks
    ## ✓ skip target split_key
    ## ✓ skip branch tracks_resampled_34106158
    ## ✓ skip branch tracks_resampled_ff26430e
    ## ✓ skip branch tracks_resampled_72f0fe87
    ## ✓ skip branch tracks_resampled_1c380af3
    ## ✓ skip branch tracks_resampled_00c83064
    ## ✓ skip branch tracks_resampled_f5a5ec5f
    ## ✓ skip pattern tracks_resampled
    ## ✓ skip branch tracks_random_8ba21cb0
    ## ✓ skip branch tracks_random_cdeaeca0
    ## ✓ skip branch tracks_random_d793a891
    ## ✓ skip branch tracks_random_806601f2
    ## ✓ skip branch tracks_random_1fe6c783
    ## ✓ skip branch tracks_random_1ee3ea95
    ## ✓ skip pattern tracks_random
    ## ✓ skip branch dist_plots_8ba21cb0
    ## ✓ skip branch dist_plots_cdeaeca0
    ## ✓ skip branch dist_plots_d793a891
    ## ✓ skip branch dist_plots_806601f2
    ## ✓ skip branch dist_plots_1fe6c783
    ## ✓ skip branch dist_plots_1ee3ea95
    ## ✓ skip pattern dist_plots
    ## ✓ skip branch dist_parameters_ec5ab836
    ## ✓ skip branch dist_parameters_328decce
    ## ✓ skip branch dist_parameters_ca449fa6
    ## ✓ skip branch dist_parameters_5b8a1304
    ## ✓ skip branch dist_parameters_f2ae2168
    ## ✓ skip branch dist_parameters_bcf8feb4
    ## ✓ skip pattern dist_parameters
    ## ✓ skip target tracks_extract
    ## ✓ skip target model_prep
    ## ✓ skip target model_lc
    ## ✓ skip target model_forest
    ## ✓ skip target check_model_lc
    ## ✓ skip target pred_h1_forest
    ## ✓ skip target pred_h2
    ## ✓ skip target pred_h1_water
    ## ✓ skip target check_model_forest
    ## ✓ skip target rss_forest
    ## ✓ skip target rss_water
    ## ✓ skip target plot_rss_forest
    ## ✓ skip target plot_rss_water
    ## ✓ skip pipeline

## Explore results

See `scripts/explore-results.R` for a full example.

Below is an example of how to interact with `targets` outputs - but
don’t run them in this README. Copy over to a separate R script or check
out the explore results script.

``` r
library(targets)

## Run the full workflow
tar_make()

## Inspect output with tar_read or tar_load
# *Read* one branch (individual in this case)
tar_read(tracks, 1)
tar_read(tracks, 2)

# Or all combined
tar_read(tracks)

# Plot all distributions
tar_read(distributions)

# *Load* all random steps
tar_load(randsteps)
```
