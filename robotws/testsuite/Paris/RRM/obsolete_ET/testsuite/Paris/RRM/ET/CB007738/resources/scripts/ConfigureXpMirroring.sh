sed -i -e s/"BACKHAUL_MIRRORING='false'"/"BACKHAUL_MIRRORING='true'"/g /ffs/run/config/scripts/gnbMirroringConfig.sh
sed -i -e s/"MIRROR_ABIL_1='true'"/"MIRROR_ABIL_1='false'"/g /ffs/run/config/scripts/gnbMirroringConfig.sh
sed -i -e s/"SYSCOM_MIRRORING='true'"/"SYSCOM_MIRRORING='false'"/g /ffs/run/config/scripts/gnbMirroringConfig.sh
