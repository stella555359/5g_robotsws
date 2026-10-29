-- Copyright (c) 2019 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"         
SERVER_IP=CONTAINER_IP

--OP-1
GNB1_NG_ADDR="10.0.3.210"
GNB1_XN_ADDR="10.0.3.210"
--OP-2
GNB2_NG_ADDR="10.0.3.214"
GNB2_XN_ADDR="10.0.3.214"
--OP-3
GNB3_NG_ADDR="10.0.3.218"
GNB3_XN_ADDR="10.0.3.218"
--OP-4
GNB4_NG_ADDR="10.0.3.222"
GNB4_XN_ADDR="10.0.3.222"
--OP-5
GNB5_NG_ADDR="10.0.3.226"
GNB5_XN_ADDR="10.0.3.226"
--OP-6
GNB6_NG_ADDR="10.0.3.230"
GNB6_XN_ADDR="10.0.3.230"

--OP-1
GNB7_NG_ADDR="fc00::3:15"
GNB7_XN_ADDR="fc00::3:15"
--OP-2
GNB8_NG_ADDR="fc00::3:19"
GNB8_XN_ADDR="fc00::3:19"
--OP-3
GNB9_NG_ADDR="fc00::3:23"
GNB9_XN_ADDR="fc00::3:23"
--OP-4
GNB10_NG_ADDR="fc00::3:27"
GNB10_XN_ADDR="fc00::3:27"
--OP-5
GNB11_NG_ADDR="fc00::3:31"
GNB11_XN_ADDR="fc00::3:31"
--OP-6
GNB12_NG_ADDR="fc00::3:35"
GNB12_XN_ADDR="fc00::3:35"


PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.5"
AMF2_NG_ADDR="10.0.1.7"
AMF3_NG_ADDR="10.0.1.9"
AMF4_NG_ADDR="10.0.1.11"
AMF5_NG_ADDR="10.0.1.13"
AMF6_NG_ADDR="10.0.1.15"
AMF7_NG_ADDR="fc00::5"
AMF8_NG_ADDR="fc00::7"
AMF9_NG_ADDR="fc00::9"
AMF10_NG_ADDR="fc00::11"
AMF11_NG_ADDR="fc00::13"
AMF12_NG_ADDR="fc00::15"

UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.3.1"
UPF2_ADDR="20.2.3.1"
UPF3_ADDR="30.2.3.1"
UPF4_ADDR="40.2.3.1"
UPF5_ADDR="50.2.3.1"
UPF6_ADDR="60.2.3.1"
UPF7_ADDR="70.2.3.1"
UPF8_ADDR="80.2.3.1"
UPF9_ADDR="90.2.3.1"
UPF10_ADDR="100.2.3.1"
UPF11_ADDR="110.2.3.1"
UPF12_ADDR="120.2.3.1"

EDAEMON_PORT="50000"

DEV_TUN_NAME="tunUPF"
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

-----LTE------
DAEMON_IP=CONTAINER_IP
DAEMON_PORT=50000
MME1_S1_ADDR="10.0.1.17"
MME2_S1_ADDR="fc00::17"
MME3_S1_ADDR="10.0.1.19"
MME4_S1_ADDR="fc00::19"
MME5_S1_ADDR="10.0.1.21"
MME6_S1_ADDR="fc00::21"
MME7_S1_ADDR="10.0.1.23"
MME8_S1_ADDR="fc00::23"
MME9_S1_ADDR="10.0.1.25"
MME10_S1_ADDR="fc00::25"
MME11_S1_ADDR="10.0.1.27"
MME12_S1_ADDR="fc00::27"



SGW1_S1U_ADDR="10.0.1.120"
SGW2_S1U_ADDR="fc00::1:120"
SGW3_S1U_ADDR="10.0.1.121"
SGW4_S1U_ADDR="fc00::1:121"
SGW5_S1U_ADDR="10.0.1.122"
SGW6_S1U_ADDR="fc00::1:122"
SGW7_S1U_ADDR="10.0.1.123"
SGW8_S1U_ADDR="fc00::1:123"
SGW9_S1U_ADDR="10.0.1.124"
SGW10_S1U_ADDR="fc00::1:124"
SGW11_S1U_ADDR="10.0.1.125"
SGW12_S1U_ADDR="fc00::1:125"

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

PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"



----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
------------------op1----------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' devname='..DEV_TUN_NAME..'')
----------------------------------------------------------------------------------------------------
------------------op2----------------------------------------------------------------------------------
exec('set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:490')
exec('set_amf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=2 pointer=2')
exec('amf_param id=2 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/24 ngu='..AMF2_NG_ADDR..' devname='..DEV_TUN2_NAME..'')

------------------op3----------------------------------------------------------------------------------
exec('set_amf_region id=3 tac_list=7627107,100,788,200,0 plmn=311:491')
exec('set_amf id=3 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF3_NG_ADDR..':38412 region=3 set_id=3 pointer=3')
exec('amf_param id=3 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=3 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF3_ADDR..'/24 ngu='..AMF3_NG_ADDR..' devname='..DEV_TUN3_NAME..'')

------------------op4----------------------------------------------------------------------------------
exec('set_amf_region id=4 tac_list=7627107,100,788,200,0 plmn=311:492')
exec('set_amf id=4 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF4_NG_ADDR..':38412 region=4 set_id=4 pointer=4')
exec('amf_param id=4 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=4 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF4_ADDR..'/24 ngu='..AMF4_NG_ADDR..' devname='..DEV_TUN4_NAME..'')

------------------op5----------------------------------------------------------------------------------
exec('set_amf_region id=5 tac_list=7627107,100,788,200,0 plmn=311:493')
exec('set_amf id=5 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF5_NG_ADDR..':38412 region=5 set_id=5 pointer=5')
exec('amf_param id=5 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=5 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF5_ADDR..'/24 ngu='..AMF5_NG_ADDR..' devname='..DEV_TUN5_NAME..'')

------------------op6----------------------------------------------------------------------------------
exec('set_amf_region id=6 tac_list=7627107,100,788,200,0 plmn=311:494')
exec('set_amf id=6 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF6_NG_ADDR..':38412 region=6 set_id=6 pointer=6')
exec('amf_param id=6 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=6 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF6_ADDR..'/24 ngu='..AMF6_NG_ADDR..' devname='..DEV_TUN6_NAME..'')


----------------------------------------------------------------------------------------------------

--IPV6
------------------op1----------------------------------------------------------------------------------
exec('set_amf_region id=7 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=7 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF7_NG_ADDR..'.38412 region=7 set_id=7 pointer=7')
exec('amf_param id=7 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=7 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF7_ADDR..'/24 ngu='..AMF7_NG_ADDR..' devname='..DEV_TUN7_NAME..'')
----------------------------------------------------------------------------------------------------
------------------op2----------------------------------------------------------------------------------
exec('set_amf_region id=8 tac_list=7627107,100,788,200,0 plmn=311:490')
exec('set_amf id=8 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF8_NG_ADDR..'.38412 region=8 set_id=8 pointer=8')
exec('amf_param id=8 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=8 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF8_ADDR..'/24 ngu='..AMF8_NG_ADDR..' devname='..DEV_TUN8_NAME..'')
------------------op3----------------------------------------------------------------------------------
exec('set_amf_region id=9 tac_list=7627107,100,788,200,0 plmn=311:491')
exec('set_amf id=9 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF9_NG_ADDR..'.38412 region=9 set_id=9 pointer=9')
exec('amf_param id=9 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=9 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF9_ADDR..'/24 ngu='..AMF9_NG_ADDR..' devname='..DEV_TUN9_NAME..'')
------------------op4----------------------------------------------------------------------------------
exec('set_amf_region id=10 tac_list=7627107,100,788,200,0 plmn=311:492')
exec('set_amf id=10 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF10_NG_ADDR..'.38412 region=10 set_id=10 pointer=10')
exec('amf_param id=10 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=10 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF10_ADDR..'/24 ngu='..AMF10_NG_ADDR..' devname='..DEV_TUN10_NAME..'')
------------------op5----------------------------------------------------------------------------------
exec('set_amf_region id=11 tac_list=7627107,100,788,200,0 plmn=311:493')
exec('set_amf id=11 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF11_NG_ADDR..'.38412 region=11 set_id=11 pointer=11')
exec('amf_param id=11 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=11 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF11_ADDR..'/24 ngu='..AMF11_NG_ADDR..' devname='..DEV_TUN11_NAME..'')
------------------op6----------------------------------------------------------------------------------
exec('set_amf_region id=12 tac_list=7627107,100,788,200,0 plmn=311:494')
exec('set_amf id=12 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF12_NG_ADDR..'.38412 region=12 set_id=12 pointer=12')
exec('amf_param id=12 full_nas_auth=on nia=null+zuc nea=null')
exec('set_upf id=12 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF12_ADDR..'/24 ngu='..AMF12_NG_ADDR..' devname='..DEV_TUN12_NAME..'')

exec('smf_upf_mapping id=1 upf=1 id=2 upf=2 id=3 upf=3 id=4 upf=4 id=5 upf=5 id=6 upf=6 id=7 upf=7 id=8 upf=8 id=9 upf=9 id=10 upf=10 id=11 upf=11 id=12 upf=12')



--ENB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_enb type=external id=14 plmn=311:489 s1=10.0.3.234 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb type=external id=15 plmn=311:489 s1=fc00::3:39 enb_id_macro=0x00001 daemon=127.0.0.1:10000')

exec('set_enb type=external id=16 plmn=311:490 s1=10.0.3.238 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb type=external id=17 plmn=311:490 s1=fc00::3:43 enb_id_macro=0x00001 daemon=127.0.0.1:10000')

exec('set_enb type=external id=18 plmn=311:491 s1=10.0.3.242 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb type=external id=19 plmn=311:491 s1=fc00::3:47 enb_id_macro=0x00001 daemon=127.0.0.1:10000')

exec('set_enb type=external id=20 plmn=311:492 s1=10.0.3.246 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb type=external id=21 plmn=311:492 s1=fc00::3:51 enb_id_macro=0x00001 daemon=127.0.0.1:10000')

exec('set_enb type=external id=22 plmn=311:493 s1=10.0.3.250 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb type=external id=23 plmn=311:493 s1=fc00::3:55 enb_id_macro=0x00001 daemon=127.0.0.1:10000')

exec('set_enb type=external id=24 plmn=311:494 s1=10.0.3.254 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb type=external id=25 plmn=311:494 s1=fc00::3:59 enb_id_macro=0x00001 daemon=127.0.0.1:10000')

exec('set_cell id=11 technology=lte enb=14 pci=3:2 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010b shared_plmn=234:77 is_cus_cell=on cus_addr=10.0.2.2:10011')



---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
--op1:
exec('mme_pool_area id=1 mmegi=1 plmn=311:489  tac_list=555,234,222,444,333,124,311')
exec('set_mme id=14 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1') --mmegi=1 mmec=3
exec('set_mme id=15 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME2_S1_ADDR..'.36412 supported_rat=lte pool=1:2')
exec('set_sgw id=14 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW1_S1U_ADDR..' s11='..SGW1_S11_ADDR..':60100')
exec('set_sgw id=15 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW2_S1U_ADDR..' s11='..SGW2_S11_ADDR..':60100')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA1')

exec('mme_pool_area id=2 mmegi=2 plmn=311:490  tac_list=555,234,222,444,333,124,311')
exec('set_mme id=16 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME3_S1_ADDR..':36412 supported_rat=lte pool=2:1') --mmegi=1 mmec=3
exec('set_mme id=17 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME4_S1_ADDR..'.36412 supported_rat=lte pool=2:2')
exec('set_sgw id=16 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW3_S1U_ADDR..' s11='..SGW3_S11_ADDR..':60100')
exec('set_sgw id=17 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW4_S1U_ADDR..' s11='..SGW4_S11_ADDR..':60100')


exec('mme_pool_area id=3 mmegi=3 plmn=311:491  tac_list=555,234,222,444,333,124,311')
exec('set_mme id=18 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME5_S1_ADDR..':36412 supported_rat=lte pool=3:1') --mmegi=1 mmec=3
exec('set_mme id=19 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME6_S1_ADDR..'.36412 supported_rat=lte pool=3:2')
exec('set_sgw id=18 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW5_S1U_ADDR..' s11='..SGW5_S11_ADDR..':60100')
exec('set_sgw id=19 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW6_S1U_ADDR..' s11='..SGW6_S11_ADDR..':60100')

exec('mme_pool_area id=4 mmegi=4 plmn=311:492  tac_list=555,234,222,444,333,124,311')
exec('set_mme id=20 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME7_S1_ADDR..':36412 supported_rat=lte pool=4:1') --mmegi=1 mmec=3
exec('set_mme id=21 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME8_S1_ADDR..'.36412 supported_rat=lte pool=4:2')
exec('set_sgw id=20 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW7_S1U_ADDR..' s11='..SGW7_S11_ADDR..':60100')
exec('set_sgw id=21 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW8_S1U_ADDR..' s11='..SGW8_S11_ADDR..':60100')

exec('mme_pool_area id=5 mmegi=5 plmn=311:493  tac_list=555,234,222,444,333,124,311')
exec('set_mme id=22 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME9_S1_ADDR..':36412 supported_rat=lte pool=5:1') --mmegi=1 mmec=3
exec('set_mme id=23 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME10_S1_ADDR..'.36412 supported_rat=lte pool=5:2')
exec('set_sgw id=22 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW9_S1U_ADDR..' s11='..SGW9_S11_ADDR..':60100')
exec('set_sgw id=23 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW10_S1U_ADDR..' s11='..SGW10_S11_ADDR..':60100')

exec('mme_pool_area id=6 mmegi=6 plmn=311:494  tac_list=555,234,222,444,333,124,311')
exec('set_mme id=24 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME11_S1_ADDR..':36412 supported_rat=lte pool=6:1') --mmegi=1 mmec=3
exec('set_mme id=25 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME12_S1_ADDR..'.36412 supported_rat=lte pool=6:2')
exec('set_sgw id=24 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW11_S1U_ADDR..' s11='..SGW11_S11_ADDR..':60100')
exec('set_sgw id=25 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW12_S1U_ADDR..' s11='..SGW12_S11_ADDR..':60100')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-------------------------op1--------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB1_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')
--set_cell id=1 gnb=2 pci=16:2 tac=788 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP:9999|'..PROXY_SERVER_IP:8888 nr_arfcn=135760:126380
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=16:2 tac=788 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF mandatory_for_activation=off tdd_cell=on')

-------------------------op2---------------------------------------------------------------------------
exec('set_gnb id=3 type=external plmn=311:490 ng='..GNB2_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=2 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op3---------------------------------------------------------------------------
exec('set_gnb id=4 type=external plmn=311:491 ng='..GNB3_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=3 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op4---------------------------------------------------------------------------
exec('set_gnb id=5 type=external plmn=311:492 ng='..GNB4_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=4 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op5---------------------------------------------------------------------------
exec('set_gnb id=6 type=external plmn=311:493 ng='..GNB5_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=5 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op6---------------------------------------------------------------------------
exec('set_gnb id=7 type=external plmn=311:494 ng='..GNB6_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=6 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

--ipv6:
-------------------------op1--------------------------------------------------------------------------
exec('set_gnb id=8 type=external plmn=311:489 ng='..GNB7_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=7 plmnList=311:489,311:490,311:491,311:492,311:493,311:494') 

-------------------------op2---------------------------------------------------------------------------
exec('set_gnb id=9 type=external plmn=311:490 ng='..GNB8_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=8 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op3---------------------------------------------------------------------------
exec('set_gnb id=10 type=external plmn=311:491 ng='..GNB9_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=9 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op4---------------------------------------------------------------------------
exec('set_gnb id=11 type=external plmn=311:492 ng='..GNB10_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=10 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op5---------------------------------------------------------------------------
exec('set_gnb id=12 type=external plmn=311:493 ng='..GNB11_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=11 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')

-------------------------op6---------------------------------------------------------------------------
exec('set_gnb id=13 type=external plmn=311:494 ng='..GNB12_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=12 plmnList=311:489,311:490,311:491,311:492,311:493,311:494')


-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec file=AirPhoneConfig.xml  id=1 enable_cus_if=on uec_cus_if_ip=10.0.2.1:40000 ip='..DAEMON_IP..':'..EDAEMON_PORT..' pdn=1 devtype=tun addr=72.22.0.1/26 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')
---------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
for QCI = 128, 148 do
exec('set_qci qci='..QCI..' gbr=no priority=1 delay=80')
end

IMSI_FIRST_UE_SA=21645400
FIRST_UE_SA=1
LAST_UE_SA=6
mnc=489

for UEID = FIRST_UE_SA, LAST_UE_SA do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:'.. mnc + UEID - 1 ..':0000:0:0:0'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end 

for UEID = FIRST_UE_SA, LAST_UE_SA  do
    exec('set_pdu_gateway id='..UEID..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end 


FIRST_UE_LTE = 11
END_UE_LTE = 20
IMSI_FIRST_UE=111111001
QCI = 128
QCI2 = 129
QCI3 = 130
QOS_ID = 2
for UEID = FIRST_UE_LTE, END_UE_LTE do
	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 enb=14 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=311:489:'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096140211807135E0000018800000080 ue_nr_capabilities=E120700047D0FFB17DE8E6BC32001A0349CF9A44F3E0048018807C07C0203F08006F3826807BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0C0200413400FF00000026007C005638280381F84800E07C003968000038000395340006000010600000F2A8284801C003C00D40A80010203038980858808890C860C0D8FA09293139414922A400 ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010') 
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
    exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')  
    exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1') 
    exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
	    QCI = QCI + 1
        if (QCI2 < 147) then 
        QCI2 = QCI2 + 1
        else QCI2 = QCI2 - 1 
        end
		if (QCI3 < 145) then 
		QCI3 = QCI3 + 1 
		else QCI3 = QCI3 - 2 
		end
end

FIRST_UE_NSA = 21
END_UE_NSA = 30
IMSI_FIRST_UE=111111001
QCI = 128
QCI2 = 129
QCI3 = 130
QOS_ID = 2
for UEID = FIRST_UE_NSA, END_UE_NSA do
	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 enb=14 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=311:489:'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096340211807135E0000018800000094408200002100 ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0 ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010') 
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
    exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')  
    exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1') 
    exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
	    QCI = QCI + 1
        if (QCI2 < 147) then 
        QCI2 = QCI2 + 1
        else QCI2 = QCI2 - 1 
        end
		if (QCI3 < 145) then 
		QCI3 = QCI3 + 1 
		else QCI3 = QCI3 - 2
		end
end

exec('qosflow_set id=1 5qi=5 default=on')
exec('qosflow_set id=2 5qi=1')
exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('nwslice_set id=1 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1 amf=1,7')
exec('nwslice_set id=2 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A6 default=on ue=2 amf=2,8')
exec('nwslice_set id=3 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A7 default=on ue=3 amf=3,9')
exec('nwslice_set id=4 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A8 default=on ue=4 amf=4,10')
exec('nwslice_set id=5 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A9 default=on ue=5 amf=5,11')
exec('nwslice_set id=6 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AA default=on ue=6 amf=6,12')
exec('nwslice_set id=7 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AB ue=1 amf=1')
exec('nwslice_set id=8 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AC ue=1 amf=1')
exec('nwslice_set id=9 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143AD ue=1 amf=1')
exec('ue_nr_capabilities id=1 voice_over_nr=on:on:off')
exec('ue_param id=1 nr_usage_setting=voice_centric')
exec('amf_param id=1 ims_voice_3gpp=on')




exec('set_cnode   ip=127.0.0.1:7676')
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

