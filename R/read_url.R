
#' Read open-meteo url to JSON
#'
#' @param url API url
#' @param max_tries number tries before fails
#'
#' @return list
#'
read_url <- function(url, max_tries = 3){

  tries <- 0
  pass <- FALSE
  while(!pass){

    tries <- tries + 1

    out <- tryCatch(
      {
        jsonlite::fromJSON(url)
      },
      error=function(cond) {
        message(cond)
        # Choose a return value in case of error
        return(NULL)
      },
      warning=function(cond) {
        message(cond)
        # Choose a return value in case of warning
        return(NULL)
      },
      finally={}
    )

    if(tries == max_tries | !is.null(out)){
      pass = TRUE
    }else{
      Sys.sleep(2)
    }
  }

  return(out)
}
