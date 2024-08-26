read_url <- function(url_base, url_path){


  os <- Sys.info()[['sysname']]

  if(os != "Darwin"){
    #for some reason jsonlite fails on windows

  out <- httr2::request(url_base) |>
    httr2::req_url_path_append(url_path) |>
    httr2::req_throttle(10 / 60, realm = url_base) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)
  }else{
    # and httr2 fails on mac
    out <- jsonlite::read_json(file.path(url_base,url_path), simplifyVector = TRUE)
  }

  #out <- httr2::request(url_base) |>
  #  httr2::req_url_path_append(url_path) |>
  #  httr2::req_retry(max_tries = 5, backoff = ~ 5) |>
  #  httr2::req_perform() |>
  #  httr2::resp_body_json(simplifyVector = TRUE)

  return(out)
}
