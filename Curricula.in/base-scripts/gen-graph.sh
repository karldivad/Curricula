#!/bin/csh
set figsize     = $1    # small or big
set lang        = $2

set current_dir = `pwd`
set file=$figsize-graph-curricula-$lang

echo "Generating <OUTPUT_FIG_DIR>/$file.ps file ..."
dot -Tps <OUTPUT_DOT_DIR>/$file.dot -o <OUTPUT_FIG_DIR>/$file.ps
echo "Generating <OUTPUT_FIG_DIR>/$file.png file ..."
dot -Tsvg <OUTPUT_DOT_DIR>/$file.dot -o <OUTPUT_FIG_DIR>/$file.svg
echo "gen-graph OK! (<OUTPUT_FIG_DIR>/$file.[ps,svg])"
# -Gcharset=latin1