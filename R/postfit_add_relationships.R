#' Add relationship fields to a Census synthetic population
#'
#' @description
#' Add `partner_id`, `father_id`, and `mother_id` fields to the synthetic population
#' based on `rlhp` (relationship in household) and `sexp` (sex of person) fields.
#'
#' @param x a data.table containing records of a Census synthetic population.
#' @export
#'
#' @return a data.table
postfit_add_relationships <- function(x) {
  cli_alert_info("Checking inputs")
  x <- checkmate::assert_data_frame(x) %>% as.data.table()
  checkmate::assert_names(names(x), must.include = c("rlhp", "sexp"))

  rlhp_categories <- c(
    "lone parent", "husband, wife or partner",
    "dependent student", "child under 15",
    "non-dependent child"
  )

  checkmate::assert_names(tolower(unique(x[["rlhp"]])), must.include = rlhp_categories)

  cli_alert_info("Creating relationship id fields: {.var partner_id}, {.var father_id}, {.var mother_id}")
  # create place holder variables for relationship columns
  x[, `:=`(
    partner_id = NA_integer_,
    father_id = NA_integer_,
    mother_id = NA_integer_
  )]

  # join all members with other members (including self) in the same family household
  cli_alert_info("Joining all members with other members (including self) in the same family household")
  x_new <-
    x[x[, .(abshid, absfid, abspid, sexp, rlhp)],
      on = .(abshid, absfid), allow.cartesian = TRUE
    ]

  setorder(x_new, abshid, abspid)

  # add relationships depedning on rlhp (relationship in household) to other members
  # ie. if an agent is a student and the other agent is a parent and is female then
  # the other agent must be the mother to the current agent.
  # NOTE: do not remove self matches (pid == i.pid) this will make the total number of rows
  #       of the result less than the total number of rows of the output. Something
  #       is definitely wrong but I need more time to investigate what is the reason
  #       behind that.
  cli_alert_info("Adding relationships")
  x_new <-
    x_new %>%
    # add mother
    .[
      tolower(rlhp) %in% c("dependent student", "child under 15", "non-dependent child") &
        tolower(i.rlhp) %in% c("lone parent", "husband, wife or partner") &
        tolower(i.sexp) == "female",
      `:=`(mother_id = i.abspid)
    ] %>%
    # add father
    .[
      tolower(rlhp) %in% c("dependent student", "child under 15", "non-dependent child") &
        tolower(i.rlhp) %in% c("lone parent", "husband, wife or partner") &
        tolower(i.sexp) == "male",
      `:=`(father_id = i.abspid)
    ] %>%
    # add partner
    .[
      tolower(rlhp) == "husband, wife or partner" &
        tolower(i.rlhp) == "husband, wife or partner" &
        abspid != i.abspid,
      `:=`(partner_id = i.abspid)
    ]

  setkey(x_new, abspid)

  # group relationships
  cols <- names(x_new)

  # only keep one record per person
  cli_alert_info("Cleaning up")
  x_new <-
    x_new[,
      # the warning here is none-fatal
      `:=`(
        partner_id = na.omit(partner_id),
        father_id = first(na.omit(father_id)),
        mother_id = first(na.omit(mother_id))
      ),
      by = .(abspid)
    ] %>%
    # remove the na.omit attributes which can cause all.equal.data.table with check.attributes = T
    # to return an error.
    .[, (cols) := lapply(.SD, function(x) {
      if (is.factor(x)) {
        as.character(x)
      } else {
        x
      }
    }), .SDcol = cols] %>%
    .[, (cols) := lapply(.SD, function(x) {
      attributes(x) <- NULL
      x
    }), .SDcol = cols] %>%
    # drop tmp conditional columns
    .[, c("i.abspid", "i.sexp", "i.rlhp") := NULL] %>%
    # only extract unique records
    unique(., by = c("abspid"))

  cli_alert_success("Done")

  stopifnot(nrow(x) == nrow(x_new))

  x_new
}
