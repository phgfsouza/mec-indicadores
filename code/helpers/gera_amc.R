#' Acrescenta areas minimas comparaveis com referencia territorial de 2010
#'
#' Preserva as linhas, a ordem e as colunas de `data`. Considera as cinco
#' emancipacoes de 2013 e Boa Esperanca do Norte. Nao corrige revisoes de
#' fronteira entre municipios que continuam existindo.
#'
#' Em desmembramentos 1:n, conserva a origem de 2010. Em unioes m:n, usa o
#' menor codigo das origens e concatena seus nomes, em ordem de codigo, com
#' ` + `. Micro e mesorregioes completas sao unidas quando necessario.
#'
#' @param data Data frame com uma coluna de codigos municipais.
#' @param cod_muni Nome, com ou sem aspas, da coluna de codigos em `data`.
#'   Aceita codigos IBGE de seis ou sete digitos, `NA` e zero.
#' @param dtb Caminho para o arquivo XLS da DTB 2010.
#'
#' @return `data` com codigos, nomes e siglas de regiao e UF sem sufixo; os de
#'   mesorregiao, microrregiao e municipio recebem `_amc`. O codigo municipal
#'   de saida tem sete digitos. `NA` e zero produzem doze valores ausentes e
#'   avisos com suas contagens. Codigos desconhecidos causam erro.
#'
#' @examples
#' gera_amc(cursos, co_municipio_curso, 'data/raw/IBGE-DTB/dtb_2010.xls')
#' gera_amc(cursos, 'co_municipio_curso', 'data/raw/IBGE-DTB/dtb_2010.xls')
gera_amc <- function(data, cod_muni, dtb) {
  if (!is.data.frame(data) || anyDuplicated(names(data)) > 0L) {
    stop('`data` deve ser um data frame com nomes de colunas unicos.',
         call. = FALSE)
  }
  if (missing(cod_muni) || missing(dtb)) {
    stop('Informe `cod_muni` e o caminho `dtb`.', call. = FALSE)
  }

  # Captura tanto o nome da coluna sem aspas quanto uma string literal.
  coluna <- substitute(cod_muni)
  if (is.symbol(coluna)) coluna <- as.character(coluna)
  if (!is.character(coluna) || length(coluna) != 1L ||
      is.na(coluna) || !coluna %in% names(data)) {
    stop('`cod_muni` deve identificar uma coluna existente em `data`.',
         call. = FALSE)
  }

  saidas <- c(
    'cod_regiao', 'nome_regiao', 'sigla_regiao',
    'cod_uf', 'nome_uf', 'sigla_uf',
    'cod_meso_amc', 'nome_meso_amc',
    'cod_micro_amc', 'nome_micro_amc',
    'cod_muni_amc', 'nome_muni_amc'
  )
  existentes <- intersect(saidas, names(data))
  if (length(existentes) > 0L) {
    stop('Colunas de saida ja existem: ', paste(existentes, collapse = ', '), '.',
         call. = FALSE)
  }
  if (!is.character(dtb) || length(dtb) != 1L || is.na(dtb) ||
      !grepl('\\.xls$', dtb, ignore.case = TRUE) || !file.exists(dtb)) {
    stop('`dtb` deve ser o caminho de um arquivo XLS existente.', call. = FALSE)
  }

  # Valida os formatos antes de converter para inteiro; assim codigos
  # incompletos ou com caracteres extras nao passam despercebidos.
  codigos <- data[[coluna]]
  if (is.factor(codigos)) codigos <- as.character(codigos)
  if (!is.null(dim(codigos))) {
    stop('`cod_muni` deve ser uma coluna vetorial de codigos.', call. = FALSE)
  }
  if (is.character(codigos)) {
    invalidos <- !is.na(codigos) &
      !grepl('^(0|[1-9][0-9]{5,6})$', codigos)
    zeros <- !is.na(codigos) & codigos == '0'
  } else if (is.numeric(codigos) && !is.object(codigos)) {
    invalidos <- is.nan(codigos) | is.infinite(codigos) |
      (!is.na(codigos) & (codigos != trunc(codigos) |
                            (codigos != 0 &
                               (codigos < 100000 | codigos > 9999999))))
    zeros <- !is.na(codigos) & codigos == 0
  } else if (is.logical(codigos) && all(is.na(codigos))) {
    invalidos <- rep(FALSE, length(codigos))
    zeros <- rep(FALSE, length(codigos))
  } else {
    stop('`cod_muni` deve conter codigos numericos ou textuais.', call. = FALSE)
  }
  if (any(invalidos)) {
    valores <- head(unique(codigos[invalidos]), 10L)
    stop('`cod_muni` deve conter codigos de seis ou sete digitos, zero ou NA. ',
         'Valores invalidos: ', paste(valores, collapse = ', '), '.',
         call. = FALSE)
  }
  faltantes <- is.na(codigos)
  if (any(faltantes)) {
    warning('H\u00e1 ', sum(faltantes), ' ',
            if (sum(faltantes) == 1L) 'linha' else 'linhas',
            ' com `cod_muni` == NA.',
            call. = FALSE)
  }
  if (any(zeros)) {
    warning('H\u00e1 ', sum(zeros), ' ',
            if (sum(zeros) == 1L) 'linha' else 'linhas',
            ' com `cod_muni` == 0.',
            call. = FALSE)
  }
  codigos <- as.integer(codigos)

  # A DTB e lida aqui; o cadastro nao depende de objetos do script principal.
  # Os nomes originais do XLS sao trocados por nomes internos mais curtos.
  referencia <- readxl::read_xls(dtb)
  campos <- c(
    uf = 'UF', nome_uf = 'Nome_UF',
    municipio = 'Munic\u00edpio', nome_munic = 'Nome_Munic',
    microrregiao = 'Microrregi\u00e3o', nome_micro = 'Nome_Micro',
    mesorregiao = 'Mesorregi\u00e3o', nome_meso = 'Nome_Meso'
  )
  ausentes <- setdiff(unname(campos), names(referencia))
  if (length(ausentes) > 0L) {
    stop('Colunas ausentes na DTB 2010: ', paste(ausentes, collapse = ', '), '.',
         call. = FALSE)
  }
  names(referencia)[match(unname(campos), names(referencia))] <- names(campos)
  ref <- data.frame(
    cod_uf = as.integer(referencia$uf),
    nome_uf = as.character(referencia$nome_uf),
    cod_muni = as.integer(referencia$municipio),
    nome_muni = as.character(referencia$nome_munic),
    cod_micro = as.integer(referencia$microrregiao),
    nome_micro = as.character(referencia$nome_micro),
    cod_meso = as.integer(referencia$mesorregiao),
    nome_meso = as.character(referencia$nome_meso)
  )
  if (anyNA(ref) || anyDuplicated(ref$cod_muni) > 0L ||
      any(ref$cod_muni %/% 100000L != ref$cod_uf) ||
      any(!(ref$cod_uf %/% 10L %in% 1:5))) {
    stop('A DTB 2010 deve ter municipios unicos e classificacoes validas.',
         call. = FALSE)
  }
  nomes_regiao <- c('Norte', 'Nordeste', 'Sudeste', 'Sul', 'Centro-Oeste')
  siglas_regiao <- c('N', 'NE', 'SE', 'S', 'CO')
  siglas_uf <- c(
    '11' = 'RO', '12' = 'AC', '13' = 'AM', '14' = 'RR',
    '15' = 'PA', '16' = 'AP', '17' = 'TO',
    '21' = 'MA', '22' = 'PI', '23' = 'CE', '24' = 'RN',
    '25' = 'PB', '26' = 'PE', '27' = 'AL', '28' = 'SE', '29' = 'BA',
    '31' = 'MG', '32' = 'ES', '33' = 'RJ', '35' = 'SP',
    '41' = 'PR', '42' = 'SC', '43' = 'RS',
    '50' = 'MS', '51' = 'MT', '52' = 'GO', '53' = 'DF'
  )
  # O primeiro algarismo do codigo da UF identifica a grande regiao.
  ref$cod_regiao <- ref$cod_uf %/% 10L
  ref$nome_regiao <- nomes_regiao[ref$cod_regiao]
  ref$sigla_regiao <- siglas_regiao[ref$cod_regiao]
  ref$sigla_uf <- unname(siglas_uf[as.character(ref$cod_uf)])
  if (anyNA(ref$sigla_uf)) {
    stop('A DTB 2010 contem codigos de UF sem sigla conhecida.',
         call. = FALSE)
  }

  # Origens dos seis municipios posteriores a referencia de 2010.
  emancipacoes <- list(
    '1504752' = 1506807L,
    '4212650' = 4209409L,
    '4220000' = 4207007L,
    '4314548' = 4302105L,
    '5006275' = c(5000203L, 5002951L, 5003256L),
    '5101837' = c(5106240L, 5106307L, 5107925L, 5108501L)
  )
  niveis <- c('muni', 'micro', 'meso')
  # Cada mapa liga uma unidade de 2010 ao codigo do grupo AMC a que pertence.
  # `chaves` guarda a unidade de origem de cada municipio em cada nivel.
  mapas <- setNames(lapply(niveis, function(nivel) {
    mapa <- unique(data.frame(
      codigo = ref[[paste0('cod_', nivel)]],
      nome = ref[[paste0('nome_', nivel)]]
    ))
    if (anyDuplicated(mapa$codigo) > 0L) {
      stop('A DTB 2010 tem nomes divergentes para o mesmo codigo de ',
           nivel, '.', call. = FALSE)
    }
    mapa$codigo_amc <- mapa$codigo
    mapa
  }), niveis)
  chaves <- data.frame(
    cod_muni = ref$cod_muni, muni = ref$cod_muni,
    micro = ref$cod_micro, meso = ref$cod_meso
  )

  for (novo_chr in names(emancipacoes)) {
    novo <- as.integer(novo_chr)
    linhas <- match(emancipacoes[[novo_chr]], ref$cod_muni)
    if (anyNA(linhas) || novo %in% ref$cod_muni) {
      stop('Vinculos territoriais invalidos para ', novo_chr, '.',
           call. = FALSE)
    }
    origem <- ref[linhas, , drop = FALSE]
    if (length(unique(origem$cod_uf)) != 1L ||
        novo %/% 100000L != origem$cod_uf[[1L]]) {
      stop('Vinculos territoriais invalidos para ', novo_chr, '.',
           call. = FALSE)
    }
    # Une grupos inteiros quando as origens estao em unidades diferentes.
    for (nivel in niveis) {
      mapa <- mapas[[nivel]]
      grupos <- mapa$codigo_amc[
        mapa$codigo %in% origem[[paste0('cod_', nivel)]]
      ]
      envolvidos <- mapa$codigo_amc %in% grupos
      mapa$codigo_amc[envolvidos] <- min(mapa$codigo[envolvidos])
      mapas[[nivel]] <- mapa
    }
    # O municipio novo herda as chaves de suas origens, ja agrupadas nos mapas.
    chaves <- rbind(chaves, data.frame(
      cod_muni = novo,
      muni = min(origem$cod_muni),
      micro = min(origem$cod_micro),
      meso = min(origem$cod_meso)
    ))
  }

  # Reconstroi os nomes completos de cada grupo e atribui os codigos AMC.
  cadastro <- chaves['cod_muni']
  for (nivel in niveis) {
    mapa <- mapas[[nivel]]
    mapa <- mapa[order(mapa$codigo), , drop = FALSE]
    nomes <- vapply(split(mapa$nome, mapa$codigo_amc),
                    paste, character(1), collapse = ' + ')
    indice <- match(chaves[[nivel]], mapa$codigo)
    cadastro[[paste0('cod_', nivel, '_amc')]] <- mapa$codigo_amc[indice]
    cadastro[[paste0('nome_', nivel, '_amc')]] <-
      unname(nomes[as.character(mapa$codigo_amc[indice])])
  }
  # UF e regiao nao se unem: os municipios novos herdam esses campos da origem.
  indice_ref <- match(chaves$cod_muni, ref$cod_muni)
  novos <- which(is.na(indice_ref))
  indice_ref[novos] <- match(chaves$muni[novos], ref$cod_muni)
  cadastro$cod_uf <- ref$cod_uf[indice_ref]
  cadastro$nome_uf <- ref$nome_uf[indice_ref]
  cadastro$sigla_uf <- ref$sigla_uf[indice_ref]
  cadastro$cod_regiao <- ref$cod_regiao[indice_ref]
  cadastro$nome_regiao <- ref$nome_regiao[indice_ref]
  cadastro$sigla_regiao <- ref$sigla_regiao[indice_ref]

  # Os seis primeiros digitos identificam o municipio sem o digito final.
  codigos_seis <- chaves$cod_muni %/% 10L
  if (anyDuplicated(codigos_seis) > 0L) {
    stop('A correspondencia entre codigos de seis e sete digitos nao e unica.',
         call. = FALSE)
  }
  # Converte apenas as entradas de seis digitos; as de sete ja estao completas.
  chaves_entrada <- codigos
  seis <- !is.na(codigos) & codigos >= 100000L & codigos <= 999999L
  chaves_entrada[seis] <- chaves$cod_muni[
    match(codigos[seis], codigos_seis)
  ]
  indice <- match(chaves_entrada, cadastro$cod_muni)
  desconhecidos <- unique(codigos[!faltantes & !zeros & is.na(indice)])
  if (length(desconhecidos) > 0L) {
    stop('Codigos municipais ausentes no cadastro: ',
         paste(head(desconhecidos, 10L), collapse = ', '), '.',
         call. = FALSE)
  }
  # A indexacao conserva a ordem, as repeticoes e as demais colunas de `data`.
  for (saida in saidas) {
    data[[saida]] <- cadastro[[saida]][indice]
  }
  data
}
