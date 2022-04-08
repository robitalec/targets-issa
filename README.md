
# targets-iSSA

qs v0.25.3.

Attaching package: ‘renv’

The following objects are masked from ‘package:stats’:

    embed, update

The following objects are masked from ‘package:utils’:

    history, upgrade

The following objects are masked from ‘package:base’:

    autoload, load, remove

Linking to GEOS 3.9.1, GDAL 3.4.0, PROJ 8.2.0; sf_use_s2() is TRUE
Loading required package: sp

Attaching package: ‘sp’

The following object is masked from ‘package:amt’:

    bbox

``` mermaid
graph LR
  subgraph Legend
    uptodate([Up to date]):::uptodate --- stem([Stem]):::none
    stem([Stem]):::none --- pattern[Pattern]:::none
  end
  subgraph Graph
    model_forest([model_forest]):::uptodate --> pred_h1_forest([pred_h1_forest]):::uptodate
    model_forest([model_forest]):::uptodate --> pred_h1_forest([pred_h1_forest]):::uptodate
    model_forest([model_forest]):::uptodate --> tracks_random[tracks_random]:::uptodate
    model_forest([model_forest]):::uptodate --> plot_rss_water([plot_rss_water]):::uptodate
    model_prep([model_prep]):::uptodate --> rss_forest([rss_forest]):::uptodate
    model_prep([model_prep]):::uptodate --> rss_forest([rss_forest]):::uptodate
    model_prep([model_prep]):::uptodate --> dist_sl_plots[dist_sl_plots]:::uptodate
    model_prep([model_prep]):::uptodate --> model_forest([model_forest]):::uptodate
    model_prep([model_prep]):::uptodate --> pred_h1_water([pred_h1_water]):::uptodate
    tracks_resampled[tracks_resampled]:::uptodate --> pred_h1_water([pred_h1_water]):::uptodate
    tracks_resampled[tracks_resampled]:::uptodate --> popdens([popdens]):::uptodate
    tracks_resampled[tracks_resampled]:::uptodate --> legend([legend]):::uptodate
    rss_water([rss_water]):::uptodate --> model_prep([model_prep]):::uptodate
    pred_h1_forest([pred_h1_forest]):::uptodate --> rss_water([rss_water]):::uptodate
    pred_h2([pred_h2]):::uptodate --> rss_water([rss_water]):::uptodate
    pred_h2([pred_h2]):::uptodate --> model_lc([model_lc]):::uptodate
    popdens_file([popdens_file]):::uptodate --> dist_parameters[dist_parameters]:::uptodate
    legend_file([legend_file]):::uptodate --> plot_rss_forest([plot_rss_forest]):::uptodate
    tracks_extract([tracks_extract]):::uptodate --> locs_raw([locs_raw]):::uptodate
    tracks_extract([tracks_extract]):::uptodate --> model_check_lc([model_check_lc]):::uptodate
    pred_h1_water([pred_h1_water]):::uptodate --> tracks_extract([tracks_extract]):::uptodate
    tracks_random[tracks_random]:::uptodate --> tracks_extract([tracks_extract]):::uptodate
    tracks_random[tracks_random]:::uptodate --> tracks_extract([tracks_extract]):::uptodate
    rss_forest([rss_forest]):::uptodate --> tracks_extract([tracks_extract]):::uptodate
    locs_raw_file([locs_raw_file]):::uptodate --> tracks_extract([tracks_extract]):::uptodate
    model_lc([model_lc]):::uptodate --> tracks_extract([tracks_extract]):::uptodate
    elev([elev]):::uptodate --> pred_h2([pred_h2]):::uptodate
    lc([lc]):::uptodate --> pred_h2([pred_h2]):::uptodate
    legend([legend]):::uptodate --> model_check_forest([model_check_forest]):::uptodate
    popdens([popdens]):::uptodate --> split_key([split_key]):::uptodate
    water([water]):::uptodate --> elev([elev]):::uptodate
    locs_prep([locs_prep]):::uptodate --> dist_ta_plots[dist_ta_plots]:::uptodate
    locs_prep([locs_prep]):::uptodate --> tracks[tracks]:::uptodate
    elev_file([elev_file]):::uptodate --> lc([lc]):::uptodate
    lc_file([lc_file]):::uptodate --> locs_prep([locs_prep]):::uptodate
    locs_raw([locs_raw]):::uptodate --> tracks_resampled[tracks_resampled]:::uptodate
    tracks[tracks]:::uptodate --> water([water]):::uptodate
    water_file([water_file]):::uptodate --> avail_lc([avail_lc]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
```

## R setup

``` r
renv::restore()
```

## Run the workflow

``` r
library(targets)
tar_make()
```
