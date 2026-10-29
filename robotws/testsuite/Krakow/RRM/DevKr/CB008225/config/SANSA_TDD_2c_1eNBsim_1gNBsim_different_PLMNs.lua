-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local DAEMON_IP="10.0.2.1"
local DAEMON_PORT="10000"
local SERVER_IP=DAEMON_IP

local GNB_NG_ADDR="10.0.1.2"
local GNB_X2_ADDR=GNB_NG_ADDR
local GNB_XN_ADDR=GNB_NG_ADDR
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local ENB1_S1_ADDR="10.0.1.20"
local ENB1_X2_ADDR="10.0.1.21"
local ENB1_X2U_ADDR="10.0.1.21"
local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local GNB_SIM_X2_ADDR="10.0.1.32"
local GNB_SIM_S1U_ADDR="10.0.1.33"
local AMF_NG_ADDR="10.0.1.1"
local AMF_NG_ADDR_2="10.0.1.12"

local MME1_S1_ADDR="10.0.1.11"
local SGW_S1U_ADDR=MME1_S1_ADDR
local SGW_S11_ADDR=MME1_S1_ADDR

local PDN_IP="4.7.254.208"

require('os')
os.execute('sudo ifconfig eth3:WTS1 add '..ENB1_S1_ADDR)
os.execute('sudo ifconfig eth3:WTS2 add '..ENB1_X2_ADDR)
os.execute('sudo ifconfig eth3:AMF add '..AMF_NG_ADDR)
os.execute('sudo ifconfig eth3:AMF2 add '..AMF_NG_ADDR_2)
os.execute('sudo ifconfig eth3:MME1 add '..MME1_S1_ADDR)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth3:gNB3_X2 add '..GNB_SIM_X2_ADDR)
os.execute('sudo ifconfig eth3:gNB3_S1U add '..GNB_SIM_S1U_ADDR)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=1,100,200,201,788,0 plmn=311:489')
exec('set_amf_region id=2 tac_list=1,100,200,201,788,0 plmn=311:490')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('set_amf id=2 name=AMF2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR_2..':38412 region=2 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

-----------------------------------------------------------------------------------------------------
--EPCSIM CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..':2152 s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--ENB1 sim CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB1_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 plmnList=311:489,311:490 ng='..GNB_NG_ADDR..' gnb_id=0x1 daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=all')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 s1u='..GNB_SIM_S1U_ADDR..' ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D x2='..GNB_SIM_X2_ADDR..':36422 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=1 xn='..GNB_SIM_XN_ADDR..':38423 nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=17:1 tac=1 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..DAEMON_PORT..' gscn=8019 nr_arfcn=650000:650000 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s measEvent=A3')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
-- bandNR: 77, 78
-- UE-NR-Capability-v1530.inactiveState = supported
-- UE-NR-Capability-v1610.powSav-Parameters-r16.powSav-ParametersCommon-r16.releasePreference-r16 = supported
local UE_SA_COUNT=9
for i=1,UE_SA_COUNT do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=21A000000109002800C4CAA2FFCBFF400626D517FE5FF81081C4C0000000881C4D0000020A6F00400000000000000010051508A800400000000000040102A02A004002004008004010020A26A510000210')
end

exec('set_ue simulated id=10 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:490:0020:0:0:021645420 enb=2 cell=1')
exec('ue_param id=10 ue_nr_capabilities=21A000000109002800C4CAA2FFCBFF400626D517FE5FF81081C4C0000000881C4D0000020A6F00400000000000000010051508A800400000000000040102A02A004002004008004010020A26A510000210')

local UE_NSA_COUNT=10
for i=UE_NSA_COUNT+1,2*UE_NSA_COUNT do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=250:555:216455'..(i+10))
    exec('ue_param id='..i..' ue_nr_capabilities=21A000000109002800C4CAA2FFCBFF400626D517FE5FF81081C4C0000000881C4D0000020A6F00400000000000000010051508A800400000000000040102A02A004002004008004010020A26A510000210')
    exec('ue_param id='..i..' dual_conn=eutra_nr ue_eutra_nr_capabilities=BD1BA013098180713000389A0000000C0122F140010000804020040080802004')

    local ue_pdn_ip = 207 + i
	exec('set_bearer id=2 ue='..i..' qci=9 pdn=1 ip=4.7.254.'..ue_pdn_ip..' default=on trf_type=internal')
	exec('set_bearer id=3 ue='..i..' default=off preprovisioned=on filter=1 precedence=8 qci=8')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=1 ue=all')
exec('set_qosflow id=4 5qi=4 ue=all')
exec('set_qosflow id=5 5qi=5 default=on')
exec('set_qosflow id=8 5qi=8 ue=all')
exec('set_qosflow id=9 5qi=9 ue=all')

exec('qosrule_set id=1 proto=tcp qos_flow=5')
exec('qosrule_set id=2 proto=udp qos_flow=1')
exec('qosrule_set id=3 proto=udp qos_flow=9')
exec('qosrule_set id=4 proto=udp qos_flow=4')
exec('qosrule_set id=5 proto=udp qos_flow=8')

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1-2 qos_flows=1,4,5,8,9 qos_rules=1,2,3,4,5')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1-2 qos_flows=1,5,9 qos_rules=1,2,3')

local UE_GW_COUNT=100

for i=1,UE_GW_COUNT do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('start version_check=off')
