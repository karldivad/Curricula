#!/bin/csh

set country     = $1
set discipline  = $2
set language    = $3
set area        = $4
set institution = $5

set countryBase    = Peru
set disciplineBase = Computing
set languageBase   = Espanol
set areaBase       = CS
set institutionBase= UTEC

mkdir -p ../Curricula.in/country/$country/$discipline/$area/$institution
cp ../Curricula.in/country/$countryBase/$disciplineBase/$areaBase/$institution/institution-info.tex ../Curricula.in/country/$country/$discipline/$area/$institution/.
mkdir -p ../Curricula.in/lang/$language/$area.config/
cp ../Curricula.in/lang/$languageBase/$areaBase.config/All.config               ../Curricula.in/lang/$language/$area.config/All.config
cp ../Curricula.in/lang/$languageBase/$areaBase.config/Area.config              ../Curricula.in/lang/$language/$area.config/.
cp ../Curricula.in/institution/$countryBase/$institutionBase/institution.config ../Curricula.in/institution/$country/$institution/.
