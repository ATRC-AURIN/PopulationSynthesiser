#' Load ABS Shapefile
#'
#' This function loads a ABS shapefile from an URL. You may use this
#' [link](https://dbr.abs.gov.au/absmaps/index.html) to help you select
#' an ABS SHP file you want to read.
#'
#' @param url a _URL_ to a shapefile on ABS website.
#' @param crs a numeric value that represents the spatial reference system
#'  of the shapefile. The default is EPGS "4326" representing "WGS84".
#'
#' @return a _sf_ object.
#' @export
#' @examples
#' url <- "https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&1270055001_sa4_2016_aust_shape.zip&1270.0.55.001&Data%20Cubes&C65BC89E549D1CA3CA257FED0013E074&0&July%202016&12.07.2016&Latest"
#' load_abs_shp(url)
load_abs_shp <- function(url, crs = 4326) {
  extracted_files <- download_file(url) %>%
    unzip_file()
  shp_file <- list.files(extracted_files, pattern = ".shp$", full.names = TRUE)
  if (length(shp_file) != 1L) {
    stop("Either no or more than one .shp files were found in the given path.")
  }
  shp <- sf::st_read(shp_file) %>%
    sf::st_transform(crs = crs)
}

download_file <- function(url) {
  file_to_read <- tempfile()
  download.file(
    url,
    file_to_read,
    mode = ifelse(Sys.info()["sysname"] == "Windows", "wb", "w")
  )
  message("Saved the downloaded file to: ", file_to_read)
  file_to_read
}

unzip_file <- function(file_to_read) {
  temp_dir <- fs::path(tempdir(), basename(tempfile()))
  message("Extracting the file to: ", temp_dir)
  zip_info <- unzip(file_to_read, exdir = temp_dir)
  temp_dir
}
