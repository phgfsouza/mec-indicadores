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


# GEOGRAFIA ====================================================================

# Inicializa lista vazia
geobr <- list()

# Municipios com AMC de 2010
geobr$municipio_amc <- read_municipality(year = 2010, simplified = FALSE) |> 
  gera_amc(code_muni, here("data/raw/IBGE-DTB/dtb_2010.xls")) |>
  rename(ano = year) |> 
  group_by(across(cod_regiao:nome_muni_amc), ano) |>
  summarise(num_muni = n(), .groups = "drop")

# Microrregioes com AMC de 2010
geobr$microrregiao_amc <- geobr$municipio_amc |>
  group_by(across(cod_regiao:nome_micro_amc), ano) |>
  summarise(
    num_muni = sum(num_muni), 
    num_muni_amc = n(), 
    .groups = "drop"
  )

# Mesorregioes com AMC de 2010
geobr$mesorregiao_amc <- geobr$microrregiao_amc |>
  group_by(across(cod_regiao:nome_meso_amc), ano) |>
  summarise(    
    num_muni = sum(num_muni), 
    num_muni_amc = sum(num_muni_amc), 
    num_micro_amc = n(),
    .groups = "drop"
  )

# Unidades da Federacao
geobr$uf <- read_state(year = 2010, simplified = FALSE) |>
  select(cod_uf = code_state, ano = year, geometry) |> 
  inner_join(
    st_drop_geometry(geobr$mesorregiao_amc) |>
      distinct(cod_regiao, nome_regiao, cod_uf, nome_uf)
  ) |>
  select(cod_regiao, nome_regiao, cod_uf, nome_uf, ano, geometry)

# Regioes
geobr$regiao <- read_region(year = 2010, simplified = FALSE) |>
  select(cod_regiao = code_region, geometry, ano = year) |> 
  inner_join(
    st_drop_geometry(geobr$uf) |> distinct(cod_regiao, nome_regiao)
  ) |>
  select(cod_regiao, nome_regiao, ano, geometry)

# Outputs
imap(
  .x = geobr, 
  .f = \(x, idx) write_sf(x, here("data/clean/", sprintf("geobr_%s.gpkg", idx)))
)


# POPULACAO ====================================================================

pop <- read_parquet(here("data/raw/RIPSA-POP/ripsa_pop_2000_2025.parquet")) |>
  gera_amc(cod_muni7, here("data/raw/IBGE-DTB/dtb_2010.xls")) |>
  filter(ano %in% 2010:2024) |>
  summarise(
    populacao_total = sum(populacao),
    populacao_18mais = sum( populacao * (idade >= 18)),
    .by = c(cod_regiao:nome_muni_amc, ano)
  ) |>
  arrange(cod_muni_amc, ano) |>
  mutate(across(where(is.character), padroniza_chr))

write_parquet(pop, here("data/clean/ripsa_pop.parquet"))


# CENSO DO ENSINO SUPERIOR =====================================================

## Cursos ----------------------------------------------------------------------

# Importacao dos dados brutos 
ces_cursos <- map(
  .x = list.files(here('data/raw/ces-cursos'), '\\.parquet$', full.names = TRUE),
  .f = ~ read_parquet(.x) |> 
    select(
      NU_ANO_CENSO, CO_MUNICIPIO, TP_DIMENSAO, 
      CO_IES, NO_CURSO, CO_CURSO, 
      CO_CINE_AREA_GERAL:NO_CINE_AREA_GERAL, 
      TP_GRAU_ACADEMICO:TP_NIVEL_ACADEMICO,  
      QT_VG_TOTAL:QT_VG_PROG_ESPECIAL, 
      QT_INSCRITO_TOTAL:QT_INSC_VG_PROG_ESPECIAL, 
      QT_ING:QT_ING_OUTRA_FORMA, 
      QT_MAT:QT_MAT_NOTURNO, QT_CONC:QT_CONC_NOTURNO, 
    )
  ) |> 
  bind_rows()
  
# Pre-processamento 
ces_cursos <- ces_cursos |> 
  # Gera AMC de municipios com referencia 2010
  gera_amc(CO_MUNICIPIO, here("data/raw/IBGE-DTB/dtb_2010.xls")) |> 
  # Padronizacoes
  rename_with(tolower, .cols = everything()) |> 
  rename(ano = nu_ano_censo) |> 
  mutate(across(where(is.character), padroniza_chr)) |> 
  # Descarta variaveis
  select(-co_municipio) |> 
  # Ordena variaveis
  relocate(cod_regiao:nome_muni_amc, ano) |>
  # Ordena por chaves de identificacao 
  arrange(co_ies, co_curso, ano, tp_dimensao, cod_muni_amc)

# Filtros 
ces_cursos <- ces_cursos |>
  filter(
    # exclui cursos EaD ofertados no exterior
    tp_dimensao != 4 & 
    # exclui cursos sequenciais de formacao especifica
    tp_nivel_academico != 2 
  )

# Ensino a Distancia (EaD)
ces_cursos  <- ces_cursos  |>
  mutate(
    qt_ing_ead = qt_ing - qt_ing_diurno - qt_ing_noturno,
    qt_mat_ead = qt_mat - qt_mat_diurno - qt_mat_noturno,
    qt_conc_ead = qt_conc - qt_conc_diurno - qt_conc_noturno
  )

# Output 
write_parquet(ces_cursos, here('data/clean/ces_cursos.parquet'))

## IES -------------------------------------------------------------------------

# Importacao dos dados brutos
ces_ies <- map(
  .x = list.files(here('data/raw/ces-ies'), '\\.parquet$', full.names = TRUE),
  .f = read_parquet
) |> 
  bind_rows()

# Pre-processamento
ces_ies <- ces_ies |> 
  # Gera AMC de municipios com referencia 2010
  gera_amc(CO_MUNICIPIO_IES, here("data/raw/IBGE-DTB/dtb_2010.xls")) |> 
  # Padronizacoes
  rename_with(tolower, .cols = everything()) |> 
  rename_with(~ paste0(.x, "_ies"), .cols = cod_regiao:nome_muni_amc) |>
  rename(ano = nu_ano_censo) |>
  mutate(across(where(is.character), padroniza_chr)) |> 
  # Ordena variaveis
  relocate(cod_regiao_ies:nome_muni_amc_ies, ano) |>
  # Ordena por chaves de identificacao
  arrange(co_ies, ano) |>
  # Descarta variaveis
  select(-matches("regiao_ies$)"))
 
# Filtro para manter somente IES com pelo menos um curso com dados validos no ano
ces_ies <- inner_join(ces_ies, ces_cursos |> select(co_ies, ano) |> distinct())

# Correcao para IES declaradas em algum ano como publicas federais e estaduais,
# de forma a gerar variaveis consistentes ao longo do tempo para IES publicas
# (`tp_categoria_harm`, `co_mantenedora_harm` e `no_mantenedora_harm`)
ces_ies <- ces_ies |> 
  mutate(
    min = min(tp_categoria_administrativa),
    # Reclassificacao pelo valor modal dos ultimos cinco anos
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

# Harmonizacao de categoria administrativa por mantenedora-ano (`catadm_it`)
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
 
# Agregacao de tipo de organizacao academica (`tp_organicao_academica_harm`)
ces_ies <- ces_ies |>
  mutate(
    across(
      .cols = tp_organizacao_academica, 
      .fns = ~ if_else(.x == 5, 4, .x), .names = '{.col}_harm'
    )
  )

# Output
write_parquet(ces_ies, here('data/clean/ces_ies.parquet'))

## Mantenedoras ----------------------------------------------------------------

# Pre-processamento
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

# Ranking de mantenedoras por matriculas no ano
ces_mantenedoras <- ces_mantenedoras |>
  mutate(
    ranking = row_number(desc(qt_mat)), 
    fx_ranking = cut(ranking, breaks = c(seq(0, 20, 5), Inf), labels = FALSE),
    .by = ano
  )

# Output
write_parquet(ces_mantenedoras, here('data/clean/ces_mantenedoras.parquet'))

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

# Output
write_xlsx(
  diag.tp_categoria_administrativa, 
  here("results/tp_categoria_administrativa.xlsx")
)

# INDICADORES DE TRAJETORIA ====================================================

## Pre-processamento -----------------------------------------------------------

# Lista de arquivos brutos
traj <- list.files(
  path = here("data/raw/INEP-TRAJETORIA/"), 
  pattern = "\\.xlsx$",  
  full.names =  TRUE
)

# Importacao dos arquivos brutos
traj <- map(traj, ~ read_xlsx(.x, skip = 8)) |> bind_rows()

# Selecao e padronizacao de variaveis
# - A base de trajetorias possui somente uma linha por curso-coorte-ano; 
#   portanto, so da para manter as variaveis que sao constantes por curso-ano,
#   o que exclui as variaveis geograficas.
traj <- traj |>
  select(CO_CURSO, NO_CURSO, NU_ANO_INGRESSO:last_col()) |> 
  rename_with(tolower, .cols = everything()) |>
  rename(coorte = nu_ano_ingresso, ano = nu_ano_referencia) |>
  mutate(
    across(where(is.character), padroniza_chr),
    across(where(is.numeric), as_integer_if_possible)
  ) |>
  filter(!is.na(co_curso)) 

# Merge com dados do CES
# - A base de trajetoria reconstroi retrospectivamente as caracteristicas 
#   cadastrais usando as informacoes do ultimo ano da analise; portanto, a 
#   harmonizacao puxa os dados contemporaneos do CES, que nao estao disponiveis
#   para todos os cursos da base de trajetorias.
traj <- ces_cursos |> 
  select(
    co_ies, co_curso, co_cine_area_geral, no_cine_area_geral, tp_grau_academico, 
    tp_modalidade_ensino, ano
  ) |>
  distinct() |> 
  right_join(traj, by = join_by(co_curso, ano), relationship = "one-to-many") |>
  mutate(
    presente_ces = !is.na(co_ies),
    n_presente_ces = sum(presente_ces),
    n_ausente_ces = sum(!presente_ces),
    pct_presente_ces = mean(presente_ces), 
    .by = c(co_curso, coorte)
  ) |> 
  arrange(coorte, co_curso, ano)

## Diagnostico de missing values -----------------------------------------------

diag.missing_traj <- list()

# Variaveis com missing values
diag.missing_traj$variaveis_com_missing <- traj |> 
  summarise(
    across(
      .cols = everything(),
      .fns =  list(n = ~ sum(is.na(.x)), pct = ~ 100 *mean(is.na(.x))),
      .names = "{.fn}_{.col}"
    ) 
  ) |>
  pivot_longer(
    cols = everything(),
    names_to = c("estatistica", ".value"),
    names_pattern = "^(n|pct)_(.*)$"
  )

# Linhas com missing values
diag.missing_traj$linhas_com_missing <- left_join(
  traj |> filter(!presente_ces) |> count(co_curso, ano, name = "n_linhas_traj"),
  ces_cursos |>
    summarise(primeiro_ces = min(ano), ultimo_ces = max(ano), .by = co_curso),
  by = join_by(co_curso),
  relationship = "many-to-one"
) |>
  mutate(
    situacao = case_when(
      is.na(primeiro_ces) ~ "4. Curso inteiramente ausente do CES",
      ano < primeiro_ces ~ "1. Antes da primeira aparicao do curso no CES",
      ano > ultimo_ces ~ "3. Depois da ultima aparicao no CES",
      .default = "2. Entre duas aparicoes no CES"
    ),
    situacao = factor(situacao)
  )

# Cursos podem aparecer em mais de uma situacao; calcula o total distinto antes
totais_missing_traj <- diag.missing_traj$linhas_com_missing |>
  summarise(
    num_linhas_traj = sum(n_linhas_traj),
    num_pares_curso_ano = n(),
    num_cursos = n_distinct(co_curso)
  ) |>
  mutate(situacao = "Total", .before = 1)

diag.missing_traj$linhas_com_missing <- diag.missing_traj$linhas_com_missing |>
  summarise(
    num_linhas_traj = sum(n_linhas_traj),
    num_pares_curso_ano = n(),
    num_cursos = n_distinct(co_curso),
    .by = situacao
  ) |>
  mutate(
    situacao = as.character(situacao)
  ) |>
  bind_rows(totais_missing_traj) |>
  arrange(situacao) |>
  mutate(
    pct_linhas_traj = 100 * num_linhas_traj / max(totais_missing_traj$num_linhas_traj, 1),
    pct_pares_curso_ano = 100 * num_pares_curso_ano / max(totais_missing_traj$num_pares_curso_ano, 1),
    pct_cursos = 100 * num_cursos / max(totais_missing_traj$num_cursos, 1)
  ) |>
  mutate(across(matches("^pct"), ~ round(.x, 2)))

# Valores unicos em linhas e variaveis com missing values
diag.missing_traj$valores_validos_unicos <- traj |>
  select(where(~ any(is.na(.x)))) |>
  names() |>
  setdiff("co_curso") |>
  map_dfr(function(variavel_atual) {
    traj |>
      summarise(
        num_valores_validos_unicos = n_distinct(
          .data[[variavel_atual]], na.rm = TRUE
        ),
        num_linhas_com_na = sum(is.na(.data[[variavel_atual]])),
        .by = co_curso
      ) |>
      filter(num_linhas_com_na > 0) |>
      summarise(
        num_cursos = n(),
        num_linhas_com_na = sum(num_linhas_com_na),
        .by = num_valores_validos_unicos
      ) |>
      mutate(variavel = variavel_atual, .before = 1)
  }) |>
  bind_rows(
    tibble(
      variavel = character(),
      num_valores_validos_unicos = integer(),
      num_cursos = integer(),
      num_linhas_com_na = integer()
    )
  ) |>
  arrange(variavel, num_valores_validos_unicos)

# Output
write_xlsx(diag.missing_traj, here("results/trajetorias_pre_imputacao.xlsx"))

## Imputacao de missing values nos dados de trajetoria -------------------------

# O preenchimento e' uma convencao de continuidade, nao uma confirmacao historica.

# Inicializa lista vazia
imputacao.traj <- list()

# Variaveis para imputar
imputacao.traj$vars <- c(
  "tp_modalidade_ensino", "co_cine_area_geral", "no_cine_area_geral",
  "tp_grau_academico", "co_ies"
)

# Cadastro no CES por curso-ano dos cursos que aparecem em trajetorias
imputacao.traj$dados <- ces_cursos |>
  semi_join(traj |> distinct(co_curso), by = join_by(co_curso)) |>
  select(co_curso, ano, all_of(imputacao.traj$vars)) |>
  distinct()

# Interrompe se houver cadastros divergentes para a mesma chave curso-ano
stopifnot(!anyDuplicated(imputacao.traj$dados[c("co_curso", "ano")]))

# Inclui os anos de trajetorias ausentes do CEs
imputacao.traj$dados <- full_join(
  imputacao.traj$dados,
  traj |> distinct(co_curso, ano),
  by = join_by(co_curso, ano), 
  relationship = "one-to-one"
) 

# Imputa missing values nas variaveis cadastrais
# - preenche lacunas iniciais com a primeira observacao valida para curso-ano;
# - preenche demais lacunas com a ultima observacao valida para curso-ano
# - aplica a mesma convencao ao grau academico, inclusive quando o NA no CES
#   indica nao aplicabilidade em registros ABI.
imputacao.traj$dados <- imputacao.traj$dados |>
  arrange(co_curso, ano) |>
  group_by(co_curso) |>
  fill(all_of(imputacao.traj$vars), .direction = "downup") |>
  ungroup()

# Merge com dados de trajetorias
traj <- left_join(
  traj,
  imputacao.traj$dados,
  by = join_by(co_curso, ano), 
  relationship = "many-to-one",
  suffix = c("", "_imputacao")
) 

# Incorpora valores imputados e cria marcas de imputacao
traj <- reduce(
  .x = imputacao.traj$vars,
  .init = traj,
  .f = function(df, var) {
    ref <- df[[paste0(var, "_imputacao")]]
    df[[paste0(var, "_imputado")]] <- is.na(df[[var]]) & !is.na(ref)
    df[[var]] <- coalesce(df[[var]], ref)
    df[[paste0(var, "_imputacao")]] <- NULL
    df
  }
)

# Marcacao de IES ativas a cada ano
# IES identificada sem evidencia de atividade recebe FALSE; IES ausente, NA.
traj <- left_join(
  traj,
  ces_cursos |>
    filter(!is.na(co_ies), qt_mat > 0) |>
    distinct(co_ies, ano) |>
    mutate(co_ies_em_atividade = TRUE),
   by = join_by(co_ies, ano), 
   relationship = "many-to-one"
) |>
  mutate(
    co_ies_em_atividade = if_else(
      is.na(co_ies), NA, coalesce(co_ies_em_atividade, FALSE)
    )
  )

## Informacoes institucionais --------------------------------------------------

# Historico completo das IES presentes em trajetorias
imputacao.ies <- ces_ies |> 
  select(co_mantenedora_harm, co_ies, ano, catadm_it) |>
  semi_join(distinct(traj, co_ies), by = "co_ies")

stopifnot(!anyDuplicated(imputacao.ies[c("co_ies", "ano")]))

# Inclui os anos necessarios para as trajetorias
imputacao.ies <- full_join(
  imputacao.ies,
  traj |> distinct(co_ies, ano) |> filter(!is.na(co_ies)),
  by = join_by(co_ies, ano),
  relationship = "one-to-one"
) |>
  mutate(
    co_mantenedora_harm_imputado = is.na(co_mantenedora_harm),
    catadm_it_imputado = is.na(catadm_it)
  )  

# Preenche mantenedora pelo historico da IES
imputacao.ies <- imputacao.ies |>
  arrange(co_ies, ano) |>
  group_by(co_ies) |>
  fill(co_mantenedora_harm, .direction = "downup") |>
  ungroup()

# Categoria unica por mantenedora-ano, preservando todo o historico disponivel
imputacao.mantenedoras <- ces_mantenedoras |>
  select(co_mantenedora_harm, ano, catadm_it) |>
  semi_join(distinct(imputacao.ies, co_mantenedora_harm), by = "co_mantenedora_harm")

stopifnot(!anyDuplicated(imputacao.mantenedoras[c("co_mantenedora_harm", "ano")]))

imputacao.mantenedoras <- full_join(
  imputacao.mantenedoras,
  imputacao.ies |>
    distinct(co_mantenedora_harm, ano) |>
    filter(!is.na(co_mantenedora_harm)),
  by = join_by(co_mantenedora_harm, ano),
  relationship = "one-to-one"
) |>
  arrange(co_mantenedora_harm, ano) |>
  group_by(co_mantenedora_harm) |>
  fill(catadm_it, .direction = "downup") |>
  ungroup()

imputacao.ies <- imputacao.ies |>
  left_join(
    imputacao.mantenedoras |>
      rename(catadm_it_mantenedora = catadm_it),
    by = join_by(co_mantenedora_harm, ano),
    relationship = "many-to-one",
    na_matches = "never"
  )

# Interrompe se a referencia contrariar alguma categoria observada da IES
stopifnot(all(
  is.na(imputacao.ies$catadm_it) |
    (!is.na(imputacao.ies$catadm_it_mantenedora) &
       imputacao.ies$catadm_it == imputacao.ies$catadm_it_mantenedora)
))

imputacao.ies <- imputacao.ies |>
  mutate(
    catadm_it = coalesce(catadm_it, catadm_it_mantenedora),
    co_mantenedora_harm_imputado = co_mantenedora_harm_imputado & !is.na(co_mantenedora_harm),
    catadm_it_imputado = catadm_it_imputado & !is.na(catadm_it)
  ) |>
  select(-catadm_it_mantenedora)

# Incorpora as informacoes institucionais as trajetorias
traj <- left_join(
  traj,
  imputacao.ies,
  by = join_by(co_ies, ano),
  relationship = "many-to-one"
)

## Output ----------------------------------------------------------------------

write_parquet(traj, here("data/clean/trajetorias.parquet"))


# ROTULOS ======================================================================

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

rotulos_vars$tp_grau_academico <- data.frame(
  bloco_nome = "Grau acadêmico",
  grupo_code = c(1, 2, 3),
  grupo_nome = c("Bacharelado", "Licenciatura", "Tecnológico")
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

rotulos_vars$nu_prazo_integralizacao <- data.frame(
  bloco_nome = 'Prazo para integralização do curso',
  grupo_code = 3:6, 
  grupo_nome = sprintf('%s anos', 3:6)
)

rotulos_vars <- bind_rows(rotulos_vars, .id = 'bloco_var')

## Rotulos para combinacoes de variaveis ---------------------------------------

rotulos_combo <- list(
  c('catadm_it', 'co_cine_area_geral'),
  c('catadm_it', 'co_cine_area_geral', 'turno'),
  c('catadm_it', 'co_cine_area_geral', 'tp_modalidade_ensino'),
  c('catadm_it', 'fx_pct_ead'),
  c('catadm_it', 'fx_pct_ead', 'co_cine_area_geral'),
  c('catadm_it', 'fx_pct_ead', 'tp_modalidade_ensino'),
  c('catadm_it', 'fx_pct_ead', 'turno'), 
  c('catadm_it', 'fx_ranking'),
  c('catadm_it', 'fx_ranking', 'co_cine_area_geral'), 
  c('catadm_it', 'fx_ranking', 'tp_modalidade_ensino'),
  c('catadm_it', 'fx_ranking', 'turno'), 
  c('catadm_it', 'nu_prazo_integralizacao'),
  c('catadm_it', 'tp_grau_academico'),
  c('catadm_it', 'tp_modalidade_ensino'),
  c('catadm_it', 'tp_organizacao_academica_harm'),
  c('catadm_it', 'tp_organizacao_academica_harm', 'turno'), 
  c('catadm_it', 'tp_organizacao_academica_harm', 'tp_modalidade_ensino'),
  c('catadm_it', 'turno'),  
  c('co_cine_area_geral', 'tp_modalidade_ensino'),
  c('co_cine_area_geral', 'turno'), 
  c('fx_ranking', 'co_cine_area_geral'),
  c('fx_ranking', 'co_cine_area_geral', 'turno'),
  c('fx_ranking', 'co_cine_area_geral', 'tp_modalidade_ensino'),
  c('fx_ranking', 'fx_pct_ead'),
  c('fx_ranking', 'fx_pct_ead', 'co_cine_area_geral'),
  c('fx_ranking', 'fx_pct_ead', 'tp_modalidade_ensino'),
  c('fx_ranking', 'fx_pct_ead', 'turno'), 
  c('fx_ranking', 'tp_modalidade_ensino'),
  c('fx_ranking', 'tp_organizacao_academica_harm'),
  c('fx_ranking', 'tp_organizacao_academica_harm', 'turno'), 
  c('fx_ranking', 'tp_organizacao_academica_harm', 'tp_modalidade_ensino'),
  c('fx_ranking', 'turno')
)

rotulos_combo <- map(rotulos_combo, ~ combina_rotulos(.x, rotulos_vars)) |> bind_rows()

### Outputs --------------------------------------------------------------------

bind_rows(rotulos_vars, rotulos_combo) |> 
  arrange(bloco_var, grupo_code) |>
  write_csv(here('data/clean/rotulos_variaveis.csv'))

