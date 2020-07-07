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
date > ../Curricula.out/log/Peru-CS-MINEDU-time.txt
#--BEGIN-FILTERS--
set institution=MINEDU
setenv CC_Institution MINEDU
set filter=MINEDU6
setenv CC_Filter MINEDU6
set version=final
setenv CC_Version final
set area=CS
setenv CC_Area CS
set CurriculaParam=CS-MINEDU
#--END-FILTERS--
set curriculamain=curricula-main
setenv CC_Main curricula-main
set current_dir = `pwd`

set Country=Peru
set InLogosDir=../Curricula.in/country/Peru/logos
set OutputDir=../Curricula.out
set OutputInstDir=../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021
set OutputTexDir=../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/tex
set OutputScriptsDir=../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts
set OutputHtmlDir=../Curricula.out/html/Peru/CS-MINEDU/Plan2021

rm *.ps *.pdf *.log *.dvi *.aux *.bcf *.xml *.bbl *.blg *.toc *.out *.xref *.lof *.log *.lot *.brf *~ *.tmp;
# ls IS*.tex | xargs -0 perl -pi -e 's/CATORCE/UNOCUATRO/g'

# sudo addgroup curricula
#sudo chown -R ecuadros:curricula ./Curricula

mkdir -p ../Curricula.out/log;
./scripts/process-curricula.pl CS-MINEDU ;
../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-eps-files.sh;
foreach lang ('ES' 'EN')
    ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-graph.sh small $lang;
end

if($pdf == 1) then
      # latex -interaction=nonstopmode curricula-main
      ./scripts/clean.sh;
      latex curricula-main;

      mkdir -p ../Curricula.out/log;
      ./scripts/compbib.sh curricula-main > ../Curricula.out/log/Peru-CS-MINEDU-errors-bib.txt;

      latex curricula-main;
      latex curricula-main;

      echo CS-MINEDU;
      dvips curricula-main.dvi -o CS-MINEDU.ps;
      echo CS-MINEDU;
      ps2pdf CS-MINEDU.ps CS-MINEDU.pdf;
      rm -rf CS-MINEDU.ps;
      mutool convert -o ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/CurriculaMain-P%d.png CS-MINEDU.pdf 1-1;
      cp CS-MINEDU.pdf ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/CurriculaMain.pdf;
      mkdir -p "../Curricula.out/pdfs/CS-MINEDU/Plan2021";
      mv CS-MINEDU.pdf "../Curricula.out/pdfs/CS-MINEDU/Plan2021/CS-MINEDU Plan2021.pdf";
endif

./scripts/update-outcome-itemizes.pl CS-MINEDU
./scripts/update-page-numbers.pl CS-MINEDU;
mkdir -p ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/figs;

if($html == 1) then
    rm unified-curricula-main* ;
    ./scripts/gen-html-main.pl CS-MINEDU;
    cp ../Curricula.in/css/curricula-main.css unified-curricula-main.css;

    latex unified-curricula-main;
    bibtex unified-curricula-main;
    latex unified-curricula-main;
    latex unified-curricula-main;

    dvips -o unified-curricula-main.ps unified-curricula-main.dvi;
    ps2pdf unified-curricula-main.ps unified-curricula-main.pdf;
    rm unified-curricula-main.ps unified-curricula-main.dvi;

    rm -rf ../Curricula.out/html/Peru/CS-MINEDU/Plan2021;
    latex2html -t "Curricula CS-MINEDU" \
    -dir "../Curricula.out/html/Peru/CS-MINEDU/Plan2021/" -mkdir \
    -toc_stars -local_icons -no_footnode -show_section_numbers -long_title 5 \
    -address "Generado por <A HREF='http://socios.spc.org.pe/ecuadros/'>Ernesto Cuadros-Vargas</A> <ecuadros AT spc.org.pe>,               <A HREF='http://www.spc.org.pe/'>Sociedad Peruana de Computaci&oacute;n-Peru</A>,               basado en el modelo de la Computing Curricula de               <A HREF='http://www.computer.org/'>IEEE-CS</A>/<A HREF='http://www.acm.org/'>ACM</A>" \
    -white unified-curricula-main;
    cp "../Curricula.out/html/Peru/CS-MINEDU/Plan2021/Curricula_CS_MINEDU.html" "../Curricula.out/html/Peru/CS-MINEDU/Plan2021/index.html";
    sed 's/max-width:50em; //g' ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/unified-curricula-main.css > ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/unified-curricula-main.css1;
    mv ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/unified-curricula-main.css1 ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/unified-curricula-main.css;

    ./scripts/update-analytic-info.pl CS-MINEDU;
    cp ../Curricula.in/lang/Espanol/figs/pdf.jpeg ../Curricula.in/lang/Espanol/figs/star.gif ../Curricula.in/lang/Espanol/figs/none.gif ../Curricula.in/lang/Espanol/figs/*.png ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/figs/.;
    cp ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/figs/*.png ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/figs/.
    cp ../Curricula.in/country/Peru/logos/MINEDU.jpg ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/figs/.;
    
    ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-map-for-course.sh;
    cp ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/figs/*.svg ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/figs/.
    ./scripts/post-processing.pl CS-MINEDU;
    
    ./scripts/update-analytic-info.pl CS-MINEDU;
endif

mkdir -p ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/figs;
foreach lang ('ES' 'EN')
    ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-graph.sh big $lang;
end

foreach lang ('ES' 'EN')
    ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/compile-simple-latex.sh small-graph-curricula-$lang CS-MINEDU-small-graph-curricula ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/tex;
    ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-poster.sh $lang;
end

../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-syllabi.sh all;
mkdir -p ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/syllabi;
cp ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/syllabi/* ../Curricula.out/html/Peru/CS-MINEDU/Plan2021/syllabi/.;

../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfSyllabi-ES  	 pdflatex "CS-MINEDU 2021-I BookOfSyllabi-ES (Plan2021) 1-10";
../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfSyllabi-EN  	 pdflatex "CS-MINEDU 2021-I BookOfSyllabi-EN (Plan2021) 1-10";
../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfBibliography-ES  pdflatex "CS-MINEDU 2021-I BookOfBibliography-ES (Plan2021) 1-10";
../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfBibliography-EN  pdflatex "CS-MINEDU 2021-I BookOfBibliography-EN (Plan2021) 1-10";
../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfDescriptions-ES  pdflatex "CS-MINEDU 2021-I BookOfDescriptions-ES (Plan2021) 1-10";
../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfDescriptions-EN  pdflatex "CS-MINEDU 2021-I BookOfDescriptions-EN (Plan2021) 1-10";

#       ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfUnitsByCourse 	latex    "CS-MINEDU 2021-I BookOfUnitsByCourse (Plan2021) 1-10";
#       ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  BookOfDeliveryControl  pdflatex "CS-MINEDU 2021-I BookOfDeliveryControl (Plan2021) 1-10";

# Generate Books
#
# foreach auxbook (../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/tex/BookOf*-*.tex)
#    set book = `echo $auxbook | sed s/.tex//`
#    $book = `echo $book | sed s|../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/tex/||`
#    echo $book
#    #bibtex $auxfile
#    ../Curricula.out/Peru/CS-MINEDU/cycle/2021-I/Plan2021/scripts/gen-book.sh  $book       	pdflatex "CS-MINEDU 2021-I $book (Plan2021) 1-10";
# end

date >> ../Curricula.out/log/Peru-CS-MINEDU-time.txt;
more ../Curricula.out/log/Peru-CS-MINEDU-time.txt;
#./scripts/testenv.pl
beep;
beep;
