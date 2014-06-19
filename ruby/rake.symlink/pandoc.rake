MDFILES = FileList["*.md"]
PDFS = MDFILES.ext(".pdf")
DOCX = MDFILES.ext(".docx")
HTML = MDFILES.ext(".html")

desc "Use Pandoc to build PDFs of all Markdown documents"
multitask :pandoc => :pandoc_pdf

desc "Use Pandoc to build all formats of all Markdown documents"
multitask :pandoc_all => [:pandoc_pdf, :pandoc_docx, :pandoc_html]

desc "Use Pandoc to build PDFs of all Markdown documents"
multitask :pandoc_pdf => PDFS

desc "Use Pandoc to build DOCXs of all Markdown documents"
multitask :pandoc_docx => DOCX

desc "Use Pandoc to build HTML files of all Markdown documents"
multitask :pandoc_html => HTML

rule ".pdf" => ".md" do |t|
  sh "pandoc #{t.source} -o #{t.name}"
end

rule ".docx" => ".md" do |t|
  sh "pandoc #{t.source} -o #{t.name}"
end

rule ".html" => ".md" do |t|
  sh "pandoc -s -t html5 #{t.source} -o #{t.name}"
end

# Only clobber generated PDFs
require "rake/clean"
CLOBBER.include(PDFS)

