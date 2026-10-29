-- Copyright (c) 2019 Nokia. All rights reserved.

os.execute("ulimit -c unlimited")	--To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")	--To enable all types of coredumps on WTS VM

-------------------------------------------------------------------------------------
--IP configuration
--------------------------------------------------------------------------------------
for ip1 = 61, 64 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
--    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3.1801')
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3')
end

for ip2 = 3, 28 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4')
end

for ip3 = 131, 139 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3')
end

for ip4 = 200, 214 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3')
end

os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA
os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'Both'	--Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA+NSA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'Both'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'no'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet

Multi_AP_FLAG = 'yes' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 2 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 12 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 12   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
SA_UE_COUNT_PER_CELL = 80 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 80 --NSA UE Count per cell

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 1001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 1     --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = 72 --TOTAL_NUMBER_OF_CELLS	--Total Number of Sequence_set groups

END_CELL_ID = FIRST_CELL_ID + TOTAL_NUMBER_OF_CELLS - 1 --End cell id =  FIRST_CELL_ID + NUMBER_OF_CELLS - 1, Ex: = 7+6-1
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
GSCN = 7880	--GSCN value
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 1 --Total number of SGW/PGW in core network
MME_Count = 1 --Total number of MME in core network

-------------------------------------------------------------------------------------
--IP TABLES
--------------------------------------------------------------------------------------
Multi_AP_IP_TABLE 	= { "10.0.2.80",
						"10.0.2.90",
						}  --IP table for each UPF

CELL_ID_TABLE_FOR_AP1	= { 1,
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
							}	--Cells belong to Airphone-1

CELL_ID_TABLE_FOR_AP2	= { 12,
							13,
							}	--Cells belong to Airphone-2

CELL_TECH_TABLE_OF_AP1	= { "'TDD'",
                            "'TDD'",
                            "'TDD'",
                            "'TDD'",
							"'TDD'",
							"'TDD'",
                            "'TDD'",
							"'TDD'",
							"'TDD'",
                            "'TDD'",
							"'TDD'",
							"'TDD'",
							}	--Cells Tech of Airphone-1

CELL_TECH_TABLE_OF_AP2	= { "'TDD'",
                            "'TDD'",
                            "'TDD'",
                            "'TDD'",
							"'TDD'",
							"'TDD'",
                            "'TDD'",
							"'TDD'",
							"'TDD'",
                            "'TDD'",
							"'TDD'",
							"'TDD'",
							}	--Cells Tech of Airphone-2

AMF_IP_TABLE 	= { "10.0.1.1",
                    "10.0.1.61",
                    "10.0.1.62",
					"10.0.1.63",
					"10.0.1.64",
                    }  --IP table for each AMF

UPF_IP_TABLE 	= { "1.2.0.1",
                    "1.2.8.1",
                    "1.2.16.1",
					"1.2.24.1",
					"1.2.32.1",
                    }  --IP table for each UPF

PCI_TABLE       = { "16:2",
                    "17:0",
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
					}  -- 4 phycical cell ids configured in table.

PCI_TABLE1       = { "16:2",
                    "17:0",
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
					}  -- 4 phycical cell ids configured in table.

NR_ARFCN_TABLE 	= { "636666:636666",
					"646888:646888",
					"636666:636666",
                    "646888:646888",
                    "636666:636666",
                    "646888:646888",
                    "636666:636666",
                    "646888:646888",
                    "636666:636666",
                    "646888:646888",
                    "636666:636666",
                    "646888:646888",
					 }  -- NRARFCN UL:DL for each cell

NR_ARFCN_TABLE1 	= { "646888:646888",
                    "646888:646888",
                    "636666:636666",
                    "636666:636666",
					"636666:636666",
					"636666:636666",
                    "636666:636666",
                    "636666:636666",
                    "636666:636666",
                    "636666:636666",
                    "636666:636666",
                    "636666:636666",
					 }  -- NRARFCN UL:DL for each cell

SGW_S1U_IP_TABLE 	= { "10.0.1.132",
                        "10.0.1.134",
                        }  --IP table for each SGW S1U
SGW_S11_IP_TABLE 	= { "10.0.1.133",
                        "10.0.1.135",
                        }  --IP table for each SGW S11

PGW_IP_TABLE    =   {   "4.7.0.254",
                        "4.7.128.254",
                      }  --IP table for each PGW

MME_IP_TABLE    =   {   "10.0.1.131",
                        "10.0.1.139",
                      }  --IP table for each MME

PLMN_TABLE    =   {   "311:489",
                      "311:488",
                    }  --Table for PLMN

GSCN_TABLE    =   {   "7880",
                      "7990",
                      "7880",
                      "7990",
                      "7880",
					  "7990",
                      "7880",
                      "7990",
                      "7880",
					  "7990",
                      "7880",
                      "7990",
                   }  --Table for GSCN

GSCN_TABLE1    =   {   "7990",
                      "7990",
                      "7880",
                      "7880",
                      "7880",
					  "7880",
                      "7880",
                      "7880",
                      "7880",
					  "7880",
                      "7880",
                      "7880",
                   }  --Table for GSCN

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

DAEMON_PORT=10000
EDAEMON_PORT="10000"
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
UEC7_ADDR="72.28.0.1"
UEC8_ADDR="72.29.0.1"
UEC9_ADDR="72.30.0.1"
UEC10_ADDR="72.31.0.1"
UEC11_ADDR="72.32.0.1"
UEC12_ADDR="72.33.0.1"

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

function run_configuration()

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
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..'')

local array_id = 1
local multi_ap_id = 1
local cell_tech
for cell_id = FIRST_CELL_ID, END_CELL_ID do
    local nrci_i = cell_id
    local nrci_o = string.format("%x", nrci_i)

    if Test_Tech == 'FDD' then
        tdd_flag = 'off'
    elseif Test_Tech == 'TDD' then
        tdd_flag = 'on'
	elseif Test_Tech == 'Both' and Multi_AP_FLAG == 'no' then
    	cell_tech = CELL_TECH_TABLE_OF_AP1 [cell_id]
        print(cell_tech)
		local result = string.match(cell_tech, 'FDD')
        if (result == nil) then
			tdd_flag = 'on'
		else
			tdd_flag = 'off'
		end
    end

	if Multi_AP_FLAG == 'yes' and NUMBER_OF_AIRPHONE >= 2 then
		for i=1, END_CELL_ID do
			if CELL_ID_TABLE_FOR_AP1[i] and cell_id == CELL_ID_TABLE_FOR_AP1[i] then
                multi_ap_id = 1
				Test_Tech = CELL_TECH_TABLE_OF_AP1 [i]
                i=1
                break
            elseif CELL_ID_TABLE_FOR_AP2[i] and cell_id == CELL_ID_TABLE_FOR_AP2[i] then
        	    multi_ap_id = 2
				Test_Tech = CELL_TECH_TABLE_OF_AP2 [i]
                i=1
                break
       		end
        end
		PROXY_SERVER = Multi_AP_IP_TABLE[multi_ap_id]

--		exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN_TABLE[array_id]..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
--	else
--    	exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')

--    if (cell_id%2)==1 then
    	exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN_TABLE[array_id]..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
--	else
--	    exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN_TABLE1[array_id]..' pci='..PCI_TABLE1[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell=on proxy='..PROXY_SERVER_IP2..':9999|'..PROXY_SERVER_IP2..':8888 nr_arfcn='..NR_ARFCN_TABLE1[array_id]..' mandatory_for_activation=off')
--    end
    end
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
    	exec('set_sgw id='..sgw_id..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_IP_TABLE[sgw_id]..' s11='..SGW_S11_IP_TABLE[sgw_id]..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=20')
    	exec('set_pgw id='..sgw_id..' type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
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
--Cell 1 UEs:
FIRST_UE_SA_CELL_1 = 1
END_UE_SA_CELL_1 = 10
FIRST_UE_NSA_CELL_1 = 11
END_UE_NSA_CELL_1 = 20

--Cell 2 UEs:
FIRST_UE_SA_CELL_2 = 21
END_UE_SA_CELL_2 = 30
FIRST_UE_NSA_CELL_2 = 31
END_UE_NSA_CELL_2 = 40

--Cell 3 UEs:
FIRST_UE_SA_CELL_3 = 41
END_UE_SA_CELL_3 = 50
FIRST_UE_NSA_CELL_3 = 51
END_UE_NSA_CELL_3 = 60

--Cell 4 UEs:
FIRST_UE_SA_CELL_4 = 61
END_UE_SA_CELL_4 = 70
FIRST_UE_NSA_CELL_4 = 71
END_UE_NSA_CELL_4 = 80

--Cell 5 UEs:
FIRST_UE_SA_CELL_5 = 81
END_UE_SA_CELL_5 = 90
FIRST_UE_NSA_CELL_5 = 91
END_UE_NSA_CELL_5 = 100

--Cell 6 UEs:
FIRST_UE_SA_CELL_6 = 101
END_UE_SA_CELL_6 = 110
FIRST_UE_NSA_CELL_6 = 111
END_UE_NSA_CELL_6 = 120

--Cell 7 UEs:
FIRST_UE_SA_CELL_7 = 121
END_UE_SA_CELL_7 = 130
FIRST_UE_NSA_CELL_7 = 131
END_UE_NSA_CELL_7 = 140

--Cell 8 UEs:
FIRST_UE_SA_CELL_8 = 141
END_UE_SA_CELL_8 = 150
FIRST_UE_NSA_CELL_8 = 151
END_UE_NSA_CELL_8 = 160

--Cell 9 UEs:
FIRST_UE_SA_CELL_9 = 161
END_UE_SA_CELL_9 = 170
FIRST_UE_NSA_CELL_9 = 171
END_UE_NSA_CELL_9 = 180

--Cell 10 UEs:
FIRST_UE_SA_CELL_10 = 181
END_UE_SA_CELL_10 = 190
FIRST_UE_NSA_CELL_10 = 191
END_UE_NSA_CELL_10 = 200

--Cell 11 UEs:
FIRST_UE_SA_CELL_11 = 201
END_UE_SA_CELL_11 = 210
FIRST_UE_NSA_CELL_11 = 211
END_UE_NSA_CELL_11 = 220

--Cell 12 UEs:
FIRST_UE_SA_CELL_12 = 221
END_UE_SA_CELL_12 = 230
FIRST_UE_NSA_CELL_12 = 231
END_UE_NSA_CELL_12 = 240

IMSI_1 = 21645100
IMSI_2 = 21645200
IMSI_3 = 21645300
IMSI_4 = 21645400
IMSI_5 = 21645500
IMSI_6 = 21645600
IMSI_7 = 21645700
IMSI_8 = 21645800
IMSI_9 = 21645900
IMSI_10 = 21646000
IMSI_11 = 21646100
IMSI_12 = 21646200
IMSI_13 = 21646300
IMSI_14 = 21646400
IMSI_15 = 21646500
IMSI_16 = 21646600
IMSI_17 = 21646700
IMSI_18 = 21646800
IMSI_19 = 21646900
IMSI_20 = 21647000
IMSI_21 = 21647100
IMSI_22 = 21647200
IMSI_23 = 21647300
IMSI_24 = 21647400
IMSI_25 = 21647500
IMSI_26 = 21647600
IMSI_27 = 21647700
IMSI_28 = 21647800
IMSI_29 = 21647900
IMSI_30 = 21648000
IMSI_31 = 21648100
IMSI_32 = 21648200
IMSI_33 = 21648300
IMSI_34 = 21648400
IMSI_35 = 21648500
IMSI_36 = 21648600
QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
        exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end


for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
        exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


for UEID = FIRST_UE_SA_CELL_2, END_UE_SA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_3 + UEID - 1)
        exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 21, 30 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_2, END_UE_NSA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_4 + UEID - 1)
        exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_3, END_UE_SA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_5 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 41, 50 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_3, END_UE_NSA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_6 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_4, END_UE_SA_CELL_4 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:489:0000:0:0:0'.. IMSI_7 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 61, 70 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_4, END_UE_NSA_CELL_4 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_8 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_5, END_UE_SA_CELL_5 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=5 suci=0:311:489:0000:0:0:0'.. IMSI_9 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 81, 90 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_5, END_UE_NSA_CELL_5 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_10 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_6, END_UE_SA_CELL_6 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=6 suci=0:311:489:0000:0:0:0'.. IMSI_11 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 101, 110 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_6, END_UE_NSA_CELL_6 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_12 + UEID - 1)
    	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_7, END_UE_SA_CELL_7 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=7 suci=0:311:489:0000:0:0:0'.. IMSI_13 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 121, 130 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_7, END_UE_NSA_CELL_7 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_14 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_8, END_UE_SA_CELL_8 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=8 suci=0:311:489:0000:0:0:0'.. IMSI_15 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 141, 150 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_8, END_UE_NSA_CELL_8 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_16 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_9, END_UE_SA_CELL_9 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=9 suci=0:311:489:0000:0:0:0'.. IMSI_17 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 161, 170 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_9, END_UE_NSA_CELL_9 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_18 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_10, END_UE_SA_CELL_10 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=10 suci=0:311:489:0000:0:0:0'.. IMSI_19 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 181, 190 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_10, END_UE_NSA_CELL_10 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_20 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_11, END_UE_SA_CELL_11 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=11 suci=0:311:489:0000:0:0:0'.. IMSI_21 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 201, 210 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_11, END_UE_NSA_CELL_11 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_22 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_12, END_UE_SA_CELL_12 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=12 suci=0:311:489:0000:0:0:0'.. IMSI_23 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
   for gw_id = 221, 230 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_12, END_UE_NSA_CELL_12 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_24 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB2A986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CAA61A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E54D000100000965950034AA285800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940 dual_conn=eutra_nr ue_eutra_nr_capabilities=011C0A8260800810389A00000008B81102C108B89A0000040800804809A1600E40A2448913620F0214489B1078000044000100800040202004008400020101002004')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.0.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
--exec('set_qosflow id=1 5qi=6 default=on')
--exec('nwslice_set id=1 qos_flows=1 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=7')
exec('nwslice_set id=1 qos_flows=1,2 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")
---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR SA  40 CA UES DL Tput 2278Mbps
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
	for seq_gr_id = 1, 12 do
		if gr_id > UE_GROUP_COUNT then
			gr_id = 1
		end
		exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
		--exec('ue_register ue_nr_capabilities=UE_CAP_t1r4_n1 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_register ue_nr_capabilities=UE_CAP_t2r4_n2 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=10')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=10')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72')
		--exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=42')
		--exec('sleep 5400') --For 1.5 hours
        exec('sleep 9900') --For 6 hours
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		gr_id = gr_id + 1
	end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 32 NONCAUEs DL Tput in 1 FDD cells
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 13, 24 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
    exec('ue_register ue_nr_capabilities=UE_CAP_t2r4_n2 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72')
    --exec('sleep 5400') --For 1.5 hours
    exec('sleep 9900') --For 6 hours
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
    gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 32NONCAUEs DL Tput in 1 FDD cell
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 25, 36  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_t2r4_n2 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=1')
        --exec('sleep 5400') --For 1.5 hours
        exec('sleep 21600') --For 6 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 32NONCAUEs DL Tput in 1 TDD cells
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 37, 48 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_t2r4_n2 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=21')
        --exec('sleep 5400') --For 1.5 hours
        exec('sleep 21600') --For 6 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 32NONCAUEs DL Tput in 1 TDD cell
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 49, 60  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_t2r4_n2 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=3')
         --exec('sleep 5400') --For 1.5 hours
        exec('sleep 21600') --For 6 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 213 CA RRC connected Ues
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 61, 72  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	    exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_4CC_FDD_CA capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('sleep 5400') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 1280 FDD NONCA RRC connected Ues
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 73, 84  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	    exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_FDD_NONCA_BAND25 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('sleep 5400') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 1280 FDD NONCA RRC connected Ues
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 85, 96  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	    exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FDD_4CCCA capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('sleep 72000') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 1024 TDD NONCA RRC connected Ues
---------------------------------------------------------------------------------------------------
gr_id = 1
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 97, 108  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	    exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_TDD_NONCA_BAND41 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('sleep 5400') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 1024 TDD NONCA RRC connected Ues
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 109, 120  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	    exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UE_CAP_TDD_NONCA_BAND77 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('sleep 5400') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR  FDD+TDD CA 40 Ues
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 121, 132  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
	    exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=UL_CA_FDD_TDD capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
       --exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=13 size=1350') --6850 kbps
       -- exec('sleep 5400') --For 1.5 hours
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=12800 size=1350')
        exec('sleep 21600') --For 6 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR  FDD+TDD CA 1 UE
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 133, 144  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FDD_4CCCA capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=12 size=1350') --280 Mbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=12800 size=1350')
         --exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul mbps=110 size=1350')
        exec('sleep 5400') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR  FDD+TDD CA 30 UEs
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 145, 156  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FDD_4CCCA capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=768 size=1350') --274 Mbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=2 dir=dl kbps=768 size=1350')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl mbps=160 size=1350')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl mbps=160 size=1350')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl mbps=160 size=1350')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=10 dir=dl mbps=110 size=1350')
        --exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl Mbps=6 size=1350') --274 Mbps
        exec('sleep 72000') --For 1.5 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR  FDD+TDD CA 30 UEs
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 157, 168  do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FDD_4CCCA capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --274 Mbps
        exec('trf_data_start pdu=1 qfi=2 trf_id=2 dir=dl bps=72 size=42') --274 Mbps
       --exec('sleep 5400') --For 1.5 hours
        exec('sleep 72000') --For 6 hours
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
--exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
--exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled') --Proxy proto flag enabled
--exec('sim_param_set disable_events_on_telnet_session=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled NR_CLUB_PROXY_PROTO_MSGS=enabled')

exec('debug_log level=1')
exec('sim_debug_log level=1 uec=1,2,3,4,5,6')
exec('sim_debug_log level=1 app_type=l2nrt')
exec('sim_debug_log level=1 app_type=l2rt')
exec('sim_debug_log level=1 app_type=ueproxy')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')

exec('trace uec=1,2,3,4,5,6 protocol=rrc on')
exec('trace uec=1,2,3,4,5,6 protocol=nr_rrc on')
exec('sim_trace uec=1,2,3,4,5,6 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')

exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')
end
