# Base de trajetórias: agregação, referência temporal e valores ausentes

Verificação realizada em 12 de outubro de 2026, sobre os arquivos locais do projeto MEC.

## 1. Conclusões e grau de evidência

1. **A unidade publicada é curso × coorte de ingresso × ano de referência.** As 11 planilhas contêm 2.731.155 linhas válidas e 323.297 pares curso–coorte, sem duplicações nessa chave.
2. **Nem todas as variáveis se referem ao último ano.** Há atributos cadastrais, características da coorte, contagens anuais e taxas anuais/acumuladas. Cada grupo tem sua própria referência temporal.
3. **Os dicionários descrevem os principais atributos cadastrais como informações do “último ano de análise”.** Os dados confirmam correspondência com o cadastro do fim da janela quando o curso está presente nesse cadastro. Entretanto, cursos ausentes do CES final também conservam atributos preenchidos, compatíveis com o último cadastro disponível dentro da janela. A documentação consultada não especifica o algoritmo interno para recuperar esses atributos.
4. **Nos arquivos examinados, os únicos valores ausentes nas linhas válidas são `CO_REGIAO`, `CO_UF` e `CO_MUNICIPIO`.** Os três campos estão ausentes em todas as linhas EaD e preenchidos em todas as linhas presenciais. Não houve ausências nas outras 28 variáveis.
5. **Não há evidência de uma regra geral “atributo variável → missing” ou “curso com múltiplas linhas no CES → atributos missing”.** Existem contraexemplos diretos às duas proposições.

Este documento distingue **definição oficial**, **resultado observado** e **inferência compatível com os dados**. A coincidência de valores não permite reconstruir, sozinha, o programa utilizado pelo Inep.

## 2. Fontes e procedimento de verificação

Foram lidas integralmente as 11 planilhas em `data/raw/INEP-TRAJETORIA/`, as bases cadastrais de cursos do CES de 2010 a 2024 e os dez dicionários de trajetórias que puderam ser abertos. Foram consultados também o dicionário do CES e trechos oficiais indexados da metodologia e dos resumos técnicos do Inep.

- [Dicionário de trajetórias 2011–2020](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2011_2020/Dicionário_acompanhamento_trajetória.docx>) e [dicionário 2020–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2020_2024/Dicionário_acompanhamento_trajetória.docx>): referência temporal e definição das variáveis. Os dicionários legíveis formam dois grupos de arquivos idênticos byte a byte: 2011–2020 a 2013–2022; e 2014–2023 a 2020–2024. As descrições relevantes à presente análise são iguais entre esses grupos.
- [Dicionário do CES](</C:/OneDrive/incompletos/mec/docs/dicionario-dados-CensoEducacaoSuperior.md>): seção `cadastro_cursos`, especialmente `TP_DIMENSAO`, localização e grau acadêmico.
- [Metodologia de cálculo dos indicadores de fluxo da educação superior, Inep, 2017](https://download.inep.gov.br/informacoes_estatisticas/indicadores_educacionais/2017/metodologia_indicadores_trajetoria_curso.pdf): construção da coorte, tratamento dos vínculos e agregação por curso, especialmente seções 2 e 3.
- [Resumo técnico do CES 2019](https://download.inep.gov.br/publicacoes/institucionais/estatisticas_e_indicadores/resumo_tecnico_censo_da_educacao_superior_2019.pdf), [apresentação do painel do CES, 2023](https://download.inep.gov.br/educacao_superior/censo_superior/documentos/2023/painel-de-bi-do-censo-da-educacao-superior-deed-inep.pdf) e [Resumo técnico do CES 2024](https://download.inep.gov.br/publicacoes/institucionais/avaliacoes_e_exames_da_educacao_superior/resumo_tecnico_do_censo_da_educacao_superior_2024.pdf): definições das taxas e tratamento dos falecimentos no denominador.

As planilhas foram importadas com `readxl::read_xlsx(..., skip = 8)`. Cada uma contém uma linha final de fonte sem código de curso; essa linha foi excluída dos diagnósticos. Ausência foi definida como `NA` ou texto vazio após remoção de espaços. Os exames foram realizados sobre os dados brutos, antes da harmonização territorial do projeto.

Para comparar atributos cadastrais, foram selecionadas as linhas CES de `TP_DIMENSAO` 1 ou 3. Essa seleção apresentou chave única `CO_CURSO + ano` nos arquivos de 2010–2024. As demais linhas CES foram usadas para verificar multiplicidade e municípios distintos. A seleção 1/3 serve para atributos cadastrais; **não estabelece que todas as contagens de alunos estejam na linha de dimensão 3**.

Não foram reexecutados os scripts de produção, nem alterados código ou dados originais. Relatórios anteriores serviram apenas como indicações de questões a verificar; as conclusões abaixo resultam das leituras atuais.

## 3. Como a base é construída e agregada

### 3.1 Vínculos individuais, tratamento e coorte

A metodologia oficial descreve pareamento por aluno, curso e ano de ingresso. A coorte recupera vínculos com o mesmo ano de ingresso nos quatro primeiros censos, incluindo registros que aparecem depois do ano inicial. São mencionadas situações relacionadas a ABI, declaração das IES e cadastro e-MEC. Esses vínculos recebem permanência nos anos anteriores à sua identificação.

O tratamento pode corrigir, imputar ou excluir trajetórias inconsistentes. Entre as regras descritas, o retorno ao vínculo ativo pode levar à substituição de uma desistência anterior por permanência; uma ausência definitiva depois do último vínculo recebe desistência no ano seguinte; lacunas intermediárias seguidas de vínculo recebem permanência. A base tratada de estudantes é então agregada por curso. Fonte: [metodologia do Inep, seções 2 e 3](https://download.inep.gov.br/informacoes_estatisticas/indicadores_educacionais/2017/metodologia_indicadores_trajetoria_curso.pdf).

Essas regras tratam **ausência de vínculos individuais no tempo**. Elas não devem ser confundidas com geração de células geográficas vazias na planilha agregada.

Permanência compreende vínculos ativos, cursando ou trancados; conclusão corresponde à formação; desistência inclui desvinculação e transferência para outro curso da mesma IES. A desistência do curso, portanto, não identifica necessariamente saída do sistema de educação superior. Fonte: [Resumo técnico do CES 2019](https://download.inep.gov.br/publicacoes/institucionais/estatisticas_e_indicadores/resumo_tecnico_censo_da_educacao_superior_2019.pdf).

### 3.2 Contagens e taxas publicadas

A partir das definições dos dicionários e da reprodução aritmética de todas as linhas, a organização operacional é a seguinte. Para um curso e uma coorte, sejam:

- `N`: `QT_INGRESSANTE`, constante ao longo dos anos dessa coorte;
- `P_t`: `QT_PERMANENCIA` no ano `t`;
- `C_t`: `QT_CONCLUINTE` no ano `t`;
- `D_t`: `QT_DESISTENCIA` no ano `t`;
- `F_t`: `QT_FALECIDO` no ano `t`;
- `B_t = N - soma(F_s, s ≤ t)`: denominador ajustado pelos falecimentos acumulados.

As cinco taxas são expressas em pontos percentuais:

| Variável | Construção reproduzida |
|---|---|
| `TAP` | `100 × P_t / B_t` |
| `TCA` | `100 × soma(C_s, s ≤ t) / B_t` |
| `TDA` | `100 × soma(D_s, s ≤ t) / B_t` |
| `TCAN` | `100 × C_t / B_t` |
| `TADA` | `100 × D_t / B_t` |

As fórmulas reproduziram as cinco taxas em todas as 2.731.155 linhas válidas. O maior erro absoluto foi aproximadamente `5 × 10⁻⁹` ponto percentual, compatível com a precisão armazenada. Não houve denominadores não finitos ou taxas ausentes nesse confronto. As definições oficiais do denominador são apresentadas na [apresentação do painel, 2023](https://download.inep.gov.br/educacao_superior/censo_superior/documentos/2023/painel-de-bi-do-censo-da-educacao-superior-deed-inep.pdf) e no [Resumo técnico de 2024](https://download.inep.gov.br/publicacoes/institucionais/avaliacoes_e_exames_da_educacao_superior/resumo_tecnico_do_censo_da_educacao_superior_2024.pdf).

`QT_CONCLUINTE`, `QT_DESISTENCIA` e `QT_FALECIDO` são contagens anuais; não são totais acumulados. `QT_PERMANENCIA` é o estoque de vínculos ativos naquele ano. Os numeradores acumulados de `TCA` e `TDA` precisam ser construídos somando eventos desde o ingresso.

Essa reprodução verifica a aritmética da planilha publicada. Não reproduz o tratamento dos microdados individuais que originou as contagens.

### 3.3 O que ocorre com cursos ofertados em vários municípios

As trajetórias EaD são publicadas por código de curso, sem decomposição por município. A multiplicidade municipal do cadastro não gera linhas adicionais da coorte na trajetória. As contagens e taxas referem-se ao conjunto de vínculos do curso acompanhado.

Isso não significa que o Inep tenha simplesmente somado as linhas do arquivo público `CES-CURSOS`: sua metodologia parte dos vínculos individuais tratados. A distribuição desses vínculos entre polos ou municípios não é recuperável a partir da planilha de trajetórias.

Exemplo conferido nesta conversa: Pedagogia da UFMT, `CO_CURSO = 105652`, aparece no CES de 2020 em nove municípios e em uma linha nacional. As linhas municipais somam 132 ingressantes; a trajetória da coorte 2020 informa 133. Essa diferença impede tratar a soma do cadastro público como reprodução exata da coorte. Não foi identificada a causa individual da diferença.

## 4. Referência temporal das 31 variáveis

| Variáveis | Referência temporal e limite da definição |
|---|---|
| `CO_IES`, `NO_IES`, `TP_CATEGORIA_ADMINISTRATIVA`, `TP_ORGANIZACAO_ACADEMICA` | Os dicionários dizem explicitamente “último ano de análise”. Não representam necessariamente a IES e seus atributos no ingresso ou em cada ano da trajetória. |
| `CO_CURSO`, `NO_CURSO`, `CO_REGIAO`, `CO_UF`, `CO_MUNICIPIO`, `TP_GRAU_ACADEMICO`, `TP_MODALIDADE_ENSINO` | Os dicionários também indicam o último ano de análise. A localização permanece ausente para EaD nos arquivos examinados. Há a ressalva dos cursos ausentes do cadastro final, detalhada abaixo. |
| `CO_CINE_AREA_GERAL`, `NO_CINE_AREA_GERAL`, `CO_CINE_ROTULO`, `NO_CINE_ROTULO` | Os dicionários definem a classificação, mas não repetem explicitamente a expressão “último ano de análise”. Os quatro campos são constantes dentro de cada curso–coorte. O código de área geral foi confrontado adicionalmente com o CES final na coorte 2020; os exemplos de mudança correspondem ao cadastro final. Isso não comprova a regra temporal interna de todos os campos Cine. |
| `NU_ANO_INGRESSO` | Ano de ingresso que define a coorte. |
| `NU_ANO_REFERENCIA` | Ano do vínculo/resultados apresentados naquela linha. |
| `NU_PRAZO_INTEGRALIZACAO`, `NU_ANO_INTEGRALIZACAO`, `NU_PRAZO_ACOMPANHAMENTO`, `NU_ANO_MAXIMO_ACOMPANHAMENTO` | Parâmetros de duração e anos previstos de integralização/acompanhamento. O dicionário não informa, nesses campos, de qual edição cadastral foi obtido o prazo. Não se deve atribuir automaticamente a eles o ano final da janela. O ano máximo previsto não é o máximo ano efetivamente publicado. |
| `QT_INGRESSANTE` | Tamanho da coorte de ingresso, reconstruída longitudinalmente, repetido em cada ano de acompanhamento. |
| `QT_PERMANENCIA`, `QT_CONCLUINTE`, `QT_DESISTENCIA`, `QT_FALECIDO` | Situação ou eventos do ano de referência da linha. |
| `TAP`, `TCA`, `TDA`, `TCAN`, `TADA` | Taxas referentes ao ano da linha; `TCA` e `TDA` acumulam eventos até esse ano. |

### 4.1 Fim da janela, última linha publicada e último cadastro disponível

É necessário separar três conceitos:

1. **Fim da janela de publicação:** por exemplo, 2019 em `2010_2019`.
2. **Último ano com linha do curso–coorte na trajetória:** máximo de `NU_ANO_REFERENCIA` para esse par.
3. **Último ano em que o curso aparece no cadastro público do CES dentro da janela.**

**Nos 323.297 pares curso–coorte examinados, os conceitos 1 e 2 coincidem.** Nenhum curso tem seu painel publicado interrompido antes do fim da janela. Portanto, nestes arquivos, “última linha da coorte–curso” não identifica uma data diferente do fim da janela. As linhas continuam publicadas mesmo depois de a permanência chegar a zero: na coorte 2020–2024 há 19.208 linhas com `QT_PERMANENCIA = 0`.

O conceito 3 frequentemente difere dos anteriores:

| Janela | Pares curso–coorte | Sem cadastro CES no ano final |
|---|---:|---:|
| 2010–2019 | 25.923 | 5.384 |
| 2011–2020 | 25.966 | 4.975 |
| 2012–2021 | 26.831 | 5.014 |
| 2013–2022 | 26.695 | 4.513 |
| 2014–2023 | 27.394 | 4.693 |
| 2015–2024 | 28.143 | 5.279 |
| 2016–2024 | 29.242 | 4.924 |
| 2017–2024 | 30.900 | 4.702 |
| 2018–2024 | 32.887 | 4.479 |
| 2019–2024 | 34.468 | 3.701 |
| 2020–2024 | 34.848 | 2.411 |
| **Total de pares** | **323.297** | **50.075** |

Todos esses cursos têm algum cadastro dentro da respectiva janela. Em todas as coortes, `CO_IES`, grau e modalidade coincidem com o último cadastro disponível; os códigos geográficos também coincidem quando estão preenchidos em ambas as fontes. Não houve divergência entre valores preenchidos desses seis campos. Para cursos EaD, a ausência geográfica na trajetória impede essa igualdade em alguns casos em que o cadastro tem localização preenchida.

Exemplo: na trajetória 2010–2019, o curso `1103713`, Educação Física da UFMT, tem atributos preenchidos, embora seu último cadastro CES nessa janela seja de 2012. A IES é 1 e o município é `5106653` nas duas fontes. O curso `1103714`, Geografia, apresenta a mesma situação, com município `5101803`.

**Interpretação sustentada:** a publicação usa atributos fixos para cada curso–coorte, compatíveis com o cadastro final quando disponível e com informações cadastrais anteriores quando o curso já não consta do CES final. **Não está demonstrado** se o Inep realiza uma busca retrospectiva no CES, mantém um cadastro histórico próprio ou usa outro procedimento equivalente. A igualdade empírica não revela a origem administrativa de cada campo.

Assim, “último ano de análise” não deve ser transformado na afirmação mais forte de que **todo atributo de todo curso foi efetivamente coletado naquele ano**.

### 4.2 Mudanças temporais não geram automaticamente ausência

Confronto entre CES 2020 e CES 2024, restrito aos cursos da coorte 2020 presentes nos dois cadastros e com valores preenchidos em ambos:

| Atributo | Cursos com valores diferentes em 2020 e 2024 | Atributo ausente na trajetória | Atributo igual ao CES 2024 |
|---|---:|---:|---:|
| IES | 369 | 0 | 369 |
| Município | 3 | 0 | 3 |
| Grau acadêmico | 2 | 0 | 2 |
| Área geral Cine | 163 | 0 | 163 |

Os códigos Cine foram normalizados numericamente para esse confronto, evitando falsas diferenças entre, por exemplo, `07` e `7`.

Exemplo: o curso `107886` pertence à IES 1139 no CES de 2020 e à IES 1923 no CES de 2024. A trajetória 2020–2024 usa `CO_IES = 1923`, incluindo nas linhas de 2020. Não fica ausente por ter mudado de IES.

## 5. Inventário sistemático de valores ausentes

### 5.1 Resultado em todas as planilhas

| Janela e arquivo de trajetória | Linhas válidas | Linhas EaD | Ausências em cada um dos três campos geográficos | Ausências nas outras 28 variáveis |
|---|---:|---:|---:|---:|
| [2010–2019](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2010_2019/indicadores_trajetoria_educacao_superior_2010_2019.xlsx>) | 259.230 | 6.970 | 6.970 | 0 |
| [2011–2020](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2011_2020/indicadores_trajetoria_educacao_superior_2011_2020.xlsx>) | 259.660 | 7.100 | 7.100 | 0 |
| [2012–2021](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2012_2021/indicadores_trajetoria_educacao_superior_2012_2021.xlsx>) | 268.310 | 7.860 | 7.860 | 0 |
| [2013–2022](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2013_2022/indicadores_trajetoria_educacao_superior_2013_2022.xlsx>) | 266.950 | 8.590 | 8.590 | 0 |
| [2014–2023](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2014_2023/indicadores_trajetoria_educacao_superior_2014_2023.xlsx>) | 273.940 | 10.880 | 10.880 | 0 |
| [2015–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2015_2024/indicadores_trajetoria_educacao_superior_2015_2024.xlsx>) | 281.430 | 11.180 | 11.180 | 0 |
| [2016–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2016_2024/indicadores_trajetoria_educacao_superior_2016_2024.xlsx>) | 263.178 | 11.619 | 11.619 | 0 |
| [2017–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2017_2024/indicadores_trajetoria_educacao_superior_2017_2024.xlsx>) | 247.200 | 15.168 | 15.168 | 0 |
| [2018–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2018_2024/indicadores_trajetoria_educacao_superior_2018_2024.xlsx>) | 230.209 | 19.390 | 19.390 | 0 |
| [2019–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2019_2024/indicadores_trajetoria_educacao_superior_2019_2024.xlsx>) | 206.808 | 23.664 | 23.664 | 0 |
| [2020–2024](</C:/OneDrive/incompletos/mec/data/raw/INEP-TRAJETORIA/2020_2024/indicadores_trajetoria_educacao_superior_2020_2024.xlsx>) | 174.240 | 26.230 | 26.230 | 0 |
| **Total** | **2.731.155** | **148.651** | **148.651 por campo** | **0** |

São 445.953 células geográficas ausentes, em 148.651 linhas. Ausência de região, UF e município ocorre conjuntamente e equivale exatamente à classificação EaD nos arquivos examinados. Não há casos presenciais com esses campos ausentes.

Esta é uma **regularidade empírica completa das edições locais**, não a recuperação do comando interno que criou as células vazias. Os dicionários de trajetórias não trazem uma regra explícita de geração desses missings nem uma explicação por número de polos ou municípios.

### 5.2 Teste da hipótese de múltiplos municípios ou múltiplas linhas

Na coorte 2020–2024, entre os cursos também presentes no CES 2024:

- **611 cursos EaD** têm apenas **um município preenchido distinto** no cadastro e, mesmo assim, têm os três campos geográficos ausentes na trajetória. São 609 cursos com duas linhas CES e dois com três linhas; a contagem de municípios ignora os valores ausentes.
- **16 cursos EaD** têm somente **uma linha** no CES 2024, de dimensão nacional e sem município, e também têm geografia ausente na trajetória.
- Nos 611 cursos de um município, `CO_IES` e `TP_GRAU_ACADEMICO` permanecem preenchidos na trajetória.

Logo, múltiplos municípios não são condição necessária para o missing geográfico; múltiplas linhas nem sequer são condição necessária; e a multiplicidade não torna todos os atributos do curso ausentes.

No CES, diferenças entre linhas do mesmo curso–ano decorrem também da coexistência de dimensões geográficas. O [dicionário do CES](</C:/OneDrive/incompletos/mec/docs/dicionario-dados-CensoEducacaoSuperior.md>) distingue cursos presenciais no Brasil (1), EaD no Brasil (2), dados EaD apenas nacionais (3) e oferta no exterior (4). Ele registra que número de cursos, vagas e inscritos EaD não podem ser quantificados por região, UF e município nessa estrutura. Isso explica a necessidade de examinar cada variável e cada dimensão, sem presumir uma mesma regra de soma para todas as colunas.

### 5.3 Tipos de ausência que precisam permanecer separados

| Situação | Evidência e interpretação |
|---|---|
| Célula vazia nas três variáveis geográficas da trajetória | Padrão exclusivo e universal de EaD nas 11 edições locais. Não preencher com município da sede da IES como se fosse o local dos estudantes. |
| Atributo muda entre anos do CES | Não implica ausência na trajetória. Os contraexemplos da seção 4.2 mostram seleção de um atributo cadastral fixo para a publicação. |
| Mais de uma linha CES por curso–ano | Não implica ausência generalizada de atributos. É necessário distinguir dimensões e a variável em análise. |
| Curso não consta do CES final | Não implica que seus atributos na trajetória estejam ausentes. Há 50.075 pares nessa situação. |
| Curso–coorte sem linha na trajetória | É ausência de observação/cobertura, não uma célula missing nem uma taxa zero. Atribuir sua causa exige examinar os critérios de seleção e os vínculos individuais. |
| Vínculo individual não observado em algum ano | A metodologia prevê tratamento longitudinal, incluindo imputação. Não corresponde automaticamente a `NA` na contagem agregada. |
| Linha final de fonte importada | Artefato de leitura: uma linha por planilha, com código de curso ausente. Deve ser excluída antes dos diagnósticos. |
| Coluna inexistente na trajetória | Variável não publicada, por exemplo `TP_DIMENSAO` e numerosas características do CES. Não é um valor ausente gerado por conflito entre linhas. |
| Zero em contagens ou taxas | Valor numérico distinto de ausência. Pode representar inexistência de eventos ou de vínculos ativos naquele ano. |

Não foi encontrada, nos arquivos e trechos documentais consultados, uma regra geral que substitua por missing todo atributo com mais de um valor dentro de curso–ano. Também não foi identificado código oficial que permita afirmar qual operação materializa a ausência geográfica EaD.

## 6. Implicações para a integração no projeto

1. Manter separados `ano_ingresso`, `ano_referencia` e `fim_janela_publicacao`. Os dois primeiros já existem na trajetória; o terceiro deve vir da identificação da edição.
2. Não interpretar a IES, categoria administrativa ou organização acadêmica da trajetória como uma série histórica anual. Os atributos são fixos dentro do curso–coorte publicado e podem refletir situação posterior ao ingresso.
3. Se a análise precisa de características contemporâneas, acrescentá-las a partir do CES do ano pretendido, preservando as originais da trajetória e identificando os pares sem correspondência. Um vínculo que muda de IES não deve desaparecer por se exigir igualdade com a IES histórica.
4. Para atributos cadastrais CES, assegurar chave única curso–ano antes da junção. Para contagens, escolher a dimensão e verificar a regra variável a variável: em Pedagogia/UFMT, a dimensão nacional tem zero em `QT_ING` e `QT_MAT`, enquanto as linhas municipais contêm estudantes.
5. Não distribuir indicadores EaD entre municípios com base apenas na repetição das linhas CES. Isso replicaria resultados do curso como se fossem específicos dos locais. A desagregação exige vínculos individuais/local de oferta ou indicadores já publicados nesse nível.
6. A harmonização territorial do projeto gera campos derivados ausentes quando o município de entrada é `NA` ou zero, conforme [gera_amc.R](</C:/OneDrive/incompletos/mec/code/helpers/gera_amc.R>). Essas ausências derivadas são diferentes das três ausências originais do Inep. O trecho de importação em [01-preparacao.R](</C:/OneDrive/incompletos/mec/code/01-preparacao.R>) não implementa uma regra de apagar atributos por multiplicidade no CES.

## 7. Limites e questões que permanecem abertas

- O dicionário local de 2010–2019 não pôde ser aberto, mesmo após nova tentativa fora da restrição inicial. A planilha dessa coorte foi lida integralmente e incluída nas verificações empíricas. A formulação documental da referência temporal foi conferida nos outros dez dicionários.
- O PDF integral da metodologia e os resumos técnicos não puderam ser baixados nas tentativas desta verificação. A consulta documental externa utilizou trechos oficiais recuperados pela busca, com as fontes indicadas acima. Não se afirma ter auditado integralmente todas as regras de seleção/exclusão descritas no PDF.
- Sem os vínculos longitudinais tratados e o código de produção do Inep, não se reproduzem a seleção inicial, as imputações individuais nem as razões específicas de exclusão de cada curso–coorte. A reprodução aritmética das taxas não substitui essa validação.
- A correspondência cadastral exata foi examinada em todas as coortes para IES, região, UF, município, grau e modalidade, respeitando a disponibilidade de valores. Para a área geral Cine, a comparação temporal adicional normalizada foi realizada na coorte 2020–2024; não foi validada sistematicamente a origem temporal dos nomes e rótulos Cine, dos nomes cadastrais ou dos quatro parâmetros de duração.
- Não é possível identificar um ano de coleta efetiva para cada atributo de um curso ausente do cadastro final apenas pela expressão “último ano de análise”. O dado sustenta compatibilidade com o último cadastro disponível, sem provar o algoritmo ou o uso de fontes administrativas adicionais.
- As constatações valem para as 11 edições locais examinadas. Não são uma garantia sobre outras versões, novas publicações ou revisões futuras.

**Resposta à questão central:** a base combina atributos cadastrais fixos por publicação com resultados anuais da coorte. Nos arquivos locais, todas as trajetórias publicadas chegam ao fim da janela; atributos de cursos que desapareceram do cadastro podem conservar informação anterior. Os missings observados limitam-se à geografia EaD e não decorrem de uma regra geral de apagar atributos variáveis ou cursos com múltiplas linhas.
