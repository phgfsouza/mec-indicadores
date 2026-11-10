import hashlib
import json
import pathlib
import xml.etree.ElementTree as ET
import zipfile


ROOT = pathlib.Path(__file__).resolve().parent


def conteudo(arquivo):
    with zipfile.ZipFile(arquivo) as z:
        partes = {}
        for nome in z.namelist():
            dados = z.read(nome)
            if nome.endswith(('.xml', '.rels')):
                raiz = ET.fromstring(dados)
                if nome == 'docProps/core.xml':
                    # Datas de criacao e modificacao mudam em qualquer regeneracao.
                    for filho in list(raiz):
                        if filho.tag in (
                            '{http://purl.org/dc/terms/}created',
                            '{http://purl.org/dc/terms/}modified',
                        ):
                            raiz.remove(filho)
                dados = ET.canonicalize(ET.tostring(raiz, encoding='unicode'))
            partes[nome] = dados
        return partes


def compara(a, b):
    primeiro, segundo = conteudo(a), conteudo(b)
    return [n for n in sorted(primeiro.keys() | segundo.keys())
            if primeiro.get(n) != segundo.get(n)]


manifesto = json.loads((ROOT / 'planilhas-originais.json').read_text(encoding='utf-8'))
resumo = []
for novo in sorted((ROOT / 'xlsx-novo').glob('*.xlsx')):
    nome = novo.name
    item = {
        'arquivo': nome,
        'diferencas_anterior_compactado': compara(ROOT / 'xlsx-anterior' / nome, novo),
        'diferencas_legado_compactado': compara(ROOT / 'xlsx-legado' / nome, novo),
    }
    atual = pathlib.Path('produtos/planilhas') / nome
    if atual.exists():
        item['diferencas_planilha_atual'] = compara(atual, novo)
        item['diferencas_preexistentes'] = compara(atual, ROOT / 'xlsx-anterior' / nome)
    resumo.append(item)

preservados = all(
    pathlib.Path(nome).stat().st_size == esperado['bytes']
    and hashlib.sha256(pathlib.Path(nome).read_bytes()).hexdigest() == esperado['sha256']
    for nome, esperado in manifesto.items()
)
resultado = {'planilhas_originais_preservadas': preservados, 'comparacoes': resumo}
(ROOT / 'comparacao-xlsx.json').write_text(
    json.dumps(resultado, ensure_ascii=False, indent=2), encoding='utf-8'
)
for item in resumo:
    print(item['arquivo'], json.dumps(item, ensure_ascii=False))
print('Planilhas originais preservadas:', preservados)
assert len(resumo) == 18, len(resumo)
assert preservados
assert all(not item['diferencas_anterior_compactado'] for item in resumo)
assert all(not item['diferencas_legado_compactado'] for item in resumo)
assert sum('diferencas_planilha_atual' in item for item in resumo) == 12
assert all(not item.get('diferencas_planilha_atual') for item in resumo)
print('Todas as comparacoes passaram.')
