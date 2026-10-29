-- Copyright (c) 2022 Nokia. All rights reserved.
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
local PROXY3_SERVER_IP="10.0.2.91"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local ENB1_S1_ADDR="10.0.1.20"
local ENB1_X2_ADDR="10.0.1.21"
local ENB1_X2U_ADDR="10.0.1.21"
local AMF1_NG_ADDR="10.0.1.1"

local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local AMF1_NG_ADDR="10.0.1.1"

local MME1_S1_ADDR="10.0.1.11"
local SGW_S1U_ADDR=MME1_S1_ADDR
local SGW_S11_ADDR=MME1_S1_ADDR


require('os')
os.execute('sudo sysctl -w net.sctp.rto_min=400')
os.execute('sudo ifconfig eth3:AMF1 add '..AMF1_NG_ADDR)
os.execute('sudo ifconfig eth3:WTS1 add '..ENB1_S1_ADDR)
os.execute('sudo ifconfig eth3:WTS2 add '..ENB1_X2_ADDR)
os.execute('sudo ifconfig eth3:MME1 add '..MME1_S1_ADDR)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY3_SERVER_IP)

-----------------------------------------------------------------------------------------------------
--EPCSIM CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..':2152 s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,788,0 plmn=311:489')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF1_NG_ADDR.. ' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

-----------------------------------------------------------------------------------------------------
--ENB1 sim CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB1_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=300:18300 tdd_cell=off mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')
exec('enb_endc_param id=1 serving_cell_index_range_scg=8:14')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 x2='..GNB_X2_ADDR..':36422 xn='..GNB_XN_ADDR..':38422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 bwp_arfcn=634002:634002,634662:634662 gscn=7853 mandatory_for_activation=on')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=518598:518598 bwp_arfcn=510606:510606,512586:512586 gscn=6381 mandatory_for_activation=on')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=376000:392000 bwp_arfcn=374056:390056,375028:391028 gscn=4876 mandatory_for_activation=on')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=355000:437000 gscn=5437 mandatory_for_activation=on')

-- ---------------------------------------------------------------------------------------------------
-- --GNB3 sim configuration
-- ---------------------------------------------------------------------------------------------------
-- exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' xn='..GNB_SIM_XN_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none nssai=0x1:0xD143A5 amf=1')
-- exec('set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..DAEMON_PORT..' gscn=7853 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
-- exec('set_cell id=2 gnb=3 pci=17:2 tac=0 nrci=0x02 tdd_cell=off proxy='..PROXY3_SERVER_IP..':'..DAEMON_PORT..' gscn=4876 nr_arfcn=376000:392000 nr_scs=15kHz bs_channel_bandwidth=30MHz')
-- exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s measEvent=A3')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')


-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
for i=1,70 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531802507C4DD618DA3A4C5411FCB29365048082D930480C18F18FFCC31E50B0381C3C045E01781507C28D618DA3A4C5411FCB29365048082D930480C18F18FFCC31E50B0381C3C044FF93FE244006C800008000000170789A001C28000000FF00BFFFFFFFFE006026C028E4D0F80320800000520800001400F236B2A60020800004B29282000032CA4A00E92E5D2ACA1200F003402010000000004040080101004008200')
end

for i=71,100 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:216454'..i..' enb=1 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531802507C4DD618DA3A4C5411FCB29365048082D930480C18F18FFCC31E50B0381C3C045E01781507C28D618DA3A4C5411FCB29365048082D930480C18F18FFCC31E50B0381C3C044FF93FE244006C800008000000170789A001C28000000FF00BFFFFFFFFE006026C028E4D0F80320800000520800001400F236B2A60020800004B29282000032CA4A00E92E5D2ACA1200F003402010000000004040080101004008200'..
    ' dual_conn=eutra_nr'..
    ' ue_eutra_nr_capabilities=A10180B84C000389A001C280000001602E7FFFFFFC01000809B00A0800080002010100200404010020')

	exec('set_bearer id=2 ue='..i..' qci=9 pdn=1 ip=4.7.254.'..i..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
end

for i=1,100 do
	exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.0.'..i..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=2 ue=all gfbr_dl=20000 mfbr_dl=30720 pci=shall_not_trigger_pre_emption pvi=pre_emptable  priority=10')
exec('set_qosflow id=3 5qi=3 ue=all gfbr_dl=20000 mfbr_dl=30720 pci=may_trigger_pre_emption pvi=not_pre_emptable priority=5')
exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('qosrule_set id=3 proto=udp qos_flow=3')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1,2,3 qos_rules=1,2,3')

exec('debug_log level=4')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc off')
exec('sim_trace amf=1 protocol=ng off')
exec('cfg_end')
sleep(1)
exec('set_log log_to_file=on')
exec('start version_check=off')
