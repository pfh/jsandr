# jsandr

Early development. Smoothing out the process of letting R and Javascript work together. Features are opinionated, and subject to change.

The focus is on creating HTML files as interactive data artifacts that will last in the long term. We either want to completely eliminate the server or only require a dumb HTTP server that does not need to run R.

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

## R to know about

* [shiny] is a client-server approach to using R with Javascript. Running a server in the long term is often difficult, so with `jsandr` I'm trying to help you get rid of the server where possible.
* [htmltools] lets you create HTML from R. It also lets you include Javascript packages, and ensure they are only included once.
* [htmlwidgets] lets other people use your Javascript widgets from R.
* [jsonlite] encodes R objects into JSON for use in Javascript.
    * R does not have the concept of a single value, so numbers are properly encoded as length 1 arrays. This is what jsonlite does by default. htmlwidgets uses jsonlite but misconfigures it to not do this, so be careful. 
    * See `let()` and `let1()` in this package.
* [crosstalk]. Your Javascript code will be able to access crosstalk selections.
* [r2d3] has similar goals to jsandr: making it easy to write Javascript widgets that work with R.

The conventional R representation of tabular data is a list of vectors (i.e. a data frame or tibble). Each vector is a column.

## Javascript to know about

The conventional Javascript representation of tabular data is an array of objects. Each object is a row.

* Learn some HTML.
* Learn some Javascript. Modern Javascript is pretty nice, if you stick to the good bits.
    * [The Modern Javascript Tutorial](https://javascript.info/) by Ilya Kantor looks good.
    * Many tutorial websites exist if you want more hand-holding, such as [codecademy](https://www.codecademy.com/).
* Learn some CSS styling to lay out your page. Style some divs,<br>eg `<div style="display: grid; ..."> ... </div>`.
* Learn some SVG and/or how to use canvas.
* Learn how to represent data as JSON.
* The `d3` package contains many useful building blocks for creating plots.
* It's ok not to use a framework. There are an infinite number of Javascript frameworks, and they are all constantly changing.


### Modules

Modern Javascript now has "modules" (or "ES2015 modules") which work a bit differently to older style modules. However they [can not be used with `file:///`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules#other_differences_between_modules_and_standard_scripts) so are not suitable for creating interactive data artifacts that can be simply distributed as a set of files.

So we stick with the older style modules. These follow the ["module pattern"](https://gist.github.com/ian-schu/8e768a27fdfc4f7197af31fbca3fa8d7), i.e. a pattern of writing code that isn't based on an explicit language feature for modules. You load these with `<script src="...some url..."></script>` and this generally has the effect of defining a new global variable containing all the functions and classes for the module.

(It might well be that such "module pattern" modules are compiled/translated from source code that uses newer language features. This doesn't affect how we use them.)

`htmltools` (and tools built on top of it such as `rmarkdown`) can inline these "module pattern" modules, to ensure your HTML file is self-contained. Maybe one day `htmltools` or a successor will support inlining ES2015 modules.

I wonder if use of `file:///` will be further restricted in future. Data historians may need to be able to run a dumb HTTP or HTTPS server.


### Running a dumb HTTP server

The [servr] R package can be used to run a dumb HTTP server.

```
servr::httd()
```

Or use `python3 -m http.server`.


## Notes

### talkToPlotly

Could be made more efficient:

* Don't always redraw if there is a filter.
* Set-specific updates.


[shiny]: https://shiny.rstudio.com/
[htmltools]: https://rstudio.github.io/htmltools/
[htmlwidgets]: http://htmlwidgets.org/
[jsonlite]: https://cran.rstudio.com/web/packages/jsonlite/index.html
[crosstalk]: https://rstudio.github.io/crosstalk/
[r2d3]: https://rstudio.github.io/r2d3/
[servr]: https://cran.rstudio.com/web/packages/servr/index.html
