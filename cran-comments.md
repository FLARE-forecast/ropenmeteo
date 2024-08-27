## R CMD check results

0 errors | 0 warnings | 0 note

* This is a resubmission that addresses the feedback from Benjamin Altmann (thanks!).
* package names, software names and API (application programming interface) now have single quotes in title and description.'Open-Meteo'
* Package names is changed from `RopenMeteo` to `ropenmeteo` to remove issues with case sensitivity.
* The redundant "R" at the start of the title and description has been removed
* All exported functions have a "\value" with the class (e.g. data frame) and what it means.
