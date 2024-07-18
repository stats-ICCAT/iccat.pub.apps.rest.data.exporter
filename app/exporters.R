future::plan("multisession")

options(future.globals.maxSize = 16 * 1024 * 1024 * 1024) # 16 GB

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @parser json
#* @post /ST01
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "logger"), globals = c("req", "res", "meta", "filters", "FC", "FC_f", "FCG", "FCG_f"), {
    body = req$body

    meta    = body$meta
    filters = body$filters
    
    filename = paste0("ST01-T1FC_", filters$reporting_flag, "_", filters$year_from, "-", filters$year_to, ".xlsx")
    filepath = file.path(tempdir(), filename)

    iccat.dev.data::ST01.export(FC, FC_f, FCG, FCG_f,
                                statistical_correspondent = meta$statistical_correspondent,
                                version_reported = meta$version_reported,
                                content_type     = meta$content_type,
                                      
                                reporting_flag   = filters$reporting_flag,
                                year_from        = filters$year_from,
                                year_to          = filters$year_to,
                                
                                destination_file = filepath)

    res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    on.exit(unlink(filepath))
      
    return(
      readBin(filepath, "raw", n = file.info(filepath)$size)
    )
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @parser json
#* @post /ST02
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data"), globals = c("req", "res", "meta", "filters", "NC"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    filename = paste0("ST02-T1BC_", filters$reporting_flag, "_", filters$year_from, "-", filters$year_to, ".xlsx")
    filepath = file.path(tempdir(), filename)
    
    iccat.dev.data::ST02.export(NC,
                                statistical_correspondent = meta$statistical_correspondent,
                                version_reported = meta$version_reported,
                                content_type     = meta$content_type,
                                
                                reporting_flag   = filters$reporting_flag,
                                year_from        = filters$year_from,
                                year_to          = filters$year_to,
                                
                                destination_file = filepath)
    
    #res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    on.exit(unlink(filepath))
    
    return(
      readBin(filepath, "raw", n = file.info(filepath)$size)
    )
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ST03
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data"), globals = c("req", "res", "meta", "filters", "EF", "CA"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    filename = paste0("ST03-T2CE_", filters$reporting_flag, "_", filters$year_from, "-", filters$year_to, "_", filters$data_source, ".xlsx")
    filepath = file.path(tempdir(), filename)
    
    iccat.dev.data::ST03.export(EF, CA,
                                statistical_correspondent = meta$statistical_correspondent,
                                version_reported = meta$version_reported,
                                content_type     = meta$content_type,
                                data_coverage    = meta$data_coverage,
                                
                                reporting_flag   = filters$reporting_flag,
                                year_from        = filters$year_from,
                                year_to          = filters$year_to,
                                data_source      = filters$data_source,
                                
                                destination_file = filepath)
    
    res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    on.exit(unlink(filepath))
    
    return(
      readBin(filepath, "raw", n = file.info(filepath)$size)
    )
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ST04
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data"), globals = c("req", "res", "meta", "filters", "SZ"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    filename = paste0("ST04-T2SZ_", filters$reporting_flag, "_", filters$year_from, "-", filters$year_to, "_",
                      filters$species, "_", #input$sz_product_type, "_",
                      filters$sampling_location, "_", filters$sampling_unit, "_",
                      ifelse(!is.na(filters$raised) & filters$raised == "Yes", "RAISED", "NOT_RAISED"), "_",
                      filters$frequency_type, "_", filters$class_limit, "_",
                      filters$size_interval, ".xlsx")
    filepath = file.path(tempdir(), filename)
    
    iccat.dev.data::ST04.export(SZ,
                                statistical_correspondent = meta$statistical_correspondent,
                                version_reported = meta$version_reported,
                                content_type     = meta$content_type,
                                
                                reporting_flag   = filters$reporting_flag,
                                year_from        = filters$year_from,
                                year_to          = filters$year_to,
                                
                                species           = filters$species, 
                                sampling_location = filters$sampling_location,
                                sampling_unit     = filters$sampling_unit,
                                frequency_type    = filters$frequency_type,
                                raised            = filters$raised,
                                class_limit       = filters$class_limit,
                                size_interval     = filters$size_interval,
                                
                                destination_file = filepath)
    
    res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    on.exit(unlink(filepath))
    
    return(
      readBin(filepath, "raw", n = file.info(filepath)$size)
    )
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ST05
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data"), globals = c("req", "res", "meta", "filters", "CS"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    filename = paste0("ST05-T2CS_", filters$reporting_flag, "_", filters$year_from, "-", filters$year_to, "_",
                      filters$species, "_",  filters$frequency_type, "_", filters$class_limit, "_",
                      filters$size_interval, ".xlsx")
    
    filepath = file.path(tempdir(), filename)
    
    iccat.dev.data::ST05.export(CS,
                                statistical_correspondent = meta$statistical_correspondent,
                                version_reported = meta$version_reported,
                                content_type     = meta$content_type,
                                
                                reporting_flag   = filters$reporting_flag,
                                year_from        = filters$year_from,
                                year_to          = filters$year_to,
                                
                                species           = filters$species, 
                                frequency_type    = filters$frequency_type,
                                class_limit       = filters$class_limit,
                                size_interval     = filters$size_interval,
                                
                                destination_file = filepath)
    
    res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    on.exit(unlink(filepath))
    
    return(
      readBin(filepath, "raw", n = file.info(filepath)$size)
    )
  })
}
