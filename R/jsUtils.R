
#' @export
let <- function(...) {
    items <- list(...)
    code <- purrr::map_chr(seq_along(items),\(i) {
        paste0("let ", names(items)[[i]], " = ", jsonlite::toJSON(items[[i]]), ";")
    })
    
    htmltools::tags$script(paste(code, collapse="\n"))
}

#' @export
let1 <- function(...) {
    items <- list(...)
    code <- purrr::map_chr(seq_along(items),\(i) {
        item <- items[[i]]
        assertthat::assert_that(length(item) == 1)
        names(item) <- NULL
        paste0("let ", names(items)[[i]], " = ", jsonlite::toJSON(items[[i]]), "[0];")
    })
    
    htmltools::tags$script(paste(code, collapse="\n"))
}

