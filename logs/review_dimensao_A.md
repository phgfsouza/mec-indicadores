# Revisao da Dimensao A

Data da revisao: 2026-06-11

## Escopo

Arquivos revisados:

- `code/02-indicadores-A.R`
- `code/helpers/calcula_dimensao_A.R`

O foco principal foi verificar se os percentuais calculados para os indicadores
A1-A5 estao matematicamente e substantivamente corretos.

Nenhum arquivo de codigo ou dado foi alterado durante a revisao.

## Achados

### [P1] Percentuais de mantenedoras do A1 usam denominadores com duplicacao

Local principal: `code/helpers/calcula_dimensao_A.R`, linha 55.

O helper calcula automaticamente os percentuais de todas as colunas `qt_*`:

```r
100 * .x / sum(.x, na.rm = TRUE)
```

Essa formula e correta somente quando os grupos de um bloco formam uma particao
da populacao, isto e, quando cada unidade pertence a apenas um grupo.

No indicador A1, uma mesma mantenedora pode possuir IES com mais de um tipo de
organizacao academica. Essa sobreposicao e reconhecida no comentario de
`code/02-indicadores-A.R`, linhas 107-108.

Consequentemente, `pct_mantenedoras` nao representa a participacao de cada grupo
no total de mantenedoras unicas nos seguintes blocos:

- `tp_organizacao_academica_harm`
- `catadm_it_tp_organizacao_academica_harm`

Nesses blocos, o denominador e a soma das contagens de mantenedoras por grupo,
que contabiliza mais de uma vez as mantenedoras presentes em diferentes tipos de
organizacao academica.

Exemplo observado para o grupo `Faculdade`, em 2022:

- percentual calculado atualmente: 69,7%;
- percentual em relacao ao total de mantenedoras unicas: 73,7%;
- diferenca: aproximadamente 4,02 pontos percentuais.

Em 2022, a soma das contagens por organizacao academica correspondeu a
aproximadamente 106% do total de mantenedoras unicas.

Direcoes possiveis para correcao:

- calcular esses percentuais usando o total anual de mantenedoras unicas como
  denominador; ou
- manter a formula atual, mas renomear e documentar os percentuais como
  participacoes no total de vinculos mantenedora-organizacao academica.

### [P3] Denominadores iguais a zero produzem `NaN`

Local: `code/helpers/calcula_dimensao_A.R`, linha 55.

Quando todas as contagens `qt_*` de um bloco-ano sao iguais a zero, a formula
calcula `0 / 0` e retorna `NaN`.

Nao foram encontrados percentuais nao finitos nos resultados atuais de A1-A5.
Entretanto, o helper permanece fragil caso dados futuros contenham um bloco-ano
com total igual a zero.

Direcao para correcao:

- definir explicitamente se percentuais com denominador zero devem retornar
  `0` ou `NA`, e implementar esse comportamento no helper.

## Questao metodologica em aberto

### Numerador da taxa de ocupacao de vagas do A2

Local: `code/02-indicadores-A.R`, linhas 160-161.

A taxa e calculada como:

```r
100 * qt_ing / qt_vg_total
```

A formula e aritmeticamente correta. Entretanto, `qt_ing` inclui ingressantes
por outras formas de ingresso, enquanto a documentacao descreve a comparacao
entre vagas abertas em processos seletivos e ingressantes efetivos.

Nos dados atuais, excluir `qt_ing_outra_forma` altera a taxa calculada em ate
aproximadamente 7,07 pontos percentuais.

E necessario confirmar metodologicamente se o numerador pretendido e:

- o total de ingressantes (`qt_ing`); ou
- apenas ingressantes associados as vagas e processos seletivos considerados no
  denominador.

## Percentuais validados

Com os dados limpos atuais:

- todas as colunas `pct_*` somam 100% dentro de cada bloco-ano;
- nao ha percentuais `NA`, `NaN` ou infinitos nos resultados atuais;
- `pct_ies` do A1 esta correto;
- `pct_mantenedoras` do A1 esta correto para o bloco `catadm_it`;
- os percentuais de A2-A5 estao corretos porque seus grupos formam particoes dos
  respectivos totais;
- o A3 calcula 50,7% das matriculas como EaD em 2024, reproduzindo o valor
  descrito na documentacao;
- os arquivos salvos `indicadorA1.xlsx` a `indicadorA5.xlsx` correspondem aos
  calculos produzidos pelo codigo atual.

## Documentacao do helper

A documentacao roxygen de `calcula_dimensao_A()` nao informa que o helper:

- cria automaticamente uma coluna percentual para cada coluna `qt_*`;
- usa como denominador a soma da respectiva coluna dentro de cada bloco-ano; e
- pode produzir `NaN` quando o denominador e zero.

Esse comportamento deve ser documentado para tornar explicito que os percentuais
so possuem interpretacao como distribuicao quando os grupos do bloco formam uma
particao adequada.

## Validacoes executadas

- leitura integral dos arquivos no escopo e da documentacao relacionada;
- verificacao de parse dos dois arquivos;
- execucao isolada de `code/02-indicadores-A.R`, com `write_xlsx()` substituido
  por uma funcao sem efeitos colaterais;
- verificacao das somas dos percentuais por bloco-ano;
- comparacao das somas dos grupos com os totais gerais;
- teste do helper com denominador zero;
- comparacao dos resultados calculados em memoria com os arquivos XLSX salvos.

