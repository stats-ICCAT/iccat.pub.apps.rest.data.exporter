library(iccat.dev.data)

FC   = ST01A.load_data_vessels()
FC_f = ST01A.load_data_fisheries()

save("FC",   file = "./app/data/FC.RData", compress = "gzip")
save("FC_f", file = "./app/data/FC_f.RData", compress = "gzip")

FCG   = ST01B.load_data_vessels()
FCG_f = ST01B.load_data_fisheries()

save("FCG",   file = "./app/data/FCG.RData", compress = "gzip")
save("FCG_f", file = "./app/data/FCG_f.RData", compress = "gzip")

NC = ST02.load_data()
save("NC", file = "./app/data/NC.RData", compress = "gzip")

EF = ST03.load_data_EF()
save("EF", file = "./app/data/EF.RData", compress = "gzip")

CA = ST03.load_data_CA()
save("CA", file = "./app/data/CA.RData", compress = "gzip")

SZ = ST04.load_data("siz")
save("SZ", file = "./appshiny/data/SZ.RData", compress = "gzip")

CS = ST05.load_data("cas")
save("CS", file = "./app/data/CS.RData", compress = "gzip")

META = list(LAST_UPDATE = "2024-07-12")
save("META", file = "./app/data/META.RData", compress = "gzip")
