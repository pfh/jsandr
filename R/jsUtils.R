
#' Send data to Javascript
#'
#' Make data available in Javascript. Data is encoded using jsonlite.
#'
#' The let1 variant is for setting single numbers, which are otherwise encoded as arrays of length 1.
#'
#' @param ... Data to send to Javascript. Argument names become variable names.
#'
#' @examples
#' let(x=c(1,2,3,4), y=c(5,6,7,8))
#'
#' let1(n=4)
#'
#' @export
let <- function(...) {
    items <- list(...)
    code <- purrr::map_chr(seq_along(items),\(i) {
        paste0("let ", names(items)[[i]], " = ", jsonlite::toJSON(items[[i]]), ";")
    })
    
    htmltools::tags$script(paste(c("",code,""), collapse="\n"))
}

#' @rdname let
#' @export
let1 <- function(...) {
    items <- list(...)
    code <- purrr::map_chr(seq_along(items),\(i) {
        item <- items[[i]]
        assertthat::assert_that(length(item) == 1)
        names(item) <- NULL
        paste0("let ", names(items)[[i]], " = ", jsonlite::toJSON(items[[i]]), "[0];")
    })
    
    htmltools::tags$script(paste(c("",code,""), collapse="\n"))
}



#' Depend on a Javascript library available at a URL
#'
#' Include a Javascript dependency, for example in an rmarkdown document.
#'
#' Downloads the script at the given URL if it is not aleady cached. Returns an empty HTML object that depends on the library. \code{name} and \code{version} are used by \code{htmltools} to decide which version of a library to include. If several versions are depended on, the latest version is chosen. Of course there is the possibility of subtle bugs because of this! If no name is given, the hash of the url is used.
#'
#' If you're using the same package as some widget, make sure you use the same name (\code{htmltools::findDependencies(someWidget)}), or just rely on the widget for the dependency.
#'
#' The file cache directory is chosen using \code{rappdirs::user_cache_dir("jsandr")}.
#'
#' @param url URL of the library.
#'
#' @param name Name of library. \code{htmltools} will include the library exactly once in the document, using the latest mentioned version.
#'
#' @param version Version of the library, should be interpretable by \code{numeric_version()}.
#'
#' @return
#' An empty \code{htmltools::tagList} that depends on the specified URL. Creates the dependency when it is printed in an rmarkdown document.
#'
#' @examples
#' depend("https://unpkg.com/svd-js@1.1.1/build-umd/svd-js.min.js")
#'
#' @export
depend <- function(url, name=NULL, version=NULL) {
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
    
    if (is.null(name)) {
        name <- destFile
        version <- "1"
    }
    
    htmltools::tagList(
        htmltools::htmlDependency(
            name, version, destDir, 
            script=destFile, all_files=FALSE))
}


#' Depend on D3
#'
#' Use a version of D3 included in r2d3.
#'
#' @param ... Parameters for \code{r2d3::html_dependencies_d3}.
#'
#' @examples
#' dependD3()
#'
#' @export
dependD3 <- function(...) {
    htmltools::tagList( r2d3::html_dependencies_d3(...) )
}


#' Depend on plotly
#'
#' Extracts the dependency from the plotly R package.
#'
#' @examples
#' dependPlotly()
#'
#' @export
dependPlotly <- function() {
    htmltools::tagList( plotly:::plotlyMainBundle() )
}


# dependCrosstalk()

