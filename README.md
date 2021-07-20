Code to collect and assemble the full programmes of three recent [EPSA](https://epsanet.org/) conferences:

- [`epsa2019`](https://github.com/briatte/epsa2019)
- [`epsa2020`](https://github.com/briatte/epsa2020) (virtual event)
- [`epsa2021`](https://github.com/briatte/epsa2021) (virtual event)

# TODO

- [ ] Unify repos
- [ ] Decide on a common format for TSV exports
- [ ] Minimal columns to get:

|                 | [2019](#)     | [2020](https://github.com/briatte/epsa2020/blob/master/data/abstracts.tsv) | [2021](https://github.com/briatte/epsa2021/blob/main/data/abstracts.tsv)    |
|:----------------|:--------:|:----:|:-------:|
panel id          |  x       |  x   |  x      |
panel title       |  x       | TODO | TODO    |
chair             |  x       | TODO | TODO    |
chair affiliation |  x       | TODO | TODO    |
discussant        |  x       | TODO | TODO    |
discussant affil. |  x       | TODO | TODO    |
abstract id       |  x       |  x   |  x (1)  |
abstract title    |  x       | TODO |  x      |
abstract (text)   |  x       | TODO | TODO    |
presenters        |  x       | TODO |  x      |
authors           |  x       |  x   |  x      |
affiliations      |  x       |  x (2) |  x (2) |
topic             |          |      |  x      |

(1) in `paper_ref`
(2) TODO: clearly assign to authors
