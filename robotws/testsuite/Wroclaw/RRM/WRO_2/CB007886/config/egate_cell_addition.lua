-- Copyright (c) 2019 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local DAEMON_IP="10.0.2.1"
local DAEMON_PORT="10000"

local ENB1_S1_ADDR="10.0.1.1"
local GNB_S1U_ADDR="10.0.1.2"

local ENB1_X2_ADDR="10.0.1.1"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.1"

local SERVER_ADDR="10.0.2.1"
local SGW_S1U_ADDR="10.0.1.21"
local SGW_S11_ADDR="10.0.1.22"

local ENB_X2U_ADDR="10.0.1.1"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local AMF_NG_ADDR="10.0.1.101"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local GNB_NG_ADDR="10.0.1.2"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,1,100,200,201,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_ADDR..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_ADDR..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':2154 earfcn=2000:20000 mapped_earfcn=4200:22200')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
--exec('set_gnb id=2 type=external plmn=250:255 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 x2_peers=1')
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 gnb_id=0x76C daemon='..SERVER_ADDR..':'..DAEMON_PORT..' x2_peers=1 amf=1')

exec('set_cell id=1 gnb=2 nr_arfcn=633364:633364 eci=0x000021f pci=16:2 tac=4 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x1 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=633364:633364 eci=0x0000220 pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x2 tdd_cell=on mandatory_for_activation=off')

--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' gtpu=off pdn=1 devtype=tun addr=11.7.255.254/16 peer=10.0.2.1:2152 tgpool=2013265920 retries=unlimited')
-----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


-------------------------------------------------------------------

--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------

for i=1,25 do
    local odd = 2*i-1
    local even = 2*i
    local odd_ue_id_aligned
    local even_ue_id_aligned

    if (odd>0 and odd<10) then odd_ue_id_aligned = '0'..odd
	elseif (odd>=10 and odd<100) then odd_ue_id_aligned = odd
	end

	if (even>0 and even<10) then even_ue_id_aligned = '0'..even
	elseif (even>=10 and even<100) then even_ue_id_aligned = even
	end

    exec('set_ue simulated id='..odd..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes eea=null nia=null+snow3g+aes nea=null imsi=250:555:216454'..odd_ue_id_aligned)
    exec('set_ue simulated id='..even..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes eea=null nia=null+snow3g+aes nea=null imsi=250:555:216454'..even_ue_id_aligned)
    exec('ue_param id='..odd..' ue_nr_capabilities=21000000010800200004D0000826805404400601BC00000000000008A80000000000000A80 dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040100904D00000402404D10001000100804008010')
    exec('ue_param id='..even..' ue_nr_capabilities=21000000010800200004D0000826803008837800000000000011500000000000001500 dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040100904D00000402404D10001000100804008010')
end


--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=9 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=8')
exec('qosrule_set id=1 proto=tcp qos_flow=3')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=3,2,1 qos_rules=1,2')
exec('set_pdu_gateway id=1 ue_nat_ip=10.1.1.2 dl_nat_gw='..SERVER_ADDR..' ul_nat_gw='..SERVER_ADDR)

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_bearer id=2 ue=1-50 qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal')

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('uec_param id=1 reordering_window_size=50 reordering_timer=200')

exec('cfg_end')

exec('set_log log_to_file=true')
