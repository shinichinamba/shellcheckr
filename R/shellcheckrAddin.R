#' Run shellcheck on a document
#'
#' An function which parses shellcheck output into markers with ShellCheck wiki links.
#' Intended for use as an RStudio Addin.
#'
#' @param path path of file to check. The active document is used if this is missing.
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
shellcheckrAddin <- function(path) {
  if (missing(path)) {
    context <- rstudioapi::getActiveDocumentContext()
    path <- context$path
  }
  result <- suppressWarnings(system2('shellcheck', c('-f', 'json1', path), stdout = TRUE))
  markers <- jsonlite::fromJSON(result)$comments %>%
    dplyr::transmute(type = .data$level,
                     file = .data$file,
                     line = .data$line,
                     column = .data$column,
                     message = htmltools::HTML(as.character(htmltools::withTags(
                       htmltools::span(.data$message,
                                       htmltools::a(href = paste0('https://www.shellcheck.net/wiki/SC', .data$code),
                                                    paste0('SC', .data$code)))))))
  rstudioapi::sourceMarkers('ShellCheck', markers, autoSelect = 'error')
}
