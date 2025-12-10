# Codebook for the data sheet

## Variables

For more details on the methodology for measuring/calculating the variables, please refer to the manuscript.

#### Anthropometrics

-   `ID`: Individual participant identifier 
-   `Sex`: Biological sex, coded as `f` (female) or `m` (male) 
-   `BM`: Body mass (in kg) 
-   `BH`: Body height (in cm) 
-   `SH`: Sitting height (in cm)

#### Age

All age variables are given in years as a continuous value. 
-   `CA`: Chronological age 
-   `Dif APHV`: Difference to age at peak velocity, i.e., `CA` minus `APHV`. Used as a proxy of the biological age. 
-   `APHV`: Age at peak height velocity. Calculated from `CA`, `BM`, `BH`, and `SH` using the Mirwald method.

#### Performance measures

Sprint values do not need to add up, because the best times can be from different trials. 
For the sprint variables, lower values indicate better performance (faster sprinting times). 
-   `S 0-10m`: 60m sprint, first 10 meters (in s)
-   `S 10-30m`: 60m sprint, meter 10-30 (in s) 
-   `S 0-30m`: 60m sprint, first half (in s)
-   `S 30-60m`: 60m sprint, second half (in s)
-   `S 0-60m`: 60m sprint, full distance (in s) 
-   `FOST`: Forward shot throw distance (in m) 
-   `BOST`: Backward overhead shot throw distance (in m) 
-   `TH`: Triple hop distance (in m) 
-   `FJT`: Five-jump test distance (in m) 
-   `CMJ`: Countermovement jump height (in cm) 
-   `DJ`: Drop jump efficiency 
-   `12MR`: 12-Minute run test distance (in m)

## License

This dataset is released under a CC-BY license (<https://creativecommons.org/licenses/by/4.0/>).
