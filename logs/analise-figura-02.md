# Analise da Figura 02: mudanca na composicao das IES privadas

Data da analise: 2026-06-12

## Pergunta de pesquisa

A Figura 02 mostra forte aumento da quantidade de Instituicoes de Educacao
Superior (IES) privadas controladas por mantenedoras com fins lucrativos e queda
das IES privadas sem fins lucrativos, especialmente a partir de 2016.

Esta analise investiga:

- se houve mudanca legal ou regulatoria que possa explicar o padrao;
- se o Inep alterou as instrucoes de preenchimento do Censo da Educacao
  Superior;
- quanto da mudanca decorre de entrada e saida de IES;
- quanto decorre da reclassificacao de IES existentes; e
- como o metodo de harmonizacao utilizado no projeto afeta a Figura 02.

## Conclusao principal

Nao foi encontrada mudanca nas instrucoes de preenchimento do Censo da
Educacao Superior que explique a inflexao observada.

A categoria administrativa nao e preenchida ou alterada diretamente pela IES
no sistema Censup. Trata-se de um dado cadastral importado do Cadastro e-MEC.
Os manuais dos Censos de 2016, 2017 e 2018 apresentam as mesmas definicoes de
IES privada com e sem fins lucrativos e informam que esses dados cadastrais nao
podem ser editados no Censup.

O padrao observado e explicado principalmente por uma combinacao de:

1. entrada liquida de novas IES classificadas como com fins lucrativos;
2. mudanca da categoria administrativa de IES existentes, de sem fins para com
   fins lucrativos;
3. transferencias de mantenca, aquisicoes e reorganizacoes societarias;
4. transformacoes juridicas ou atualizacoes cadastrais de mantenedoras,
   frequentemente de associacoes para sociedades `Ltda.` ou `S/S Ltda.`; e
5. regras de harmonizacao aplicadas pelo projeto, que ampliam a mudanca
   observada em relacao a classificacao original do Inep.

Mudancas regulatorias ocorridas em 2016 e 2017 forneceram um contexto
favoravel a reorganizacao e expansao empresarial do setor. Entretanto, os
resultados apresentados aqui nao permitem atribuir causalmente o movimento a
uma norma especifica.

## Serie apresentada na Figura 02

A Figura 02 utiliza o bloco `catadm_it` do indicador A1:

- `code/10-graficos.R`, linhas 78-80;
- `code/02-indicadores-A.R`, linhas 118-123.

`catadm_it` nao corresponde diretamente a variavel original
`TP_CATEGORIA_ADMINISTRATIVA` do Inep. Ela e uma classificacao harmonizada no
nivel mantenedora-ano, construida em `code/01-preparacao.R`, linhas 175-209.

Adicionalmente, antes da construcao da serie, o projeto mantem somente IES que
possuem pelo menos um curso com dados considerados validos no ano:

```r
ces_ies <- ces_ies |>
  inner_join(ces_cursos |> select(co_ies, ano) |> distinct())
```

Portanto, a Figura 02 deve ser interpretada como a quantidade de IES com cursos
validos segundo o pre-processamento do projeto, classificadas pela categoria
administrativa harmonizada da mantenedora no ano.

## Evolucao entre 2016 e 2019

### Classificacao original do Inep

Considerando a categoria administrativa original das IES que permanecem apos
o filtro do projeto:

| Categoria | 2016 | 2019 | Variacao |
|---|---:|---:|---:|
| Privada com fins lucrativos | 1.052 | 1.389 | +337 |
| Privada sem fins lucrativos | 1.058 | 917 | -141 |

O padrao, portanto, ja esta presente na classificacao original do Inep. Ele nao
e criado pela harmonizacao do projeto.

### Classificacao harmonizada da Figura 02

| Categoria | 2016 | 2019 | Variacao |
|---|---:|---:|---:|
| Privada com fins lucrativos | 1.057 | 1.447 | +390 |
| Privada sem fins lucrativos | 1.055 | 861 | -194 |

A harmonizacao aumenta em 53 IES a variacao positiva das IES com fins
lucrativos e aumenta, tambem em 53 IES, a queda das IES sem fins lucrativos.

## Decomposicao da variacao na classificacao original

Entre 2016 e 2019, o aumento liquido de 337 IES com fins lucrativos pode ser
decomposto exatamente em:

| Componente | Efeito sobre IES com fins lucrativos |
|---|---:|
| Entradas menos saidas | +234 |
| Mudancas liquidas de sem fins para com fins | +103 |
| Variacao total | +337 |

A queda liquida de 141 IES sem fins lucrativos pode ser decomposta em:

| Componente | Efeito sobre IES sem fins lucrativos |
|---|---:|
| Entradas menos saidas | -38 |
| Mudancas liquidas para com fins lucrativos | -103 |
| Variacao total | -141 |

Assim, aproximadamente 73% da queda liquida das IES sem fins lucrativos entre
2016 e 2019 decorre da mudanca liquida de categoria, e nao da saida liquida
dessas IES da base:

```text
103 / 141 = 73,0%
```

## Mudancas de categoria de IES existentes

Entre 2017 e 2019, foram identificadas:

- 144 IES que passaram da categoria original sem fins lucrativos para com fins
  lucrativos;
- 41 IES que fizeram o movimento inverso; e
- saldo liquido de 103 IES em direcao a categoria com fins lucrativos.

O maior volume ocorreu em 2017 e 2018:

| Ano | Sem fins para com fins | Com fins para sem fins | Saldo |
|---|---:|---:|---:|
| 2017 | 62 | 30 | +32 |
| 2018 | 64 | 1 | +63 |
| 2019 | 18 | 10 | +8 |
| Total | 144 | 41 | +103 |

Das 144 IES que passaram de sem fins para com fins:

- 43 trocaram de codigo de mantenedora;
- 101 permaneceram com o mesmo codigo de mantenedora;
- entre as 101 que mantiveram o codigo, 69 tambem mudaram o nome da
  mantenedora; e
- entre essas 101, 84 passaram a apresentar nome com indicios de forma
  societaria comercial, como `Ltda.`, `S/S Ltda.`, `S.A.` ou `Eireli`.

Esses resultados indicam que o movimento combina:

- transferencias de mantenca ou aquisicoes;
- transformacoes da natureza juridica de mantenedoras existentes;
- reorganizacoes cadastrais; e
- correcoes ou atualizacoes no Cadastro e-MEC.

Exemplos observados em 2018:

| Nome anterior da mantenedora | Nome posterior | IES afetadas |
|---|---|---:|
| Associacao Unificada Paulista de Ensino Renovado Objetivo - Assupero | Assupero Ensino Superior Ltda. | 21 |
| Associacao Objetivo de Ensino Superior - Assobes | Assobes Ensino Superior S/S Ltda. | 12 |
| Associacao Pernambucana de Ensino Superior - Apesu | Apesu Ensino Superior de Pernambuco S/S Ltda. | 5 |

## Efeito da harmonizacao utilizada no projeto

O projeto cria `catadm_it` como a categoria modal das IES de uma mantenedora em
cada ano e aplica regras adicionais:

- se alguma IES da mantenedora e publica, a mantenedora-ano e classificada como
  publica;
- mantenedoras inicialmente classificadas como sem fins podem ser
  reclassificadas como com fins quando o nome contem determinadas siglas ou
  formas societarias comerciais;
- a categoria especial e convertida em sem fins lucrativos.

Trecho relevante de `code/01-preparacao.R`, linhas 184-207:

```r
catadm_it = moda(tp_categoria_administrativa_harm)[1],
catadm_it = case_when(
  min <= 3 ~ min,
  catadm_it == 5 & ind_restrito == TRUE ~ 4L,
  catadm_it == 5 & min == 4 & ind_amplo == TRUE ~ 4L,
  catadm_it == 7 ~ 5L,
  .default = catadm_it
)
```

Entre 2016 e 2019, a harmonizacao aumenta a mudanca liquida de sem fins para
com fins de 103 para 166 IES. Por isso, ela reforca visualmente a inflexao que
ja existe nos dados originais.

Recomendacao de documentacao:

> A Figura 02 apresenta a quantidade de IES com cursos validos segundo o
> pre-processamento do projeto, por categoria administrativa harmonizada da
> mantenedora no ano. A classificacao harmonizada pode divergir da categoria
> administrativa originalmente registrada pelo Inep.

## Instrucoes do Censo da Educacao Superior

Os manuais dos modulos IES dos Censos de 2016, 2017 e 2018 apresentam
instrucoes substantivamente iguais sobre a categoria administrativa.

Os tres documentos informam que:

- os dados cadastrais sao extraidos do Cadastro e-MEC em dezembro do respectivo
  ano;
- os dados incluem mantenedora, IES e categoria administrativa;
- esses campos nao podem ser alterados no Censup; e
- qualquer alteracao deve ser solicitada e realizada no Cadastro e-MEC.

As definicoes tambem permanecem iguais:

- privada com fins lucrativos: IES mantida por ente privado com fins
  lucrativos;
- privada sem fins lucrativos: IES mantida por ente privado sem fins
  lucrativos, beneficente ou nao beneficente.

Consequentemente, nao ha evidencia de que a inflexao tenha sido causada por
uma nova instrucao de preenchimento do Censo. A mudanca aparece no Censo porque
o Censup incorpora os dados cadastrais atualizados no e-MEC.

Manuais consultados:

- [Manual do Modulo IES - Censo 2016](https://download.inep.gov.br/educacao_superior/censo_superior/questionarios_e_manuais/2016/modulo_IES_2016.pdf)
- [Manual do Modulo IES - Censo 2017](https://download.inep.gov.br/educacao_superior/censo_superior/questionarios_e_manuais/2017/modulo_IES_2017.pdf)
- [Manual do Modulo IES - Censo 2018](https://download.inep.gov.br/educacao_superior/censo_superior/questionarios_e_manuais/2018/modulo_IES-2019-04-10-completo.pdf)

## Contexto legal e regulatorio

### A possibilidade de mantenedoras com fins lucrativos e anterior a 2016

O regime juridico que permite mantenedoras de IES com finalidade lucrativa nao
foi criado no periodo analisado.

O Decreto nº 2.306/1997 ja permitia que mantenedoras privadas assumissem formas
de natureza civil ou comercial e distinguia entidades com e sem finalidade
lucrativa. A Lei nº 9.870/1999 incorporou regras equivalentes a Lei nº
9.131/1995.

Fontes:

- [Decreto nº 2.306/1997](https://www.planalto.gov.br/ccivil_03/decreto/d2306.htm)
- [Lei nº 9.870/1999](https://www.planalto.gov.br/ccivil_03/leis/l9870.htm)

Portanto, nao houve em 2016 ou 2017 uma autorizacao inteiramente nova para que
IES privadas fossem mantidas por entidades com fins lucrativos.

### Simplificacao de transferencias de mantenca

O Decreto nº 8.754/2016 alterou o Decreto nº 5.773/2006 e permitiu que o MEC
previsse procedimento simplificado para transferencia de mantenca entre
pessoas juridicas de um mesmo grupo educacional.

O Decreto nº 9.235/2017 alterou mais profundamente o procedimento. Na regra
anterior, a transferencia deveria ser submetida ao MEC e tramitava como
aditamento sujeito a deliberacao especifica. Na regra de 2017, a alteracao da
mantenca passou a ser comunicada ao MEC em ate sessenta dias apos a assinatura
do instrumento juridico, com verificacao posterior no recredenciamento.

Fontes:

- [Decreto nº 8.754/2016](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2016/decreto/d8754.htm)
- [Decreto nº 5.773/2006](https://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/decreto/d5773.htm)
- [Decreto nº 9.235/2017](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2017/decreto/d9235.htm)

Essas mudancas sao temporalmente compativeis com transferencias, reorganizacoes
e consolidacao empresarial. Contudo, a decomposicao dos dados nao demonstra,
isoladamente, que elas tenham causado a mudanca de composicao.

### Reforma regulatoria da educacao a distancia

O Decreto nº 9.057/2017 e a Portaria Normativa MEC nº 11/2017 flexibilizaram e
ampliaram as possibilidades de oferta de educacao a distancia. Entre outras
mudancas:

- permitiram credenciamento de IES exclusivamente para oferta a distancia;
- permitiram que IES credenciadas criassem polos EaD por ato proprio;
- estabeleceram limites anuais de ate 50, 150 ou 250 novos polos conforme o
  conceito institucional; e
- simplificaram procedimentos relacionados a cursos e polos.

Fontes:

- [Decreto nº 9.057/2017](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2017/decreto/d9057.htm)
- [Portaria Normativa MEC nº 11/2017](https://abmes.org.br/arquivos/legislacoes/Port-Normativa-011-2017-06-20.pdf)

Essas normas sao relevantes para explicar a expansao posterior de cursos, polos
e matriculas, especialmente no segmento privado com fins lucrativos.

Entretanto, elas nao parecem explicar diretamente a inflexao da quantidade de
IES apresentada na Figura 02. Nenhuma das novas IES com fins lucrativos que
entrou na base processada entre 2017 e 2019 ofertava EaD no respectivo ano de
entrada. A reforma da EaD parece ter afetado principalmente a escala de oferta
dentro de IES existentes, e nao a classificacao juridica das IES.

## Interpretacao mais provavel

O padrao observado a partir de 2016 representa uma mudanca real na composicao
institucional do setor privado, mas nao deve ser interpretado simplesmente como
o surgimento de centenas de novas IES lucrativas e o fechamento equivalente de
IES sem fins lucrativos.

Uma parte importante do movimento resulta da conversao ou reclassificacao de
IES existentes. A evidencia e consistente com:

- associacoes sem fins lucrativos transformadas em sociedades empresariais ou
  sociedades simples com fins lucrativos;
- venda e transferencia de IES para grupos empresariais;
- reorganizacao de mantenedoras dentro de grupos educacionais;
- atualizacao tardia ou correcao de registros no Cadastro e-MEC; e
- entrada liquida de novas IES predominantemente classificadas como com fins
  lucrativos.

O contexto regulatorio de 2016 e 2017 provavelmente reduziu custos e barreiras
para reorganizacoes e expansao do setor privado. A reforma da EaD criou
oportunidades adicionais de escala, mas nao explica diretamente a maior parte
da mudanca de classificacao observada na Figura 02.

## Limitacoes

- A analise identifica mudancas cadastrais e de classificacao, mas nao verifica
  individualmente os atos societarios, contratos de aquisicao ou processos
  regulatorios de cada IES.
- Mudanca de nome ou categoria sem mudanca do codigo da mantenedora pode
  representar transformacao juridica, correcao cadastral ou outra atualizacao.
  O microdado do Censo nao permite distinguir essas hipoteses sozinho.
- A relacao temporal entre mudancas regulatorias e a serie nao comprova
  causalidade.
- A Figura 02 usa classificacao harmonizada e um filtro proprio de IES com
  cursos validos. Seus valores nao devem ser apresentados como reproducao
  literal das contagens oficiais publicadas pelo Inep.

## Validacoes executadas

- leitura da serie completa de `report/figures/figura02.xlsx`;
- comparacao entre `catadm_it` e `TP_CATEGORIA_ADMINISTRATIVA`;
- decomposicao anual das entradas, saidas e mudancas de categoria;
- comparacao dos codigos e nomes das mantenedoras antes e depois das mudancas;
- verificacao dos manuais oficiais dos modulos IES dos Censos de 2016, 2017 e
  2018;
- leitura das regras de harmonizacao em `code/01-preparacao.R`;
- verificacao da construcao da Figura 02 em `code/10-graficos.R`;
- consulta aos decretos e a portaria normativa mencionados neste relatorio; e
- verificacao da modalidade ofertada pelas novas IES com fins lucrativos no ano
  de entrada.

Nenhum arquivo de codigo, dado ou resultado foi alterado durante a analise.
