-- Copyright (c) 2019 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local DAEMON_IP="127.0.0.1"
local DAEMON_PORT="10000"

local ENB1_S1_ADDR="10.0.1.21"
local ENB2_S1_ADDR="10.0.1.22"
local GNB_S1U_ADDR="10.0.1.112"
local GNB_SIM_S1U_ADDR="10.0.1.31"

local ENB1_X2_ADDR="10.0.1.21"
local ENB2_X2_ADDR="10.0.1.22"
local GNB_X2_ADDR="10.0.1.2"
local GNB_SIM_X2_ADDR="10.0.1.31"

local GNB_XN_ADDR="10.0.1.112"
local GNB_SIM_XN_ADDR="10.0.1.31"

local MME1_S1_ADDR="10.0.1.1"

local SERVER_ADDR="192.168.4.132"
local SGW_S1U_ADDR="10.0.1.1"
local SGW_S11_ADDR="10.0.1.1"

local ENB_X2U_ADDR="10.0.1.21"
local ENB2_X2U_ADDR="10.0.1.22"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local ue_id = 0
local imsi_prefix = '250:555:216454'


eea = {"null"}
eia = "null+snow3g+aes"
ue_nr_capa = {"01000000010800000004D780000000000001150000000000000150", "01000000010800000004D780000000000001150000000000000150", "01000000010800000004D780000000000001150000000000000150"}

-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------

print('Adding interface eth3:simeNB1 10.0.1.21')
os.execute('sudo ifconfig eth3:simeNB1 10.0.1.21/24 up')

exec('set_enb id=1 plmn=250:255 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':2154 earfcn=2000:20000 mapped_earfcn=4200:22200')
exec('set_cell id=2 enb=1 eci=0x1234602 pci=4:2 tac=222 proxy='..DAEMON_IP..':2155 earfcn=2100:20100')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--ENB SIM TARGET CONFIGURATION
-----------------------------------------------------------------------------------------------------

print('Adding interface eth3:simeNB2 10.0.1.22')
os.execute('sudo ifconfig eth3:simeNB2 10.0.1.22/24 up')

exec('set_enb id=4 plmn=250:255 s1='..ENB2_S1_ADDR..' enb_id_macro=0x12345 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB2_X2_ADDR..' x2u='..ENB2_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=4 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=4 eci=0x1234501 pci=0:1 tac=222 proxy='..DAEMON_IP..':2156 earfcn=2000:20000 mapped_earfcn=4200:22200')
exec('enb_endc_param id=4 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
print('Adding interface eth3:simgNB1 10.0.1.31')
os.execute('sudo ifconfig eth3:simgNB1 10.0.1.31/24 up')
exec('set_gnb id=2 type=external plmn=250:255 gnb_id=0x4 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 x2_peers=1 xn='..GNB_XN_ADDR)
exec('set_cell id=1 gnb=2 nr_arfcn=135760:126380  pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=off mandatory_for_activation=on')
exec('set_cell id=2 gnb=2 nr_arfcn=135760:126380  pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=off mandatory_for_activation=on')

-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=250:255 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..':2152 s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' gtpu=off pdn=1 devtype=tun addr=11.7.255.254/16 peer=10.0.2.1:2152 retries=unlimited')
-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
for eea_index=1,table.getn(eea) do
	for capa_index=1,10 do
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
		local ue_eutra_nr_capabilities = 'BD1BA063058380711800000018062B000060400C1001830030600E230000010300C160801C46000006060182C000388C00000C0C0305810070A000001018060B0600E23000002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080401008020100402010040200804010080000004020080400000000000402000000000000000040200804010080201000000080401008000000000008040000000000000000804010080201004020080400000020100402008040000000000000000804000000000000000000001009C0020200804008080101000000040400808000000000004040000000000000000402010040100802010040200804010080201004020080401008020100402008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004040000000000020200404000000000002020000000000000000202700100802010040200000010080201000000080400000000000402000000000002010040200804000000201004020000001008000000000008040000000000040100802010040200804010080201004020080401008020100402008040100804010080201000000080401008000000402000000100800000040200000000000201000000000001009C0020200404008080101002020000000808010100202000000000001010000000404008080101002020040400000010100202004040000000000020200000008080101002020040400808000000202004040080800000000000404000000100802010040200804010080201004020080401008020100402008040100802010040200804010080401700100801010000000404008080000000000000000808000000000000000000002010020200000008080101000000000000000010100000000000000000000040200404000000101002020000000000000000202000000000000000000000804008080000002020040400808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004'
		local ue_nr_capabilities = 'e1201000014f5e0302c00201404820d9c4c3e140426c020ffcc31e50b03826010188a01014c200141f11b586368e9315047f2ca4d940220b64c1203063c63ff30c7942c0e070f0113804e0001083011b9343e01c8200000148200000548200000949280000d300f81b7953781b5bac0141000009652504000065949410000296525040000e594941000049652524000154b29280ba07974ab2e81e4d2ac9a55915dc8020f00340201000000100'

		exec('set_ue simulated id='..ue_id..
			 ' uec='..uec..
			 ' release='..release..
			 ' idle_edrx_cycle_len='..idle_edrx_cycle_len..
			 ' ptw='..ptw..
			 ' sec_key='..ue_sec_key..
			 ' eea='..eea[eea_index]..
			 ' eia='..eia..
			 ' nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc'..
			 ' imsi='..imsi)
		exec('ue_param id='..ue_id..
			 ' ue_nr_capabilities='..ue_nr_capabilities..
			 ' dual_conn='..dual_conn..
			 ' ue_eutra_nr_capabilities='..ue_eutra_nr_capabilities)
        local ue_ip = 207 + ue_id
        exec('set_bearer id=2 ue='..ue_id..' qci=9 pdn=1 ip=4.7.254.'..ue_ip..' default=on trf_type=internal')
        exec('set_bearer id=3 ue='..ue_id..' default=off preprovisioned=on filter=1 precedence=8 qci=8')
	end
end

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------


exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('uec_param id=1 reordering_window_size=50 reordering_timer=200')

exec('cfg_end')

exec('set_log log_to_file=true max_file_num=1')
