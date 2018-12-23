#' Title
#'
#' @param x
#' @param y
#'
#' @return
#' @export
#' @importFrom vctrs field new_vctr vec_assert vec_cast
#' @examples
#'
#' new_coordinates()
#' coordinates()
#' x <- new_coordinates(rnorm(10))
#' x
#' as.data.frame(x)
new_coordinates <- function(x = double(),
                            y = double(),
                            crs= character()) {
  vec_assert(x,  double())
  vec_assert(y, double())

  vctrs::new_rcrd(list(x = x, y = y),
                  crs = crs, class = "vctrs_coordinates")
}

#' @name coordinates
#' @importFrom zeallot %<-%
#' @export
coordinates <- function(x = double(), y = double(), crs = character()) {
  UseMethod("coordinates")
}

#' @name coordinates
#' @export
coordinates.default <- function(x = double(), y = double(), crs = character()) {
  c(x, y) %<-% vctrs::vec_cast_common(x, y, .to = double())
  c(x, y) %<-% vctrs::vec_recycle_common(x, y)
  new_coordinates(x, y, crs = crs)
}
#' @name coordinates
#' @export
coordinates.Spatial <- function(x = double(), y = double(), crs = character()) {
 xy <- sp::coordinates(x)
 coordinates(x = xy[,1], y = xy[,2], crs = x@proj4string@projargs)
}
#' @export
format.vctrs_coordinates <- function(x, ...) {
  outx <- formatC(signif(vctrs::field(x, "x"), 3))
  outy <- formatC(signif(vctrs::field(x, "y"), 3))
  out <-   paste(outx, outy, sep = ",")

  out[is.na(outx) | is.na(outy)] <- NA
  out
}



vec_type2.vctrs_coordinates <- function(x, y) UseMethod("vec_type2.vctrs_coordinates")
vec_type2.vctrs_coordinates.default <- function(x, y) stop_incompatible_type(x, y)
vec_type2.vctrs_coordinates.vctrs_unspecified <- function(x, y) x

vec_type2.vctrs_coordinates.vctrs_coordinates <- function(x, y) new_coordinates()
vec_type2.vctrs_coordinates.matrix <- function(x, y) new_coordinates()

vec_cast.vctrs_coordinates <- function(x, to) UseMethod("vec_cast.vctrs_coordinates")
vec_cast.vctrs_coordinates.default <- function(x, to) stop_incompatible_cast(x, to)
vec_cast.vctrs_coordinates.logical <- function(x, to) vec_unspecified_cast(x, to)

#' @name vec_ptype
#' @export
vec_ptype_abbr.vctrs_coordinates <- function(x) "crdnt"
#' @name vec_ptype
#' @export
vec_ptype_full.vctrs_coordinates <- function(x) "coordinates"


#' @export
plot.vctrs_coordinates <- function(x, ...) {
  plot(field(x, "x"), field(x, "y"), ...)
}
