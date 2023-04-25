library(data.table)
library(magrittr)
library(here)

inputs_dir <- here("atrc_data", "inputs")

ref_sample <- fread(fs::path(inputs_dir, "reference_sample.csv"))
person_controls <- lapply(list.files(path = inputs_dir, pattern = "^persons.*csv$", full.names = TRUE), fread)
household_controls <- lapply(list.files(path = inputs_dir, pattern = "^households.*csv$", full.names = TRUE), fread)
geo_hierarchy <- data.table(
    REGION = c(1, 1, 2, 2),
    ZONE = c(1, 2, 3, 4)
)

# randomly assign half of the households to each REGION ID
region_2_households <- sample(unique(ref_sample$hhid), length(unique(ref_sample$hhid)) / 2)
geo_ref_sample <- ref_sample %>%
    data.table::copy() %>%
    .[, REGION := 1] %>%
    .[hhid %in% region_1_households, REGION := 2]

# clone N zones copies of each control table at each level and assign
# a ZONE ID from each zone in `zones`.
clone_to_zones <- function(df, zones) {
    checkmate::assert_integerish(zones, min.len = 1)
    data.table::rbindlist(
        lapply(
            zones,
            function(zone) {
                data.table::copy(df)[, ZONE := zone]
            }
        )
    )
}

geo_person_controls <- lapply(
    person_controls,
    function(x) {
        clone_to_zones(x, zones = 1:4)
    }
)

geo_household_controls <- lapply(
    household_controls,
    function(x) {
        clone_to_zones(x, zones = 1:4)
    }
)

# export to the inputs dir
fwrite(geo_ref_sample, fs::path(inputs_dir, "geo_reference_sample.csv"))
lapply(seq_along(geo_person_controls), function(index) {
    fwrite(
        geo_person_controls[[index]],
        fs::path(inputs_dir, paste0("geo-persons-control", index, ".csv"))
    )
})
lapply(seq_along(geo_household_controls), function(index) {
    fwrite(
        geo_household_controls[[index]],
        fs::path(inputs_dir, paste0("geo-households-control", index, ".csv"))
    )
})
fwrite(geo_hierarchy, fs::path(inputs_dir, "geo-hierarchy.csv"))
