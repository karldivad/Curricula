#!/bin/csh
set lang=$1

<OUTPUT_SCRIPTS_DIR>/compile-simple-latex.sh <DISCIPLINE>-poster-$lang <AREA>-<INST>-poster-$lang <OUTPUT_TEX_DIR>;
echo "mutool convert -o <OUTPUT_TEX_DIR>/../html/<AREA>-<INST>-poster-$lang-P%d.png <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang.pdf 1-1"
mutool convert -o <OUTPUT_TEX_DIR>/../html/<AREA>-<INST>-poster-$lang-P%d.png <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang.pdf 1-1
mv "<OUTPUT_TEX_DIR>/../html/<AREA>-<INST>-poster-$lang-P1.png" "<OUTPUT_TEX_DIR>/../html/<AREA>-<INST>-poster-$lang-P1.png"

#pdftk A=<OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang.pdf cat A1-1 output <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang-P1.pdf;
#convert <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang-P1.pdf <OUTPUT_TEX_DIR>/../html/<AREA>-<INST>-poster-$lang.png;
#rm <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang-P1.pdf
mkdir -p <OUTPUT_DIR>/pdfs/<AREA>-<INST>/<PLAN>/.
cp <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang.pdf <OUTPUT_DIR>/pdfs/<AREA>-<INST>/<PLAN>/.
mv <OUTPUT_TEX_DIR>/<AREA>-<INST>-poster-$lang.pdf <OUTPUT_HTML_DOCS_DIR>/.
