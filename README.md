# jsandr

Early development. Utilities to help R and Javascript work together. Features are opinionated, and subject to change.

The focus is on creating HTML files as interactive data artifacts that will last in the long term. No server or dumb HTTP server.

If the data is large, we might need supplementary files that can be loaded with HTTP range requests.

Timeline:

1. R code is run. HTML file is produced. (Usually Rmd or qmd rendering.) 
2. Years pass.
3. HTML file loaded in browser. JS code runs as HTML is parsed.

Principles:

* Results appear below all the code necessary to create it. We are not creating the Knuth/Observable literate programming hairball. Have to defer JS execution until relevant DOM element exists.
* Results are a function of inputs. The state of the system is fully captured by the state of the inputs.
* The simplest correct way to implement this is using an idempotent update function that is called any time an input changes. Finer grained options exist: multiple stages of update, libraries such as react.
* BUT the user making a selection is an event. The selection does not change if the data under it changes in future. You might need to make sure the right type of state is stashed somewhere, eg managed by crosstalk. You might need to fight your tools to achieve this.

# R to know about

* shiny is what we are trying to escape from.
* htmltools.
* htmlwidgets.
* r2d3 has similar goals to jsandr.
* jsonlite. R does not have the concept of a single value, so numbers are properly encoded as length 1 arrays. htmlwidgets uses jsonlite but misconfigures it away from this correct default, so be careful. (See `let()` and `let1()` in this package.)

The conventional R representation of tabular data is a list of vectors (i.e. a data frame or tibble).

# Javascript to know about

The conventional Javascript representation of tabular data is an array of objects.

* Learn some HTML.
* Learn some CSS.
* Learn some SVG and/or how to use canvas.
* Modern Javascript is ok, if you stick to the good bits.
* It's ok not to use a framework. There are an infinite number of Javascript frameworks, and they are all constantly changing.

# Notes

## talkToPlotly

Could be made more efficient:

* Don't always redraw if there is a filter.
* Set-specific updates.