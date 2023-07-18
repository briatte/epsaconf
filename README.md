# Data from EPSA conferences, 2019-2023

[![DOI](https://zenodo.org/badge/387525767.svg)](https://zenodo.org/badge/latestdoi/387525767)

This repository contains R code to collect and assemble the full programmes of recent [EPSA](https://epsanet.org/) conferences:

| Conference year                  | GitHub      | Online programme        |
|:---------------------------------|:-----------:|:------------------------|
| [EPSA 2019][y19]                 | [repo][r19] | [Oxford Abstracts][p19] |
| [EPSA 2020][y20] (virtual event) | [repo][r20] | [COMS.events][p20]      |
| [EPSA 2021][y21] (virtual event) | [repo][r21] | [COMS.events][p21]      |
| [EPSA 2022][y22]                 | [repo][r22] | [COMS.events][p22]      |
| [EPSA 2023][y23]                 | [repo][r23] | [Oxford Abstracts][p23] |

[y19]: https://epsanet.org/epsa2019/
[y20]: https://epsanet.org/epsa2020/
[y21]: https://epsanet.org/epsa2021/
[y22]: https://epsanet.org/epsa2022/
[y23]: https://epsanet.org/epsa-2023-programme-committee/

[r19]: https://github.com/briatte/epsa2019
[r20]: https://github.com/briatte/epsa2020
[r21]: https://github.com/briatte/epsa2021
[r22]: https://github.com/briatte/epsa2022
[r23]: https://github.com/briatte/epsa2023

[p19]: https://virtual.oxfordabstracts.com/#/event/public/772/program
[p20]: https://coms.events/EPSA-2020/en/
[p21]: https://coms.events/epsa2021/en/
[p22]: https://coms.events/epsa-2022/en/
[p23]: https://virtual.oxfordabstracts.com/#/event/3738/information

The master dataset [`data/epsa-program.tsv`][prgm] contains all 5 conference years. Details on variables appear in the notes below.

The code starts by importing the conference programme located in each of the repositories listed above. It then applies some corrections to academic affiliations, guesses genders, performs a few more cleaning routines, updates participant hashes, and creates the master dataset. The single-year programmes, with uncorrected academic affiliations, are preserved for reference.

This is __work in progress__. See the [issues](issues) for a list of things that still need fixing. In the unlikely event that you need to run the code on your side (the TSV master dataset should be usable without doing so), please feel free to ask for help if something does not work as expected.

[prgm]: https://github.com/briatte/epsaconf/blob/main/data/epsa-program.tsv

# Data

For each conference year, we collected information on the conference panels, the papers that they hosted, and the individuals involved in either organizing the panels (chairs and discussants) or presenting the papers (authors):

|                  | 2019 | 2020 | 2021 | 2022 | 2023 |
|:-----------------|:----:|:----:|:----:|:----:|:----:|
| Participants (1) | 1318 |  298 |  792 | 1415 | 1863 |
| Affiliations (2) |  328 |  130 |  241 |  348 |  392 |
| Panels           |  186 |   32 |  131 |  228 |  258 |
| Abstracts        |  802 |  136 |  517 |  933 | 1127 |
| Edges (3)        | 1964 |  319 | 1262 | 2285 | 2912 |

1. The names of the participants have not been harmonised across datasets. The data contain 32-bit hashes to identify unique participants _in a single conference year_, based on his or her name and affiliation, in addition to the conference year. You will need to generate new hashes to identify e.g. participants with identical names throughout _all conference years_.
2. Academic affiliations (which are not always academic) have been cleaned and identified with their [ROR][ror] IDs. A few participants have affiliations with no ROR record, and independent researchers have been assigned special value `"(independent)"` as their affiliation.
3. Defined as the presence of a participant `i` in a conference panel `j` as either chair (`c`), discussant (`d`) or presenter (`p`). This is only one of the (one-mode or two-mode, at least) networks that can be built from the data. See the section on networks for further notes.

[ror]: https://ror.org/

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

The `data/` folder also contains two external resources used to fix affiliations: [this spreadsheet of manual checks and corrections to ROR guesses][ror-corrections], and a [ROR data dump](https://ror.readme.io/docs/data-dump) from March 2023.

[ror-corrections]: https://docs.google.com/spreadsheets/d/1DHR7NQCNUOslXO5CA2e9hTla6YWZLPs7Uwqmp-wLATE/edit?usp=sharing

## Variables

Contents of [`data/epsa-program.tsv`][prgm]:

|                     | 2019  | 2020   | 2021  | 2022  | 2023  |
|:--------------------|:-----:|:------:|:-----:|:-----:|:-----:|
| panel id (file)     | x     | x      | x     | x     | x     |
| panel ref           | x     | NA     | NA    | NA    | x (1) |
| panel title         | x     | x      | x     | x     | x     |
| panel track         | x     | x (1)  | NA    | NA    | x     |
| panel type          | x (1) | x      | x     | x     | x (1) |
| panel chairs        | x     | x      | x     | x     | x     |
| panel discussants   | x     | NA (2) | x     | x     | x     |
| abstract id (file)  | x     | x      | x     | x     | x     |
| abstract ref        | x     | x      | x     | x     | x     |
| abstract title      | x     | x      | x     | x     | x     |
| abstract text       | x     | x      | x     | x     | x     |
| abstract topic      | NA    | NA     | x (3) | x (3) | NA    |
| abstract authors    | x     | x      | x     | x     | x     |
| abstract presenters | x     | x      | x     | x     | x     |
| affiliations        | x (4) | x (4)  | x (4) | x (4) | x (4) |
| genders             | x (5) | x (5)  | x (5) | x (5) | x (5) |

1. Contains some missing values (`NA`).
2. There were no discussants that year, only chairs, called 'moderators' in the data.
3. Ues the same values as panel tracks in other years, but varies within each panel.
4. Affiliations are available for chairs, discussants and authors. They have been manually checked and, when possible, matched to [ROR][ror] identifiers (the first affiliation was used when there were more than one). Raw affiliations are available in the single-year programmes.
5. Genders were guessed by [genderize.io](https://genderize.io/), with a few `"unknown"` results, based on the first part of the full names of the participants.

Full-text variables (like titles and abstracts) have been only minimally cleaned to avoid having line breaks and double quotes in the (TSV) data. All other text, punctuation and special characters have been preserved.

## Format

Overview of the [`data/epsa-program.tsv`][prgm] dataset:

```r
library(tidyverse)
glimpse(read_tsv("data/epsa-program.tsv"))
```
```
Rows: 8,742
Columns: 20
$ year              <chr> "2019", "2019", "2019", "2019", "2019", "2019", …
$ session_id        <chr> "4823", "4823", "4823", "4555", "4555", "4555", …
$ session_ref       <chr> "PS1 Roundtable", "PS1 Roundtable", "PS1 Roundta…
$ session_track     <chr> "Political Science as a Discipline", "Political …
$ session_type      <chr> "Roundtable", "Roundtable", "Roundtable", "Panel…
$ session_title     <chr> "Journal Publishing: Finding the Right Outlet fo…
$ pid               <chr> "e04cbb06a9c309fa40dc2d8bc65251d4", "db22ada49c8…
$ full_name         <chr> "Brandon Prins", "Scott Gates", "Debbie Lisle", …
$ gender            <chr> "male", "male", "female", "male", "male", "male"…
$ affiliation_ror   <chr> "University of Tennessee at Knoxville", "Peace R…
$ role              <chr> "c", "d", "p", "c", "d", "p", "p", "p", "p", "p"…
$ presenter         <chr> NA, NA, NA, NA, NA, "y", "y", "y", "n", "y", "n"…
$ abstract_id       <chr> NA, NA, "133452", NA, NA, "86598", "78993", "857…
$ abstract_ref      <chr> NA, NA, "1281", NA, NA, "1157", "80", "549", "54…
$ abstract_title    <chr> NA, NA, "Navigating an R&R Decision", NA, NA, "B…
$ abstract_text     <chr> NA, NA, "My contribution to this roundtable on J…
$ abstract_topic    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
$ affiliation_url   <chr> "https://ror.org/020f3ap87", "https://ror.org/04…
$ affiliation_ccode <chr> "US", "NO", "GB", "GB", "GB", "PT", "CH", "US", …
$ affiliation_cname <chr> "United States", "Norway", "United Kingdom", "Un…
```

See [stage/issues/38](https://github.com/briatte/stage/issues/38) and [the related wiki page](https://github.com/briatte/stage/wiki/Format-des-donn%C3%A9es) for details (the links point to a private repository, sorry).

## Unique identifiers (UIDs)

Participants (`pid`):

- 2019: `dc5d...7ff5` (32-bit hashes)
- 2020: `2b94...d199` (32-bit hashes)
- 2021: `bd0f...e19e` (32-bit hashes)
- 2022: `1a89...5098` (32-bit hashes)
- 2023: `6f5e...4b74` (32-bit hashes)

Hashes are based on names, affiliations and conference year, and so are unique at that level. Names might contain homonyms, and affiliations are not stable from a conference year to the other.

Panels (`session_id`_):

- 2019: `4555` (fixed-length, 4 digits)
- 2020: `20`, `212` (variable-length, 2-3 digits)
- 2021: `3`, `84`, `129` (variable-length, 1-3 digits)
- 2022: `9`, `11`, `109` (variable-length, 1-3 digits)
- 2023: `74640` (fixed-length, 5 digits)

Panel UIDs are based on their Web page identifiers rather than on their conference identifiers (`session_ref`).

Abstracts (`abstract_id`):

- 2019: `133452`, `87064` (variable-length, 5-6 digits)
- 2020: `0008`, `0009` (fixed-length, sequential, left-padded)
- 2021: `0069`, `0075` (fixed-length, sequential, left-padded)
- 2022: `0303`, `0304` (fixed-length, sequential, left-padded)
- 2023: `1`, `97`, `104`, `1043` (variable-length, 1-4 digits)

Abstract UIDs are based on their Web page identifiers rather than on their conference identifiers (`abstract_ref`).

## Participant roles

- 2019: `c`, `d`, `p`
- 2020: `c`, `p` (no discussants that year, only chairs/moderators)
- 2021: `c`, `d`, `p`
- 2022: `c`, `d`, `p`
- 2023: `c`, `d`, `p`

Almost all panels have a single chair `c` and a single discussant `d`, but there are many other combinations between 0-2 chairs and 0-2 discussants:

```r
read_tsv("data/epsa-program.tsv") %>% 
  group_by(year, session_id) %>% 
  summarise(n_chairs = n_distinct(pid[ role == "c" ]), 
            n_discus = n_distinct(pid[ role == "d" ])) %>%
  count(n_chairs, n_discus) %>% 
  print(n = Inf)
```

The number of authors/presenters `p` per panel is unbounded. In most cases, they correspond to the authors/presenters of 4 to 6 papers per panel:

```r
# number of authors/presenters
read_tsv("data/epsa-program.tsv") %>% 
  group_by(year, session_id) %>% 
  summarise(na = n_distinct(pid[ role == "p" ]) %>% 
              cut(c(0:99, Inf), right = FALSE)) %>%
  count(na) %>% 
  print(n = Inf)

# number of papers per panel
read_tsv("data/epsa-program.tsv") %>% 
    group_by(year, session_id) %>% 
    summarise(n_papers = n_distinct(abstract_id)) %>% 
    ungroup() %>% 
    count(n_papers)
```

The additional `presenter` variable indicates whether the author/presenter of an abstract was formally listed as a presenter in the programme (`y` for yes, `n` for no, `NA` for chairs and discussants).

# All years

```r
library(tidyverse)

# 5 conference years
d <- read_tsv("data/epsa-program.tsv", col_types = cols(.default = "c"))

# ... 3515 conference papers
nrow(drop_na(distinct(d, year, abstract_id), abstract_id))

# ... 835 conference panels
nrow(drop_na(distinct(d, year, session_id), session_id))

# ... 8742 conference participations as chair, discussant or author/presenter
nrow(d)

# ... 3892 unique participants
n_distinct(pull(bind_rows(d), full_name))
```

# Network constructors

```r
library(igraph)
library(tidyverse)

# two-mode (participant-panel), unweighted
fs::dir_ls("data", regexp = "epsa\\d{4}-edges") %>% 
  map(read_tsv, col_types = cols(.default = "c")) %>% 
  map(select, -year) %>% 
  map(~ add_count(group_by(.x, j))) %>% # number of participants per panel
  map(igraph::graph_from_data_frame)

# one-mode (participant-to-participant), weighted by shared panel appearances
fs::dir_ls("data", regexp = "epsa\\d{4}-edges") %>%
  map(read_tsv, col_types = cols(.default = "c")) %>%
  map(select, i, j) %>% 
  # treating all participations to a panel (c, d, p) as a single tie
  map(distinct) %>% 
  # link participants i.x to participants i.y over panels j
  map2(., ., full_join, by = "j") %>% 
  # remove self-ties and de-duplicate i -> j and j -> i
  map(filter, i.x < i.y) %>% 
  map(select, -j, i = i.x, j = i.y) %>% 
  # edge weights n = number of shared panel appearances (1 to 3)
  map(count, i, j, sort = TRUE) %>% 
  map(igraph::graph_from_data_frame, directed = FALSE)
```

Feel free to open an issue to discuss additional constructors.
