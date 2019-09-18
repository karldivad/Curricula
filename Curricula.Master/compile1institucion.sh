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
date > ../Curricula.out/log/Peru-IS-UTEC-time.txt
#--BEGIN-FILTERS--
set institution=UTEC
setenv CC_Institution UTEC
set filter=SPC,UTEC
setenv CC_Filter SPC,UTEC
set version=final
setenv CC_Version final
set area=IS
setenv CC_Area IS
set CurriculaParam=IS-UTEC
#--END-FILTERS--
set curriculamain=curricula-main
setenv CC_Main curricula-main
set current_dir = `pwd`

set Country=Peru
set OutputDir=../Curricula.out
set OutputInstDir=../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020
set OutputTexDir=../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/tex
set OutputScriptsDir=../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts
set OutputHtmlDir=../Curricula.out/html/Peru/IS-UTEC/Plan2020

rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp
# ls IS*.tex | xargs -0 perl -pi -e 's/CATORCE/UNOCUATRO/g'

# sudo addgroup curricula
#sudo chown -R ecuadros:curricula ./Curricula

mkdir -p ../Curricula.out/log
./scripts/process-curricula.pl IS-UTEC ;
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-eps-files.sh;
foreach lang ('ES')
    ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-graph.sh small $lang
end

if($pdf == 1) then
      # latex -interaction=nonstopmode curricula-main
      ./scripts/clean.sh
      latex curricula-main;
      #bibtex curricula-main1;

      mkdir -p ../Curricula.out/log
      ./scripts/compbib.sh curricula-main > ../Curricula.out/log/Peru-IS-UTEC-errors-bib.txt;

      latex curricula-main;
      latex curricula-main;

      echo IS-UTEC;
      dvips curricula-main.dvi -o IS-UTEC.ps;
      echo IS-UTEC;
      ps2pdf IS-UTEC.ps IS-UTEC.pdf;
      rm -rf IS-UTEC.ps;

#     Generate the first page and place it at html dir
      mutool convert -o ../Curricula.out/html/Peru/IS-UTEC/Plan2020/CurriculaMain-P1.png IS-UTEC.pdf 1-1
      #pdftk A=IS-UTEC.pdf cat A1-1 output IS-UTEC-P1.pdf;
      #convert IS-UTEC-P1.pdf IS-UTEC-P1.png;
      #rm IS-UTEC-P1.pdf;
      #mv IS-UTEC-P1.png ../Curricula.out/html/Peru/IS-UTEC/Plan2020/CurriculaMain-P1.png;
      cp IS-UTEC.pdf ../Curricula.out/html/Peru/IS-UTEC/Plan2020/CurriculaMain.pdf;
      mkdir -p "../Curricula.out/pdfs/IS-UTEC/Plan2020"
      mv IS-UTEC.pdf "../Curricula.out/pdfs/IS-UTEC/Plan2020/IS-UTEC Plan2020.pdf";
endif

./scripts/update-outcome-itemizes.pl IS-UTEC
./scripts/update-page-numbers.pl IS-UTEC;
foreach lang ('ES')
    ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-graph.sh big $lang
end
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-map-for-course.sh

if($html == 1) then
      rm unified-curricula-main* ;
      ./scripts/gen-html-main.pl IS-UTEC;
      cp ../Curricula.in/css/curricula-main.css unified-curricula-main.css

      latex unified-curricula-main;
      bibtex unified-curricula-main;
      latex unified-curricula-main;
      latex unified-curricula-main;

      dvips -o unified-curricula-main.ps unified-curricula-main.dvi;
      ps2pdf unified-curricula-main.ps unified-curricula-main.pdf;
      rm unified-curricula-main.ps unified-curricula-main.dvi;

      rm -rf ../Curricula.out/html/Peru/IS-UTEC/Plan2020;
      mkdir -p ../Curricula.out/html/Peru/IS-UTEC/Plan2020/figs;
      cp ../Curricula.in/lang/Espanol/figs/pdf.jpeg ../Curricula.in/lang/Espanol/figs/star.gif ../Curricula.in/lang/Espanol/figs/none.gif ../Curricula.in/lang/Espanol/figs/*.png ../Curricula.out/html/Peru/IS-UTEC/Plan2020/figs/.;

      latex2html -t "Curricula IS-UTEC" \
      -dir "../Curricula.out/html/Peru/IS-UTEC/Plan2020/" -mkdir \
      -toc_stars -local_icons -no_footnode -show_section_numbers -long_title 5 \
      -address "Generado por <A HREF='http://socios.spc.org.pe/ecuadros/'>Ernesto Cuadros-Vargas</A> <ecuadros AT spc.org.pe>,               <A HREF='http://www.spc.org.pe/'>Sociedad Peruana de Computaci&oacute;n-Peru</A>,               <A HREF='http://www.utec.edu.pe/'>Universidad de Ingenier&iacute;a y Tecnolog&iacute;a, Lima-Per&uacute;</A><BR>              basado en el modelo de la Computing Curricula de               <A HREF='http://www.computer.org/'>IEEE-CS</A>/<A HREF='http://www.acm.org/'>ACM</A>" \
      -white unified-curricula-main;
      cp "../Curricula.out/html/Peru/IS-UTEC/Plan2020/Curricula_IS_UTEC.html" "../Curricula.out/html/Peru/IS-UTEC/Plan2020/index.html";
      #-split 3 -numbered_footnotes -images_only -timing -html_version latin1 -antialias -no_transparent \


      ./scripts/update-analytic-info.pl IS-UTEC
      ./scripts/gen-faculty-info.pl IS-UTEC
endif

../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/compile-simple-latex.sh small-graph-curricula IS-UTEC-small-graph-curricula ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/tex;

foreach lang ('ES')
    ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-poster.sh $lang
end

../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-syllabi.sh all;
mkdir -p ../Curricula.out/html/Peru/IS-UTEC/Plan2020/syllabi;
cp ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/syllabi/* ../Curricula.out/html/Peru/IS-UTEC/Plan2020/syllabi/.;

# Generate Books
#
# foreach auxbook (../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/tex/BookOf*-*.tex)
#    set book = `echo $auxbook | sed s/.tex//`
#    $book = `echo $book | sed s|../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/tex/||`
#    echo $book
#    #bibtex $auxfile
#    ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  $book       	pdflatex "IS-UTEC 2020-I $book (Plan2020) 1-10";
# end

../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfSyllabi-ES  	 pdflatex "IS-UTEC 2020-I BookOfSyllabi-ES (Plan2020) 1-10";
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfSyllabi-EN  	 pdflatex "IS-UTEC 2020-I BookOfSyllabi-EN (Plan2020) 1-10";
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfBibliography-ES  pdflatex "IS-UTEC 2020-I BookOfBibliography-ES (Plan2020) 1-10";
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfBibliography-EN  pdflatex "IS-UTEC 2020-I BookOfBibliography-EN (Plan2020) 1-10";
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfDescriptions-ES  pdflatex "IS-UTEC 2020-I BookOfDescriptions-ES (Plan2020) 1-10";
../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfDescriptions-EN  pdflatex "IS-UTEC 2020-I BookOfDescriptions-EN (Plan2020) 1-10";

#       ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfUnitsByCourse 	latex    "IS-UTEC 2020-I BookOfUnitsByCourse (Plan2020) 1-10";
#       ../Curricula.out/Peru/IS-UTEC/cycle/2020-I/Plan2020/scripts/gen-book.sh  BookOfDeliveryControl  pdflatex "IS-UTEC 2020-I BookOfDeliveryControl (Plan2020) 1-10";


date >> ../Curricula.out/log/Peru-IS-UTEC-time.txt;
more ../Curricula.out/log/Peru-IS-UTEC-time.txt;
#./scripts/testenv.pl
beep;
beep;
