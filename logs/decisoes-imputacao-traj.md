# Decisões de imputação das características anuais de cursos em `traj`

Regras de imputação aprovadas em 17/10/2026, substituindo as regras anteriores.
Documento atualizado em 18/10/2026 para registrar o descarte intencional dos
atributos cadastrais originais de Trajetórias e o estado da implementação.
A seção “Imputação de missing values nos dados de trajetória”, em
`code/01-preparacao.R`, já incorpora a regra temporal simplificada, os indicadores
`_imputado` e `co_ies_em_atividade`. A retirada de `no_curso` do procedimento
também está implementada.

## Unidade e fontes

O cadastro é preenchido uma única vez por `co_curso + ano`, usando todo o
histórico disponível em `ces_cursos`, inclusive anos fora das janelas de cada
coorte. Depois, o resultado é incorporado às linhas de Trajetórias. A mesma
característica de um curso–ano deve ser idêntica entre coortes.

Valores observados no CES são preservados. Os atributos originais de Trajetórias
correspondentes a `co_ies`, `tp_modalidade_ensino`, `tp_grau_academico`,
`co_cine_area_geral` e `no_cine_area_geral` são descartados intencionalmente no
pré-processamento; não são mantidos em colunas `*_traj`. As características anuais
vêm exclusivamente do CES, por observação ou imputação temporal. A referência
retrospectiva de Trajetórias não é usada para preenchê-las. `no_curso` não é
necessário para a análise e foi retirado do procedimento: não é recuperado nem
imputado nesta seção.

## Manutenção dos cursos com grau acadêmico incompleto

Manter em `traj` todas as linhas dos quatro cursos identificados com grau
acadêmico ausente em cadastros encontrados no CES. Fica revogada a decisão
anterior de excluir integralmente esses cursos. Aplicar aos 16 graus ausentes
nesses cadastros a regra temporal geral descrita abaixo, sem exceção para grau
acadêmico. Fica revogada a decisão intermediária de preservar essas ausências.

| `co_curso` | Linhas mantidas | Grau ausente antes da imputação | Grau originalmente preenchido |
|---|---:|---:|---:|
| 151 | 85 | 4 | 81 |
| 14357 | 40 | 3 | 37 |
| 300637 | 30 | 3 | 27 |
| 5000948 | 30 | 6 | 24 |
| **Total** | **185** | **16** | **169** |

Esses códigos e contagens identificam os casos da base examinada. Grau ausente
não comprova ABI, trajetória inválida ou não aplicabilidade. Não atribuir uma
dessas causas sem evidência específica. A opção aprovada é manter os cursos e
preencher os 16 graus pela mesma convenção aplicada às demais variáveis,
inclusive quando o cadastro do curso–ano existe no CES.

Esse preenchimento não esclarece a causa da ausência original. Se ela decorrer
de não aplicabilidade, o transporte temporal poderá atribuir um grau que não
corresponde à situação daquele ano. A redução a zero missing não demonstra
correção histórica nem aplicabilidade do grau. Identificar esses preenchimentos
por `tp_grau_academico_imputado = TRUE` e explicitar essa limitação nas análises
por grau. O indicador permite avaliar os resultados com e sem graus imputados,
sem excluir os cursos da base geral.

## Regra temporal simplificada aprovada

Aplicar a mesma regra, separadamente por curso e variável, a:

- `tp_modalidade_ensino`;
- `co_cine_area_geral`;
- `no_cine_area_geral`;
- `tp_grau_academico`;
- `co_ies`.

| Situação | Tratamento |
|---|---|
| Valor observado | Preservar o valor original. |
| Missing antes do primeiro valor válido observado | Usar o primeiro valor válido disponível. |
| Missing interno | Usar o último valor válido observado antes dele, mesmo que o próximo valor observado seja diferente. |
| Missing após o último valor válido observado | Usar o último valor válido observado. |
| Nenhum valor válido no histórico do curso para a variável | Manter missing. |

Os limites são definidos pela disponibilidade de cada variável, e não apenas
pela presença do curso no CES. A regra também alcança campos vazios em cadastros
encontrados, inclusive grau acadêmico. Não há limite de
duração da lacuna nem exigência de igualdade entre os valores antes e depois.
Não se exige modalidade invariável e não se mantém uma regra especial de
concordância dos limites para código e nome Cine.

As referências vêm de observações originais; um preenchimento não justifica
outro. Não inferir IES sucessoras acompanhando outros cursos nem utilizar
a IES retrospectiva de Trajetórias para desempatar. A atividade da IES não
condiciona o preenchimento, em nenhuma posição da série.

## Interpretação e rastreabilidade

O preenchimento assume continuidade da última característica conhecida. Quando
os limites de uma lacuna interna diferem, adota-se a convenção de que a mudança
ocorre no primeiro ano em que o novo valor aparece observado. Antes da primeira
observação, assume-se continuidade retrospectiva do primeiro valor disponível.
Essas convenções não comprovam a situação histórica nos anos ausentes.

São criados os seguintes indicadores lógicos, com sufixo `_imputado`,
substituindo o padrão anterior `imputado_<variavel>`:

- `tp_modalidade_ensino_imputado`;
- `co_cine_area_geral_imputado`;
- `no_cine_area_geral_imputado`;
- `tp_grau_academico_imputado`;
- `co_ies_imputado`.

Cada indicador é `TRUE` quando o valor originalmente ausente tiver sido
preenchido e `FALSE` nos demais casos, inclusive observações originais e
ausências que não puderem ser preenchidas.

Também é criado `co_ies_em_atividade`, para IES observadas e imputadas:

| Valor | Condição |
|---|---|
| `TRUE` | Existe ao menos um curso dessa IES com `qt_mat > 0` no CES processado daquele ano. |
| `FALSE` | A IES está identificada, mas não foi encontrada essa evidência de atividade no ano. |
| `NA` | `co_ies` está ausente, impedindo a verificação. |

A busca de atividade considera todos os cursos de `ces_cursos`, não apenas os
presentes em Trajetórias. `FALSE` significa ausência de atividade observada nessa
base; não comprova encerramento da instituição. A coluna documenta a condição,
sem impedir a imputação: `co_ies_imputado = TRUE` pode coexistir com
`co_ies_em_atividade = FALSE`.

`presente_ces`, `n_presente_ces`, `n_ausente_ces` e
`pct_presente_ces` continuam descrevendo a cobertura original, anterior à
imputação. Os objetos intermediários ficam em `imputacao.traj`.

O bloco não exporta nem sobrescreve dados. A tabela de diagnóstico anterior à
seção continua registrando a situação antes da imputação.

## Relação com a metodologia do Inep e limites de interpretação

Fonte: [Metodologia de cálculo dos indicadores de fluxo da educação superior,
Inep, 2017](https://download.inep.gov.br/informacoes_estatisticas/indicadores_educacionais/2017/metodologia_indicadores_trajetoria_curso.pdf).
As páginas abaixo usam a numeração impressa do documento.

### Objetos distintos de imputação

Nas seções 2 e 3 (pp. 19–25), o Inep corrige e imputa situações de vínculo
individual dos estudantes e depois agrega os resultados por curso. Nosso
procedimento reconstrói atributos cadastrais anuais a partir do CES processado.
Não modifica vínculos individuais, contagens ou taxas publicadas. A regra
temporal simplificada é uma convenção analítica própria: não reproduz nem é
validada pelo procedimento de imputação do Inep.

A igualdade empírica entre duas regras de preenchimento não demonstra a verdade
histórica dos atributos atribuídos. Os indicadores `_imputado` distinguem
preenchimento de observação, mas não medem a precisão histórica da imputação.

### Referência temporal e unidade de análise

O Apêndice II (pp. 38–39) descreve IES, grau e modalidade pela situação no último
ano de análise. Os atributos anuais recuperados ou imputados do CES têm outra
referência temporal e não devem ser apresentados como informações anuais
confirmadas pelo Inep. Os atributos cadastrais originais de Trajetórias são
descartados no pré-processamento, conforme a decisão descrita em “Unidade e
fontes”.

O documento também distingue desistência do curso e saída da IES (p. 13).
Agrupar indicadores de cursos por IES não transforma automaticamente desistência
do curso em evasão institucional. Ao comparar grupos ao longo do tempo, explicitar
se a classificação corresponde ao ingresso, ao ano de referência ou ao fim da
janela; mudanças anuais de classificação podem mudar a composição dos grupos.

### Continuidade dos códigos de curso

O Inep descreve mudanças de código e acompanhamento por curso representante,
usando também informações administrativas que não constam dos microdados
públicos (pp. 21–23). Portanto, ausência de correspondência por `co_curso + ano`
não comprova ausência de informação sobre o curso: pode existir cadastro sob
outro código. A junção e a imputação adotadas não reconstroem essas relações.

Essa é uma limitação a investigar, não uma demonstração de que algum valor
específico já imputado esteja errado. Não inferir automaticamente sucessão de
códigos ou IES. Transportar um atributo no tempo continua sendo uma hipótese de
continuidade, e não recuperação comprovada do vínculo histórico.

### Grau acadêmico, ABI e classificação de área

A exclusão por ABI apresentada pelo Inep segue um critério específico de
classificação ao longo da trajetória (p. 20), e não uma regra geral de exclusão
por grau ausente. O documento não fundamenta a retirada automática dos quatro
cursos listados acima. Eles permanecem na base e recebem a imputação temporal
do grau por decisão analítica própria, com a limitação de possível não
aplicabilidade descrita acima. A metodologia do Inep não valida esses graus
atribuídos nem permite identificar ABI apenas pela ausência do grau.

A publicação de 2017 utiliza a classificação OCDE (p. 39). Ela não valida por si
só a harmonização posterior em Cine, cuja consistência deve ser verificada nas
fontes e versões efetivamente usadas pelo projeto.

## Comparação empírica e validação da implementação

A comparação em memória usou as 2.731.155 linhas válidas das 11 planilhas locais
de Trajetórias e o CES processado existente. A referência foi o conjunto de
regras aprovado antes da simplificação, já incluindo o transporte de `co_ies`
sem filtro de atividade, e não somente o código então implementado.

O exercício anterior testou a regra uniforme agora adotada, incluindo os graus
ausentes em cadastros encontrados:

| Variável | Imputações que receberiam outro valor | Missing adicionais preenchidos |
|---|---:|---:|
| `tp_modalidade_ensino` | 0 | 0 |
| `co_cine_area_geral` | 0 | 0 |
| `no_cine_area_geral` | 0 | 0 |
| `tp_grau_academico` | 0 | 16 |
| `co_ies` | 0 | 0 |

Os 16 preenchimentos adicionais ocorrem justamente nos quatro cursos mantidos
na base. Com a manutenção das 185 linhas e a regra simplificada nas cinco
variáveis, o resultado esperado para os dados examinados passa a ser:

| Medida | Resultado esperado |
|---|---:|
| Linhas de `traj` | 2.731.155 |
| Missing em `tp_modalidade_ensino` | 0 |
| Missing em `co_cine_area_geral` | 0 |
| Missing em `no_cine_area_geral` | 0 |
| Missing em `tp_grau_academico` | 0 |
| Missing em `co_ies` | 0 |

Esses números foram inicialmente obtidos nas comparações anteriores, incluindo
o preenchimento dos 16 graus. A execução em memória dos trechos atuais de
preparação e imputação, na revisão de 18/10/2026, confirmou as 2.731.155 linhas e
a ausência de missing nas cinco variáveis, usando as 11 planilhas locais e o CES
processado existente. Também confirmou:

- preservação dos valores observados no CES, das demais colunas de `traj` e dos
  indicadores de cobertura original;
- marcas `_imputado` corretas e atributos idênticos entre coortes para cada
  curso–ano;
- manutenção das 185 linhas dos quatro cursos listados;
- tratamento das lacunas iniciais, internas com limites diferentes, finais e
  dos históricos sem valor válido;
- uso da atividade da IES somente como indicador, sem bloquear imputações.

Uma comparação independente em 1.270.739 pares curso–ano de teste não encontrou
divergências nas cinco variáveis. Não houve execução integral de
`01-preparacao.R`, regeneração do CES nem exportação de resultados.

Essas verificações não comprovam a correção histórica dos atributos imputados
nem garantem ausência de outros missing ou equivalência entre regras em novas
atualizações. A manutenção dos cursos preserva o universo geral; eventuais
restrições por grau precisam ser informadas nas análises correspondentes.

Os arquivos `logs/_valida_imputacao_traj_20261017.R` e
`logs/validacao-imputacao-traj-2026-10-17.md` registram a validação da
implementação anterior. Ainda incluem `no_curso`, os indicadores com prefixo
`imputado_` e o filtro de atividade da IES; não validam as novas regras deste
documento.
