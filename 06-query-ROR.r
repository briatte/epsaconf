library(tidyverse)
library(httr)
library(jsonlite)

a <- fs::dir_ls("data", regexp = "epsa\\d{4}-participants") %>%
  map(readr::read_tsv, col_types = cols(.default = "c")) %>%
  map_dfr(select, affiliation) %>%
  filter(!is.na(affiliation)) %>%
  distinct()

cat("Querying ROR for", nrow(a), "affiliations")

d <- a %>%
  mutate(
    url = "https://api.ror.org/organizations?affiliation=" %>%
      # replace spaces
      str_c(str_replace_all(affiliation, "\\s", "+")) %>%
      # sanitize: remove non-ASCII characters (otherwise error 400)
      stringi::stri_trans_general(id = "Latin-ASCII"),
    ror = list(NA)
  )

# remove affiliations that have already been parsed
f <- "data/ror-results.rds"
if (fs::file_exists(f)) {

  d <- anti_join(d, readr::read_rds(f), by = "affiliation")
  cat(" (skipping", nrow(a) - nrow(d), "already queried)...\n")

} else {

  cat("...\n")

}

cat("\n")

for (i in nrow(d):1) {

  cat(
    str_pad(i, 4),
    str_pad(str_trunc(d$affiliation[ i ], 50), 50, side = "right"),
    "..."
  )

  r <- try(httr::GET(d$url[ i ]), silent = TRUE)

  if ("try-error" %in% class(r)) {
    cat("ERROR\n")
    next
  }

  Sys.sleep(0.75)

  if (httr::status_code(r) != 200) {

    cat(" error", httr::status_code(r), "\n")
    next

  } else {

    cat(" OK\n")
    d$ror[ i ] <- httr::content(r, as = "text", encoding = "UTF-8")

  }

}

# subset to valid results
d <- mutate(d, ror_results = map_lgl(ror, is.character)) %>%
  filter(ror_results) %>%
  mutate(
    # [NOTE] we used to `map_chr` here, and then `as.integer` the result, but
    # it now seems safe to expect an integer straight away
    ror_results = map_int(ror, ~ jsonlite::fromJSON(.x, flatten = TRUE) %>%
                            magrittr::extract2("number_of_results"))
  )

# export full results -----------------------------------------------------

if (fs::file_exists(f)) {

  # append
  readr::write_rds(bind_rows(d, readr::read_rds(f)), f, compress = "gz")

} else {

  # initialize
  readr::write_rds(d, f, compress = "gz")

}

# export results overview -------------------------------------------------

d <- readr::read_rds(f)

cat("\nExporting overview of", nrow(d), "results on disk...")

# results overview
r <- map_dfr(d$ror[ d$ror_results > 0 ],
  ~ jsonlite::fromJSON(.x, flatten = TRUE) %>%
    magrittr::extract2("items") %>%
    slice(1) %>%
    select(
      # confidence
      chosen, score, matching_type,
      # information
      organization.name, organization.id, organization.country.country_name
    )
)

# ror-corrections (Google Sheets): RAW sheet = TSV below
f <- "data/ror-corrections.tsv"

# affiliations: queried, successfully
d <- bind_cols(select(filter(d, ror_results > 0), -ror), r) %>%
  # add queried, not successfully
  bind_rows(select(filter(d, ror_results == 0), -ror)) %>%
  # add not queried yet
  full_join(a, ., by = "affiliation")

if (!fs::file_exists(f)) {

  # initialize file
  arrange(d, affiliation) %>%
    mutate(rowid = row_number(), .before = 1) %>%
    readr::write_tsv(f, na = "")

} else {

  # new rows to add at end of Google Sheets
  anti_join(arrange(d, affiliation), read_tsv(f)) %>%
    bind_rows(read_tsv(f), .) %>%
    # excessively safe append of additional row numbers
    mutate(rowid = if_else(is.na(rowid), row_number(), rowid)) %>%
    readr::write_tsv(f, na = "")

}

cat(" done.\n")

# kthxbye
