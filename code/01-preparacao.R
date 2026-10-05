#==============================================================================#
# INDICADORES PARA ANALISE DA EDUCACAO SUPERIOR NO BRASIL
# Pre-processamento dos inputs 
# Pedro HGF Souza 
# Maio/2026
#==============================================================================#

# INSTRUCOES ===================================================================

# Este script faz o pre-processamento dos dados brutos que serão utilizados no
# projeto e salva os arquivos processados na pasta `data/clean`.

# Inputs:
# - Script com a configuracao do projeto
#   - `code/_setup.R`
# - Scripts com funcoes auxiliares
#   - `code/helpers/detecta_siglas_comerciais.R`
# - `code/helpers/moda.R`
# - `code/helpers/padroniza_chr.R`
# - Microdados do Censo da Educacao Superior, 2010-2024
#   - `data/raw/CES-CURSOS/*.parquet
#   - `data/raw/CES-IES/*.parquet`

# Outputs:
# - Microdados limpos do Censo da Educacao Superior, 2010-2024
#   - `data/clean/ces_cursos.parquet
#   - `data/clean/ces_ies.parquet`
# - Rotulos de valores para variaveis selecionadas
#   - `data/clean/rotulos_variaveis.csv`


# CONFIGURACAO =================================================================

source('code/_setup.R')


# CENSO DA EDUCACAO SUPERIOR - CURSOS ==========================================

## Importacao dos dados brutos -------------------------------------------------

ces_cursos <- map(
  .x = list.files(here('data/raw/ces-cursos'), '\\.parquet$', full.names = TRUE),
  .f = ~ read_parquet(.x) |> 
    select(
      NU_ANO_CENSO:TP_DIMENSAO, 
      CO_IES:CO_CURSO, 
      CO_CINE_AREA_GERAL:NO_CINE_AREA_GERAL, 
      TP_GRAU_ACADEMICO:TP_NIVEL_ACADEMICO,  
      QT_VG_TOTAL:QT_VG_PROG_ESPECIAL, 
      QT_INSCRITO_TOTAL:QT_INSC_VG_PROG_ESPECIAL, 
      QT_ING:QT_ING_OUTRA_FORMA, 
      QT_MAT:QT_MAT_NOTURNO, QT_CONC:QT_CONC_NOTURNO, 
    )
  ) |> 
  bind_rows()
  
## Pre-processamento -----------------------------------------------------------

ces_cursos <- ces_cursos |> 
  # Padroniza nomes de variaveis
  rename_with(tolower, .cols = everything()) |> 
  rename_with(~ paste0(.x, '_oferta'), .cols = no_regiao:in_capital) |> 
  rename(ano = nu_ano_censo) |> 
  # Padroniza conteudo de variaveis do tipo character
  mutate(across(where(is.character), padroniza_chr)) |> 
  # Ordena por chaves de identificacao 
  arrange(co_ies, co_curso, ano, tp_dimensao, co_municipio_oferta)

## Filtros ---------------------------------------------------------------------

ces_cursos <- ces_cursos |>
  filter(
    # exclui cursos EaD ofertados no exterior
    tp_dimensao != 4 & 
    # exclui cursos sequenciais de formacao especifica
    tp_nivel_academico != 2 
  )

## Ensino a Distancia (EaD) ----------------------------------------------------

# Problema: 
# CES nao inclui explicitamente variaveis para ingressantes, matriculas e 
# concluintes em EaD.

# Solucao:
# Criacao de variaveis com valores validos para tp_dimensao != 3: `qt_ing_ead`,
# `qt_mat_ead` e `qt_conc_ead`.

ces_cursos  <- ces_cursos  |>
  mutate(
    qt_ing_ead = qt_ing - qt_ing_diurno - qt_ing_noturno,
    qt_mat_ead = qt_mat - qt_mat_diurno - qt_mat_noturno,
    qt_conc_ead = qt_conc - qt_conc_diurno - qt_conc_noturno
  )

## Output ----------------------------------------------------------------------

write_parquet(ces_cursos, here('data/clean/ces_cursos.parquet'))


# CENSO DA EDUCACAO SUPERIOR - IES =============================================

## Importacao dos dados brutos -------------------------------------------------

ces_ies <- map(
  .x = list.files(here('data/raw/ces-ies'), '\\.parquet$', full.names = TRUE),
  .f = read_parquet
) |> 
  bind_rows()

## Pre-processamento -----------------------------------------------------------

ces_ies <- ces_ies |> 
  # Padroniza nomes de variaveis
  rename_with(tolower, .cols = everything()) |> 
  rename(ano = nu_ano_censo) |>
  # Padroniza conteudo de variaveis do tipo character
  mutate(across(where(is.character), padroniza_chr)) |> 
  # Ordena por chaves de identificacao
  arrange(co_ies, ano)

## Filtros ---------------------------------------------------------------------

ces_ies <- ces_ies |> 
  # mantem somente IES com pelo menos um curso com dados validos no ano
  inner_join(ces_cursos |> select(co_ies, ano) |> distinct())

## Diagnostico de `tp_categoria_administrativa` --------------------------------

# Inicializacao
diag.tp_categoria_administrativa <- list()

# Dados
diag.tp_categoria_administrativa$data <- ces_ies |> 
  distinct(co_mantenedora, co_ies, ano, tp_categoria_administrativa) |>
  mutate(presente = 1L) |>
  complete(co_ies, ano = 2010:2024) |> 
  arrange(co_ies, ano) |> 
  mutate(
    presente   = coalesce(presente, 0L), 
    apareceu   = presente > lag(presente), 
    sumiu      = presente < lag(presente),
    permaneceu = presente == 1L & lag(presente) == 1L,
    mudou_mantenedora = permaneceu & co_mantenedora != lag(co_mantenedora),
    mudou_categoria_admin = permaneceu & tp_categoria_administrativa != lag(tp_categoria_administrativa),
    sem_mudancas = permaneceu & !mudou_mantenedora & !mudou_categoria_admin,
    com_mudancas = mudou_mantenedora | mudou_categoria_admin,
    mudou_somente_mantenedora = mudou_mantenedora & !mudou_categoria_admin, 
    mudou_somente_categoria_admin =  !mudou_mantenedora & mudou_categoria_admin, 
    mudou_ambas = mudou_mantenedora & mudou_categoria_admin,
    across(
      .cols = c(apareceu, sumiu, permaneceu, matches('^(sem|com|mudou)')), 
      .fns = ~ if_else(ano == 2010, NA_integer_, as.integer(.x))),
    .by = co_ies
  ) |>
  relocate(sem_mudancas, com_mudancas, .after = permaneceu)

# Totais por ano
diag.tp_categoria_administrativa$totais_por_ano <- diag.tp_categoria_administrativa$data |> 
  summarise(across(presente:last_col(), sum), .by = ano)

# Totais por IES
diag.tp_categoria_administrativa$totais_por_ies <- diag.tp_categoria_administrativa$data |> 
  filter(ano > 2010) |>
  summarise(across(presente:last_col(), sum), .by = c(co_ies)) |> 
  arrange(desc(com_mudancas))

# Totais por categoria administrativa em t1
diag.tp_categoria_administrativa$totais_por_categoria_em_t1 <- 
  diag.tp_categoria_administrativa$data |> 
  filter(ano > 2010) |>
  summarise(across(presente:last_col(), sum), .by = c(tp_categoria_administrativa)) |> 
  arrange(tp_categoria_administrativa)

# Transicoes entre categorias administrativas
diag.tp_categoria_administrativa$transicoes_categoria <- 
  diag.tp_categoria_administrativa$data |> 
  mutate(
    variavel = 'tp_categoria_administrativa', 
    t0 = lag(tp_categoria_administrativa), 
    t1 = tp_categoria_administrativa,
    .by = co_ies
  ) |> 
  summarise(num_transicoes = n(), .by = c(variavel, t0, t1, mudou_mantenedora)) |> 
  filter(!is.na(t0) & !is.na(t1)) |> 
  arrange(t0, t1) |> 
  mutate(pct_t0 = 100 * num_transicoes / sum(num_transicoes), .by = t0) |> 
  mutate(pct_t1 = 100 * num_transicoes / sum(num_transicoes), .by = t1) 

# Mantenedoras com IES de multiplas categorias administrativas
diag.tp_categoria_administrativa$combinacoes_em_um_mesmo_ano <-
  diag.tp_categoria_administrativa$data |> 
  distinct(co_mantenedora, ano, tp_categoria_administrativa) |> 
  filter(!is.na(tp_categoria_administrativa)) |> 
  summarise(
    across(
      .cols = tp_categoria_administrativa, 
      .fns = ~ as.integer(paste0(sort(unique(na.omit(tp_categoria_administrativa))), collapse = "")),
      .names = 'categorias_em_um_mesmo_ano'
    ),
    .by = c(co_mantenedora, ano)
  ) |> 
  tabyl(categorias_em_um_mesmo_ano) |> 
  rename(num_combinacoes_mantenedora_ano = n) |> 
  arrange(categorias_em_um_mesmo_ano) |> 
  mutate(
    across(categorias_em_um_mesmo_ano, ~ str_replace_all(as.character(.x), "(?<=.)(?=.)", "-")),
    percent = 100 * percent,
    cumulative_percent = cumsum(percent)
  )

## Correcoes para IES publicas -------------------------------------------------

# Problema:
# IES publicas cuja declaracao de categoria administrativa e mantenedora varia 
# artificialmente ao longo do tempo. 

# Solucao:
# Criacao de variaveis consistentes ao longo do tempo para IES publicas:
# `tp_categoria_harm`, `co_mantenedora_harm` e `no_mantenedora_harm`.

# Correcao para IES declaradas em algum ano como publicas federais e estaduais
ces_ies <- ces_ies |> 
  mutate(
    min = min(tp_categoria_administrativa),
    # Reclassificacao pelo valor modal das ultimas cinco aparicoes para evitar 
    # variacoes espurias
    w = as.integer((max(ano) - ano) < 5), 
     across(
      .cols = c(tp_categoria_administrativa, co_mantenedora, no_mantenedora),
      .fns = ~ if_else(min <= 2, moda(.x, w)[1], .x),
      .names = '{.col}_harm'
    ),   
    .by = co_ies
  ) |> 
  select(-min, -w)

# Correcao para IES declaradas em algum ano como publicas municipais
ces_ies <- ces_ies |>
  mutate(
    min = min(tp_categoria_administrativa_harm),
    moda = moda(tp_categoria_administrativa_harm)[1],
    ind_muni = max(str_detect(no_mantenedora_harm, '(AUTARQUIA|MUNICIPIO|MUNICIPAL)')), 
    tp_categoria_administrativa_harm = case_when(
      # Reclassificacao como municipal para mantenedoras com nomes indicativos 
      # de orgaos publicos em algum ano
      min >= 3 & ind_muni == 1 ~ 3L, 
      # Reclassificacao pelo valor modal para mantenedoras de IES declaradas 
      # como municipais em algum ano
      min == 3 ~ moda, 
      .default = tp_categoria_administrativa_harm
    ),
    .by = c(co_mantenedora_harm, co_ies)
  ) |> 
  select(-min, -moda, -ind_muni)

## Categoria administrativa harmonizada por mantenedora-ano --------------------

# Problema:
# Classificacoes inconsistentes para IES de uma mesma mantenedora e/ou erroneas 
# para algumas mantenedoras em determinado ano.

# Solucao:
# Criacao de variavel `catadm_it` corrigida para as combinacoes mantenedora-ano.

ces_ies <- ces_ies |>
  mutate(
    min = min(tp_categoria_administrativa_harm),
    ind_restrito = detecta_sigla_comercial(no_mantenedora_harm, restrito = TRUE),
    ind_amplo = detecta_sigla_comercial(no_mantenedora_harm, restrito = FALSE),
    # Classificacao inicial conforme o valor modal das IES mantidas a cada ano
    catadm_it = moda(tp_categoria_administrativa_harm)[1],
    catadm_it = case_when(
      # Reclassifica como publicas as mantenedoras com alguma IES publica no ano
      min <= 3 ~ min,
      # Reclassifica como com fins lucrativos as mantenedoras com valor modal
      # sem fins lucrativos, mas cujo nome denota empresas exclusivamente 
      # comerciais
      catadm_it == 5 & ind_restrito == TRUE ~ 4L, 
      # Reclassifica como com fins lucrativos as mantenedoras com valor modal 
      # sem fins lucrativos, mas que possuem alguma IES declarada como com fins
      # lucrativos e cujo nome denota empresa tipicamente comercial 
      catadm_it == 5 & min == 4 & ind_amplo == TRUE ~ 4L,       
      # Reclassifica como sem fins lucrativos as mantenedoras com valor modal 
      # especial
      catadm_it == 7 ~ 5L,
      .default = catadm_it
    ), 
    .by = c(co_mantenedora_harm, ano)
  ) |> 
  select(-min, -ind_restrito, -ind_amplo)

## Categoria administrativa harmonizada so por mantenedora ---------------------

# Problema:
# Mesmo apos a harmonizacao, a categoria administrativa de muitas mantenedoras 
# varia ao longo do tempo. Essa variacao pode ser legitima, mas em muitos casos 
# e' artificial

# Solucao:
# Como nao e' possivel discriminar entre variacoes legitimas e artificiais, 
# sao criadas duas novas variaveis invariantes no tempo:
# - `catadm_i`
# - `catadm_i5`

ces_ies <- ces_ies |> 
  # Peso para evitar dupla contagem de mantenedoras com multiplas IES no mesmo ano
  mutate(w = 1 / n(), .by = c(co_mantenedora_harm, ano)) |>
  mutate(
    # Peso que leva em conta somente os cinco anos anteriores 'a ultima aparicao
    # da mantenedora no CES
    w_last5 = w * ((max(ano) - ano) < 5), 
    # Classificacao pelo valor modal de toda a serie historica
    catadm_i  = moda(catadm_it, w)[1], 
    # Classificacao pelo valor modal somente dos cinco anos anteriores 'a 
    # ultima aparicao da mantenedora no CES
    catadm_i5 = moda(catadm_it, w_last5)[1],
    .by = co_mantenedora_harm
  ) |> 
  select(-w, -w_last5)
 
## Agregacao de tipo de organizacao academica ----------------------------------

# Problema:
# `tp_organizacao_academica` e' excessivamente desagregada para o projeto

# Solucao:
# Criacao de variavel mais agregada `tp_organicao_academica_harm`

ces_ies <- ces_ies |>
  mutate(
    across(tp_organizacao_academica, ~ if_else(.x == 5, 4, .x), .names = '{.col}_harm')
  )

## Output ----------------------------------------------------------------------

write_parquet(ces_ies, here('data/clean/ces_ies.parquet'))

write_xlsx(diag.tp_categoria_administrativa, here('logs/tp_categoria_administrativa.xlsx'))

# CENSO DA EDUCACAO SUPERIOR - MANTENEDORAS ====================================

## Pre-processamento -----------------------------------------------------------

ces_mantenedoras <- full_join(
  ces_ies |> select(co_mantenedora_harm, no_mantenedora_harm, catadm_it, co_ies, ano),
  ces_cursos |> select(co_ies, co_curso, ano, qt_mat)
) |>
  summarise(
    num_ies = n_distinct(co_ies),
    num_cursos = n_distinct(co_curso), 
    qt_mat = sum(qt_mat, na.rm = TRUE),
    .by = c(matches('harm$'), catadm_it, ano)
  ) 

## Ranking de mantenedoras por matriculas no ano -------------------------------

ces_mantenedoras <- ces_mantenedoras |>
  mutate(
    ranking = row_number(desc(qt_mat)), 
    fx_ranking = cut(ranking, breaks = c(seq(0, 20, 5), Inf), labels = FALSE),
    .by = ano
  )

## Output ----------------------------------------------------------------------

write_parquet(ces_mantenedoras, here('data/clean/ces_mantenedoras.parquet'))


# ROTULOS PARA VARIAVEIS =======================================================

## Rotulos manuais para variaveis unicas ---------------------------------------

rotulos_vars <- list() 

rotulos_vars$total <- data.frame(
  bloco_nome = 'Total',
  grupo_code = 1, 
  grupo_nome = 'Total'
)

rotulos_vars$tp_modalidade_ensino <- data.frame(
  bloco_nome = "Modalidade de ensino", 
  grupo_code = c(1, 2),
  grupo_nome = c("Presencial", "Educação a Distância")
)

rotulos_vars$co_cine_area_geral <- data.frame(
  bloco_nome = 'Área de conhecimento (CINE Brasil)', 
  grupo_code = 0:10,
  grupo_nome = c(
    'Programas Básicos',
    'Educação',
    'Artes e Humanidades',
    'Ciências Sociais, Comunicação e Informação',
    'Negócios, Administração e Direito',
    'Ciências Naturais, Matemática e Estatística',
    'Computação e TIC',
    'Engenharia, Produção e Construção',
    'Agricultura, Silvicultura, Pesca e Veterinária',
    'Saúde e Bem-estar',
    'Serviços'
  )
)

rotulos_vars$tp_organizacao_academica_harm <- data.frame(
  bloco_nome = 'Organização Acadêmica',
  grupo_code = 1:4, 
  grupo_nome = c('Universidade', 'Centro Universitário', 'Faculdade', 'IF/CEFET')
)

rotulos_vars$catadm_it <- data.frame(
  bloco_nome = 'Categoria Administrativa',
  grupo_code = 1:5,
  grupo_nome = c(
    'Pública Federal', 'Pública Estadual', 'Pública Municipal', 
    'Privada com fins lucrativos','Privada sem fins lucrativos'
  )
)

rotulos_vars$catadm_i <- rotulos_vars$catadm_it

rotulos_vars$catadm_i5 <- rotulos_vars$catadm_it

rotulos_vars$fx_ranking <- data.frame(
  bloco_nome = 'Tamanho de mantenedoras por número de matrículas',
  grupo_code = 1:5, 
  grupo_nome = c(
    paste('Top', c('5', '6-10', '11-15', '16-20'), 'mantenedoras'), 
    'Demais mantenedoras'
  )
)

rotulos_vars$turno <- data.frame(
  bloco_nome = 'Turno de ensino', 
  grupo_code = 1:3, 
  grupo_nome = c('Presencial - Diurno', 'Presencial - Noturno', 'Educação a Distância')
)

rotulos_vars$fx_pct_ead <- data.frame(
  bloco_nome = 'Percentual de matriculas na educacao a distancia',
  grupo_code = 1:4, 
  grupo_nome = c(
    'IES sem EaD', 'Mais de 0% e até 33% das matrículas',
    'Mais de 33% e até 66% das matrículas', 'Mais de 66% das matrículas'
  )
)

rotulos_vars <- bind_rows(rotulos_vars, .id = 'bloco_var')

## Rotulos para combinacoes de variaveis ---------------------------------------

rotulos_combo <- list(
  c('catadm_it', 'tp_organizacao_academica_harm'),
  c('catadm_it', 'tp_modalidade_ensino'),
  c('catadm_it', 'turno'),
  c('catadm_it', 'co_cine_area_geral'),
  c('catadm_it', 'co_cine_area_geral', 'tp_modalidade_ensino'),
  c('catadm_it', 'co_cine_area_geral', 'turno'),  
  c('co_cine_area_geral', 'tp_modalidade_ensino'),
  c('co_cine_area_geral', 'turno'), 
  c('fx_ranking', 'tp_modalidade_ensino'),
  c('fx_ranking', 'turno')  
)

rotulos_combo <- map(rotulos_combo, ~ combina_rotulos(.x, rotulos_vars)) |> bind_rows()

### Outputs --------------------------------------------------------------------

bind_rows(rotulos_vars, rotulos_combo) |> 
  arrange(bloco_var, grupo_code) |>
  write_csv(here('data/clean/rotulos_variaveis.csv'))

