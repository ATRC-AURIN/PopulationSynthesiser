test_that("retotal_control()", {
  count <- 1:4
  ctrl <- data.table(x = 1:4, N = count)
  total <- 20
  count_col <- "N"
  new_ctrl <- retotal_control(ctrl, total, count_col)
  expect_equal(
    object = sum(new_ctrl[[count_col]]),
    expected = total
  )
  expect_equal(
    object = sum(ctrl[[count_col]]),
    expected = sum(count)
  )
})
