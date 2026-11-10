# Decisão sobre os percentuais do indicador G.1

Data: 27 de setembro de 2026.

**Situação:** decisão substantiva de G.1 aprovada pelo usuário; implementação ainda não realizada. Este documento registra a decisão e a proposta de implementação. **Os denominadores de G.2, G.3 e G.4 ainda não foram decididos.**

## 1. Problema identificado

A função `code/helpers/calcula_dimensao_G.R` calcula atualmente os percentuais de todas as variáveis de docentes pela razão entre a variável e `qt_doc_exe`, após a agregação por grupo e ano.

Como `qt_doc_exe` contém o total de docentes do próprio grupo, essa regra produz:

- nas abas `Doc`, o total de docentes do grupo dividido por ele mesmo, resultando em 100%;
- nas abas `DocInt`, a proporção de docentes em tempo integral dentro do corpo docente daquele grupo.

São medidas diferentes da distribuição de cada variável entre os grupos. A conferência aritmética anterior confirmou a reprodução da fórmula implementada, mas não identificou a inadequação dos percentuais de 100% para representar essa distribuição.

## 2. Decisão aprovada para G.1

**Cada grupo será dividido pelo total da própria variável, no mesmo ano.**

A ficha G.1 mostrará como os docentes em exercício e os docentes em exercício em tempo integral se distribuem por categoria administrativa, faixa de participação da EaD e faixa de tamanho da mantenedora.

Para cada variável, recorte e ano:

```text
Distribuição entre grupos (%) =
  100 × quantidade do grupo / total da mesma variável no ano
```

O denominador será comum a todas as colunas de dados de uma mesma aba, em cada ano. O numerador será a quantidade correspondente ao grupo da coluna e ao ano da linha.

### Denominadores por aba e coluna

| Aba | Colunas de dados | Denominador de cada coluna, no mesmo ano |
|---|---|---|
| `Total_Doc` | B — Total | Total nacional de docentes em exercício |
| `CatAdm_Doc` | B–F — categorias administrativas | Total nacional de docentes em exercício |
| `FxEaD_Doc` | B–E — faixas de participação da EaD | Total nacional de docentes em exercício |
| `Tamanho_Doc` | B–F — faixas de tamanho da mantenedora | Total nacional de docentes em exercício |
| `Total_DocInt` | B — Total | Total nacional de docentes em exercício em tempo integral |
| `CatAdm_DocInt` | B–F — categorias administrativas | Total nacional de docentes em exercício em tempo integral |
| `FxEaD_DocInt` | B–E — faixas de participação da EaD | Total nacional de docentes em exercício em tempo integral |
| `Tamanho_DocInt` | B–F — faixas de tamanho da mantenedora | Total nacional de docentes em exercício em tempo integral |

As colunas dos recortes são:

- **Categoria administrativa:** B, pública federal; C, pública estadual; D, pública municipal; E, privada com fins lucrativos; F, privada sem fins lucrativos.
- **Faixa de participação da EaD:** B, IES sem EaD; C, mais de 0% e até 33% das matrículas; D, mais de 33% e até 66%; E, mais de 66%.
- **Tamanho da mantenedora:** B, Top 5; C, Top 6–10; D, Top 11–15; E, Top 16–20; F, demais mantenedoras.

A coluna A contém o ano e não participa do cálculo percentual. A aba `Índice` não contém indicadores a recalcular.

### Consequências para a interpretação

- Cada linha anual das abas desagregadas deverá somar 100%, ressalvado o arredondamento de exibição.
- Nas duas abas `Total`, o percentual será 100%.
- Em particular, `Total_DocInt` deixará de apresentar a proporção nacional de docentes em tempo integral no conjunto de todos os docentes. Passará a representar o total da distribuição dos docentes em tempo integral.
- As quantidades absolutas serão preservadas.
- O título visível do bloco percentual será **“Distribuição entre grupos (%)”**.

### Exemplo de referência: 2024

Os valores abaixo foram conferidos nos resultados atuais de G.1 e servem como referência para validar a futura implementação.

| Grandeza | Valor |
|---|---:|
| Total nacional de docentes em exercício | 374.501 |
| Total nacional de docentes em exercício em tempo integral | 212.899 |
| Docentes em exercício na categoria pública federal | 126.799 |
| Docentes em exercício em tempo integral na categoria pública federal | 118.775 |

Com a decisão aprovada:

- `CatAdm_Doc`, categoria pública federal: `100 × 126.799 / 374.501 = 33,9%`.
- `CatAdm_DocInt`, categoria pública federal: `100 × 118.775 / 212.899 = 55,8%`.

O percentual atual de 93,7% em `CatAdm_DocInt` responde a outra pergunta: a proporção em tempo integral dentro do corpo docente federal, calculada como `100 × 118.775 / 126.799`.

## 3. Sugestão de implementação

Esta seção é uma proposta técnica; nenhum dos trechos abaixo foi aplicado ao código.

### 3.1. Configuração específica de G.1

Em `code/08-indicadores-G.R`, acrescentar à configuração de G.1:

```r
G1$tipo_percentual <- 'distribuicao'
```

### 3.2. Cálculo na função compartilhada

Em `code/helpers/calcula_dimensao_G.R`, reconhecer essa configuração e selecionar o cálculo correspondente depois da agregação feita por `fn()` e antes de `pivot_longer()`.

Para o modo `distribuicao`, o núcleo do cálculo sugerido é:

```r
mutate(
  across(
    starts_with('qt_doc'),
    ~ 100 * .x / sum(.x),
    .names = "{sub('^qt', 'pct', .col)}"
  ),
  .by = ano
)
```

Esse cálculo deve permanecer dentro do processamento de cada recorte, antes de empilhar os recortes. Assim, a soma é feita separadamente para cada variável e ano, sem misturar anos ou somar os mesmos docentes em diferentes recortes.

Nos recortes atuais de G.1, os grupos formam partições do total. A implementação deve conferir que a soma de cada variável entre os grupos coincide com o respectivo total nacional apresentado nas abas `Total`.

Para os indicadores sem a configuração `distribuicao`, manter provisoriamente o comportamento atual da função. Isso restringe a alteração a G.1; não representa aprovação substantiva dos denominadores atuais de G.2–G.4. O cálculo da razão matrículas por docente também não faz parte desta alteração.

### 3.3. Identificação no Excel

Em `code/helpers/gera_xlsx_formatado.R`, usar o título visível **“Distribuição entre grupos (%)”** para o bloco percentual de G.1.

Preservar o valor interno `Percentual` no campo `unidade`, utilizado para separar e formatar as tabelas. A mudança de texto deve ocorrer na apresentação do cabeçalho, especificamente para G.1.

### 3.4. Validação e regeneração

Na futura implementação:

1. Conferir que as quantidades absolutas, os grupos, os anos e a estrutura dos resultados de G.1 permanecem iguais.
2. Conferir os denominadores contra os totais anuais das respectivas variáveis.
3. Verificar que cada distribuição desagregada soma 100%, dentro da precisão numérica, e que as abas `Total` apresentam 100%.
4. Conferir os exemplos de 2024 registrados neste documento.
5. Verificar que os resultados de G.2–G.4 não foram alterados pela mudança na função compartilhada.
6. Revisar eventuais usos dos percentuais de G.1 em gráficos, slides ou textos, pois a interpretação de `DocInt` será modificada.
7. Regenerar somente `results/indicadorG1.csv` e `produtos/planilhas/indicadorG1.xlsx`, conferindo a correspondência entre os valores exportados.

Os scripts atuais `code/08-indicadores-G.R` e `code/11-planilhas.R` produzem vários indicadores quando executados integralmente. A regeneração de G.1 deve respeitar o escopo específico desta decisão.

## 4. Pendências: G.2, G.3 e G.4

**Ainda não há decisão sobre os denominadores de G.2, G.3 e G.4.** Cada ficha será discutida separadamente.

Na conversa, foi sugerido que a composição interna do corpo docente por regime de trabalho poderia ser apresentada em G.3, enquanto G.1 trataria da distribuição entre grupos. Essa possibilidade permanece uma sugestão para a discussão de G.3, não uma decisão aprovada para essa ficha.

A decisão de G.1 não autoriza aplicar automaticamente a regra de distribuição a todos os indicadores G, nem alterar os percentuais ou as taxas das demais fichas.
