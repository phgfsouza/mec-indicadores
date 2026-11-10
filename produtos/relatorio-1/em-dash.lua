function Str(elemento)
  elemento.text = elemento.text:gsub("%-%-", "—")
  return elemento
end
