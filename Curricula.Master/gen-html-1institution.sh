#!/bin/csh
# DEPRECATED !!!! it is already contained inside compile1institution.sh

date > out/time-CS-UTEC.txt
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
setenv CC_Main $curriculamain
set current_dir = `pwd`
set UnifiedMain=unified-curricula-main
#set UnifiedMain = `echo $FullUnifiedMainFile | sed s/.tex//`

set Country=Peru
set OutputTexDir=../Curricula.out/Peru/CS-UTEC/cycle/2020-0/Plan2018/tex
set OutputHtmlDir=../Curricula.out/html/Peru/CS-UTEC/Plan2018
set OutputScriptsDir=../Curricula.out/Peru/CS-UTEC/cycle/2020-0/Plan2018/scripts

./scripts/process-curricula.pl CS-UTEC
../Curricula.out/Peru/CS-UTEC/cycle/2020-0/Plan2018/scripts/gen-eps-files.sh CS UTEC Peru Espanol
./scripts/update-page-numbers.pl CS-UTEC 
./scripts/gen-graph.sh CS UTEC Peru Espanol big
rm unified-curricula-main* 
./scripts/gen-html-main.pl CS-UTEC

latex unified-curricula-main
bibtex unified-curricula-main
latex unified-curricula-main
latex unified-curricula-main

dvips -o unified-curricula-main.ps unified-curricula-main.dvi
ps2pdf unified-curricula-main.ps unified-curricula-main.pdf
rm unified-curricula-main.ps unified-curricula-main.dvi

rm -rf ../Curricula.out/html/Peru/CS-UTEC/Plan2018
mkdir -p ../Curricula.out/html/Peru/CS-UTEC/Plan2018
mkdir ../Curricula.out/html/Peru/CS-UTEC/Plan2018/figs
cp ./in/lang.Espanol/figs/pdf.jpeg cp ./in/lang.Espanol/figs/star.gif cp ./in/lang.Espanol/figs/none.gif ../Curricula.out/html/Peru/CS-UTEC/Plan2018/figs/.

latex2html \
-t "Curricula CS-UTEC" \
-dir "../Curricula.out/html/Peru/CS-UTEC/Plan2018/" -mkdir \
-toc_stars -local_icons -show_section_numbers \
-address "Generado por <A HREF='http://socios.spc.org.pe/ecuadros/'>Ernesto Cuadros-Vargas</A> <ecuadros AT spc.org.pe>,               <A HREF='http://www.spc.org.pe/'>Sociedad Peruana de Computaci&oacute;n-Peru</A>,               <A HREF='http://www.utec.edu.pe/'>Universidad de Ingenier&iacute;a y Tecnolog&iacute;a, Lima-Per&uacute;</A><BR>              basado en el modelo de la Computing Curricula de               <A HREF='http://www.computer.org/'>IEEE-CS</A>/<A HREF='http://www.acm.org/'>ACM</A>" \
unified-curricula-main
#-split 3 -numbered_footnotes -images_only -timing -html_version latin1 \

./scripts/update-analytic-info.pl CS-UTEC

#../Curricula.out/Peru/CS-UTEC/cycle/2020-0/Plan2018/tex/scripts/gen-syllabi.sh
mkdir ../Curricula.out/html/Peru/CS-UTEC/Plan2018/syllabi
cp ../Curricula.out/Peru/CS-UTEC/cycle/2020-0/Plan2018/tex/syllabi/* ../Curricula.out/html/Peru/CS-UTEC/Plan2018/syllabi/*

#Redundant withcompile1institution
# ./scripts/$area-$institution-gen-silabos

beep
beep

