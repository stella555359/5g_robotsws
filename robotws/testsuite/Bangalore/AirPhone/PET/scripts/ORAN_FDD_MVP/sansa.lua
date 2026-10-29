-- Copyright (c) 2019 Nokia. All rights reserved.
os.execute("ulimit -c unlimited")   --To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")  --To enable all types of coredumps on WTS VM

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
for ip1 = 61, 65 do --To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
--    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3.1801')
    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3'..GNB_VLAN..'')
end

for ip2 = 3, 28 do  --To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 131, 139 do   --To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3'..GNB_VLAN..'')
end

for ip4 = 200, 214 do   --To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3'..GNB_VLAN..'')
end

os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA


----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'FDD'	--Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Enabled = 'yes'  --Sim-gNBs configured for Handover if set to 'yes'

Multi_AP_FLAG = 'no' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 1 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 6 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 18   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC

sim_gNBs = 3	--Sim-gNBs for Handover

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
FIRST_AMF_ID = 1   --Starting AMF id

UE_GROUP_COUNT_PER_CELL = 12     --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups

END_CELL_ID = FIRST_CELL_ID + TOTAL_NUMBER_OF_CELLS - 1 --End cell id =  FIRST_CELL_ID + NUMBER_OF_CELLS - 1, Ex: = 7+6-1
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 0 --Total number of SGW/PGW in core network
MME_Count = 1 --Total number of MME in core network

---------------------------------------------------------------------------------------------------
--UE DISTRIBUTION
---------------------------------------------------------------------------------------------------
--[[
Scenario                 UE group id for cell 1-6          No UEs/CELL      
																		
A-D+SCell ADD-DEL        --->1-18                             21          
A-D+DEL                  --->19-36                            128         
PAG                      --->37-54                            130         
ST                       --->55-72                            130         
INTRA-GNB+INTRA FREQ     --->73-90                            31          
INTRA-GNB+INTER FREQ     --->91-108                           7          
INTER-GNB+INTRA FREQ     --->109-126                          10          
INTER-GNB+INTER FREQ     --->127-148                          2          
RNA                      --->149-162                          408         
TAU                      --->163-180                          4           
Ad DRB                   --->181-198                          6           
VoNR                     --->199-216                          15         

--]]



UE_A_D_SCELL_ADD_DEL=3
UE_A_D_SCELL_ADD=18
UE_PAG=11
UE_ST=10
UE_IN_GNB_IN_FREQ=3
UE_IN_GNB_ITR_FREQ=2
UE_ITR_GNB_IN_FREQ=1
UE_ITR_GNB_ITR_FREQ=1
UE_RNA=135
UE_TAU=2
UE_Ad_DRB=1
UE_VoNR=5

START_UE_A_D_SCELL_ADD_DEL = 1
END_UE_A_D_SCELL_ADD_DEL = TOTAL_NUMBER_OF_CELLS*UE_A_D_SCELL_ADD_DEL

START_UE_A_D_SCELL_ADD = END_UE_A_D_SCELL_ADD_DEL + 1
END_UE_A_D_SCELL_ADD = START_UE_A_D_SCELL_ADD + (TOTAL_NUMBER_OF_CELLS*UE_A_D_SCELL_ADD)-1

START_UE_PAG = END_UE_A_D_SCELL_ADD + 1
END_UE_PAG = START_UE_PAG + (TOTAL_NUMBER_OF_CELLS*UE_PAG)-1

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
                    "18:2",
                    "19:0",
					"19:1",
					"19:2",
					"20:0",
					"20:1",
					"20:2",
					"21:0",
					"21:1",
                    "21:2",
                    "22:0",
                    "22:1",
					}  -- phycical cell ids configured in table.
					
NR_ARFCN_TABLE 	= { "390000:424000",
                    "349000:364000",
                    "353000:368000",
					"390000:424000",
                    "349000:364000",
                    "353000:368000",
					"390000:424000",
                    "349000:364000",
                    "353000:368000",
					"390000:424000",
                    "349000:364000",
                    "353000:368000",
					"390000:424000",
                    "349000:364000",
                    "353000:368000",
					"390000:424000",
                    "349000:364000",
                    "353000:368000",
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

GSCN_TABLE    =   { "5297",
					"4547",
					"4600",
					"5297",
					"4547",
					"4600",
					"5297",
					"4547",
					"4600",
					"5297",
					"4547",
					"4600",
					"5297",
					"4547",
					"4600",
					"5297",
					"4547",
					"4600"
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

SIM_GNB_PCI_TABLE	= { "0:1",
                        "0:2",
    					"1:0",
	    				}  -- 6 phycical cell ids configured in table

SIM_GNB_NR_ARFCN_TABLE 	= { "390000:424000",
							"349000:364000",
							"353000:368000"
                        }  
SIM_GSCN_TABLE  = 	{ 	"5297",
						"4547",
						"4600",
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
	exec('set_cell id=1 gnb='..sim_nrci_i..' pci='..SIM_GNB_PCI_TABLE[simgnb_id]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':9999|'..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[simgnb_id]..' mandatory_for_activation=off gscn='..SIM_GSCN_TABLE[simgnb_id]..'')
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
exec('set_trf_data_profile profile_id=1 trf_id=1  size=178 kbps=176  seconds=8')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=859 kbps=1166  seconds=8') --- started on 2 non-gBR DRB per UE
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
UE_FLAG = 1
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


--Attach-Detach with SCell-add--

ue_group_id = 19
SA_CELLID = 1
UE_FiLAG = 1
for SA_UEID =START_UE_A_D_SCELL_ADD,END_UE_A_D_SCELL_ADD do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 19
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

---Paging---

ue_group_id = 37
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_PAG,END_UE_PAG  do
    if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 37
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--UE state transition--

ue_group_id = 55
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_ST,END_UE_ST  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 55
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Intra-gNB_Intra_Freq-----

ue_group_id = 73
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_IN_GNB_IN_FREQ,END_UE_IN_GNB_IN_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 73
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Intra-gNB_Inter_Freq----

ue_group_id = 91 
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_IN_GNB_ITR_FREQ,END_UE_IN_GNB_ITR_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 91
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Inter-gNB_Intra-Freq----

ue_group_id = 109
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_ITR_GNB_IN_FREQ,END_UE_ITR_GNB_IN_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 109
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----Inter-gNB_Inter-Freq----

ue_group_id = 127
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_ITR_GNB_ITR_FREQ,END_UE_ITR_GNB_ITR_FREQ  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 127
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

----RNA-----

ue_group_id = 145
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_RNA,END_UE_RNA  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 145
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--- TAU------

ue_group_id = 163
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_TAU,END_UE_TAU  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 163
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

-----Additional DRB-------------

ue_group_id = 181
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_Ad_DRB,END_UE_Ad_DRB  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 181
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1")
	ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

-----VoNR-----

ue_group_id = 199
SA_CELLID = 1
UE_FLAG = 1
for SA_UEID = START_UE_VoNR,END_UE_VoNR  do
	if SA_CELLID > END_CELL_ID then
			SA_CELLID = FIRST_CELL_ID
			ue_group_id = 199
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
--PET_SE Scell add-del cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
		exec('seq_set id=1 name=scell-add-del-1-2 ue_group=1')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
		exec('seq_delay 4')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=2 name=scell-add-del-1-2 ue_group=2')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=3 name=scell-add-del-1-2 ue_group=3')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=4 name=scell-add-del-1-2 ue_group=4')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=5 name=scell-add-del-1-2 ue_group=5')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=6 name=scell-add-del-1-2 ue_group=6')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=7 name=scell-add-del-1-2 ue_group=7')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=8 name=scell-add-del-1-2 ue_group=8')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=9 name=scell-add-del-1-2 ue_group=9')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=10 name=scell-add-del-1-2 ue_group=10')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=11 name=scell-add-del-1-2 ue_group=11')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=12 name=scell-add-del-1-2 ue_group=12')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=13 name=scell-add-del-1-2 ue_group=13')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=14 name=scell-add-del-1-2 ue_group=14')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=15 name=scell-add-del-1-2 ue_group=15')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=16 name=scell-add-del-1-2 ue_group=16')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=17 name=scell-add-del-1-2 ue_group=17')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=367970 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=18 name=scell-add-del-1-2 ue_group=18')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 4')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=423850 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=363850 src_rsrp_nr=10 src_rsrq_nr=10 scell=2')
        exec('seq_delay 4')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

----------------------------------------------------
--UE ST+CA scell add only
----------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-1->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
		exec('seq_set id=19 name=scell-add-del-1-2 ue_group=19')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 0.2')
		exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 8')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-2->cell-1 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=20 name=scell-add-del-1-2 ue_group=20')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-3->cell-2 and cell-3
---------------------------------------------------------------------------------------------------
        exec('seq_set id=21 name=scell-add-del-1-2 ue_group=21')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-4->cell-5 and cell-6
---------------------------------------------------------------------------------------------------
        exec('seq_set id=22 name=scell-add-del-1-2 ue_group=22')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
		exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
		exec('seq_delay 8') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-5->cell-4 and cell-6
---------------------------------------------------------------------------------------------------
        exec('seq_set id=23 name=scell-add-del-1-2 ue_group=23')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-6->cell-4 and cell-5
---------------------------------------------------------------------------------------------------
        exec('seq_set id=24 name=scell-add-del-1-2 ue_group=24')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-7->cell-8 and cell-9
---------------------------------------------------------------------------------------------------
        exec('seq_set id=25 name=scell-add-del-1-2 ue_group=25')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-8->cell-7 and cell-9
---------------------------------------------------------------------------------------------------
        exec('seq_set id=26 name=scell-add-del-1-2 ue_group=26')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 8') 
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-9->cell-7 and cell-8
---------------------------------------------------------------------------------------------------
        exec('seq_set id=27 name=scell-add-del-1-2 ue_group=27')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-10->cell-11 and cell-12
---------------------------------------------------------------------------------------------------
        exec('seq_set id=28 name=scell-add-del-1-2 ue_group=28')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-11->cell-10 and cell-12
---------------------------------------------------------------------------------------------------
        exec('seq_set id=29 name=scell-add-del-1-2 ue_group=29')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
		exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-12->cell-10 and cell-11
---------------------------------------------------------------------------------------------------
        exec('seq_set id=30 name=scell-add-del-1-2 ue_group=30')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2') 
		exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-13->cell-14 and cell-15
---------------------------------------------------------------------------------------------------
        exec('seq_set id=31 name=scell-add-del-1-2 ue_group=31')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-14->cell-13 and cell-15
---------------------------------------------------------------------------------------------------
        exec('seq_set id=32 name=scell-add-del-1-2 ue_group=32')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
		exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-15->cell-13 and cell-14
---------------------------------------------------------------------------------------------------
        exec('seq_set id=33 name=scell-add-del-1-2 ue_group=33')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-16->cell-17 and cell-18
---------------------------------------------------------------------------------------------------
        exec('seq_set id=34 name=scell-add-del-1-2 ue_group=34')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=423850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-17->cell-16 and cell-18
---------------------------------------------------------------------------------------------------
        exec('seq_set id=35 name=scell-add-del-1-2 ue_group=35')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=363850')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell-18->cell-16 and cell-17
---------------------------------------------------------------------------------------------------
        exec('seq_set id=36 name=scell-add-del-1-2 ue_group=36')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=367970')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')




-----------------------------------------
--Paging
------------------------------------------

	for seq_gr_id = 37,54 do
		exec('seq_set id='..seq_gr_id..' name=PagingStartStop-'..seq_gr_id..' ue_group='..seq_gr_id..'')
		exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_loop_start loop='..LOOP_count..'')
            exec('seq_delay '..ue_active_delay..'')
            exec('amf_paging_start id=1-5')
		exec("seq_loop_end")
        exec("ue_im_exit by=ue")
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
    end
	
---------------------------------------------------
--UE state transition:
--------------------------------------------------------

	for seq_gr_id = 55,72 do		
		exec('seq_set id='..seq_gr_id..' name=Pet_UE_STATE-'..seq_gr_id..' ue_group='..seq_gr_id..'')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 nwslice=1")
        exec('seq_delay 14')
		exec('seq_loop_start loop='..LOOP_count..'')
            exec('seq_delay '..ue_active_delay..'')
            exec("ue_im_exit by=ue")
		exec("seq_loop_end")
        exec("ue_im_exit by=ue")
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
    end
	
---------------------------------------------------------------------------------------------------
-----Intra-GNB-------------------
---------------------------------------------------------------------------------------------------

--Intra Frequency HO Between Cell-1 and Cell-4

		exec('seq_set id=73 name=Intragnb-IntraFreq-HO ue_group=73')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-2 and Cell-5

		exec('seq_set id=74 name=Intragnb-IntraFreq-HO ue_group=74')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-3 and Cell-6

		exec('seq_set id=75 name=Intragnb-IntraFreq-HO ue_group=75')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')		

--Intra Frequency HO Between Cell-4 and Cell-1

		exec('seq_set id=76 name=Intragnb-IntraFreq-HO ue_group=76')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-5 and Cell-2

		exec('seq_set id=77 name=Intragnb-IntraFreq-HO ue_group=77')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-6 and Cell-2

		exec('seq_set id=78 name=Intragnb-IntraFreq-HO ue_group=78')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-7 and Cell-10

		exec('seq_set id=79 name=Intragnb-IntraFreq-HO ue_group=79')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-8 and Cell-11

		exec('seq_set id=80 name=Intragnb-IntraFreq-HO ue_group=80')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-9 and Cell-13

		exec('seq_set id=81 name=Intragnb-IntraFreq-HO ue_group=81')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-10 and Cell-7

		exec('seq_set id=82 name=Intragnb-IntraFreq-HO ue_group=82')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-11 and Cell-8

		exec('seq_set id=83 name=Intragnb-IntraFreq-HO ue_group=83')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-12 and Cell-9

		exec('seq_set id=84 name=Intragnb-IntraFreq-HO ue_group=84')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-13 and Cell-16

		exec('seq_set id=85 name=Intragnb-IntraFreq-HO ue_group=85')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-14 and Cell-17

		exec('seq_set id=86 name=Intragnb-IntraFreq-HO ue_group=86')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-15 and Cell-18

		exec('seq_set id=87 name=Intragnb-IntraFreq-HO ue_group=87')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-16 and Cell-13

		exec('seq_set id=88 name=Intragnb-IntraFreq-HO ue_group=88')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-17 and Cell-14

		exec('seq_set id=89 name=Intragnb-IntraFreq-HO ue_group=89')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-18 and Cell-15

		exec('seq_set id=90 name=Intragnb-IntraFreq-HO ue_group=90')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')		

--Inter Frequency HO Between Cell-1 and Cell-6

		exec('seq_set id=91 name=Intragnb-IntraFreq-HO ue_group=91')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-2 and Cell-4

		exec('seq_set id=92 name=Intragnb-IntraFreq-HO ue_group=92')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-3 and Cell-5

		exec('seq_set id=93 name=Intragnb-IntraFreq-HO ue_group=93')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-4 and Cell-3

		exec('seq_set id=94 name=Intragnb-IntraFreq-HO ue_group=94')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-5 and Cell-1

		exec('seq_set id=95 name=Intragnb-IntraFreq-HO ue_group=95')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-6 and Cell-2

		exec('seq_set id=96 name=Intragnb-IntraFreq-HO ue_group=96')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-7 and Cell-12

		exec('seq_set id=97 name=Intragnb-IntraFreq-HO ue_group=97')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-8 and Cell-10

		exec('seq_set id=98 name=Intragnb-IntraFreq-HO ue_group=98')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-9 and Cell-11

		exec('seq_set id=99 name=Intragnb-IntraFreq-HO ue_group=99')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-10 and Cell-9

		exec('seq_set id=100 name=Intragnb-IntraFreq-HO ue_group=100')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-11 and Cell-7

		exec('seq_set id=101 name=Intragnb-IntraFreq-HO ue_group=101')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-12 and Cell-8

		exec('seq_set id=102 name=Intragnb-IntraFreq-HO ue_group=102')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-13 and Cell-18

		exec('seq_set id=103 name=Intragnb-IntraFreq-HO ue_group=103')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-14 and Cell-16

		exec('seq_set id=104 name=Intragnb-IntraFreq-HO ue_group=104')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-15 and Cell-17

		exec('seq_set id=105 name=Intragnb-IntraFreq-HO ue_group=105')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-16 and Cell-15

		exec('seq_set id=106 name=Intragnb-IntraFreq-HO ue_group=106')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-17 and Cell-13

		exec('seq_set id=107 name=Intragnb-IntraFreq-HO ue_group=107')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-18 and Cell-14

		exec('seq_set id=108 name=Intragnb-IntraFreq-HO ue_group=108')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
-----Inter-GNB-------------------
---------------------------------------------------------------------------------------------------

--Intra Frequency HO Between Cell-1 and sim-gNB-3

		exec('seq_set id=109 name=Intergnb-IntraFreq-HO ue_group=109')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-2 and sim-gNB-4

		exec('seq_set id=110 name=Intergnb-IntraFreq-HO ue_group=110')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-3 and sim-gNB-5

		exec('seq_set id=111 name=Intergnb-IntraFreq-HO ue_group=111')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')		

--Intra Frequency HO Between Cell-4 and sim-gNB-3

		exec('seq_set id=112 name=Intergnb-IntraFreq-HO ue_group=112')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-5 and sim-gNB-4

		exec('seq_set id=113 name=Intergnb-IntraFreq-HO ue_group=113')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-6 and sim-gNB-5

		exec('seq_set id=114 name=Intergnb-IntraFreq-HO ue_group=114')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-7 and sim-gNB-3

		exec('seq_set id=115 name=Intergnb-IntraFreq-HO ue_group=115')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-8 and sim-gNB-4

		exec('seq_set id=116 name=Intergnb-IntraFreq-HO ue_group=116')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-9 and sim-gNB-5

		exec('seq_set id=117 name=Intergnb-IntraFreq-HO ue_group=117')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-10 and sim-gNB-3

		exec('seq_set id=118 name=Intergnb-IntraFreq-HO ue_group=118')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-11 and sim-gNB-4

		exec('seq_set id=119 name=Intergnb-IntraFreq-HO ue_group=119')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-12 and sim-gNB-5

		exec('seq_set id=120 name=Intergnb-IntraFreq-HO ue_group=120')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-13 and sim-gNB-3

		exec('seq_set id=121 name=Intergnb-IntraFreq-HO ue_group=121')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-14 and sim-gNB-4

		exec('seq_set id=122 name=Intergnb-IntraFreq-HO ue_group=122')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-15 and sim-gNB-5

		exec('seq_set id=123 name=Intergnb-IntraFreq-HO ue_group=123')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-16 and sim-gNB-3

		exec('seq_set id=124 name=Intergnb-IntraFreq-HO ue_group=124')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Intra Frequency HO Between Cell-17 and sim-gNB-4

		exec('seq_set id=125 name=Intergnb-IntraFreq-HO ue_group=125')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Intra Frequency HO Between Cell-18 and sim-gNB-5

		exec('seq_set id=126 name=Intergnb-IntraFreq-HO ue_group=126')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')		

--------------------------------------------------------------------------------------------

--Inter Frequency HO Between Cell-1 and sim-gNB-5

		exec('seq_set id=127 name=Intergnb-IntraFreq-HO ue_group=127')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-2 and sim-gNB-3

		exec('seq_set id=128 name=Intergnb-IntraFreq-HO ue_group=128')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-3 and sim-gNB-4

		exec('seq_set id=129 name=Intergnb-IntraFreq-HO ue_group=129')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-4 and sim-gNB-5

		exec('seq_set id=130 name=Intergnb-IntraFreq-HO ue_group=130')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-5 and sim-gNB-3

		exec('seq_set id=131 name=Intergnb-IntraFreq-HO ue_group=131')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-6 and sim-gNB-4

		exec('seq_set id=132 name=Intergnb-IntraFreq-HO ue_group=132')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-7 and sim-gNB-5

		exec('seq_set id=133 name=Intergnb-IntraFreq-HO ue_group=133')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-8 and sim-gNB-3

		exec('seq_set id=134 name=Intergnb-IntraFreq-HO ue_group=134')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-9 and sim-gNB-4

		exec('seq_set id=135 name=Intergnb-IntraFreq-HO ue_group=135')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-10 and sim-gNB-5

		exec('seq_set id=136 name=Intergnb-IntraFreq-HO ue_group=136')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-11 and sim-gNB-3

		exec('seq_set id=137 name=Intergnb-IntraFreq-HO ue_group=137')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-12 and sim-gNB-4

		exec('seq_set id=138 name=Intergnb-IntraFreq-HO ue_group=138')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-13 and sim-gNB-5

		exec('seq_set id=139 name=Intergnb-IntraFreq-HO ue_group=139')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-14 and sim-gNB-3

		exec('seq_set id=140 name=Intergnb-IntraFreq-HO ue_group=140')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-15 and sim-gNB-4

		exec('seq_set id=141 name=Intergnb-IntraFreq-HO ue_group=141')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-16 and sim-gNB-5

		exec('seq_set id=142 name=Intergnb-IntraFreq-HO ue_group=142')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=3 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
		
--Inter Frequency HO Between Cell-17 and sim-gNB-3

		exec('seq_set id=143 name=Intergnb-IntraFreq-HO ue_group=143')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=423850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
	
--Inter Frequency HO Between Cell-18 and sim-gNB-4

		exec('seq_set id=144 name=Intergnb-IntraFreq-HO ue_group=144')
        exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=363850')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=367970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
-----RNA-------------------
---------------------------------------------------------------------------------------------------


for seq_gr_id = 145,162 do		

    exec('seq_set id='..seq_gr_id..' name=RNA-'..seq_gr_id..' ue_group='..seq_gr_id..'')	
	exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=750 size=1350 seconds=8')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=125 size=1350 seconds=8')			
	exec('seq_delay '..duration)
    exec("ue_im_exit by=ue")
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

end	

---------------------------------------------------------------------------------------------------
-----TAU-------------------
---------------------------------------------------------------------------------------------------

for seq_gr_id = 163,180 do		

		exec('seq_set id='..seq_gr_id..' name=TAU-'..seq_gr_id..' ue_group='..seq_gr_id..'')
		exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration'	)
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_loop_start loop='..TAU_LOOP_count..'')
			exec('seq_delay 16')
			exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg reactivate_pdu=off use_suci=off registration_type=MobilityRegistrationUpdting')
		exec("seq_loop_end"	)
		exec('seq_delay 3'	)
        exec("ue_im_exit by=ue")
		exec('ue_deregister by=ue ue_deregister_type=switch_off')	
		exec('seq_end')

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DRB addition:
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
for seq_gr_id =181,198 do

    exec('seq_set id='..seq_gr_id..' name=Pet_PDU-add-del'..seq_gr_id..' ue_group='..seq_gr_id..'')
    exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 0.1')
	exec("ue_pdu_session_setup pdu=2 nwslice=1")
    exec('seq_delay 8')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---VONR-------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

for seq_gr_id = 199,216 do

    exec('seq_set id='..seq_gr_id..' name=Pet_VONR'..seq_gr_id..' ue_group='..seq_gr_id..'')
    exec('ue_register ue_nr_capabilities=VTM_BW40 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1 nwslice=1")
    exec('seq_delay 0.1')
    exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
    exec('seq_delay 120')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
end		

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
exec('debug_log level=4 uec=1-6 amf=1-5 max_file_num=50 max_log_size=200M')
exec('sim_param_set ENABLE_CORE_LIMIT=on')
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=200M')
exec('sim_start version_check=off')

end
