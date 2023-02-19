make_new_colname <- function(.prefix) {
  checkmate::assert_string(.prefix)
  function(x) {
    checkmate::assert_string(x)
    checkmate::assert_names(x, type = "strict")
    paste(.prefix, x, sep = "_")
  }
}
