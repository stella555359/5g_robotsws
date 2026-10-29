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
for ip2 = 3, 31 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

os.execute('sudo ip addr add 2a00:8a00:4000:4504::138c/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::138d/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::138e/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::138f/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::1390/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::1391/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::1392/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::1393/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::1394/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::1395/123 dev eth3.490')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13ac/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13ad/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13ae/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13af/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13b0/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13b1/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13b2/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13b3/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13b4/123 dev eth3.500')
os.execute('sudo ip addr add 2a00:8a00:4000:4504::13b5/123 dev eth3.500')

--os.execute('sudo ip route add 2a00:8a00:4000:4504::16d8/124 via 2a00:8a00:4000:4504::1381 dev eth3.490') --CPLANE
--os.execute('sudo ip route add 2a00:8a00:4000:4504::1710/124 via 2a00:8a00:4000:4504::13a1 dev eth3.500') --UPLANE

os.execute('sudo sysctl -w net.sctp.rto_min=100')
os.execute('sudo sysctl -w net.sctp.sack_timeout=200')
os.execute('sudo sysctl -w net.sctp.rto_initial=3000')
os.execute('sudo sysctl -w net.sctp.rto_max=60000')
os.execute('sudo sysctl -w net.core.wmem_max=20971520')
os.execute('sudo sysctl -w net.core.wmem_default=20971520')
os.execute('sudo sysctl -w net.core.rmem_max=20971520')
os.execute('sudo sysctl -w net.core.rmem_default=20971520')
--os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

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
NUMBER_OF_CELLS_IN_AP1 = 12 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 12   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
SA_UE_COUNT_PER_CELL = 900 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 0 --NSA UE Count per cell
sim_gNBs = 2	--Sim-gNBs for Handover

FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 18001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 20     --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = 240 --TOTAL_NUMBER_OF_CELLS	--Total Number of Sequence_set groups

END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 0 --Total number of SGW/PGW in core network
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
							12,
							}	--Cells belong to Airphone-1

CELL_ID_TABLE_FOR_AP2	= { 13,
							14,
							15,
							16,
							17,
							18,
							}	--Cells belong to Airphone-2

CELL_TECH_TABLE_OF_AP1	= { "FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							}	--Cells Tech of Airphone-1

CELL_TECH_TABLE_OF_AP2	= { "FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							"FDD",
							}	--Cells Tech of Airphone-2

AMF_IP_TABLE 	= { "2a00:8a00:4000:4504::138c",
                    "2a00:8a00:4000:4504::138d",
                    "2a00:8a00:4000:4504::138e",
                    "2a00:8a00:4000:4504::138f",
                    "2a00:8a00:4000:4504::1390",
                    }  --IP table for each AMF

UPF_NG_IP_TABLE  = { "2a00:8a00:4000:4504::13ac",
                     "2a00:8a00:4000:4504::13ad",
                     "2a00:8a00:4000:4504::13ae",
                     "2a00:8a00:4000:4504::13af",
                     "2a00:8a00:4000:4504::13b0",
                   }  --IP table for each UPF_NF

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
					}  -- 12 phycical cell ids configured in table.
                       -- PCI 16:2 = (16x3) + 2 = 50, 17:0 = 51 ...
                       -- Compare with gNB commissioning and align
                       -- with NUMBER_OF_CELLS parameter

NR_ARFCN_TABLE 	= { "351740:436740",
                    "135760:126380",
                    "351740:436740",
                    "135760:126380",
                    "351740:436740",
                    "135760:126380",
                    "351740:436740",
                    "135760:126380",
                    "351740:436740",
					"135760:126380",
					"351740:436740",
					"135760:126380",
                    }  --NRARFCN UL:DL for each cell for Multi-AP

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
                    }  --PLMN table for Multi-AP

GSCN_TABLE    =   {   "5460",
                      "1582",
					  "5460",
					  "1582",
					  "5460",
                      "1582",
					  "5460",
					  "1582",
					  "5460",
					  "1582",
					  "5460",
					  "1582",
                    }  --GSCN Table with absolute value for Multi-AP

SIM_GSCN_TABLE = 	{	"5460",
						"1582",
                    }   --Table for GSCN

SIM_GNB_SERVER_IP_TABLE	= { "10.0.2.14",
                	        "10.0.2.15",
                	        "10.0.2.16",
            	           }  --Daemon IP table for each sim-gNB

SIM_GNB_XN_IP_TABLE	= { "2a00:8a00:4000:4504::1391",
                	    "2a00:8a00:4000:4504::1392",
                	    "2a00:8a00:4000:4504::13b1",
           	           }  --XN IP table for each sim-gNB

SIM_GNB_NG_IP_TABLE	= { "2a00:8a00:4000:4504::1393",
                	    "2a00:8a00:4000:4504::1394",
                	    "2a00:8a00:4000:4504::13b2",
        	           }  --NG IP table for each sim-gNB

SIM_GNB_PCI_TABLE	= { "20:2",
                        "21:0",
	    				}  -- 2 phycical cell ids configured in table

SIM_GNB_NR_ARFCN_TABLE 	= { "351740:436740",
							"135760:126380"
        					}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---UE assigmnent -----------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = 1                                            --1
LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 95      --96
FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 1       --97
LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 47      --144
FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 1       --145
LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 59      --204
FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA = LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 1       --205
LAST_INTER_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA + 11      --216
FIRST_CA_SCELL_ADD_UE_SA = LAST_INTER_gNB_INTER_FREQ_HO_UE_SA + 1                  --217
LAST_CA_SCELL_ADD_UE_SA = FIRST_CA_SCELL_ADD_UE_SA + 767                           --984
FIRST_CA_SCELL_ADD_DEL_UE_SA = LAST_CA_SCELL_ADD_UE_SA + 1                         --985
LAST_CA_SCELL_ADD_DEL_UE_SA = FIRST_CA_SCELL_ADD_DEL_UE_SA + 131                   --1116
FIRST_ADITIONAL_DRB_ADD_UE_SA = LAST_CA_SCELL_ADD_DEL_UE_SA + 1                    --1117
LAST_ADITIONAL_DRB_ADD_UE_SA  = FIRST_ADITIONAL_DRB_ADD_UE_SA + 35                 --1152
FIRST_VONR_DRB_ADD_UE_SA = LAST_ADITIONAL_DRB_ADD_UE_SA + 1                        --1153
LAST_VONR_DRB_ADD_UE_SA = FIRST_VONR_DRB_ADD_UE_SA + 83                            --1236
FIRST_ATTACH_DETACH_UE_SA = LAST_VONR_DRB_ADD_UE_SA + 1                            --1237
LAST_ATTACH_DETACH_UE_SA = FIRST_ATTACH_DETACH_UE_SA + 83                          --1320
FIRST_TAU_UPDATE_UE_SA = LAST_ATTACH_DETACH_UE_SA + 1                              --1321
LAST_TAU_UPDATE_UE_SA = FIRST_TAU_UPDATE_UE_SA + 23                                --1344
FIRST_STATE_TRASITION_UE_SA = LAST_TAU_UPDATE_UE_SA + 1			                   --1345
LAST_STATE_TRASITION_UE_SA = FIRST_STATE_TRASITION_UE_SA + 779                     --2124
FIRST_PAGING_UE_SA = LAST_STATE_TRASITION_UE_SA + 1                                --2125
LAST_PAGING_UE_SA = FIRST_PAGING_UE_SA + 779                                  	   --2904
FIRST_RNA_UE_SA = LAST_PAGING_UE_SA + 1                                            --2905
LAST_RNA_UE_SA = FIRST_RNA_UE_SA + 2447                                            --5352

FIRST_NORMAL_UE_SA_CELL1 = LAST_RNA_UE_SA + 1                                      --5353
FIRST_NORMAL_UE_SA_CELL2 = FIRST_NORMAL_UE_SA_CELL1 + 380                          --5733
FIRST_NORMAL_UE_SA_CELL3 = FIRST_NORMAL_UE_SA_CELL2 + 380                          --6113
FIRST_NORMAL_UE_SA_CELL4 = FIRST_NORMAL_UE_SA_CELL3 + 380                          --6493
FIRST_NORMAL_UE_SA_CELL5 = FIRST_NORMAL_UE_SA_CELL4 + 380                          --6893
FIRST_NORMAL_UE_SA_CELL6 = FIRST_NORMAL_UE_SA_CELL5 + 380                          --7253
FIRST_NORMAL_UE_SA_CELL7 = FIRST_NORMAL_UE_SA_CELL6 + 380                          --7633
FIRST_NORMAL_UE_SA_CELL8 = FIRST_NORMAL_UE_SA_CELL7 + 380                          --8013
FIRST_NORMAL_UE_SA_CELL9 = FIRST_NORMAL_UE_SA_CELL8 + 380                          --8393
FIRST_NORMAL_UE_SA_CELL10 = FIRST_NORMAL_UE_SA_CELL9 + 380                         --8773
FIRST_NORMAL_UE_SA_CELL11 = FIRST_NORMAL_UE_SA_CELL10 + 380                         --9153
FIRST_NORMAL_UE_SA_CELL12 = FIRST_NORMAL_UE_SA_CELL11 + 380                         --9533
LAST_NORMAL_UE_SA_CELL12 = FIRST_NORMAL_UE_SA_CELL12 + 380                          --9913

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
GNB_X2_ADDR="2a00:8a00:4000:4504::16da"
GNB_XN_ADDR="2a00:8a00:4000:4504::16da"
GNB_NG_ADDR="2a00:8a00:4000:4504::16da"

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

GNB3_NG_ADDR="2a00:8a00:4000:4504::1393"
GNB3_XN_ADDR="2a00:8a00:4000:4504::1391"
GNB4_NG_ADDR="2a00:8a00:4000:4504::1394"
GNB4_XN_ADDR="2a00:8a00:4000:4504::1392"
GNB5_NG_ADDR="2a00:8a00:4000:4504::13b2"
GNB5_XN_ADDR="2a00:8a00:4000:4504::13b1"

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
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..'.36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..'')

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
	exec('gnb_param id='..sim_nrci_i..' xn_listening_socket=on send_xn_setup=on sib1_period=2000 measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
	exec('enb_timer T_RELOCprepTimeout=2000')
	exec('set_cell id=1 gnb='..sim_nrci_i..' pci='..SIM_GNB_PCI_TABLE[simgnb_id]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':9999|'..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[simgnb_id]..' mandatory_for_activation=off gscn='..SIM_GSCN_TABLE[simgnb_id]..' suggested_band=66')
	end
end

--SIM-GNB FOR CORE GENERATION [this gnb will send signal to egate to collect core when hung]
local simgnb_dummy = sim_gNBs + 3
local simgnb_dummy_ip = 3
exec('set_gnb id='..simgnb_dummy..' hb_failure_action=true plmn='..PLMN..' xn='..SIM_GNB_XN_IP_TABLE[simgnb_dummy_ip]..' ng='..SIM_GNB_NG_IP_TABLE[simgnb_dummy_ip]..' gnb_id=0x01:32')

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
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' name=SimModeAMF-'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..'.38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
    exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
    exec('set_upf id='..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[array_id]..'/21 ngu='..UPF_NG_IP_TABLE[array_id]..' devname=tunUPF'..amf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

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
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500 disable_sib1_flood=true disable_sib_during_ho=true')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
end

--Traffic profile creation
-------------------------------------------------------------------------------------------------------
exec('set_trf_data_profile profile_id=1 trf_id=1 size=355 kbps=88 seconds=9')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1 size=1277 kbps=538 seconds=9') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1 size=60 kbps=50 seconds=120')  -----> for VNR same traffic in DL and UL
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
--SA UEs allocation for each traffic model
-------------------------------------------------------------------

--Intra_gnb HO_intra_freq--
SA_FLAG = 1
ue_group_id = 1
SA_CELLID = 1
for SA_UEID = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA, LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 1
        SA_CELLID = 1
    end
    exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--Inter_gnb_intra_freq HO-
SA_FLAG = 1
ue_group_id = 13
SA_CELLID = 1
for SA_UEID = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA, LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 13
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
	ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--Inter_gnb_inter_freq HO--
SA_FLAG = 1
ue_group_id = 25
SA_CELLID = 1
for SA_UEID = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA, LAST_INTER_gNB_INTER_FREQ_HO_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 25
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--CA_scell add--
SA_FLAG = 1
ue_group_id = 37
SA_CELLID = 1
for SA_UEID = FIRST_CA_SCELL_ADD_UE_SA, LAST_CA_SCELL_ADD_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 37
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--CA_scell add/del--
SA_FLAG = 1
ue_group_id = 49
SA_CELLID = 1
for SA_UEID = FIRST_CA_SCELL_ADD_DEL_UE_SA, LAST_CA_SCELL_ADD_DEL_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 49
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

---AdditionalDRB---
SA_CELLID = 1
ue_group_id = 61
SA_CELLID = 1
for SA_UEID = FIRST_ADITIONAL_DRB_ADD_UE_SA, LAST_ADITIONAL_DRB_ADD_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 61
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
	exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

-----VONR------
SA_CELLID = 1
ue_group_id = 73
SA_CELLID = 1
for SA_UEID = FIRST_VONR_DRB_ADD_UE_SA, LAST_VONR_DRB_ADD_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 73
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
--	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1 qfi=3 trf_prof_dl=3 trf_prof_ul=3")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--Attach+detach--
SA_CELLID = 1
ue_group_id = 85
SA_CELLID = 1
for SA_UEID = FIRST_ATTACH_DETACH_UE_SA, LAST_ATTACH_DETACH_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 85
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--TAU--
SA_CELLID = 1
ue_group_id = 97
SA_CELLID = 1
for SA_UEID = FIRST_TAU_UPDATE_UE_SA, LAST_TAU_UPDATE_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 97
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--UE_State transition--
SA_CELLID = 1
ue_group_id = 109
SA_CELLID = 1
for SA_UEID = FIRST_STATE_TRASITION_UE_SA, LAST_STATE_TRASITION_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 109
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

---Paging-----
SA_CELLID = 1
ue_group_id = 121
SA_CELLID = 1
for SA_UEID = FIRST_PAGING_UE_SA, LAST_PAGING_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 121
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
 end

--RNA--
SA_CELLID = 1
ue_group_id = 133
SA_CELLID = 1
for SA_UEID = FIRST_RNA_UE_SA, LAST_RNA_UE_SA do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 133
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
 end


--NORMAL TEST--
SA_CELLID = 1
ue_group_id = 145
SA_CELLID = 1
SA_FLAG = 1
for SA_UEID = FIRST_NORMAL_UE_SA_CELL1, LAST_NORMAL_UE_SA_CELL12 do
    if SA_FLAG == 13 then
        SA_FLAG = 1
        ue_group_id = 145
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
  exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2 trf_prof_ul=1 qfi=3 trf_prof_dl=3 trf_prof_ul=3")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
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
		exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=NSA_TDD_4CC dual_conn=eutra_nr ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg')
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
--Multi-DRB configuration for SA UEs
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
exec('set_nwslice id=1 qos_flows=1,2,3 snssai='..SNSSAI..' default=on ue=all amf_region_id='..FIRST_AMF_ID..'-'..END_AMF_ID..' plmn_list='..PLMN)
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-------------------------------------------------------------------------------------------------------
if PET_SE_FLAG == 'yes' then


-----Intra-GNB [ Intra & Inter freq ]-
--------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell1 to cell2 & viceversa(Inter-freq)
--------------------------------------------------------------------------------------------------
	exec('seq_set id=1 name=Intragnb-HO ue_group=1')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
--------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell2 to cell4 & viceversa(Intra-freq)
--------------------------------------------------------------------------------------------------
	exec('seq_set id=2 name=Intragnb-HO ue_group=2')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
--------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell3 to cell1 & viceversa(Intra-freq)
--------------------------------------------------------------------------------------------------
	exec('seq_set id=3 name=Intragnb-HO ue_group=3')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
--------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell4 to cell3 & viceversa(Inter-freq)
--------------------------------------------------------------------------------------------------
	exec('seq_set id=4 name=Intragnb-HO ue_group=4')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
--------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell5 to cell6 & viceversa(Inter-freq)
--------------------------------------------------------------------------------------------------
	exec('seq_set id=5 name=Intragnb-HO ue_group=5')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
--------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell6 to cell8 & viceversa(Intra-freq)
--------------------------------------------------------------------------------------------------
	exec('seq_set id=6 name=Intragnb-HO ue_group=6')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell7 to cell5 & viceversa [Intra freq]
---------------------------------------------------------------------------------------------------
	exec('seq_set id=7 name=Intragnb-HO  ue_group=7')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell8 to cell7 & viceversa [Inter freq]
---------------------------------------------------------------------------------------------------
	exec('seq_set id=8 name=Intragnb-HO  ue_group=8')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell9 to cell10 & viceversa [Inter freq]
---------------------------------------------------------------------------------------------------
	exec('seq_set id=9 name=Intragnb-HO  ue_group=9')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell10 to cell12 & viceversa [Intra freq]
---------------------------------------------------------------------------------------------------
	exec('seq_set id=10 name=Intragnb-HO  ue_group=10')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell11 to cell9 & viceversa [Intra freq]
---------------------------------------------------------------------------------------------------
	exec('seq_set id=11 name=Intragnb-HO  ue_group=11')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell12 to cell11 & viceversa [Inter freq]
---------------------------------------------------------------------------------------------------
	exec('seq_set id=12 name=Intragnb-HO  ue_group=12')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3.5')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

----Inter-GNB Intra freq-------
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell1 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=13 name=Intergnb-HO ue_group=13')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell2 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=14 name=Intergnb-HO ue_group=14')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell3 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=15 name=Intergnb-HO  ue_group=15')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell4 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=16 name=Intergnb-HO  ue_group=16')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell5 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=17 name=Intergnb-HO  ue_group=17')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell6 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=18 name=Intergnb-HO  ue_group=18')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell7 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=19 name=Intergnb-HO ue_group=19')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell8 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=20 name=Intergnb-HO ue_group=20')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell9 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=21 name=Intergnb-HO  ue_group=21')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell10 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=22 name=Intergnb-HO  ue_group=22')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell11 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=23 name=Intergnb-HO  ue_group=23')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell12 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=24 name=Intergnb-HO  ue_group=24')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
----Inter-GNB Inter freq-------
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell1 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=25 name=Intergnb-HO ue_group=25')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell2 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=26 name=Intergnb-HO ue_group=26')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell3 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=27 name=Intergnb-HO  ue_group=27')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell4 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=28 name=Intergnb-HO  ue_group=28')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell5 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=29 name=Intergnb-HO  ue_group=29')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell6 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=30 name=Intergnb-HO  ue_group=30')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell7 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=31 name=Intergnb-HO ue_group=31')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell8 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=32 name=Intergnb-HO ue_group=32')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell9 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=33 name=Intergnb-HO  ue_group=33')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell10 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=34 name=Intergnb-HO  ue_group=34')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell11 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=35 name=Intergnb-HO  ue_group=35')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell12 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
	exec('seq_set id=36 name=Intergnb-HO  ue_group=36')
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 9')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=436830')
	exec('seq_delay 3')
	exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=126530')
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

--------------------------------------------------------------------------------------------------
----Attach-Detach +CA scell add
--------------------------------------------------------------------------------------------------
--PET_SE Scell add cell1 to cell2
--------------------------------------------------------------------------------------------------
	exec('seq_set id=37 name=scell-add ue_group=37')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell2 to cell11
---------------------------------------------------------------------------------------------------
	exec('seq_set id=38 name=scell-add ue_group=38')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell3 to cell10
---------------------------------------------------------------------------------------------------
	exec('seq_set id=39 name=scell-add ue_group=39')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell4 to cell9
---------------------------------------------------------------------------------------------------
	exec('seq_set id=40 name=scell-add  ue_group=40')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell5 to cell8
---------------------------------------------------------------------------------------------------
	exec('seq_set id=41 name=scell-add  ue_group=41')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell6 to cell7
---------------------------------------------------------------------------------------------------
	exec('seq_set id=42 name=scell-add  ue_group=42')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell7 to cell6
---------------------------------------------------------------------------------------------------
	exec('seq_set id=43 name=scell-add ue_group=43')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell8 to cell5
---------------------------------------------------------------------------------------------------
	exec('seq_set id=44 name=scell-add ue_group=44')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell9 to cell4
---------------------------------------------------------------------------------------------------
	exec('seq_set id=45 name=scell-add  ue_group=45')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell10 to cell3
---------------------------------------------------------------------------------------------------
	exec('seq_set id=46 name=scell-add ue_group=46')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell11 to cell2
---------------------------------------------------------------------------------------------------
	exec('seq_set id=47 name=scell-add-del-5-6  ue_group=47')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell12 to cell1
---------------------------------------------------------------------------------------------------
	exec('seq_set id=48 name=scell-add  ue_group=48')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 7')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

--------------------------------------------------------------------------------------------------
----Attach-Detach +CA scell add & del
--------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to celll2
--------------------------------------------------------------------------------------------------
	exec('seq_set id=49 name=scell-add-del ue_group=49')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=126530 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell11
---------------------------------------------------------------------------------------------------
	exec('seq_set id=50 name=scell-add-del ue_group=50')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=436830 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell10
---------------------------------------------------------------------------------------------------
	exec('seq_set id=51 name=scell-add-del ue_group=51')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=126530 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell9
---------------------------------------------------------------------------------------------------
	exec('seq_set id=52 name=scell-add-del ue_group=52')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=436830 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell8
---------------------------------------------------------------------------------------------------
	exec('seq_set id=53 name=scell-add-del  ue_group=53')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=126530 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell7
---------------------------------------------------------------------------------------------------
	exec('seq_set id=54 name=scell-add-del  ue_group=54')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=436830 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell7 to cell6
---------------------------------------------------------------------------------------------------
	exec('seq_set id=55 name=scell-add-del ue_group=55')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=126530 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell8 to cell5
---------------------------------------------------------------------------------------------------
	exec('seq_set id=56 name=scell-add-del ue_group=56')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=436830 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell9 to cell4
---------------------------------------------------------------------------------------------------
	exec('seq_set id=57 name=scell-add-del  ue_group=57')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=126530 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell10 to cell3
---------------------------------------------------------------------------------------------------
	exec('seq_set id=58 name=scell-add-del  ue_group=58')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=436830 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell11 to cell2
---------------------------------------------------------------------------------------------------
	exec('seq_set id=59 name=scell-add-del  ue_group=59')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=436830')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=126530 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell12 to cell1
---------------------------------------------------------------------------------------------------
	exec('seq_set id=60 name=scell-add-del  ue_group=60')
	exec('ue_register ue_nr_capabilities=CA_4CC capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('seq_delay 0.2')
	exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=126530')
	exec('seq_delay 4.5')
	exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=436830 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
	exec('seq_delay 4.5')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DRB addition:
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id1 = 61
for seq_gr_id = 61,72 do
	if gr_id1 > 72 then
		gr_id1 = 61
	end
	exec('seq_set id='..seq_gr_id..' name=Pet_PDU-add-del'..seq_gr_id..' ue_group='..gr_id1)
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 0.1')
	exec("ue_pdu_session_setup pdu=2 nwslice=1")
	exec('seq_delay 9')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id1 = gr_id1 + 1
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---VONR-------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id2 = 73

for seq_gr_id = 73,84 do
	if gr_id2 > 84 then
		gr_id2 = 73
	end
	exec('seq_set id='..seq_gr_id..' name=Pet_VONR'..seq_gr_id..' ue_group='..gr_id2)
	exec('ue_register ue_nr_capabilities=VONR_GBR capability_file=./capability.cfg registration_type=InitialRegistration')
	exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 0.1')
	exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
	exec('seq_delay 120')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id2 = gr_id2 + 1
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---AD rate
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id3 = 85

for seq_gr_id = 85,96 do
	if gr_id3 > 96 then
		gr_id3 = 85
	end
	exec('seq_set id='..seq_gr_id..' name=PetAttachDetach-'..seq_gr_id..' ue_group='..gr_id3)
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 9')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id3 = gr_id3 + 1
end

---------------------------------------------------------
--TAU:
---------------------------------------------------------
gr_id4 = 97
for seq_gr_id = 97,108 do
	if gr_id4 > 108 then
	   gr_id4 = 97
	end
	exec('seq_set id='..seq_gr_id..' name=TAU-'..seq_gr_id..' ue_group='..gr_id4)
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	for i=1, 1 do
	   exec("seq_loop_start loop=337")
	   exec('seq_delay 16')
	   exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg reactivate_pdu=off use_suci=off registration_type=MobilityRegistrationUpdting')
	   exec("seq_loop_end")
	end
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id4 = gr_id4 + 1
end

------------------------------------------------------------------------------------------------------------------------------------------------------
--UE state transition:
----------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id5 = 109
for seq_gr_id = 109,120 do
	if gr_id5 > 120 then
	   gr_id5 = 109
	end
	exec('seq_set id='..seq_gr_id..' name=UE_ST'..seq_gr_id..' ue_group='..gr_id5)
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 15')
	exec("seq_loop_start loop=87")
	exec('seq_delay 62')
	exec("ue_im_exit ")
	exec("seq_loop_end")
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id5 = gr_id5 + 1
end
-----------------------------------------
--Paging
------------------------------------------
gr_id6 = 121
for seq_gr_id = 121, 132 do
	if gr_id6 > 132 then
		gr_id6 = 121
	end
	exec('seq_set id='..seq_gr_id..' name=PagingStartStop-'..seq_gr_id..' ue_group='..gr_id6)
--	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_register ue_nr_capabilities=Paging_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
	exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 15')
	exec("seq_loop_start loop=87")
	exec('seq_delay 62')
	exec('amf_paging_start id=1-5')
	exec("seq_loop_end")
	exec('seq_delay 3')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id6 = gr_id6 + 1
end
---------------------------------------------------
--RNA:
---------------------------------------------------
gr_id7 = 133
for seq_gr_id = 133,144 do
	if gr_id7 > 144 then
	   gr_id7 = 133
	end
	exec('seq_set id='..seq_gr_id..' name=RNA-'..seq_gr_id..' ue_group='..gr_id7)
	exec('ue_register ue_nr_capabilities=NR_CAP_4x4 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec("ue_pdu_session_setup pdu=1 nwslice=1")
	exec('seq_delay 5400')
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	gr_id7 = gr_id7 + 1
end


---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR SA Max 375 UES Registration
---------------------------------------------------------------------------------------------------
gr_id = 145

if PET_SE_FLAG == 'yes' then
	for seq_gr_id = 145, 156 do
		if gr_id > UE_GROUP_COUNT then
			gr_id = 145
		end
		exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=VRAN_FDD capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=74 size=42') --74 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=74 size=42') --74 bp
		exec('sleep 0.5')
        exec("ue_pdu_session_modify pdu=1 qosflows_to_del=2")
		exec('sleep '..timer)
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		gr_id = gr_id + 1
	end
end

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR 72 UL Tput
---------------------------------------------------------------------------------------------------
gr_id = 145

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 157, 168 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 145
        end
        exec('seq_set id='..seq_gr_id..' name=DL-UL-Peak-Traffic-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=VRAN_FDD capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=3100 size=1350') --For UL-3.1 Mbps per cell for SUE
		exec('sleep 0.5')
		exec("ue_pdu_session_modify pdu=1 qosflows_to_del=2")
		exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

gr_id = 145

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 169, 180 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 145
        end
        exec('seq_set id='..seq_gr_id..' name=DL-UL-Peak-Traffic-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=VRAN_FDD capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=1300 size=1350') --For UL-93.6 Mbps per cell
		exec('sleep 0.5')
		exec("ue_pdu_session_modify pdu=1 qosflows_to_del=2")
		exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
--------------------------------------------------------------------------
--VoNR
---------------------------------------------------------------------------
gr_id = 145

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 181, 192 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 145
        end
        exec('seq_set id='..seq_gr_id..' name=DL-UL-Peak-Traffic-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=VONR_GBR capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('seq_delay 0.1')
        exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
		exec('sleep 0.5')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=26 size=1350')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=26 size=1350')
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul kbps=26 size=1350')
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl kbps=26 size=1350')
        exec('trf_data_start pdu=1 qfi=3 trf_id=1 dir=ul kbps=26 size=1350')
        exec('trf_data_start pdu=1 qfi=3 trf_id=1 dir=dl kbps=26 size=1350')
		exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

------------------------------------
-- 72 UE DL TP TC6
------------------------------------
gr_id = 145

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 193, 204 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 145
        end
        exec('seq_set id='..seq_gr_id..' name=DL-UL-Peak-Traffic-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=VRAN_FDD capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=6151 size=1350')
		exec('sleep 0.5')
        exec("ue_pdu_session_modify pdu=1 qosflows_to_del=2")
		exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

gr_id = 145

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 205, 216 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 145
        end
        exec('seq_set id='..seq_gr_id..' name=DL-UL-Peak-Traffic-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=VRAN_FDD capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=3415 size=1350')
		exec('sleep 0.5')
        exec("ue_pdu_session_modify pdu=1 qosflows_to_del=2")
		exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

end
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled NR_CLUB_PROXY_PROTO_MSGS=enabled TTI=5') --Proxy proto flags enabled and added TTI param
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set purge_buffer_on_full=on')
--exec('sim_param_set ENABLE_MULTIPLE_L2NRT=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
--exec('debug_log level=4 max_file_num=20 max_log_size=500M')
exec('debug_log level=5 max_file_num=20 max_log_size=500M')
exec('sim_param_set ENABLE_CORE_LIMIT=on')
--exec('sim_debug_log level=0 gate=1')
--exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('sim_param_set pet_5g_testing=on')
exec('link_ctrl_param use_hb=off')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=500M')
exec('sim_start version_check=off')
--exec('debug_sim_log level=4 uec=1-6')
--exec('debug_sim_log level=4 amf=1-5')
--exec('sim_trace uec=1-6 protocol=nr_rrc on')
--exec('debug_sim_log level=0 enb=3')
--exec('sim_trace enb=3 protocol=nr_rrc on')
--exec('sim_debug_log level=4 app_type=ueproxy')

end
