est <- mapbayest(exmodel())
dat <- get_data(est)
arg.ofv <- c(est$arg.ofv.fix, est$arg.ofv.id[[1]])

test_that("f works", {

  # tweak because of the "etasrc = data"
  etatest <- eta(runif(3))
  arg.ofv$idvaliddata_eta <- merge_validdata_eta(arg.ofv$idvaliddata, etatest)
  dat_eta <- merge_datadf_etavec(dat, etatest/2)

  #on validated data
  expect_length(f(qmod = arg.ofv$qmod, data = arg.ofv$idvaliddata_eta), 4)

  #on non-validated data
  expect_length(f(qmod = arg.ofv$qmod, data = dat_eta), 4)
  expect_equal(
    f(qmod = arg.ofv$qmod, data = arg.ofv$idvaliddata_eta),
    f(qmod = arg.ofv$qmod, data = dat_eta)
  )

  #mdv != 0 are dealed ok
  validddatabis <- arg.ofv$idvaliddata_eta
  validddatabis[5,"mdv"] <- 1
  expect_length(f(qmod = arg.ofv$qmod, data = validddatabis), 4-1)
  expect_equal(
    f(qmod = arg.ofv$qmod, data = arg.ofv$idvaliddata_eta)[1:3],
    f(qmod = arg.ofv$qmod, data = validddatabis)
  )
})

test_that("h matrix computation works", {
  expectmat <- matrix(c(400, 0, 200, 0, 1, 0, 1, 0, 0, 40, 0, 20, 0, 1, 0, 1), ncol = 4, nrow = 4)

  expect_equal(h(pred = c(400, 40, 200, 20), cmt = c(2, 3, 2, 3), all_cmt = c(2, 3)), expectmat)

  expectmat[1,1] <- 1
  expect_equal(h(pred = c(0, 40, 200, 20), cmt = c(2, 3, 2, 3), all_cmt = c(2, 3)), expectmat)

  # e.g. time = 0 with oral drug
  est <- exmodel(add_exdata = F) %>%
    adm_rows(amt = 100) %>%
    obs_rows(time = c(0, 10), DV = c(.1, 1)) %>%
    mapbayest(output = "df")

  expect_equal(est$IPRED, c(0, 0, 0.9244), tolerance = 0.001)

})

test_that("compute basic ofv", {
  expecteta <- c(
    ETA1 = 0.4050570108131819058,
    ETA2 = 0.07285029212110255559,
    ETA3 = -0.07495339444174362042
    )

  expectofv <- 22.29351276398179493

  of_value1 <- compute_ofv(
    eta = expecteta,

    qmod = arg.ofv$qmod, idvaliddata = arg.ofv$idvaliddata,
    sigma = arg.ofv$sigma, log_transformation = arg.ofv$log_transformation,
    idDV = arg.ofv$idDV, idcmt = arg.ofv$idcmt,
    omega_inv = arg.ofv$omega_inv, all_cmt = arg.ofv$all_cmt)

  expect_equal(of_value1, expectofv)

  of_value2 <- compute_ofv(
    eta = as.list(expecteta),

    qmod = arg.ofv$qmod, idvaliddata = arg.ofv$idvaliddata,
    sigma = arg.ofv$sigma, log_transformation = arg.ofv$log_transformation,
    idDV = arg.ofv$idDV, idcmt = arg.ofv$idcmt,
    omega_inv = arg.ofv$omega_inv, all_cmt = arg.ofv$all_cmt)

  expect_equal(of_value2, expectofv)

  do_ofv1 <- do_compute_ofv(eta = expecteta, argofv = arg.ofv)
  expect_equal(do_ofv1, expectofv)

  do_ofv2 <- do_compute_ofv(eta = expecteta, argofv = arg.ofv)
  expect_equal(do_ofv2, expectofv)

})

test_that("small negative values are fixed", {
  #see #140

  code408 <- "$PROB Reference model

$PARAM @annotated
TVCL   : 4.00 : Clearance (L/h)
TVVC   : 70.0 : Central volume of distribution (L)
TVKA   : 1.00 : Absorption rate (h-1)

ETA1 : 0 : CL
ETA2 : 0 : VC
ETA3 : 0 : KA

$OMEGA
0.2 // CL
0.2 // VC
0.2 // KA

$SIGMA
0 // err prop
.05 //  err log additive


$CMT @annotated
DEPOT   : Depot () []
CENTRAL : Central () [ADM, OBS]

$TABLE
double DV = (CENTRAL / VC) * exp(EPS(2)) ;

$MAIN
double CL  = TVCL  * exp(ETA(1) + ETA1 ) ;
double VC  = TVVC  * exp(ETA(2) + ETA2 ) ;
double KA  = TVKA  * exp(ETA(3) + ETA3 ) ;

double K20 = CL / VC ;

$ODE
dxdt_DEPOT   = - KA * DEPOT ;
dxdt_CENTRAL = - K20 * CENTRAL + KA * DEPOT ;

$CAPTURE DV"


  mod408 <- mcode("mod408", code408, quiet = TRUE)
  dat408 <- data.frame(
    ID = 1405,
    time = c(0, 1.2, 4.6, 8.8, 26.5),
    evid = c(1, 0, 0, 0, 0),
    amt = c(30000, 0,0,0,0),
    cmt = 2,
    rate = c(30000, 0,0,0,0),
    mdv = c(1, 0, 0, 0, 0),
    DV =  c(NA, 1703, 669, 216, 0.806)
  )

  argofv <- c(
    preprocess.ofv.fix(mod408, dat408),
    preprocess.ofv.id(mod408, dat408)
  )
  testparam <- c(ETA1 = 1.6, ETA2 = -1.6, ETA3 = 0)
  pred <- mapbayr:::f(argofv$qmod, data = merge_datadf_etavec(dat408, testparam))
  expect_true(any(pred < 0))
  expect_true(any(is.nan(suppressWarnings(log(pred)))))
  expect_false(is.nan(do_compute_ofv(eta = testparam, argofv)))
})

test_that("dose-related parameters > II", {

  code141 <- "
$PARAM ETA1 = 0, ETA2 = 0
$CMT GUT CENT
$OMEGA .5 .5
$SIGMA .04 0
$MAIN
double KA = 1 ;
double CL = 1 ;
double V = 30 ;
double ALAG1 = 5.0 * exp(ETA(1) + ETA1) ;
double D1 = 5.0 * exp(ETA(2) + ETA2) ;
ALAG_GUT = ALAG1 ;
D_GUT = D1 ;
$PKMODEL ncmt = 1, depot = TRUE
$ERROR
double DV = CENT/V *(1 + EPS(1)) ;
$CAPTURE DV ALAG1 D1
"
  mod141 <- mcode("mod141",code141, quiet = TRUE)

  dat141 <- mod141 %>%
    adm_rows(amt = 1000, cmt = 1, ss = 1, ii = 24) %>%
    obs_rows(time = c(1,4), DV = c(26, 52), cmt = 2) %>%
    get_data()

  argofv141 <- c(
    preprocess.ofv.fix(mod141, dat141),
    preprocess.ofv.id(mod141, dat141)
  )

  ofv1 <- do_compute_ofv(eta = c(ETA1 = -2, ETA2 = -2), argofv141)
  expect_true(all(ofv1 > 20, ofv1 < 30))

  ofv2 <- do_compute_ofv(eta = c(ETA1 = 2, ETA2 = 2), argofv141)
  expect_equal(ofv2, 1E10)
})

test_that("lambda argument works", {
  par <- eta(runif(3))
  ofv_ref <- do_compute_ofv(par, argofv = arg.ofv)

  arg.ofv2 <- arg.ofv
  arg.ofv2$lambda <- NULL

  expect_lt(do_compute_ofv(par, argofv = arg.ofv2, lambda = 0.01), ofv_ref)
  expect_gt(do_compute_ofv(par, argofv = arg.ofv2, lambda = 10), ofv_ref)
})

test_that("merge_validdata_eta() works", {
  val <- mrgsolve::valid_data_set(exdata(1), exmodel(1))
  eta <- eta(runif(3))

  merged <- merge_validdata_eta(val, eta)

  expect_true(mrgsolve:::is.valid_data_set(merged))
  expect_equal(ncol(merged), ncol(val)+length(eta))
})
