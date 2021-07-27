Code to collect and assemble the full programmes of three recent [EPSA](https://epsanet.org/) conferences:

- [`epsa2019`](https://github.com/briatte/epsa2019)
- [`epsa2020`](https://github.com/briatte/epsa2020) (virtual event)
- [`epsa2021`](https://github.com/briatte/epsa2021) (virtual event)

This repository is __work in progress__, and some links point to a private repository.

# TODO

See the [issues](issues) for further details.

|                   | [2019][2019] | [2020][2020] | [2021][2021] |
|:------------------|:------------:|:------------:|:------------:|
panel id (file)     |  x           |  x           |  x           |
panel ref           |  x           |  NA          |  ??          |
panel title         |  x           |  x           | TODO         |
panel track         |  x           |  x (3)       | ????         |
chair               |  x           |  x           | TODO         |
chair affiliation   |  x           |  x           | TODO         |
discussant          |  x           |  NA (4)      | TODO         |
discussant affil.   |  x           |  NA (4)      | TODO         |
abstract id (file)  |  x           |  x           |  x           |
abstract ref        |  x           |  x           |  ?? (1)      |
abstract title      |  x           |  x           |  x           |
abstract text       |  x           |  x           | TODO         |
abstract presenters |  x           |  x           |  x           |
abstract authors    |  x           |  x           |  x           |
author affiliations |  x           |  x (2)       |  x (2)       |
topic keywords      |  NA          | NA           |  x           |
first names         |  NA          | NA           | NA           |
family names        |  NA          | NA           | NA           |
gender              |  NA          | NA           | NA           |

1. in `paper_ref`
2. __TODO:__ clearly assign to authors (use abstracts)
3. contains missing values
4. no discussants that year (only chairs, alternatively called 'moderators')

[2019]: https://github.com/briatte/epsa2019/blob/main/data/program.tsv
[2020]: https://github.com/briatte/epsa2020/blob/master/data/abstracts.tsv
[2021]: https://github.com/briatte/epsa2021/blob/main/data/abstracts.tsv

## Data formats

See [stage/issues/38](https://github.com/briatte/stage/issues/38) and [the related wiki page](https://github.com/briatte/stage/wiki/Format-des-donn%C3%A9es).

Example format from EPSA 2019:

```
Rows: 1,964
Columns: 13
$ session_id          <chr> "4823", "4823", "4823", "4555", "4555", "4555", …
$ session_ref         <chr> "PS1 Roundtable", "PS1 Roundtable", "PS1 Roundta…
$ session_track       <chr> "Political Science as a Discipline", "Political …
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

__TODO:__ extract `first_name` and `family_name`, and guess `gender`.

## Descriptives

Numbers of rows:

|                  | 2019 | 2020 | 2021 |
|:-----------------|:----:|:----:|:----:|
| Edges            | 1964 |  319 |      |
| Participants (1) | 1318 |  298 |      |
| Panels           |  186 |   32 |      |
| Abstracts        |  802 |  136 |      |

1. before fixing names/affiliations

```r
library(tidyverse)
fs::dir_ls("data") %>%
  map(read_tsv, col_types = cols(.default = "c")) %>%
  map_int(nrow)
```

## UID formats

Participants:

- 2019: `dc5d...7ff5` (32-bit, computed before fixing names/affiliations)
- 2020: `2b94...d199` (32-bit, computed before fixing names/affiliations)

Panels:

- 2019: `4555` (fixed-length, 4 digits)
- 2020: `20`, `212` (variable-length, 2-3 digits)

Abstracts:

- 2019: `133452`, `87064` (variable-length, 5-6 digits)
- 2020: `0008`, `0009` (fixed-length, sequential, left-padded)

## Roles

- 2019: `c`, `d`, `p`
- 2020: `c`, `p` (no discussants, only chairs/moderators)

# Combine all years

```r
library(tidyverse)

bind_rows(
  read_tsv("data/epsa2019-program.tsv", col_types = cols(.default = "c")) %>% 
    add_column(year = 2019L, .before = 1),
  read_tsv("data/epsa2020-program.tsv", col_types = cols(.default = "c")) %>% 
    add_column(year = 2020L, .before = 1)
)
```
