while true
do
DL_T1=`cat /sys/class/net/eth3/statistics/tx_bytes`
UL_R1=`cat /sys/class/net/eth3/statistics/rx_bytes`
DL_R1=`cat /sys/class/net/eth4/statistics/rx_bytes`
UL_T1=`cat /sys/class/net/eth4/statistics/tx_bytes`
sleep 60

#Downlink transmitted
DL_T2=`cat /sys/class/net/eth3/statistics/tx_bytes`
DL_TBPS=`expr $DL_T2 - $DL_T1`
DL_TKBPS=`expr $DL_TBPS / 60000`
DL_TXBPS=$(expr $DL_TKBPS \* 8)

#Downlink received
DL_R2=`cat /sys/class/net/eth4/statistics/rx_bytes`
DL_RBPS=`expr $DL_R2 - $DL_R1`
DL_RKBPS=`expr $DL_RBPS / 60000`
DL_RXBPS=$(expr $DL_RKBPS \* 8)

#Uplink transmitted
UL_T2=`cat /sys/class/net/eth4/statistics/tx_bytes`
UL_TBPS=`expr $UL_T2 - $UL_T1`
UL_TKBPS=`expr $UL_TBPS / 60000`
UL_TXBPS=$(expr $UL_TKBPS \* 8)

#Uplink received
UL_R2=`cat /sys/class/net/eth3/statistics/rx_bytes`
UL_RBPS=`expr $UL_R2 - $UL_R1`
UL_RKBPS=`expr $UL_RBPS / 60000`
UL_RXBPS=$(expr $UL_RKBPS \* 8)

now="$(date)"
echo "WTS Interface Stats at $(date)"
echo "DL (Transmitted): $DL_TXBPS Kbps "
echo "DL (Received): $DL_RXBPS Kbps "
echo "UL (Transmitted): $UL_TXBPS Kbps "
echo "UL (Received): $UL_RXBPS Kbps "
done
while true
do
DL_T1=`cat /sys/class/net/eth3/statistics/tx_bytes`
UL_R1=`cat /sys/class/net/eth3/statistics/rx_bytes`
DL_R1=`cat /sys/class/net/eth4/statistics/rx_bytes`
UL_T1=`cat /sys/class/net/eth4/statistics/tx_bytes`
sleep 60

#Downlink transmitted
DL_T2=`cat /sys/class/net/eth3/statistics/tx_bytes`
DL_TBPS=`expr $DL_T2 - $DL_T1`
DL_TKBPS=`expr $DL_TBPS / 60000`
DL_TXBPS=$(expr $DL_TKBPS \* 8)

#Downlink received
DL_R2=`cat /sys/class/net/eth4/statistics/rx_bytes`
DL_RBPS=`expr $DL_R2 - $DL_R1`
DL_RKBPS=`expr $DL_RBPS / 60000`
DL_RXBPS=$(expr $DL_RKBPS \* 8)

#Uplink transmitted
UL_T2=`cat /sys/class/net/eth4/statistics/tx_bytes`
UL_TBPS=`expr $UL_T2 - $UL_T1`
UL_TKBPS=`expr $UL_TBPS / 60000`
UL_TXBPS=$(expr $UL_TKBPS \* 8)

#Uplink received
UL_R2=`cat /sys/class/net/eth3/statistics/rx_bytes`
UL_RBPS=`expr $UL_R2 - $UL_R1`
UL_RKBPS=`expr $UL_RBPS / 60000`
UL_RXBPS=$(expr $UL_RKBPS \* 8)

now="$(date)"
echo "WTS Interface Stats at $(date)"
echo "DL (Transmitted): $DL_TXBPS Kbps "
echo "DL (Received): $DL_RXBPS Kbps "
echo "UL (Transmitted): $UL_TXBPS Kbps "
echo "UL (Received): $UL_RXBPS Kbps "
done
