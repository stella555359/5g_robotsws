-- Copyright (c) 2019 Nokia. All rights reserved.

exec('set_log log_to_file=true max_file_num=1')

os.execute("ulimit -c unlimited")    --To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")    --To enable all types of coredumps on WTS VM

-------------------------------------------------------------------------------------
--IP configuration
--------------------------------------------------------------------------------------
for ip1 = 61, 64 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3')
end

for ip2 = 3, 21 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4')
end

for ip3 = 131, 139 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3')
end

for ip4 = 200, 221 do    --To configure IP 10.0.1.200,.. on eth3
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3')
end

os.execute('sudo sysctl -w net.sctp.rto_min=100')
os.execute('sudo sysctl -w net.sctp.sack_timeout=200')
os.execute('sudo sysctl -w net.sctp.rto_initial=3000')
os.execute('sudo sysctl -w net.sctp.rto_max=60000')
os.execute('sudo sysctl -w net.core.wmem_max=20971520')
os.execute('sudo sysctl -w net.core.wmem_default=20971520')
os.execute('sudo sysctl -w net.core.rmem_max=20971520')
os.execute('sudo sysctl -w net.core.rmem_default=20971520')
os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'TDD'    --Set values as 'FDD or 'TDD' based on your Test Line
Test_UEs = 'SA'    --Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'    --Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet

NUMBER_OF_CELLS = 6   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
UE_COUNT_ON_CELL = 200 --Intra-Loki: 2CELLS per LOKI, supports max 250UE per cell
NSA_UE_COUNT_ON_CELL = 0 --NSA UE Count per cell

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
FIRST_AMF_ID = 1   --Starting AMF id
FIRST_UE_SA_CELL = 1    --Starting SA UEid
FIRST_UE_NSA_CELL = 1    --Starting NSA UEid

UE_GROUP_COUNT = NUMBER_OF_CELLS     --Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = 1500    --Number of Sequence_set groups

END_CELL_ID = FIRST_CELL_ID + NUMBER_OF_CELLS - 1 --End cell id =  FIRST_CELL_ID + NUMBER_OF_CELLS - 1, Ex: = 7+6-1
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
END_UE_SA_CELL = FIRST_UE_SA_CELL + ( NUMBER_OF_CELLS * UE_COUNT_ON_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
END_UE_NSA_CELL = FIRST_UE_NSA_CELL + ( NUMBER_OF_CELLS * NSA_UE_COUNT_ON_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489"    --gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"    --SLICE ID
TAC = 200    --gNB & AMF supported Tracking Area Code
GSCN = 7880    --GSCN value
GSCN_TDD = nil    --GSCN value , set to nil  if no GSCN needed !
GSCN_FDD = nil
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 2    --Total number of SGW/PGW in core network

PERFORMANCE_SRS_ENABLED_CELLS = {1,2,3,4,5,6}        --SRS for CB014680_100UE_with_full_buffer_DL_UL

-------------------------------------------------------------------------------------
--IP TABLES
--------------------------------------------------------------------------------------

AMF_IP_TABLE     = { "10.0.1.1","10.0.1.61","10.0.1.62","10.0.1.63","10.0.1.64", }  --IP table for each AMF

UPF_IP_TABLE     = { "1.2.0.1","1.2.8.1","1.2.16.1","1.2.24.1","1.2.32.1", }  --IP table for each UPF

PCI_TABLE       = { "16:2","17:0","17:1","17:2","18:0","18:1", }
                       -- Cells 50-55 mapped to AP1
                       -- PCI 16:2 = (16x3) + 2 = 50, 17:0 = 51 ...
                       -- Compare with gNB commissioning and align
                       -- with NUMBER_OF_CELLS parameter

NR_ARFCN_TABLE     = {  "635600:635600","642400:642400","649200:649200","635600:635600","642400:642400","649200:649200", }  -- NRARFCN UL:DL for each cell

SGW_S1U_IP_TABLE     = { "10.0.1.132", "10.0.1.134", }  --IP table for each SGW S1U
SGW_S11_IP_TABLE     = { "10.0.1.133", "10.0.1.135", }  --IP table for each SGW S11
PGW_IP_TABLE    =   {  "4.7.0.254", "4.7.128.254", }  --IP table for each PGW
----------------------------------------------------------------------------------------------------
--COMMON VARIABLES for ALL WTS
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
SERVER_IP2="10.0.2.3"
SERVER_IP3="10.0.2.4"
SERVER_IP4="10.0.2.5"
SERVER_IP5="10.0.2.6"
SERVER_IP6="10.0.2.7"
SERVER_IP7="10.0.2.8"
SERVER_IP8="10.0.2.9"
SERVER_IP9="10.0.2.10"
SERVER_IP10="10.0.2.11"
SERVER_IP11="10.0.2.12"
SERVER_IP12="10.0.2.13"

DAEMON_PORT=22222
EDAEMON_PORT="22222"
PROXY_SERVER_IP="10.0.2.80"

GNB_S1U_ADDR="10.0.1.112"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"

UEC1_ADDR="72.21.0.1"
UEC2_ADDR="72.23.0.1"
UEC3_ADDR="72.24.0.1"
UEC4_ADDR="72.25.0.1"
UEC5_ADDR="72.26.0.1"
UEC6_ADDR="72.27.0.1"

AMF1_NG_ADDR="10.0.1.1"
UPF1_ADDR="1.2.6.1"

--additonal AMFs/UPFs
AMF2_NG_ADDR="10.0.1.61"
UPF2_ADDR="1.2.8.1"
AMF3_NG_ADDR="10.0.1.62"
UPF3_ADDR="1.2.24.1"
AMF4_NG_ADDR="10.0.1.63"
UPF4_ADDR="1.2.32.1"
AMF5_NG_ADDR="10.0.1.64"
UPF5_ADDR="1.2.40.1"

----------------------------------------------------------------------------------------------------
-- VARIABLES for MULTI-AIRPHONE support
----------------------------------------------------------------------------------------------------
--LTE definitions
ENB1_X2U_ADDR="10.0.1.136"
ENB1_X2_ADDR="10.0.1.137"
ENB1_S1_ADDR="10.0.1.138"

MME1_S1_ADDR="10.0.1.131"
SGW1_S1U_ADDR="10.0.1.132"
SGW1_S11_ADDR="10.0.1.133"
SGW2_S1U_ADDR="10.0.1.134"
SGW2_S11_ADDR="10.0.1.135"

PGW1_ADDR="4.7.0.254"
PGW2_ADDR="4.7.128.254"

PDN_IP="4.7.0.253"
PDN_IP2="4.7.100.253"
PDN_IP3="4.7.150.253"
PDN_IP4="4.7.200.253"

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
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..'')

local array_id = 1
for cell_id = FIRST_CELL_ID, END_CELL_ID do
    local gscn =nil
	local nrci_i = cell_id
    local nrci_o = string.format("%x", nrci_i)
	local UL_NR_ARFCN, DL_NR_ARFCN = string.match(NR_ARFCN_TABLE[array_id], "(%d+):(%d+)")
    if UL_NR_ARFCN == DL_NR_ARFCN  then
        tdd_flag = 'on'
		if GSCN_TDD ~= nil then
		    gscn = GSCN_TDD
		else gscn = nil
		end
    else
        tdd_flag = 'off'
		if GSCN_FDD ~= nil then
            gscn = GSCN_FDD
        else
		    gscn = nil
        end
    end
	if gscn == nil then
        exec('set_cell id='..cell_id..' gnb=2 pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
    else
        exec('set_cell id='..cell_id..' gnb=2 pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' gscn='..gscn..' mandatory_for_activation=off')
    end
	array_id = array_id + 1
end
----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
if Test_UEs == 'NSA' or Test_UEs == 'Both' then
    exec('mme_pool_area id=1 mmegi=1 plmn='..PLMN..' tac_list=777,111,222,444,333,'..TAC..'')
    exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')

    for sgw_id = 1, CORENETWORK_COUNT do
        exec('set_sgw id='..sgw_id..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_IP_TABLE[sgw_id]..' s11='..SGW_S11_IP_TABLE[sgw_id]..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
        exec('set_pgw id='..sgw_id..' type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
    end
end

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' name=SimModeAMF-AP1'..'-'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
    exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
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
uecid = 1
cellid = FIRST_CELL_ID

if PET_SE_FLAG == 'yes' then
    for ue_group_id = 1, UE_GROUP_COUNT do
        if cellid > END_CELL_ID then
            cellid = FIRST_CELL_ID
        end
        if uecid > UEC_COUNT then
            uecid = 1
        end
        exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.." uec="..uecid.." enb=2 cell="..cellid.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
        cellid = cellid + 1
        uecid = uecid + 1
    end
end

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

QOS_ID = 2
SA_UECID = 1
SA_CELLID = FIRST_CELL_ID
NSA_UECID = 1
NSA_CELLID = FIRST_CELL_ID
NSA_IP1 = 0
NSA_IP2 = 1
ue_group_id = 1

-------------------------------------------------------------------
if Test_UEs == 'SA' or Test_UEs == 'Both' then
    for SA_UEID = FIRST_UE_SA_CELL, END_UE_SA_CELL do
        if SA_CELLID > END_CELL_ID then
            SA_CELLID = FIRST_CELL_ID
        end
        if PET_SE_FLAG == 'yes' then
            exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
            exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
        else
            exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
--        exec('ue_param id='..SA_UEID..' ue_nr_capabilities=UE_CAP capability_file=./capability.cfg')
        end
        if ue_group_id >= UE_GROUP_COUNT then
            ue_group_id = 1
        else
            ue_group_id = ue_group_id + 1
        end
        if SA_UECID >= UEC_COUNT then
            SA_UECID = 1
        else
            SA_UECID = SA_UECID + 1
        end
        SA_CELLID = SA_CELLID + 1
    end

-------------------------------------------------------------------

elseif Test_UEs == 'NSA' or Test_UEs == 'Both' then
    for NSA_UEID = FIRST_UE_NSA_CELL, END_UE_NSA_CELL do
        if NSA_CELLID > END_CELL_ID then
            NSA_CELLID = FIRST_CELL_ID
        end
        if NSA_UECID > UEC_COUNT then
            NSA_UECID = 1
        end
        exec('set_ue simulated id='..NSA_UEID..' uec='..NSA_UECID..' pdn=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. NSA_IMSI + NSA_UEID - 1)
--        exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c8000878180c4034026010180e01951b0a3582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b133582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b137582028688965954c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b13b582028680965944c043d6c10101070ef1c39061c00103278faa8000028000000841c4d00000000202682807008089ec1601800140e0601c0c01601c001a0f8000000000000395340004000025965400d2aba0207000b000000040080118b130001020304050607080b101112131921252627284a0 dual_conn=eutra_nr ue_eutra_nr_capabilities=010C040100904D00000402404D000200020100801002')
        exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=NSA_UE_CAP dual_conn=eutra_nr ue_eutra_nr_capabilities=NSA_UE_EUTRA_CAP capability_file=./capability.cfg')
        if NSA_IP2 == 253 then
            NSA_IP1 = NSA_IP1 + 1
            NSA_IP2 = 1
        end
        exec('set_bearer id=2 ue='..NSA_UEID..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ip=4.7.'..NSA_IP1..'.'..NSA_IP2)
        NSA_UECID = NSA_UECID + 1
        NSA_CELLID = NSA_CELLID + 1
        NSA_IP2 = NSA_IP2 + 1
    end
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('nwslice_set id=1 qos_flows=1 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
if #PERFORMANCE_SRS_ENABLED_CELLS > 0 then
    exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')
    for _, cell in pairs(PERFORMANCE_SRS_ENABLED_CELLS) do
        exec('cell_testmode_set_nr cell_id='..cell..' gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR SA UES
---------------------------------------------------------------------------------------------------
---1208FF/1070FF_24UEs_6cells_DL_UL_1mbps_traffics---
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 1, 6 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=1')    -- mbps=1
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=1')    -- mbps=1
        exec('sleep 86400') --For 24 Hrs
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---1208FF/1070FF_600UEs_6cells_DL_3.6GGb_UL_1.2Gb---
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 7, 12 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=15000 size=1350')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=2000 size=1350')
        exec('sleep 86400') --For 24 Hrs
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end


---1208FF/1070FF_600UEs_6cells_DL_3.6GGb_UL_1.2Gb---
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 13, 13 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=150000 size=1350')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=54000 size=1350')
        exec('sleep 86400') --For 24 Hrs
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---1208FF/1070FF_24UEs_6cells_DL_UL_1mbps_traffics---
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 14, 18 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=1')    -- mbps=1
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=1')    -- mbps=1
        exec('sleep 86400') --For 24 Hrs
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')

-- <PERFORMANCE VRF>
-- exec('trace uec=1 protocol=rrc on')
-- exec('trace uec=1 protocol=nr_rrc on')
-- exec('trace uec=1 protocol=x2 on')
-- exec('sim_trace uec=1-'..UEC_COUNT..' protocol=nr_rrc on')
-- exec('sim_trace amf='..FIRST_AMF_ID..'-'..END_AMF_ID..' protocol=ng on')
--
-- exec('debug_log level=0')
-- exec('sim_debug_log level=0')
-- exec('sim_debug_log level=0 uec=3') --uec id for which you want to enable logs.
-- </PERFORMANCE VRF>

---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled NR_CLUB_PROXY_PROTO_MSGS=enabled TTI=3') --Proxy proto flag enabled
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=5 max_file_num=10 max_log_size=100M')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('sim_start version_check=off')
end