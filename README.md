# countdown

<!-- badges: start -->
<!-- badges: end -->

**countdown** makes it easy to drop in a simple countdown timer in slides and HTML documents written in R Markdown.

``` r
library(countdown)

countdown(minutes = 0, seconds = 15)
```

<img src="man/figures/countdown.gif" width="200px">

### Want to know more?

Check out countdown in its native environment in the [countdown presentation](https://pkg.garrickadenbuie.com/countdown).

## Installation

You can install countdown from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("gadenbuie/countdown")
```

## Shiny App

**countdown** ships with a [Shiny app](https://shiny.rstudio.com) for an interactive _full-screen countdown timer_!

To launch the app, run

```r
countdown_app()
```

or use the version hosted online at [apps.garrickadenbuie.com/countdown](https://apps.garrickadenbuie.com/countdown/).

<a href="https://apps.garrickadenbuie.com/countdown/">
<img src="docs/img/countdown-app.png" width="75%" />
</a>
