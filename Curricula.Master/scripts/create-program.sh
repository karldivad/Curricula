#!/bin/csh

set country     = $1
set discipline  = $2
set language    = $3
set area        = $4
set institution = $5

set countryBase     = Peru
set disciplineBase  = Computing
set languageBase    = Espanol
set areaBase        = CS
set institutionBase = UTEC

mkdir -p ../Curricula.in/country/$country/$discipline/$area/$institution
echo "cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/institution-info.tex ../Curricula.in/country/$country/$discipline/$area/$institution/institution-info.tex"
cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/institution-info.tex ../Curricula.in/country/$country/$discipline/$area/$institution/institution-info.tex

echo "cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/team.tex ../Curricula.in/country/$country/$discipline/$area/$institution/team.tex"
cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/team.tex ../Curricula.in/country/$country/$discipline/$area/$institution/team.tex

echo "cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/ack.tex  ../Curricula.in/country/$country/$discipline/$area/$institution/ack.tex"
cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/ack.tex  ../Curricula.in/country/$country/$discipline/$area/$institution/ack.tex

echo "cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/ack-general.tex  ../Curricula.in/country/$country/$discipline/$area/$institution/ack-general.tex"
cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/ack.tex-general  ../Curricula.in/country/$country/$discipline/$area/$institution/ack-general.tex

mkdir -p ../Curricula.in/lang/$language/$area.config/
echo "cp ../Curricula.in/lang/$languageBase/$areaBase.config/All.config         ../Curricula.in/lang/$language/$area.config/All.config"
cp ../Curricula.in/lang/$languageBase/$areaBase.config/All.config               ../Curricula.in/lang/$language/$area.config/All.config
echo "cp ../Curricula.in/lang/$languageBase/$areaBase.config/Area.config        ../Curricula.in/lang/$language/$area.config/Area.config"
cp ../Curricula.in/lang/$languageBase/$areaBase.config/Area.config              ../Curricula.in/lang/$language/$area.config/Area.config
mkdir -p ../Curricula.in/lang/$language/$area.sty/
cp ../Curricula.in/lang/$languageBase/$areaBase.sty/bok-macros-V0.sty           ../Curricula.in/lang/$language/$area.sty/bok-macros-V0.sty

mkdir -p ../Curricula.in/institution/$country/$institution
echo "cp ../Curricula.in/institution/$countryBase/$institutionBase/institution.config ../Curricula.in/institution/$country/$institution/institution.config"
cp ../Curricula.in/institution/$countryBase/$institutionBase/institution.config ../Curricula.in/institution/$country/$institution/institution.config

mkdir -p ../Curricula.in/lang/$language/$area.tex
echo "cp ../Curricula.in/lang/$languageBase/$areaBase.tex/outcomes-macros.tex         ../Curricula.in/lang/$language/$area.tex/outcomes-macros.tex"
cp ../Curricula.in/lang/$languageBase/$areaBase.tex/outcomes-macros.tex             ../Curricula.in/lang/$language/$area.tex/outcomes-macros.tex

echo "cp ../Curricula.in/lang/$languageBase/$areaBase.tex/description-foreach-prefix.tex  ../Curricula.in/lang/$language/$area.tex/description-foreach-prefix.tex"
cp ../Curricula.in/lang/$languageBase/$areaBase.tex/description-foreach-prefix.tex  ../Curricula.in/lang/$language/$area.tex/description-foreach-prefix.tex

echo "cp ../Curricula.in/lang/$languageBase/$areaBase.tex/other-packages.tex              ../Curricula.in/lang/$language/$area.tex/other-packages.tex"
cp ../Curricula.in/lang/$languageBase/$areaBase.tex/other-packages.tex              ../Curricula.in/lang/$language/$area.tex/other-packages.tex

echo "cp ../Curricula.in/lang/$languageBase/$areaBase.tex/copyright.tex                   ../Curricula.in/lang/$language/$area.tex/copyright.tex"
cp ../Curricula.in/lang/$languageBase/$areaBase.tex/copyright.tex                   ../Curricula.in/lang/$language/$area.tex/copyright.tex

echo "cp ../Curricula.in/lang/$languageBase/$areaBase.tex/abstract.tex            ../Curricula.in/lang/$language/$area.tex/abstract.tex"
cp ../Curricula.in/lang/$languageBase/$areaBase.tex/abstract.tex            ../Curricula.in/lang/$language/$area.tex/abstract.tex

echo "End !"