
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



#' Depend on a Javascript library available at a URL
#'
#' Include a Javascript dependency, for example in an rmarkdown document.
#'
#' Downloads the script at the given URL if it is not aleady cached. Returns an empty HTML object that depends on the library. \code{name} and \code{version} are used by \code{htmltools} to decide which version of a library to include. If several versions are depended on, the latest version is chosen. Of course there is the possibility of subtle bugs because of this!
#'
#' In Javascript, a script will generally create some object, which might or might not be called the same thing as the name used here. For example plotly creates an object called "Plotly" in Javascript, however the plotly R package uses the dependency name "plotly-main". Because we don't control the name of the object created in Javascript, we can't use multiple versions of a library at once even if we were mad enough to want to.
#'
#' If you're using the same package as some widget, make sure you use the same name (\code{htmltools::findDependencies(someWidget)}), or just rely on the widget for the dependency.
#'
#' @param name Name of library. \code{htmltools} will include the library exactly once in the document, using the latest mentioned version.
#'
#' @param version Version of the library, should be interpretable by \code{numeric_version()}.
#'
#' @param url URL of the library.
#'
#' @export
depend <- function(name, version, url) {
    destDir <- rappdirs::user_cache_dir("jsandr")
    dir.create(destDir, recursive=TRUE, showWarnings=FALSE)
    
    destFile <- paste0(openssl::sha1(url),".js")
    destPath <- file.path(destDir, destFile)
    
    if (!file.exists(destPath)) {
        tempPath <- tempfile(tmpdir=destDir)
        result <- download.file(url, destfile=tempPath)
        if (result != 0)
            stop("Failed to download ", url)
        file.rename(tempPath, destPath)
    }
    
    htmltools::tagList(
        htmltools::htmlDependency(
            name, version, destDir, 
            script=destFile, all_files=FALSE))
}


# dependD3()
# dependPlotly()
# dependCrosstalk()

