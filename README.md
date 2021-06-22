
# `targets` workflow for iSSA with `amt`

![](README_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

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

## Run

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
