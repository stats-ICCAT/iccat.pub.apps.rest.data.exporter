future::plan("multisession")

options(future.globals.maxSize = 16 * 1024 * 1024 * 1024) # 16 GB

api_error = function(message, status) {
  err = structure(
    list(message = message, status = status),
    class = c("api_error", "error", "condition")
  )
  
  signalCondition(err)
}

missing_parameter = function(message) {
  api_error(message, 400)
}

check_common_missing_filters = function(filters) {
  #print(filters)
  #print(filters$reporting_flag)
  
  if(!"reporting_flag" %in% names(filters) | is.null(filters$reporting_flag)) missing_parameter("The 'Reporting flag' filter is mandatory")
  if(!"year_from"      %in% names(filters) | is.null(filters$year_from))      missing_parameter("The 'Year (from)' filter is mandatory")
  if(!"year_to"        %in% names(filters) | is.null(filters$year_to))        missing_parameter("The 'Year (to)' filter is mandatory")
}

error_handler = function(req, res, err) {
  if (!inherits(err, "api_error")) {
    res$status = 500
    res$body = jsonlite::toJSON(auto_unbox = TRUE, list(
      status = 500,
      message = "Internal server error."
    ))
    res$setHeader("content-type", "application/json")  # Make this JSON
    
    # Print the internal error so we can see it from the server side. A more
    # robust implementation would use proper logging.
    print(err)
  } else {
    # We know that the message is intended to be user-facing.
    res$status = err$status
    res$body = jsonlite::toJSON(auto_unbox = TRUE, list(
      status = err$status,
      message = err$message
    ))
    
    res$setHeader("content-type", "application/json")  # Make this JSON
  }
  
  res
}

#* @plumber
function(pr) {
  # Use custom error handler
  pr %>% pr_set_error(error_handler)
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @parser json
#* @post /ST01
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang", "plumber"), globals = c("req", "res", "meta", "filters", "FC", "FC_f", "FCG", "FCG_f", "check_common_missing_filters"), {
    body = req$body

    meta    = body$meta
    filters = body$filters
    
    check_common_missing_filters(filters)
    
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

    # If we use "as_attachment" then the correct filename is returned to the caller,
    # but if we then attempt to remove the file with "on.exit(unlink(filepath))" the call never completes
    # This means that each and every download will create a stale temporary file...
    
    plumber::as_attachment(readBin(filepath, "raw", n = file.info(filepath)$size), filename) 
    
    # Before:
    
    #res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    #on.exit(unlink(filepath))
      
    #return(
    #  readBin(filepath, "raw", n = file.info(filepath)$size)
    #)
  })
}

#* @parser json
#* @get /ST01/<reporting_flag>
function(req, res, reporting_flag) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang"), globals = c("req", "res", "FC", "reporting_flag"), {
     return(
       FC[FlagCode == reporting_flag, .(NUM_RECORDS = .N), keyby = .(REPORTING_FLAG = FlagCode, YEAR = YearC)][order(YEAR)]
     )                      
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @parser json
#* @post /ST02
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang", "plumber"), globals = c("req", "res", "meta", "filters", "NC", "check_common_missing_filters"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    check_common_missing_filters(filters)
    
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
    
    
    # If we use "as_attachment" then the correct filename is returned to the caller,
    # but if we then attempt to remove the file with "on.exit(unlink(filepath))" the call never completes
    # This means that each and every download will create a stale temporary file...
    
    plumber::as_attachment(readBin(filepath, "raw", n = file.info(filepath)$size), filename)  
    
    # Before:
    
    #res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    #on.exit(unlink(filepath))
    
    #return(
    #  readBin(filepath, "raw", n = file.info(filepath)$size)
    #)
  })
}

#* @parser json
#* @get /ST02/<reporting_flag>
function(req, res, reporting_flag) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang"), globals = c("req", "res", "NC", "reporting_flag"), {
    return(
      NC[Year >= 1950 & FlagCode == reporting_flag, 
          .(NUM_RECORDS = .N, TOTAL_CATCHES_T = round(sum(CatchKg, na.rm = TRUE) / 1000.0, 2)), 
           keyby = .(REPORTING_FLAG = FlagCode, YEAR = Year)][order(YEAR)]
    )                
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ST03
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang", "plumber"), globals = c("req", "res", "meta", "filters", "EF", "CA", "check_common_missing_filters"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    check_common_missing_filters(filters)
    
    if(!"data_source" %in% names(filters) | is.null(filters$data_source)) missing_parameter("The 'Data source' filter is mandatory")
    
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
    
    
    # If we use "as_attachment" then the correct filename is returned to the caller,
    # but if we then attempt to remove the file with "on.exit(unlink(filepath))" the call never completes
    # This means that each and every download will create a stale temporary file...
    
    plumber::as_attachment(readBin(filepath, "raw", n = file.info(filepath)$size), filename)  
    
    # Before:
    
    #res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    #on.exit(unlink(filepath))
    
    #return(
    #  readBin(filepath, "raw", n = file.info(filepath)$size)
    #)
  })
}

#* @parser json
#* @get /ST03/<reporting_flag>
function(req, res, reporting_flag) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang"), globals = c("req", "res", "EF", "CA", "reporting_flag"), {
    efforts  = EF[FlagCode == reporting_flag]
    catches = CA[FlagCode == reporting_flag]
    
    efforts = efforts[, .(NUM_EF_RECORDS = .N), keyby = .(REPORTING_FLAG = FlagCode, YEAR = Year, DATA_SOURCE_CODE = DataSourceCode)]
    catches = catches[, .(NUM_CA_RECORDS = .N, TOTAL_CATCHES_T = round(sum(CatchStdCE, na.rm = TRUE) / 1000.0, 2)), keyby = .(REPORTING_FLAG = FlagCode, YEAR = Year, DATA_SOURCE_CODE = DataSourceCode)]

    CE = merge(efforts, catches,
               by = c("REPORTING_FLAG", "YEAR", "DATA_SOURCE_CODE"),
               all.x = TRUE)

    return(          
      CE[order(YEAR, DATA_SOURCE_CODE)]
    )                      
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ST04
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang", "plumber"), globals = c("req", "res", "meta", "filters", "SZ", "check_common_missing_filters"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    check_common_missing_filters(filters)
    
    if(!"species" %in% names(filters)           | is.null(filters$species))           missing_parameter("The 'Species' filter is mandatory")
    if(!"sampling_location" %in% names(filters) | is.null(filters$sampling_location)) missing_parameter("The 'Sampling location' filter is mandatory")
    if(!"sampling_unit" %in% names(filters)     | is.null(filters$sampling_unit))     missing_parameter("The 'Sampling unit' filter is mandatory")
    if(!"raised" %in% names(filters)            | is.null(filters$raised))            missing_parameter("The 'Raised' filter is mandatory")
    if(!"frequency_type" %in% names(filters)    | is.null(filters$frequency_type))    missing_parameter("The 'Frequency type' filter is mandatory")
    if(!"class_limit" %in% names(filters)       | is.null(filters$class_limit))       missing_parameter("The 'Class limit' filter is mandatory")
    if(!"size_interval" %in% names(filters)     | is.null(filters$size_interval))     missing_parameter("The 'Size interval' filter is mandatory")
    
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
    
    
    # If we use "as_attachment" then the correct filename is returned to the caller,
    # but if we then attempt to remove the file with "on.exit(unlink(filepath))" the call never completes
    # This means that each and every download will create a stale temporary file...
    
    plumber::as_attachment(readBin(filepath, "raw", n = file.info(filepath)$size), filename)  
    
    # Before:
    
    #res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    #on.exit(unlink(filepath))
    
    #return(
    #  readBin(filepath, "raw", n = file.info(filepath)$size)
    #)
  })
}

#* @parser json
#* @get /ST04/<reporting_flag>
function(req, res, reporting_flag) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang"), globals = c("req", "res", "SZ", "reporting_flag"), {
    return(
      SZ[Year >= 1950 & FlagCode == reporting_flag, 
         .(NUM_SAMPLES = sum(Nr, na.rm = TRUE)), 
         keyby = .(REPORTING_FLAG = FlagCode, YEAR = Year, 
                   SPECIES = SpeciesCode,
                   SAMPLING_LOCATION = SampLocationCode,
                   SAMPLING_UNIT = SampUnitTypeCode,
                   FREQUENCY_TYPE = FreqTypeCode,
                   RAISED = Raised,
                   CLASS_LIMIT = SzClassLimitCode,
                   SIZE_INTERVAL = SzInterval)][order(YEAR, SPECIES, SAMPLING_LOCATION, SAMPLING_UNIT, FREQUENCY_TYPE, RAISED, CLASS_LIMIT, SIZE_INTERVAL)]
    )                      
  })
}

#* @serializer contentType list(type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ST05
function(req, res) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang", "plumber"), globals = c("req", "res", "meta", "filters", "CS", "check_common_missing_filters"), {
    body = req$body
    
    meta    = body$meta
    filters = body$filters
    
    check_common_missing_filters(filters)
    
    if(!"species" %in% names(filters)        |is.null(filters$species))        missing_parameter("The 'Species' filter is mandatory")
    if(!"frequency_type" %in% names(filters) |is.null(filters$frequency_type)) missing_parameter("The 'Frequency type' filter is mandatory")
    if(!"class_limit" %in% names(filters)    |is.null(filters$class_limit))    missing_parameter("The 'Class limit' filter is mandatory")
    if(!"size_interval" %in% names(filters)  |is.null(filters$size_interval))  missing_parameter("The 'Size interval' filter is mandatory")
    
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
    
    
    # If we use "as_attachment" then the correct filename is returned to the caller,
    # but if we then attempt to remove the file with "on.exit(unlink(filepath))" the call never completes
    # This means that each and every download will create a stale temporary file...
    
    plumber::as_attachment(readBin(filepath, "raw", n = file.info(filepath)$size), filename) 
    
    # Before:
    
    #res$setHeader("Content-Disposition", paste0("attachment; filename=", filename))
    
    #on.exit(unlink(filepath))
    
    #return(
    #  readBin(filepath, "raw", n = file.info(filepath)$size)
    #)
  })
}

#* @parser json
#* @get /ST05/<reporting_flag>
function(req, res, reporting_flag) {
  promises::future_promise(packages = c("iccat.dev.data", "iccat.pub.data", "rlang"), globals = c("req", "res", "CS", "reporting_flag"), {
    return(
      CS[Year >= 1950 & FlagCode == reporting_flag, 
         .(NUM_FISH = sum(Nr, na.rm = TRUE)),
         keyby = .(REPORTING_FLAG = FlagCode, YEAR = Year, 
                   SPECIES = SpeciesCode,
                   FREQUENCY_TYPE = FreqTypeCode,
                   CLASS_LIMIT = SzClassLimitCode,
                   SIZE_INTERVAL = SzInterval)][order(YEAR, SPECIES, FREQUENCY_TYPE, CLASS_LIMIT, SIZE_INTERVAL)]
    )                      
  })
}