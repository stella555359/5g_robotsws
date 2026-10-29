#Script to Mirror Loner
#Copy script to ASIK /ffs/run/logs/ and chmod +x
#To run it go to ABIL Loner /ffs/run/logs/ and run it
#Author: OTAVA

#Get the line number where 8 or a is in the end
var=`fpga_rw ra 0xDF1D038C 32 | egrep -in '000(8|a)$'`
echo $var
first_char="${var:0:1}"
echo $first_char

#Base address plus the offset
offset=$((($first_char-1)*4))
echo $offset
dec_addr=$((3743220620+$offset))
echo $dec_addr

#convert address from dec to hex
MACADDR=`printf '%x\n' $dec_addr`
echo $MACADDR

# Read current value in register and or it with 0x00000008
registerValue=`fpga_rw ra $MACADDR`
echo $registerValue
modifiedRegisterValue="${registerValue::-1}""c"
echo $modifiedRegisterValue

#enable mirroring
echo "Write ${modifiedRegisterValue} to ${MACADDR} address"
fpga_rw wa $MACADDR $modifiedRegisterValue




