-- Copyright (c) 2019 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT="22222"


GNB1_NGC_ADDR="10.0.3.2"
GNB2_NGC_ADDR="fc00::3:2"
GNB3_NGC_ADDR="10.0.3.4"
GNB4_NGC_ADDR="fc00::3:4"
GNB5_NGC_ADDR="10.0.3.6"
GNB6_NGC_ADDR="fc00::3:6"
GNB7_NGC_ADDR="10.0.3.8"
GNB8_NGC_ADDR="fc00::3:8"
GNB9_NGC_ADDR="10.0.3.10"
GNB10_NGC_ADDR="fc00::3:a"
GNB11_NGC_ADDR="10.0.3.12"
GNB12_NGC_ADDR="fc00::3:c"
GNB13_NGC_ADDR="10.0.3.14"
GNB14_NGC_ADDR="fc00::3:e"
GNB15_NGC_ADDR="10.0.3.16"
GNB16_NGC_ADDR="fc00::3:10"
GNB17_NGC_ADDR="10.0.3.18"
GNB18_NGC_ADDR="fc00::3:12"
GNB19_NGC_ADDR="10.0.3.20"
GNB20_NGC_ADDR="fc00::3:14"

GNB1_NGC2_ADDR="10.0.3.3"
GNB2_NGC2_ADDR="fc00::3:3"
GNB3_NGC2_ADDR="10.0.3.5"
GNB4_NGC2_ADDR="fc00::3:5"
GNB5_NGC2_ADDR="10.0.3.7"
GNB6_NGC2_ADDR="fc00::3:7"
GNB7_NGC2_ADDR="10.0.3.9"
GNB8_NGC2_ADDR="fc00::3:9"
GNB9_NGC2_ADDR="10.0.3.11"
GNB10_NGC2_ADDR="fc00::3:b"
GNB11_NGC2_ADDR="10.0.3.13"
GNB12_NGC2_ADDR="fc00::3:d"
GNB13_NGC2_ADDR="10.0.3.15"
GNB14_NGC2_ADDR="fc00::3:f"
GNB15_NGC2_ADDR="10.0.3.17"
GNB16_NGC2_ADDR="fc00::3:11"
GNB17_NGC2_ADDR="10.0.3.19"
GNB18_NGC2_ADDR="fc00::3:13"
GNB19_NGC2_ADDR="10.0.3.21"
GNB20_NGC2_ADDR="fc00::3:15"


PROXY_SERVER_IP="10.0.2.80"

AMF1_NG_ADDR="10.0.3.131"
AMF3_NG_ADDR="10.0.3.133"
AMF5_NG_ADDR="10.0.3.135"
AMF7_NG_ADDR="10.0.3.137"
AMF9_NG_ADDR="10.0.3.139"
AMF11_NG_ADDR="10.0.3.141"
AMF13_NG_ADDR="10.0.3.143"
AMF15_NG_ADDR="10.0.3.145"
AMF17_NG_ADDR="10.0.3.147"
AMF19_NG_ADDR="10.0.3.149"

AMF2_NG_ADDR="fc00::3:83"
AMF4_NG_ADDR="fc00::3:85"
AMF6_NG_ADDR="fc00::3:87"
AMF8_NG_ADDR="fc00::3:89"
AMF10_NG_ADDR="fc00::3:8b"
AMF12_NG_ADDR="fc00::3:8d"
AMF14_NG_ADDR="fc00::3:8f"
AMF16_NG_ADDR="fc00::3:91"
AMF18_NG_ADDR="fc00::3:93"
AMF20_NG_ADDR="fc00::3:95"

AMF1_NG2_ADDR="10.0.3.132"
AMF3_NG2_ADDR="10.0.3.134"
AMF5_NG2_ADDR="10.0.3.136"
AMF7_NG2_ADDR="10.0.3.138"
AMF9_NG2_ADDR="10.0.3.140"
AMF11_NG2_ADDR="10.0.3.142"
AMF13_NG2_ADDR="10.0.3.144"
AMF15_NG2_ADDR="10.0.3.146"
AMF17_NG2_ADDR="10.0.3.148"
AMF19_NG2_ADDR="10.0.3.150"

AMF2_NG2_ADDR="fc00::3:84"
AMF4_NG2_ADDR="fc00::3:86"
AMF6_NG2_ADDR="fc00::3:88"
AMF8_NG2_ADDR="fc00::3:8a"
AMF10_NG2_ADDR="fc00::3:8c"
AMF12_NG2_ADDR="fc00::3:8e"
AMF14_NG2_ADDR="fc00::3:90"
AMF16_NG2_ADDR="fc00::3:92"
AMF18_NG2_ADDR="fc00::3:94"
AMF20_NG2_ADDR="fc00::3:96"

AMF1_NGU_ADDR="10.0.5.131"
AMF3_NGU_ADDR="10.0.5.132"
AMF5_NGU_ADDR="10.0.5.133"
AMF7_NGU_ADDR="10.0.5.134"
AMF9_NGU_ADDR="10.0.5.135"
AMF11_NGU_ADDR="10.0.5.136"
AMF13_NGU_ADDR="10.0.5.137"
AMF15_NGU_ADDR="10.0.5.138"
AMF17_NGU_ADDR="10.0.5.139"
AMF19_NGU_ADDR="10.0.5.140"

AMF2_NGU_ADDR="fc00::5:83"
AMF4_NGU_ADDR="fc00::5:84"
AMF6_NGU_ADDR="fc00::5:85"
AMF8_NGU_ADDR="fc00::5:86"
AMF10_NGU_ADDR="fc00::5:87"
AMF12_NGU_ADDR="fc00::5:88"
AMF14_NGU_ADDR="fc00::5:89"
AMF16_NGU_ADDR="fc00::5:8a"
AMF18_NGU_ADDR="fc00::5:8b"
AMF20_NGU_ADDR="fc00::5:8c"


UEC_ADDR="72.22.0.1"

UPF1_ADDR="1.2.4.1"
UPF2_ADDR="1.2.5.1"
UPF3_ADDR="1.2.6.1"
UPF4_ADDR="1.2.7.1"
UPF5_ADDR="1.2.8.1"
UPF6_ADDR="1.2.9.1"
UPF7_ADDR="1.2.10.1"
UPF8_ADDR="1.2.11.1"
UPF9_ADDR="1.2.12.1"
UPF10_ADDR="1.2.13.1"
UPF11_ADDR="1.2.14.1"
UPF12_ADDR="1.2.15.1"
UPF13_ADDR="1.2.16.1"
UPF14_ADDR="1.2.17.1"
UPF15_ADDR="1.2.18.1"
UPF16_ADDR="1.2.19.1"
UPF17_ADDR="1.2.20.1"
UPF18_ADDR="1.2.21.1"
UPF19_ADDR="1.2.22.1"
UPF20_ADDR="1.2.23.1"


---- Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.5.2"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2C_ADDR="10.0.5.2"
GNB_X2U_ADDR="10.0.5.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP1="4.7.254.1"
PDN_IP2="4.7.254.2"

-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
------------------------IPv4----------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 ng_multihome_ip='..AMF1_NG2_ADDR..' region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..AMF1_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF1')

exec('set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:490')
exec('set_amf id=3 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF3_NG_ADDR..':38412 ng_multihome_ip='..AMF3_NG2_ADDR..' region=2 set_id=2 pointer=2')
exec('amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=3 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/24 ngu='..AMF3_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF2')

exec('set_amf_region id=3 tac_list=7627107,100,788,200,0 plmn=311:491')
exec('set_amf id=5 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF5_NG_ADDR..':38412 ng_multihome_ip='..AMF5_NG2_ADDR..' region=3 set_id=2 pointer=2')
exec('amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=5 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF3_ADDR..'/24 ngu='..AMF5_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF3')

exec('set_amf_region id=4 tac_list=7627107,100,788,200,0 plmn=311:492')
exec('set_amf id=7 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF7_NG_ADDR..':38412 ng_multihome_ip='..AMF7_NG2_ADDR..' region=4 set_id=2 pointer=2')
exec('amf_param id=7 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=7 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF4_ADDR..'/24 ngu='..AMF7_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF4')

exec('set_amf_region id=5 tac_list=7627107,100,788,200,0 plmn=311:493')
exec('set_amf id=9 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF9_NG_ADDR..':38412 ng_multihome_ip='..AMF9_NG2_ADDR..' region=5 set_id=2 pointer=2')
exec('amf_param id=9 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=9 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF5_ADDR..'/24 ngu='..AMF9_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF5')

exec('set_amf_region id=6 tac_list=7627107,100,788,200,0 plmn=311:494')
exec('set_amf id=11 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF11_NG_ADDR..':38412 ng_multihome_ip='..AMF11_NG2_ADDR..' region=6 set_id=2 pointer=2')
exec('amf_param id=11 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=11 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF6_ADDR..'/24 ngu='..AMF11_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF6')

exec('set_amf_region id=7 tac_list=7627107,100,788,200,0 plmn=311:495')
exec('set_amf id=13 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF13_NG_ADDR..':38412 ng_multihome_ip='..AMF13_NG2_ADDR..' region=7 set_id=2 pointer=2')
exec('amf_param id=13 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=13 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF13_ADDR..'/24 ngu='..AMF13_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF13')

exec('set_amf_region id=8 tac_list=7627107,100,788,200,0 plmn=311:496')
exec('set_amf id=15 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF15_NG_ADDR..':38412 ng_multihome_ip='..AMF15_NG2_ADDR..' region=8 set_id=2 pointer=2')
exec('amf_param id=15 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=15 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF15_ADDR..'/24 ngu='..AMF15_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF15')

exec('set_amf_region id=9 tac_list=7627107,100,788,200,0 plmn=311:497')
exec('set_amf id=17 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF17_NG_ADDR..':38412 ng_multihome_ip='..AMF17_NG2_ADDR..' region=9 set_id=2 pointer=2')
exec('amf_param id=17 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=17 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF17_ADDR..'/24 ngu='..AMF17_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF17')

exec('set_amf_region id=10 tac_list=7627107,100,788,200,0 plmn=311:498')
exec('set_amf id=19 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF19_NG_ADDR..':38412 ng_multihome_ip='..AMF19_NG2_ADDR..' region=10 set_id=2 pointer=2')
exec('amf_param id=19 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=19 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF19_ADDR..'/24 ngu='..AMF19_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF19')

-------------------------IPv6------------------------------

exec('set_amf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF2_NG_ADDR..'.38412 ng_multihome_ip='..AMF2_NG2_ADDR..' region=1 set_id=3 pointer=3')
exec('amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF7_ADDR..'/24 ngu='..AMF2_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF7')

exec('set_amf id=4 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF4_NG_ADDR..'.38412 ng_multihome_ip='..AMF4_NG2_ADDR..' region=2 set_id=3 pointer=3')
exec('amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=4 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF8_ADDR..'/24 ngu='..AMF4_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF8')

exec('set_amf id=6 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF6_NG_ADDR..'.38412 ng_multihome_ip='..AMF6_NG2_ADDR..' region=3 set_id=3 pointer=3')
exec('amf_param id=6 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=6 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF9_ADDR..'/24 ngu='..AMF6_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF9')

exec('set_amf id=8 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF8_NG_ADDR..'.38412 ng_multihome_ip='..AMF8_NG2_ADDR..' region=4 set_id=3 pointer=3')
exec('amf_param id=8 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=8 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF10_ADDR..'/24 ngu='..AMF8_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF10')

exec('set_amf id=10 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF10_NG_ADDR..'.38412 ng_multihome_ip='..AMF10_NG2_ADDR..' region=5 set_id=3 pointer=3')
exec('amf_param id=10 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=10 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF11_ADDR..'/24 ngu='..AMF10_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF11')

exec('set_amf id=12 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF12_NG_ADDR..'.38412 ng_multihome_ip='..AMF12_NG2_ADDR..' region=6 set_id=3 pointer=3')
exec('amf_param id=12 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=12 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF12_ADDR..'/24 ngu='..AMF12_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF12')

exec('set_amf id=14 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF14_NG_ADDR..'.38412 ng_multihome_ip='..AMF14_NG2_ADDR..' region=7 set_id=3 pointer=3')
exec('amf_param id=14 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=14 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF14_ADDR..'/24 ngu='..AMF14_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF14')

exec('set_amf id=16 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF16_NG_ADDR..'.38412 ng_multihome_ip='..AMF16_NG2_ADDR..' region=8 set_id=3 pointer=3')
exec('amf_param id=16 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=16 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF16_ADDR..'/24 ngu='..AMF16_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF16')

exec('set_amf id=18 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF18_NG_ADDR..'.38412 ng_multihome_ip='..AMF18_NG2_ADDR..' region=9 set_id=3 pointer=3')
exec('amf_param id=18 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=18 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF18_ADDR..'/24 ngu='..AMF18_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF18')

exec('set_amf id=20 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF20_NG_ADDR..'.38412 ng_multihome_ip='..AMF20_NG2_ADDR..' region=10 set_id=3 pointer=3')
exec('amf_param id=20 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=20 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF20_ADDR..'/24 ngu='..AMF20_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10 devname=tunUPF20')

--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
exec('smf_upf_mapping id=1 upf=1 id=2 upf=2 id=3 upf=3 id=4 upf=4 id=5 upf=5 id=6 upf=6 id=7 upf=7 id=8 upf=8 id=9 upf=9 id=10 upf=10 id=11 upf=11 id=12 upf=12 id=13 upf=13 id=14 upf=14 id=15 upf=15 id=16 upf=16 id=17 upf=17 id=18 upf=18 id=19 upf=19 id=20 upf=20')
-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2C_ADDR..':36422 ng='..GNB1_NGC_ADDR..' ng_multihome_ip='..GNB1_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_gnb id=3 type=external plmn=311:490 ng='..GNB3_NGC_ADDR..' ng_multihome_ip='..GNB3_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=3 plmnList=311:490 nssai=0x1:0xd143a6')
exec('set_gnb id=4 type=external plmn=311:491 ng='..GNB5_NGC_ADDR..' ng_multihome_ip='..GNB5_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=5 plmnList=311:491 nssai=0x1:0xd143a7')
exec('set_gnb id=5 type=external plmn=311:492 ng='..GNB7_NGC_ADDR..' ng_multihome_ip='..GNB7_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=7 plmnList=311:492 nssai=0x1:0xd143a8')
exec('set_gnb id=6 type=external plmn=311:493 ng='..GNB9_NGC_ADDR..' ng_multihome_ip='..GNB9_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=9 plmnList=311:493 nssai=0x1:0xd143a9')
exec('set_gnb id=7 type=external plmn=311:494 ng='..GNB11_NGC_ADDR..' ng_multihome_ip='..GNB11_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=11 plmnList=311:494 nssai=0x1:0xd143aa')
exec('set_gnb id=14 type=external plmn=311:495 ng='..GNB13_NGC_ADDR..' ng_multihome_ip='..GNB13_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=13 plmnList=311:495 nssai=0x1:0xd143ab')
exec('set_gnb id=16 type=external plmn=311:496 ng='..GNB15_NGC_ADDR..' ng_multihome_ip='..GNB15_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=15 plmnList=311:496 nssai=0x1:0xd143ac')
exec('set_gnb id=18 type=external plmn=311:497 ng='..GNB17_NGC_ADDR..' ng_multihome_ip='..GNB17_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=17 plmnList=311:497 nssai=0x1:0xd143ad')
exec('set_gnb id=20 type=external plmn=311:498 ng='..GNB19_NGC_ADDR..' ng_multihome_ip='..GNB19_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=19 plmnList=311:498 nssai=0x1:0xd143ae')


exec('set_gnb id=8 type=external plmn=311:489 ng='..GNB2_NGC_ADDR..' ng_multihome_ip='..GNB2_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=2 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_gnb id=9 type=external plmn=311:490 ng='..GNB4_NGC_ADDR..' ng_multihome_ip='..GNB4_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=4 plmnList=311:490 nssai=0x1:0xd143a6')
exec('set_gnb id=10 type=external plmn=311:491 ng='..GNB6_NGC_ADDR..' ng_multihome_ip='..GNB6_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=6 plmnList=311:491 nssai=0x1:0xd143a7')
exec('set_gnb id=11 type=external plmn=311:492 ng='..GNB8_NGC_ADDR..' ng_multihome_ip='..GNB8_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=8 plmnList=311:492 nssai=0x1:0xd143a8')
exec('set_gnb id=12 type=external plmn=311:493 ng='..GNB10_NGC_ADDR..' ng_multihome_ip='..GNB10_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=10 plmnList=311:493 nssai=0x1:0xd143a9')
exec('set_gnb id=13 type=external plmn=311:494 ng='..GNB12_NGC_ADDR..' ng_multihome_ip='..GNB12_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=12 plmnList=311:494 nssai=0x1:0xd143aa')
exec('set_gnb id=15 type=external plmn=311:495 ng='..GNB14_NGC_ADDR..' ng_multihome_ip='..GNB14_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=14 plmnList=311:495 nssai=0x1:0xd143ab')
exec('set_gnb id=17 type=external plmn=311:496 ng='..GNB16_NGC_ADDR..' ng_multihome_ip='..GNB16_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=16 plmnList=311:496 nssai=0x1:0xd143ac')
exec('set_gnb id=19 type=external plmn=311:497 ng='..GNB18_NGC_ADDR..' ng_multihome_ip='..GNB18_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=18 plmnList=311:497 nssai=0x1:0xd143ad')
exec('set_gnb id=21 type=external plmn=311:498 ng='..GNB20_NGC_ADDR..' ng_multihome_ip='..GNB20_NGC2_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=20 plmnList=311:498 nssai=0x1:0xd143ae')

exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
IMSI_FIRST_UE_SA=21645400
IMSI_FIRST_UE=111111001
FIRST_UE_SA=1
LAST_UE_SA=6
mnc=489

for UEID = 1, 6 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:'.. mnc + UEID - 1 ..':0000:0:0:0'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

for UEID = 11, 16 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:'.. mnc + UEID - 11 ..':0000:0:0:0'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

mnc2=495

for UEID = 7, 10 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:'.. mnc2 + UEID - 7 ..':0000:0:0:1'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

for UEID = 17, 20 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:'.. mnc2 + UEID - 17 ..':0000:0:0:1'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end


for ID = 1, 40 do
	exec('set_pdu_gateway id='..ID..' ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
end


--UE Id=51 NSA OP1
exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
exec('set_ue simulated id=51 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=405:030:21645400')
exec('ue_param id=51 ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801') 
exec('set_bearer id=2 ue=51 qci=9 pdn=1 ip='..PDN_IP1..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')

--UE Id=52 NSA OP2
exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
exec('set_ue simulated id=52 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=405:031:21645400')
exec('ue_param id=52 ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801')
exec('set_bearer id=2 ue=52 qci=9 pdn=1 ip='..PDN_IP1..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')

-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
--set_nwslice id=1 snssai=0x01:0xd143a5             amf=1 default=on ue=all

--add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1,11 amf=1,2')
exec('nwslice_set id=2 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A6 default=on ue=2,12 amf=3,4')
exec('nwslice_set id=3 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A7 default=on ue=3,13 amf=5,6')
exec('nwslice_set id=4 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A8 default=on ue=4,14 amf=7,8')
exec('nwslice_set id=5 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A9 default=on ue=5,15 amf=9,10')
exec('nwslice_set id=6 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143AA default=on ue=6,16 amf=11,12')
exec('nwslice_set id=7 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143AB default=on ue=7,17 amf=13,14')
exec('nwslice_set id=8 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143AC default=on ue=8,18 amf=15,16')
exec('nwslice_set id=9 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143AD default=on ue=9,19 amf=17,18')
exec('nwslice_set id=10 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143AE default=on ue=10,20 amf=19,20')


exec('set_pdu_gateway id=11 ue_nat_ip=72.23.0.11 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=12 ue_nat_ip=72.23.0.12 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

-----------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')

