---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
NUMBER_OF_UES_SA=10
NUMBER_OF_UES_NSA=10

local EDAEMON_PORT="10000"
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

--VARIABLES for SA configuration

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

--VARIABLES for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=250:255 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..SERVER_IP..':12219|'..SERVER_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=777:14 eq_plmn=250:255 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=8M s5u_rcv_buff_size=8M s1u_snd_buff_size=8M s1u_rcv_buff_size=8M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..SERVER_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=1 amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=518580:518580 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=136620:127420')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=137000:127860')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:21645402')
exec('ue_param id=1 ue_nr_capabilities=E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623803DC6C28C0D608C21A0810748046D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B8002F800E000BE0003801C0A836236B04610D04083C40232B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13F8000000FE00000003801C00550388C080000240A838280388C000004240AC3C28000C2300008240AC1C28080006020EB0F0A000305000040107003011A0140283902C09DB1CF870A74ED8E7C3851276C73E1C089B1CF870A24ED8E7C31E81601E00140E0601C0C01501C0018090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200100C030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E594901000049652404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900C52AABA55554AA2E95455058AA071541A2A94C55268AA031540A2A93555078A022F012A05028140A05028140A05028140A05028140A0502800200040780608080100002018030404008020100C00000203001040400802010020006287C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD050 dual_conn=eutra_nr ue_eutra_nr_capabilities=A11FF82384C0C03850001C46000000122205C160601C46000002022205C2606018280388C00000824440B84C0C038500018460001848881005011A0140030B00CA09127449DB1CF870A74ED80000893A24ED800008806C0000018031000040202004010080600C1000080404030061000040202004000080600C2000080404008020100C0000')
exec('set_bearer id=2 ue=1 qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=8 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('set_log flush')
exec('cfg_end')
sleep(1)
