#!/bin/csh
# ./scripts/process-bok.pl CS-UCSP

# ./scripts/gen-scripts.pl CS-UTEC
# ./scripts/process-curricula.pl CS-UTEC
# ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/gen-eps-files.sh;
# ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/gen-graph.sh small &
# ./scripts/update-outcome-itemizes.pl CS-UTEC &
# ./scripts/update-page-numbers.pl CS-UTEC;
# ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/gen-graph.sh big &
# ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/gen-map-for-course.sh &
# ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/compile-simple-latex.sh Computing-poster CS-UTEC-poster ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/tex;

# ./scripts/process-curricula.pl CS-UNSA
# ./scripts/update-outcome-itemizes.pl CS-UNSA &
# ./scripts/update-page-numbers.pl CS-UNSA;
# ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-graph.sh big &
# ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-map-for-course.sh &
# ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/compile-simple-latex.sh Computing-poster CS-UNSA-poster ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex;
# ./scripts/gen-scripts.pl CS-UTEC

rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp
#./scripts/gen-scripts.pl CS-UTEC

#find . -name "*.bib" -type f -exec iconv -f iso-8859-15 -t utf-8 "{}" -o ./"{}" \;
#find . -name "*.tex" -type f -exec iconv -f iso-8859-15 -t utf-8 "{}" -o ./"{}" \;

./scripts/process-curricula.pl CS-UTEC
../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/scripts/compile-simple-latex.sh small-graph-curricula CS-UTEC-small-graph-curricula ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex;
../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/scripts/compile-simple-latex.sh Computing-poster CS-UTEC-poster ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex;
pdftk A=../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/CS-UTEC-poster.pdf cat A1-1 output ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/CS-UTEC-poster-P1.pdf;
convert ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/CS-UTEC-poster-P1.pdf ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/../html/CS-UTEC-poster.png;
rm ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/CS-UTEC-poster-P1.pdf
cp ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/CS-UTEC-poster.pdf ../Curricula.out/pdfs/CS-UTEC/Plan2018/.
mv ../Curricula.out/Peru/CS-UTEC/cycle/2018-II/Plan2018/tex/CS-UTEC-poster.pdf ../Curricula.out/html/Peru/CS-UTEC/Plan2018/.
