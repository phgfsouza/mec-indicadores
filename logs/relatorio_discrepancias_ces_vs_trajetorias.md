# Diagnóstico das discrepâncias entre `ces_cursos` e `traj`

## Escopo e método

Este relatório examina a construção dos dois objetos em [`code/01-preparacao.R`](../code/01-preparacao.R), somente até a linha 392. A comparação usa os arquivos brutos do Censo da Educação Superior, as 11 planilhas de trajetória em `data/raw/INEP-TRAJETORIA/` e o arquivo já produzido `data/clean/ces_cursos.parquet`. Os arquivos foram lidos em memória; o script de preparação completo não foi executado porque grava saídas.

A unidade de comparação é **ano de ingresso + `CO_CURSO`**. Em `traj`, contei cada coorte uma vez, usando a linha em que `NU_ANO_REFERENCIA == NU_ANO_INGRESSO`; as demais linhas acompanham a mesma coorte nos anos seguintes. Em `ces_cursos`, contei cada curso uma vez por ano, independentemente das várias linhas geográficas que um curso EaD pode ter. O período comparável é 2010–2020.

## Resultado

| Ano | `ces_cursos` | `traj` | Em ambos | Só no Censo | Só na trajetória |
|---:|---:|---:|---:|---:|---:|
| 2010 | 29.605 | 25.923 | 24.631 | 4.974 | 1.292 |
| 2011 | 30.550 | 25.966 | 25.135 | 5.415 | 831 |
| 2012 | 32.010 | 26.831 | 26.334 | 5.676 | 497 |
| 2013 | 32.234 | 26.695 | 26.388 | 5.846 | 307 |
| 2014 | 33.141 | 27.394 | 27.116 | 6.025 | 278 |
| 2015 | 33.767 | 28.143 | 27.862 | 5.905 | 281 |
| 2016 | 34.621 | 29.242 | 28.966 | 5.655 | 276 |
| 2017 | 35.630 | 30.900 | 30.581 | 5.049 | 319 |
| 2018 | 38.211 | 32.887 | 32.590 | 5.621 | 297 |
| 2019 | 40.673 | 34.468 | 34.222 | 6.451 | 246 |
| 2020 | 42.208 | 34.848 | 34.184 | 8.024 | 664 |
| **Total de pares curso–ano** | **382.650** | **323.297** | **318.009** | **64.641** | **5.288** |

Os totais são de **pares curso–ano**, não de cursos distintos ao longo de toda a série. Recalculei as chaves a partir dos arquivos brutos e dos filtros das linhas 143–149 e comparei com `data/clean/ces_cursos.parquet`: as 563.752 chaves de 2010–2024 coincidem exatamente, sem diferença em qualquer direção. Portanto, a preparação geográfica não explica as discrepâncias de cobertura.

## Causas identificadas

### 1. Cobertura temporal diferente

`ces_cursos` cobre 2010–2024. As planilhas carregadas em `traj` contêm coortes de ingresso de 2010 a 2020; as mais recentes acompanham os alunos até 2024. Assim, os cursos do cadastro de 2021–2024 não têm coorte correspondente nesses arquivos. A [página de dados do Inep](https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/indicadores-educacionais/indicadores-de-trajetoria-da-educacao-superior) lista as coortes publicadas.

### 2. Efeito limitado dos filtros de `ces_cursos`

Entre 2010 e 2020, os filtros das linhas 143–149 retiram **1.239 pares curso–ano** do cadastro bruto. Todos esses pares são de cursos classificados como sequenciais (`TP_NIVEL_ACADEMICO == 2`). **1.238** já não constavam da trajetória. A exceção é `CO_CURSO = 1325257`, `CO_IES = 20532`, em 2018: o cadastro o classifica como sequencial e registra 30 ingressantes, enquanto a trajetória traz uma coorte de 25 ingressantes.

A exclusão de `TP_DIMENSAO == 4` retira linhas de oferta no exterior, mas não elimina um código de curso exclusivo no período comparável. Os filtros, portanto, não explicam a maior parte da diferença entre as listas.

### 3. Cursos cadastrados sem coorte observada e contagens pequenas

Dos **64.641** pares exclusivos de `ces_cursos` após os filtros, **47.513** não têm `QT_ING` positivo naquele ano. Outros **17.128** têm `QT_ING` positivo; **13.855** destes registram apenas **1 a 3** ingressantes. Nas 323.297 linhas iniciais das coortes publicadas, o menor `QT_INGRESSANTE` observado foi **4**. Trata-se de um padrão empírico dos arquivos analisados; não encontrei nas fontes consultadas uma regra documental que permita afirmar que o Inep excluiu cursos por esse limiar.

Não basta, porém, filtrar o cadastro por `QT_ING > 0`: **4.531 pares presentes em ambas as fontes** não têm `QT_ING` positivo no cadastro do ano de ingresso. Isso é coerente com a reconstrução retrospectiva das coortes descrita abaixo.

### 4. Reconstrução retrospectiva das coortes

Dos **5.287 pares** presentes na trajetória e ausentes do cadastro **bruto** no ano de ingresso, **5.171** aparecem no cadastro em algum dos três anos seguintes; os outros **116** aparecem mais tarde. Todos os 5.287 constam do cadastro em algum outro ano. Um dos 5.288 pares exclusivos da trajetória **após os filtros** é o curso sequencial de 2018 citado acima.

A [metodologia do Inep](https://download.inep.gov.br/informacoes_estatisticas/indicadores_educacionais/2017/metodologia_indicadores_trajetoria_curso.pdf), reafirmada no [resumo técnico do Censo Superior 2024](https://download.inep.gov.br/publicacoes/institucionais/avaliacoes_e_exames_da_educacao_superior/resumo_tecnico_do_censo_da_educacao_superior_2024.pdf), define a coorte com vínculos identificados nos **quatro primeiros censos**. O método menciona recuperação de alunos vinculados a cursos de destino de Área Básica de Ingresso (ABI), problemas no cadastro e-MEC e IES que não declararam o Censo no ano inicial. Isso explica por que pode haver coorte sem uma linha cadastral do mesmo curso naquele ano. Os dados disponíveis aqui não identificam qual desses mecanismos se aplica a cada par individual.

### 5. Ingressantes do cadastro sem trajetória

Dos **17.128** pares exclusivos do cadastro com `QT_ING` positivo, **3.273** têm pelo menos 4 ingressantes. Em **2.028** deles, o nome do curso contém “ABI”. A metodologia do Inep descreve exclusões ligadas a inconsistências de classificação ABI, mas o nome não comprova que cada um desses pares satisfaça o critério. Os outros **1.245** pares com pelo menos 4 ingressantes não têm “ABI” no nome; há entre eles cursos com dezenas ou centenas de ingressantes.

Essa parcela residual requer confronto com os vínculos individuais dos alunos e as regras de tratamento aplicadas pelo Inep. O repositório contém os cadastros de cursos e as planilhas de trajetória, mas não os microdados longitudinais de alunos necessários para atribuir uma causa individual confirmada a esses casos.

### 6. A IES e outros atributos não são chaves temporais estáveis

Em **6.981 pares** com o mesmo ano e `CO_CURSO` nas duas fontes, `CO_IES` difere. O dicionário das planilhas de trajetória informa que a IES e atributos do curso refletem o **último ano da análise**, ao passo que o Censo registra a situação anual. Exigir `ano + CO_IES + CO_CURSO` como chave inicial produziria falsas ausências. Entre pares com código de curso coincidente, também foram observadas 334 diferenças de município e 184 de grau acadêmico; esses atributos devem ser conferidos antes de serem tratados como constantes.

### 7. Linha de rodapé importada como dado

Cada uma das 11 planilhas termina com uma linha de fonte. A leitura na linha 392 de `01-preparacao.R` incorpora essas **11 linhas sem código de curso**. Elas devem ser retiradas antes de contar cursos ou fazer junções.

## Harmonização recomendada

Para criar uma **vista de comparação**, use `NU_ANO_INGRESSO` como ano de `traj` e `CO_CURSO` como identificador inicial do curso. Preserve `CO_IES` das duas fontes em colunas separadas. Em `ces_cursos`, selecione `tp_dimensao` **1** (presencial) ou **3** (total nacional EaD) para obter uma única linha por curso–ano: verifiquei que essa seleção cobre todos os **382.650 pares** de 2010–2020, sem duplicatas nem perdas. A tabela municipal EaD pode ser mantida separadamente para análises geográficas.

```r
ces_chaves <- ces_cursos |>
  filter(ano %in% 2010:2020, tp_dimensao %in% c(1, 3)) |>
  transmute(
    ano, co_curso,
    co_ies_ces = co_ies,
    qt_ing_ces = qt_ing
  )

traj_chaves <- traj |>
  filter(
    !is.na(CO_CURSO),
    NU_ANO_INGRESSO %in% 2010:2020,
    NU_ANO_REFERENCIA == NU_ANO_INGRESSO
  ) |>
  transmute(
    ano = as.integer(NU_ANO_INGRESSO),
    co_curso = as.integer(CO_CURSO),
    co_ies_traj = as.integer(CO_IES),
    qt_ing_traj = QT_INGRESSANTE
  )

stopifnot(
  !anyDuplicated(ces_chaves[c("ano", "co_curso")]),
  !anyDuplicated(traj_chaves[c("ano", "co_curso")])
)

comparacao <- full_join(
  ces_chaves, traj_chaves,
  by = c("ano", "co_curso")
) |>
  mutate(origem = case_when(
    is.na(co_ies_ces)  ~ "somente_traj",
    is.na(co_ies_traj) ~ "somente_censo",
    TRUE               ~ "ambos"
  ))
```

Para análises que exigem simultaneamente características do Censo e indicadores de trajetória, a amostra diretamente verificável é a interseção de **318.009 pares**. Nos diagnósticos, mantenha os pares exclusivos com uma marca de origem. Não interprete ausência de trajetória como taxa zero nem atribua a uma coorte características retiradas de um ano posterior como se fossem contemporâneas. Para indicadores descritivos do cadastro, mantenha a cobertura integral de `ces_cursos`.

## Limites da verificação e fontes locais

As contagens foram reproduzidas por leituras direcionadas em memória; não foi executado o script completo de preparação. A classificação dos 1.245 pares residuais sem “ABI” no nome permanece aberta porque os microdados longitudinais dos alunos não estão neste repositório. Nenhum arquivo-fonte foi modificado durante o diagnóstico.

Fontes locais: [`code/01-preparacao.R`](../code/01-preparacao.R); [`code/helpers/gera_amc.R`](../code/helpers/gera_amc.R); [`docs/dicionario-dados-CensoEducacaoSuperior.md`](../docs/dicionario-dados-CensoEducacaoSuperior.md); `data/raw/CES-CURSOS/MICRODADOS_CADASTRO_CURSOS_2010.parquet` a `MICRODADOS_CADASTRO_CURSOS_2024.parquet`; `data/raw/INEP-TRAJETORIA/2010_2019/` a `2020_2024/`, incluindo suas planilhas `.xlsx` e o dicionário de acompanhamento; e `data/clean/ces_cursos.parquet`.
