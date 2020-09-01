# library(dplyr)
# library(htmltools)
# library(jsonlite)
# library(magrittr)

shellcheckrAddin <- function(path) {
  if (missing(path)) {
    context <- rstudioapi::getActiveDocumentContext()
    path <- context$path
  }
  result <- suppressWarnings(system2('shellcheck', c('-f', 'json1', path), stdout = TRUE))
  markers <- jsonlite::fromJSON(result)$comments %>%
    transmute(type = level,
              file = file,
              line = line,
              column = column,
              message = HTML(as.character(
                withTags(span(.data$message,
                              a(href = paste0('https://www.shellcheck.net/wiki/SC', .data$code),
                                paste0('SC', .data$code)))))))
  rstudioapi::sourceMarkers('ShellCheck', markers, autoSelect = 'error')
}
