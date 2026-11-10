# Tamanho dos CSVs dos indicadores I

Relatório atualizado em 02/11/2026, 17:04:58 (horário de São Paulo), a partir do código e dos 26 CSVs existentes em results/. MB = 1.000.000 bytes. Os scripts e os CSVs de produção não foram alterados por esta análise.

## Base atual e mudanças desde a última atualização

O código e os 26 CSVs agora incluem somente os anos de 2010 e 2024. O ano de 2017 foi retirado. Os blocos de desagregação são os mesmos da atualização anterior: sete em I1, quatro em I2 (total, categoria administrativa, tamanho da mantenedora e modalidade), quatro em I3 (total, categoria, tamanho e área) e cinco em I4–I6 (total, categoria, tamanho, área e modalidade).

Os 26 CSVs têm os conjuntos de anos e blocos definidos no código. As linhas de cada combinação de território, bloco, grupo e série estão juntas e seus anos estão em ordem crescente. Não há arquivos pendentes por incompatibilidade de anos ou blocos. Essas verificações não constituem uma nova validação metodológica dos valores.

As comparações long e wide e a supressão de cada bloco restante foram recalculadas com base nos arquivos atuais, já limitados a dois anos.

## Redução já obtida

A versão original deste chat tinha mais cruzamentos e três anos. A versão anterior do relatório já tinha os cortes de blocos e ainda incluía 2010, 2017 e 2024. A comparação com a versão anterior mede o efeito líquido desta atualização, incluindo eventuais mudanças no conjunto de grupos observados. Todos os tamanhos atuais foram medidos em CSVs existentes.

| Nível | Original MB | Anterior, três anos MB | Atual, dois anos MB | Economia nesta atualização MB | Redução nesta atualização | Redução desde o original |
|---|---:|---:|---:|---:|---:|---:|
| Mesorregião AMC | 42,30 | 14,42 | 9,62 | 4,80 | 33,3% | 77,3% |
| Microrregião AMC | 164,96 | 55,75 | 37,19 | 18,55 | 33,3% | 77,5% |
| Município AMC | 1.640,06 | 551,42 | 367,80 | 183,62 | 33,3% | 77,6% |

### Comparação por arquivo

| Arquivo | Original MB | Anterior MB | Atual MB | Redução nesta atualização | Redução desde o original |
|---|---:|---:|---:|---:|---:|
| indicadorI1.csv | 0,11 | 0,11 | 0,07 | 33,3% | 33,3% |
| indicadorI2a.csv | 0,18 | 0,05 | 0,04 | 33,2% | 79,8% |
| indicadorI2b.csv | 1,00 | 0,30 | 0,20 | 33,3% | 79,8% |
| indicadorI2c.csv | 5,21 | 1,59 | 1,06 | 33,3% | 79,6% |
| indicadorI2d.csv | 20,46 | 6,20 | 4,13 | 33,3% | 79,8% |
| indicadorI2e.csv | 207,29 | 62,96 | 41,97 | 33,3% | 79,8% |
| indicadorI3a.csv | 0,10 | 0,10 | 0,07 | 33,3% | 33,3% |
| indicadorI3b.csv | 0,57 | 0,57 | 0,38 | 33,3% | 33,3% |
| indicadorI3c.csv | 2,98 | 2,98 | 1,98 | 33,4% | 33,4% |
| indicadorI3d.csv | 11,44 | 11,44 | 7,62 | 33,3% | 33,3% |
| indicadorI3e.csv | 113,41 | 113,41 | 75,40 | 33,5% | 33,5% |
| indicadorI4a.csv | 0,40 | 0,11 | 0,08 | 33,3% | 80,9% |
| indicadorI4b.csv | 2,20 | 0,63 | 0,42 | 33,3% | 80,9% |
| indicadorI4c.csv | 11,40 | 3,29 | 2,20 | 33,3% | 80,7% |
| indicadorI4d.csv | 44,45 | 12,74 | 8,50 | 33,3% | 80,9% |
| indicadorI4e.csv | 440,70 | 125,37 | 83,72 | 33,2% | 81,0% |
| indicadorI5a.csv | 0,40 | 0,11 | 0,08 | 33,3% | 81,0% |
| indicadorI5b.csv | 2,19 | 0,63 | 0,42 | 33,3% | 80,9% |
| indicadorI5c.csv | 11,36 | 3,28 | 2,19 | 33,3% | 80,7% |
| indicadorI5d.csv | 44,32 | 12,69 | 8,47 | 33,2% | 80,9% |
| indicadorI5e.csv | 438,79 | 124,71 | 83,30 | 33,2% | 81,0% |
| indicadorI6a.csv | 0,40 | 0,11 | 0,08 | 33,2% | 80,9% |
| indicadorI6b.csv | 2,19 | 0,63 | 0,42 | 33,3% | 80,9% |
| indicadorI6c.csv | 11,36 | 3,28 | 2,19 | 33,3% | 80,7% |
| indicadorI6d.csv | 44,28 | 12,67 | 8,46 | 33,3% | 80,9% |
| indicadorI6e.csv | 439,88 | 124,98 | 83,42 | 33,3% | 81,0% |

## Recomendação

Manter CSV long e avaliar duas medidas adicionais: transferir os nomes e descrições repetidos para dicionários CSV e omitir explicitamente as linhas de valor zero. Essas medidas preservam os valores numéricos e os blocos restantes, desde que as referências permitam reconstruir o universo original.

Ao omitir zeros, é necessário fornecer os territórios-anos e as combinações válidas de bloco, grupo e série por indicador. Somente a ausência dentro desse universo significa zero. Grupos nunca observados não podem ser confundidos com grupos de valor zero. NA deve ser preservado. A economia medida inclui todos os zeros atuais, tanto observados quanto acrescentados pela complementação geográfica.

## Economia adicional mantendo long por nível geográfico

Totais de I2 a I6 nos CSVs atuais. As reduções desta seção usam a base atual de dois anos. Os tamanhos com dicionários excluem as referências auxiliares.

| Nível | Atual MB | Omitir zeros (MB; redução) | Rótulos em dicionários (MB; redução) | Ambas (MB; redução) |
|---|---:|---:|---:|---:|---:|
| Mesorregião AMC | 9,62 | 8,11; 15,7% | 3,08; 68,0% | 2,65; 72,4% |
| Microrregião AMC | 37,19 | 24,12; 35,2% | 12,26; 67,0% | 8,35; 77,6% |
| Município AMC | 367,80 | 68,74; 81,3% | 117,61; 68,0% | 24,40; 93,4% |

## Cenários long por arquivo

“Dicionários” remove indicador_nome, bloco_nome, grupo_nome, serie_nome, unidade e os nomes geográficos. Os códigos, ano, serie_var e valor continuam no CSV principal. As descrições removidas devem constar nas referências auxiliares. Exemplo atualizado para I4 municipal: os dicionários de geografia, blocos, grupos e séries somam 127.271 bytes (0,127 MB), além do pequeno registro do nome do indicador. Eles incluem 5.560 territórios e 24 combinações de bloco e grupo.

| Arquivo | Nível | Atual MB | Linhas | Sem zeros MB | Redução | Com dicionários MB | Redução | Sem zeros e com dicionários MB | Redução |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| indicadorI1.csv | Nacional | 0,07 | 348 | 0,07 | 0,0% | 0,02 | 67,8% | 0,02 | 67,8% |
| indicadorI2a.csv | Região | 0,04 | 260 | 0,04 | 0,0% | 0,01 | 66,5% | 0,01 | 66,5% |
| indicadorI2b.csv | UF | 0,20 | 1.404 | 0,19 | 7,0% | 0,07 | 66,6% | 0,06 | 68,9% |
| indicadorI2c.csv | Mesorregião AMC | 1,06 | 7.124 | 0,94 | 11,7% | 0,32 | 70,0% | 0,28 | 73,3% |
| indicadorI2d.csv | Microrregião AMC | 4,13 | 28.860 | 2,99 | 27,5% | 1,31 | 68,3% | 0,97 | 76,6% |
| indicadorI2e.csv | Município AMC | 41,97 | 289.120 | 9,73 | 76,8% | 13,67 | 67,4% | 3,28 | 92,2% |
| indicadorI3a.csv | Região | 0,07 | 440 | 0,07 | 5,4% | 0,03 | 62,1% | 0,03 | 63,8% |
| indicadorI3b.csv | UF | 0,38 | 2.376 | 0,32 | 15,2% | 0,14 | 62,6% | 0,12 | 67,4% |
| indicadorI3c.csv | Mesorregião AMC | 1,98 | 12.056 | 1,42 | 28,7% | 0,67 | 66,3% | 0,50 | 74,7% |
| indicadorI3d.csv | Microrregião AMC | 7,62 | 48.840 | 3,36 | 56,0% | 2,62 | 65,7% | 1,26 | 83,4% |
| indicadorI3e.csv | Município AMC | 75,40 | 489.280 | 2,58 | 96,6% | 25,17 | 66,6% | 1,00 | 98,7% |
| indicadorI4a.csv | Região | 0,08 | 480 | 0,08 | 0,8% | 0,03 | 65,0% | 0,03 | 65,2% |
| indicadorI4b.csv | UF | 0,42 | 2.592 | 0,40 | 5,6% | 0,15 | 65,2% | 0,14 | 66,9% |
| indicadorI4c.csv | Mesorregião AMC | 2,20 | 13.152 | 1,94 | 11,7% | 0,69 | 68,4% | 0,62 | 71,6% |
| indicadorI4d.csv | Microrregião AMC | 8,50 | 53.280 | 6,05 | 28,9% | 2,77 | 67,5% | 2,07 | 75,7% |
| indicadorI4e.csv | Município AMC | 83,72 | 533.760 | 19,91 | 76,2% | 26,14 | 68,8% | 7,04 | 91,6% |
| indicadorI5a.csv | Região | 0,08 | 480 | 0,08 | 0,8% | 0,03 | 64,7% | 0,03 | 64,9% |
| indicadorI5b.csv | UF | 0,42 | 2.592 | 0,40 | 4,7% | 0,15 | 64,9% | 0,14 | 66,3% |
| indicadorI5c.csv | Mesorregião AMC | 2,19 | 13.152 | 1,97 | 9,8% | 0,70 | 68,1% | 0,64 | 70,7% |
| indicadorI5d.csv | Microrregião AMC | 8,47 | 53.280 | 6,30 | 25,6% | 2,79 | 67,1% | 2,17 | 74,4% |
| indicadorI5e.csv | Município AMC | 83,30 | 533.760 | 21,33 | 74,4% | 26,25 | 68,5% | 7,59 | 90,9% |
| indicadorI6a.csv | Região | 0,08 | 480 | 0,07 | 3,5% | 0,03 | 64,5% | 0,03 | 65,7% |
| indicadorI6b.csv | UF | 0,42 | 2.592 | 0,39 | 7,9% | 0,15 | 64,8% | 0,14 | 67,3% |
| indicadorI6c.csv | Mesorregião AMC | 2,19 | 13.152 | 1,85 | 15,7% | 0,70 | 68,1% | 0,60 | 72,4% |
| indicadorI6d.csv | Microrregião AMC | 8,46 | 53.280 | 5,42 | 36,0% | 2,77 | 67,2% | 1,88 | 77,7% |
| indicadorI6e.csv | Município AMC | 83,42 | 533.760 | 15,18 | 81,8% | 26,38 | 68,4% | 5,48 | 93,4% |

## Comparação com wide

Três variantes, sem omitir zeros e sem arredondar valores:

- Anos: 2010 e 2024 em colunas valor_2010 e valor_2024. A série, seu nome e a unidade continuam nas linhas.
- Séries: as séries passam a colunas, por exemplo qt_ing e pct_ing. Ano continua nas linhas. serie_nome e unidade passam a ser metadados associados às colunas.
- Anos e séries: uma linha por território, bloco e grupo; quatro colunas de valores para arquivos com duas séries e dois anos. Os metadados de série e unidade ficam associados às colunas.

As três variantes preservam os códigos e os nomes de geografia, bloco e grupo. indicador_code e indicador_nome continuam preenchidos apenas na primeira linha. Os percentuais de redução usam os CSVs atuais de dois anos como base.

| Arquivo | Atual MB | Wide anos MB | Redução | Wide séries MB | Redução | Wide anos e séries MB | Redução |
|---|---:|---:|---:|---:|---:|---:|---:|
| indicadorI1.csv | 0,07 | 0,04 | 47,8% | 0,03 | 58,7% | 0,02 | 77,1% |
| indicadorI2a.csv | 0,04 | 0,02 | 50,3% | 0,01 | 61,7% | 0,01 | 80,2% |
| indicadorI2b.csv | 0,20 | 0,10 | 50,8% | 0,08 | 61,9% | 0,04 | 80,8% |
| indicadorI2c.csv | 1,06 | 0,52 | 50,9% | 0,41 | 61,6% | 0,20 | 80,8% |
| indicadorI2d.csv | 4,13 | 2,03 | 51,0% | 1,56 | 62,2% | 0,78 | 81,2% |
| indicadorI2e.csv | 41,97 | 20,56 | 51,0% | 15,93 | 62,0% | 7,90 | 81,2% |
| indicadorI3a.csv | 0,07 | 0,04 | 47,6% | 0,03 | 57,3% | 0,02 | 75,4% |
| indicadorI3b.csv | 0,38 | 0,20 | 48,2% | 0,16 | 57,7% | 0,09 | 76,2% |
| indicadorI3c.csv | 1,98 | 1,02 | 48,7% | 0,83 | 57,9% | 0,46 | 76,9% |
| indicadorI3d.csv | 7,62 | 3,85 | 49,5% | 3,10 | 59,3% | 1,65 | 78,3% |
| indicadorI3e.csv | 75,40 | 37,05 | 50,9% | 29,59 | 60,8% | 14,76 | 80,4% |
| indicadorI4a.csv | 0,08 | 0,04 | 47,5% | 0,03 | 57,7% | 0,02 | 75,6% |
| indicadorI4b.csv | 0,42 | 0,22 | 47,9% | 0,18 | 57,9% | 0,10 | 76,1% |
| indicadorI4c.csv | 2,20 | 1,14 | 48,2% | 0,93 | 57,9% | 0,52 | 76,4% |
| indicadorI4d.csv | 8,50 | 4,37 | 48,7% | 3,50 | 58,8% | 1,93 | 77,3% |
| indicadorI4e.csv | 83,72 | 41,69 | 50,2% | 33,01 | 60,6% | 17,00 | 79,7% |
| indicadorI5a.csv | 0,08 | 0,04 | 47,4% | 0,03 | 57,4% | 0,02 | 75,3% |
| indicadorI5b.csv | 0,42 | 0,22 | 47,8% | 0,18 | 57,5% | 0,10 | 75,8% |
| indicadorI5c.csv | 2,19 | 1,14 | 48,0% | 0,93 | 57,5% | 0,52 | 76,0% |
| indicadorI5d.csv | 8,47 | 4,36 | 48,5% | 3,52 | 58,4% | 1,96 | 76,9% |
| indicadorI5e.csv | 83,30 | 41,53 | 50,1% | 33,12 | 60,2% | 17,11 | 79,5% |
| indicadorI6a.csv | 0,08 | 0,04 | 47,7% | 0,03 | 57,9% | 0,02 | 75,8% |
| indicadorI6b.csv | 0,42 | 0,22 | 48,0% | 0,18 | 58,1% | 0,10 | 76,3% |
| indicadorI6c.csv | 2,19 | 1,13 | 48,3% | 0,92 | 58,1% | 0,51 | 76,6% |
| indicadorI6d.csv | 8,46 | 4,32 | 48,9% | 3,45 | 59,2% | 1,89 | 77,7% |
| indicadorI6e.csv | 83,42 | 41,39 | 50,4% | 32,71 | 60,8% | 16,70 | 80,0% |

## Supressão de cada bloco restante

Cada linha é um cenário independente: retira somente aquele bloco e mantém as demais linhas e colunas. Os blocos já retirados do código não aparecem nessas simulações. Em I1 ainda existem cruzamentos: retirar um bloco simples não retira automaticamente os cruzamentos que usam a mesma variável.

As economias em bytes de blocos distintos podem ser somadas. A identificação do indicador é recolocada na primeira linha restante quando necessário, inclusive quando o bloco retirado é o primeiro do arquivo.

### indicadorI1.csv — Nacional

Tamanho atual medido no CSV: 0,07 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Total | total | 4 | 0,00 | 0,5% | 0,07 |
| Categoria Administrativa | catadm_it | 20 | 0,00 | 3,7% | 0,07 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 20 | 0,00 | 4,4% | 0,07 |
| Modalidade de ensino | tp_modalidade_ensino | 8 | 0,00 | 1,5% | 0,07 |
| Categoria Administrativa + Modalidade de ensino | catadm_it_tp_modalidade_ensino | 40 | 0,01 | 10,9% | 0,07 |
| Categoria Administrativa + Área de conhecimento (CINE Brasil) | catadm_it_co_cine_area_geral | 216 | 0,05 | 66,2% | 0,03 |
| Tamanho de mantenedoras por número de matrículas + Modalidade de ensino | fx_ranking_tp_modalidade_ensino | 40 | 0,01 | 12,4% | 0,07 |

### indicadorI2a.csv — Região

Tamanho atual medido no CSV: 0,04 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 100 | 0,01 | 36,2% | 0,02 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 100 | 0,02 | 43,2% | 0,02 |
| Total | total | 20 | 0,00 | 5,2% | 0,03 |
| Modalidade de ensino | tp_modalidade_ensino | 40 | 0,01 | 14,8% | 0,03 |

### indicadorI2b.csv — UF

Tamanho atual medido no CSV: 0,20 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 540 | 0,07 | 36,4% | 0,13 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 540 | 0,09 | 43,4% | 0,11 |
| Total | total | 108 | 0,01 | 5,2% | 0,19 |
| Modalidade de ensino | tp_modalidade_ensino | 216 | 0,03 | 14,9% | 0,17 |

### indicadorI2c.csv — Mesorregião AMC

Tamanho atual medido no CSV: 1,06 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 2.740 | 0,39 | 36,5% | 0,67 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 2.740 | 0,46 | 43,3% | 0,60 |
| Total | total | 548 | 0,06 | 5,3% | 1,00 |
| Modalidade de ensino | tp_modalidade_ensino | 1.096 | 0,16 | 14,9% | 0,90 |

### indicadorI2d.csv — Microrregião AMC

Tamanho atual medido no CSV: 4,13 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 11.100 | 1,50 | 36,4% | 2,63 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 11.100 | 1,80 | 43,5% | 2,33 |
| Total | total | 2.220 | 0,22 | 5,2% | 3,92 |
| Modalidade de ensino | tp_modalidade_ensino | 4.440 | 0,61 | 14,9% | 3,52 |

### indicadorI2e.csv — Município AMC

Tamanho atual medido no CSV: 41,97 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 111.200 | 15,30 | 36,5% | 26,67 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 111.200 | 18,24 | 43,5% | 23,73 |
| Total | total | 22.240 | 2,20 | 5,2% | 39,78 |
| Modalidade de ensino | tp_modalidade_ensino | 44.480 | 6,23 | 14,9% | 35,74 |

### indicadorI3a.csv — Região

Tamanho atual medido no CSV: 0,07 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 100 | 0,01 | 20,2% | 0,06 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 220 | 0,04 | 52,8% | 0,03 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 100 | 0,02 | 23,7% | 0,05 |
| Total | total | 20 | 0,00 | 2,9% | 0,07 |

### indicadorI3b.csv — UF

Tamanho atual medido no CSV: 0,38 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 540 | 0,08 | 20,2% | 0,30 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 1.188 | 0,20 | 53,2% | 0,18 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 540 | 0,09 | 23,5% | 0,29 |
| Total | total | 108 | 0,01 | 3,0% | 0,37 |

### indicadorI3c.csv — Mesorregião AMC

Tamanho atual medido no CSV: 1,98 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 2.740 | 0,40 | 20,4% | 1,58 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 6.028 | 1,05 | 53,1% | 0,93 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 2.740 | 0,47 | 23,5% | 1,52 |
| Total | total | 548 | 0,06 | 3,1% | 1,92 |

### indicadorI3d.csv — Microrregião AMC

Tamanho atual medido no CSV: 7,62 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 11.100 | 1,54 | 20,2% | 6,09 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 24.420 | 4,05 | 53,1% | 3,58 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 11.100 | 1,81 | 23,7% | 5,82 |
| Total | total | 2.220 | 0,23 | 3,0% | 7,39 |

### indicadorI3e.csv — Município AMC

Tamanho atual medido no CSV: 75,40 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 111.200 | 15,17 | 20,1% | 60,23 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 244.640 | 39,95 | 53,0% | 35,45 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 111.200 | 18,10 | 24,0% | 57,30 |
| Total | total | 22.240 | 2,18 | 2,9% | 73,22 |

### indicadorI4a.csv — Região

Tamanho atual medido no CSV: 0,08 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 100 | 0,01 | 18,6% | 0,06 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 220 | 0,04 | 48,7% | 0,04 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 100 | 0,02 | 22,1% | 0,06 |
| Total | total | 20 | 0,00 | 2,7% | 0,07 |
| Modalidade de ensino | tp_modalidade_ensino | 40 | 0,01 | 7,6% | 0,07 |

### indicadorI4b.csv — UF

Tamanho atual medido no CSV: 0,42 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 540 | 0,08 | 18,6% | 0,34 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 1.188 | 0,21 | 48,9% | 0,21 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 540 | 0,09 | 22,1% | 0,33 |
| Total | total | 108 | 0,01 | 2,8% | 0,41 |
| Modalidade de ensino | tp_modalidade_ensino | 216 | 0,03 | 7,6% | 0,39 |

### indicadorI4c.csv — Mesorregião AMC

Tamanho atual medido no CSV: 2,20 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 2.740 | 0,41 | 18,7% | 1,79 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 6.028 | 1,07 | 48,8% | 1,13 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 2.740 | 0,48 | 22,0% | 1,71 |
| Total | total | 548 | 0,06 | 2,8% | 2,13 |
| Modalidade de ensino | tp_modalidade_ensino | 1.096 | 0,17 | 7,7% | 2,03 |

### indicadorI4d.csv — Microrregião AMC

Tamanho atual medido no CSV: 8,50 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 11.100 | 1,58 | 18,6% | 6,93 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 24.420 | 4,16 | 48,9% | 4,35 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 11.100 | 1,88 | 22,1% | 6,63 |
| Total | total | 2.220 | 0,24 | 2,8% | 8,27 |
| Modalidade de ensino | tp_modalidade_ensino | 4.440 | 0,66 | 7,7% | 7,85 |

### indicadorI4e.csv — Município AMC

Tamanho atual medido no CSV: 83,72 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 111.200 | 15,54 | 18,6% | 68,18 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 244.640 | 40,97 | 48,9% | 42,75 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 111.200 | 18,51 | 22,1% | 65,21 |
| Total | total | 22.240 | 2,31 | 2,8% | 81,41 |
| Modalidade de ensino | tp_modalidade_ensino | 44.480 | 6,39 | 7,6% | 77,33 |

### indicadorI5a.csv — Região

Tamanho atual medido no CSV: 0,08 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 100 | 0,01 | 18,6% | 0,06 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 220 | 0,04 | 48,7% | 0,04 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 100 | 0,02 | 22,1% | 0,06 |
| Total | total | 20 | 0,00 | 2,7% | 0,07 |
| Modalidade de ensino | tp_modalidade_ensino | 40 | 0,01 | 7,6% | 0,07 |

### indicadorI5b.csv — UF

Tamanho atual medido no CSV: 0,42 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 540 | 0,08 | 18,6% | 0,34 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 1.188 | 0,20 | 48,8% | 0,21 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 540 | 0,09 | 22,1% | 0,33 |
| Total | total | 108 | 0,01 | 2,8% | 0,41 |
| Modalidade de ensino | tp_modalidade_ensino | 216 | 0,03 | 7,6% | 0,39 |

### indicadorI5c.csv — Mesorregião AMC

Tamanho atual medido no CSV: 2,19 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 2.740 | 0,41 | 18,7% | 1,78 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 6.028 | 1,07 | 48,7% | 1,12 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 2.740 | 0,48 | 22,1% | 1,71 |
| Total | total | 548 | 0,06 | 2,8% | 2,13 |
| Modalidade de ensino | tp_modalidade_ensino | 1.096 | 0,17 | 7,7% | 2,02 |

### indicadorI5d.csv — Microrregião AMC

Tamanho atual medido no CSV: 8,47 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 11.100 | 1,57 | 18,6% | 6,90 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 24.420 | 4,14 | 48,8% | 4,34 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 11.100 | 1,87 | 22,1% | 6,60 |
| Total | total | 2.220 | 0,24 | 2,8% | 8,24 |
| Modalidade de ensino | tp_modalidade_ensino | 4.440 | 0,65 | 7,7% | 7,82 |

### indicadorI5e.csv — Município AMC

Tamanho atual medido no CSV: 83,30 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 111.200 | 15,46 | 18,6% | 67,84 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 244.640 | 40,76 | 48,9% | 42,54 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 111.200 | 18,42 | 22,1% | 64,87 |
| Total | total | 22.240 | 2,29 | 2,8% | 81,00 |
| Modalidade de ensino | tp_modalidade_ensino | 44.480 | 6,36 | 7,6% | 76,93 |

### indicadorI6a.csv — Região

Tamanho atual medido no CSV: 0,08 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 100 | 0,01 | 18,7% | 0,06 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 220 | 0,04 | 48,6% | 0,04 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 100 | 0,02 | 22,1% | 0,06 |
| Total | total | 20 | 0,00 | 2,7% | 0,07 |
| Modalidade de ensino | tp_modalidade_ensino | 40 | 0,01 | 7,6% | 0,07 |

### indicadorI6b.csv — UF

Tamanho atual medido no CSV: 0,42 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 540 | 0,08 | 18,6% | 0,34 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 1.188 | 0,20 | 48,8% | 0,21 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 540 | 0,09 | 22,1% | 0,33 |
| Total | total | 108 | 0,01 | 2,8% | 0,41 |
| Modalidade de ensino | tp_modalidade_ensino | 216 | 0,03 | 7,7% | 0,39 |

### indicadorI6c.csv — Mesorregião AMC

Tamanho atual medido no CSV: 2,19 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 2.740 | 0,41 | 18,7% | 1,78 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 6.028 | 1,06 | 48,6% | 1,12 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 2.740 | 0,48 | 22,1% | 1,71 |
| Total | total | 548 | 0,06 | 2,8% | 2,13 |
| Modalidade de ensino | tp_modalidade_ensino | 1.096 | 0,17 | 7,7% | 2,02 |

### indicadorI6d.csv — Microrregião AMC

Tamanho atual medido no CSV: 8,46 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 11.100 | 1,57 | 18,6% | 6,88 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 24.420 | 4,12 | 48,8% | 4,33 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 11.100 | 1,87 | 22,1% | 6,59 |
| Total | total | 2.220 | 0,24 | 2,8% | 8,22 |
| Modalidade de ensino | tp_modalidade_ensino | 4.440 | 0,65 | 7,7% | 7,80 |

### indicadorI6e.csv — Município AMC

Tamanho atual medido no CSV: 83,42 MB.

| Bloco suprimido | Código | Linhas retiradas | Economia MB | Redução | Tamanho restante MB |
|---|---|---:|---:|---:|---:|
| Categoria Administrativa | catadm_it | 111.200 | 15,52 | 18,6% | 67,90 |
| Área de conhecimento (CINE Brasil) | co_cine_area_geral | 244.640 | 40,75 | 48,9% | 42,67 |
| Tamanho de mantenedoras por número de matrículas | fx_ranking | 111.200 | 18,48 | 22,1% | 64,94 |
| Total | total | 22.240 | 2,29 | 2,7% | 81,12 |
| Modalidade de ensino | tp_modalidade_ensino | 44.480 | 6,38 | 7,6% | 77,04 |

## Outras medidas

Economias adicionais nos arquivos municipais atuais:

| Indicador | Arredondar percentuais para duas casas | Retirar aspas dispensáveis dos dados |
|---|---:|---:|
| I2 | 0,0% | 12,4% |
| I3 | 0,2% | 11,4% |
| I4 | 1,3% | 11,2% |
| I5 | 1,5% | 11,3% |
| I6 | 1,0% | 11,3% |

Arredondar altera a precisão disponível. Retirar aspas dispensáveis preserva os valores: campos que contêm vírgulas, aspas ou quebras de linha continuam entre aspas. O cabeçalho conserva suas aspas nessa simulação.

Dividir por bloco ou ano facilita abrir partes menores, mas não reduz o volume total; os cabeçalhos extras podem aumentá-lo ligeiramente.

## Método e verificação

- Nova leitura integral dos 26 CSVs, conferindo campos por linha e soma dos bytes com o tamanho físico de cada arquivo, incluindo BOM UTF-8, delimitadores, aspas e quebras de linha LF.
- Comparação dos anos e blocos de cada CSV com o script atual. Os 26 arquivos contêm apenas 2010 e 2024 e os blocos configurados.
- Conferência de que as linhas de cada combinação de território, bloco, grupo e série estão juntas e os anos estão em ordem crescente nos 26 arquivos.
- Chaves duplicadas verificadas nos cenários wide. I2–I6 têm grades completas. I1 tem 4 células de combinações originalmente ausentes, preenchidas com NA; não foram convertidas em zero.
- Segunda leitura de todos os arquivos confirmou contagens totais e de zeros e os tamanhos de dois cenários: omitir zeros e omitir zeros com retirada de rótulos.
- A identificação do indicador é preservada e recolocada na primeira linha restante quando a linha original é retirada, tanto na supressão de blocos quanto na omissão de zeros.
- Os números são mantidos com a mesma escrita decimal dos arquivos atuais. Os cenários wide contam os bytes de serialização sem criar cópias grandes.
- Conferência com pivot_wider e write_excel_csv do R em I4 mesorregional atualizado: 1.138.815 bytes para anos, 925.059 para séries e 519.411 para ambos. Os três resultados coincidiram com a simulação, preservando os valores como texto e descontando apenas as aspas adicionais dos campos numéricos.
- Conferência adicional no R para I4 mesorregional: 1.940.091 bytes ao omitir zeros e 1.785.908 bytes ao retirar o primeiro bloco (catadm_it), incluindo a recolocação dos metadados. Ambos coincidiram com a medição.
- Os tamanhos e as datas de modificação dos CSVs e o conteúdo do script foram conferidos antes da gravação do relatório.
- Não foi feita nova validação metodológica dos indicadores nem regeneração dos dados por esta análise.

## Arquivos de origem

Código: [06-indicadores-I.R](C:/OneDrive/incompletos/mec/code/06-indicadores-I.R).

- [indicadorI1.csv](C:/OneDrive/incompletos/mec/results/indicadorI1.csv) — 74.217 bytes; gravado em 02/11/2026, 17:00:53.
- [indicadorI2a.csv](C:/OneDrive/incompletos/mec/results/indicadorI2a.csv) — 36.707 bytes; gravado em 02/11/2026, 17:00:57.
- [indicadorI2b.csv](C:/OneDrive/incompletos/mec/results/indicadorI2b.csv) — 201.802 bytes; gravado em 02/11/2026, 17:00:58.
- [indicadorI2c.csv](C:/OneDrive/incompletos/mec/results/indicadorI2c.csv) — 1.061.115 bytes; gravado em 02/11/2026, 17:00:58.
- [indicadorI2d.csv](C:/OneDrive/incompletos/mec/results/indicadorI2d.csv) — 4.131.918 bytes; gravado em 02/11/2026, 17:00:58.
- [indicadorI2e.csv](C:/OneDrive/incompletos/mec/results/indicadorI2e.csv) — 41.973.395 bytes; gravado em 02/11/2026, 17:00:59.
- [indicadorI3a.csv](C:/OneDrive/incompletos/mec/results/indicadorI3a.csv) — 69.651 bytes; gravado em 02/11/2026, 17:01:01.
- [indicadorI3b.csv](C:/OneDrive/incompletos/mec/results/indicadorI3b.csv) — 381.272 bytes; gravado em 02/11/2026, 17:01:01.
- [indicadorI3c.csv](C:/OneDrive/incompletos/mec/results/indicadorI3c.csv) — 1.983.765 bytes; gravado em 02/11/2026, 17:01:01.
- [indicadorI3d.csv](C:/OneDrive/incompletos/mec/results/indicadorI3d.csv) — 7.624.491 bytes; gravado em 02/11/2026, 17:01:01.
- [indicadorI3e.csv](C:/OneDrive/incompletos/mec/results/indicadorI3e.csv) — 75.398.626 bytes; gravado em 02/11/2026, 16:58:49.
- [indicadorI4a.csv](C:/OneDrive/incompletos/mec/results/indicadorI4a.csv) — 76.514 bytes; gravado em 02/11/2026, 17:01:04.
- [indicadorI4b.csv](C:/OneDrive/incompletos/mec/results/indicadorI4b.csv) — 420.326 bytes; gravado em 02/11/2026, 17:01:04.
- [indicadorI4c.csv](C:/OneDrive/incompletos/mec/results/indicadorI4c.csv) — 2.196.765 bytes; gravado em 02/11/2026, 17:01:05.
- [indicadorI4d.csv](C:/OneDrive/incompletos/mec/results/indicadorI4d.csv) — 8.503.724 bytes; gravado em 02/11/2026, 17:01:05.
- [indicadorI4e.csv](C:/OneDrive/incompletos/mec/results/indicadorI4e.csv) — 83.718.960 bytes; gravado em 02/11/2026, 17:01:06.
- [indicadorI5a.csv](C:/OneDrive/incompletos/mec/results/indicadorI5a.csv) — 76.120 bytes; gravado em 02/11/2026, 17:01:08.
- [indicadorI5b.csv](C:/OneDrive/incompletos/mec/results/indicadorI5b.csv) — 418.445 bytes; gravado em 02/11/2026, 17:01:08.
- [indicadorI5c.csv](C:/OneDrive/incompletos/mec/results/indicadorI5c.csv) — 2.188.518 bytes; gravado em 02/11/2026, 17:01:09.
- [indicadorI5d.csv](C:/OneDrive/incompletos/mec/results/indicadorI5d.csv) — 8.474.832 bytes; gravado em 02/11/2026, 17:01:09.
- [indicadorI5e.csv](C:/OneDrive/incompletos/mec/results/indicadorI5e.csv) — 83.295.365 bytes; gravado em 02/11/2026, 17:01:09.
- [indicadorI6a.csv](C:/OneDrive/incompletos/mec/results/indicadorI6a.csv) — 76.255 bytes; gravado em 02/11/2026, 17:01:12.
- [indicadorI6b.csv](C:/OneDrive/incompletos/mec/results/indicadorI6b.csv) — 419.134 bytes; gravado em 02/11/2026, 17:01:12.
- [indicadorI6c.csv](C:/OneDrive/incompletos/mec/results/indicadorI6c.csv) — 2.188.834 bytes; gravado em 02/11/2026, 17:01:13.
- [indicadorI6d.csv](C:/OneDrive/incompletos/mec/results/indicadorI6d.csv) — 8.458.386 bytes; gravado em 02/11/2026, 17:01:13.
- [indicadorI6e.csv](C:/OneDrive/incompletos/mec/results/indicadorI6e.csv) — 83.416.622 bytes; gravado em 02/11/2026, 17:01:13.
