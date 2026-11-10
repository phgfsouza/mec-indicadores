# Constância das características dos cursos no Censo da Educação Superior

## Escopo e critérios

Esta análise usa `data/clean/ces_cursos.parquet`, arquivo processado por `code/01-preparacao.R`, com observações de 2010 a 2024. Foram examinadas todas as 21 variáveis que não começam com `qt_`. O arquivo contém 3.796.169 linhas, 66.881 códigos de curso e 563.752 combinações distintas de `co_curso` e `ano`. Desses cursos, 62.248 aparecem em pelo menos dois anos.

Uma variável é **constante por `co_curso`** se todas as linhas daquele curso, em todos os anos disponíveis, têm o mesmo valor. Ela é **constante por `co_curso` + `ano`** se todas as linhas de cada combinação de curso e ano têm o mesmo valor. Nesta verificação estrita, `NA` conta como valor distinto de qualquer valor preenchido. Cursos observados em apenas um ano também entram na verificação por `co_curso` + `ano`.

## Resultado principal

- **Constantes para cada `co_curso` em todo o arquivo:** `co_curso`, `tp_modalidade_ensino` e `tp_nivel_academico`.
- **Constantes para cada combinação `co_curso` + `ano` em todo o arquivo:** `ano`, `co_ies`, `no_curso`, `co_curso`, `co_cine_area_geral`, `no_cine_area_geral`, `tp_grau_academico`, `in_gratuito`, `tp_modalidade_ensino` e `tp_nivel_academico`.
- **Não constantes nem para cada combinação `co_curso` + `ano`:** `tp_dimensao` e as dez variáveis geográficas terminadas em `_curso` listadas na tabela abaixo.

`ano` é constante por `co_curso` + `ano` por definição, mas varia para todo curso observado em mais de um ano. `co_curso` é constante nos dois níveis por definição.

## Resultado por variável

A segunda coluna conta, entre os **62.248 cursos presentes em mais de um ano**, quantos têm pelo menos dois valores distintos considerando todas as suas linhas. A terceira conta, entre as **563.752 combinações de curso e ano**, quantas têm pelo menos dois valores distintos dentro da própria combinação. Zero significa constância no respectivo nível; as contagens da segunda coluna não incluem cursos observados em um único ano.

| Variável | Cursos com valores distintos | Combinações `co_curso` + `ano` com valores distintos |
|---|---:|---:|
| `cod_regiao_curso` | 11.385 | 63.117 |
| `nome_regiao_curso` | 11.385 | 63.117 |
| `cod_uf_curso` | 11.385 | 63.117 |
| `nome_uf_curso` | 11.385 | 63.117 |
| `cod_meso_amc_curso` | 11.428 | 63.117 |
| `nome_meso_amc_curso` | 11.428 | 63.117 |
| `cod_micro_amc_curso` | 11.467 | 63.117 |
| `nome_micro_amc_curso` | 11.467 | 63.117 |
| `cod_muni_amc_curso` | 11.519 | 63.117 |
| `nome_muni_amc_curso` | 11.519 | 63.117 |
| `ano` | 62.248 | 0 |
| `tp_dimensao` | 11.385 | 63.109 |
| `co_ies` | 1.444 | 0 |
| `no_curso` | 2.884 | 0 |
| `co_curso` | 0 | 0 |
| `co_cine_area_geral` | 245 | 0 |
| `no_cine_area_geral` | 245 | 0 |
| `tp_grau_academico` | 409 | 0 |
| `in_gratuito` | 969 | 0 |
| `tp_modalidade_ensino` | 0 | 0 |
| `tp_nivel_academico` | 0 | 0 |

## Observações para interpretação

`no_cine_area_geral` **não é invariante por curso**: ela e `co_cine_area_geral` mudam em 245 cursos, embora sejam constantes dentro de cada combinação de curso e ano. Por exemplo, o curso `631` passa da área geral 6 em 2010–2023 para a área geral 7 em 2024. Dos 245 cursos com mudança de área, 208 apresentam uma transição em 2024.

As variáveis geográficas e `tp_dimensao` podem diferir **dentro do mesmo curso e ano**. Assim, uma diferença nessas variáveis não deve ser interpretada automaticamente como mudança temporal. Nas dez variáveis geográficas, 11.385 cursos presentes em mais de um ano combinam valores ausentes e preenchidos; em parte deles também há dois ou mais valores preenchidos distintos.

Em `tp_grau_academico`, 409 cursos presentes em mais de um ano têm valores distintos na verificação que inclui `NA`; 69 deles têm dois ou mais valores **preenchidos** distintos. Os outros casos de diferença envolvem ausência de informação.

Esta é uma verificação do arquivo processado existente. O script de preparação não foi reexecutado e nenhum dado foi alterado.
