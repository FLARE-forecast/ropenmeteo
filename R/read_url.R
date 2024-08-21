read_url <- function(url_base, url_path){

  out <- httr2::request(url_base) |> httr2::req_url_path(url_path) |> httr2::req_retry(max_tries = 5, backoff = ~ 5) |> httr2::req_perform() |> httr2::resp_body_json(simplifyVector = TRUE)

  return(out)
}
