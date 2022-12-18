# jsandr

```
remotes::install_github("pfh/jsandr")
```

Early development. Smoothing out the process of letting R and Javascript work together. Features are opinionated, and subject to change.

* [See articles for example usage.](https://logarithmic.net/jsandr/articles/)

The focus is on creating HTML files as interactive data artifacts that will last in the long term. We either want to completely eliminate the server or only require an HTTP server to serves static files.

Typical sequence of events:

1. R code is run. HTML file is produced (usually rmarkdown or quarto.) 
2. Years pass.
3. HTML file loaded in browser. Javascript code runs as HTML is parsed.


## R to know about

* [shiny] is a client-server approach to using R with Javascript. Running a server in the long term is often difficult, so with `jsandr` I'm trying to help you get rid of the server where possible.
* [htmltools] lets you create HTML from R. It also lets you include Javascript packages, and ensure they are only included once.
* [htmlwidgets] lets you create Javascript widgets that are convenient for others to use.
* [jsonlite] encodes R objects into JSON for use in Javascript.
    * R does not have the concept of a single value that is not part of a vector, so numbers are properly encoded as length 1 arrays. This is what jsonlite does by default. htmlwidgets uses jsonlite but misconfigures it so that all vectors of length one are treated as simple values, possibly introducing bugs when you truly do have a vector of length 1.
    * See `let()` and `let1()` in this package.
* [crosstalk] lets htmlwidgets share a selection and filters. Your Javascript code can also access crosstalk selections.
* [r2d3] has similar goals to jsandr: making it easy to write Javascript widgets that work with R.


## Javascript to know about

* Learn some HTML.
* Learn some Javascript. Javascript has a long history with some mistakes along the way, but modern Javascript is pretty nice if you stick to the good bits.
    * [The Modern Javascript Tutorial](https://javascript.info/) by Ilya Kantor looks good to me.
    * Many tutorial websites exist if you want more hand-holding, such as [codecademy](https://www.codecademy.com/).
* Learn some CSS styling to lay out your page. Grid layout using `<div>`s will be sufficient for many layout tasks. <br>eg `<div style="display: grid; ..."> ... </div>`.
* Learn some SVG and/or how to use canvas.
* Learn how to represent data as JSON.
* The [d3] package contains many useful building blocks for creating plots.
    * [D3 in Depth](https://www.d3indepth.com/) by Peter Cook looks good to me.
* It's ok not to use a framework. There are an infinite number of Javascript frameworks, and they are all constantly changing.


## Javascript modules

Modern Javascript now has "modules" (or "ES2015 modules") which work a bit differently to older style modules. However they [can not be used with `file:///`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules#other_differences_between_modules_and_standard_scripts) so are not suitable for creating interactive data artifacts that can be simply distributed as a set of files.

So we stick with the older style modules. These follow the ["module pattern"](https://gist.github.com/ian-schu/8e768a27fdfc4f7197af31fbca3fa8d7), i.e. a pattern of writing code that isn't based on an explicit language feature for modules. You load these with `<script src="...some url..."></script>` and this generally has the effect of defining a new global variable containing all the functions and classes for the module.

(Most such "module pattern" modules are compiled/translated from source code that uses newer language features. This doesn't affect how we use them.)

`htmltools` (and tools built on top of it such as `rmarkdown`) can inline these "module pattern" modules, to ensure your HTML file is self-contained. Maybe one day `htmltools` or a successor will support inlining ES2015 modules.

I wonder if use of `file:///` will be further restricted in future. Data historians may need to run a dumb HTTP or HTTPS server.


## Tabular data

The conventional R representation of tabular data is a list of vectors (i.e. a data frame or tibble). Each vector is a column.

The conventional Javascript representation of tabular data is an array of objects. Each object is a row.

A Javascript array is like an unnamed list in R, it can hold anything and is indexed by numbers (0,1,2,...). A Javascript object is like a named list in R, it also can hold anything, is indexed by name, and the order of elements is usually not important.

[d3] has [functions for manipulating arrays](https://github.com/d3/d3-array) which cover many common operations, eg grouped summaries are called a rollup.


## Running a dumb HTTP server

The [servr] R package can be used to run a dumb HTTP server, serving static files.

```
servr::httd()
```

Or use `python3 -m http.server`.


## Further rough notes

### Principles

* Results appear below all the code necessary to create it. 
    * Have to defer JS execution until relevant DOM element exists.
    * Donald Knuth's original concept of literate programming allowed code to be presented in an arbitrary order. [Observable](https://observablehq.com/) also allows things to be presented out of order and always shows results before code. Personal opinion: I don't like this.
* Results are a function of inputs. The state of the system is fully captured by the state of the inputs.
* The simplest correct way to implement this is using an [idempotent] update function that is called any time an input changes. Finer grained options exist: multiple stages of update, libraries such as react.
* When the user makes a selection, the "input" that defines the state is the selected items. The selected items should not change in response to other inputs. You might need to fight your tools to achieve this. [crosstalk] gets this right.
    * Example: Suppose you have a rectangular selection, and then points are move in and out of the rectangle when other inputs change. The selected points should not change.

There is a reactive development principle "data down, actions up".

### Large data

If the data is large, we might need supplementary files that can be accessed using HTTP range requests. So far as I can google, only bioinformaticians think this is a good idea. [GMOD](https://github.com/GMOD) has a collection of Javascript packages that can read bioinformatic formats in this way. These are all specialized formats, the tabix format is probably the most generic. The bgzf format allows random access to compressed data, and is the basis for several of these formats.

### talkToPlotly implementation

Could be made more efficient:

* Don't always redraw if there is a filter.
* Set-specific updates.


[idempotent]:  https://stackoverflow.com/questions/1077412/what-is-an-idempotent-operation
[shiny]: https://shiny.rstudio.com/
[htmltools]: https://rstudio.github.io/htmltools/
[htmlwidgets]: http://htmlwidgets.org/
[jsonlite]: https://cran.rstudio.com/web/packages/jsonlite/index.html
[crosstalk]: https://rstudio.github.io/crosstalk/
[r2d3]: https://rstudio.github.io/r2d3/
[servr]: https://cran.rstudio.com/web/packages/servr/index.html
[d3]: https://github.com/d3/d3