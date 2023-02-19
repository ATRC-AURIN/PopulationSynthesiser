# census sample file's id fields.
# - abshid: household id
# - absfid: family id
# - abspid: person id
.csf_id_fields <- list(hid = "abshid", fid = "absfid", pid = "abspid")

# fitting algoritms available in the mlfit package.
.fitting_algorithms <-
  formals(mlfit::ml_fit)$algorithm %>%
  eval()

.supported_zone_fields <- paste0("sa", 1:4)

.supported_census_years <- c("2011", "2016")

.microdata_zone_fields <- c("areaenum", "regucp")
