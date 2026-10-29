-- Copyright (c) 2019 Nokia. All rights reserved.

os.execute("ulimit -c unlimited")	--To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")	--To enable all types of coredumps on WTS VM

-------------------------------------------------------------------------------------
--VLAN Finder
-------------------------------------------------------------------------------------
function find_vlan(interface)
    local filename = os.tmpname()
    local command = "ip link > " .. filename
    os.execute(command)
  
    local file = io.open(filename, "r")
    local output = ""
    if file then
      for line in file:lines() do
		if string.match(line, "trunk") then
			break
        elseif string.match(line, interface) then
          local vlan = string.match(line, "%.%d+")
          if vlan then
            output = vlan
            break
          end
        end
      end
      file:close()
      os.remove(filename)
    end
    if output ~= "" then
      return output -- Return VLAN ID if found
    else
      return "" -- Return empty string if VLAN ID is not found
    end
  end
  
  GNB_VLAN = find_vlan("eth3")
  AP_VLAN = find_vlan("eth4")
  
  -- Write the VLAN IDs to file
  os.execute('echo "GNB_VLAN:'..GNB_VLAN..'"> /opt/wts/latest/vlan')
  os.execute('echo "AP_VLAN'..AP_VLAN..'">> /opt/wts/latest/vlan')

-------------------------------------------------------------------------------------
--IP configuration
--------------------------------------------------------------------------------------
for ip1 = 61, 65 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
--    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3.1801')
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3'..GNB_VLAN..'')
end

for ip2 = 3, 28 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 131, 139 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3'..GNB_VLAN..'')
end

for ip4 = 200, 214 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3'..GNB_VLAN..'')
end

os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA
----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'TDD'	--Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Enabled = 'yes'  --Sim-gNBs configured for Handover if set to 'yes'

Multi_AP_FLAG = 'no' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 1 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 6 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 6   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
SA_UE_COUNT_PER_CELL = 881 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 0 --NSA UE Count per cell
sim_gNBs = 2	--Sim-gNBs for Handover

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 18001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 12     --Number of PET_SE UE_Groups per cell
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
CORENETWORK_COUNT = 0 --Total number of SGW/PGW in core network
MME_Count = 1 --Total number of MME in core network

---------------------------------------------------------------------------------------------------
--UE DISTRIBUTION
---------------------------------------------------------------------------------------------------
--[[
Scenario                 UE group id for cell 1-6          No UEs/CELL      
																		
A-D+SCell ADD-DEL        --->1-6                            21          
A-D+DEL                  --->7-12                           128         
PAG                      --->13-18                          130         
ST                       --->19-24                          130         
INTRA-GNB+INTRA FREQ     --->25-30                          31          
INTRA-GNB+INTER FREQ     --->31-36                          7          
INTER-GNB+INTRA FREQ     --->37-42                          10          
INTER-GNB+INTER FREQ     --->43-48                          2          
RNA                      --->49-54                          408         
TAU                      --->55-60                          4           
Ad DRB                   --->61-66                          6           
VoNR                     --->67-72                          15         

--]]


UE_A_D_SCELL_ADD_DEL=22
UE_A_D_SCELL_ADD=128
UE_PAG=33
UE_ST=34
UE_IN_GNB_IN_FREQ=16
UE_IN_GNB_ITR_FREQ=4
UE_ITR_GNB_IN_FREQ=10
UE_ITR_GNB_ITR_FREQ=2
UE_RNA=408
UE_TAU=4
UE_Ad_DRB=6
UE_VoNR=15

START_UE_A_D_SCELL_ADD_DEL = 1
END_UE_A_D_SCELL_ADD_DEL = TOTAL_NUMBER_OF_CELLS*UE_A_D_SCELL_ADD_DEL

START_UE_A_D_SCELL_ADD = END_UE_A_D_SCELL_ADD_DEL + 1
END_UE_A_D_SCELL_ADD = START_UE_A_D_SCELL_ADD + (TOTAL_NUMBER_OF_CELLS*UE_A_D_SCELL_ADD)-1

START_UE_PAG = END_UE_A_D_SCELL_ADD + 1
END_UE_PAG = START_UE_PAG + (TOTAL_NUMBER_OF_CELLS*UE_PAG) -1

START_UE_ST = END_UE_PAG+1
END_UE_ST = START_UE_ST+(TOTAL_NUMBER_OF_CELLS*UE_ST)-1

START_UE_IN_GNB_IN_FREQ = END_UE_ST+1
END_UE_IN_GNB_IN_FREQ = START_UE_IN_GNB_IN_FREQ+(TOTAL_NUMBER_OF_CELLS*UE_IN_GNB_IN_FREQ)-1

START_UE_IN_GNB_ITR_FREQ = END_UE_IN_GNB_IN_FREQ+1
END_UE_IN_GNB_ITR_FREQ = START_UE_IN_GNB_ITR_FREQ+(TOTAL_NUMBER_OF_CELLS*UE_IN_GNB_ITR_FREQ)-1

START_UE_ITR_GNB_IN_FREQ = END_UE_IN_GNB_ITR_FREQ+1
END_UE_ITR_GNB_IN_FREQ = START_UE_ITR_GNB_IN_FREQ+(TOTAL_NUMBER_OF_CELLS*UE_ITR_GNB_IN_FREQ)-1

START_UE_ITR_GNB_ITR_FREQ = END_UE_ITR_GNB_IN_FREQ+1
END_UE_ITR_GNB_ITR_FREQ = START_UE_ITR_GNB_ITR_FREQ+(TOTAL_NUMBER_OF_CELLS*UE_ITR_GNB_ITR_FREQ)-1

START_UE_RNA = END_UE_ITR_GNB_ITR_FREQ+1
END_UE_RNA = START_UE_RNA+(TOTAL_NUMBER_OF_CELLS*UE_RNA)-1

START_UE_TAU = END_UE_RNA+1
END_UE_TAU = START_UE_TAU+(TOTAL_NUMBER_OF_CELLS*UE_TAU)-1

START_UE_Ad_DRB = END_UE_TAU+1
END_UE_Ad_DRB = START_UE_Ad_DRB+(TOTAL_NUMBER_OF_CELLS*UE_Ad_DRB)-1

START_UE_VoNR = END_UE_Ad_DRB+1
END_UE_VoNR = START_UE_VoNR+(TOTAL_NUMBER_OF_CELLS*UE_VoNR)-1

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
							}	--Cells belong to Airphone-1

CELL_ID_TABLE_FOR_AP2	= { 7,
							8,
							9,
							10,
							11,
							12,
							}	--Cells belong to Airphone-2

CELL_TECH_TABLE_OF_AP1	= { "'TDD'",
							"'TDD'",
							"'TDD'",
							"'TDD'",
							"'TDD'",
							"'TDD'",
							}	--Cells Tech of Airphone-1

CELL_TECH_TABLE_OF_AP2	= { "'FDD'",
							"'TDD'",
							"'FDD'",
							"'TDD'",
							"'FDD'",
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
					}  -- 6 phycical cell ids configured in table.
					
NR_ARFCN_TABLE 	= { "630000:630000",
                    "630000:630000",
                    "630000:630000",
                    "636640:636640",
                    "636640:636640",
                    "636640:636640",
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

GSCN_TABLE    =   {   "7811",
                      "7811",
					  "7811",
					  "7881",
					  "7881",
					  "7881",
                    }  --Table for GSCN
					

SIM_GNB_SERVER_IP_TABLE	= { "10.0.2.14",
                	        "10.0.2.15",
    	                    "10.0.2.16",
    		    			"10.0.2.17",
    	    				"10.0.2.18",
        					"10.0.2.19",
            	           }  --Daemon IP table for each sim-gNB

SIM_GNB_XN_IP_TABLE	= { "10.0.1.201",
                	    "10.0.1.203",
	                    "10.0.1.205",
				    	"10.0.1.207",
	    				"10.0.1.209",
    					"10.0.1.211",
           	           }  --XN IP table for each sim-gNB

SIM_GNB_NG_IP_TABLE	= { "10.0.1.202",
                	    "10.0.1.204",
	                    "10.0.1.206",
		    			"10.0.1.208",
    					"10.0.1.210",
    					"10.0.1.212",
        	           }  --NG IP table for each sim-gNB

SIM_GNB_PCI_TABLE	= { "18:2",
                        "19:0",
    					"19:1",
    					"19:2",
    					"20:0",
    					"20:1",
	    				}  -- 6 phycical cell ids configured in table

SIM_GNB_NR_ARFCN_TABLE 	= { "630000:630000",
                            "636640:636640"	
                        }  
SIM_GSCN_TABLE  = 	{ 	"7811",
						"7881"
					}   --Table for GSCN
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

--Simulated gNBs for Handover
SERVER_IP_sim1="10.0.2.14"
SERVER_IP_sim2="10.0.2.15"
SERVER_IP_sim3="10.0.2.16"
SERVER_IP_sim4="10.0.2.17"
SERVER_IP_sim5="10.0.2.18"
SERVER_IP_sim6="10.0.2.19"

GNB3_NG_ADDR="10.0.1.202"
GNB3_XN_ADDR="10.0.1.201"
GNB4_NG_ADDR="10.0.1.204"
GNB4_XN_ADDR="10.0.1.203"
GNB5_NG_ADDR="10.0.1.206"
GNB5_XN_ADDR="10.0.1.205"
GNB6_NG_ADDR="10.0.1.208"
GNB6_XN_ADDR="10.0.1.207"
GNB7_NG_ADDR="10.0.1.210"
GNB7_XN_ADDR="10.0.1.209"
GNB8_NG_ADDR="10.0.1.212"
GNB8_XN_ADDR="10.0.1.211"

function run_configuration(duration)

local ue_active_delay=15
local LOOP_count=math.floor(duration/ue_active_delay)
local TAU_LOOP_count=math.floor(duration/16)

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

		exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN_TABLE[array_id]..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
	else
    	--exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
		exec('set_cell id='..cell_id..' gnb=2 gscn='..GSCN_TABLE[cell_id]..' pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
	end
	array_id = array_id + 1
end
----------------------------------------------------------------------------------------------------
--SIM-GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
if HO_Enabled == 'yes' then
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
	exec('set_cell id=1 gnb='..sim_nrci_i..' pci='..SIM_GNB_PCI_TABLE[simgnb_id]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':9999|'..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[simgnb_id]..' mandatory_for_activation=off gscn='..SIM_GSCN_TABLE[simgnb_id]..' suggested_band=78')
	end
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
    exec('set_amf id='..amf_id..' name=SimModeAMF-'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
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
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500 disable_sib1_flood=true disable_sib_during_ho=true')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
end


--Traffic profile creation
-------------------------------------------------------------------------------------------------------
exec('set_trf_data_profile profile_id=1 trf_id=1  size=355 kbps=176  seconds=8')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=1277 kbps=1166  seconds=8') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')  -----> for VNR same traffic in DL and UL
----------------------------------------------------------------------------------------------------
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
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.."-CELL-"..cellid.." uec="..uecid.." enb=2 cell="..cellid.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
		cellid = cellid + 1
		uecid = uecid + 1
	end
end

--Attach-Detach with SCell-add-del--

ue_group_id = 1
SA_CELLID = 1
UE_FLAG=1
for SA_UEID =START_UE_A_D_SCELL_ADD_DEL,END_UE_A_D_SCELL_ADD_DEL do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 1
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

---Attach-Detach with SCell-add--

ue_group_id = 7 
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_A_D_SCELL_ADD,END_UE_A_D_SCELL_ADD do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 7
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

---Paging---

ue_group_id = 13
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_PAG,END_UE_PAG  do
    if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 13
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--UE state transition--

ue_group_id = 19
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_ST,END_UE_ST  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 19 
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Intra-gNB_Intra_Freq-----

ue_group_id = 25
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_IN_GNB_IN_FREQ,END_UE_IN_GNB_IN_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 25
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Intra-gNB_Inter_Freq----

ue_group_id = 31 
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_IN_GNB_ITR_FREQ,END_UE_IN_GNB_ITR_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 31			
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Inter-gNB_Intra-Freq----

ue_group_id = 37
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_ITR_GNB_IN_FREQ,END_UE_ITR_GNB_IN_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 37 
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Inter-gNB_Inter-Freq----

ue_group_id = 43
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_ITR_GNB_ITR_FREQ,END_UE_ITR_GNB_ITR_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 43
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----RNA-----

ue_group_id = 49
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_RNA,END_UE_RNA  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 49 
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--- TAU------

ue_group_id = 55
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_TAU,END_UE_TAU  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 55 
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

-----Additional DRB-------------

ue_group_id = 61
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_Ad_DRB,END_UE_Ad_DRB  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 61
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

-----VoNR-----

ue_group_id = 67
SA_CELLID = 1
UE_FLAG=1
for SA_UEID = START_UE_VoNR,END_UE_VoNR  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 67 
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2  trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1 qfi=3 trf_prof_dl=3  trf_prof_ul=3")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
exec('set_qosflow id=4 5qi=8 default=off')
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1,2,3 amf_region_id=1-5 plmn_list='..PLMN..'  ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
 
 if PET_SE_FLAG == 'yes' then
----------------------------------------------------
--Attach-Detach +CA scell add + del
----------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=1 name=scell-add-del-1-2 ue_group=1')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=629952')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636672 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell5
---------------------------------------------------------------------------------------------------
		exec('seq_set id=2 name=scell-add-del-2-1 ue_group=2')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=629952')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636672 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')		
		exec('seq_end')
			 
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell6
---------------------------------------------------------------------------------------------------
		exec('seq_set id=3 name=scell-add-del-3-4  ue_group=3')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=629952')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636672 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4')  
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell1
---------------------------------------------------------------------------------------------------
		exec('seq_set id=4 name=scell-add-del-4-3  ue_group=4')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636672')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=629952 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=5 name=scell-add-del-5-6  ue_group=5')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636672')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=629952 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell3
---------------------------------------------------------------------------------------------------
		exec('seq_set id=6 name=scell-add-del-6-5  ue_group=6')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636672')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=629952 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
----------------------------------------------------
--Attach-Detach +CA scell add  at rate 6
-----------------------------------------------------		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to cell5 
---------------------------------------------------------------------------------------------------
		exec('seq_set id=7 name=scell-add-del-1-2 ue_group=7')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=629952')
		exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=8 name=scell-add-del-2-1 ue_group=8')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=629952')
		exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
			 
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=9 name=scell-add-del-3-4  ue_group=9')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=629952')
		exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell6 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=10 name=scell-add-del-4-3  ue_group=10')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636672')
		exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=11 name=scell-add-del-5-6  ue_group=11')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636672')
		exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=12 name=scell-add-del-6-5  ue_group=12')
        exec('ue_register ue_nr_capabilities=TWO_CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636672')
		exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
end
-----------------------------------------
--Paging
------------------------------------------
gr_id = 13
	for seq_gr_id = 13, 18 do
        
		exec('seq_set id='..seq_gr_id..' name=PagingStartStop-'..seq_gr_id..' ue_group='..gr_id)
		exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec("ue_pdu_session_setup pdu=1 nwslice=1")
            exec('seq_loop_start loop='..LOOP_count..'')
            exec('seq_delay '..ue_active_delay..'')
            exec('amf_paging_start id=1-5')
        exec("seq_loop_end")
        exec('seq_delay 3')
        exec("ue_im_exit by=ue")
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
---------------------------------------------------
--UE state transition:
--------------------------------------------------------
gr_id = 19
	for seq_gr_id = 19,24 do		
			if gr_id > 42 then
			   gr_id = 37
			end
		    exec('seq_set id='..seq_gr_id..' name=Pet_Attach-Detach'..seq_gr_id..' ue_group='..gr_id)
            exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
            exec("ue_pdu_session_setup pdu=1 nwslice=1")
            exec('seq_loop_start loop='..LOOP_count..'')
                exec('seq_delay  '..ue_active_delay..'')
                exec("ue_im_exit by=ue")
            exec("seq_loop_end")
            exec('seq_delay 3')
            exec("ue_im_exit by=ue")
            exec('ue_deregister by=ue ue_deregister_type=switch_off')
            exec('seq_end')
            gr_id = gr_id + 1
    end

---------------------------------------------------------------------------------------------------
-----Intra-GNB-------------------
---------------------------------------------------------------------------------------------------

--Intra Frequency HO Between Cell-1 and Cell-2

		exec('seq_set id=25 name=Intragnb-IntraFreq-HO ue_group=25')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-2 and Cell-3 

		exec('seq_set id=26 name=Intragnb-IntraFreq-HO ue_group=26')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-3 and Cell-1

		exec('seq_set id=27 name=Intragnb-IntraFreq-HO  ue_group=27')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-4 and Cell-5

		exec('seq_set id=28 name=Intragnb-IntraFreq-HO ue_group=28')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-5 and Cell-6

		exec('seq_set id=29 name=Intragnb-IntraFreq-HO  ue_group=29')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 2')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-6 and Cell-4

		exec('seq_set id=30 name=IntraGNB-IntraFreq-HO ue_group=30')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-------------------------------------------------------------------------------------------------------------------

--Inter Frequency HO Between Cell-1 and Cell-4

		exec('seq_set id=31 name=IntraGNB-InterFreq-HO ue_group=31')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-2 and Cell-5 

		exec('seq_set id=32 name=IntraGNB-InterFreq-HO ue_group=32')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-3 and Cell-6

		exec('seq_set id=33 name=IntraGNB-InterFreq-HO ue_group=33')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-4 and Cell-1

		exec('seq_set id=34 name=IntraGNB-InterFreq-HO ue_group=34')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-5 and Cell-2

		exec('seq_set id=35 name=IntraGNB-InterFreq-HO ue_group=35')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-6 and Cell-3

		exec('seq_set id=36 name=IntraGNB-InterFreq-HO ue_group=36')
        exec('ue_register ue_nr_capabilities=SA_BAND_41_77_78_79 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') --rate=8
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

---------------------------------------------------------------------------------------------------
-----Inter-GNB-------------------
---------------------------------------------------------------------------------------------------

--Intra Frequency HO Between Real gNB Cell-1 and sim_gNB_3

		exec('seq_set id=37 name=Intergnb-IntraFreq-HO ue_group=37')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Real gNB Cell-2 and sim_gNB_3 

		exec('seq_set id=38 name=Intergnb-IntraFreq-HO ue_group=38')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Real gNB Cell-3 and sim_gNB_3

		exec('seq_set id=39 name=Intergnb-IntraFreq-HO  ue_group=39')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Real gNB Cell-4 and sim_gNB_4

		exec('seq_set id=40 name=Intergnb-IntraFreq-HO  ue_group=40')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Real gNB Cell-5 and sim_gNB_4

		exec('seq_set id=41 name=Intergnb-IntraFreq-HO  ue_group=41')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Real gNB Cell-6 and sim_gNB_4

		exec('seq_set id=42 name=Intergnb-IntraFreq-HO  ue_group=42')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-------------------------------------------------------------------------

--Inter Frequency HO Between Real gNB Cell-1 and sim_gNB_4

		exec('seq_set id=43 name=Intergnb-InterFreq-HO ue_group=43')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Real gNB Cell-2 and sim_gNB_4 

		exec('seq_set id=44 name=Intergnb-InterFreq-HO ue_group=44')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 2')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Real gNB Cell-3 and sim_gNB_4

		exec('seq_set id=45 name=Intergnb-InterFreq-HO  ue_group=45')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Real gNB Cell-4 and sim_gNB_3

		exec('seq_set id=46 name=Intergnb-InterFreq-HO  ue_group=46')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Real gNB Cell-5 and sim_gNB_3

		exec('seq_set id=47 name=Intergnb-InterFreq-HO  ue_group=47')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Real gNB Cell-6 and sim_gNB_3

		exec('seq_set id=48 name=Intergnb-InterFreq-HO  ue_group=48')
        exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=629952')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=636672')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
-----RNA-------------------
---------------------------------------------------------------------------------------------------

gr_id = 49
for seq_gr_id = 49,54 do		
	if gr_id > 54 then
	   gr_id = 49
	end
    exec('seq_set id='..seq_gr_id..' name=RNA-'..seq_gr_id..' ue_group='..gr_id)	
	exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=750 size=1350 seconds=8')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=125 size=1350 seconds=8')			
	exec('seq_delay 16200')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id = gr_id + 1
end	

---------------------------------------------------------------------------------------------------
-----TAU-------------------
---------------------------------------------------------------------------------------------------
gr_id = 55

for seq_gr_id = 55,60 do		
	if gr_id > 60 then
	   gr_id = 55
	end
		exec('seq_set id='..seq_gr_id..' name=TAU-'..seq_gr_id..' ue_group='..gr_id)
		exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration'	)
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec("seq_loop_start loop=1013"	)
			exec('seq_delay '..TAU_LOOP_count..'')
			exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg reactivate_pdu=off use_suci=off registration_type=MobilityRegistrationUpdting')
		exec("seq_loop_end"	)
		exec('seq_delay 3'	)
		exec('ue_deregister by=ue ue_deregister_type=switch_off')	
		exec('seq_end')
	gr_id = gr_id + 1
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DRB addition:
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 61
for seq_gr_id =61,66 do
    if gr_id > 66 then
        gr_id = 61
    end
    exec('seq_set id='..seq_gr_id..' name=Pet_PDU-add-del'..seq_gr_id..' ue_group='..gr_id)
    exec('ue_register ue_nr_capabilities=SA_BAND_78 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 0.1')
	exec("ue_pdu_session_setup pdu=2 nwslice=1")
    exec('seq_delay 8')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
    gr_id = gr_id + 1
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---VONR-------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

gr_id = 67

for seq_gr_id = 67,72 do
    if  gr_id > 72 then
        gr_id = 67
    end
    exec('seq_set id='..seq_gr_id..' name=Pet_VONR'..seq_gr_id..' ue_group='..gr_id)
    exec('ue_register ue_nr_capabilities=VONR_8360 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1 nwslice=1")
    exec('seq_delay 0.1')
    exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
    exec('seq_delay 120')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
    gr_id = gr_id + 1
end
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled') --Proxy proto flag enabled
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled') 
exec('sim_param_set TTI=3 ')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set purge_buffer_on_full=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4 max_file_num=50 max_log_size=200M')
exec('sim_param_set ENABLE_CORE_LIMIT=on')
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=200M')
exec('sim_start version_check=off')
exec('debug_sim_log level=4 uec=1-6')
exec('debug_sim_log level=4 amf=1-5')
exec('sim_debug_log level=4 app_type=ueproxy')



end
