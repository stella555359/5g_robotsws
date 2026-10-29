-- Copyright (c) 2019 Nokia. All rights reserved.

os.execute("ulimit -c unlimited")
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")

for ip1 = 61, 74 do
    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3')
end

for ip2 = 3, 28 do
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4')
end

for ip3 = 131, 139 do
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3')
end

for ip4 = 200, 214 do
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

os.execute('rm egate_console.log.*')

----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES-- TO BE ALIGNED WITH SPECIFIC TOPOLOGIES
-- TMO UTE TOPOLOGY
----------------------------------------------------------------------------------------------------
Test_Tech = 'Both'  --Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA+NSA'  --Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA' --Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes' --Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Supported = 'yes'

Multi_AP_FLAG = 'no' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 1 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 12 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 12   --Total number of Cells
AMF_COUNT = 6   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
SA_UE_COUNT_PER_CELL = 50 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 0 --NSA UE Count per cell
sim_gNBs = 3

FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 18001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 4     --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = TOTAL_NUMBER_OF_CELLS * 5 --Total Number of Sequence_set groups

END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "310:260"    --gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"    --SLICE ID
TAC = 200   --gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000
NSA_IMSI = 21690000
CORENETWORK_COUNT = 1 --Total number of SGW/PGW in core network
MME_Count = 1 --Total number of MME in core network


FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = 1

LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 92         --93

FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 1           --93
LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 20         --113

FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 1           --114
LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 40          --154

FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA = LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 1           --155
LAST_INTER_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA + 12          --167

FIRST_ATTACH_DETACH_UE_SA = LAST_INTER_gNB_INTER_FREQ_HO_UE_SA + 1                                --168
LAST_ATTACH_DETACH_UE_SA = FIRST_ATTACH_DETACH_UE_SA + 100                             --268

FIRST_ADITIONAL_DRB_ADD_UE_SA = LAST_ATTACH_DETACH_UE_SA + 1                  --269
LAST_ADITIONAL_DRB_ADD_UE_SA  = FIRST_ADITIONAL_DRB_ADD_UE_SA + 30                    --299

FIRST_VONR_DRB_ADD_UE_SA = LAST_ADITIONAL_DRB_ADD_UE_SA + 1                           --300
LAST_VONR_DRB_ADD_UE_SA = FIRST_VONR_DRB_ADD_UE_SA + 89                               --389

FIRST_STATE_TRASITION_UE_SA = LAST_VONR_DRB_ADD_UE_SA + 1                               --390
LAST_STATE_TRASITION_UE_SA = FIRST_STATE_TRASITION_UE_SA + 110                        --500
-------------------------------------------------------------------------------------
--IP TABLES
--------------------------------------------------------------------------------------
Multi_AP_IP_TABLE   = { "10.0.2.80",
                        }  --IP table for each UPF

CELL_ID_TABLE_FOR_AP1   = { 1,
                            2,
                            3,
                            4,
                            5,
                            6,
                            7,
                            8,
                            9,
                            10,
                            11,
                            12,
                            }   --Cells belong to Airphone-1

CELL_TECH_TABLE_OF_AP1  = { "TDD",
                            "TDD",
                            "TDD",
                            "TDD",
                            "TDD",
                            "TDD",
                            "FDD",
                            "FDD",
                            "FDD",
                            "FDD",
                            "FDD",
                            "FDD",
                            }   --Cells Tech of Airphone-1

AMF_IP_TABLE    = { "10.0.1.1",
                    "10.0.1.61",
                    "10.0.1.62",
                    "10.0.1.63",
                    "10.0.1.64",
                    "10.0.1.65",
                    }  --IP table for each AMF

UPF_IP_TABLE    = { "1.2.0.1",
                    "1.2.8.1",
                    "1.2.16.1",
                    "1.2.24.1",
                    "1.2.28.1",
                    "1.2.32.1",
                    }  --IP table for each UPF

PCI_TABLE       = { "17:0",
                    "17:1",
                    "17:2",
                    "18:0",
                    "18:1",
                    "18:2",
                    "19:0",
                    "19:1",
                    "19:2",
                    "20:0",
                    "20:1",
                    "20:2",
                    }  --Physical cell ids configured in table for Multi-AP

NR_ARFCN_TABLE  = { "528000:528000",
                    "509058:509058",
                    "528000:528000",
                    "509058:509058",
                    "528000:528000",
                    "509058:509058",
                    "381000:397000",
                    "381000:397000",
                    "381000:397000",
                    "135600:126400",
                    "135600:126400",
                    "135600:126400",
                    }  --NRARFCN UL:DL for each cell for Multi-AP
SGW_S1U_IP_TABLE    = { "10.0.1.132",
                        "10.0.1.134",
                        }  --IP table for each SGW S1U
SGW_S11_IP_TABLE    = { "10.0.1.133",
                        "10.0.1.135",
                        }  --IP table for each SGW S11

PGW_IP_TABLE    =   {   "4.7.0.254",
                        "4.7.128.254",
                      }  --IP table for each PGW

MME_IP_TABLE    =   {   "10.0.1.131",
                        "10.0.1.139",
                      }  --IP table for each MME

PLMN_TABLE    =   {   "310:260",
                    }  --PLMN table for Multi-AP

GSCN_TABLE    =   {   "6501",
                      "6276",
                      "6501",
                      "6276",
                      "6501",
                      "6276",
                      "4961",
                      "4961",
                      "4961",
                      "1565",
                      "1565",
                      "1565",
                    }  --GSCN Table with absolute value for Multi-AP

SIM_GSCN_TABLE    =    {    "6501",
                        "6501",
                        "6276",
                   }

SIM_GNB_SERVER_IP_TABLE = { "10.0.2.14",
                            "10.0.2.15",
                            "10.0.2.16",
                            "10.0.2.17",
                            "10.0.2.18",
                            "10.0.2.19",
                           }  --Daemon IP table for each sim-gNB

SIM_GNB_XN_IP_TABLE = { "10.0.1.201",
                        "10.0.1.203",
                        "10.0.1.205",
                        "10.0.1.207",
                        "10.0.1.209",
                        "10.0.1.211",
                       }  --XN IP table for each sim-gNB

SIM_GNB_NG_IP_TABLE = { "10.0.1.202",
                        "10.0.1.204",
                        "10.0.1.206",
                        "10.0.1.208",
                        "10.0.1.210",
                        "10.0.1.212",
                       }  --NG IP table for each sim-gNB

SIM_GNB_PCI_TABLE   = { "21:0",
                        "21:1",
                        "21:2",
                        "22:0",
                        "22:1",
                        "22:2",
                        }  -- 6 phycical cell ids configured in table

SIM_GNB_NR_ARFCN_TABLE  = { "528000:528000",
                            "528000:528000",
                            "509058:509058",
                        }
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
PROXY_SERVER_IP2="10.0.2.90"

GNB_S1U_ADDR="10.0.1.2"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"

UEC1_ADDR="72.21.0.1"
UEC2_ADDR="72.23.0.1"
UEC3_ADDR="72.24.0.1"
UEC4_ADDR="72.25.0.1"
UEC5_ADDR="72.26.0.1"
UEC6_ADDR="72.27.0.1"

----------------------------------------------------------------------------------------------------
-- VARIABLES for MULTI-AIRPHONE support
----------------------------------------------------------------------------------------------------
--LTE definitions
ENB1_X2U_ADDR="10.0.1.136"
ENB1_X2_ADDR="10.0.1.137"
ENB1_S1_ADDR="10.0.1.138"

MME1_S1_ADDR="10.0.1.131"

PDN_IP="4.7.0.253"
PDN_IP2="4.7.100.253"
PDN_IP3="4.7.150.253"
PDN_IP4="4.7.200.253"

function run_configuration(timer)

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
if cellDepType == 'NSA' or cellDepType == 'SA+NSA' then
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
local multi_ap_id = 1
local cell_tech

FIRST_CELL_ID = CELL_ID_TABLE_FOR_AP1[1]
if Multi_AP_FLAG == 'yes' then END_CELL_ID = CELL_ID_TABLE_FOR_AP2[#CELL_ID_TABLE_FOR_AP2] else END_CELL_ID = CELL_ID_TABLE_FOR_AP1[#CELL_ID_TABLE_FOR_AP1] end


for cell_id = FIRST_CELL_ID, END_CELL_ID do
    local nrci_i = cell_id
    local nrci_o = string.format("%x", nrci_i)

    if Multi_AP_FLAG == 'no' and NUMBER_OF_AIRPHONE >= 1 then
        for i=1, END_CELL_ID do
            if CELL_ID_TABLE_FOR_AP1[i] and cell_id == CELL_ID_TABLE_FOR_AP1[i] then
                multi_ap_id = 1
                cell_tech = CELL_TECH_TABLE_OF_AP1 [i]
                i=1
                break
            end
        end
    elseif Multi_AP_FLAG == 'yes' and NUMBER_OF_AIRPHONE >= 2 then
        for i=1, END_CELL_ID do
            if CELL_ID_TABLE_FOR_AP1[i] and cell_id == CELL_ID_TABLE_FOR_AP1[i] then
                multi_ap_id = 1
                cell_tech = CELL_TECH_TABLE_OF_AP1 [i]
                i=1
                break
            elseif CELL_ID_TABLE_FOR_AP2[i] and cell_id == CELL_ID_TABLE_FOR_AP2[i] then
                multi_ap_id = 2
                cell_tech = CELL_TECH_TABLE_OF_AP2 [i]
                i=1
                break
            end
        end
    end

    PROXY_SERVER = Multi_AP_IP_TABLE[multi_ap_id]
    local result2 = string.match(cell_tech, 'FDD')
    if (result2 == nil) then
        tdd_flag = 'on'
    else
        tdd_flag = 'off'
    end

    exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN_TABLE[array_id]..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
    array_id = array_id + 1
end

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
if cellDepType == 'NSA' or cellDepType == 'SA+NSA' then
    for mme_id=1, MME_Count do
        exec('mme_pool_area id='..mme_id..' mmegi='..mme_id..' plmn='..PLMN_TABLE[mme_id]..' tac_list=777,111,222,444,333,'..TAC..'')
        exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME_IP_TABLE[mme_id]..':36412 supported_rat=lte,nblte pool=1:1')
    end

    for sgw_id = 1, CORENETWORK_COUNT do
        exec('set_sgw id='..sgw_id..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_IP_TABLE[sgw_id]..' s11='..SGW_S11_IP_TABLE[sgw_id]..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
        exec('set_pgw id='..sgw_id..' type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
    end
end
----------------------------------------------------------------------------------------------------
--SIM-GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
if HO_Supported == 'yes' then
    for simgnb_id = 1, sim_gNBs do
    local sim_nrci_i = simgnb_id + 2
    local sim_nrci_o = string.format("%x", sim_nrci_i)
    if Test_Tech == 'FDD' then
        tdd_flag = 'off'
    else
        tdd_flag = 'on'
    end
    exec('set_gnb id='..sim_nrci_i..' type=simulated plmn='..PLMN..' daemon='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':'..DAEMON_PORT..' xn='..SIM_GNB_XN_IP_TABLE[simgnb_id]..' ng='..SIM_GNB_NG_IP_TABLE[simgnb_id]..' gnb_id=0x'..sim_nrci_o..' x2_peers=none amf=1-'..AMF_COUNT..' plmnList='..PLMN..' nssai='..SNSSAI)
    exec('gnb_param id='..sim_nrci_i..' xn_listening_socket=on send_xn_setup=on measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
    exec('enb_timer T_RELOCprepTimeout=2000')
    exec('set_cell id=1 gnb='..sim_nrci_i..' pci='..SIM_GNB_PCI_TABLE[simgnb_id]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':9999|'..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[simgnb_id]..' mandatory_for_activation=off gscn='..SIM_GSCN_TABLE[simgnb_id]..' ')
    end
end

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
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
    exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100 ctrl_conn_timeout=150000')
    exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500')
    if UEC_IP == 1 then
        UEC_IP = UEC_IP + 1
    end
    UEC_IP = UEC_IP + 1
    UEC_IP2 = UEC_IP2 + 1
end

exec('set_trf_data_profile profile_id=1 trf_id=1  size=355 kbps=88  seconds=8')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=1277 kbps=583  seconds=8') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')  -----> for VNR same traffic in DL and UL



---------------------------------------------------------------------------------------------------
--UE GROUPS FOR PET_SE
--Grouping considering MPLANE in TMO : CELLS: 5,6,9 and 12 - MPLANE ONLY

---------------------------------------------------------------------------------------------------
uecid = 1
cellid = FIRST_CELL_ID
TDD_LIST = 4
FDD_LIST_START = 7
FDD_LIST_END = 10
if PET_SE_FLAG == 'yes' then
    for ue_group_id = 1, UE_GROUP_COUNT do
        if cellid > END_CELL_ID then
            cellid = FIRST_CELL_ID
        end
        if uecid > UEC_COUNT then
            uecid = 1
        end
        if SA_CELLID == 5 then
            SA_CELLID = 7
        end
        if SA_CELLID == 6 then
            SA_CELLID = 7
        end
        if SA_CELLID == 9 then
            SA_CELLID = 10
        end
        if SA_CELLID == 12 then
            SA_CELLID = FIRST_CELL_ID
        end
        exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.." uec="..uecid.." enb=2 cell="..cellid.." ptw=2.56 idle_edrx_cycle_len=2 release=17 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
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
--SA UEs allocation on UE wise: UE1 on cell1, UE2 on cell2,..
-------------------------------------------------------------------
--[[
if Test_UEs == 'SA' or Test_UEs == 'Both' then
    for SA_UEID = FIRST_SA_UE_ID, LAST_SA_UE_ID do
        if SA_CELLID > END_CELL_ID then
            SA_CELLID = FIRST_CELL_ID
        end
        if SA_CELLID == 5 then
            SA_CELLID = 7
        end
        if SA_CELLID == 9 then
            SA_CELLID = 10
        end
        if SA_CELLID == 12 then
            SA_CELLID = FIRST_CELL_ID
        end
        if SA_UECID > UEC_COUNT then
            SA_UECID = 1
        end
        if ue_group_id > UE_GROUP_COUNT then
            ue_group_id = 1
        end
        if PET_SE_FLAG == 'yes' then
            exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' additional_qosflows_to_activate=2 suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
            exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
        else
            exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
                if SA_CELLID < 3 then
                    exec('ue_param id='..SA_UEID..' ue_nr_capabilities=UE_CAP_VONR capability_file=./capability.cfg')
                else
                    exec('ue_param id='..SA_UEID..' ue_nr_capabilities=UE_CAP_VONR capability_file=./capability.cfg')
                end
            end
        SA_UECID = SA_UECID + 1
        SA_CELLID = SA_CELLID + 1
        ue_group_id = ue_group_id + 1
    end
end
]]--


--Intra_gnb HO_intra_freq-- -rate 1.3

ue_group_id = 1
SA_CELLID = 1
for SA_UEID = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA, LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA  do

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")

    ue_group_id = ue_group_id + 1
    if ue_group_id > 3 then
        ue_group_id = 1
    end
end

--Intra_gnb_inter_freq-- -rate 0.3

SA_FLAG = 1
ue_group_id = 4
SA_CELLID = 2

for SA_UEID = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA, LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA  do
        ue_group_id = 4
        SA_CELLID = 2

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")


end
--Inter_gnb_intra_freq HO-- -rate 0.18


ue_group_id = 5
SA_CELLID = 3

for SA_UEID = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA, LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA  do
        ue_group_id = 5

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")

    ue_group_id = ue_group_id + 1
    if ue_group_id > 6 then
        ue_group_id = 5
    end
end

--Inter_gnb_inter_freq HO--  0.055

ue_group_id = 7
SA_CELLID = 1

for SA_UEID = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA, LAST_INTER_gNB_INTER_FREQ_HO_UE_SA  do

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
end


--Attach+detach--  -rate 1.5

ue_group_id = 8
SA_CELLID = 1

for SA_UEID = FIRST_ATTACH_DETACH_UE_SA, LAST_ATTACH_DETACH_UE_SA   do

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")

    SA_CELLID = SA_CELLID + 1
        if SA_CELLID == 5 then
            SA_CELLID = 7
        end
        if SA_CELLID == 6 then
            SA_CELLID = 7
        end
        if SA_CELLID == 9 then
            SA_CELLID = 10
        end
        if SA_CELLID == 12 then
            SA_CELLID = FIRST_CELL_ID
        end


    ue_group_id = ue_group_id + 1
    if ue_group_id > 12 then
        ue_group_id = 8
    end
  end

 ---DRBAdd-----  -rate 0.3

SA_CELLID = 1
ue_group_id = 13
for SA_UEID = FIRST_ADITIONAL_DRB_ADD_UE_SA, LAST_ADITIONAL_DRB_ADD_UE_SA  do


    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1")


    SA_CELLID = SA_CELLID + 1
            if SA_CELLID == 5 then
            SA_CELLID = 7
        end
        if SA_CELLID == 6 then
            SA_CELLID = 7
        end
        if SA_CELLID == 9 then
            SA_CELLID = 10
        end
        if SA_CELLID == 12 then
            SA_CELLID = FIRST_CELL_ID
        end
    ue_group_id = ue_group_id + 1
    if ue_group_id > 14 then
        ue_group_id = 13
    end
end

-----VONR------

SA_CELLID = 1
ue_group_id = 15

for SA_UEID = FIRST_VONR_DRB_ADD_UE_SA, LAST_VONR_DRB_ADD_UE_SA  do

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1 qfi=3 trf_prof_dl=3  trf_prof_ul=3")

        SA_CELLID = SA_CELLID + 1
            if SA_CELLID == 5 then
            SA_CELLID = 7
        end
        if SA_CELLID == 6 then
            SA_CELLID = 7
        end
        if SA_CELLID == 9 then
            SA_CELLID = 10
        end
        if SA_CELLID == 12 then
            SA_CELLID = FIRST_CELL_ID
        end
    ue_group_id = ue_group_id + 1
    if ue_group_id > 18 then
        ue_group_id = 15
    end

end

--UE_State transition--   40UE/cell  -rate 2

ue_group_id = 19
SA_CELLID = 1

for SA_UEID = FIRST_STATE_TRASITION_UE_SA, LAST_STATE_TRASITION_UE_SA  do

    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")

        SA_CELLID = SA_CELLID + 1
            if SA_CELLID == 5 then
            SA_CELLID = 7
        end
        if SA_CELLID == 6 then
            SA_CELLID = 7
        end
        if SA_CELLID == 9 then
            SA_CELLID = 10
        end
        if SA_CELLID == 12 then
            SA_CELLID = FIRST_CELL_ID
        end
    ue_group_id = ue_group_id + 1
    if ue_group_id > 23 then
        ue_group_id = 19
    end

   end

-------------------------------------------------------------------
--NSA UEs allocation on UE wise: UE1 on cell1, UE2 on cell2,..
-------------------------------------------------------------------

if Test_UEs == 'NSA' or Test_UEs == 'Both' then
    for NSA_UEID = FIRST_NSA_UE_ID, LAST_NSA_UE_ID do
        if NSA_CELLID > END_CELL_ID then
            NSA_CELLID = FIRST_CELL_ID
        end
        if NSA_UECID > UEC_COUNT then
            NSA_UECID = 1
        end
        exec('set_ue simulated id='..NSA_UEID..' uec='..NSA_UECID..' pdn=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. NSA_IMSI + NSA_UEID - 1)
        exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=UE_CAP dual_conn=eutra_nr ue_eutra_nr_capabilities=NSA_UE_EUTRA_CAP capability_file=./capability.cfg')
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
exec('set_qosflow id=2 5qi=5 ue=all')
exec('set_qosflow id=3 5qi=1 ue=all')
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1 amf_region_id=1-6 plmn_list='..PLMN.. ' ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")

--------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCES
---------------------------------------------------------------------------------------------------
timer1 = 10800


---------------------------------------------------------------------------------------------------
-- TMO CELL 1 to CELL 2 (Intra FREQ - TDD)
---------------------------------------------------------------------------------------------------
loop_counter = 20

gr_id = 1
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 1,3 do
        if gr_id > 3 then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=IaIAgNB-TDD-HO-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl kbps=74') --74 kbps
        exec('sleep 60')
                exec("seq_loop_start loop="..loop_counter..'')
                exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=520110')
                exec('seq_delay 7') --rate=8
                exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=520110')
                exec('seq_delay 7')
            exec("seq_loop_end")
            exec('ue_deregister by=ue ue_deregister_type=switch_off')
            exec('seq_end')
        gr_id = gr_id + 1

    end
end

--------------------------------------------------------------------------------------------------
--- TMO CELL 2 to CELL 8 (Inter Freq) TDD to FDD and back
---------------------------------------------------------------------------------------------------

        exec('seq_set id=4 name=IaIEgNB-TDD/FDD-HO ue_group=4')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl kbps=74') --74 kbps
        exec('sleep 60')

            exec("seq_loop_start loop="..loop_counter..'')
                exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=396970')
                exec('seq_delay 7') --rate=8
                exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=502110')
                exec('seq_delay 7')
            exec("seq_loop_end")
            exec('ue_deregister by=ue ue_deregister_type=switch_off')

        exec('seq_end')


---------------------------------------------------------------------------------------------------
--XN
---------------------------------------------------------------------------------------------------

gr_id = 5
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 5,5 do
        if gr_id > 5 then
            gr_id = 5
        end
        exec('seq_set id='..seq_gr_id..' name=IntergNB-XN-HO'..seq_gr_id..' ue_group='..gr_id)
                exec('ue_register ue_nr_capabilities=UE_CAP_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl kbps=74') --74 kbps
        exec('trf_data_start pdu=1 qfi=2 dir=dl protocol=tcp')
        exec('trf_data_start pdu=1 qfi=2 dir=ul protocol=tcp')

        exec('sleep 60')
            exec("seq_loop_start loop="..loop_counter..'')
                exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=520110')
                exec('seq_delay 7') --rate=8
                exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=520110')
                exec('seq_delay 7')
            exec("seq_loop_end")
            exec('ue_deregister by=ue ue_deregister_type=switch_off')

            exec('seq_end')
        gr_id = gr_id + 1

    end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
gr_id = 8

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 8,10 do
        if gr_id > 10 then
            gr_id = 8
        end
        exec('seq_set id='..seq_gr_id..' name=ConstantTraffic-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=12')
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul mbps=6')
        exec('sleep '..timer1)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

gr_id = 11
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 11,12 do
        if gr_id > 12 then
            gr_id = 11
        end
        exec('seq_set id='..seq_gr_id..' name=sssg-'..seq_gr_id..' ue_group='..gr_id)
            exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=15')
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul mbps=5')
        exec('sleep '..timer1) --For 24 Hrs -- Will hold here till release
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
gr_id = 15

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 15,17 do
        if gr_id > 17 then
            gr_id = 15
        end
        exec('seq_set id='..seq_gr_id..' name=ConstantTraffic-VONR'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=7000')
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul kbps=1000')
        exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
        exec('trf_data_start pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_18_25')
        exec('trf_data_start pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_18_25')

        exec('sleep '..timer1)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
-------------------------------------------------------
--UE state transitions
--------------------------------------------------------

timer6  = 400
timer7  = 100

if PET_SE_FLAG == 'yes' then
gr_id = 19
    for seq_gr_id = 19,23 do
            if gr_id > 23 then
                    gr_id = 19
            end
            exec('seq_set id='..seq_gr_id..' name=UE_Transition'..seq_gr_id..' ue_group='..gr_id)
                    exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
                    exec("ue_pdu_session_setup pdu=1 nwslice=1")
                    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=60')
                    exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=60')
                    exec('seq_delay 80')
                    exec("seq_loop_start loop="..timer6..'')
                        exec("ue_im_entry by=ue")
                        exec('seq_delay 40')
                        exec("ue_im_exit ")
                        exec('seq_delay 30')
                        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=1000')
                        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=1000')
                        exec('seq_delay  30 ')
                    exec("seq_loop_end")
                    exec('sleep '..timer7)
                    exec('ue_deregister by=ue ue_deregister_type=switch_off')
                    exec('seq_end')
                    gr_id = gr_id + 1
    end
end



---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled NR_CLUB_PROXY_PROTO_MSGS=enabled TTI=3') --Proxy proto flags enabled and added TTI param

exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=40,20,-40,-40')
exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')

---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=5')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')
end
               
