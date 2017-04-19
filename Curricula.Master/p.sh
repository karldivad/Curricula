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

./scripts/process-curricula.pl CS-UTEC
../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/gen-syllabi.sh all;
../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/scripts/gen-syllabi.sh all;

cp ../Curricula.in/lang/Espanol/cycle/2017-I/Syllabi/Computing/CS/CS1D1.bib ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017/tex
./scripts/gen-syllabus.sh CS1D1-EN ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017
./scripts/gen-syllabus.sh CS1D1-ES ../Curricula.out/Peru/CS-UTEC/cycle/2017-I/Plan2017

find . -name "*.bib" -type f -exec iconv -f iso-8859-15 -t utf-8 "{}" -o ./"{}" \;
find . -name "*.tex" -type f -exec iconv -f iso-8859-15 -t utf-8 "{}" -o ./"{}" \;