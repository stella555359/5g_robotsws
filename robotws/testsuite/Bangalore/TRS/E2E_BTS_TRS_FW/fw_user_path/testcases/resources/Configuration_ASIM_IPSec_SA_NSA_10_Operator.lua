-- Copyright (c) 2019 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT="22222"

GNB1_NGC_ADDR="10.0.21.2"
GNB2_NGC_ADDR="fc00::15:2"
GNB3_NGC_ADDR="10.0.21.11"
GNB4_NGC_ADDR="fc00::15:b"
GNB5_NGC_ADDR="10.0.21.20"
GNB6_NGC_ADDR="fc00::15:14"
GNB7_NGC_ADDR="10.0.21.28"
GNB8_NGC_ADDR="fc00::15:1d"
GNB9_NGC_ADDR="10.0.21.38"
GNB10_NGC_ADDR="fc00::15:26"
GNB11_NGC_ADDR="10.0.21.47"
GNB12_NGC_ADDR="fc00::15:2f"
GNB13_NGC_ADDR="10.0.21.56"
GNB14_NGC_ADDR="fc00::15:38"
GNB15_NGC_ADDR="10.0.21.65"
GNB16_NGC_ADDR="fc00::15:41"
GNB17_NGC_ADDR="10.0.21.74"
GNB18_NGC_ADDR="fc00::15:4a"
GNB19_NGC_ADDR="10.0.21.83"
GNB20_NGC_ADDR="fc00::15:53"


PROXY_SERVER_IP="10.0.2.80"

AMF1_NG_ADDR="10.0.21.141"
AMF2_NG_ADDR="fc00::15:141"
AMF3_NG_ADDR="10.0.21.142"
AMF4_NG_ADDR="fc00::15:142"
AMF5_NG_ADDR="10.0.21.143"
AMF6_NG_ADDR="fc00::15:143"
AMF7_NG_ADDR="10.0.21.144"
AMF8_NG_ADDR="fc00::15:144"
AMF9_NG_ADDR="10.0.21.145"
AMF10_NG_ADDR="fc00::15:145"
AMF11_NG_ADDR="10.0.21.146"
AMF12_NG_ADDR="fc00::15:146"
AMF13_NG_ADDR="10.0.21.147"
AMF14_NG_ADDR="fc00::15:147"
AMF15_NG_ADDR="10.0.21.148"
AMF16_NG_ADDR="fc00::15:148"
AMF17_NG_ADDR="10.0.21.149"
AMF18_NG_ADDR="fc00::15:149"
AMF19_NG_ADDR="10.0.21.150"
AMF20_NG_ADDR="fc00::15:150"


UEC_ADDR="72.22.0.1"


UPF1_ADDR="1.2.4.1"
UPF2_ADDR="20.2.4.1"
UPF3_ADDR="30.2.4.1"
UPF4_ADDR="40.2.4.1"
UPF5_ADDR="50.2.4.1"
UPF6_ADDR="60.2.4.1"
UPF7_ADDR="70.2.4.1"
UPF8_ADDR="80.2.4.1"
UPF9_ADDR="90.2.4.1"
UPF10_ADDR="100.2.4.1"
UPF11_ADDR="110.2.4.1"
UPF12_ADDR="120.2.4.1"
UPF13_ADDR="130.2.4.1"
UPF14_ADDR="140.2.4.1"
UPF15_ADDR="150.2.4.1"
UPF16_ADDR="160.2.4.1"
UPF17_ADDR="170.2.4.1"
UPF18_ADDR="180.2.4.1"
UPF19_ADDR="190.2.4.1"
UPF20_ADDR="200.2.4.1"

DEV_TUN1_NAME="tunUPF"
DEV_TUN2_NAME="tun2UPF"
DEV_TUN3_NAME="tun3UPF"
DEV_TUN4_NAME="tun4UPF"
DEV_TUN5_NAME="tun5UPF"
DEV_TUN6_NAME="tun6UPF"
DEV_TUN7_NAME="tun7UPF"
DEV_TUN8_NAME="tun8UPF"
DEV_TUN9_NAME="tun9UPF"
DEV_TUN10_NAME="tun10UPF"
DEV_TUN11_NAME="tun11UPF"
DEV_TUN12_NAME="tun12UPF"
DEV_TUN13_NAME="tun13UPF"
DEV_TUN14_NAME="tun14UPF"
DEV_TUN15_NAME="tun15UPF"
DEV_TUN16_NAME="tun16UPF"
DEV_TUN17_NAME="tun17UPF"
DEV_TUN18_NAME="tun18UPF"
DEV_TUN19_NAME="tun19UPF"
DEV_TUN20_NAME="tun20UPF"



ENB1_S1C_ADDR="10.0.21.9"
ENB2_S1C_ADDR="fc00::15:9"
ENB3_S1C_ADDR="10.0.21.18"
ENB4_S1C_ADDR="fc00::15:12"
ENB5_S1C_ADDR="10.0.21.27"
ENB6_S1C_ADDR="fc00::15:1b"
ENB7_S1C_ADDR="10.0.21.36"
ENB8_S1C_ADDR="fc00::15:24"
ENB9_S1C_ADDR="10.0.21.45"
ENB10_S1C_ADDR="fc00::15:2d"
ENB11_S1C_ADDR="10.0.21.54"
ENB12_S1C_ADDR="fc00::15:36"
ENB13_S1C_ADDR="10.0.21.63"
ENB14_S1C_ADDR="fc00::15:3f"
ENB15_S1C_ADDR="10.0.21.72"
ENB16_S1C_ADDR="fc00::15:48"
ENB17_S1C_ADDR="10.0.21.81"
ENB18_S1C_ADDR="fc00::15:51"
ENB19_S1C_ADDR="10.0.21.90"
ENB20_S1C_ADDR="fc00::15:5a"


GNB1_X2_ADDR="10.0.21.4"
GNB2_X2_ADDR="fc00::15:4"
GNB3_X2_ADDR="10.0.21.22"
GNB4_X2_ADDR="fc00::15:16"
GNB5_X2_ADDR="10.0.21.40"
GNB6_X2_ADDR="fc00::15:28"
GNB7_X2_ADDR="10.0.21.58"
GNB8_X2_ADDR="fc00::15:3a"
GNB9_X2_ADDR="10.0.21.76"
GNB10_X2_ADDR="fc00::15:4c"
GNB11_X2_ADDR="10.0.21.85"
GNB12_X2_ADDR="fc00::15:55"


MME1_S1_ADDR="10.0.21.121"
MME2_S1_ADDR="fc00::15:121"
MME3_S1_ADDR="10.0.21.122"
MME4_S1_ADDR="fc00::15:122"
MME5_S1_ADDR="10.0.21.123"
MME6_S1_ADDR="fc00::15:123"
MME7_S1_ADDR="10.0.21.124"
MME8_S1_ADDR="fc00::15:124"
MME9_S1_ADDR="10.0.21.125"
MME10_S1_ADDR="fc00::15:125"
MME11_S1_ADDR="10.0.21.126"
MME12_S1_ADDR="fc00::15:126"
MME13_S1_ADDR="10.0.21.127"
MME14_S1_ADDR="fc00::15:127"
MME15_S1_ADDR="10.0.21.128"
MME16_S1_ADDR="fc00::15:128"
MME17_S1_ADDR="10.0.21.129"
MME18_S1_ADDR="fc00::15:129"
MME19_S1_ADDR="10.0.21.130"
MME20_S1_ADDR="fc00::15:130"



SERVER_ADDR="10.0.1.132"


SGW1_S1U_ADDR="10.0.21.131"
SGW2_S1U_ADDR="fc00::15:131"
SGW3_S1U_ADDR="10.0.21.132"
SGW4_S1U_ADDR="fc00::15:132"
SGW5_S1U_ADDR="10.0.21.133"
SGW6_S1U_ADDR="fc00::15:133"
SGW7_S1U_ADDR="10.0.21.134"
SGW8_S1U_ADDR="fc00::15:134"
SGW9_S1U_ADDR="10.0.21.135"
SGW10_S1U_ADDR="fc00::15:135"
SGW11_S1U_ADDR="10.0.21.136"
SGW12_S1U_ADDR="fc00::15:136"
SGW13_S1U_ADDR="10.0.21.137"
SGW14_S1U_ADDR="fc00::15:137"
SGW15_S1U_ADDR="10.0.21.138"
SGW16_S1U_ADDR="fc00::15:138"
SGW17_S1U_ADDR="10.0.21.139"
SGW18_S1U_ADDR="fc00::15:139"
SGW19_S1U_ADDR="10.0.21.140"
SGW20_S1U_ADDR="fc00::15:140"


SGW1_S11_ADDR="10.0.1.134"
SGW2_S11_ADDR="10.0.1.135"
SGW3_S11_ADDR="10.0.1.136"
SGW4_S11_ADDR="10.0.1.137"
SGW5_S11_ADDR="10.0.1.138"
SGW6_S11_ADDR="10.0.1.139"
SGW7_S11_ADDR="10.0.1.140"
SGW8_S11_ADDR="10.0.1.141"
SGW9_S11_ADDR="10.0.1.142"
SGW10_S11_ADDR="10.0.1.143"
SGW11_S11_ADDR="10.0.1.144"
SGW12_S11_ADDR="10.0.1.145"
SGW13_S11_ADDR="10.0.1.146"
SGW14_S11_ADDR="10.0.1.147"
SGW15_S11_ADDR="10.0.1.148"
SGW16_S11_ADDR="10.0.1.149"
SGW17_S11_ADDR="10.0.1.150"
SGW18_S11_ADDR="10.0.1.151"
SGW19_S11_ADDR="10.0.1.152"
SGW20_S11_ADDR="10.0.1.153"


PGW1_ADDR="4.7.254.207"
PGW2_ADDR="5.7.254.207"
PGW3_ADDR="6.7.254.207"
PGW4_ADDR="7.7.254.207"
PGW5_ADDR="8.7.254.207"
PGW6_ADDR="9.7.254.207"
PGW7_ADDR="10.7.254.207"
PGW8_ADDR="11.7.254.207"
PGW9_ADDR="12.7.254.207"
PGW10_ADDR="13.7.254.207"
PGW11_ADDR="14.7.254.207"
PGW12_ADDR="15.7.254.207"
PGW13_ADDR="16.7.254.207"
PGW14_ADDR="17.7.254.207"
PGW15_ADDR="18.7.254.207"
PGW16_ADDR="19.7.254.207"
PGW17_ADDR="20.7.254.207"
PGW18_ADDR="21.7.254.207"
PGW19_ADDR="22.7.254.207"
PGW20_ADDR="23.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"



exec('set_enb type=external id=1 plmn=311:489 s1='..ENB1_S1C_ADDR..'/'..ENB2_S1C_ADDR..','..ENB4_S1C_ADDR..','..ENB5_S1C_ADDR..'/'..ENB6_S1C_ADDR..','..ENB7_S1C_ADDR..','..ENB9_S1C_ADDR..'/'..ENB10_S1C_ADDR..','..ENB12_S1C_ADDR..','..ENB13_S1C_ADDR..'/'..ENB14_S1C_ADDR..','..ENB15_S1C_ADDR..','..ENB17_S1C_ADDR..'/'..ENB18_S1C_ADDR..','..ENB20_S1C_ADDR..' mme=1,2,4,5,6,7,9,10,12,13,14,15,17,18,20 enb_id_macro=0x00001 daemon=127.0.0.1:22222')

exec('set_cell id=11 technology=lte enb=1 pci=3:2 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010b shared_plmn=311:489,311:490,311:491,311:492 is_cus_cell=on cus_addr=10.0.2.2:10011')
exec('set_cell id=12 technology=lte enb=1 pci=4:0 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010c shared_plmn=311:489,311:493,311:494,311:495 is_cus_cell=on cus_addr=10.0.2.2:10012')
exec('set_cell id=13 technology=lte enb=1 pci=4:1 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010d shared_plmn=311:489,311:496,311:497,311:498 is_cus_cell=on cus_addr=10.0.2.2:10013')

exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=2 mmegi=2 plmn=311:490 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=3 mmegi=3 plmn=311:491 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=4 mmegi=4 plmn=311:492 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=5 mmegi=5 plmn=311:493 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=6 mmegi=6 plmn=311:494 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=7 mmegi=7 plmn=311:495 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=8 mmegi=8 plmn=311:496 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=9 mmegi=9 plmn=311:497 tac_list=555,234,222,444,333,124')
exec('mme_pool_area id=10 mmegi=10 plmn=311:498 tac_list=555,234,222,444,333,124')

exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_mme id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME2_S1_ADDR..'.36412 supported_rat=lte pool=1:2')
exec('set_mme id=3 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME3_S1_ADDR..':36412 supported_rat=lte pool=2:1')
exec('set_mme id=4 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME4_S1_ADDR..'.36412 supported_rat=lte pool=2:2')
exec('set_mme id=5 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME5_S1_ADDR..':36412 supported_rat=lte pool=3:1')
exec('set_mme id=6 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME6_S1_ADDR..'.36412 supported_rat=lte pool=3:2')
exec('set_mme id=7 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME7_S1_ADDR..':36412 supported_rat=lte pool=4:1')
exec('set_mme id=8 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME8_S1_ADDR..'.36412 supported_rat=lte pool=4:2')
exec('set_mme id=9 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME9_S1_ADDR..':36412 supported_rat=lte pool=5:1')
exec('set_mme id=10 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME10_S1_ADDR..'.36412 supported_rat=lte pool=5:2')
exec('set_mme id=11 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME11_S1_ADDR..':36412 supported_rat=lte pool=6:1')
exec('set_mme id=12 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME12_S1_ADDR..'.36412 supported_rat=lte pool=6:2')
exec('set_mme id=13 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME13_S1_ADDR..':36412 supported_rat=lte pool=7:1')
exec('set_mme id=14 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME14_S1_ADDR..'.36412 supported_rat=lte pool=7:2')
exec('set_mme id=15 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME15_S1_ADDR..':36412 supported_rat=lte pool=8:1')
exec('set_mme id=16 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME16_S1_ADDR..'.36412 supported_rat=lte pool=8:2')
exec('set_mme id=17 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME17_S1_ADDR..':36412 supported_rat=lte pool=9:1')
exec('set_mme id=18 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME18_S1_ADDR..'.36412 supported_rat=lte pool=9:2')
exec('set_mme id=19 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME19_S1_ADDR..':36412 supported_rat=lte pool=10:1')
exec('set_mme id=20 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME20_S1_ADDR..'.36412 supported_rat=lte pool=10:2')


exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW1_S1U_ADDR..' s11='..SGW1_S11_ADDR..':60100')
exec('set_sgw id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW2_S1U_ADDR..' s11='..SGW2_S11_ADDR..':60100')
exec('set_sgw id=3 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW3_S1U_ADDR..' s11='..SGW3_S11_ADDR..':60100')
exec('set_sgw id=4 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW4_S1U_ADDR..' s11='..SGW4_S11_ADDR..':60100')
exec('set_sgw id=5 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW5_S1U_ADDR..' s11='..SGW5_S11_ADDR..':60100')
exec('set_sgw id=6 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW6_S1U_ADDR..' s11='..SGW6_S11_ADDR..':60100')
exec('set_sgw id=7 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW7_S1U_ADDR..' s11='..SGW7_S11_ADDR..':60100')
exec('set_sgw id=8 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW8_S1U_ADDR..' s11='..SGW8_S11_ADDR..':60100')
exec('set_sgw id=9 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW9_S1U_ADDR..' s11='..SGW9_S11_ADDR..':60100')
exec('set_sgw id=10 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW10_S1U_ADDR..' s11='..SGW10_S11_ADDR..':60100')
exec('set_sgw id=11 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW11_S1U_ADDR..' s11='..SGW11_S11_ADDR..':60100')
exec('set_sgw id=12 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW12_S1U_ADDR..' s11='..SGW12_S11_ADDR..':60100')
exec('set_sgw id=13 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW13_S1U_ADDR..' s11='..SGW13_S11_ADDR..':60100')
exec('set_sgw id=14 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW14_S1U_ADDR..' s11='..SGW14_S11_ADDR..':60100')
exec('set_sgw id=15 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW15_S1U_ADDR..' s11='..SGW15_S11_ADDR..':60100')
exec('set_sgw id=16 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW16_S1U_ADDR..' s11='..SGW16_S11_ADDR..':60100')
exec('set_sgw id=17 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW17_S1U_ADDR..' s11='..SGW17_S11_ADDR..':60100')
exec('set_sgw id=18 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW18_S1U_ADDR..' s11='..SGW18_S11_ADDR..':60100')
exec('set_sgw id=19 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW19_S1U_ADDR..' s11='..SGW19_S11_ADDR..':60100')
exec('set_sgw id=20 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW20_S1U_ADDR..' s11='..SGW20_S11_ADDR..':60100')

exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW1_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA1')
exec('set_pgw id=2 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW2_ADDR..'/16 apn=lteapn2.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA2')
exec('set_pgw id=3 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW3_ADDR..'/16 apn=lteapn3.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA3')
exec('set_pgw id=4 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW4_ADDR..'/16 apn=lteapn4.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA4')
exec('set_pgw id=5 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW5_ADDR..'/16 apn=lteapn5.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA5')
exec('set_pgw id=6 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW6_ADDR..'/16 apn=lteapn6.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA6')
exec('set_pgw id=7 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW7_ADDR..'/16 apn=lteapn7.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA7')
exec('set_pgw id=8 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW8_ADDR..'/16 apn=lteapn8.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA8')
exec('set_pgw id=9 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW9_ADDR..'/16 apn=lteapn9.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA9')
exec('set_pgw id=10 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW10_ADDR..'/16 apn=lteapn10.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA10')
exec('set_pgw id=11 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW11_ADDR..'/16 apn=lteapn11.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA11')
exec('set_pgw id=12 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW12_ADDR..'/16 apn=lteapn12.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA12')
exec('set_pgw id=13 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW13_ADDR..'/16 apn=lteapn13.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')
exec('set_pgw id=14 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW14_ADDR..'/16 apn=lteapn14.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA14')
exec('set_pgw id=15 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW15_ADDR..'/16 apn=lteapn15.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA15')
exec('set_pgw id=16 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW16_ADDR..'/16 apn=lteapn16.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA16')
exec('set_pgw id=17 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW17_ADDR..'/16 apn=lteapn17.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA17')
exec('set_pgw id=18 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW18_ADDR..'/16 apn=lteapn18.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA18')
exec('set_pgw id=19 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW19_ADDR..'/16 apn=lteapn19.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA19')
exec('set_pgw id=20 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW20_ADDR..'/16 apn=lteapn20.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA20')



-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:490')
exec('set_amf_region id=3 tac_list=7627107,100,788,200,0 plmn=311:491')
exec('set_amf_region id=4 tac_list=7627107,100,788,200,0 plmn=311:492')
exec('set_amf_region id=5 tac_list=7627107,100,788,200,0 plmn=311:493')
exec('set_amf_region id=6 tac_list=7627107,100,788,200,0 plmn=311:494')
exec('set_amf_region id=7 tac_list=7627107,100,788,200,0 plmn=311:495')
exec('set_amf_region id=8 tac_list=7627107,100,788,200,0 plmn=311:496')
exec('set_amf_region id=9 tac_list=7627107,100,788,200,0 plmn=311:497')
exec('set_amf_region id=10 tac_list=7627107,100,788,200,0 plmn=311:498')

exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..AMF1_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN1_NAME..'')

exec('set_amf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF2_NG_ADDR..'.38412 region=1 set_id=2 pointer=2')
exec('amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/24 ngu='..AMF2_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN2_NAME..'')

exec('set_amf id=3 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF3_NG_ADDR..':38412 region=2 set_id=1 pointer=1')
exec('amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=3 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF3_ADDR..'/24 ngu='..AMF3_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN3_NAME..'')

exec('set_amf id=4 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF4_NG_ADDR..'.38412 region=2 set_id=2 pointer=2')
exec('amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=4 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF4_ADDR..'/24 ngu='..AMF4_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN4_NAME..'')

exec('set_amf id=5 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF5_NG_ADDR..':38412 region=3 set_id=1 pointer=1')
exec('amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=5 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF5_ADDR..'/24 ngu='..AMF5_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN5_NAME..'')

exec('set_amf id=6 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF6_NG_ADDR..'.38412 region=3 set_id=2 pointer=2')
exec('amf_param id=6 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=6 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF6_ADDR..'/24 ngu='..AMF6_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN6_NAME..'')

exec('set_amf id=7 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF7_NG_ADDR..':38412 region=4 set_id=1 pointer=1')
exec('amf_param id=7 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=7 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF7_ADDR..'/24 ngu='..AMF7_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN7_NAME..'')

exec('set_amf id=8 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF8_NG_ADDR..'.38412 region=4 set_id=2 pointer=2')
exec('amf_param id=8 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=8 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF8_ADDR..'/24 ngu='..AMF8_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN8_NAME..'')

exec('set_amf id=9 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF9_NG_ADDR..':38412 region=5 set_id=1 pointer=1')
exec('amf_param id=9 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=9 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF9_ADDR..'/24 ngu='..AMF9_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN9_NAME..'')

exec('set_amf id=10 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF10_NG_ADDR..'.38412 region=5 set_id=2 pointer=2')
exec('amf_param id=10 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=10 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF10_ADDR..'/24 ngu='..AMF10_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN10_NAME..'')

exec('set_amf id=11 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF11_NG_ADDR..':38412 region=6 set_id=1 pointer=1')
exec('amf_param id=11 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=11 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF11_ADDR..'/24 ngu='..AMF11_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN11_NAME..'')

exec('set_amf id=12 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF12_NG_ADDR..'.38412 region=6 set_id=2 pointer=2')
exec('amf_param id=12 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=12 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF12_ADDR..'/24 ngu='..AMF12_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN12_NAME..'')

exec('set_amf id=13 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF13_NG_ADDR..':38412 region=7 set_id=1 pointer=1')
exec('amf_param id=13 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=13 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF13_ADDR..'/24 ngu='..AMF13_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN13_NAME..'')

exec('set_amf id=14 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF14_NG_ADDR..'.38412 region=7 set_id=2 pointer=2')
exec('amf_param id=14 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=14 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF14_ADDR..'/24 ngu='..AMF14_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN14_NAME..'')

exec('set_amf id=15 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF15_NG_ADDR..':38412 region=8 set_id=1 pointer=1')
exec('amf_param id=15 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=15 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF15_ADDR..'/24 ngu='..AMF15_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN15_NAME..'')

exec('set_amf id=16 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF16_NG_ADDR..'.38412 region=8 set_id=2 pointer=2')
exec('amf_param id=16 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=16 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF16_ADDR..'/24 ngu='..AMF16_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN16_NAME..'')

exec('set_amf id=17 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF17_NG_ADDR..':38412 region=9 set_id=1 pointer=1')
exec('amf_param id=17 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=17 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF17_ADDR..'/24 ngu='..AMF17_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN17_NAME..'')

exec('set_amf id=18 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF18_NG_ADDR..'.38412 region=9 set_id=2 pointer=2')
exec('amf_param id=18 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=18 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF18_ADDR..'/24 ngu='..AMF18_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN18_NAME..'')

exec('set_amf id=19 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF19_NG_ADDR..':38412 region=10 set_id=1 pointer=1')
exec('amf_param id=19 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=19 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF19_ADDR..'/24 ngu='..AMF19_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN19_NAME..'')

exec('set_amf id=20 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF20_NG_ADDR..'.38412 region=10 set_id=2 pointer=2')
exec('amf_param id=20 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=20 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF20_ADDR..'/24 ngu='..AMF20_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname='..DEV_TUN20_NAME..'')


exec('smf_upf_mapping id=1 upf=1 id=2 upf=2 id=3 upf=3 id=4 upf=4 id=5 upf=5 id=6 upf=6 id=7 upf=7 id=8 upf=8 id=9 upf=9 id=10 upf=10 id=11 upf=11 id=12 upf=12 id=13 upf=13 id=14 upf=14 id=15 upf=15 id=16 upf=16 id=17 upf=17 id=18 upf=18 id=19 upf=19 id=20 upf=20')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------

exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB1_NGC_ADDR..'/'..GNB2_NGC_ADDR..','..GNB3_NGC_ADDR..','..GNB5_NGC_ADDR..'/'..GNB6_NGC_ADDR..','..GNB8_NGC_ADDR..','..GNB9_NGC_ADDR..'/'..GNB10_NGC_ADDR..','..GNB11_NGC_ADDR..','..GNB13_NGC_ADDR..'/'..GNB14_NGC_ADDR..','..GNB16_NGC_ADDR..','..GNB17_NGC_ADDR..'/'..GNB18_NGC_ADDR..','..GNB19_NGC_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1,2,3,5,6,8,9,10,11,13,14,16,17,18,19 plmnList=311:489,311:490,311:491,311:492,311:493,311:494,311:495,311:496,311:497,311:498')

exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 mandatory_for_activation=off tdd_cell=on')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=17:0 tac=788 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 mandatory_for_activation=off tdd_cell=on')
exec('set_cell id=3 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 mandatory_for_activation=off tdd_cell=on')
exec('set_cell id=4 gnb=2 nr_arfcn=390000:428000 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 mandatory_for_activation=off tdd_cell=off')
exec('set_cell id=5 gnb=2 nr_arfcn=390000:428000 eci=0x000021f pci=18:0 tac=200 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 mandatory_for_activation=off tdd_cell=off')
exec('set_cell id=6 gnb=2 nr_arfcn=390000:428000 eci=0x000021f pci=18:1 tac=200 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 mandatory_for_activation=off tdd_cell=off')

-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec file=AirPhoneConfig.xml  id=1 enable_cus_if=on uec_cus_if_ip=10.0.2.1:40000 ip='..DAEMON_IP..':'..DAEMON_PORT..' pdn=1 devtype=tun addr=72.22.0.1/26 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')
-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------

IMSI_FIRST_UE_SA=21645400
IMSI_FIRST_UE=111111001
FIRST_UE_SA=1
LAST_UE_SA=10
mnc=489

for UEID = FIRST_UE_SA, LAST_UE_SA do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:'.. mnc + UEID - 1 ..':0000:0:0:0'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

for UEID = 11, 20 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:'.. mnc + UEID - 11 ..':0000:0:0:0'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

for UEID = 21, 40 do
	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=311:489:'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=5DA00200A4000801001850AA5F80000001202004078500000E908020800014401C369A0600FA000AE00000 ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801') 
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
end
-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
--set_qosflow id=1 5qi=6 default=on
--set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
--set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP ul_nat_gw='..SERVER_IP
--set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP ul_nat_gw='..SERVER_IP

for UEID = FIRST_UE_SA, LAST_UE_SA  do
    exec('set_pdu_gateway id='..UEID..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
end 

exec('qosflow_set id=1 5qi=5 default=on')
exec('qosflow_set id=2 5qi=1')
exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('nwslice_set id=1 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1,11 amf=1,2')
exec('nwslice_set id=2 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A6 default=on ue=2,12 amf=3,4')
exec('nwslice_set id=3 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A7 default=on ue=3,13 amf=5,6')
exec('nwslice_set id=4 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A8 default=on ue=4,14 amf=7,8')
exec('nwslice_set id=5 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A9 default=on ue=5,15 amf=9,10')
exec('nwslice_set id=6 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AA default=on ue=6,16 amf=11,12')
exec('nwslice_set id=7 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AB default=on ue=7,17 amf=13,14')
exec('nwslice_set id=8 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AC default=on ue=8,18 amf=15,16')
exec('nwslice_set id=9 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AD default=on ue=9,19 amf=17,18')
exec('nwslice_set id=10 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AE default=on ue=10,20 amf=19,20')

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------
--[[
set_bearer id=2 ue=11 qci=9 pdn=1 ip='..PDN_IP default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
set_bearer id=2 ue=12 qci=9 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
set_bearer id=2 ue=13 qci=9 pdn=1 ip=4.7.254.216 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
set_bearer id=2 ue=14 qci=9 pdn=1 ip=4.7.254.218 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
set_bearer id=2 ue=15 qci=9 pdn=1 ip=4.7.254.222 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
set_bearer id=2 ue=16 qci=9 pdn=1 ip=4.7.254.226 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
uec_param id=1 reordering_window_size=1000 reordering_timer=200
]]--
-----------------------------------------------------------------------------------------------------
exec('set_cnode ip=127.0.0.1:7676')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('debug_log level=6 uec=1')
exec('sim_debug_log level=6 pgw=1 enb=4')
exec('sim_trace uec=1 protocol=nr_rrc,rrc on')
exec('set_log log_to_file=true max_file_num=1')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('trace uec=1 protocol=x2 on')
exec('start version_check=off')
--exec('trace protocol=s1 on mme=1')
exec('sim_debug_log level=6 uec=1')