# Program data from EPSA conferences, 2019-2023

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8151267.svg)](https://doi.org/10.5281/zenodo.8151267)

This repository contains R code to collect and assemble the full programmes of recent [EPSA](https://epsanet.org/) conferences:

- [EPSA 2019](https://github.com/briatte/epsa2019)
- [EPSA 2020](https://github.com/briatte/epsa2020) (virtual event)
- [EPSA 2021](https://github.com/briatte/epsa2021) (virtual event)
- [EPSA 2022](https://github.com/briatte/epsa2022)
- [EPSA 2023](https://github.com/briatte/epsa2023)

The master dataset `data/epsa-program.tsv` contains all 5 conference years. Details on variables appear in the notes below.

The `data/` folder contains two external resources used to fix affiliations: [this spreadsheet of manual checks and corrections to ROR guesses][ror-corrections], and a [ROR data dump](https://ror.readme.io/docs/data-dump) from March 2023.

[ror-corrections]: https://docs.google.com/spreadsheets/d/1DHR7NQCNUOslXO5CA2e9hTla6YWZLPs7Uwqmp-wLATE/edit?usp=sharing

This is __work in progress__, and some links point to a private repository. See the [issues](issues) for a list of things that need fixing.

# Data

|                  | 2019 | 2020 | 2021 | 2022 | 2023 |
|:-----------------|:----:|:----:|:----:|:----:|:----:|
| Participants (1) | 1318 |  298 |  792 | 1415 | 1863 |
| Affiliations (2) |  328 |  130 |  241 |  348 |  392 |
| Panels           |  186 |   32 |  131 |  228 |  258 |
| Abstracts        |  802 |  136 |  517 |  933 | 1127 |
| Edges (3)        | 1964 |  319 | 1262 | 2285 | 2912 |

1. Names have not been harmonised across datasets.
2. Affiliations have been cleaned and identified with their [ROR](https://ror.org/) IDs.
3. Defined as the presence of a participant `i` in a conference panel `j` as either chair (`c`), discussant (`d`) or presenter (`p`).

```r
library(tidyverse)

# participants, panels, abstracts and edges
fs::dir_ls("data", regexp = "epsa\\d{4}") %>%
  map(read_tsv, col_types = cols(.default = "c")) %>%
  map_int(nrow)

# unique affiliations
fs::dir_ls("data", regexp = "epsa\\d{4}-participants") %>%
  map(read_tsv, col_types = cols(.default = "c")) %>%
  map_int(~ n_distinct(.x$affiliation_ror))
```

## Variables

|                   | [2019][19] | [2020][20] | [2021][21] | [2022][22] | [2023][23] |
|:------------------|:----------:|:----------:|:----------:|:----------:|:----------:|
panel id (file)     |  x         |  x         |  x         |  x         |  x         |
panel ref           |  x         |  NA        |  NA        |  NA        |  x (1)     |
panel title         |  x         |  x         |  x         |  x         |  x         |
panel track         |  x         |  x (1)     |  NA        |  NA        |  x         |
panel type          |  x (1)     |  x         |  x         |  x         |  x (1)     |
chair               |  x         |  x         |  x         |  x         |  x         |
chair affiliation   |  x         |  x         |  x         |  x         |  x         |
discussant          |  x         |  NA (2)    |  x         |  x         |  x         |
discussant affil.   |  x         |  NA (2)    |  x         |  x         |  x         |
abstract id (file)  |  x         |  x         |  x         |  x         |  x         |
abstract ref        |  x         |  x         |  x         |  x         |  x         |
abstract title      |  x         |  x         |  x         |  x         |  x         |
abstract text       |  x         |  x         |  x         |  x         |  x         |
abstract presenters |  x         |  x         |  x         |  x         |  x         |
abstract topic      |  NA        |  NA        |  x (3)     |  x (3)     |  NA        |
abstract authors    |  x         |  x         |  x         |  x         |  x         |
author affiliations |  x         |  x         |  x         |  x         |  x         |
first names         |  NA        |  NA        |  NA        |  NA        |  NA        |
family names        |  NA        |  NA        |  NA        |  NA        |  NA        |
gender              |  NA        |  NA        |  NA        |  NA        |  NA        |

1. contains missing values
2. no discussants that year (only chairs, alternatively called 'moderators')
3. uses the same values as panel tracks in other years, but varies within each panel

[19]: https://github.com/briatte/epsa2019/blob/main/data/program.tsv
[20]: https://github.com/briatte/epsa2020/blob/master/data/program.tsv
[21]: https://github.com/briatte/epsa2021/blob/main/data/program.tsv
[22]: https://github.com/briatte/epsa2022/blob/main/data/program.tsv
[23]: https://github.com/briatte/epsa2023/blob/main/data/program.tsv

## Format

See [stage/issues/38](https://github.com/briatte/stage/issues/38) and [the related wiki page](https://github.com/briatte/stage/wiki/Format-des-donn%C3%A9es).

Example data from EPSA 2019:

```
Rows: 1,964                                                                                                      
Columns: 14
$ session_id          <chr> "4823", "4823", "4823", "4555", "4555", "4555", …
$ session_ref         <chr> "PS1 Roundtable", "PS1 Roundtable", "PS1 Roundta…
$ session_track       <chr> "Political Science as a Discipline", "Political …
$ session_type        <chr> "Roundtable", "Roundtable", "Roundtable", "Panel…
$ session_title       <chr> "Journal Publishing: Finding the Right Outlet fo…
$ pid                 <chr> "dc5d8ad76f91cd91d2821d1a980a7ff5", "25910517749…
$ full_name           <chr> "Brandon Prins", "Scott Gates", "Debbie Lisle", …
$ affiliation         <chr> "University of Tennessee, Knoxville, USA", "Peac…
$ role                <chr> "c", "d", "p", "c", "d", "p", "p", "p", "p", "p"…
$ abstract_id         <chr> NA, NA, "133452", NA, NA, "86598", "78993", "857…
$ abstract_ref        <chr> NA, NA, "1281", NA, NA, "1157", "80", "549", "54…
$ abstract_title      <chr> NA, NA, "Navigating an R&R Decision", NA, NA, "B…
$ abstract_text       <chr> NA, NA, "My contribution to this roundtable on J…
$ abstract_presenters <chr> NA, NA, NA, NA, NA, "Ricardo Carvalho", "André W…
```

## Identifiers (UIDs)

Participants:

- 2019: `dc5d...7ff5` (32-bit hashes)
- 2020: `2b94...d199` (32-bit hashes)
- 2021: `bd0f...e19e` (32-bit hashes)
- 2022: `1a89...5098` (32-bit hashes)
- 2023: `6f5e...4b74` (32-bit hashes)

Hashes are based on names, affiliations (replaced with `"NA"` if missing) and conference year.

Panels:

- 2019: `4555` (fixed-length, 4 digits)
- 2020: `20`, `212` (variable-length, 2-3 digits)
- 2021: `3`, `84`, `129` (variable-length, 1-3 digits)
- 2022: `9`, `11`, `109` (variable-length, 1-3 digits)
- 2023: `74640` (fixed-length, 5 digits)

Panel UIDs are based on their Web page identifiers rather than on their conference identifiers.

Abstracts:

- 2019: `133452`, `87064` (variable-length, 5-6 digits)
- 2020: `0008`, `0009` (fixed-length, sequential, left-padded)
- 2021: `0069`, `0075` (fixed-length, sequential, left-padded)
- 2022: `0303`, `0304` (fixed-length, sequential, left-padded)
- 2023: `1`, `97`, `104`, `1043` (variable-length, 1-4 digits)

Abstract UIDs are based on their Web page identifiers rather than on their conference identifiers.

## Roles

- 2019: `c`, `d`, `p`
- 2020: `c`, `p` (no discussants that year, only chairs/moderators)
- 2021: `c`, `d`, `p`
- 2022: `c`, `d`, `p`
- 2023: `c`, `d`, `p`

# All years

```r
library(tidyverse)

# 5 conference years
d <- read_tsv("data/epsa-program.tsv", col_types = cols(.default = "c"))

# ... 3515 conference papers
nrow(drop_na(distinct(d, year, abstract_id), abstract_id))

# ... 835 conference panels
nrow(drop_na(distinct(d, year, session_id), session_id))

# ... 8742 conference participations as chair, discussant or presenter
nrow(d)

# ... 3892 unique participants
n_distinct(pull(bind_rows(d), full_name))
```
