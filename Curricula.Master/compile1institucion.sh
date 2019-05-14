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
date > ../Curricula.out/log/Peru-CS-UTEC-time.txt
#--BEGIN-FILTERS--
set institution=UTEC
setenv CC_Institution UTEC
set filter=UTEC
setenv CC_Filter UTEC
set version=final
setenv CC_Version final
set area=CS
setenv CC_Area CS
set CurriculaParam=CS-UTEC
#--END-FILTERS--
set curriculamain=curricula-main
setenv CC_Main curricula-main
set current_dir = `pwd`

set Country=Peru
set OutputDir=../Curricula.out
set OutputInstDir=../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018
set OutputTexDir=../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex
set OutputScriptsDir=../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts
set OutputHtmlDir=../Curricula.out/html/Peru/CS-UTEC/Plan2018

rm *.ps *.pdf *.log *.dvi *.aux *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp
# ls IS*.tex | xargs -0 perl -pi -e 's/CATORCE/UNOCUATRO/g'

# sudo addgroup curricula
#sudo chown -R ecuadros:curricula ./Curricula

mkdir -p ../Curricula.out/log
./scripts/process-curricula.pl CS-UTEC ;
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-eps-files.sh;
foreach lang ('ES' 'EN')
    ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-graph.sh small $lang
end

if($pdf == 1) then
      # latex -interaction=nonstopmode curricula-main
      ./scripts/clean.sh
      latex curricula-main;
      #bibtex curricula-main1;

      mkdir -p ../Curricula.out/log
      ./scripts/compbib.sh curricula-main > ../Curricula.out/log/Peru-CS-UTEC-errors-bib.txt;

      latex curricula-main;
      latex curricula-main;

      echo CS-UTEC;
      dvips curricula-main.dvi -o CS-UTEC.ps;
      echo CS-UTEC;
      ps2pdf CS-UTEC.ps CS-UTEC.pdf;

#     Generate the first page and place it at html dir
      pdftk A=CS-UTEC.pdf cat A1-1 output CS-UTEC-P1.pdf;
      convert CS-UTEC-P1.pdf CS-UTEC-P1.png;
      rm CS-UTEC-P1.pdf;
      mv CS-UTEC-P1.png ../Curricula.out/html/Peru/CS-UTEC/Plan2018/CurriculaMain-P1.png;
      cp CS-UTEC.pdf ../Curricula.out/html/Peru/CS-UTEC/Plan2018/CurriculaMain.pdf;

      mv CS-UTEC.pdf "../Curricula.out/pdfs/CS-UTEC Plan2018.pdf";
      rm -rf CS-UTEC.ps;
endif

./scripts/update-outcome-itemizes.pl CS-UTEC
./scripts/update-page-numbers.pl CS-UTEC;
foreach lang ('ES' 'EN')
    ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-graph.sh big $lang
end
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-map-for-course.sh

if($html == 1) then
      rm unified-curricula-main* ;
      ./scripts/gen-html-main.pl CS-UTEC;
      cp ../Curricula.in/css/curricula-main.css unified-curricula-main.css

      latex unified-curricula-main;
      bibtex unified-curricula-main;
      latex unified-curricula-main;
      latex unified-curricula-main;

      dvips -o unified-curricula-main.ps unified-curricula-main.dvi;
      ps2pdf unified-curricula-main.ps unified-curricula-main.pdf;
      rm unified-curricula-main.ps unified-curricula-main.dvi;

      rm -rf ../Curricula.out/html/Peru/CS-UTEC/Plan2018;
      mkdir -p ../Curricula.out/html/Peru/CS-UTEC/Plan2018/figs;
      cp ../Curricula.in/lang/Espanol/figs/pdf.jpeg ../Curricula.in/lang/Espanol/figs/star.gif ../Curricula.in/lang/Espanol/figs/none.gif ../Curricula.in/lang/Espanol/figs/*.png ../Curricula.out/html/Peru/CS-UTEC/Plan2018/figs/.;

      latex2html -t "Curricula CS-UTEC" \
      -dir "../Curricula.out/html/Peru/CS-UTEC/Plan2018/" -mkdir \
      -toc_stars -local_icons -no_footnode -show_section_numbers -long_title 5 \
      -address "Generado por <A HREF='http://socios.spc.org.pe/ecuadros/'>Ernesto Cuadros-Vargas</A> <ecuadros AT spc.org.pe>,               <A HREF='http://www.spc.org.pe/'>Sociedad Peruana de Computaci&oacute;n-Peru</A>,               <A HREF='http://www.utec.edu.pe/'>Universidad de Ingenier&iacute;a y Tecnolog&iacute;a, Lima-Per&uacute;</A><BR>              basado en el modelo de la Computing Curricula de               <A HREF='http://www.computer.org/'>IEEE-CS</A>/<A HREF='http://www.acm.org/'>ACM</A>" \
      -white unified-curricula-main;
      cp "../Curricula.out/html/Peru/CS-UTEC/Plan2018/Curricula_CS_UTEC.html" "../Curricula.out/html/Peru/CS-UTEC/Plan2018/index.html";
      #-split 3 -numbered_footnotes -images_only -timing -html_version latin1 -antialias -no_transparent \


      ./scripts/update-analytic-info.pl CS-UTEC
      ./scripts/gen-faculty-info.pl CS-UTEC
endif

../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/compile-simple-latex.sh small-graph-curricula CS-UTEC-small-graph-curricula ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex;

foreach lang ('ES' 'EN')
    ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/compile-simple-latex.sh Computing-poster-$lang CS-UTEC-poster-$lang ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex;
    pdftk A=../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/CS-UTEC-poster-$lang.pdf cat A1-1 output ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/CS-UTEC-poster-$lang-P1.pdf;
    convert ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/CS-UTEC-poster-$lang-P1.pdf ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/../html/CS-UTEC-poster-$lang.png;
    rm ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/CS-UTEC-poster-$lang-P1.pdf
    cp ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/CS-UTEC-poster-$lang.pdf ../Curricula.out/pdfs/CS-UTEC/Plan2018/.
    mv ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/CS-UTEC-poster-$lang.pdf ../Curricula.out/html/Peru/CS-UTEC/Plan2018/.
end

../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-syllabi.sh all;
mkdir -p ../Curricula.out/html/Peru/CS-UTEC/Plan2018/syllabi;
cp ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/syllabi/* ../Curricula.out/html/Peru/CS-UTEC/Plan2018/syllabi/.;

# Generate Books
#
# foreach auxbook (../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/BookOf*-*.tex)
#    set book = `echo $auxbook | sed s/.tex//`
#    $book = `echo $book | sed s|../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/tex/||`
#    echo $book
#    #bibtex $auxfile
#    ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  $book       	pdflatex "CS-UTEC 2019-I $book (Plan2018) 1-10";
# end

../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfSyllabi-ES  	 pdflatex "CS-UTEC 2019-I BookOfSyllabi-ES (Plan2018) 1-10";
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfSyllabi-EN  	 pdflatex "CS-UTEC 2019-I BookOfSyllabi-EN (Plan2018) 1-10";
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfBibliography-ES  pdflatex "CS-UTEC 2019-I BookOfBibliography-ES (Plan2018) 1-10";
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfBibliography-EN  pdflatex "CS-UTEC 2019-I BookOfBibliography-EN (Plan2018) 1-10";
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfDescriptions-ES  pdflatex "CS-UTEC 2019-I BookOfDescriptions-ES (Plan2018) 1-10";
../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfDescriptions-EN  pdflatex "CS-UTEC 2019-I BookOfDescriptions-EN (Plan2018) 1-10";

#       ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfUnitsByCourse 	latex    "CS-UTEC 2019-I BookOfUnitsByCourse (Plan2018) 1-10";
#       ../Curricula.out/Peru/CS-UTEC/cycle/2019-I/Plan2018/scripts/gen-book.sh  BookOfDeliveryControl  pdflatex "CS-UTEC 2019-I BookOfDeliveryControl (Plan2018) 1-10";


date >> ../Curricula.out/log/Peru-CS-UTEC-time.txt;
more ../Curricula.out/log/Peru-CS-UTEC-time.txt;
#./scripts/testenv.pl
beep;
beep;
