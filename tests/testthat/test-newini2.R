test_that("new_ini2 works", {

  mod <- exmodel(ID = 1)
  dat <- get_data(mod)

  argofv <- c(
    preprocess.ofv.fix(x = mod),
    preprocess.ofv.id(x = mod, iddata = dat)
    )

  argopt <- preprocess.optim(x = mod, method = "L-BFGS-B", control = list(), force_initial_eta = NULL,
                             quantile_bound = .4) # !!

  ini2 <- new_ini2(arg.ofv = argofv, arg.optim = argopt, run = 1)

  ini3 <- new_ini3(arg.ofv = argofv, upper = argopt$upper, nreset = 1, select_eta = argopt$select_eta)

  expect_equal(ini2, ini3)
  expect_type(ini3, "double")
  expect_true(all(ini3 > argopt$lower))
  expect_true(all(ini3 < argopt$upper))

})
