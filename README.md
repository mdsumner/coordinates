
<!-- README.md is generated from README.Rmd. Please edit that file -->

# coordinates

The goal of coordinates is to provide a simple basis for storing
coordinates. At its simplest this is two vectors of x and y data but
should always include a *coordinate reference system* (i.e. a map
projection) to enable transformations.

In R there are many formal and informal methods for storing coordinates.
The informal ones are efficient and fast. There’s no efficient way to
store raw coordinates in a data frame with reference system metadata:
the closest was sp’s `SpatialPointsDataFrame` but that only worked by
pretending to be a data frame. The tidyverse still has no coordinates
data frame mechanism.

``` r
n <- 1e6
data <- list(x = rnorm(n), y = runif(n))
system.time(plot(data, pch = "."))
```

<img src="man/figures/README-unnamed-chunk-1-1.png" width="100%" />

    #>    user  system elapsed 
    #>   1.142   0.043   1.185
    
    data1 <- cbind(x = data$x, y = data$y)
    system.time(plot(data1, pch = "."))

<img src="man/figures/README-unnamed-chunk-1-2.png" width="100%" />

    #>    user  system elapsed 
    #>   1.282   0.047   1.330
    
    data2 <- as.data.frame(data1)
    system.time(plot(data2, pch = "."))
    #>    user  system elapsed 
    #>   1.258   0.045   1.304
    
    data2.1 <- data2
    data2.1$a <- seq_len(nrow(data2.1))
    library(sf)
    #> Linking to GEOS 3.6.2, GDAL 2.3.3, PROJ 4.9.3

<img src="man/figures/README-unnamed-chunk-1-3.png" width="100%" />

``` r

data3 <- sf::st_as_sf(data2, coords = c("x", "y"))
## don't try this it's exceptionally slow
##data3 <- sf::st_sf(geometry = sf::st_sfc(lapply(split(t(data1), rep(seq_len(nrow(data1)), each = 2)), function(x) sf::st_point(x))))

## it's no surprise that the split-list method of sf POINT is extremely slow
system.time(plot(st_geometry(data3), pch = ".", asp = ""))
```

<img src="man/figures/README-unnamed-chunk-1-4.png" width="100%" />

    #>    user  system elapsed 
    #>   8.102   0.284   8.390
    
    
    library(ggplot2)
    system.time(print(ggplot(data2, aes(x, y)) + geom_point(pch = ".")))

<img src="man/figures/README-unnamed-chunk-1-5.png" width="100%" />

    #>    user  system elapsed 
    #>   6.478   0.100   6.581
    
    ## this is so slow, it's pointless to use geom_sf at all for such simple data
    #system.time(print(ggplot(data3) + geom_sf(pch = ".")))  ## Timing stopped at: 192.5 2.206 194.7

## Installation

You can install the development version of coordinates from
[Github](https://github.com/mdsumner/coordinates) with:

``` r
remotes::install_github("mdsumner/coordinates")
```

## Example

This is a basic example which shows the creation and reprojection of a
set of coordinates. It’s efficient because the storage is vector-based
(x and y are each contiguous chunks of memory, not split across a list
of vectors of matrices).

``` r
library(geosphere)
library(coordinates)
x <- coordinates(randomCoordinates(1e6), crs = "+proj=longlat +datum=WGS84")
system.time(plot(x, pch = "."))
```

<img src="man/figures/README-example-1.png" width="100%" />

    #>    user  system elapsed 
    #>   1.177   0.000   1.178

By using the advanced techniques of vctrs we have defined behaviour to
bind x and y together in a single column, along with persistent metadata
(the coordinate reference system). Using the lightweight transformation
engine of reproj we can transform the object arbitrarily with very
simple code, and we can reproject again and again.

``` r
system.time(plot(x1 <- reproj(x, "+proj=laea +datum=WGS84"), pch = "."))
```

<img src="man/figures/README-proj-1.png" width="100%" />

    #>    user  system elapsed 
    #>   1.535   0.000   1.536
    
    system.time(plot(x2 <- reproj(x1, "+proj=ortho +datum=WGS84"), pch = "."))

<img src="man/figures/README-proj-2.png" width="100%" />

    #>    user  system elapsed 
    #>   1.416   0.000   1.416
    
    system.time(plot(x3 <- reproj(x2, "+proj=merc +datum=WGS84"), pch = "."))

<img src="man/figures/README-proj-3.png" width="100%" />

    #>    user  system elapsed 
    #>    1.05    0.00    1.05
    
    vicgrid <- "+proj=lcc +lat_1=-36 +lat_2=-38 +lat_0=-37 +lon_0=145 +x_0=2500000 +y_0=2500000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
    
    ## when things are a bit funny or out of place we don't get berated or scorned
    ## we simply get what we asked for
    system.time(plot(x4 <- reproj(x3, vicgrid), pch = ".", 
                     xlim = c(-1e7, 1e7), ylim = c(-1e7, 1e7)))

<img src="man/figures/README-proj-4.png" width="100%" />

    #>    user  system elapsed 
    #>   1.309   0.000   1.311
    
    
    system.time(plot(x5 <- reproj(x4, "+proj=longlat +datum=WGS84"), pch = "."))

<img src="man/figures/README-proj-5.png" width="100%" />

    #>    user  system elapsed 
    #>   1.392   0.000   1.392

Technically it’s not possible to round-trip from any projection to
another, we have carefully chosen a round-trippable set of coordinate
systems here.

## Development

There’s more to do\!

  - reproj needs a modern interface to PROJ
  - the vctrs mechanism is only partially implemented here
  - PROJ strings are only partially practical (“+init=epsg:code” form is
    not supported on CRAN for instance)
  - warn on data loss (e.g. UTM, or merc out of bounds, …)
  - flesh out use of coordinates by other packages, e.g. silicate

Please note that the ‘coordinates’ project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to
this project, you agree to abide by its terms.
