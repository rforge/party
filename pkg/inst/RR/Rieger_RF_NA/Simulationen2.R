##############################################################################
#                                                                            #
#                           R-Code zur HiWi-Stelle                           #
#                                                                            #
#                                  Teil 4b:                                  #
#            Die Simulationen zu den zusätzlichen NA-Mechanismen             #
#                                                                            #
##############################################################################

# source("funktionenZuMV2class.R") bzw. source("funktionenZuMV2regres.R")
# vorher laden!

#library("party", lib.loc = "~/lib/oldparty/")
#library("mvtnorm", lib.loc = "~/lib/oldmvtnorm/")
#library("impute", lib.loc = "~/lib/impute/")       # hier Unterschied!

source("funktionenZumDGP.R")
source("funktionenZuRF2.R")            # hier Unterschied!

#****************************************************************************#

#library("party", lib.loc = "~/lib/oldparty/")
#library("impute", lib.loc = "~/lib/impute/")       # hier Unterschied!
set.seed(856329)

sigma <- list()

sigma[[1]] <- matrix(data = c(  1, 0.9, 0.9, 0.9, 0.9,
                              0.9,   1, 0.9, 0.9, 0.9,
                              0.9, 0.9,   1, 0.9, 0.9,
                              0.9, 0.9, 0.9,   1, 0.9,
                              0.9, 0.9, 0.9, 0.9,   1), byrow = TRUE, ncol = 5)

sigma[[2]] <- matrix(data = c(  1, 0.9, 0.9,   0,   0,
                              0.9,   1, 0.9,   0,   0,
                              0.9, 0.9,   1,   0,   0,
                                0,   0,   0,   1, 0.9,
                                0,   0,   0, 0.9,   1), byrow = TRUE, ncol = 5)

sigma[[3]] <- matrix(data = c(  1, 0.1, 0.1, 0.1, 0.1,
                              0.1,   1, 0.1, 0.1, 0.1,
                              0.1, 0.1,   1, 0.1, 0.1,
                              0.1, 0.1, 0.1,   1, 0.1,
                              0.1, 0.1, 0.1, 0.1,   1), byrow = TRUE, ncol = 5)

delete <- vector(mode = "list", length = 2)
delete[[1]] <- deleteLOG               # hier Unterschied!
delete[[2]] <- deleteDEPy              # hier Unterschied!

imp <- c(TRUE, FALSE)

foo <- function(RF = RF1, dgp = dgp1, ntest = 10000, dgpfun.niter = 500, ...) {
    res <- NULL
    for (si in 1:length(sigma)) {
        # fuer jedes Korrelations-Design:
        #--------------------------------
        cat(" sigma =", si, "\n Es folgt der Test-Datensatz (kein RF). \n")

        # Test-Datensatz generieren:
        testds <- dgp(niter=1, n=ntest, sigma[[si]], ...)

        # Goldstandard:
        cat(" sigma =", si, "\n Es folgt der Goldstandard. \n")
        gold <- RF(test = testds, nIter = dgpfun.niter, sigma = sigma[[si]], ...)
        res <- rbind(res, cbind(gold, 0, si, TRUE, 0, FALSE, FALSE, FALSE))

        for (di in 1:length(delete)) {
            # fuer jeden NA-Mechanismus:
            #---------------------------

            # reduzierter Fall "-NA":
            cat(" sigma =", si, ";", "delete =", di, "\n Es folgt der reduzierte Datensatz. \n")
            worst <- RF(delete[[di]], test = testds, nIter = dgpfun.niter, sigma = sigma[[si]],
                na.omit = TRUE, lernMV = TRUE, ...)
            res <- rbind(res, cbind(worst, 0, si, TRUE, di, TRUE, FALSE, FALSE))

            for (impute in imp) {
                # fuer vorherige Imputation und Surrogat-Splits:
                #-----------------------------------------------
                cat(" sigma =", si, ";", "delete =", di, ";", "impute =", impute,
                    "\n Es folgen 3x",  dgpfun.niter, "Datensaetze mit NA. \n")

                # fehlende Werte in den Lern-Datensaetzen:
                cat("lernMV: \n")
                tmp <- RF(delete[[di]], test = testds, nIter = dgpfun.niter, sigma = sigma[[si]],
                    lernMV = TRUE, testMV = FALSE, imp = impute, ...)
                res <- rbind(res, cbind(tmp, 0, si, FALSE, di, TRUE, FALSE, impute))

                # fehlende Werte im Test-Datensatz:
                cat("testMV: \n")
                tmp <- RF(delete[[di]], test = testds, nIter = dgpfun.niter, sigma = sigma[[si]],
                    lernMV = FALSE, testMV = TRUE, imp = impute, ...)
                res <- rbind(res, cbind(tmp, 0, si, FALSE, di, FALSE, TRUE, impute))

                # fehlende Werte in den Lern-Datensaetzen und im Test-Datensatz:
                cat("lerntestMV: \n")
                tmp <- RF(delete[[di]], test = testds, nIter = dgpfun.niter, sigma = sigma[[si]],
                    lernMV = TRUE, testMV = TRUE, imp = impute, ...)
                res <- rbind(res, cbind(tmp, 0, si, FALSE, di, TRUE, TRUE, impute))
            }
        }
    }
    colnames(res) <- c("risk", "dgp", "sigma", "bench", "MV", "lernMV", "testMV", "imput")
    res
}

##############################################################################