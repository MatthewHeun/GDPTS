# This file contains code to standardize
# PWT5.6 data (base year 1985) to be consistent with
# PWT10.01 (base year 2017).
# The approach is to look at GDP data from the USA for 2017
# and 1985, form a ratio, and
# apply the ratio to selected PWT5.6 GDP data as needed.

# Both PWT5.6 and PWT10.01 provide real GDP that is comparable
# across both countries and years.
# We select the rgdpch time series from PWT5.6,
# described as "the recommended intertemporal GDP time series" in the paper
# Robert Summers and Alan Heston,
# "The Penn World Table (Mark 5): An Expanded Set of International Comparisons, 1950-1988."
# The Quarterly Journal of Economics, May, 1991, Vol. 106, No. 2 (May, 1991), pp. 327-368.
# rgdpch is provided as per-capita GDP, so we multiply by population provided by PWT5.6.
# We select the rgdpe time series from PWT10.01,
# described as
# "real GDP using prices that are constant across countries and are also constant over time"
# in the paper
# Robert C. Feenstra, Robert Inklaar, and Marcel P. Timmer,
# "The Next Generation of the Penn World Table."
# American Economic Review, 2015, Vol. 105, No. 10, pp. 3150–3182.

# Step 1
# Gather PWT 5.6 USA data (1985 base year).
pwt56_usa <- pwt::pwt5.6 |>
  dplyr::filter(wbcode == "USA") |>
  tibble::as_tibble() |>
  magrittr::set_rownames(NULL) |>
  # Use rgdpch (per capita chained real GDP) in 1985$
  dplyr::select(country, wbcode, year, rgdpch, pop) |>
  dplyr::mutate(
    pop_56 = pop * 1000, # pop in thousands, pop_56 in persons
    rgdpch_56 = rgdpch * pop_56, # rgdpch in $/person, rgdpch_56 in $
    pop = NULL,
    rgdpch = NULL
  )
# Extract the relevant data point (1985).
rgdpch_56_1985 <- pwt56_usa |>
  dplyr::filter(year == 1985) |>
  magrittr::extract2("rgdpch_56")

# Step 2
# Gather PWT10.01 USA data (2017 base year).
pwt1001_usa <- pwt10::pwt10.01 |>
  tibble::as_tibble() |>
  magrittr::set_rownames(NULL) |>
  # Use rgdpe in 2017$
  dplyr::select(country, isocode, year, rgdpe, pop) |>
  dplyr::filter(isocode == "USA") |>
  dplyr::mutate(
    pop_1001 = pop * 1e6, # pop in millions, pop_1001 in persons
    rgdpe_1001 = rgdpe * 1e6, # rgdpe in million 2017$, rgdpe_1001 in $
    pop = NULL,
    rgdpe = NULL
  )
# Extract the relevant data point (1985).
rgdpe_1001_1985 <- pwt1001_usa |>
  dplyr::filter(year == 1985) |>
  magrittr::extract2("rgdpe_1001")

# Step 3
# Calculate the ratio in the base year (1985)
# rgdpch_fix_ratio_for_2017_base_year in 2017$/1985$
rgdpch_fix_ratio_for_2017_base_year <- rgdpe_1001_1985 / rgdpch_56_1985

# Step 4
# Apply the ratio to the rgdpch time series from PWT5.6.
pwt56_usa <- pwt56_usa |>
  dplyr::mutate(
    rgdpch_56_2017 = rgdpch_56 * rgdpch_fix_ratio_for_2017_base_year
  )

# Step 5
# Make a data frame of population and GDP for later use in graphs.
pwt_comparison_df <- dplyr::full_join(pwt56_usa, pwt1001_usa,
                                      by = dplyr::join_by(country, year, wbcode == isocode)) |>
  tidyr::pivot_longer(cols = c(pop_56, pop_1001, rgdpch_56, rgdpch_56_2017, rgdpe_1001),
                      names_to = "varname",
                      values_to = "value")




# Compare countries available in PWT vs. CL-PFU database

pwt_codes <- PFUSetup::get_abs_paths(version = "v1.3")[["country_concordance_path"]] |>
  readxl::read_excel() |>
  dplyr::select("pwt5.6.name", "pwt10.name", "PFU.code")

pwt56_with_country_codes <- dplyr::left_join(pwt::pwt5.6,
                                             pwt_codes |> dplyr::select(-`pwt10.name`),
                                             by = dplyr::join_by(country == `pwt5.6.name`)) |>
  dplyr::select(country, wbcode, PFU.code, year, pop, rgdpch) |>
  dplyr::filter(!is.na(pop))
# Check for iso code differences with the following code
# pwt56_with_country_codes |>
#   dplyr::filter(wbcode != PFU.code)
# Zaire (PWT5.6 wbcode "ZAR") is assigned PFU.code "COD" according to iso3c
# China (PWT5.6 wbcode "CHN") is assigned PFU.code "CHNM" for Mainland China
#   - Hong Kong (PWT5.6 wbcode "HKG") keeps same PFU.code "HKG"
#   - Taiwan (PWT5.6 wbcode "OAN") is assigned PFU.code "TWN"
# Myanmar (PWT5.6 wbcode "BUR") is assigned PFU.code "MMR"
# Germany, West (PWT5.6 wbcode "DEU" pre-1990) is assigned PFU.code "DEUW"
#   to distinguish from DEU (unified Germany, post-1990)
# Romania (PWT5.6 wbcode "ROM") is assigned PFU.code "ROU" according to iso3c

pwt1001_with_country_codes <- dplyr::left_join(pwt10::pwt10.01,
                                               pwt_codes |> dplyr::select(-`pwt5.6.name`),
                                               by = dplyr::join_by(country == `pwt10.name`)) |>
  dplyr::select(country, isocode, PFU.code, year, pop, rgdpe) |>
  dplyr::filter(!is.na(pop))
# Check for iso code differences with the following code
# pwt1001_with_country_codes |>
#   dplyr::filter(isocode != PFU.code)
# China (PWT10.01 wbcode "CHN") is assigned PFU.code "CHNM" for Mainland China
#   - Hong Kong (PWT10.01 isocode "HKG") keeps same PFU.code "HKG"
#   - Taiwan (PWT10.01 isocode "TWN") is assigned PFU.code "TWN"


# How to deal with Germany:
#
# PWT10.01 appears to aggregate East and West Germany prior to 1990.
# Look at population
# PWT5.6 1988 DEU (West): 61.474 million
# PWT5.6 1988 DDR (East): 16.670 million
# PWT5.6 sum: 78.144 million
# PWT10.01 1988 DEU: 78.30752 million
# So PWT10.01 DEU captures all of Germany (including East and West, prior to 1990).
#### Use PWT10.01 exclusively for DEU.

# How to deal with USSR, RUS, FoSUN:
#
# PWT5.6 has USSR, population of 287.630 million in 1989.
# PWT10.01 has FoSUN countries 1990ff and populations for 1990,
# none of which are in PWT5.6:
#   - RUS (Russian Federation): 147.5 million
#   - ARM (Armenia): 3.5 million
#   - AZE (Azerbaijan): 7.2 million
#   - BLR (Belarus): 10.2 million
#   - EST (Estonia): 1.6 million
#   - GEO (Georgia): 5.4 million
#   - KAZ (Kazakhstan): 16.4 million
#   - KGZ (Kyrgyzstan): 4.4 million
#   - LVA (Latvia): 2.7 million
#   - LTU (Lithuania): 3.7 million
#   - MDA (Moldova): 4.4 million
#   - TJK (Tajikistan): 5.3 million
#   - TKM (Turkmenistan): 3.7 million
#   - UKR (Ukraine): 51.5 million
#   - UZB (Uzbekistan): 20.4 million
# PWT10.01 sum: 287.9 million
# So PWT5.6 includes all the countries of FoSUN under the SUN banner.
#### Use PWT5.6 for SUN <= 1989. Use PWT10.01 for FoSUN >= 1990.

# How to deal with Yugoslavia:
#
# PWT5.6 has YUG (Yugoslavia) 1990 and before, population of 23.809 million in 1990.
# PWT10.01 FoYUG countries 1990 and following (with 1990 population):
#   - BIH (Bosnia and Herzegovina): 4.5 million
#   - HRV (Croatia): 4.8 million
#   - MKD (North Macedonia): 2.0 million
#   - MNE (Montenegro): 0.6 million
#   - SRB (Serbia): 9.5 million
#   - SVN (Slovenia): 2.0 million
# PWT10.01 sum: 22.8 million
# So PWT5.6 contains all countries of FoYUG under the YUG banner.
#### Use PWT5.6 for YUG <= 1989 (trim 1990). Use PWT10.01 for FoYUG >= 1990.

# How to deal with Czechoslovakia:
#
# PWT5.6 has CSK (Czechoslovakia) 1990 and before, population of 15.7 million in 1990.
# PWT10.01 lacks CSK but has FoCSK countries (with population in 1990):
#   - CZE (Czech Republic): 10.3 million
#   - SVK (Slovakia): 5.3 million
# PWT10.01 sum: 15.6 million
# So PWT5.6 contains all FoCZK countries under the CZK banner.
#### Use PWT5.6 for CSK <= 1989 (trim 1990). Use PWT10.01 for FoCSK >= 1990.

# How to deal with China:
#
# PWT5.6 has CHN (China) for 1960-1992 with 1990 population of 1133.7 million.
# PWT5.6 has TWN (Taiwan) for 1951-1990 with 1990 population of 8.1 million.
# PWT5.6 has HKG (Hong Kong) for 1960-1992 with 1990 population of 5.7 million.
# PWT5.6 sum: 1147.5 million
# PWT10.01 has CHN (China) for 1952-2019 with 1990 population of 1176.9 million.
# PWT10.01 has TWN Taiwan) for 1961-2019 with 1990 population of 20.3 million.
# PWT10.01 has HKG (Hong Kong) for 1960-2019 with 1990 population of 5.7 million.
# PWT10.01 sum: 1202.9 million
# Worldometer has the following populations in 1990:
#   CHN (China): 1153.7 million
#   TWN (Taiwan): 20.6 million
#   HKG (Hong Kong): 5.8 million
# So maybe PWT counts CHNM + TWN = CHN?
# I find no evidence that CHNM + TWN = CHN in documentation for the PWT.
# In fact, evidence points CHN and TWN being treated separately in the PWT,
# such that CHN = CHNM (when PWT says "China", they mean "Mainland China").
#### Treat CHN as CHNM in the CL-PFU database.

# Build a data frame of standardized PWT information

# Pull in needed information from PWT5.6
pwt56_additions <- pwt::pwt5.6 |>
  dplyr::left_join(pwt_codes |> dplyr::select(PFU.code, `pwt5.6.name`),
                   by = dplyr::join_by(country == `pwt5.6.name`)) |>
  tibble::as_tibble() |>
  magrittr::set_rownames(NULL) |>
  # Use rgdpch (per capita chained real GDP) in 1985$
  dplyr::select(PFU.code, year, pop, rgdpch) |>
  dplyr::rename(Country = PFU.code, Year = year) |>
  dplyr::filter(!is.na(pop)) |>
  dplyr::filter(Country %in% c("SUN", "YUG", "CSK"), Year <= 1989) |>
  dplyr::mutate(
    pop_56 = pop * 1000, # pop in thousands, pop_56 in persons
    rgdpch_56 = rgdpch * pop_56, # rgdpch in 1985$/person, rgdpch_56 in 1985$
    pop = NULL,
    rgdpch = NULL
  ) |>
  dplyr::rename(
    pop = pop_56
  ) |>
  dplyr::mutate(
    # Convert to 2017 base year
    # and give the name rgdpe to match PWT10.01.
    # rgdpch_56 in 1985$,
    # rgdpe in 2017$, and
    # rgdpch_fix_ratio_for_2017_base_year in 2017$/1985$
    # (See above.)
    rgdpe = rgdpch_56 * rgdpch_fix_ratio_for_2017_base_year,
    rgdpch_56 = NULL
  )


# Build the standardized pwt data frame
# starting with PWT10.01.
pwt_harmonized <- pwt10::pwt10.01 |>
  dplyr::left_join(pwt_codes |> dplyr::select(PFU.code, `pwt10.name`),
                   by = dplyr::join_by(country == `pwt10.name`)) |>
  dplyr::filter(!is.na(pop)) |>
  tibble::as_tibble() |>
  magrittr::set_rownames(NULL) |>
  # Use rgdpe in 2017$
  dplyr::select(PFU.code, year, rgdpe, pop) |>
  dplyr::rename(
    Country = PFU.code,
    Year = year
  ) |>
  dplyr::mutate(
    # Convert to persons and 2017$
    pop_1001 = pop * 1e6, # pop in millions, pop_1001 in persons
    rgdpe_1001 = rgdpe * 1e6, # rgdpe in million 2017$, rgdpe_1001 in $
    pop = NULL,
    rgdpe = NULL
  ) |>
  dplyr::rename(
    # From this point onward,
    # all population and GDP numbers are in persons and 2017$.
    pop = pop_1001,
    rgdpe = rgdpe_1001
  ) |>
  # Now add Soviet Union, Yugoslavia, and Czechoslovakia
  dplyr::bind_rows(pwt56_additions)

# Now aggregate to various regions
pwt_harmonized_world <- pwt_harmonized |>
  dplyr::group_by(Year) |>
  dplyr::summarise(pop = sum(pop), rgdpe = sum(rgdpe), .groups = "drop") |>
  dplyr::mutate(
    Country = "World"
  )


pwt_harmonized <- pwt_harmonized |>
  dplyr::bind_rows(pwt_harmonized_world)


usethis::use_data(pwt_harmonized, overwrite = TRUE)
