## R CMD check results

0 errors | 0 warnings | 1 note

This is a re-submission of v0.4.0 to address this comment:

> Please always make sure to reset to user's options(), working directory
> or par() after you changed it in examples and vignettes and demos.
> e.g.:
> 
> old <- options(digits = 3)
> ...
> options(old)
> 
> Please fix and resubmit.

I removed the call to options() in the example Shiny app.
