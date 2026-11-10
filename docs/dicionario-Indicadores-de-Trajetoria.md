# Dicionário dos indicadores de trajetória por curso

Dicionário único para as 11 edições locais dos Indicadores de Trajetória da Educação Superior do Inep: 2010–2019, 2011–2020, 2012–2021, 2013–2022, 2014–2023, 2015–2024, 2016–2024, 2017–2024, 2018–2024, 2019–2024 e 2020–2024.

O conteúdo textual dos 11 arquivos `Dicionário_acompanhamento_trajetória.docx`, nas subpastas de `data/raw/INEP-TRAJETORIA/`, foi comparado integralmente em 24/10/2026 e é idêntico. Esta versão reúne as mesmas 31 variáveis, na ordem original, com suas descrições, tipos, tamanhos, categorias e notas. A validade para outras edições depende de nova conferência.

A transcrição preserva as grafias e classificações do original, inclusive eventuais inconsistências. Por exemplo, `NO_CURSO` está definido como `Num`, quatro nomes de contagens contêm espaço após `QT` e `NU_PRAZO_INTEGRALIZAÇÃO` contém acentuação. Esses registros não devem ser interpretados como uma conferência dos nomes ou tipos efetivamente usados nas planilhas de dados.

## Variáveis

### DADOS DA IES

| Posição | Nome da variável | Descrição | Tipo | TAM¹ | F/V² | Descrição das categorias |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | CO_IES | Código único de identificação da instituição de educação superior em que o curso está localizado no último ano de análise. | Num | 8 | V |  |
| 2 | NO_IES | Nome da instituição de educação superior em que o curso está localizado no último ano de análise. | Char | 200 | V |  |
| 3 | TP_CATEGORIA_ADMINISTRATIVA | Código da categoria Administrativa da IES no último ano de análise. | Num | 1 | F | 1. Pública Federal<br>2. Pública Estadual<br>3. Pública Municipal<br>4. Privada com fins lucrativos<br>5. Privada sem fins lucrativos<br>7. Especial |
| 4 | TP_ORGANIZACAO_ACADEMICA | Código da organização acadêmica no último ano de análise. | Num | 1 | F | 1. Universidade<br>2. Centro Universitário<br>3. Faculdade<br>4. Instituto Federal de Educação, Ciência e Tecnologia                                <br> 5. Centro Federal de Educação Tecnológica |

### DADOS DO CURSO

| Posição | Nome da variável | Descrição | Tipo | TAM¹ | F/V² | Descrição das categorias |
| --- | --- | --- | --- | --- | --- | --- |
| 5 | CO_CURSO | Código único de identificação do curso gerado pelo E-MEC, com a informação do último ano de análise. | Num | 8 | V |  |
| 6 | NO_CURSO | Nome do curso com a informação do último ano de análise. | Num | 200 | V |  |
| 7 | CO_REGIAO | Código da Região Geográfica do local de oferta do curso gerado pelo E-MEC no último ano de análise. | Num | 1 | F | 1. Região Norte<br>2. Região Nordeste<br>3. Região Sudeste<br>4. Região Sul<br>5. Região Centro-Oeste |
| 8 | CO_UF | Código da Unidade da Federação do local de oferta do curso gerado pelo E-MEC no último ano de análise. | Num | 2 | F |  |
| 9 | CO_MUNICIPIO | Código do município do local de oferta do curso gerado pelo E-MEC no último ano de análise. | Num | 7 | F |  |
| 10 | TP_GRAU_ACADEMICO | Código do grau acadêmico conferido ao diplomado pelo curso no último ano de análise. | Num | 1 | F | 1. Bacharelado<br>2. Licenciatura<br>3. Tecnológico |
| 11 | TP_MODALIDADE_ENSINO | Código da modalidade de ensino do curso no último ano de análise. | Num | 1 | F | 1. Presencial<br>2. Curso a distância |
| 12 | CO_CINE_AREA_GERAL | Código da área geral conforme adaptação da Classificação Internacional Normalizada da Educação Cine/Unesco | Num | 1 | F |  |
| 13 | NO_CINE_AREA_GERAL | Nome da área geral conforme adaptação da Classificação Internacional Normalizada da Educação Cine/Unesco | Char | 120 | V |  |
| 14 | CO_CINE_ROTULO | Código de identificação do curso, conforme adaptação da Classificação Internacional Normalizada da Educação Cine/Unesco | Num | 7 | V |  |
| 15 | NO_CINE_ROTULO | Nome de identificação do curso, conforme adaptação da Classificação Internacional Normalizada da Educação Cine/Unesco | Char | 120 | V |  |
| 16 | NU_ANO_INGRESSO | Ano de ingresso do aluno no curso. | Num | 4 | F |  |
| 17 | NU_ANO_REFERENCIA | Ano de referência do vínculo do ingressante. | Num | 4 | F |  |
| 18 | NU_PRAZO_INTEGRALIZAÇÃO | Prazo mínimo de integralização de curso de graduação em número de anos | Num | 2 | F |  |
| 19 | NU_ANO_INTEGRALIZACAO | Ano previsto de integralização do aluno ao curso. | Num | 4 | F |  |
| 20 | NU_PRAZO_ACOMPANHAMENTO | Prazo máximo de integralização de curso de graduação em número de anos | Num | 2 | F |  |
| 21 | NU_ANO_MAXIMO_ACOMPANHAMENTO | Ano máximo de acompanhamento da situação de vínculo do aluno. | Num | 4 | F |  |
| 22 | QT_INGRESSANTE | Número de ingressantes do curso no ano de ingresso da coorte. | Num | 8 | V |  |
| 23 | QT _PERMANENCIA | Número de estudantes que permaneceram no curso de graduação no ano de referência da análise | Num | 8 |  V |  |
| 24 | QT _CONCLUINTE | Número de estudantes que concluíram o curso de graduação no ano de referência da análise | Num | 8 | V |  |
| 25 | QT _DESISTENCIA | Número de estudantes que desistiram do curso de graduação no ano de referência da análise | Num | 8 | V |  |
| 26 | QT _FALECIDO | Número de estudantes que faleceram no ano de referência da análise | Num | 8 | V |  |

### INDICADORES DE TRAJETÓRIA

| Posição | Nome da variável | Descrição | Tipo | TAM¹ | F/V² | Descrição das categorias |
| --- | --- | --- | --- | --- | --- | --- |
| 27 | TAP | Taxa de Permanência | Num | 5 | V | Percentual de ingressantes que estão com vínculo ativo no curso no ano de referência |
| 28 | TCA | Taxa de Conclusão Acumulada | Num | 5 | V | Percentual de ingressantes que concluíram o curso até o ano de referência |
| 29 | TDA | Taxa de Desistência Acumulada | Num | 5 | V | Percentual de ingressantes que desistiram do curso até o ano de referência |
| 30 | TCAN | Taxa de Conclusão Anual | Num | 5 | V | Percentual de ingressantes que concluíram o curso no ano de referência |
| 31 | TADA | Taxa de Desistência Anual | Num | 5 | V | Percentual de ingressantes que desistiram do curso no ano de referência |

## Notas do dicionário original

1. Tamanho da variável.
2. Tamanho fixo/Tamanho variável.

