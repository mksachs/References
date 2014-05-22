#!/bin/tcsh
############################################################################

# Set location of files  ###################################################
set pdfpath = "Refs/"

if ( $1  == "" ) then
  set bibfile = "references.bib"
else
  set bibfile = $1
endif

# Create template file #####################################################
cat << EOF > tmp123.tex
\documentclass[11pt]{article}
\usepackage{fullpage}
\usepackage{times}
\usepackage[colorlinks=true,filecolor=blue]{hyperref}
\renewcommand\refname{${bibfile}:}
\begin{document}
\nocite*{}
\bibliographystyle{plain}
\bibliography{$bibfile}
\end{document}
EOF

# Have latex/bibtex create a bbl file ######################################
pdflatex tmp123
bibtex tmp123

# Edit the bbl file ########################################################
foreach i ( `grep bibitem tmp123.bbl | cut -f2 -d"{" | cut -f1 -d"}"` )
if ( `find $pdfpath -name "$i.*" | wc -l` ) then
    sed -i s%"bibitem{$i}"%"bibitem[\\href{${pdfpath}${i}.pdf}{$i}]{$i}"%g tmp123.bbl
  else
    sed -i s%"bibitem{$i}"%"bibitem[$i]{$i}"%g tmp123.bbl
  endif
end

# Adjust the width of the keys #############################################
sed -i s/"{thebibliography}{100}"/"{thebibliography}{MMMMMMMMMM}"/g tmp123.bbl

# Recompile with latex #####################################################
pdflatex tmp123
pdflatex tmp123

# Clean up and exit ########################################################
mv tmp123.pdf references.pdf
rm -rf tmp123.*
echo "\n\n\tCreated file 'references.pdf'\n\n\n"
