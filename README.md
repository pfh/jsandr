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
* Data down, actions up.
* Data down is performed using idempotent update functions. (Maybe support react at some point?)

# Notes

## talkToPlotly

Could be made more efficient:

* Don't always redraw if there is a filter.
* Set-specific updates.