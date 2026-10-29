-- Copyright (c) 2019 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local DAEMON_IP="127.0.0.1"
local DAEMON_PORT="10000"

local ENB1_S1_ADDR="10.0.1.1"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.1"
local GNB_X2_ADDR="10.0.1.111"

local MME1_S1_ADDR="10.0.1.1"

local SERVER_ADDR="192.168.4.132"
local SGW_S1U_ADDR="10.0.1.21"
local SGW_S11_ADDR="10.0.1.21"

local ENB_X2U_ADDR="10.0.1.1"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local AP_CONIG_FILE="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/config/nsa_tdd_cmWv/AirPhoneConfig_tdd_nsa_2c.xml"

local ue_id = 0
local imsi_prefix = '250:555:216454'

eea = "aes"
eia = "aes"


ue_nr_capa = {"21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054"}

-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=250:255 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':2154 earfcn=2000:20000 mapped_earfcn=4200:22200')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=250:255 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 x2_peers=1')
exec('set_cell id=1 gnb=2 nr_arfcn=628334:628334 eci=0x000021f pci=16:2 tac=4 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF tdd_cell=on')
exec('set_cell id=2 gnb=2 nr_arfcn=628334:628334 eci=0x000021f pci=17:0 tac=4 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF tdd_cell=on')
-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=250:255 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' gtpu=off pdn=1 devtype=tun addr=11.7.255.254/16'..
' peer=10.0.2.1:2152 proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608 retries=unlimited file='..AP_CONIG_FILE)

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
	for capa_index=1,table.getn(ue_nr_capa) do
		ue_id = ue_id + 1
		print(ue_id)

		local ue_id_aligned
		if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
		elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
		end

		local uec = '1'
		local release = '15'
		local idle_edrx_cycle_len = '2'
		local ptw = '2.56'
		local ue_sec_key = '0102030405060708090A0B0C0D0EFF00'
		local imsi = imsi_prefix..ue_id_aligned

		local dual_conn = 'eutra_nr'
		local ue_eutra_nr_capabilities = 'A1018090201209A0008800804809A2000200020100801002'

		exec('set_ue simulated id='..ue_id..
			 ' uec='..uec..
			 ' release='..release..
			 ' idle_edrx_cycle_len='..idle_edrx_cycle_len..
			 ' ptw='..ptw..
			 ' sec_key='..ue_sec_key..
			 ' eea='..eea..
			 ' eia='..eia..
                         ' nea='..eea..
			 ' nia='..eia..
			 ' imsi='..imsi)
		exec('ue_param id='..ue_id..
			 ' ue_nr_capabilities='..ue_nr_capa[capa_index]..
			 ' dual_conn='..dual_conn..
			 ' ue_eutra_nr_capabilities='..ue_eutra_nr_capabilities)
	end



-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_bearer id=2 ue=1-'..ue_id..' qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal')

exec('debug_log level=6')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('uec_param id=1 reordering_window_size=50 reordering_timer=200')

exec('cfg_end')

exec('set_log log_to_file=true max_file_num=1')
