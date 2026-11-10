# Pendência: preservar a geografia no gerador de planilhas

Registrada em 24/10/2026 a pedido do usuário. Correção adiada para quando o
gerador de planilhas for alterado; não implementar nesta revisão.

## Problema confirmado

`code/07-planilhas.R` encaminha os CSV dos indicadores geográficos à função
`code/helpers/gera_xlsx_formatado.R`. Na linha 138, a seleção de unidade,
grupo, ano/período e valor descarta os códigos e nomes dos territórios.
O `pivot_wider()` da linha 143 passa a encontrar vários valores para a
mesma combinação de ano e grupo, produzindo colunas de listas. O workbook
reúne os valores territoriais como texto em uma célula, sem identificar
os territórios.

A conversão em memória de `results/indicadorI4a.csv` confirmou cinco valores
regionais reunidos por ano. O workbook foi inspecionado em memória; nenhum
arquivo Excel foi salvo ou sobrescrito. Os CSV preservam a geografia.

## Correção futura

Ao alterar o gerador, preservar os territórios nas chaves das tabelas ou
separá-los em abas. A escolha de apresentação permanece em aberto.
Verificar identificação geográfica, uma observação por célula numérica,
ausência de colunas de listas e preservação dos resultados A/B/G.

Nenhum código ou resultado foi alterado para corrigir esta pendência.
