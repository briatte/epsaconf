# overwrites early TSV files created after importing from other repositories
# updated files have slightly different columns, a lot of revised information
# (affiliations) and additional information (country codes, gender)

library(tidyverse)

d <- readr::read_tsv("data/epsa-program.tsv", col_types = cols(.default = "c"))

# edges -------------------------------------------------------------------

# year, i = participant UID, j = panel UID, role

group_by(d, year) %>%
  group_split() %>%
  map(select, year, i = pid, j = session_id, role) %>%
  map(
    ~ readr::write_tsv(.x, str_c("data/epsa", unique(.x$year), "-edges.tsv"))
  )

# participants ------------------------------------------------------------

select(d, year, i = pid, full_name, gender, starts_with("affiliation")) %>%
  distinct() %>%
  group_by(year) %>%
  group_split() %>%
  map(
    ~ readr::write_tsv(.x, str_c("data/epsa", unique(.x$year), "-participants.tsv"))
  )

# panels ------------------------------------------------------------------

select(d, year, j = session_id, starts_with("session_")) %>%
  rename_with(~ str_replace(.x, "session_", "panel_")) %>%
  add_column(panel_description = NA_character_) %>%
  add_column(notes = NA_character_) %>%
  distinct() %>%
  group_by(year) %>%
  group_split() %>%
  map(
    ~ readr::write_tsv(.x, str_c("data/epsa", unique(.x$year), "-panels.tsv"))
  )

# abstracts ---------------------------------------------------------------

select(d, year, starts_with("abstract_")) %>%
  # remove rows coding for discussants or chairs
  filter(!is.na(abstract_id)) %>%
  distinct() %>%
  group_by(year) %>%
  group_split() %>%
  map(
    ~ readr::write_tsv(.x, str_c("data/epsa", unique(.x$year), "-abstracts.tsv"))
  )

# kthxbye
