library(tidyverse)

# all conference years
d <- fs::dir_ls("data", regexp = "epsa\\d{4}-program") %>%
  map_dfr(read_tsv, col_types = cols(.default = "c"), .id = "year") %>%
  mutate(year = as.integer(str_extract(year, "\\d{4}")))

# guessed genders ---------------------------------------------------------

d <- d %>%
  # same routin as in `08-query-genderizer.r` to ensure matches
  mutate(
    # remove brackets in 'Alice (Yunyun) Smith'
    first_name = str_remove_all(full_name, "\\(|\\)") %>%
      # remove initials in "Alex C. Smith"
      str_remove_all("[A-Z]\\.\\s") %>%
      # remove initials in "Alex C Smith"
      str_replace_all("\\s([A-Z])\\s", " "),
    first_name = str_remove(first_name, "\\s.*")
  )

g <- readr::read_tsv("data/genderizer-results.tsv", col_types = "cccdi")

# sanity check: all first_names are found in genderizer results
stopifnot(d$first_name %in% g$first_name)

d <- left_join(d, select(g, -name, -probability, -count), by = "first_name") %>%
  select(-first_name) %>%
  relocate(gender, .after = "full_name")

# fixed affiliations ------------------------------------------------------

a <- read_tsv("data/ror-affiliations.tsv")
d <- select(left_join(d, a, by = "affiliation"), -affiliation) %>%
  relocate(affiliation_ror, .after = "gender") %>%
  mutate(
    # until last NA values in `affiliation` have been handled
    affiliation_ror = str_replace_na(affiliation_ror)
  )

# TODO: fix, two persons from 2019 missing an affiliation
filter(d, affiliation_ror == "NA")

# sanity checks
stopifnot(!is.na(d$affiliation_ror))
stopifnot(d$affiliation_ror != "")

# some individuals have stable affiliations...
select(d, full_name, affiliation_ror, year) %>%
  distinct() %>%
  # ... and some attended all conference years
  count(full_name, affiliation_ror, sort = TRUE)

# others (many... over 800) have varying affiliations
group_by(d, full_name) %>%
  filter(n_distinct(affiliation_ror) > 1) %>%
  count(full_name, affiliation_ror)

# participant hashes ------------------------------------------------------

# generate hashes that are unique per individual and conference year, but that
# repeat in a given conference year when the participant was in several panels
d <- d %>%
  mutate(pid = str_c(year, full_name, affiliation_ror),
         pid = map_chr(pid, rlang::hash))

# example
# View(d[ d$pid == "9df0ed10a3175afdf1d67984329e0625", ])

# export master dataset ---------------------------------------------------

# final cleanup step
d <- mutate_if(d, is.character, ~ str_replace_all(.x, "\\n", " "))

readr::write_tsv(d, "data/epsa-program.tsv")

# kthxbye
