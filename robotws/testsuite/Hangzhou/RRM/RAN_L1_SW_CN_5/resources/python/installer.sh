BUILDNAME=$1
HWID=$(sed -e "s/ /_/g" /mnt/factory/configs/unit/hwid.txt)
STARTPOINT=$PWD
TARGETFLASH=/mnt/slot_running

echo "Updating build: $BUILDNAME"
echo "Using HWID: $HWID"
rm -rf master slave-extras
tar -xf $BUILDNAME
cd master/simics-mars/
mount -o remount,rw $TARGETFLASH/
xz -d *.xz
cp image-mars.itb sbl.bin $TARGETFLASH/
cp u-boot-dtb-$HWID.bin $TARGETFLASH/u-boot-mars.bin

cd $STARTPOINT
cd slave-extras/thor
xz -d *.xz
cp default-thor-ebf-config.dtb flash-cnf10kb.img image-thor.itb  $TARGETFLASH/
cd $HWID
xz -d *.xz
cp thor-ebf-config.dtb $TARGETFLASH/
sync
echo "DONE"
