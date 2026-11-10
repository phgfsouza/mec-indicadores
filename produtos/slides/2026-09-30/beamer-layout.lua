-- Aplica as aberturas de secao sem misturar o estilo ao conteudo do QMD.
local function latex(inlines)
  return pandoc.write(pandoc.Pandoc({pandoc.Plain(inlines)}), "latex")
end

function Pandoc(doc)
  if FORMAT ~= "beamer" then return doc end
  local blocks = pandoc.List()
  local i = 1
  while i <= #doc.blocks do
    local block = doc.blocks[i]
    if block.t == "Header" and block.classes:includes("section-slide") then
      local description = doc.blocks[i + 1]
      assert(description and description.t == "Para", "A secao precisa de uma descricao.")
      blocks:insert(pandoc.Header(2, {}, pandoc.Attr(block.identifier, {"plain"})))
      blocks:insert(pandoc.RawBlock("latex",
        "\\AberturaSecao{" .. latex(block.content) .. "}{" .. latex(description.content) .. "}"))
      i = i + 1
    elseif block.t == "Header" and block.classes:includes("chart-slide") then
      block.content = {pandoc.RawInline("latex", "\\TituloGrafico{" .. latex(block.content) .. "}")}
      blocks:insert(block)
    else
      blocks:insert(block)
    end
    i = i + 1
  end
  doc.blocks = blocks
  return doc
end
