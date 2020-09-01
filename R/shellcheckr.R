#' Run `shellcheck` on a document and parse to markers
#'
#' Runs [`shellcheck`](https://www.shellcheck.net/) and parses output into markers with
#' [ShellCheck wiki](https://www.shellcheck.net/wiki/) links for the problematic codes.
#'
#' Intended for use as an [RStudio Addin](https://rstudio.github.io/rstudioaddins/).
#'
#' @param path path of file to check. The active document is used if this is missing.
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
shellcheckrMarkers <- function(path) {
  markers <- shellcheckr(path)$comments %>%
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

#' Run `shellcheck` on a document
#'
#' Runs [`shellcheck`](https://www.shellcheck.net/) on a document and returns the JSON output.
#'
#' @param path path of file to check. The active document is used if this is missing.
#'
#' @return JSON output of [`shellcheck`](https://www.shellcheck.net/).
#' @export
shellcheckr <- function(path) {
  if (missing(path)) {
    context <- rstudioapi::getActiveDocumentContext()
    path <- context$path
  }
  result <- suppressWarnings(system2('shellcheck', c('-f', 'json1', path), stdout = TRUE))
  jsonlite::fromJSON(result)
}
