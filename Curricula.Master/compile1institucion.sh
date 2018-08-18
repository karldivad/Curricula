#!/bin/csh
set pdfparam=$1
set htmlparam=$2
set pdf=0
set html=0

if($pdfparam == "y" || $pdfparam == "Y" || $pdfparam == "yes" || $pdfparam == "Yes" || $pdfparam == "YES") then
    set pdf=1
else if($pdfparam == "n" || $pdfparam == "N" || $pdfparam == "no" || $pdfparam == "No" || $pdfparam == "NO") then
    set pdf=0
else
    echo "Error in pdf param"
    exit
endif

if($htmlparam == "y" || $htmlparam == "Y" || $htmlparam == "yes" || $htmlparam == "Yes" || $htmlparam == "YES") then
    set html=1
else if($htmlparam == "n" || $htmlparam == "N" || $htmlparam == "no" || $htmlparam == "No" || $htmlparam == "NO") then
    set html=0
else
    echo "Error in html param"
    exit
endif
echo "pdf=$pdf, html=$html"

set LogDir=../Curricula.out/log
date > ../Curricula.out/log/Peru-CS-UNSA-time.txt
#--BEGIN-FILTERS--
set institution=UNSA
setenv CC_Institution UNSA
set filter=UNSA
setenv CC_Filter UNSA
set version=final
setenv CC_Version final
set area=CS
setenv CC_Area CS
set CurriculaParam=CS-UNSA
#--END-FILTERS--
set curriculamain=curricula-main
setenv CC_Main curricula-main
set current_dir = `pwd`

set Country=Peru
set OutputDir=../Curricula.out
set OutputInstDir=../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017
set OutputTexDir=../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex
set OutputScriptsDir=../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts
set OutputHtmlDir=../Curricula.out/html/Peru/CS-UNSA/Plan2017

rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp
# ls IS*.tex | xargs -0 perl -pi -e 's/CATORCE/UNOCUATRO/g'

# sudo addgroup curricula
#sudo chown -R ecuadros:curricula ./Curricula

mkdir -p ../Curricula.out/log
./scripts/process-curricula.pl CS-UNSA ;
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-eps-files.sh;
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-graph.sh small

if($pdf == 1) then
      # latex -interaction=nonstopmode curricula-main
      ./scripts/clean.sh
      latex curricula-main;
      #bibtex curricula-main1;

      mkdir -p ../Curricula.out/log
      ./scripts/compbib.sh curricula-main > ../Curricula.out/log/Peru-CS-UNSA-errors-bib.txt;

      latex curricula-main;
      latex curricula-main;

      echo CS-UNSA;
      dvips curricula-main.dvi -o CS-UNSA.ps;
      echo CS-UNSA;
      ps2pdf CS-UNSA.ps CS-UNSA.pdf;

#     Generate the first page and place it at html dir
      pdftk A=CS-UNSA.pdf cat A1-1 output CS-UNSA-P1.pdf;
      convert CS-UNSA-P1.pdf CS-UNSA-P1.png;
      rm CS-UNSA-P1.pdf;
      mv CS-UNSA-P1.png ../Curricula.out/html/Peru/CS-UNSA/Plan2017/CurriculaMain-P1.png;
      cp CS-UNSA.pdf ../Curricula.out/html/Peru/CS-UNSA/Plan2017/CurriculaMain.pdf;

      mv CS-UNSA.pdf "../Curricula.out/pdfs/CS-UNSA Plan2017.pdf";
      rm -rf CS-UNSA.ps;
endif

./scripts/update-outcome-itemizes.pl CS-UNSA
./scripts/update-page-numbers.pl CS-UNSA;
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-graph.sh big
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-map-for-course.sh

if($html == 1) then
      rm unified-curricula-main* ;
      ./scripts/gen-html-main.pl CS-UNSA;
      cp ../Curricula.in/css/curricula-main.css unified-curricula-main.css

      latex unified-curricula-main;
      bibtex unified-curricula-main;
      latex unified-curricula-main;
      latex unified-curricula-main;

      dvips -o unified-curricula-main.ps unified-curricula-main.dvi;
      ps2pdf unified-curricula-main.ps unified-curricula-main.pdf;
      rm unified-curricula-main.ps unified-curricula-main.dvi;

      rm -rf ../Curricula.out/html/Peru/CS-UNSA/Plan2017;
      mkdir -p ../Curricula.out/html/Peru/CS-UNSA/Plan2017/figs;
      cp ../Curricula.in/lang/Espanol/figs/pdf.jpeg ../Curricula.in/lang/Espanol/figs/star.gif ../Curricula.in/lang/Espanol/figs/none.gif ../Curricula.in/lang/Espanol/figs/*.png ../Curricula.out/html/Peru/CS-UNSA/Plan2017/figs/.;

      latex2html -t "Curricula CS-UNSA" \
      -dir "../Curricula.out/html/Peru/CS-UNSA/Plan2017/" -mkdir \
      -toc_stars -local_icons -no_footnode -show_section_numbers -long_title 5 \
      -address "Generado por <A HREF='http://socios.spc.org.pe/ecuadros/'>Ernesto Cuadros-Vargas</A> <ecuadros AT spc.org.pe>,               <A HREF='http://www.spc.org.pe/'>Sociedad Peruana de Computaci&oacute;n-Peru</A>,               <A HREF='http://www.utec.edu.pe/'>Universidad de Ingenier&iacute;a y Tecnolog&iacute;a, Lima-Per&uacute;</A><BR>              basado en el modelo de la Computing Curricula de               <A HREF='http://www.computer.org/'>IEEE-CS</A>/<A HREF='http://www.acm.org/'>ACM</A>" \
      -white unified-curricula-main;
      cp "../Curricula.out/html/Peru/CS-UNSA/Plan2017/Curricula_CS_UNSA.html" "../Curricula.out/html/Peru/CS-UNSA/Plan2017/index.html";
      #-split 3 -numbered_footnotes -images_only -timing -html_version latin1 -antialias -no_transparent \


      ./scripts/update-analytic-info.pl CS-UNSA
      ./scripts/gen-faculty-info.pl CS-UNSA
endif

../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/compile-simple-latex.sh small-graph-curricula CS-UNSA-small-graph-curricula ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex;
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/compile-simple-latex.sh Computing-poster CS-UNSA-poster ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex;
pdftk A=../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/CS-UNSA-poster.pdf cat A1-1 output ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/CS-UNSA-poster-P1.pdf;
convert ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/CS-UNSA-poster-P1.pdf ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/../html/CS-UNSA-poster.png;
rm ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/CS-UNSA-poster-P1.pdf
cp ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/CS-UNSA-poster.pdf ../Curricula.out/pdfs/CS-UNSA/Plan2017/.
mv ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/CS-UNSA-poster.pdf ../Curricula.out/html/Peru/CS-UNSA/Plan2017/.

../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-syllabi.sh all;
mkdir -p ../Curricula.out/html/Peru/CS-UNSA/Plan2017/syllabi;
cp ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/syllabi/* ../Curricula.out/html/Peru/CS-UNSA/Plan2017/syllabi/.;

# Generate Books
#
# foreach auxbook (../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/BookOf*-*.tex)
#    set book = `echo $auxbook | sed s/.tex//`
#    $book = `echo $book | sed s|../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/tex/||`
#    echo $book
#    #bibtex $auxfile
#    ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  $book       	pdflatex "CS-UNSA 2017-I $book (Plan2017) 1-10";
# end

../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfSyllabi-ES  	 pdflatex "CS-UNSA 2017-I BookOfSyllabi-ES (Plan2017) 1-10";
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfSyllabi-EN  	 pdflatex "CS-UNSA 2017-I BookOfSyllabi-EN (Plan2017) 1-10";
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfBibliography-ES  pdflatex "CS-UNSA 2017-I BookOfBibliography-ES (Plan2017) 1-10";
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfBibliography-EN  pdflatex "CS-UNSA 2017-I BookOfBibliography-EN (Plan2017) 1-10";
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfDescriptions-ES  pdflatex "CS-UNSA 2017-I BookOfDescriptions-ES (Plan2017) 1-10";
../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfDescriptions-EN  pdflatex "CS-UNSA 2017-I BookOfDescriptions-EN (Plan2017) 1-10";

#       ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfUnitsByCourse 	latex    "CS-UNSA 2017-I BookOfUnitsByCourse (Plan2017) 1-10";
#       ../Curricula.out/Peru/CS-UNSA/cycle/2017-I/Plan2017/scripts/gen-book.sh  BookOfDeliveryControl  pdflatex "CS-UNSA 2017-I BookOfDeliveryControl (Plan2017) 1-10";


date >> ../Curricula.out/log/Peru-CS-UNSA-time.txt;
more ../Curricula.out/log/Peru-CS-UNSA-time.txt;
#./scripts/testenv.pl
beep;
beep;
