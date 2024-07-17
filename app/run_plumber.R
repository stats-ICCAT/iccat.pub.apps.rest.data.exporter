library(plumber)
library(jsonlite)
library(future)
library(iccat.dev.data)
library(iccat.pub.data)

load("./data/FC.RData")
load("./data/FC_f.RData")

load("./data/FCG.RData")
load("./data/FCG_f.RData")

load("./data/NC.RData")

load("./data/EF.RData")
load("./data/CA.RData")

load("./data/SZ.RData")

load("./data/CS.RData")

REST = plumb("exporters.R")
REST$run(port = 3838, host = "0.0.0.0")
