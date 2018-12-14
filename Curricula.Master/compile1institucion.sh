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
date > ../Curricula.out/log/Peru-CS-UNMSM-time.txt
#--BEGIN-FILTERS--
set institution=UNMSM
setenv CC_Institution UNMSM
set filter=UNMSM,UNSA,SPC
setenv CC_Filter UNMSM,UNSA,SPC
set version=final
setenv CC_Version final
set area=CS
setenv CC_Area CS
set CurriculaParam=CS-UNMSM
#--END-FILTERS--
set curriculamain=curricula-main
setenv CC_Main curricula-main
set current_dir = `pwd`

set Country=Peru
set OutputDir=../Curricula.out
set OutputInstDir=../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014
set OutputTexDir=../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex
set OutputScriptsDir=../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts
set OutputHtmlDir=../Curricula.out/html/Peru/CS-UNMSM/Plan2014

rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp
# ls IS*.tex | xargs -0 perl -pi -e 's/CATORCE/UNOCUATRO/g'

# sudo addgroup curricula
#sudo chown -R ecuadros:curricula ./Curricula

mkdir -p ../Curricula.out/log
./scripts/process-curricula.pl CS-UNMSM ;
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-eps-files.sh;
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-graph.sh small

if($pdf == 1) then
      # latex -interaction=nonstopmode curricula-main
      ./scripts/clean.sh
      latex curricula-main;
      #bibtex curricula-main1;

      mkdir -p ../Curricula.out/log
      ./scripts/compbib.sh curricula-main > ../Curricula.out/log/Peru-CS-UNMSM-errors-bib.txt;

      latex curricula-main;
      latex curricula-main;

      echo CS-UNMSM;
      dvips curricula-main.dvi -o CS-UNMSM.ps;
      echo CS-UNMSM;
      ps2pdf CS-UNMSM.ps CS-UNMSM.pdf;

#     Generate the first page and place it at html dir
      pdftk A=CS-UNMSM.pdf cat A1-1 output CS-UNMSM-P1.pdf;
      convert CS-UNMSM-P1.pdf CS-UNMSM-P1.png;
      rm CS-UNMSM-P1.pdf;
      mv CS-UNMSM-P1.png ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/CurriculaMain-P1.png;
      cp CS-UNMSM.pdf ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/CurriculaMain.pdf;

      mv CS-UNMSM.pdf "../Curricula.out/pdfs/CS-UNMSM Plan2014.pdf";
      rm -rf CS-UNMSM.ps;
endif

./scripts/update-outcome-itemizes.pl CS-UNMSM
./scripts/update-page-numbers.pl CS-UNMSM;
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-graph.sh big
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-map-for-course.sh

if($html == 1) then
      rm unified-curricula-main* ;
      ./scripts/gen-html-main.pl CS-UNMSM;
      cp ../Curricula.in/css/curricula-main.css unified-curricula-main.css

      latex unified-curricula-main;
      bibtex unified-curricula-main;
      latex unified-curricula-main;
      latex unified-curricula-main;

      dvips -o unified-curricula-main.ps unified-curricula-main.dvi;
      ps2pdf unified-curricula-main.ps unified-curricula-main.pdf;
      rm unified-curricula-main.ps unified-curricula-main.dvi;

      rm -rf ../Curricula.out/html/Peru/CS-UNMSM/Plan2014;
      mkdir -p ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/figs;
      cp ../Curricula.in/lang/Espanol/figs/pdf.jpeg ../Curricula.in/lang/Espanol/figs/star.gif ../Curricula.in/lang/Espanol/figs/none.gif ../Curricula.in/lang/Espanol/figs/*.png ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/figs/.;

      latex2html -t "Curricula CS-UNMSM" \
      -dir "../Curricula.out/html/Peru/CS-UNMSM/Plan2014/" -mkdir \
      -toc_stars -local_icons -no_footnode -show_section_numbers -long_title 5 \
      -address "Generado por <A HREF='http://socios.spc.org.pe/ecuadros/'>Ernesto Cuadros-Vargas</A> <ecuadros AT spc.org.pe>,               <A HREF='http://www.spc.org.pe/'>Sociedad Peruana de Computaci&oacute;n-Peru</A>,               <A HREF='http://www.utec.edu.pe/'>Universidad de Ingenier&iacute;a y Tecnolog&iacute;a, Lima-Per&uacute;</A><BR>              basado en el modelo de la Computing Curricula de               <A HREF='http://www.computer.org/'>IEEE-CS</A>/<A HREF='http://www.acm.org/'>ACM</A>" \
      -white unified-curricula-main;
      cp "../Curricula.out/html/Peru/CS-UNMSM/Plan2014/Curricula_CS_UNMSM.html" "../Curricula.out/html/Peru/CS-UNMSM/Plan2014/index.html";
      #-split 3 -numbered_footnotes -images_only -timing -html_version latin1 -antialias -no_transparent \


      ./scripts/update-analytic-info.pl CS-UNMSM
      ./scripts/gen-faculty-info.pl CS-UNMSM
endif

../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/compile-simple-latex.sh small-graph-curricula CS-UNMSM-small-graph-curricula ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex;
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/compile-simple-latex.sh Computing-poster CS-UNMSM-poster ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex;
pdftk A=../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/CS-UNMSM-poster.pdf cat A1-1 output ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/CS-UNMSM-poster-P1.pdf;
convert ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/CS-UNMSM-poster-P1.pdf ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/../html/CS-UNMSM-poster.png;
rm ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/CS-UNMSM-poster-P1.pdf
cp ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/CS-UNMSM-poster.pdf ../Curricula.out/pdfs/CS-UNMSM/Plan2014/.
mv ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/CS-UNMSM-poster.pdf ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/.

../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-syllabi.sh all;
mkdir -p ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/syllabi;
cp ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/syllabi/* ../Curricula.out/html/Peru/CS-UNMSM/Plan2014/syllabi/.;

# Generate Books
#
# foreach auxbook (../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/BookOf*-*.tex)
#    set book = `echo $auxbook | sed s/.tex//`
#    $book = `echo $book | sed s|../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/tex/||`
#    echo $book
#    #bibtex $auxfile
#    ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  $book       	pdflatex "CS-UNMSM 2014-1 $book (Plan2014) 1-10";
# end

../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfSyllabi-ES  	 pdflatex "CS-UNMSM 2014-1 BookOfSyllabi-ES (Plan2014) 1-10";
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfSyllabi-EN  	 pdflatex "CS-UNMSM 2014-1 BookOfSyllabi-EN (Plan2014) 1-10";
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfBibliography-ES  pdflatex "CS-UNMSM 2014-1 BookOfBibliography-ES (Plan2014) 1-10";
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfBibliography-EN  pdflatex "CS-UNMSM 2014-1 BookOfBibliography-EN (Plan2014) 1-10";
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfDescriptions-ES  pdflatex "CS-UNMSM 2014-1 BookOfDescriptions-ES (Plan2014) 1-10";
../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfDescriptions-EN  pdflatex "CS-UNMSM 2014-1 BookOfDescriptions-EN (Plan2014) 1-10";

#       ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfUnitsByCourse 	latex    "CS-UNMSM 2014-1 BookOfUnitsByCourse (Plan2014) 1-10";
#       ../Curricula.out/Peru/CS-UNMSM/cycle/2014-1/Plan2014/scripts/gen-book.sh  BookOfDeliveryControl  pdflatex "CS-UNMSM 2014-1 BookOfDeliveryControl (Plan2014) 1-10";


date >> ../Curricula.out/log/Peru-CS-UNMSM-time.txt;
more ../Curricula.out/log/Peru-CS-UNMSM-time.txt;
#./scripts/testenv.pl
beep;
beep;
