## PDF and SVG tools

This sandbox has poppler-utils (`pdftotext`, `pdftoppm`, `pdfinfo`,
`pdfimages`, ...) for reading PDFs and rendering their pages to images, and
`rsvg-convert` (librsvg) for rendering SVG to PNG or PDF. To look at a PDF
page, `pdftoppm -png -r 100 -f N -l N in.pdf page` and read the PNG.
