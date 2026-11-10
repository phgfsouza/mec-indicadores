# Diagnóstico e plano de imputação das características anuais dos cursos

Relatório salvo em 17 de outubro de 2026, com base no diagnóstico apresentado nesta conversa. Escopo: linhas 388–440 de `code/01-preparacao.R` e planejamento do uso de `code/helpers/imputa_valores.R`.

**O merge até a linha 440 está correto para incorporar as características anuais do CES.** Reproduzi a integração em memória: ela mantém as **2.731.155 linhas válidas** de Trajetórias, sem duplicar a chave curso–coorte–ano. Também confirmei que o CES processado coincide com os dados brutos após os filtros atuais, para as colunas utilizadas.

Há um ajuste no diagnóstico: são **186.769 linhas sem correspondência no CES**, com ausência simultânea nas seis características. O grau acadêmico tem **186.785 ausências**, porque outras **16 linhas encontram cadastro no CES, mas esse cadastro não informa o grau**.

**A maior parte das ausências ocorre depois do último cadastro do curso.**

Classifiquei cada ausência usando todo o histórico disponível do CES, de 2010 a 2024:

| Situação | Linhas de Trajetórias | Pares curso–ano distintos | % das linhas sem CES |
|---|---:|---:|---:|
| Antes da primeira aparição do curso no CES | 6.536 | 4.942 | 3,50% |
| Entre duas aparições no CES | 12.004 | 3.542 | 6,43% |
| Depois da última aparição no CES | 168.229 | 66.581 | 90,07% |
| Curso inteiramente ausente do CES | **0** | **0** | **0%** |
| **Total** | **186.769** | **75.065** | **100%** |

Essas ausências atingem **18.361 cursos**. Tampouco existe curso–coorte inteiramente sem correspondência: todos têm pelo menos um ano observado no CES.

Portanto, o problema predominante não é encontrar atributos de cursos nunca cadastrados. É decidir como representar suas características quando a trajetória continua sendo publicada depois que o cadastro deixa de aparecer.

Nesse grupo final, encontrei um resultado especialmente importante:

- Nas **168.229 linhas**, a permanência e as conclusões são sempre **zero**.
- Há **5.290 linhas com desistências positivas**.
- O último CES anterior à ausência informa as seis características em todos os casos.
- **Nas seis características, esse último cadastro coincide integralmente com a referência retrospectiva de Trajetórias.**

Isso favorece uma regra específica para esse período. Não prova, por si, que o curso foi formalmente extinto ou que seus atributos administrativos permaneceram inalterados.

As lacunas finais demandadas pelas Trajetórias têm mediana de **quatro anos**, chegando a nove. Já existem muitas lacunas internas curtas, mas também alguns intervalos longos; não convém tratá-los todos com a mesma regra.

**Eu adotaria a seguinte sequência de trabalho.**

1. **Separar recuperação de informação, imputação e não aplicabilidade.**

   Há uma ausência de correspondência que pode ser explicada diretamente pelos filtros: o curso **1325257, em 2018**, existe no CES bruto, mas foi excluído por estar classificado como sequencial. Precisamos decidir se o cadastro destinado à recuperação de atributos históricos deve conservar esse registro, mantendo explícita sua classificação naquele ano. Isso seria recuperação de informação observada.

   As 16 ausências adicionais de grau correspondem a apenas **seis pares curso–ano, em quatro cursos**: Artes Plásticas, Matemática e dois cursos identificados como ABI no nome. Eu examinaria esses casos separadamente. Os registros ABI podem representar não aplicabilidade; não devem receber automaticamente o grau posterior.

   Também precisamos uniformizar os tipos antes das comparações: `co_cine_area_geral` é inteiro no CES e texto na referência de Trajetórias.

2. **Começar pela modalidade, com uma hipótese explícita de invariância por código de curso.**

   Todos os cursos envolvidos nos faltantes apresentam uma única modalidade no histórico observado do CES, e ela concorda com todas as suas referências em Trajetórias.

   Assim, **as 186.769 ausências de modalidade são candidatas ao preenchimento**, assumindo que o mesmo código de curso mantém sua modalidade nos anos não observados. É uma hipótese bem sustentada nestes arquivos, embora a ausência de mudanças observadas não seja uma demonstração de impossibilidade de mudança.

3. **Preencher lacunas internas curtas entre observações originais iguais.**

   Começaria por **um único ano sem cadastro**, com CES observado imediatamente antes e depois, exigindo igualdade dos limites para cada característica.

   Há **6.613 linhas de Trajetórias**, referentes a **1.484 pares curso–ano**, em que uma lacuna dessa duração tem limites iguais nas **seis características simultaneamente**. Regras por característica permitem recuperar um pouco mais.

   A hipótese é local e clara: não ocorreu uma mudança seguida de reversão justamente no ano ausente. Eu validaria essa regra ocultando anos conhecidos do CES antes de ampliar o limite para dois ou mais anos.

   Os limites devem vir de observações originais, evitando que uma imputação anterior passe a justificar outra.

4. **Adotar uma convenção específica depois do último CES, caso ela seja adequada à análise.**

   Para as **168.229 linhas finais sem permanência nem conclusões**, minha preferência seria carregar as características do **último cadastro observado**, mantendo sua origem e seu ano de referência identificados.

   Esse procedimento é determinístico quanto à informação utilizada. Sua interpretação seria: **“características do curso no último cadastro disponível”**. Se exigirmos que os campos representem estritamente a situação administrativa efetiva de cada ano posterior, os dados disponíveis não permitem eliminar essa incerteza.

   Essa distinção é importante porque as desistências continuam aparecendo em parte dessas linhas, e as taxas acumuladas também permanecem relevantes. Elas não devem ser descartadas por não haver permanência.

   A concordância integral com Trajetórias permite verificar a consistência dessa convenção, mas não deve ser contada como uma confirmação histórica independente do CES.

5. **Tratar as pontas iniciais e os casos restantes com maior cautela.**

   Nas **6.536 linhas anteriores ao primeiro CES**, todas apresentam permanência positiva. Aqui estamos classificando estudantes acompanhados antes de existir um cadastro anual observado do curso. Transportar atributos posteriores pode antecipar mudanças de IES, grau, nome ou classificação.

   Para ampliar o preenchimento, podemos selecionar cursos cujos valores sejam constantes em todo o CES observado e concordem com todas as referências de Trajetórias. Esse critério encontra os seguintes candidatos:

   | Característica | Linhas candidatas entre as 186.769 sem CES |
   |---|---:|
   | Modalidade | 186.769 |
   | Grau acadêmico | 186.357 |
   | Código e nome da área geral Cine | 186.710, em cada coluna |
   | IES | 183.188 |
   | Nome do curso | 176.678 |

   **Esses totais incluem casos dos passos anteriores e não são aditivos.** Indicam o alcance possível de uma hipótese adicional de estabilidade fora dos anos observados; não demonstram que todos esses preenchimentos seriam corretos. Eu avaliaria essa ampliação separadamente, sobretudo nas pontas iniciais.

**Há um cenário inicial de cobertura bastante alto, sem precisar começar pela regra mais abrangente.** A convenção de último cadastro nas linhas finais, combinada com as lacunas internas de um ano e seis limites iguais, abrangeria **174.842 das 186.769 linhas sem CES — 93,61%**. Restariam **11.927 linhas** fora desse preenchimento conjunto das seis características. A modalidade poderia ser preenchida também nesse restante, pela regra específica de invariância. As 16 ausências adicionais de grau continuariam sob análise própria.

Para operacionalizar esse plano, eu construiria primeiro uma tabela única por **curso–ano**, aplicaria as regras nela e depois a juntaria às coortes. Cada característica precisaria conservar sua origem: observada no CES, recuperada do bruto, imputada por invariância, interpolada ou herdada do último cadastro. Também registraria os anos utilizados como referência e os conflitos encontrados.

A `imputa_valores()` pode continuar sendo a ferramenta mecânica, mas eu **separaria seus dois mecanismos e controlaria explicitamente quais casos entram em cada um**. A aplicação atual, que tenta primeiro copiar de `_traj` e depois interpolar, mistura decisões que o diagnóstico mostra serem diferentes.

Uma regra determinística pode continuar tendo incerteza sobre o valor histórico verdadeiro. O plano permite tornar explícito onde há informação recuperada, onde há uma hipótese de continuidade e onde estamos adotando uma convenção para classificar o período posterior ao último cadastro.

O diagnóstico foi executado em memória, sem alterações no código ou nos dados do projeto.
