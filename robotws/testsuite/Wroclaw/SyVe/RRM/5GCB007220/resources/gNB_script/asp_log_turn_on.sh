#!/bin/sh

cd  /tmp/
mkdir -p var/preserve/

echo "level=DBG
L2.L2_PS.UL.APER_CSI=1
L2.L2_PS.DL.APER_CSI=1
" >> var/preserve/feature_log_activation.txt

tar czf trace.tgz var/preserve/feature_log_activation.txt

mkdir -p /ffs/run/swpool/L2RT/addons/
mv trace.tgz /ffs/run/swpool/L2RT/addons/
crasign /ffs/run/swpool/L2RT/addons/trace.tgz

ln /ffs/run/swpool/L2RT/addons/trace.tgz /ffs/run/boardcfg/1/A/mcu-aspd/addons/trace.tgz
ln /ffs/run/swpool/L2RT/addons/trace.tgz.p7 /ffs/run/boardcfg/1/A/mcu-aspd/addons/trace.tgz.p7

ln /ffs/run/swpool/L2RT/addons/trace.tgz /ffs/run/boardcfg/2/A/mcu-aspd/addons/trace.tgz
ln /ffs/run/swpool/L2RT/addons/trace.tgz.p7 /ffs/run/boardcfg/2/A/mcu-aspd/addons/trace.tgz.p7

ln /ffs/run/swpool/L2RT/addons/trace.tgz /ffs/run/boardcfg/3/A/mcu-aspd/addons/trace.tgz
ln /ffs/run/swpool/L2RT/addons/trace.tgz.p7 /ffs/run/boardcfg/3/A/mcu-aspd/addons/trace.tgz.p7

echo DONE
