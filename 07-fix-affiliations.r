library(tidyverse)
library(readxl)

a <- readxl::read_excel("data/ror-corrections.xlsx", sheet = "CORRECTED") %>%
  mutate(rowid = as.integer(rowid))

# sanity checks
stopifnot(!is.na(a$rowid))
stopifnot(!is.na(a$keep))
stopifnot(a$keep %in% c("c", "m", "s", "y")) # non-problematic cases
stopifnot(!is.na(a$affiliation))
stopifnot(!duplicated(a$affiliation))
stopifnot(!(a$keep == "c" & is.na(a$c_name)))
stopifnot(!(a$keep == "c" & is.na(a$c_id)))
stopifnot(!(a$keep == "m" & is.na(a$m1_name)))
stopifnot(!(a$keep == "m" & is.na(a$m1_id)))
stopifnot(!(a$keep == "m" & is.na(a$m2_name)))
stopifnot(!(a$keep == "m" & is.na(a$m2_id)))
# 24 special values
select(filter(a, keep == "s"), rowid, starts_with("c_")) %>% print(n = Inf)

a <- a %>%
  # process corrected rows
  mutate(
    organization.name = case_when(
      keep == "y" ~ organization.name,
      keep == "c" ~ c_name,
      # TODO: currently using 1st affil. only, fix?
      keep == "m" ~ m1_name,
      keep == "s" & c_name == "(independent)" ~ "(independent)",
      keep == "s" & c_name != "(independent)" ~ c_name
    ),
    organization.id = case_when(
      keep == "y" ~ organization.id,
      keep == "c" ~ c_id,
      # TODO: currently using 1st affil. only, fix?
      keep == "m" ~ m1_id,
      keep == "s" ~ c_id # contains countries for special values
    )
  ) %>%
  select(
    affiliation,
    # [NOTE] this column contains special values, e.g. "(private sector)", that
    #        deliberately do not have a ROR URL; use this instead of the name
    #        provided by the ROR data dump (problem: those participants will not
    #        have a country value)
    affiliation_ror = organization.name, #
    affiliation_url = organization.id # missing for a few special cases
  )

# sanity check: some affiliations are not assigned to a ROR entity, but in that
# case, we at least have their corrected country stored
table(is.na(a$affiliation_url))
table(str_detect(a$affiliation_url, "ror.org")) # 24 special cases

# add country information -------------------------------------------------

b <- readr::read_csv("data/v1.25-2023-05-11-ror-data.csv.zip") %>%
  mutate(country.country_code = if_else(
    is.na(country.country_code) & country.country_name == "Namibia", "NA",
    country.country_code)) %>%
  select(id, starts_with("country"))

a <- left_join(a, b, by = c("affiliation_url" = "id"))

# sanity check: no ROR-identified affiliation has a missing country code
stopifnot(!(str_detect(a$affiliation_url, "ror.org") &
              is.na(a$country.country_code)))

# for the few remaining cases, we go through a different merge
a <- bind_rows(
  filter(a, !is.na(country.country_code)),
  left_join(
    filter(a, is.na(country.country_code)) %>%
      select(-starts_with("country")) %>%
      mutate(country.country_name = affiliation_url,
             affiliation_url = NA_character_)
    ,
    distinct(select(b, starts_with("country.")))
    ,
    by = "country.country_name"
  )
) %>%
  rename(
    affiliation_ccode = country.country_code,
    affiliation_cname = country.country_name
  ) %>%
  arrange(affiliation)

# sanity checks: no missing affiliations or country codes
stopifnot(!is.na(a$affiliation))
stopifnot(!is.na(a$affiliation_ccode))
stopifnot(!is.na(a$affiliation_cname))

# export ------------------------------------------------------------------

write_tsv(a, "data/ror-affiliations.tsv")

# kthxbye
