Code to collect and assemble the full programmes of three recent [EPSA](https://epsanet.org/) conferences:

- [`epsa2019`](https://github.com/briatte/epsa2019)
- [`epsa2020`](https://github.com/briatte/epsa2020) (virtual event)
- [`epsa2021`](https://github.com/briatte/epsa2021) (virtual event)

# TODO

- [ ] Unify repos
- [ ] Decide on a common format for TSV exports
- [ ] Minimal columns to get:

|                 | [2019](#) |  [2020](https://github.com/briatte/epsa2020/blob/master/data/abstracts.tsv) |  [2021](https://github.com/briatte/epsa2021/blob/main/data/abstracts.tsv) |
|:-----------------|:--------:|:------:|:-------:|
panel id (file)    |  x       |  x     |  x      |
panel ref          |  x       |  ??    |  ??     |
panel title        |  x       | TODO   | TODO    |
panel track        |  x       | ????   | ????    |
chair              |  x       | TODO   | TODO    |
chair affiliation  |  x       | TODO   | TODO    |
discussant         |  x       | TODO   | TODO    |
discussant affil.  |  x       | TODO   | TODO    |
abstract id (file) |  x       |  x     |  x      |
abstract ref       |  x       |  ??    |  ?? (1) |
abstract title     |  x       | TODO   |  x      |
abstract text      |  x       | TODO   | TODO    |
presenters         |  x       | TODO   |  x      |
authors            |  x       |  x     |  x      |
affiliations       |  x       |  x (2) |  x (2)  |
topic keywords     |          |        |  x      |

(1) in `paper_ref`
(2) __TODO:__ clearly assign to authors (use abstracts)

## Data formats

See [stage/issues/38](https://github.com/briatte/stage/issues/38).

Example format from APSA:

| year | session | type	| session_title	| paper	| paper_title	| abstract | pid | full_name | first_name | affiliation | role |
|------|---------|------|---------------|-------|-------------|----------|-----|-----------|------------|-------------|------|
| 2015 | 1000053 | Full Panel	| Authoritarianism, [...] | NA | NA | NA | 5650271 | Jillian M. Schwedler | Jillian | Hunter College | c
| 2015 | 1000053 | Full Panel	| Authoritarianism, [...] | NA | NA | NA | 5660835 | Tarek E. Masoud | Tarek | Harvard University | d
| 2015 | 1000053 | Full Panel	| Authoritarianism, [...] | 1000057 | Judiciary-Police Relations [...] | During [...] | 5643721 | Dina I. Rashed | Dina | NA | p

