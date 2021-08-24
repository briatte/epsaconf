library(tidyverse)
library(readxl)

a <- "data/ror-corrections.xlsx" %>%
  readxl::read_excel(sheet = "CORRECTED") %>%
  # process corrected rows
  mutate(
    organization.name = case_when(
      keep %in% "y" ~ organization.name,
      keep %in% "c" ~ c_name,
      # TODO
      # currently using 1st affil only
      keep %in% "m" ~ m1_name,
      keep %in% "n" ~ NA_character_,
      # covers `p`
      TRUE ~ NA_character_
    ),
    organization.id = case_when(
      keep %in% "y" ~ organization.id,
      keep %in% "c" ~ c_id,
      # TODO
      # currently using 1st affil only
      keep %in% "m" ~ m1_id,
      keep %in% "n" ~ NA_character_,
      # covers `p`
      TRUE ~ NA_character_
    ) #,
    # # countries for correctly identified affiliations
    # country = case_when(
    #   keep %in% "y" ~ organization.country.country_name,
    #   TRUE ~ NA_character_
    # )
  ) %>%
  select(
    affiliation,
    # [NOTE] this column contains special values, e.g. "(private sector)", that
    #        deliberately do not have a ROR URL; use this instead of the name
    #        provided by the ROR data dump (problem: those participants will not
    #        have a country value)
    affiliation_ror = organization.name,
    affiliation_url = organization.id
  )

# sanity check
stopifnot(!duplicated(a$affiliation))

# some affiliations are not assigned to a ROR entity
table(is.na(a$affiliation_url))

# add country information -------------------------------------------------

f <- "data/ror-countries.tsv"

# initialize country dataset, using ROR data dump
if (!fs::file_exists(f)) {

  b <- fs::dir_ls("data", regexp = "ror-data\\.json$")
  if (length(b) != 1) {
    stop("No ROR data dump found in `data` folder.")
  }

  # extract relevant columns from JSON object
  # [NOTE] very slow (5 minutes)
  jsonlite::fromJSON(b, flatten = TRUE) %>%
  select(id, starts_with("country")) %>%
    readr::write_tsv(f)

}

b <- readr::read_tsv(f, col_types = "ccc")

# export ------------------------------------------------------------------

left_join(d, b, by = c("affiliation_url" = "id")) %>%
  rename(
    affiliation_ccode = country.country_code,
    affiliation_cname = country.country_name
  ) %>%
  write_tsv("data/ror-affiliations.tsv")

# kthxbye
