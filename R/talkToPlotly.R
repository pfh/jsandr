#' Improved crosstalk behaviour with plotly widget
#'
#' Try to provide standard behaviour for selections and filters.
#'
#' @import htmlwidgets
#'
#' @export
talkToPlotly <- function(plotlyObject, dragmode="select", webGL=TRUE, unselectedColor="#cccccc", width=NULL, height=NULL, elementId=NULL) {
    
    if (ggplot2::is.ggplot(plotlyObject))
        plotlyObject <- plotly::ggplotly(plotlyObject, tooltip="text")
       
    if (webGL)
        plotlyObject <- plotly::toWebGL(plotlyObject)
    
    x <- plotlyObject$x
    
    if (!is.null(dragmode))
        x$layout$dragmode <- dragmode
    
    warn <- FALSE
    for(i in seq_along(x$data)) {
        if (typeof(x$data[[i]]$key) != "list") next
        x$data[[i]]$set <- NULL
        x$data[[i]]$key <- NULL
        warn <- TRUE
    }
    if (warn) 
        warning("talkToPlotly does not allow linked brushing of grouped data.")
        
    if (!is.null(unselectedColor)) {
        for(i in seq_along(x$data)) {
            x$data[[i]]$unselected$marker$color <- unselectedColor
        }
    }
    
    dependencies <- c(
        crosstalk::crosstalkLibs(),
        Filter(
            \(item) item$name == "plotly-main", 
            plotlyObject$dependencies))

    # create widget
    widget <- htmlwidgets::createWidget(
        name = 'talkToPlotly',
        x,
        width = width,
        height = height,
        package = 'jsandr',
        elementId = elementId,        
        dependencies = dependencies)
    
    widget
}

#' Shiny bindings for talkToPlotly
#'
#' Output and render functions for using plotsync within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a plotsync
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name talkToPlotly-shiny
#'
#' @export
talkToPlotlyOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'talkToPlotly', width, height, package = 'talkToPlotly')
}

#' @rdname talkToPlotly-shiny
#' @export
renderTalkToPlotly <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, talkToPlotlyOutput, env, quoted = TRUE)
}
