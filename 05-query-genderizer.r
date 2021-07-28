# matches 'de', 'van', 'von der', or 'X i', or 'X da'
r <- "^[DdLl][aei]|[Vv][ao]n(\\sder)?$|.*\\si$|.*\\s[Dd][aei]"

# extract (likely) first names --------------------------------------------

# simple heuristics to get first names from (mostly) Western names
d <- fs::dir_ls("data", regexp = "participants") %>%
  map(readr::read_tsv, col_types = cols(.default = "c")) %>%
  map_dfr(select, full_name) %>%
  distinct() %>%
  mutate(
    # remove brackets in 'Alice (Yunyun) Smith'
    name = str_remove_all(full_name, "\\(|\\)") %>%
      # remove initials in "Alex C. Smith"
      str_remove_all("[A-Z]\\.\\s") %>%
      # remove initials in "Alex C Smith"
      str_replace_all("\\s([A-Z])\\s", " "),
    first = str_remove(name, "\\s.*"),
    last = str_remove(name, ".*\\s"),
    mid = str_remove(name, first) %>%
      str_remove(last) %>%
      str_squish()
  ) %>%
  # handle 'X de Y', 'X Y da Z' and similar cases
  mutate(
    last = if_else(str_detect(mid, r), str_c(mid, " ", last), last),
    mid = if_else(str_detect(mid, r), "", mid)
  ) %>%
  select(full_name, name, first_name = first, mid, family_name = last) # %>%
  # arrange(first_name) %>%
  # count(first_name, sort = TRUE) %>%
  # filter(str_length(mid) > 0) %>%
  # count(mid, sort = TRUE) %>%
  # print(n = Inf)
  # print(n = 10)

# separate `mid` into likely first and last names
d <- d %>%
  mutate(
    mid_first = if_else(mid %in% d$first_name, mid, ""),
    mid_last = if_else(mid_first %in% "", mid, "")
  ) %>%
  select(full_name, name, first_name, mid_first, mid_last, family_name)

n <- select(d, first_name) %>%
  # just to be sure
  filter(!is.na(first_name)) %>%
  distinct()

# guess names via genderizer.io -------------------------------------------
cat("Querying genderizer.io for", nrow(n), "first names...\n")

f <- "data/genderizer-results.tsv"
if (!fs::file_exists(f)) {

  # init
  n %>%
    # name as sent to genderizer.io (sanitized)
    add_column(name = NA_character_) %>%
    add_column(gender = NA_character_) %>%
    add_column(probability = NA_real_) %>%
    add_column(count = NA_integer_) %>%
    write_tsv(f)

}

repeat {

  # sample 10 names (batch limit)
  g <- readr::read_tsv(f, col_types = "cccdi") %>%
    filter(is.na(gender)) %>%
    slice_sample(n = 10)

  r <- g$first_name %>%
    # sanitize: remove non-ASCII characters (as a precaution)
    stringi::stri_trans_general(id = "Latin-ASCII") %>%
    str_flatten(collapse = "&name[]=") %>%
    str_c("https://api.genderize.io/?name[]=", .)

  cat("Guessing", str_trunc(str_c(g$first_name, collapse = ", "), 50))
  if (!nrow(g)) {

    cat("... done\n")
    break

  }

  r <- try(httr::GET(r))

  if("try-error" %in% class(r)) {

    cat(": network error\n")
    break

  }

  # will fail around 1,000 requests/day (API limit)
  if(status_code(r) != 200) {

    cat(":", content(r)$error, "\n")
    break

  }

  Sys.sleep(1.5)

  r <- content(r, as = "text") %>%
    fromJSON(flatten = TRUE) %>%
    # denote unknown genders as missing
    mutate(gender = str_replace_na(gender, "unknown")) %>%
    add_column(first_name = g$first_name, .before = 1)

  # reload names list
  g <- readr::read_tsv(f, col_types = "cccdi")

  # collate to names list
  g <- bind_rows(
    # new additions
    semi_join(r, g, by = "first_name"),
    # not yet queried
    anti_join(g, r, by = "first_name")
  ) %>%
    arrange(first_name)

  cat("", sum(!is.na(g$gender)), "guessed,", sum(is.na(g$gender)), "left\n")
  readr::write_tsv(g, f)

}

g <- readr::read_tsv(f, col_types = "cccdi")

cat(
  "Genders:",
  sum(g$gender %in% "female"), "females,",
  sum(g$gender %in% "male"), "males,",
  sum(is.na(g$gender)), "missing,",
  sum(g$gender %in% "unknown"), "unknown.\n"
)

# few ambiguous results
filter(g, probability > 0, probability < 0.9)

# very few unknowns
filter(g, probability == 0)

# very hacky but works
