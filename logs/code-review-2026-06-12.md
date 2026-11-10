# Revisão de código do pipeline

Data da revisão: 2026-06-12

## Escopo

Foram auditados:

- `code/master.R`
- `code/_setup.R`
- `code/01-preparacao.R`
- `code/02-indicadores-A.R`
- `code/10-graficos.R`
- `report/relatorio-descritivo.qmd`
- filtros Lua usados pelo relatório
- documentação em `docs/`
- funções auxiliares relevantes em `code/helpers/`

Os indicadores B e os trechos explicitamente inacabados foram ignorados conforme solicitado.

## Achados

### [P1] Percentuais de reclassificação estão 100 vezes menores

**Local:** `report/relatorio-descritivo.qmd:125`

O cálculo de `pct_reclass` não multiplica a razão por 100:

```r
pct_reclass <- paste0(sprintf('%.0f', saldo_reclass / delta), '%')
```

O relatório produz **0%** e **1%**, mas os valores corretos são aproximadamente **39%** e **76%** para as categorias privadas com e sem fins lucrativos.

**Direção de correção:** usar `100 * saldo_reclass / delta`.

### [P1] Executar qualquer script apaga o workspace do usuário

**Local:** `code/_setup.R:20`

Todos os scripts auditados carregam `_setup.R`, que executa:

```r
rm(list = ls())
```

Foi confirmado em subprocesso que um objeto existente no workspace é apagado mesmo quando o setup falha posteriormente.

Isso cria um efeito colateral destrutivo e inesperado para quem executa qualquer etapa individualmente.

**Direção de correção:** remover a limpeza automática ou torná-la uma ação explícita e opcional.

### [P2] Crescimento das mantenedoras informado como 3%, mas foi 1,33%

**Local:** `report/relatorio-descritivo.qmd:75-76`

Os resultados atuais mostram crescimento de 1.729 mantenedoras em 2010 para 1.752 em 2024:

```text
100 * (1752 / 1729 - 1) = 1,33%
```

A afirmação de crescimento de 3% não corresponde aos resultados gerados pelo pipeline.

**Direção de correção:** corrigir o texto ou calcular o percentual dinamicamente a partir dos resultados.

### [P3] Valor padrão de `ggplot_linhas()` gera aviso e linha em infinito

**Local:** `code/helpers/ggplot_linhas.R:17` e `code/helpers/ggplot_linhas.R:26`

Com o padrão `y_limits = NULL`, a função executa:

```r
hline_yintercept <- min(y_limits)
```

Isso retorna `Inf`, emite aviso e cria uma linha horizontal em posição inválida. Os usos atuais fornecem limites e, portanto, os gráficos existentes não são afetados.

**Direção de correção:** definir a linha somente quando `y_limits` não for `NULL`, ou usar outro valor padrão explícito.

## Pergunta em aberto

### Denominador dos percentuais de mantenedoras por organização acadêmica

**Locais:** `code/02-indicadores-A.R:107-108` e `code/helpers/calcula_dimensao_A.R:53-58`

Em A1, os percentuais de mantenedoras por organização acadêmica usam como denominador a soma das contagens dos grupos. Uma mesma mantenedora pode aparecer em mais de uma organização acadêmica.

Em 2024:

- soma das contagens por organização: 1.846;
- mantenedoras únicas: 1.752;
- sobreposição: 94.

O resultado representa corretamente uma distribuição de vínculos mantenedora-organização, mas não uma distribuição de mantenedoras únicas. É necessário confirmar qual conceito é desejado.

## Críticas de estilo

### Joins usam chaves implícitas

**Locais:**

- `code/01-preparacao.R:128`
- `code/01-preparacao.R:262-265`
- `code/02-indicadores-A.R:71-72`

Os joins dependem das colunas homônimas presentes em cada objeto. Mudanças futuras de esquema podem alterar silenciosamente as chaves utilizadas.

**Direção sugerida:** informar `by` e, quando aplicável, `relationship` explicitamente.

### Documentação de `detecta_sigla_comercial()` está incompleta

**Local:** `code/helpers/detecta_siglas_comerciais.R:4-13` e `code/helpers/detecta_siglas_comerciais.R:43`

A documentação informa que `restrito = FALSE` acrescenta `LTDA` e `LIMITADA`, mas a implementação também detecta `EMPRESARIAL`.

**Direção sugerida:** documentar esse padrão adicional ou removê-lo, caso não faça parte do contrato pretendido.

## Validações executadas

- Todos os arquivos R atuais do escopo passam no parse.
- `01-preparacao.R` foi recalculado integralmente em memória, com escritas desativadas.
- A recomputação reproduziu:
  - 3.459.363 linhas em `ces_cursos`;
  - 37.021 linhas em `ces_ies`;
  - 26.044 linhas em `ces_mantenedoras`;
  - 283 linhas de rótulos.
- Os cinco indicadores A foram reconstruídos em memória.
- Os indicadores cobrem 2010 a 2024 sem valores `NA`, `NaN` ou infinitos nos resultados.
- Os dez gráficos foram construídos em memória sem salvar arquivos.
- As chaves inspecionadas não apresentaram duplicatas nos dados atuais.
- Não foram encontrados cursos sem correspondência de IES-ano.
- A instalação ativa em R 4.6.0 contém o pacote `quarto` 1.5.1; `library(quarto)`, `quarto_available()` e `source('code/_setup.R')` funcionam corretamente.
- O `Rscript` padrão disponível no `PATH` durante parte da auditoria apontava para R 4.5.2, cuja biblioteca não contém o pacote `quarto`. Essa diferença de ambiente não constitui um erro do pipeline.
- O arquivo `.qmd` auditado é mais recente que os arquivos `.docx` e `.pdf`; esses entregáveis não representam exatamente a versão atual do relatório.

## Avaliação geral

A preparação dos dados, os indicadores A e a construção dos gráficos reproduzem os resultados atuais e não apresentaram erros substantivos adicionais nas validações realizadas. Os principais problemas confirmados estão no efeito destrutivo do setup comum e em dois números incorretos no relatório descritivo.
