#' Check whether inputs are valid IUCN status codes.
#' 
#' A warning is raised if a item in \code{statuses} is not found. This item
#' is removed from the vector. If none of the items are valid, raise an error.
#' 
#' Argument \code{statuses} is a vector containing one or several of the 
#' following:
#' \tabular{rl}{
#'  \code{"CR"} \tab Critically Endangered \cr
#'  \code{"EN"} \tab Endangered \cr
#'  \code{"VU"} \tab Vulnerable \cr
#'  \code{"NT"} \tab Near Threatened \cr
#'  \code{"LC"} \tab Least Concern \cr
#'  \code{"EX"} \tab Extinct \cr
#'  \code{"EW"} \tab Extinct in the Wild \cr
#'  \code{"DD"} \tab Data Deficient \cr
#' }
#' 
#' @param statuses A character vector of the IUCN Conservation Statuses.

#' @return valid A character vector of valid items in \code{statuses}. 
#' 
#' @export
#' 
#' @author Joona Lehtomaki <joona.lehtomaki@@gmail.com>
#' 
#' @examples \dontrun{
#' check_iucn_status("EN")
#' check_iucn_status(c("EN", "VU"))
#' # Gives a warning
#' check_iucn_status(c("EN", "BB"))
#' # Fails
#' check_iucn_status("ENX")
#' }
#' 
check_iucn_status <- function(statuses) {
  valid <- c()
  for (status in statuses) {
    if (!status %in% c("CR", "EN", "VU", "NT", "LC", "EX", "EW", "DD")) {
      warning(status, " is not a valid IUCN status code")
    } else {
      valid <- c(valid, status)
    }
  }
  if (length(valid) == 0) {
    if (length(statuses) > 1) {
      stop("None of the provided codes are valid IUCN status codes")
    } else {
      stop("Provided code is not a valid IUCN status code")
    }
  }
  return(valid)
}

#' Get IUCN protected area categories
#' 
#' @return A dataframe of IUCN protected area categories
#' 
#' @keywords internal
#' 
#' @author Joona Lehtomaki <joona.lehtomaki@@gmail.com>
#'
get_iucn_pa_categories <- function(){
  
  iucn_pa_categories <- data.frame(iucn_cat=c("0", "Ia", "Ib", "II", "III", 
                                              "IV", "V", "VI", "Not Reported",
                                              "Not Applicable"),
                                   desc=c("Unknkown",
                                          "Strict Nature Reserve",
                                          "Wilderness Area",
                                          "National park",
                                          "Natural Monument or Feature",
                                          "Habitat/Species Management Area",
                                          "Protected Landscape/ Seascape",
                                          "Protected area with sustainable use of natural resources",
                                          "",""),
                                   category=0:9)
  return(iucn_pa_categories)
}

#' Coerce a DOPA response object into a dataframe
#' 
#' DOPA responses are often structured as lists of lists. Turn this into a 
#' data structure.
#' 
#' By default, function \code{\link[httr]{content}} parses nulls in JSON into
#' NULLs in R, which causes problems in data.frame coercion. Therefore replace
#' NULLs with NA.
#' 
#' @param x list of lists

#' @return Data frame of response data
#' 
#' @keywords internal
#' 
#' @author Joona Lehtomaki <joona.lehtomaki@@gmail.com>
#'
parse_dopa_response <- function(x) {
  x <- lapply(x, function(x) lapply(x, function(x) ifelse(is.null(x), NA, x)))
  
  # [fixme] - Didn't figure out how to pass stringsAsFactors=FALSE in 
  # rbind.data.frame to do.call
  options(stringsAsFactors=FALSE)
  x <- do.call(rbind.data.frame, x)
  options(stringsAsFactors=TRUE)
  # Get rid of rownames
  row.names(x) <- NULL
  return(x)
}

#' Get ISO 3166-1 country code.
#' 
#' Country identity can be provided as a number or as country name. If the 
#' provided number is a valid ISO 3166-1 country code it is returned directly.
#' 
#' @details Package \code{\link{countrycode}} is used to resolve the value of argument
#' \code{country} which can be either a country name (\code{country.name}) or a 
#' ISO 3166-1 country code (\code{iso3n}).
#' 
#' @param country Character country name or numeric country code.
#' @param full.name Logical should the full name of the country be returned? 
#'   (default: FALSE)

#' @return Numeric count of the species whose range intersects with the country.
#' 
#' @import countrycode
#' 
#' @export
#' 
#' @seealso \code{\link{countrycode}} 
#' 
#' @author Joona Lehtomaki <joona.lehtomaki@@gmail.com>
#' 
#' @examples
#' 
#' # Using country name
#' code <- resolve_country("Finland")
#'   
#' # Using country code (156 is China)
#' code <- resolve_country(156)
#' # Getting the full name
#' country.name <- resolve_country(156, full.name=TRUE)
#' 
#' # Country code can be provided as a character string as well
#' code <- resolve_country("156")
#'
resolve_country <- function(country, full.name=FALSE) {
  
  # Check if country is string that can be coerced to a numeric
  if (suppressWarnings(!is.na(as.numeric(country)))) {
    country <- as.numeric(country)
  }
  
  # If country is provided as a country name, try to convert it to a ISO code
  if (is.character(country)) {
    if (full.name) {
      token <- countrycode(country, "country.name", "country.name")
    } else {
      # Must coerce to numeric, will give integer otherwise
      token <- as.numeric(countrycode(country, "country.name", "iso3n"))
    }
    if (is.na(token)) {
      stop("Country name ", country, " was not matched to an ISO code.")
    }
  } else if (is.numeric(country)) {
    # Check that the ISO code exists
    if (!country %in% codelist$iso3n) {
      stop("Country code ", country, " not a valid ISO 3166-1 code")
    } else {
      if (full.name) {
        token <- countrycode(country, "iso3n", "country.name")
      } else {
        token <- country
      }
    }
  } else {
    stop("country must be either string country name of numeric country code")
  }
  return(token)
}

#' Convert a data frame with a WKT column into SpatialPolygonsDataFrame.
#' 
#' Many queries to the DOPA API return a response object that has the spatial
#' geometry stored as a WKT MULTIPOLYGON data. This function converts the
#' input data frame into a SpatialPolygonsDataFrame.
#' 
#' @details A functional installation of \code{rgeos} is needed.
#' 
#' @param x Data frame containing all the necessary data.
#' @param wkt.col Character string name of the column containing the WKT data.
#' @param p4s Either a character string or an object of class CRS.
#'   (default: "+init=epsg:4326")

#' @return A SpatialPolygonsDataFrame.
#' 
#' @import rgeos sp
#' 
#' @export 
#' 
#' @author Joona Lehtomaki <joona.lehtomaki@@gmail.com>
#'
#'
wktdf2sp <- function(x, wkt.col, p4s="+init=epsg:4326") {
  
  if (!wkt.col %in% names(x)) {
    stop(wkt.col, " not a valid column name")
  }
  
  # Insert new polygons into a list
  spatial_polygons <- list()

  for (i in 1:nrow(x)) {
    # Select all columns for the current row except the WKT column
    x_data <- x[-which(names(x) == wkt.col)][i,]
    # Generate FID based on the current row index
    x_data$FID <- i
    # Use current row index as the polygon ID
    x_poly <- readWKT(x[i,][[wkt.col]], p4s=p4s, id=i)
    
    spatial_polygons[[i]] <- SpatialPolygonsDataFrame(x_poly, data=x_data,
                                                      match.ID="FID")
  }
  # Bind everything together
  spatial_polygons <- do.call("rbind", spatial_polygons)
  return(spatial_polygons)
}
