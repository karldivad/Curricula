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
./scripts/process-curricula.pl CS-UTEC
latex curricula-main
latex curricula-main;
bibtex curricula-main1
./scripts/compbib.sh curricula-main
      
../Curricula.out/Peru/CS-UTEC/cycle/2017-II/Plan2017/scripts/gen-syllabi.sh all;
../Curricula.out/Peru/CS-UTEC/cycle/2017-II/Plan2017/scripts/gen-syllabi.sh all;

./scripts/process-curricula.pl CS-UTEC
dot -Tps ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/dot/CS2102.dot -o ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/fig/CS2102.ps; 
convert ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/fig/CS2102.ps ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/fig/CS2102.png


cp ../Curricula.in/lang/Espanol/cycle/2017-I/Syllabi/Computing/CS/CS1D1.bib ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/tex
./scripts/gen-syllabus.sh CS1D1-EN ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017
./scripts/gen-syllabus.sh CS1D1-ES ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017

find . -name "*.bib" -type f -exec iconv -f iso-8859-15 -t utf-8 "{}" -o ./"{}" \;
find . -name "*.tex" -type f -exec iconv -f iso-8859-15 -t utf-8 "{}" -o ./"{}" \;


./scripts/process-curricula.pl CS-UTEC
../Curricula.out/Peru/CS-UTEC/cycle/2017-II/Plan2017/scripts/gen-syllabi.sh GH1013
../Curricula.out/Peru/CS-UTEC/cycle/2017-II/Plan2017/scripts/gen-book.sh  BookOfSyllabi-ES  	pdflatex "CS-UTEC 2017-II BookOfSyllabi-ES (Plan2017) 1-10";
../Curricula.out/Peru/CS-UTEC/cycle/2017-II/Plan2017/scripts/gen-book.sh  BookOfSyllabi-EN  	pdflatex "CS-UTEC 2017-II BookOfSyllabi-EN (Plan2017) 1-10";

rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp
rm unified-curricula-main* ;
./scripts/gen-html-main.pl CS-UTEC
latex unified-curricula-main
