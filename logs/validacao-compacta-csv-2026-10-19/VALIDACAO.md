# Validação da compactação dos metadados dos indicadores

Data: 19/10/2026.

## Alteração implementada

- Nova função `code/helpers/compacta_csv.R`: deixa `indicador_code` e
  `indicador_nome` preenchidos somente na primeira linha da cópia exportada.
- As 18 exportações de A, B, G e I chamam `compacta_csv()` dentro de
  `write_excel_csv()`, depois dos filtros de cada indicador.
- `gera_xlsx_formatado()` recupera o título antes de dividir a tabela em abas,
  ignorando `NA`, strings vazias e espaços em branco. Exige um único título.
- Os objetos `*$output` e as funções `calcula_dimensao_*` são preservados.

## Verificações executadas

1. Sintaxe dos scripts alterados e de `07-planilhas.R`; inspeção das 18
   chamadas reais de exportação, executadas com os resultados atuais em uma
   pasta de validação, sem executar novamente os cálculos dos indicadores.
2. Casos dirigidos: tabela vazia, uma linha, preservação do objeto original,
   repetição da compactação, metadados parcialmente preenchidos e rejeição de
   metadados ausentes ou conflitantes.
3. Compactação e gravação/leitura dos 18 CSVs completos. A transformação em
   memória preservou integralmente todas as outras colunas e a ordem das linhas.
4. Comparação de planilhas geradas com a função anterior, com a função nova
   recebendo dados completos e com a função nova recebendo os CSVs compactados.
5. Comparação direta com as 12 planilhas atuais de A1–A5, B1–B3 e G1–G4 em
   `produtos/planilhas`.
6. Verificação SHA-256 dos 12 arquivos originais antes e depois dos testes.

## Resultado

**Todos os testes passaram. As 12 planilhas regeneradas são iguais às atuais
em conteúdo e formatação. Os 12 arquivos originais permanecem idênticos em
bytes e não foram sobrescritos.**

A comparação examina todas as partes internas dos arquivos XLSX: células,
fórmulas, textos, estilos, abas, larguras, mesclagens, relacionamentos e demais
configurações. XML é comparado em forma canônica. Somente as datas internas
de criação/modificação e os registros de tempo do contêiner ZIP ficam fora da
comparação entre arquivos regenerados.

No B2, quatro valores apresentam diferença máxima de aproximadamente
`6,94e-18` após gravar e reler o CSV. A mesma diferença ocorre no controle sem
compactação: decorre do ciclo de escrita/leitura numérica do `readr`. Não há
diferença correspondente no conteúdo interno das planilhas Excel.

## Limites da validação da dimensão I

- Não há planilhas atuais de I em `produtos/planilhas` para comparação direta.
  I1 foi testado integralmente contra a função anterior.
- Os cinco CSVs de I2 foram testados integralmente quanto à compactação.
  Para gerar Excel, usou-se um território de cada arquivo, pois o formatador
  atual não separa os territórios em tabelas. Não se validou a geração de um
  Excel territorial completo; essa capacidade não foi alterada nesta tarefa.
- O CSV municipal atual, `results/indicadorI2e.csv`, já estava sem as duas
  colunas de identificação. Somente na cópia usada no teste elas foram
  reconstruídas com a configuração atual de I2. O arquivo original não foi
  alterado. O teste de ausência de metadados confirma que a função informa erro.
- Os CSVs de `results` não foram substituídos. As próximas execuções dos
  scripts passarão a gravar os metadados compactados.

## Evidências e reprodução

- `valida.R`: testes de sintaxe, compactação, exportações e geração de Excel.
- `execucao-R.txt`: saída da execução concluída.
- `resumo-csv.csv`: contagens de linhas, tamanhos e diagnóstico numérico.
- `compara_xlsx.py`: comparação das partes internas e dos arquivos originais.
- `comparacao-xlsx.json`: resultado de todas as comparações, sem diferenças.
- `planilhas-originais.json`: tamanhos e SHA-256 dos 12 arquivos originais.
- `xlsx-anterior`, `xlsx-novo` e `xlsx-legado`: planilhas usadas nas comparações.

Os CSVs temporários foram removidos após a validação para evitar duplicar
centenas de MB. Para reproduzir os testes a partir da raiz do projeto:

```powershell
Rscript --vanilla logs/validacao-compacta-csv-2026-10-19/valida.R
python logs/validacao-compacta-csv-2026-10-19/compara_xlsx.py
```

A execução foi feita com R 4.6.1, dplyr 1.2.1, readr 2.2.0, purrr 1.2.2,
tidyr 1.3.2, stringr 1.6.0, forcats 1.0.1 e openxlsx 4.2.9, usando a biblioteca
local existente. Nenhum pacote foi instalado nem configuração do projeto foi
modificada.
