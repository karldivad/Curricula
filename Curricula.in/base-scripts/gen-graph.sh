#!/bin/csh

set figsize     = $1    # small or big
set lang        = $2

set current_dir = `pwd`
set file=$figsize-graph-curricula-$lang

echo "Generating <OUTPUT_FIG_DIR>/$file.ps file ..."
# -Gcharset=latin1
dot -Tps <OUTPUT_DOT_DIR>/$file.dot -o <OUTPUT_FIG_DIR>/$file.ps
echo "Generating <OUTPUT_FIG_DIR>/$file.png file ..."
dot -Tpng <OUTPUT_DOT_DIR>/$file.dot -o <OUTPUT_FIG_DIR>/$file.png

# convert <OUTPUT_FIG_DIR>/$file.ps <OUTPUT_FIG_DIR>/$file.png
# ps2eps <OUTPUT_FIG_DIR>/<AREA>-$figsize-graph-curricula.ps
# ps file looks fine on <AREA>-institution.pdf but eps does not ! misplaced !
# rm fig/<AREA>-<INST>-$figsize-grafo-curricula.ps
echo "gen-graph OK! (<OUTPUT_FIG_DIR>/$file.[ps,png])"
