-- Copyright (c) 2019 Nokia. All rights reserved.

exec('set_log log_to_file=true max_file_num=1')

require "CNI-138433_CA_Sector2_UE_groups_configuration_AP2"
require "CNI-138433_CA_Sector2_SIMULATION_variables_AP2"
os.execute("ulimit -c unlimited")	--To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")	--To enable all types of coredumps on WTS VM
os.execute("ulimit -c unlimited")	--To support unlimited coredump file size on WTS VM
--os.execute("sudo bash -c 'echo 'core_%e' > /proc/sys/kernel/core_pattern'")	--To enable all types of coredumps on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")	--To enable all types of coredumps on WTS VM

-------------------------------------------------------------------------------------
--IP configuration
--------------------------------------------------------------------------------------
for ip1 = 62, 62 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3')
end

for ip2 = 3, 21 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4')
end

for ip3 = 141, 149 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3')
end

for ip4 = 203, 205 do    --To configure IP 10.0.1.200,.. on eth3
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3')
end
--os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA
os.execute('sudo sysctl -w net.sctp.rto_min=100')
os.execute('sudo sysctl -w net.sctp.sack_timeout=200')
os.execute('sudo sysctl -w net.sctp.rto_initial=3000')
os.execute('sudo sysctl -w net.sctp.rto_max=60000')
os.execute('sudo sysctl -w net.core.wmem_max=20971520')
os.execute('sudo sysctl -w net.core.wmem_default=20971520')
os.execute('sudo sysctl -w net.core.rmem_max=20971520')
os.execute('sudo sysctl -w net.core.rmem_default=20971520')
os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

function run_configuration()

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
if Test_UEs == 'NSA' or Test_UEs == 'Both' then
    exec('set_enb id=1 plmn='..PLMN..' s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB1_X2U_ADDR..' type=simulated x2_peers=none')
    exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
    if Test_Tech == 'FDD' then
        tdd_flag = 'off'
    else
        tdd_flag = 'on'
    end
    exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell='..tdd_flag..' mandatory_for_activation=off')
    exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')
end
----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI1..','..SNSSAI2..','..SNSSAI3..','..SNSSAI4..','..SNSSAI5..','..SNSSAI6..'')
exec('gnb_param id=2 rohc_continue=on rohc_profile=rtp,udp')
local array_id = 1
for item=1, #CELL_ID_TABLE do
	local nrci_i = CELL_ID_TABLE[item].cell_id
    local nrci_o = string.format("%x", nrci_i)
    if CELL_ID_TABLE[item].technology == 'FDD' then
		tdd_flag='off'
	else
        tdd_flag='on'
	end
	exec('set_cell id='..CELL_ID_TABLE[item].cell_id..' gnb=2 gscn='..CELL_ID_TABLE[item].gscn..' pci='..CELL_ID_TABLE[item].pci..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..CELL_ID_TABLE[item].nrarfcn..' mandatory_for_activation=off')
	item=item+1
end

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
if Test_UEs == 'NSA' or Test_UEs == 'Both' then
    exec('mme_pool_area id=1 mmegi=1 plmn='..PLMN..' tac_list=777,111,222,444,333,'..TAC..'')
    exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')

    for sgw_id = 1, CORENETWORK_COUNT do
    	exec('set_sgw id='..sgw_id..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_IP_TABLE[sgw_id]..' s11='..SGW_S11_IP_TABLE[sgw_id]..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
    	exec('set_pgw id='..sgw_id..' type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')
    end
end

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' name=SimModeAMF-AP2'..'-'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
    exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on')
    exec('set_upf id='..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[array_id]..'/21 ngu='..AMF_IP_TABLE[array_id]..' devname=tunUPF'..amf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

    exec('smf_upf_mapping id='..amf_id..' upf='..amf_id)
    exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
	array_id = array_id + 1
end

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
UEC_IP2 = UEC_COUNT + 2
UEC_IP = 1

for uec_id = 1, UEC_COUNT do
    exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
end

---------------------------------------------------------------------------------------------------
--UE GROUPS FOR PET_SE
---------------------------------------------------------------------------------------------------

run_ue_configuration() -- This is defined in CB010367_FDD_AP2_UE_groups_configuration


---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=9 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=6')
exec('set_qosflow id=5 5qi=7')
exec('set_qosflow id=6 5qi=128')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
exec('set_qosrule id=4 proto=udp qos_flow=5')
exec('set_qosrule id=5 proto=udp qos_flow=6')
exec('sim_param_set EXTENDED_NWSLICE_TEST_MODE=on')
exec('addl_nwslice_set number_of_slices=6 starting_snssai='..SNSSAI1..' slice_support_list=on amf=1 plmn_list='..PLMN)
exec('addl_nwslice_set number_of_slices=6 starting_snssai='..SNSSAI1..' slice_support_list=on amf=2 plmn_list='..PLMN)
exec('addl_nwslice_set number_of_slices=6 starting_snssai='..SNSSAI1..' slice_support_list=on amf=3 plmn_list='..PLMN)
exec('addl_nwslice_set number_of_slices=6 starting_snssai='..SNSSAI1..' slice_support_list=on amf=4 plmn_list='..PLMN)
exec('addl_nwslice_set number_of_slices=6 starting_snssai='..SNSSAI1..' slice_support_list=on amf=5 plmn_list='..PLMN)
exec('nwslice_set id=1 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai='..SNSSAI1..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')
exec('nwslice_set id=2 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai='..SNSSAI2..' default=off ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')
exec('nwslice_set id=3 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai='..SNSSAI3..' default=off ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')
exec('nwslice_set id=4 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai='..SNSSAI4..' default=off ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')
exec('nwslice_set id=5 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai='..SNSSAI5..' default=off ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')
exec('nwslice_set id=6 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai='..SNSSAI6..' default=off ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')


---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled')
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set TTI=3')
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set purge_buffer_on_full=on')
exec('sim_param_set CM_OPTIMIZATION=on')

---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=6 max_file_num=20 max_log_size=200M')                   --loglevel should be 4
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('sim_start version_check=off')
exec('debug_sim_log level=4 uec=1-6')
exec('debug_sim_log level=4 amf=1-5')
exec('sim_trace uec=1-6 protocol=nr_rrc on')
exec('debug_sim_log level=0 enb=2')
exec('sim_debug_log level=1 app_type=ueproxy')  --debug added
exec('sim_debug_log level=4 app_type=ueproxy')
end

