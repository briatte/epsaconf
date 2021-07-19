# TODO

Unify repos:

- `epsa2019`
- `epsa2020`
- `epsa2021`

... and decide on a common format for TSV exports.

Minimal columns to get:

|                 | 2019     | 2020 | 2021    |
|:----------------|:--------:|:----:|:-------:|
panel id          |  x       |  x   |  x      |
panel title       |  x       | TODO | TODO    |
chair             |  x       | TODO | TODO    |
chair affiliation |  x       | TODO | TODO    |
discussant        |  x       | TODO | TODO    |
discussant affil. |  x       | TODO | TODO    |
abstract id       |  x       |  x   |  x (1)  |
abstract title    |  x       | TODO |  x      |
presenters        | TODO (3) | TODO |  x      |
authors           |  x       |  x   |  x      |
affiliations      |  x (2)   |  x   |  x      |
topic             |          |      |  x      |

(1) in `paper_ref`
(2) in `abstract_authors`
(3) in abstracts, presenters seem to be <u>underlined</u>

Sources:

- [EPSA 2019]()
- [EPSA 2020](https://github.com/briatte/epsa2020/blob/master/data/abstracts.tsv)
- [EPSA 2021](https://github.com/briatte/epsa2021/blob/main/data/abstracts.tsv)
