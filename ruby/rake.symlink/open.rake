task :md do
  system %[gvim *.md 2>/dev/null]
end

task :pdf do
  system %[xdg-open *.pdf 2>/dev/null]
end
