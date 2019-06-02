#!/bin/csh

#--BEGIN-FILTERS--
set MainFile	= $1		# BookOfSyllabi-ES
set Compiler    = $2    	# pdflatex
set OutputFile  = "$3"

# ../Curricula.out/Peru/CS-ANR/cycle/2012-2/Plan2012/scripts/gen-book.sh  BookOfSyllabi-ES       	pdflatex "CS-ANR 2012-2 BookOfSyllabi (Plan2012) 1-10"

#--END-FILTERS--
set OutputInstDir=<OUTPUT_INST_DIR>
set current_dir = `pwd`

# # set semester = `grep -e "\Semester}" $InfoFile | cut -d"{" -f3 | cut -d\\ -f1`
# set InfoFile	= "<IN_INST_DIR>/institution-info.tex"

echo "<OUTPUT_SCRIPTS_DIR>/CompileTexFile.sh <AREA> <INST> $Compiler $MainFile $OutputFile"
<OUTPUT_SCRIPTS_DIR>/CompileTexFile.sh <AREA> <INST> $Compiler $MainFile "$OutputFile";

cd "<OUTPUT_HTML_DIR>";
echo "cd <OUTPUT_HTML_DIR>";
#echo "pdftk A=$MainFile.pdf cat A1-1 output $MainFile-P1.pdf";
#pdftk A=$MainFile.pdf cat A1-1 output $MainFile-P1.pdf;
#convert $MainFile-P1.pdf $MainFile-P1.png;
#rm $MainFile-P1.pdf;
echo "mutool convert -o $MainFile-P1.png $MainFile.pdf 1-1"
mutool convert -o $MainFile-P1.png $MainFile.pdf 1-1

cd $current_dir;
mkdir -p <OUTPUT_DIR>/pdfs/<AREA>-<INST>/Plan<PLAN>
echo cp <OUTPUT_TEX_DIR>/$MainFile.pdf <OUTPUT_DIR>/pdfs/<AREA>-<INST>/Plan<PLAN>/.
cp <OUTPUT_TEX_DIR>/$MainFile.pdf <OUTPUT_DIR>/pdfs/<AREA>-<INST>/Plan<PLAN>/.

