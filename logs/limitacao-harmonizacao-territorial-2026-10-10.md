# Harmonização territorial: mudanças de fronteira desconsideradas

Data: 10 de outubro de 2026.

## 1. Decisão metodológica do projeto

Por decisão do responsável pelo projeto, a harmonização territorial considerará somente emancipações e desmembramentos associados à formação de novos municípios. Serão desconsideradas as transferências de território e as revisões de limites entre municípios que continuam existindo.

A classificação municipal em micro e mesorregiões terá como referência a Divisão Territorial Brasileira de 2010, já utilizada em `code/01-preparacao.R`. Quando a formação de um novo município envolver mais de um município de origem, será necessário reunir os municípios de origem e seus remanescentes em uma unidade comparável durante toda a série. Eventuais uniões de micro e mesorregiões decorrerão desses desmembramentos, não das mudanças de fronteira excluídas do escopo.

Consequentemente, as unidades produzidas serão comparáveis quanto às emancipações consideradas, mas não representarão uma harmonização territorial exata de todas as fronteiras de 2010 a 2024. Municípios com o mesmo código podem ter populações e atividades incorporadas ou retiradas por alterações de fronteira que a harmonização não corrigirá.

## 2. Alcance do levantamento

O levantamento quantificou aproximadamente a população situada em áreas com atribuição municipal diferente entre as malhas de 2010 e 2013, nas oito UFs examinadas: AL, BA, ES, MA, PB, PE, PR e SP.

Essas UFs correspondem aos estados relacionados pelo IBGE no levantamento de 166 alterações de limites municipais ou distritais entre maio de 2012 e abril de 2013. Contudo, o cruzamento das malhas de 2010 e 2013 também incorpora alterações anteriores e diferenças de representação cartográfica. Portanto:

- os resultados não isolam exclusivamente as 166 alterações daquele levantamento;
- não constituem um inventário nacional de todas as mudanças de 2010 a 2013;
- não estimam a população total afetada por todas as mudanças de fronteira de 2010 a 2024;
- a população de referência da estimativa espacial é a do Censo 2010, sem atualização demográfica para 2013;
- diferenças cartográficas nem sempre equivalem a uma mudança legal efetiva de pertencimento municipal.

## 3. Método da estimativa espacial

Foram cruzadas as malhas municipais do IBGE de 2010 e 2013. Os polígonos foram corrigidos quanto à validade geométrica e projetados em EPSG:6933 para cálculo de áreas. Foram selecionadas as interseções em que o código do município de 2010 difere do código do município de 2013.

A população foi obtida da Grade Estatística do Censo 2010, que usa células de 200 m x 200 m em áreas urbanas e 1 km x 1 km em áreas rurais. Para cada interseção, calculou-se:

`população estimada = população da célula × área da célula na área reatribuída / área total da célula`.

Essa distribuição proporcional dentro de cada célula é uma hipótese do cálculo. A própria grade combina localização de domicílios, associação a faces de logradouros e procedimentos de desagregação espacial. Assim, os resultados são estimativas próprias baseadas em dados oficiais, não contagens oficiais exatas de habitantes transferidos.

Os municípios de origem e destino foram associados às micro e mesorregiões da DTB 2010, disponível em `data/raw/IBGE/dtb_2010.xls`. Transferências entre municípios da mesma região não entram no total de população que cruza esse nível regional.

Foi verificada a soma das frações de interseção por célula: nenhuma superou 1 acima da tolerância de 0,000001, e não foram encontrados valores populacionais diferentes para um mesmo identificador de célula nas partes combinadas.

## 4. População aproximadamente atingida

Valores arredondados. As três colunas representam subconjuntos e não devem ser somadas.

| UF | Entre municípios | Entre microrregiões | Entre mesorregiões |
|---|---:|---:|---:|
| AL | 16.900 | 4.200 | 1.200 |
| BA | 65.900 | 20.400 | 7.700 |
| ES | < 1 | < 1 | < 1 |
| MA | 31.700 | 10.200 | 6.300 |
| PB | 10.400 | 700 | aproximadamente 0 |
| PE | 8.300 | 2.000 | 1.900 |
| PR | 1.600 | 100 | 100 |
| SP | 11.500 | 300 | 100 |
| **Total aproximado** | **146.000** | **38.000** | **17.000** |

Os totais calculados antes do arredondamento foram 146.251,7, 37.864,0 e 17.343,0, respectivamente. Essa precisão numérica não implica precisão equivalente da estimativa populacional.

Cerca de 74% da população estimada nas áreas reatribuídas permanece na mesma microrregião de 2010; aproximadamente 88% permanece na mesma mesorregião. Como referência de escala, os três totais equivalem a aproximadamente 0,077%, 0,020% e 0,009% da população brasileira de 2010. Esses percentuais não transformam o levantamento parcial em uma estimativa nacional de todas as alterações.

### Verificação com setores censitários

O cálculo também foi realizado com população de setores censitários de 2010, distribuída proporcionalmente à área quando o setor é cortado pela fronteira. Nas sete UFs comparáveis, excluindo SP, resultou em 127.801,5 pessoas, contra 134.769,0 pela grade: diferença de aproximadamente 5%. Os totais entre microrregiões e mesorregiões pelo método de setores foram 36.789,5 e 16.992,3.

Foram identificados 112 setores censitários cujas áreas ficaram inteiramente atribuídas a outros municípios no cruzamento, somando 30.895 moradores em 2010. A existência de população nas áreas reatribuídas, portanto, não depende somente da hipótese de distribuição proporcional em unidades parcialmente cortadas.

A comparação entre os dois métodos verifica a ordem de grandeza; não é um intervalo de confiança nem elimina as incertezas de geolocalização e representação cartográfica. Valores próximos de zero, como os do ES, não constituem comprovação individual de ausência de moradores em cada alteração legal.

## 5. Efeito sobre as regiões de 2010

Para cada região, foram calculados o saldo populacional estimado, `entrada - saída`, e o movimento bruto, `entrada + saída`, divididos pela população da região no Censo 2010. O movimento bruto evita que transferências em sentidos opostos se anulem na avaliação.

Entre as microrregiões, os maiores saldos relativos estimados incluem:

- Baixo Parnaíba Maranhense: -3,02%;
- Livramento do Brumado: -2,27%;
- Chapadinha: +2,07%.

Doze microrregiões superam 1% de movimento bruto. O maior percentual é o de Traipu, aproximadamente 4,41%, embora seu saldo seja cerca de +1,00%.

Entre as mesorregiões, o maior saldo absoluto estimado é 0,36%, no Sul Maranhense. O maior movimento bruto é aproximadamente 0,55%, no Extremo Oeste Baiano. Nenhuma mesorregião examinada supera 1% de movimento bruto.

Essas diferenças são medidas de descompasso populacional entre classificações territoriais, não estimativas diretas de erro em indicadores educacionais.

## 6. Casos documentados nas estimativas oficiais de 2013

A comparação da publicação inicial e da versão definitiva das estimativas para a mesma data, 1º de julho de 2013, permite identificar dois remanejamentos registrados expressamente pelo TCU:

| Transferência | População remanejada nas estimativas | Classificação regional de 2010 |
|---|---:|---|
| Santa Quitéria do Maranhão → Urbano Santos | 4.502 | Baixo Parnaíba Maranhense → Chapadinha; mesma mesorregião, Leste Maranhense |
| Bayeux → Santa Rita | 7.593 | Mesma microrregião, João Pessoa, e mesma mesorregião, Mata Paraibana |
| **Total desses dois casos** | **12.095** | |

Santa Quitéria do Maranhão passou de 29.208 para 24.706 habitantes e Urbano Santos de 26.833 para 31.335. Bayeux passou de 102.789 para 95.196 e Santa Rita de 125.278 para 132.871.

As perdas dos municípios doadores correspondem a 15,4% e 7,4% das estimativas inicialmente publicadas. Como a data de referência é a mesma, as diferenças não representam crescimento demográfico entre anos. São habitantes nas estimativas oficiais, não uma enumeração censitária realizada em 2013.

Esses 12.095 habitantes não devem ser adicionados ao total espacial: há sobreposição dos casos, datas populacionais diferentes e métodos distintos. Tampouco constituem o total de remanejamentos de 2013.

## 7. Limitação a registrar nos produtos do projeto

> A harmonização geográfica adota a classificação municipal e regional de 2010 e corrige as emancipações e os desmembramentos associados à formação de novos municípios. Não corrige transferências de território ou revisões de fronteiras entre municípios que continuam existindo. Consequentemente, mudanças territoriais residuais podem afetar a comparação dos indicadores ao longo do tempo. Um levantamento aproximado das diferenças entre as malhas de 2010 e 2013, em oito UFs, identificou cerca de 146 mil moradores de 2010 em áreas com atribuição municipal diferente, dos quais aproximadamente 38 mil cruzam microrregiões e 17 mil cruzam mesorregiões da classificação de 2010. Esses valores não abrangem todas as mudanças de 2010 a 2024. O efeito populacional é relativamente pequeno no agregado mesorregional, mas pode ser relevante em determinados municípios e microrregiões. A população afetada não quantifica diretamente matrículas, instituições ou outros resultados educacionais afetados.

## 8. Fontes e rastreabilidade

- [IBGE: malhas municipais de 2010](https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2010/).
- [IBGE: malhas municipais de 2013](https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2013/).
- [IBGE: Grade Estatística do Censo 2010, dados](https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/).
- [IBGE: metodologia da Grade Estatística](https://geoftp.ibge.gov.br/recortes_para_fins_estatisticos/grade_estatistica/censo_2010/grade_estatistica.pdf).
- [IBGE: agregados por setores censitários de 2010](https://ftp.ibge.gov.br/Censos/Censo_Demografico_2010/Resultados_do_Universo/Agregados_por_Setores_Censitarios/), população total na variável V001 dos arquivos Pessoa13.
- [IBGE/SIDRA: população municipal dos Censos 2000 e 2010, tabela 202](https://servicodados.ibge.gov.br/api/v3/agregados/202/periodos/2000%7C2010/variaveis/93?localidades=N6%5Ball%5D&classificacao=2%5B0%5D%7C1%5B0%5D), utilizando somente 2010 como denominador.
- DTB 2010: `data/raw/IBGE/dtb_2010.xls`, arquivo já existente no projeto.
- [IBGE: metodologia das estimativas municipais de 2013](https://biblioteca.ibge.gov.br/visualizacao/livros/liv97742.pdf), descrição das 166 alterações entre maio de 2012 e abril de 2013.
- [IBGE: estimativas de 2013 inicialmente publicadas no DOU](https://ftp.ibge.gov.br/Estimativas_de_Populacao/Estimativas_2013/estimativa_2013_dou_xls.zip).
- [IBGE: estimativas definitivas de 2013](https://ftp.ibge.gov.br/Estimativas_de_Populacao/Estimativas_2013/estimativa_2013_TCU_20170614.pdf).
- [TCU: cálculo do FPM de 2014, relatório, item 14](https://portal.tcu.gov.br/data/files/03/46/1E/DD/766519101C466F09F18818A8/FPM-2014%20DNT2013_133.pdf), documentação do remanejamento de população nos dois pares acima.

Os cálculos exploratórios foram executados em R com `sf`, `dplyr`, `readxl` e `jsonlite`. Os downloads e resultados intermediários permaneceram em diretório temporário, fora de `data/raw/`. Este relatório registra método, fontes e resultados; a reprodução completa requer recuperar os dados e refazer os cruzamentos, pois não foi incorporado um script de cálculo ao projeto.
