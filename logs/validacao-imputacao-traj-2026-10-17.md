# Validação da imputação de características anuais em Trajetórias

Data: 17/10/2026. Decisões: `docs/decisoes-imputacao-traj.md`.

## Escopo da alteração

Foi inserido um bloco a partir da linha 527 de `code/01-preparacao.R`, dentro da
seção já existente de imputação. A inserção inicial foi conferida em bytes,
removendo-se o acréscimo e comparando com o conteúdo imediatamente anterior.
Os ajustes posteriores ficaram dentro do próprio acréscimo. A conferência final
comparou o bloco com a inserção esperada, preservando os 22.454 bytes originais.
Foram acrescentadas 174 linhas. Nenhum código preexistente foi alterado.

## Execução e verificações

O arquivo completo passou na análise sintática em R 4.6.1. O teste executável
está em `logs/_valida_imputacao_traj_20261017.R`; ele inclui a biblioteca de
usuário de R 4.6 na sessão isolada de validação, sem alterar a configuração do
projeto.

Os casos controlados passaram, incluindo:

- Limites internos iguais e diferentes, preenchimentos iniciais e finais.
- Modalidade divergente e curso inteiramente sem referência no CES.
- Código Cine igual com nomes diferentes, preservando a lacuna do par.
- Ausência de grau em cadastro existente, preservada.
- IES sem atividade no ano inicial ou interno, inclusive registros com zero ou
  matrículas ausentes; bloqueio do preenchimento nesses anos.
- Preservação de valores observados, linhas, ordem, outras colunas e referências
  originais de Trajetórias.
- Reexecução com o mesmo resultado, sem duplicar colunas ou perder indicadores.

A validação real usou `data/clean/ces_cursos.parquet` e importou somente as
chaves e a IES original das 11 planilhas, reconstruindo em memória o merge das
características anuais. Foram preservadas as 2.731.155 linhas, a ordem, os
atributos observados presentes na entrada do teste e os indicadores da cobertura
original. As características anuais ficaram únicas por curso–ano entre coortes.
Cada IES imputada encontrou ao menos um curso com matrículas positivas no mesmo
ano. Os indicadores de imputação coincidiram com os preenchimentos realizados.

| Variável | Ausências antes | Valores imputados | Ausências depois |
|---|---:|---:|---:|
| `co_ies` | 186.769 | 140.586 | 46.183 |
| `no_curso` | 186.769 | 186.422 | 347 |
| `co_cine_area_geral` | 186.769 | 186.769 | 0 |
| `no_cine_area_geral` | 186.769 | 186.769 | 0 |
| `tp_grau_academico` | 186.785 | 186.769 | 16 |
| `tp_modalidade_ensino` | 186.769 | 186.769 | 0 |

Para `no_curso`, as ausências anteriores foram calculadas pelo cadastro do CES
associado às chaves de entrada, pois a variável não estava no merge original.
Recuperar um nome observado não foi contado como imputação.

## Limites

Os testes verificam a aplicação das regras aprovadas, não a verdade histórica
dos valores imputados. Não foi executado o roteiro completo de preparação, não
foi regenerado o CES processado e não foram executadas as exportações do script.
Nenhum arquivo bruto, Parquet de saída ou planilha de resultados foi escrito
pela validação.

A sessão de R emitiu avisos de configuração regional no início; isso não impediu
a execução dos testes. A leitura com tipos numéricos explícitos também emitiu
avisos nas planilhas, cujo rodapé sem código de curso é excluído da entrada.
