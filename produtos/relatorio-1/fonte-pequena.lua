function Div(elemento)
  if FORMAT:match("latex")
      and elemento.attributes["custom-style"] == "FontePequena" then
    return {
      pandoc.RawBlock("latex", "\\begin{FontePequena}"),
      elemento,
      pandoc.RawBlock("latex", "\\end{FontePequena}")
    }
  end
end
