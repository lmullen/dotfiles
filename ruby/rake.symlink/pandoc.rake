MDFILES = FileList["*.md"]
PDFS = MDFILES.ext(".pdf")

desc "Use Pandoc to build PDFs of all Markdown documents"
task :pandoc => PDFS

rule ".pdf" => ".md" do |t|
  sh "pandoc #{t.source} -o #{t.name}"
end

# Only clobber generated PDFs
require "rake/clean"
CLOBBER.include(PDFS)

