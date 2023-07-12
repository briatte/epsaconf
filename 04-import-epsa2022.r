library(tidyverse)

fs::dir_create("data")

f <- "data/epsa2022-program.tsv"
if (!fs::file_exists(f)) {

  "https://raw.githubusercontent.com/briatte/epsa2022/master/data/program.tsv" %>%
    download.file(f, mode = "wb")

}

d <- readr::read_tsv(f, col_types = "ccccccccccccc")

# edges -------------------------------------------------------------------

# year, i = participant UID, j = panel UID, role

e <- select(d, i = pid, j = session_id, role) %>%
  add_column(year = 2022L, .before = 1)

# [NOTE]
#
# edges sometimes repeat as some authors have 2+ papers in a same panel
# - e.g. Goerres in session 131, abstracts 0642 and 0658
#
# happens only to presenters, not chairs or discussants
stopifnot(e$role[ duplicated(e) ] == "p")
#
# happens quite a few times (n = 36 duplicates)
e[ duplicated(e), ]
#
# relative frequency: 3.9% of all authors (n = 1842)
2 * sum(duplicated(e)) / sum(e$role == "p")

# export
readr::write_tsv(e, "data/epsa2022-edges.tsv")

# participants ------------------------------------------------------------

select(d, i = pid, full_name, affiliation) %>%
  add_column(year = 2022L, .before = 1) %>%
  add_column(first_name = NA_character_, .after = "full_name") %>%
  add_column(family_name = NA_character_, .after = "first_name") %>%
  add_column(gender = NA_character_) %>%
  # [NOTE] participants repeat due to multiple roles or contributions
  distinct() %>%
  # export
  readr::write_tsv("data/epsa2022-participants.tsv")

# panels ------------------------------------------------------------------

select(d, j = session_id, starts_with("session_")) %>%
  rename_with(~ str_replace(.x, "session_", "panel_")) %>%
  add_column(year = 2022L, .before = 1) %>%
  add_column(panel_ref = NA_character_, .after = "j") %>%
  add_column(panel_track = NA_character_) %>%
  add_column(panel_description = NA_character_) %>%
  add_column(notes = NA_character_) %>%
  # [NOTE] panels repeat once per participant
  distinct() %>%
  # export
  readr::write_tsv("data/epsa2022-panels.tsv")

# abstracts ---------------------------------------------------------------

select(d, starts_with("abstract_")) %>%
  # remove rows coding for discussants or chairs
  filter(!is.na(abstract_id)) %>%
  add_column(year = 2022L, .before = 1) %>%
  distinct() %>%
  # export
  readr::write_tsv("data/epsa2022-abstracts.tsv")

# kthxbye
