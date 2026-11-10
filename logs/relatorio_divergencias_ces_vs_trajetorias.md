# Divergências entre o Censo da Educação Superior e os Indicadores de Trajetórias

**Data da análise:** 12 de outubro de 2026. **Período de ingresso comparável:** 2010–2020. Os censos de 2021–2024 também foram usados para investigar a presença posterior dos cursos e a referência temporal de seus atributos.

## Diferenças conceituais

### Retrato anual e acompanhamento de coortes

O Censo da Educação Superior (CES) registra cursos, instituições e vínculos no ano de referência. Os Indicadores de Trajetórias acompanham uma coorte de ingressantes de determinado curso ao longo de vários anos. Uma linha de trajetória identifica **curso + ano de ingresso + ano de referência do acompanhamento**. Repetir a soma de `QT_INGRESSANTE` em todos os anos de referência conta a mesma coorte diversas vezes.

A coorte é reconstruída retrospectivamente, com vínculos identificados nos quatro primeiros censos da janela. Isso recupera alunos de cursos de destino de Área Básica de Ingresso (ABI), erros de declaração, cursos não carregados pelo e-MEC e instituições que não responderam no início da janela. Assim, `QT_INGRESSANTE` da trajetória pode superar `QT_ING` do CES inicial, e uma coorte pode ter um código de curso ausente desse cadastro inicial. Esses mecanismos estão descritos na seção 2.1, p. 19, da [metodologia do Inep](https://download.inep.gov.br/informacoes_estatisticas/indicadores_educacionais/2017/metodologia_indicadores_trajetoria_curso.pdf).

O [resumo técnico do CES 2023, seção 4, p. 32](https://download.inep.gov.br/educacao_superior/censo_superior/documentos/2023/resumo_tecnico_do_censo_da_educacao_superior_2023.pdf) também informa que as coortes são tratadas e podem sofrer revisões entre edições. Portanto, a comparação envolve um agregado anual publicado e uma reconstrução longitudinal, com edições e tratamentos diferentes. Uma divergência não comprova, por si, erro em uma das fontes.

### Atributos do último ano da análise

**A intuição sobre `CO_IES` está correta.** Nos dicionários locais das trajetórias, a instituição é aquela em que o curso se localiza no último ano da análise. A mesma referência aparece para `NO_IES`, categoria administrativa, organização acadêmica, nome do curso, região, UF, município, grau e modalidade. O próprio `CO_CURSO` é descrito como o código informado no último ano da análise. Os campos CINE são descritos como classificações do curso, sem explicitar nessa descrição o ano; a comparação empírica abaixo também os aproxima da classificação final.

Isso significa que a linha com `NU_ANO_REFERENCIA == NU_ANO_INGRESSO` não traz necessariamente atributos do ano de ingresso. Uma coorte de 2010 pode aparecer associada à IES que controla o curso em 2019. Uma IES que passou de faculdade a centro universitário pode receber a organização final em todas as linhas da coorte. Usar esses atributos para caracterizar a oferta de 2010 introduz informação posterior.

Foram conferidos diretamente os dicionários das pastas `2011_2020`, `2015_2024` e `2020_2024`. Nas 11 planilhas, os atributos cadastrais da linha inicial e da linha final de cada curso–coorte coincidem. Isso corrobora a referência final e não significa constância histórica no CES.

### Universo de cursos, ABI e pequenos números

O cadastro anual pode conter cursos sem ingressantes. Já a trajetória exige uma coorte observável, além dos tratamentos necessários ao acompanhamento. Cursos sequenciais também constam do cadastro bruto, enquanto o universo de interesse das trajetórias é a graduação.

A ABI merece atenção: ela é um ciclo básico que pode conduzir a diferentes formações, e não oferece certificação própria. Essa definição consta do [manual CINE Brasil do Inep, p. 25](https://download.inep.gov.br/publicacoes/institucionais/avaliacoes_e_exames_da_educacao_superior/manual_classificacao_cursos_graduacao_sequencias_formacao_especifica.pdf). A recuperação dos vínculos nos cursos de destino ajuda a entender a presença de ingressantes no cadastro da ABI sem uma trajetória correspondente no mesmo código. Sem os vínculos individuais, não se pode demonstrar para cada caso a transferência da ABI para o curso de destino.

Nas planilhas locais, o menor `QT_INGRESSANTE` observado é **4**, em todas as coortes. Esse é um **limiar empírico de publicação**, não uma regra documental comprovada nesta análise. Tampouco implica que todo curso com `QT_ING < 4` no CES deva ficar fora: a coorte reconstruída pode ser maior do que o ingresso declarado naquele censo.

### Granularidade geográfica e contagem de ingressantes

O CES representa a EaD em dimensões distintas: `TP_DIMENSAO = 2` contém linhas municipais e `TP_DIMENSAO = 3` contém a linha nacional do curso, usada para informações como curso, vagas e inscritos. **A linha nacional não deve ser usada sozinha para somar ingressantes da EaD.** Para contar cursos, usa-se uma chave distinta de curso–ano ou as dimensões 1 e 3. Para somar ingressantes, usam-se as dimensões 1 e 2, excluindo a oferta no exterior. Somar todas as linhas ou substituir os vazios da dimensão 3 por zero leva a interpretações incorretas.

Os totais nacionais da EaD têm localização ausente. Isso também acontece nas trajetórias analisadas. Não se deve substituir a localização do curso EaD pelo município da sede da IES, nem distribuir uma trajetória nacional entre polos sem informações adicionais.

## Comparação empírica

### Bases e regras de comparação

Foram lidos os 15 arquivos brutos de cursos em `data/raw/CES-CURSOS/`, os 15 de instituições em `data/raw/CES-IES/` e as 11 planilhas em `data/raw/INEP-TRAJETORIA/`. A comparação principal reproduz o universo de `ces_cursos`: exclui cursos sequenciais (`TP_NIVEL_ACADEMICO == 2`) e linhas de oferta no exterior (`TP_DIMENSAO == 4`). O cadastro integral foi mantido na investigação da presença dos códigos em outros anos.

As regras são:

1. A chave inicial é `CO_CURSO + ano`, sendo `ano = NU_ANO_INGRESSO` nas trajetórias e `ano = NU_ANO_CENSO` no CES. `CO_IES` é um atributo a comparar, não uma terceira chave.
2. Cada curso–coorte da trajetória entra uma vez, pela linha em que referência e ingresso coincidem. As linhas posteriores são usadas somente para verificações e para o exercício de sensibilidade.
3. Cursos do CES são contados uma vez por ano. As dimensões 1 e 3 representam todas as chaves do universo principal em 2010–2020, sem duplicatas. Os ingressantes são somados nas dimensões 1 e 2, cujas chaves curso–ano–município também foram verificadas como únicas.
4. A presença posterior do código considera todas as linhas brasileiras do cadastro bruto de 2010–2024, incluindo cursos sequenciais. Ausência de uma linha nacional, isoladamente, não foi tratada como desaparecimento do curso.
5. Valores ausentes não foram transformados em zero. Para textos, a comparação inicial preserva conteúdo e grafia, corrigindo apenas a leitura de codificação. Uma verificação adicional aplica as regras de `padroniza_chr()` do projeto.

As janelas locais são 2010–2019, 2011–2020, 2012–2021, 2013–2022, 2014–2023 e, para ingressos de 2015 a 2020, acompanham até 2024. Elas têm, respectivamente, 10, 10, 10, 10, 10, 10, 9, 8, 7, 6 e 5 observações anuais por curso–coorte. Não há coortes de ingresso de 2021–2024 nas planilhas locais, razão pela qual esses anos não aparecem nas duas tabelas principais.

### Cursos em ambas as fontes e cursos exclusivos

Cada célula conta cursos distintos naquele ano. O total da série conta **pares curso–ano**, e não cursos distintos em todo o período.

| Ano | CES | Trajetórias | Em ambas | Só no CES | Só nas trajetórias |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2010 | 29.605 | 25.923 | 24.631 | 4.974 | 1.292 |
| 2011 | 30.550 | 25.966 | 25.135 | 5.415 | 831 |
| 2012 | 32.010 | 26.831 | 26.334 | 5.676 | 497 |
| 2013 | 32.234 | 26.695 | 26.388 | 5.846 | 307 |
| 2014 | 33.141 | 27.394 | 27.116 | 6.025 | 278 |
| 2015 | 33.767 | 28.143 | 27.862 | 5.905 | 281 |
| 2016 | 34.621 | 29.242 | 28.966 | 5.655 | 276 |
| 2017 | 35.630 | 30.900 | 30.581 | 5.049 | 319 |
| 2018 | 38.211 | 32.887 | 32.590 | 5.621 | 297 |
| 2019 | 40.673 | 34.468 | 34.222 | 6.451 | 246 |
| 2020 | 42.208 | 34.848 | 34.184 | 8.024 | 664 |
| **Total** | **382.650** | **323.297** | **318.009** | **64.641** | **5.288** |

### Ingressantes segundo a presença do curso nas fontes

“Em ambas” identifica **cursos correspondentes**, não pessoas identificadas nas duas bases. Não há identificadores individuais nos arquivos utilizados para calcular uma interseção de estudantes. Por isso, essa categoria tem duas colunas: a quantidade informada pelo CES e a quantidade da coorte reconstruída nas trajetórias.

| Ano | Em ambas: CES | Em ambas: trajetórias | Só CES: ingressantes CES | Só trajetórias: ingressantes da coorte | Total CES declarado | Total trajetórias |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2010 | 2.168.480 | 2.508.867 | 13.749 | 64.582 | 2.182.229 | 2.573.449 |
| 2011 | 2.328.823 | 2.519.901 | 17.872 | 54.854 | 2.346.695 | 2.574.755 |
| 2012 | 2.729.015 | 2.865.522 | 18.074 | 33.917 | 2.747.089 | 2.899.439 |
| 2013 | 2.724.241 | 2.920.514 | 18.709 | 15.065 | 2.742.950 | 2.935.579 |
| 2014 | 3.087.681 | 3.161.880 | 23.167 | 15.481 | 3.110.848 | 3.177.361 |
| 2015 | 2.894.713 | 3.016.012 | 25.509 | 11.265 | 2.920.222 | 3.027.277 |
| 2016 | 2.962.408 | 3.049.965 | 23.236 | 11.492 | 2.985.644 | 3.061.457 |
| 2017 | 3.203.434 | 3.300.749 | 22.364 | 15.935 | 3.225.798 | 3.316.684 |
| 2018 | 3.421.348 | 3.506.979 | 23.427 | 15.636 | 3.444.775 | 3.522.615 |
| 2019 | 3.608.473 | 3.700.982 | 23.447 | 6.915 | 3.631.920 | 3.707.897 |
| 2020 | 3.743.930 | 3.837.847 | 19.823 | 21.601 | 3.763.753 | 3.859.448 |
| **Total** | **32.872.546** | **34.389.218** | **229.377** | **266.743** | **33.101.923** | **34.655.961** |

O CES tem **203 pares curso–ano sem quantidade de ingressantes disponível** após a agregação: um em 2010 e 202 em 2020, todos de EaD sem linha municipal de alunos. Desses, 22 estão em ambas as fontes e 181 são exclusivos do CES. Os totais CES acima somam quantidades declaradas e não imputam ingressantes para esses casos. Não há valores ausentes de `QT_ING` nas linhas de alunos brasileiras efetivamente somadas em 2010–2020. Nas trajetórias, `QT_INGRESSANTE` está preenchido para todos os pares.

A soma dos ingressantes exclusivos do CES com quantidade conhecida é **229.377**, equivalente a **0,69%** do ingresso CES declarado no período. Nas trajetórias, os exclusivos somam **266.743** ingressantes, **0,77%** das coortes. Os dois percentuais medem cobertura de fontes com definições distintas.

Os filtros do projeto retiram **1.239 pares sequenciais** em 2010–2020. Desses, 1.238 já não constam das trajetórias. O único que consta é `CO_CURSO = 1325257`, em 2018: 30 ingressantes no cadastro bruto e 25 na trajetória. Sem excluir sequenciais, o cadastro tem 383.889 pares, dos quais 318.010 em ambas, 65.879 só no CES e 5.287 só nas trajetórias. Assim, quase toda a diferença principal persiste no cadastro bruto. A exclusão da oferta no exterior não retira um código de curso exclusivo nesse período.

As chaves, `CO_IES` e os ingressantes agregados foram confrontados com os objetos existentes em `data/clean/`, com coincidência no período principal. O script completo de preparação não foi executado, pois grava saídas.

### Cursos que só aparecem no Censo

#### Decomposição sem dupla contagem

Para tornar as magnitudes legíveis, cada par exclusivo foi classificado uma única vez, nesta ordem: zero ingressantes; 1 a 3; quantidade ausente; pelo menos 4 com indícios de ABI; e, nos demais casos com pelo menos 4, saída persistente, lacuna temporária ou presença contínua.

“Indícios de ABI” significa nome contendo `ABI` ou área geral CINE igual a 0. “Saída persistente” significa que a última aparição do código no cadastro bruto brasileiro ocorre **antes do último ano da janela**, sem retorno até 2024. “Lacuna temporária” significa ausência em pelo menos um ano posterior ao ingresso dentro da janela, sem satisfazer o critério de saída persistente. “Presença contínua” significa presença em todos os censos da janela. Essas condições descrevem padrões observados, não causas administrativas comprovadas.

| Grupo | Pares curso–ano | % dos exclusivos | Ingressantes CES conhecidos |
| --- | ---: | ---: | ---: |
| Zero ingressantes | 47.332 | 73,22% | 0 |
| 1 a 3 ingressantes | 13.842 | 21,41% | 23.580 |
| Quantidade ausente | 181 | 0,28% | — |
| 4+ e indícios de ABI | 2.183 | 3,38% | 175.988 |
| 4+, sem indícios de ABI, saída persistente | 867 | 1,34% | 25.251 |
| 4+, sem indícios de ABI, lacuna temporária | 51 | 0,08% | 1.293 |
| 4+, sem indícios de ABI, presença contínua | 185 | 0,29% | 3.265 |
| **Total** | **64.641** | **100,00%** | **229.377** |

| Ano | Zero | 1–3 | Ausente | 4+ ABI | 4+ saída persistente | 4+ lacuna temporária | 4+ contínuo | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2010 | 3.588 | 1.138 | 1 | 90 | 130 | 12 | 15 | 4.974 |
| 2011 | 4.049 | 1.052 | 0 | 107 | 153 | 6 | 48 | 5.415 |
| 2012 | 4.258 | 1.127 | 0 | 125 | 143 | 3 | 20 | 5.676 |
| 2013 | 4.483 | 1.050 | 0 | 173 | 106 | 6 | 28 | 5.846 |
| 2014 | 4.794 | 907 | 0 | 244 | 74 | 3 | 3 | 6.025 |
| 2015 | 4.570 | 982 | 0 | 256 | 91 | 3 | 3 | 5.905 |
| 2016 | 4.343 | 1.016 | 0 | 252 | 32 | 0 | 12 | 5.655 |
| 2017 | 3.628 | 1.127 | 0 | 246 | 37 | 1 | 10 | 5.049 |
| 2018 | 3.751 | 1.565 | 0 | 247 | 39 | 4 | 15 | 5.621 |
| 2019 | 4.314 | 1.819 | 0 | 234 | 49 | 13 | 22 | 6.451 |
| 2020 | 5.554 | 2.059 | 180 | 209 | 13 | 0 | 9 | 8.024 |
| **Total** | **47.332** | **13.842** | **181** | **2.183** | **867** | **51** | **185** | **64.641** |

**Leitura das magnitudes.** Zero ou 1 a 3 ingressantes correspondem a **61.174 pares**, **94,64%** dos exclusivos. Portanto, a maior parte da diferença na contagem de cursos concentra-se em cursos sem ingresso declarado ou com quantidades muito pequenas.

Isso não encerra a análise do ingresso: os **3.286 pares com pelo menos 4 ingressantes** respondem por **205.797 ingressantes**, a maior parte do ingresso conhecido sem trajetória. Dentro deles, **2.183 pares com indícios de ABI** respondem por **175.988 ingressantes**, ou **76,72%** do ingresso exclusivo conhecido. A ABI é, portanto, pequena em número de pares diante dos cursos sem ingresso, mas grande em quantidade de ingressantes.

O critério combinado é mais abrangente que procurar apenas “ABI” no nome: entre os exclusivos com pelo menos 4 ingressantes, 2.028 têm “ABI” no nome e 2.178 têm área geral 0. A união é 2.183. Esse padrão é compatível com tratamento de ciclos básicos e cursos de destino, mas não permite ligar cada ingressante a uma formação posterior.

Há também cursos com contagens pequenas **presentes nas duas fontes**: **4.509 pares** têm ingresso CES igual a zero, **3.045** têm 1 a 3 e **22** não têm quantidade CES disponível. Todos têm coorte publicada com pelo menos 4 ingressantes. Logo, não se deve aplicar um filtro `QT_ING >= 4` no CES como se ele reproduzisse o universo das trajetórias.

#### Quanto pesa o desaparecimento do cadastro?

O desaparecimento se sobrepõe às pequenas contagens. A tabela seguinte cruza essas duas dimensões, sem somar suas margens como se fossem efeitos independentes.

| Ingresso no CES | Saída persistente | Sem saída persistente | Total |
| --- | ---: | ---: | ---: |
| Zero | 38.042 | 9.290 | 47.332 |
| 1 a 3 | 9.180 | 4.662 | 13.842 |
| 4 ou mais | 1.239 | 2.047 | 3.286 |
| Quantidade ausente | 64 | 117 | 181 |
| **Total** | **48.525** | **16.116** | **64.641** |

A saída persistente ocorre em **48.525 pares exclusivos**, **75,07%** desse conjunto. Porém, **38.042** desses pares tinham zero ingressantes e **9.180** tinham 1 a 3. O desaparecimento caracteriza sobretudo cursos já pequenos ou sem ingresso; não deve ser adicionado à parcela de zero/pequeno ingresso.

Após separar pequenos números, valores ausentes e indícios de ABI, restam **1.103 pares com pelo menos 4 ingressantes e sem esses indícios**, com **29.809 ingressantes**. Neles, **867** têm saída persistente, **51** têm lacunas temporárias e **185** aparecem continuamente. Assim, o desaparecimento ajuda a caracterizar **78,60%** desse resíduo.

Mesmo assim, ele não é uma regra de exclusão: **47.923 pares presentes nas duas fontes**, **15,07%** da interseção, também saem persistentemente do cadastro durante a janela. Trajetórias históricas podem continuar publicadas depois de o código deixar de aparecer no CES.

“Saída persistente” é compatível com fechamento, alteração de código, reorganização de oferta ou interrupção de declaração. O cadastro disponível não identifica qual mecanismo ocorreu. As janelas têm durações distintas, o que também afeta a oportunidade de observar saídas.

#### Casos que ainda exigem investigação individual

Os **185 pares com presença contínua**, sem indícios de ABI e com pelo menos 4 ingressantes, formam o resíduo mais difícil de explicar pelas hipóteses examinadas. Eles representam **0,29% dos cursos exclusivos** e **3.265 ingressantes**. Os 51 com lacunas temporárias também não têm causa individual comprovada. Há casos maiores entre os cursos que saem do cadastro.

| Ano | Código do curso | Nome CES | Ingressantes CES | Padrão cadastral |
| --- | ---: | ---: | ---: | ---: |
| 2011 | 1.134.708 | INTERDISCIPLINAR EM CIÊNCIA E TECNOLOGIA | 436 | Saída persistente |
| 2012 | 17.929 | ADMINISTRAÇÃO | 278 | Saída persistente |
| 2018 | 1.385.361 | PEDAGOGIA | 266 | Presença contínua |
| 2013 | 13.744 | CIÊNCIAS JURÍDICAS E SOCIAIS | 223 | Saída persistente |
| 2010 | 21.648 | ADMINISTRAÇÃO | 213 | Saída persistente |

Por exemplo, Pedagogia, código 1385361, tem 266 ingressantes no CES de 2018, aparece continuamente na janela e não tem trajetória para essa coorte. Isso mostra que o resíduo não se limita a casos na fronteira do limiar 4. A ausência de “ABI” no nome e de área 0 tampouco exclui todas as formas de reorganização de curso: “Interdisciplinar em Ciência e Tecnologia”, na tabela, pode exigir exame de seu desenho acadêmico. A confirmação demandaria vínculos individuais, históricos de códigos ou esclarecimentos do Inep.

### Cursos que só aparecem nas trajetórias

#### Todos os códigos aparecem no cadastro em algum momento

Dos 5.288 pares exclusivos das trajetórias no universo do projeto, **5.287 estão ausentes do cadastro bruto no ano de ingresso**. Todos esses códigos aparecem posteriormente no CES. O par restante é o curso sequencial de 2018 já identificado. Portanto, não foram encontrados códigos publicados nas trajetórias que nunca apareçam no cadastro brasileiro de 2010–2024.

A tabela classifica os pares pelo primeiro reaparecimento do código após o ano de ingresso. Quando o código já existia antes, esse intervalo mede uma lacuna de declaração, e não a criação do curso.

| Ano de ingresso | t+1 | t+2 | t+3 | t+4 ou depois | Sequencial no próprio ano | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2010 | 681 | 415 | 158 | 38 | 0 | 1.292 |
| 2011 | 521 | 211 | 77 | 22 | 0 | 831 |
| 2012 | 346 | 99 | 36 | 16 | 0 | 497 |
| 2013 | 214 | 40 | 45 | 8 | 0 | 307 |
| 2014 | 150 | 86 | 36 | 6 | 0 | 278 |
| 2015 | 205 | 51 | 20 | 5 | 0 | 281 |
| 2016 | 214 | 43 | 14 | 5 | 0 | 276 |
| 2017 | 247 | 53 | 16 | 3 | 0 | 319 |
| 2018 | 226 | 47 | 19 | 4 | 1 | 297 |
| 2019 | 190 | 42 | 10 | 4 | 0 | 246 |
| 2020 | 588 | 52 | 19 | 5 | 0 | 664 |
| **Total** | **3.582** | **1.139** | **450** | **116** | **1** | **5.288** |

| Presença posterior no CES | Pares curso–ano | Ingressantes da trajetória |
| --- | ---: | ---: |
| Aparece em t+1 | 3.582 | 177.548 |
| Aparece em t+2 | 1.139 | 61.487 |
| Aparece em t+3 | 450 | 24.371 |
| Aparece em t+4 ou depois | 116 | 3.312 |
| Presente bruto, sequencial | 1 | 25 |
| **Total** | **5.288** | **266.743** |

**5.171 dos 5.287 pares realmente ausentes no ano inicial (97,81%) aparecem nos três anos seguintes**, dentro do intervalo usado na reconstrução inicial das coortes. Esse é o padrão mais consistente com recuperação retrospectiva de vínculos, cursos de destino de ABI e atrasos/inconsistências cadastrais.

Os **116 pares que só aparecem em t+4 ou depois**, com **3.312 ingressantes**, não são explicados apenas pela janela inicial de quatro censos. Podem envolver retificações posteriores, atualização dos identificadores ou recuperação de histórico. Essas possibilidades são hipóteses: os arquivos agregados não permitem verificar o vínculo original nem um eventual código anterior.

Entre os pares exclusivos, **949**, com **39.185 ingressantes**, tinham o código no CES em algum ano anterior ao ingresso. São lacunas cadastrais observadas diretamente. Os demais 4.339 incluem 4.338 cuja primeira aparição na série disponível é posterior e o sequencial presente no próprio ano. Para a coorte de 2010, a ausência de observação anterior é limitada pelo início da série local.

#### São cursos pequenos e a perda seria desprezível?

Os casos são menos numerosos que os exclusivos do CES, mas **não são todos coortes pequenas**.

| Ingressantes por coorte | Pares curso–ano | Ingressantes totais |
| --- | ---: | ---: |
| 4-9 | 1.031 | 6.234 |
| 10-49 | 2.892 | 74.013 |
| 50-99 | 833 | 58.092 |
| 100-499 | 495 | 86.803 |
| 500+ | 37 | 41.601 |
| **Total** | **5.288** | **266.743** |

| Ano | Cursos perdidos | % dos cursos das trajetórias | Ingressantes perdidos | % dos ingressantes das trajetórias | Mediana da coorte |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2010 | 1.292 | 4,98% | 64.582 | 2,51% | 30,5 |
| 2011 | 831 | 3,20% | 54.854 | 2,13% | 33,0 |
| 2012 | 497 | 1,85% | 33.917 | 1,17% | 34,0 |
| 2013 | 307 | 1,15% | 15.065 | 0,51% | 31,0 |
| 2014 | 278 | 1,01% | 15.481 | 0,49% | 26,0 |
| 2015 | 281 | 1,00% | 11.265 | 0,37% | 21,0 |
| 2016 | 276 | 0,94% | 11.492 | 0,38% | 19,0 |
| 2017 | 319 | 1,03% | 15.935 | 0,48% | 22,0 |
| 2018 | 297 | 0,90% | 15.636 | 0,44% | 20,0 |
| 2019 | 246 | 0,71% | 6.915 | 0,19% | 14,0 |
| 2020 | 664 | 1,91% | 21.601 | 0,56% | 22,0 |

A perda por uma junção interna fica abaixo de 0,60% dos ingressantes em cada coorte de 2013–2020, mas atinge **2,51% em 2010**, **2,13% em 2011** e **1,17% em 2012**. Além disso, **37 pares têm 500 ou mais ingressantes** e somam **41.601 ingressantes**. O tamanho agregado nacional não garante irrelevância em grupos específicos.

| Ano | Código do curso | Curso na trajetória | Modalidade | Ingressantes da coorte | Primeiro ano no CES |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2011 | 111.720 | ADMINISTRAÇÃO | EaD | 5.484 | 2012 |
| 2018 | 1.445.261 | GESTÃO PÚBLICA | EaD | 4.535 | 2019 |
| 2012 | 79.377 | PEDAGOGIA | EaD | 3.879 | 2013 |
| 2010 | 79.377 | PEDAGOGIA | EaD | 3.127 | 2013 |
| 2011 | 79.377 | PEDAGOGIA | EaD | 2.679 | 2013 |

Administração, código 111720, tem 5.484 ingressantes na coorte de 2011, mas o código só aparece no CES em 2012. Gestão Pública, código 1445261, tem 4.535 ingressantes em 2018 e primeira aparição no CES em 2019. Esses dois exemplos afastam a hipótese de que excluir os exclusivos removeria apenas coortes diminutas.

## Comparação dos atributos nos cursos presentes nas duas fontes

### Critérios de igualdade

As tabelas abaixo usam os **318.009 pares** da interseção. Os atributos CES são os do ano de ingresso; os de trajetória são os publicados na planilha dessa coorte. Categoria e organização vêm diretamente do cadastro bruto de cursos. `NO_IES`, que não está nesse cadastro, foi obtido do cadastro bruto de IES do mesmo ano e do `CO_IES` do CES. As duas variáveis institucionais também foram conferidas contra o cadastro de IES e seus campos básicos no objeto limpo.

Para cada variável, os cursos se distribuem entre **iguais com informação preenchida**, **ambos ausentes**, **valores preenchidos divergentes** e **ausência em apenas uma fonte**. As quatro colunas somam o total de cursos comuns no ano. Ausência nas duas fontes não comprova concordância substantiva. Códigos numéricos de região, UF, município e área geral CINE são comparados como números: `04` e `4` representam a mesma categoria. Os códigos alfanuméricos de rótulo CINE preservam seus caracteres, inclusive zeros iniciais.

Foram comparadas todas as 15 variáveis cadastrais compartilhadas, incluindo a chave `CO_CURSO`. O ano é igual por construção da chave; `NU_ANO_REFERENCIA` tem função de acompanhamento e não deve ser confundido com um atributo anual original. `TP_NIVEL_ACADEMICO`, `IN_GRATUITO`, dimensões geográficas do CES e prazos de acompanhamento das trajetórias não têm uma variável diretamente correspondente na outra fonte.

### `co_curso`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.631 | 0 | 0 | 0 |
| 2011 | 25.135 | 0 | 0 | 0 |
| 2012 | 26.334 | 0 | 0 | 0 |
| 2013 | 26.388 | 0 | 0 | 0 |
| 2014 | 27.116 | 0 | 0 | 0 |
| 2015 | 27.862 | 0 | 0 | 0 |
| 2016 | 28.966 | 0 | 0 | 0 |
| 2017 | 30.581 | 0 | 0 | 0 |
| 2018 | 32.590 | 0 | 0 | 0 |
| 2019 | 34.222 | 0 | 0 | 0 |
| 2020 | 34.184 | 0 | 0 | 0 |
| **Total** | **318.009** | **0** | **0** | **0** |

A igualdade decorre da junção por esse código. Ela valida a correspondência encontrada, mas não resolve eventuais alterações de identificadores entre edições.

### `co_ies`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.161 | 0 | 470 | 0 |
| 2011 | 24.511 | 0 | 624 | 0 |
| 2012 | 25.691 | 0 | 643 | 0 |
| 2013 | 25.783 | 0 | 605 | 0 |
| 2014 | 26.479 | 0 | 637 | 0 |
| 2015 | 27.180 | 0 | 682 | 0 |
| 2016 | 28.237 | 0 | 729 | 0 |
| 2017 | 29.812 | 0 | 769 | 0 |
| 2018 | 31.876 | 0 | 714 | 0 |
| 2019 | 33.503 | 0 | 719 | 0 |
| 2020 | 33.795 | 0 | 389 | 0 |
| **Total** | **311.028** | **0** | **6.981** | **0** |

Há 6.981 diferenças (2,20% da interseção). Nos 6.056 casos em que o curso ainda aparece no CES ao fim da janela, a IES da trajetória coincide com a IES desse censo final. Os outros 925 cursos não constam do cadastro final. O padrão confirma a diferença de referência temporal.

### `no_ies`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 19.243 | 0 | 5.388 | 0 |
| 2011 | 19.148 | 0 | 5.987 | 0 |
| 2012 | 20.231 | 0 | 6.103 | 0 |
| 2013 | 19.836 | 0 | 6.552 | 0 |
| 2014 | 20.252 | 0 | 6.864 | 0 |
| 2015 | 20.578 | 0 | 7.284 | 0 |
| 2016 | 21.434 | 0 | 7.532 | 0 |
| 2017 | 23.846 | 0 | 6.735 | 0 |
| 2018 | 26.616 | 0 | 5.974 | 0 |
| 2019 | 29.390 | 0 | 4.832 | 0 |
| 2020 | 30.773 | 0 | 3.411 | 0 |
| **Total** | **251.347** | **0** | **66.662** | **0** |

Há 66.662 diferenças literais. A padronização textual do projeto reduz esse número a 66.555. Isso indica que a maior parte envolve nome institucional de outro momento, em vez de apenas acentos ou aspas. O confronto com o CES final, após padronização, resolve todas as diferenças em que o curso ainda está presente.

### `tp_categoria_administrativa`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 22.225 | 0 | 2.406 | 0 |
| 2011 | 22.453 | 0 | 2.682 | 0 |
| 2012 | 23.410 | 0 | 2.924 | 0 |
| 2013 | 23.218 | 0 | 3.170 | 0 |
| 2014 | 24.025 | 0 | 3.091 | 0 |
| 2015 | 24.945 | 0 | 2.917 | 0 |
| 2016 | 25.984 | 0 | 2.982 | 0 |
| 2017 | 27.937 | 0 | 2.644 | 0 |
| 2018 | 31.244 | 0 | 1.346 | 0 |
| 2019 | 33.078 | 0 | 1.144 | 0 |
| 2020 | 33.346 | 0 | 838 | 0 |
| **Total** | **291.865** | **0** | **26.144** | **0** |

As 26.144 diferenças correspondem a 8,22% da interseção. A combinação mais frequente é CES categoria 5 (privada sem fins lucrativos) e trajetória categoria 4 (privada com fins lucrativos): 19.644 pares. No confronto com o mesmo curso no CES final, todas as diferenças verificáveis desaparecem. A atribuição final pode ocultar mudanças de controle ou de declaração ocorridas durante a coorte.

### `tp_organizacao_academica`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 22.089 | 0 | 2.542 | 0 |
| 2011 | 22.217 | 0 | 2.918 | 0 |
| 2012 | 23.272 | 0 | 3.062 | 0 |
| 2013 | 22.926 | 0 | 3.462 | 0 |
| 2014 | 23.427 | 0 | 3.689 | 0 |
| 2015 | 23.731 | 0 | 4.131 | 0 |
| 2016 | 24.854 | 0 | 4.112 | 0 |
| 2017 | 26.702 | 0 | 3.879 | 0 |
| 2018 | 29.435 | 0 | 3.155 | 0 |
| 2019 | 32.125 | 0 | 2.097 | 0 |
| 2020 | 32.720 | 0 | 1.464 | 0 |
| **Total** | **283.498** | **0** | **34.511** | **0** |

Há 34.511 diferenças (10,85%). Elas desaparecem nos 29.600 casos com curso no CES final. Vinculando a IES da trajetória diretamente ao cadastro de IES final, 34.499 das diferenças coincidem com a organização final; nos 12 restantes, a IES não consta desse cadastro. O resultado é compatível com transformações institucionais ao longo da janela.

### `no_curso`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 23.008 | 0 | 1.623 | 0 |
| 2011 | 23.712 | 0 | 1.423 | 0 |
| 2012 | 25.237 | 0 | 1.097 | 0 |
| 2013 | 25.512 | 0 | 876 | 0 |
| 2014 | 26.290 | 0 | 826 | 0 |
| 2015 | 27.057 | 0 | 805 | 0 |
| 2016 | 28.262 | 0 | 704 | 0 |
| 2017 | 29.945 | 0 | 636 | 0 |
| 2018 | 32.039 | 0 | 551 | 0 |
| 2019 | 33.735 | 0 | 487 | 0 |
| 2020 | 33.747 | 0 | 437 | 0 |
| **Total** | **308.544** | **0** | **9.465** | **0** |

Há 9.465 diferenças literais; restam 8.669 após padronização textual. Nos 7.540 casos com curso no CES final, o nome padronizado coincide com a trajetória. Exemplos incluem “Ciências Políticas”/“Ciência Política” e “Engenharia Ambiental”/“Engenharia Ambiental e Sanitária”. Os demais 1.129 não têm curso no cadastro final.

### `co_regiao`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 23.992 | 639 | 0 | 0 |
| 2011 | 24.476 | 659 | 0 | 0 |
| 2012 | 25.568 | 766 | 0 | 0 |
| 2013 | 25.550 | 838 | 0 | 0 |
| 2014 | 26.055 | 1.061 | 0 | 0 |
| 2015 | 26.769 | 1.093 | 0 | 0 |
| 2016 | 27.729 | 1.237 | 0 | 0 |
| 2017 | 28.758 | 1.823 | 0 | 0 |
| 2018 | 29.906 | 2.684 | 0 | 0 |
| 2019 | 30.366 | 3.856 | 0 | 0 |
| 2020 | 29.057 | 5.127 | 0 | 0 |
| **Total** | **298.226** | **19.783** | **0** | **0** |

Não há divergência de região entre valores preenchidos. A ausência nas duas fontes corresponde ao tratamento nacional da EaD, não à comprovação de localização do curso.

### `co_uf`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 23.992 | 639 | 0 | 0 |
| 2011 | 24.476 | 659 | 0 | 0 |
| 2012 | 25.568 | 766 | 0 | 0 |
| 2013 | 25.550 | 838 | 0 | 0 |
| 2014 | 26.055 | 1.061 | 0 | 0 |
| 2015 | 26.769 | 1.093 | 0 | 0 |
| 2016 | 27.729 | 1.237 | 0 | 0 |
| 2017 | 28.758 | 1.823 | 0 | 0 |
| 2018 | 29.906 | 2.684 | 0 | 0 |
| 2019 | 30.366 | 3.856 | 0 | 0 |
| 2020 | 29.057 | 5.127 | 0 | 0 |
| **Total** | **298.226** | **19.783** | **0** | **0** |

Não há divergência de UF entre valores preenchidos. Os registros sem UF nas duas fontes devem continuar sem localização estadual atribuída a partir da trajetória nacional.

### `co_municipio`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 23.913 | 639 | 79 | 0 |
| 2011 | 24.423 | 659 | 53 | 0 |
| 2012 | 25.521 | 766 | 47 | 0 |
| 2013 | 25.514 | 838 | 36 | 0 |
| 2014 | 26.028 | 1.061 | 27 | 0 |
| 2015 | 26.747 | 1.093 | 22 | 0 |
| 2016 | 27.704 | 1.237 | 25 | 0 |
| 2017 | 28.742 | 1.823 | 16 | 0 |
| 2018 | 29.894 | 2.684 | 12 | 0 |
| 2019 | 30.357 | 3.856 | 9 | 0 |
| 2020 | 29.049 | 5.127 | 8 | 0 |
| **Total** | **297.892** | **19.783** | **334** | **0** |

Há 334 diferenças de município, sem mudança de UF ou região. Nos 297 casos com curso no CES final, o município final coincide com a trajetória; os 37 restantes não têm curso no cadastro final. Isso é compatível com mudanças ou revisões de local de oferta. A comparação aqui é de códigos municipais originais, anterior à conversão em AMC.

### `tp_grau_academico`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.588 | 0 | 43 | 0 |
| 2011 | 25.098 | 0 | 37 | 0 |
| 2012 | 26.312 | 0 | 21 | 1 |
| 2013 | 26.368 | 0 | 19 | 1 |
| 2014 | 27.098 | 0 | 16 | 2 |
| 2015 | 27.846 | 0 | 15 | 1 |
| 2016 | 28.954 | 0 | 12 | 0 |
| 2017 | 30.573 | 0 | 8 | 0 |
| 2018 | 32.583 | 0 | 7 | 0 |
| 2019 | 34.218 | 0 | 4 | 0 |
| 2020 | 34.182 | 0 | 2 | 0 |
| **Total** | **317.820** | **0** | **184** | **5** |

Há 189 discrepâncias na comparação estrita, incluindo ausência em apenas uma fonte. Nos 143 casos com curso no CES final, o grau final coincide com a trajetória; nos 46 restantes não há curso no cadastro final. Mudanças de classificação e passagem de informação ausente para preenchida devem ser distinguidas de mudanças efetivas de grau.

### `tp_modalidade_ensino`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.631 | 0 | 0 | 0 |
| 2011 | 25.135 | 0 | 0 | 0 |
| 2012 | 26.334 | 0 | 0 | 0 |
| 2013 | 26.388 | 0 | 0 | 0 |
| 2014 | 27.116 | 0 | 0 | 0 |
| 2015 | 27.862 | 0 | 0 | 0 |
| 2016 | 28.966 | 0 | 0 | 0 |
| 2017 | 30.581 | 0 | 0 | 0 |
| 2018 | 32.590 | 0 | 0 | 0 |
| 2019 | 34.222 | 0 | 0 | 0 |
| 2020 | 34.184 | 0 | 0 | 0 |
| **Total** | **318.009** | **0** | **0** | **0** |

A modalidade coincide em todos os pares comuns. É o atributo substantivo mais estável entre as fontes neste exercício.

### `co_cine_area_geral`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.631 | 0 | 0 | 0 |
| 2011 | 25.133 | 0 | 2 | 0 |
| 2012 | 26.328 | 0 | 6 | 0 |
| 2013 | 26.381 | 0 | 7 | 0 |
| 2014 | 27.103 | 0 | 13 | 0 |
| 2015 | 27.743 | 0 | 119 | 0 |
| 2016 | 28.832 | 0 | 134 | 0 |
| 2017 | 30.439 | 0 | 142 | 0 |
| 2018 | 32.440 | 0 | 150 | 0 |
| 2019 | 34.058 | 0 | 164 | 0 |
| 2020 | 34.019 | 0 | 165 | 0 |
| **Total** | **317.107** | **0** | **902** | **0** |

Há 902 diferenças. Em 888 pares, a área da trajetória coincide com a classificação CES final; os 14 restantes não têm curso no cadastro final. Não é adequado supor invariância da área geral por código de curso em toda a série.

### `no_cine_area_geral`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.631 | 0 | 0 | 0 |
| 2011 | 25.133 | 0 | 2 | 0 |
| 2012 | 26.328 | 0 | 6 | 0 |
| 2013 | 26.381 | 0 | 7 | 0 |
| 2014 | 27.103 | 0 | 13 | 0 |
| 2015 | 27.743 | 0 | 119 | 0 |
| 2016 | 28.832 | 0 | 134 | 0 |
| 2017 | 30.439 | 0 | 142 | 0 |
| 2018 | 32.440 | 0 | 150 | 0 |
| 2019 | 34.058 | 0 | 164 | 0 |
| 2020 | 34.019 | 0 | 165 | 0 |
| **Total** | **317.107** | **0** | **902** | **0** |

As 902 diferenças de nome acompanham as 902 diferenças do código da área geral. A padronização de textos não remove esses casos; eles refletem diferenças de classificação temporal.

### `co_cine_rotulo`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 0 | 0 | 24.631 | 0 |
| 2011 | 0 | 0 | 25.135 | 0 |
| 2012 | 0 | 0 | 26.334 | 0 |
| 2013 | 0 | 0 | 26.388 | 0 |
| 2014 | 0 | 0 | 27.116 | 0 |
| 2015 | 0 | 0 | 27.862 | 0 |
| 2016 | 0 | 0 | 28.966 | 0 |
| 2017 | 0 | 0 | 30.581 | 0 |
| 2018 | 0 | 0 | 32.590 | 0 |
| 2019 | 0 | 0 | 34.222 | 0 |
| 2020 | 0 | 0 | 34.184 | 0 |
| **Total** | **0** | **0** | **318.009** | **0** |

A comparação literal encontra diferença em todos os pares porque os códigos CES brutos contêm aspas incorporadas ao conteúdo, que não estão nos códigos das trajetórias. A padronização existente remove as aspas e reduz a discrepância a 9.412 pares. Destes, 9.387 coincidem com o rótulo CES final; os 25 restantes não têm curso no cadastro final. Em alguns anos do CES, o campo também muda de nome para `CO_CINE_ROTULO2`; esse nome foi mapeado para o campo equivalente antes da comparação.

**Comparação adicional após a padronização textual do projeto:**

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.630 | 0 | 1 | 0 |
| 2011 | 25.109 | 0 | 26 | 0 |
| 2012 | 26.298 | 0 | 36 | 0 |
| 2013 | 26.355 | 0 | 33 | 0 |
| 2014 | 27.052 | 0 | 64 | 0 |
| 2015 | 26.554 | 0 | 1.308 | 0 |
| 2016 | 27.596 | 0 | 1.370 | 0 |
| 2017 | 29.136 | 0 | 1.445 | 0 |
| 2018 | 31.012 | 0 | 1.578 | 0 |
| 2019 | 32.512 | 0 | 1.710 | 0 |
| 2020 | 32.343 | 0 | 1.841 | 0 |
| **Total** | **308.597** | **0** | **9.412** | **0** |

Entre as mudanças mais frequentes, o rótulo `0615S02` no CES inicial passa a `0613S01` na trajetória em 4.953 pares; `0614C01` passa a `0613C01` em 1.979. O confronto com o CES final distingue essas mudanças de classificação do simples problema das aspas.

### `no_cine_rotulo`

| Ano | Iguais preenchidos | Ambos ausentes | Divergentes preenchidos | Ausente em uma fonte |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 24.630 | 0 | 1 | 0 |
| 2011 | 25.109 | 0 | 26 | 0 |
| 2012 | 26.298 | 0 | 36 | 0 |
| 2013 | 26.355 | 0 | 33 | 0 |
| 2014 | 27.052 | 0 | 64 | 0 |
| 2015 | 27.553 | 0 | 309 | 0 |
| 2016 | 28.634 | 0 | 332 | 0 |
| 2017 | 30.222 | 0 | 359 | 0 |
| 2018 | 32.192 | 0 | 398 | 0 |
| 2019 | 33.789 | 0 | 433 | 0 |
| 2020 | 33.776 | 0 | 408 | 0 |
| **Total** | **315.610** | **0** | **2.399** | **0** |

Há 2.399 diferenças de nome do rótulo, que permanecem após padronização textual. As 2.328 verificáveis no cadastro final coincidem com a trajetória; os 71 demais não têm curso no CES final. Uma mudança do código de rótulo nem sempre modifica seu nome, o que ajuda a explicar por que a divergência de código, após remover aspas, é maior que a divergência de nome.

### O que o confronto com o CES final explica

Para cada discrepância inicial, foi procurado o mesmo código de curso no **último ano da janela da respectiva planilha**. A tabela usa textos padronizados, quando aplicável, e inclui como discrepância uma ausência em apenas uma fonte.

| Variável | Discrepâncias no ingresso | Coincidem com CES final | Curso ausente no CES final | Persistem com curso no CES final |
| --- | ---: | ---: | ---: | ---: |
| `co_ies` | 6.981 | 6.056 | 925 | 0 |
| `no_ies` | 66.555 | 53.051 | 13.504 | 0 |
| `tp_categoria_administrativa` | 26.144 | 20.349 | 5.795 | 0 |
| `tp_organizacao_academica` | 34.511 | 29.600 | 4.911 | 0 |
| `no_curso` | 8.669 | 7.540 | 1.129 | 0 |
| `co_regiao` | 0 | 0 | 0 | 0 |
| `co_uf` | 0 | 0 | 0 | 0 |
| `co_municipio` | 334 | 297 | 37 | 0 |
| `tp_grau_academico` | 189 | 143 | 46 | 0 |
| `tp_modalidade_ensino` | 0 | 0 | 0 | 0 |
| `co_cine_area_geral` | 902 | 888 | 14 | 0 |
| `no_cine_area_geral` | 902 | 888 | 14 | 0 |
| `co_cine_rotulo` | 9.412 | 9.387 | 25 | 0 |
| `no_cine_rotulo` | 2.399 | 2.328 | 71 | 0 |

**Todas as diferenças verificáveis de atributos desaparecem ao usar o CES final e a padronização de textos.** Isso é uma evidência forte de referência temporal e de formatação, e não uma demonstração de que o CES inicial esteja errado. Os casos sem curso no cadastro final permanecem sem verificação por essa via; não foram classificados como explicados individualmente.

Para categoria e organização, também foi confrontado o cadastro da IES publicada na trajetória no ano final, mesmo quando o curso não está mais no CES. Isso resolve 25.050 das 26.144 diferenças de categoria, deixando 1.094 sem IES final; resolve 34.499 das 34.511 diferenças de organização, deixando 12 sem IES final. Não há discrepância residual preenchida nesses dois confrontos institucionais.

### Quantidade de ingressantes nos cursos comuns

Os ingressantes são quantidades com construção diferente nas duas fontes, embora sejam comparáveis como diagnóstico. A tabela conta cursos, não o número de alunos em cada tipo de diferença. Os cursos com CES zero estão incluídos na coluna “Trajetória maior”; não devem ser somados novamente.

| Ano | Quantidades iguais | CES maior | Trajetória maior | CES sem quantidade | Desses casos: CES zero |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2010 | 6.003 | 2.227 | 16.401 | 0 | 467 |
| 2011 | 9.267 | 2.228 | 13.640 | 0 | 408 |
| 2012 | 11.574 | 2.864 | 11.896 | 0 | 320 |
| 2013 | 11.460 | 2.784 | 12.144 | 0 | 327 |
| 2014 | 13.477 | 3.315 | 10.324 | 0 | 389 |
| 2015 | 14.376 | 2.467 | 11.019 | 0 | 383 |
| 2016 | 16.368 | 2.619 | 9.979 | 0 | 409 |
| 2017 | 15.162 | 2.521 | 12.898 | 0 | 468 |
| 2018 | 16.500 | 2.601 | 13.489 | 0 | 394 |
| 2019 | 17.783 | 2.532 | 13.907 | 0 | 426 |
| 2020 | 21.817 | 1.423 | 10.922 | 22 | 518 |
| **Total** | **153.787** | **27.581** | **136.619** | **22** | **4.509** |

Essas diferenças persistem mesmo com os mesmos cursos. A reconstrução retrospectiva das coortes fornece uma explicação metodológica para aumentos nas trajetórias; diferenças no sentido oposto também ocorrem e podem envolver tratamento e revisão de vínculos. O exercício não permite atribuir uma causa a cada discrepância individual. **Os denominadores de trajetória devem continuar sendo os do arquivo de trajetória.** Substituí-los pelo ingresso CES ou ajustar proporcionalmente as taxas alteraria os indicadores publicados.

## Sugestão de uso e harmonização

### Recomendação principal

**Recomendo usar o CES como fonte de atributos anuais e das harmonizações do projeto, ligando as trajetórias por `CO_CURSO + ano de ingresso`. Recomendo também preservar as trajetórias sem correspondência nesse ano, em vez de descartá-las na construção da base.**

A primeira parte confirma a intuição proposta: o CES é a fonte adequada para atribuir à coorte características do ano em que ela começou e para manter compatibilidade com os indicadores já produzidos. Os resultados não sustentam uma afirmação genérica de que todos os dados do CES tenham qualidade superior. Nas trajetórias, os atributos finais estão sendo usados para outra finalidade temporal, e os ingressantes são reconstruídos para acompanhar a coorte.

A segunda parte modifica a proposta de excluir os exclusivos. Eles são poucos em proporção agregada, sobretudo nas coortes recentes, mas incluem coortes grandes e não são aleatórios em seu desempenho. Todos os códigos têm alguma correspondência no CES durante a série, o que torna viável manter uma base integrada com marcação de origem e de referência temporal dos atributos.

### Efeito observado de restringir à interseção

Para avaliar o descarte, calculei a média de `TDA` publicada no **quinto ano de observação**, isto é, `NU_ANO_REFERENCIA = NU_ANO_INGRESSO + 4`, ponderada por `QT_INGRESSANTE`. Todas as coortes locais têm esse horizonte. A comparação mantém o mesmo indicador, ano de acompanhamento e peso em cada coorte. É um exercício de sensibilidade sobre médias dos cursos, não uma reconstrução dos vínculos individuais.

| Coorte | TDA: trajetórias completas | TDA: somente interseção | TDA: cursos exclusivos | Variação ao excluir (p.p.) |
| --- | ---: | ---: | ---: | ---: |
| 2010 | 51,39% | 51,73% | 37,83% | 0,349 |
| 2011 | 50,55% | 50,83% | 37,96% | 0,274 |
| 2012 | 52,12% | 52,29% | 37,95% | 0,168 |
| 2013 | 50,38% | 50,48% | 31,26% | 0,099 |
| 2014 | 52,44% | 52,50% | 40,78% | 0,057 |
| 2015 | 53,78% | 53,82% | 42,03% | 0,044 |
| 2016 | 55,75% | 55,79% | 46,98% | 0,033 |
| 2017 | 54,99% | 55,03% | 44,81% | 0,049 |
| 2018 | 56,70% | 56,76% | 41,40% | 0,068 |
| 2019 | 58,02% | 58,03% | 49,93% | 0,015 |
| 2020 | 62,06% | 62,17% | 42,23% | 0,112 |

A exclusão eleva a desistência média em todas as coortes desse exercício. A maior diferença nacional é de **0,349 ponto percentual em 2010**; em 2020, é **0,112 ponto percentual**. Os exclusivos têm desistência média menor que a interseção no quinto ano em todas as coortes. Isso mostra seleção, embora o impacto nacional seja limitado. Esses limites nacionais não valem automaticamente para recortes por instituição, mantenedora, área ou modalidade.

A perda de ingressantes também varia por modalidade. Em 2011, a exclusão remove **3,28%** dos ingressantes EaD publicados; em 2010, remove **2,61%** dos presenciais. Para uma análise nacional aproximada, a interseção pode ser aceitável quando esses limites estiverem explícitos. Para uma base geral de monitoramento e comparações entre grupos, preservar os casos é uma escolha melhor.

As médias acima usam as edições locais disponíveis. Uma nova edição pode revisar coortes anteriores; comparar edições distintas exige registrar o ano final de cada arquivo. O horizonte comum controla a duração de observação, mas não elimina possíveis revisões entre edições.

### Como integrar sem reproduzir todas as harmonizações

O desenho recomendado tem uma tabela de atributos anuais do CES e uma tabela longitudinal de trajetórias ligada a ela. Elas compartilham classificações, mas preservam as quantidades e a unidade de observação próprias de cada fonte.

| Elemento | Fonte/regra recomendada |
| --- | ---: |
| Chave de ligação | `co_curso + ano_ingresso` para caracterizar a coorte no ingresso. Não incluir a IES da trajetória nessa chave. |
| Chave da trajetória | `co_curso + ano_ingresso + ano_referencia`, mais identificação da edição quando houver arquivos repetidos para a mesma coorte. |
| Atributos do curso no ingresso | `ces_cursos`, uma linha por curso–ano nas dimensões 1 e 3 para o período verificado. |
| IES do curso no ingresso | `co_ies` obtido do CES do mesmo curso e ano, preservando `co_ies_traj` como atributo de origem/final. |
| Classificações institucionais harmonizadas | Junção com `ces_ies` por `co_ies_ces + ano_ingresso`. Reusar os campos já calculados. |
| Classificações da mantenedora e tamanho | Junção com `ces_mantenedoras` pela mantenedora harmonizada e pelo ano correspondente. Reusar ranking e `fx_ranking`. |
| Ingressantes e resultados da coorte | Manter `QT_INGRESSANTE`, permanência, conclusão, desistência, falecimento e taxas da trajetória. |
| Quantidade anual do CES | Manter separada, com nome que identifique o CES e agregação correta da EaD. |
| Curso sem CES no ano de ingresso | Preservar o registro, com atributos históricos ausentes e indicação de ausência de correspondência. |
| Atributos de outro ano | Se necessários, buscar a primeira observação posterior do mesmo curso, mantendo `ano_atributos` e origem. Não apresentá-los como comprovados no ingresso. |
| Localização | Usar a geografia do CES do ano escolhido e a mesma transformação em AMC. A EaD nacional continua sem distribuição territorial inferida. |

A ligação dos 318.009 pares comuns ao objeto `ces_ies` pelo `CO_IES` do CES e ano de ingresso encontrou **correspondência para todos**. Assim, podem ser reaproveitados `tp_categoria_administrativa_harm`, `co_mantenedora_harm`, `no_mantenedora_harm`, `catadm_it` e `tp_organizacao_academica_harm`.

Isso evita repetir em um subconjunto de trajetórias as regras que usam a história inteira de uma IES ou o conjunto de IES de uma mantenedora. Recalcular modas, reclassificações de mantenedoras e rankings sobre a cobertura parcial das trajetórias poderia produzir harmonizações diferentes das do CES, mesmo usando fórmulas semelhantes. Os campos harmonizados devem vir de uma dimensão institucional comum, calculada uma vez sobre o universo CES.

Nos dados atuais, `catadm_it` do CES de ingresso difere da categoria administrativa bruta da trajetória em **25.478 pares**. A organização acadêmica harmonizada do CES difere da variável bruta da trajetória em **34.987 pares**. Esses números combinam referência temporal e harmonização; não são erros adicionais das trajetórias. Reusar os campos do CES elimina a necessidade de forçar a variável bruta final a reproduzir uma classificação histórica harmonizada.

Há duas decisões temporais úteis, que devem ter nomes claros: classificar a coorte **no ingresso**, usando o CES daquele ano, ou classificar seu vínculo **em cada ano de acompanhamento**, usando `CO_CURSO + ano_referencia` e a IES anual do CES. A primeira permite acompanhar grupos de origem; a segunda descreve a configuração institucional contemporânea aos resultados. Para estudar quem recebeu ingressantes e como esses grupos evoluíram, a classificação no ingresso é o padrão recomendado. Para cursos que desaparecem, a segunda opção naturalmente perde atributos anuais posteriores e exige uma regra explícita.

O objeto `ces_cursos` atual conserva a área geral CINE, mas não todos os campos de rótulo CINE comparados neste relatório. Se forem necessários, será preciso incorporar um cadastro auxiliar dos campos brutos ao mesmo curso–ano. Isso pode ser feito preservando as regras existentes de texto e de referência temporal, sem reprocessar os indicadores de trajetória. Se o objetivo for uma área CINE constante por curso, essa será uma decisão adicional de classificação histórica; as diferenças encontradas mostram que a constância não pode ser presumida.

### Tratamento dos casos sem correspondência no ingresso

Para a base principal, a junção deve preservar todas as linhas da trajetória e criar indicadores de correspondência. Nos exclusivos, recomenda-se:

1. Manter a coorte e seus indicadores, identificando a ausência no CES de ingresso.
2. Conservar os atributos publicados nas trajetórias em campos com sufixo de origem, associados ao ano final da edição.
3. Registrar o primeiro ano posterior em que o código aparece no CES. Se houver necessidade de completar atributos, buscar nesse ano a IES e suas classificações harmonizadas **do mesmo ano**.
4. Marcar esse preenchimento como atributo de ano posterior. Não usar o código de IES final para atribuir silenciosamente uma mantenedora histórica à coorte.
5. Nas tabelas por atributos do ingresso, mostrar os casos sem classificação histórica em uma categoria própria, ou apresentar a interseção junto de um controle da perda em cada grupo.
6. Tratar separadamente o caso sequencial de 2018. A trajetória pode ser preservada no arquivo de origem, mas seu uso como graduação precisa de uma regra de escopo ou esclarecimento adicional.

Esse desenho mantém compatibilidade com `ces_cursos`, `ces_ies` e `ces_mantenedoras` sem exigir que as duas fontes tenham o mesmo universo ou o mesmo denominador. Os arquivos de origem continuam separados para rastreabilidade; os produtos analíticos usam dimensões comuns. Não recomendo criar duas cadeias independentes de harmonização institucional.

### Cuidados de implementação já identificados

A leitura das planilhas com `skip = 8` encontra uma linha de fonte ao final de cada arquivo. As **11 linhas sem código de curso** devem ser retiradas antes de junções ou contagens. As chaves da tabela de atributos CES e da coorte devem ser validadas como únicas; a junção das linhas de acompanhamento com atributos é de muitos para um. Somar novamente os ingressantes em todos os anos de acompanhamento deve ser evitado.

Para 2010–2020, a seleção das dimensões 1 e 3 cobre todas as chaves principais. Em 2023 e 2024, o cadastro bruto tem, respectivamente, **2 e 7 códigos brasileiros sem essa linha nacional/presencial**, presentes em outras linhas. Essa exceção não afetou as tabelas principais nem os confrontos de atributos finais aqui apresentados, mas a regra deve ser validada novamente se a integração for ampliada para novas coortes.

Ausência de trajetória nunca deve virar taxa zero. A população de ingresso do CES e a coorte longitudinal não devem ser equiparadas por ajuste de totais. Também se deve conservar a edição original de cada trajetória e escolher uma única edição por coorte ao incorporar versões novas.

### Verificação realizada e limites

Foram verificados unicidade de chaves, decomposições exaustivas sem dupla contagem, somas anuais, correspondências com os objetos limpos e valores iniciais/finais das coortes. A extração das planilhas foi conferida por uma segunda biblioteca para todos os 31 campos de uma linha de 2010 e outra de 2020. As 11 planilhas têm os anos de acompanhamento esperados, nenhuma mudança de `QT_INGRESSANTE` ao longo do acompanhamento e mínimo de 4 ingressantes. Os totais de cursos reproduzem o diagnóstico anterior; a contagem de ingressantes distingue a soma municipal EaD de sua linha nacional e separa zero de ausência de informação.

Não foram usados microdados individuais de alunos, históricos administrativos de encerramento ou tabelas de sucessão de códigos de cursos. Por isso, os mecanismos gerais têm apoio documental e empírico, mas a causa individual permanece aberta nos resíduos descritos. Nenhum dado bruto, objeto limpo ou script de produção foi modificado, e as sugestões de harmonização não foram implementadas.

### Fontes locais

- Cadastros anuais: `data/raw/CES-CURSOS/MICRODADOS_CADASTRO_CURSOS_2010.parquet` a `2024.parquet` e arquivos correspondentes em `data/raw/CES-IES/`.
- Trajetórias: as 11 planilhas `.xlsx` nas pastas `data/raw/INEP-TRAJETORIA/2010_2019/` a `2020_2024/`, com os dicionários locais conferidos nas pastas `2011_2020`, `2015_2024` e `2020_2024`.
- Objetos preparados: `data/clean/ces_cursos.parquet` e `data/clean/ces_ies.parquet`.
- Preparação e harmonizações: [`code/01-preparacao.R`](../code/01-preparacao.R), [`padroniza_chr.R`](../code/helpers/padroniza_chr.R) e [`gera_amc.R`](../code/helpers/gera_amc.R).
- Definições CES: [`dicionário local`](../docs/dicionario-dados-CensoEducacaoSuperior.md). Escopo do monitoramento: [`entendimento do negócio`](../docs/entendimento_do_negocio.md) e [`conjunto de indicadores`](../docs/monitoramento_ead_sumario.md).
- Diagnóstico anterior, preservado: [`relatorio_discrepancias_ces_vs_trajetorias.md`](relatorio_discrepancias_ces_vs_trajetorias.md). As tabelas deste relatório foram recalculadas a partir dos arquivos atuais.
