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
--os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

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
UEC_COUNT = 8   --Total number of UEC
SA_UE_COUNT_PER_CELL = 925 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 0 --NSA UE Count per cell
sim_gNBs = 3	--Sim-gNBs for Handover

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 18001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 15     --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = 90 --TOTAL_NUMBER_OF_CELLS	--Total Number of Sequence_set groups

END_CELL_ID = FIRST_CELL_ID + TOTAL_NUMBER_OF_CELLS - 1 --End cell id =  FIRST_CELL_ID + NUMBER_OF_CELLS - 1, Ex: = 7+6-1
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
--TAC_sim_gnb = 201
GSCN = 7880	--GSCN value
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 0 --Total number of SGW/PGW in core network
MME_Count = 1 --Total number of MME in core network
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---UE assigmnent -----------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = 1
LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 92           --93 [1-92]
FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA + 1            --94   
LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 20	       --114 [94-114]			
FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA = LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA + 1           --115 
LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 59		   --174 [115-174]
FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA = LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA + 1           --175 
LAST_INTER_gNB_INTER_FREQ_HO_UE_SA = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA + 11          --186 [175-186]
FIRST_CA_SCELL_ADD_DEL_UE_SA = LAST_INTER_gNB_INTER_FREQ_HO_UE_SA + 1                  --187 
LAST_CA_SCELL_ADD_DEL_UE_SA = FIRST_CA_SCELL_ADD_DEL_UE_SA  + 125                      --312 [187-312]
FIRST_CA_SCELL_ADD_UE_SA = LAST_CA_SCELL_ADD_DEL_UE_SA + 1                             --313 
LAST_CA_SCELL_ADD_UE_SA = FIRST_CA_SCELL_ADD_UE_SA + 767                              --1080 [313-1080]
FIRST_ATTACH_DETACH_UE_SA = LAST_CA_SCELL_ADD_UE_SA + 1                               --1081 
LAST_ATTACH_DETACH_UE_SA = FIRST_ATTACH_DETACH_UE_SA + 119                            --1200 [1081-1200]
FIRST_ADITIONAL_DRB_ADD_UE_SA = LAST_ATTACH_DETACH_UE_SA + 1			              --1201 						
LAST_ADITIONAL_DRB_ADD_UE_SA  = FIRST_ADITIONAL_DRB_ADD_UE_SA + 39                    --1240 [1201-1232]
FIRST_VONR_DRB_ADD_UE_SA = LAST_ADITIONAL_DRB_ADD_UE_SA + 1                           --1241 
LAST_VONR_DRB_ADD_UE_SA = FIRST_VONR_DRB_ADD_UE_SA + 95                               --1336 [1233-1328]
FIRST_TAU_UPDATE_UE_SA = LAST_VONR_DRB_ADD_UE_SA  + 1				                  --1337 
LAST_TAU_UPDATE_UE_SA = FIRST_TAU_UPDATE_UE_SA + 23                                   --1360 [1329-1352]
FIRST_STATE_TRASITION_UE_SA = LAST_TAU_UPDATE_UE_SA + 1                               --1361                  
LAST_STATE_TRASITION_UE_SA = FIRST_STATE_TRASITION_UE_SA + 783                        --2144 [1353-2136] 
FIRST_PAGING_UE_SA = LAST_STATE_TRASITION_UE_SA + 1                                   --2145 
LAST_PAGING_UE_SA = FIRST_PAGING_UE_SA + 783                                          --2928 [2137-2920] 
FIRST_RNA_UE_SA = LAST_PAGING_UE_SA + 1                                               --2929 
LAST_RNA_UE_SA = FIRST_RNA_UE_SA + 2447                                               --5376 [2921-5368]

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
					
NR_ARFCN_TABLE 	= { "636666:636666",
                    "636666:636666",
                    "643330:643330",
					"643330:643330",
					"649994:649994",
					"649994:649994",
                    }  
--[[
NR_ARFCN_TABLE 	= { "370000:390000",
					"528600:528600",
                    "345000:432000",
					"623400:623400",
					"351740:436740",
					"509202:509202"
					 }  -- NRARFCN UL:DL for each cell
]]--
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

GSCN_TABLE = 				{ 		"7880",
									"7880",
									"7950",
									"7950",
									"8019",
									"8019",
                        }   --Table for GSCN
						
SIM_GSCN_TABLE = 				{ 		"7880",
									"7950",
									"8019",
                        }   --Table for GSCN

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

SIM_GNB_NR_ARFCN_TABLE 	= { "636666:636666",
                            "643330:643330",
                            "649994:649994",
        					
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
	exec('gnb_param id='..sim_nrci_i..' xn_listening_socket=on sib1_period=2000 send_xn_setup=on measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
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

--Traffic profile creation for VTM test
-------------------------------------------------------------------------------------------------------
--[[exec('set_trf_data_profile profile_id=1 trf_id=1  size=355 kbps=176  seconds=8')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=1277 kbps=1166  seconds=8') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')  -----> for VNR same traffic in DL and UL--]]



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
	for ue_group_id = 1, 30 do
		if cellid > END_CELL_ID then
			cellid = FIRST_CELL_ID
		end
		if uecid > 6 then
			uecid = 1
		end
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.." uec="..uecid.." enb=2 cell="..cellid.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
		cellid = cellid + 1
		uecid = uecid + 1
	end
end

uecid = 1
cellid = FIRST_CELL_ID

if PET_SE_FLAG == 'yes' then
	for ue_group_id = 31, 86 do
		if cellid > END_CELL_ID then
			cellid = FIRST_CELL_ID
		end
		if uecid > 8 then
			uecid = 1
		end
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.." uec="..uecid.." enb=2 cell="..cellid.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
		cellid = cellid + 1
		uecid = uecid + 1
	end
end



--[[exec('set_ue_group id=1 name=UE_GRP-1 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=2 name=UE_GRP-2 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=3 name=UE_GRP-3 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=4 name=UE_GRP-4 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=5 name=UE_GRP-5 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=6 name=UE_GRP-6 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=7 name=UE_GRP-7 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=8 name=UE_GRP-8 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=9 name=UE_GRP-9 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=10 name=UE_GRP-10 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=11 name=UE_GRP-11 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=12 name=UE_GRP-12 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=13 name=UE_GRP-13 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=14 name=UE_GRP-14 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=15 name=UE_GRP-15 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=16 name=UE_GRP-16 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=17 name=UE_GRP-17 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=18 name=UE_GRP-18 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=19 name=UE_GRP-19 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=20 name=UE_GRP-20 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=21 name=UE_GRP-21 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=22 name=UE_GRP-22 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=23 name=UE_GRP-23 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=24 name=UE_GRP-24 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=25 name=UE_GRP-25 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=26 name=UE_GRP-26 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=27 name=UE_GRP-27 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=28 name=UE_GRP-28 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=29 name=UE_GRP-29 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=30 name=UE_GRP-30 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=31 name=UE_GRP-31 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=32 name=UE_GRP-32 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=33 name=UE_GRP-33 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=34 name=UE_GRP-34 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=35 name=UE_GRP-35 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=36 name=UE_GRP-36 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=37 name=UE_GRP-37 uec=7 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=38 name=UE_GRP-38 uec=8 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=39 name=UE_GRP-39 uec=1 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=40 name=UE_GRP-40 uec=2 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=41 name=UE_GRP-41 uec=3 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=42 name=UE_GRP-42 uec=4 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=43 name=UE_GRP-43 uec=5 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=44 name=UE_GRP-44 uec=6 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=45 name=UE_GRP-45 uec=7 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=46 name=UE_GRP-46 uec=8 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=47 name=UE_GRP-47 uec=1 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=48 name=UE_GRP-48 uec=2 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=49 name=UE_GRP-49 uec=3 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=50 name=UE_GRP-50 uec=4 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=51 name=UE_GRP-51 uec=5 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=52 name=UE_GRP-52 uec=6 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=53 name=UE_GRP-53 uec=7 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=54 name=UE_GRP-54 uec=8 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=55 name=UE_GRP-55 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=56 name=UE_GRP-56 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=57 name=UE_GRP-57 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=58 name=UE_GRP-58 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=59 name=UE_GRP-59 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=60 name=UE_GRP-60 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=61 name=UE_GRP-61 uec=7 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=62 name=UE_GRP-62 uec=8 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=63 name=UE_GRP-63 uec=1 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=64 name=UE_GRP-64 uec=2 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=65 name=UE_GRP-65 uec=3 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=66 name=UE_GRP-66 uec=4 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=67 name=UE_GRP-67 uec=5 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=68 name=UE_GRP-68 uec=6 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=69 name=UE_GRP-69 uec=7 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=70 name=UE_GRP-70 uec=8 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=71 name=UE_GRP-71 uec=1 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=72 name=UE_GRP-72 uec=2 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=73 name=UE_GRP-73 uec=3 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=74 name=UE_GRP-74 uec=4 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=75 name=UE_GRP-75 uec=5 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=76 name=UE_GRP-76 uec=6 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=77 name=UE_GRP-77 uec=7 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=78 name=UE_GRP-78 uec=8 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=79 name=UE_GRP-79 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=80 name=UE_GRP-80 uec=2 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=81 name=UE_GRP-81 uec=3 enb=2 cell=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=82 name=UE_GRP-82 uec=4 enb=2 cell=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=83 name=UE_GRP-83 uec=5 enb=2 cell=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=84 name=UE_GRP-84 uec=6 enb=2 cell=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=85 name=UE_GRP-85 uec=7 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group id=86 name=UE_GRP-86 uec=8 enb=2 cell=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')--]]
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
		if SA_UECID > UEC_COUNT then
			SA_UECID = 1
		end
        if ue_group_id > UE_GROUP_COUNT then
            ue_group_id = 1
        end
        if PET_SE_FLAG == 'yes' then
	        exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
        else
    		exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
			--exec('ue_param id='..SA_UEID..' ue_nr_capabilities=UE_CAP_4CC_FDD_CA capability_file=./capability.cfg')
        end
		SA_UECID = SA_UECID + 1
		SA_CELLID = SA_CELLID + 1
        ue_group_id = ue_group_id + 1
	end
end
]]


--Intra_gnb HO_intra_freq-- -rate 1.3

SA_FLAG = 1
ue_group_id = 1
SA_CELLID = 1
for SA_UEID = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA, LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA  do
    if SA_FLAG == 4 then
        SA_FLAG = 1
        ue_group_id = 1
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 2
    SA_CELLID = SA_CELLID + 2
end

--Intra_gnb_inter_freq-- -rate 0.3

SA_FLAG = 1
ue_group_id = 2
SA_CELLID = 2
 
for SA_UEID = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA, LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA  do
    if SA_FLAG == 4 then
        SA_FLAG = 1
        ue_group_id = 2
        SA_CELLID = 2
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
	ue_group_id = ue_group_id + 2
    SA_CELLID = SA_CELLID + 2
end

--Inter_gnb_intra_freq HO-- -rate 0.18

SA_FLAG = 1
ue_group_id = 7
SA_CELLID = 1
 
for SA_UEID = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA, LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        ue_group_id = 7
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
	ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
end

--Inter_gnb_inter_freq HO--  0.055

SA_FLAG = 1
ue_group_id = 13
SA_CELLID = 1
 
for SA_UEID = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA, LAST_INTER_gNB_INTER_FREQ_HO_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        ue_group_id =13 
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end

--CA_scell add/del-- -rate 1.3

SA_FLAG = 1
ue_group_id = 19
SA_CELLID = 1
 
for SA_UEID = FIRST_CA_SCELL_ADD_DEL_UE_SA, LAST_CA_SCELL_ADD_DEL_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        ue_group_id =19
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end

--CA_scell add--  -rate 6   

SA_FLAG = 1
ue_group_id = 25
SA_CELLID = 1
 
for SA_UEID = FIRST_CA_SCELL_ADD_UE_SA, LAST_CA_SCELL_ADD_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        ue_group_id =25
        SA_CELLID = 1
    end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end
   
--Attach+detach--  -rate 1.5
 
SA_FLAG = 1
ue_group_id = 31
SA_CELLID = 1
 
for SA_UEID = FIRST_ATTACH_DETACH_UE_SA, LAST_ATTACH_DETACH_UE_SA   do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =31
        SA_CELLID = 1
    end
	if ue_group_id == 39 then
	    ue_group_id = 31
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
  end
  
 ---DRBAdd-----  -rate 0.3
 
SA_FLAG = 1
ue_group_id = 39
SA_CELLID = 1
for SA_UEID = FIRST_ADITIONAL_DRB_ADD_UE_SA, LAST_ADITIONAL_DRB_ADD_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =39
        SA_CELLID = 1
    end
	if ue_group_id == 47 then
	    ue_group_id = 39
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end
   
-----VONR------ 

SA_FLAG = 1
ue_group_id = 47
SA_CELLID = 1
   
for SA_UEID = FIRST_VONR_DRB_ADD_UE_SA, LAST_VONR_DRB_ADD_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =47
        SA_CELLID = 1
    end
	if ue_group_id == 55 then
	   ue_group_id = 47
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1 qfi=3 trf_prof_dl=3  trf_prof_ul=3")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end
   
 --TAU----

SA_FLAG = 1
ue_group_id = 55
SA_CELLID = 1
   
for SA_UEID = FIRST_TAU_UPDATE_UE_SA, LAST_TAU_UPDATE_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =55
        SA_CELLID = 1
    end
	if ue_group_id == 63 then
		ue_group_id = 55
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end
 
 
--UE_State transition--   40UE/cell  -rate 2
 
SA_FLAG = 1
ue_group_id = 63
SA_CELLID = 1
 
for SA_UEID = FIRST_STATE_TRASITION_UE_SA, LAST_STATE_TRASITION_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =63
        SA_CELLID = 1
    end
	if ue_group_id == 71 then
		ue_group_id = 63
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end
 
 --Paging----- 70UE/cell -rate3.3
 
SA_FLAG = 1
ue_group_id = 71
SA_CELLID = 1
   
for SA_UEID = FIRST_PAGING_UE_SA, LAST_PAGING_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =71
        SA_CELLID = 1
    end
	if ue_group_id == 79 then
		ue_group_id = 71
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    exec(' ue_param id='..SA_UEID..' ignore_paging=on')
    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    SA_FLAG = SA_FLAG + 1
    ue_group_id = ue_group_id + 1
    SA_CELLID = SA_CELLID + 1
   end
   
--RNA--

SA_FLAG = 1
ue_group_id = 79
SA_CELLID = 1
   
for SA_UEID = FIRST_RNA_UE_SA, LAST_RNA_UE_SA  do
    if SA_FLAG == 7 then
        SA_FLAG = 1
        --ue_group_id =79
        SA_CELLID = 1
    end
	if ue_group_id == 87 then
		ue_group_id = 79
	end
    exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
	exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
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
		exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=NSA_UE_CAP_4CC_FDD_CA dual_conn=eutra_nr ue_eutra_nr_capabilities=NSA_UE_EUTRA_CAP capability_file=./capability.cfg')
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
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
exec('set_qosflow id=4 5qi=8 default=off')
--exec('set_qosrule id=1 proto=tcp qos_flow=2')
--exec('set_qosrule id=2 proto=udp qos_flow=3')
--exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1,2,3 amf_region_id=1-5 plmn_list='..PLMN..'  ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
 
 if PET_SE_FLAG == 'yes' then
 

 
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Intra-GNB Intra freq rate 1.3 & inter freq rate 0.3
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell1 to cell2 & viceversa(Intra-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=1 name=Intragnb-Intrafreq-HO ue_group=1')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell2 to cell3 & viceversa(Inter-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=2 name=Intragnb-Interfreq-HO ue_group=2')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell3 to cell4 & viceversa (Intra-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=3 name=Intragnb-Intrafreq-HO  ue_group=3')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell4 to cell5 & viceversa (Inter-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=4 name=Intragnb-Interfreq-HO ue_group=4')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell5 to cell6 & viceversa(Intra-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=5 name=Intragnb-Intrafreq-HO  ue_group=5')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell6 to cell1 & viceversa(Inter-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=6 name=Intragnb-Interfreq-HO  ue_group=6')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--Inter-GNB Intra freq rate 0.4
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell1 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=7 name=Intergnb-Intrafreq-HO ue_group=7')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell2 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=8 name=Intergnb-Intrafreq-HO ue_group=8')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell3 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=9 name=Intergnb-Intrafreq-HO ue_group=9')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell4 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=10 name=Intergnb-Intrafreq-HO ue_group=10')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell5 to simgnb3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=11 name=Intergnb-Intrafreq-HO ue_group=11')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell6 to simgnb3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=12 name=Intergnb-Intrafreq-HO  ue_group=12')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
--Inter-GNB Inter freq rate 0.1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell1 to simgnb3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=13 name=Intergnb-Interfreq-HO  ue_group=13')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell2 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=14 name=Intergnb-Interfreq-HO ue_group=14')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell3 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=15 name=Intergnb-Interfreq-HO  ue_group=15')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell4 to simgnb3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=16 name=Intergnb-Interfreq-HO  ue_group=16')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell5 to simgnb2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=17 name=Intergnb-Interfreq-HO   ue_group=17')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell6 to simgnb1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=18 name=Intergnb-Interfreq-HO  ue_group=18')
        exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 8') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Attach-Detach +CA scell add & del at rate 1.33
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to cell5 
---------------------------------------------------------------------------------------------------
		exec('seq_set id=19 name=scell-add-del ue_group=19')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=649920 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=20 name=scell-add-del ue_group=20')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
		exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=643296 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')		
		exec('seq_end')
			 
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=21 name=scell-add-del  ue_group=21')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636576 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')  
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell6 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=22 name=scell-add-del  ue_group=22')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=649920 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=23 name=scell-add-del  ue_group=23')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=643296 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=24 name=scell-add-del ue_group=24')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636576 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Attach-Detach +CA scell add  at rate 6
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to cell5 
---------------------------------------------------------------------------------------------------
		exec('seq_set id=25 name=scell-add-del-1-2 ue_group=25')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
		exec('seq_delay 6')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=26 name=scell-add-del-2-1 ue_group=26')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
		exec('seq_delay 6')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
			 
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=27 name=scell-add-del-3-4  ue_group=27')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 6')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell6 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=28 name=scell-add-del-4-3  ue_group=28')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 6')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=29 name=scell-add-del-5-6  ue_group=29')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 6')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=30 name=scell-add-del-6-5  ue_group=30')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 6')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---AD rate 1.5 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 31
 
	for seq_gr_id = 31,38 do		
			if gr_id > 38 then
					gr_id = 31
			end
					exec('seq_set id='..seq_gr_id..' name=PetAttachDetach-'..seq_gr_id..' ue_group='..gr_id)
					exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
					exec("ue_pdu_session_setup pdu=1 nwslice=1")
					exec('seq_delay 8')
					exec('ue_deregister by=ue ue_deregister_type=switch_off')
					exec('seq_end')	
					gr_id = gr_id + 1
	end
	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DRB addition:  rate 0.3
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 39
    for seq_gr_id =39,46 do
            if gr_id > 46 then
                gr_id = 39
            end
                exec('seq_set id='..seq_gr_id..' name=Pet_PDU-add-del'..seq_gr_id..' ue_group='..gr_id)
                exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
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

gr_id = 47

 for seq_gr_id = 47,54 do
            if gr_id > 54 then
                gr_id = 47
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
	 
	 
	 
---------------------------------------------------------
--TAU:
---------------------------------------------------------
gr_id = 55
	for seq_gr_id = 55,62 do		
			if gr_id > 62 then
			   gr_id = 55
			end
		    exec('seq_set id='..seq_gr_id..' name=TAU-'..seq_gr_id..' ue_group='..gr_id)
            exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
			exec('ue_pdu_session_setup pdu=1 nwslice=1')
            for i=1, 5 do
                       exec("seq_loop_start loop=203")
					   exec('seq_delay 16')
                       exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg reactivate_pdu=off use_suci=off registration_type=MobilityRegistrationUpdting')
                       exec("seq_loop_end")
			end
			exec('seq_delay 8')
			exec('ue_deregister by=ue ue_deregister_type=switch_off')
			exec('seq_end')
			gr_id = gr_id + 1
	end


------------------------------------------------------------------------------------------------------------------------------------------------------
--UE state transition:
----------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 63
	for seq_gr_id = 63,70 do		
			if gr_id > 70 then
			   gr_id = 63
			end
		    exec('seq_set id='..seq_gr_id..' name=UE_ST'..seq_gr_id..' ue_group='..gr_id)
                    exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
                    exec("ue_pdu_session_setup pdu=1 nwslice=1")   
                    exec("seq_loop_start loop=235")
                    exec('seq_delay  66')
                    exec("ue_im_exit by=ue")
                    exec("seq_loop_end")
                    exec('seq_delay 3')
					exec('ue_deregister by=ue ue_deregister_type=switch_off')
                    exec('seq_end')
                    gr_id = gr_id + 1
	end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Paging
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 71
	for seq_gr_id = 71,78 do
		if gr_id > 78 then
			gr_id = 71
		end
		exec('seq_set id='..seq_gr_id..' name=PagingStartStop-'..seq_gr_id..' ue_group='..gr_id)
		exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		--exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
        --for i=1, 5 do
        --exec("seq_loop_start loop=232")
        --exec('seq_delay 6')
        --exec('amf_paging_start id=1-5')
        exec('amf_fake_paging_start amf=1-5 gnbs=2 session_id=1 tai=311:489|200 5g_s_tmsi=1:1:2 5g_s_tmsi_num=5 drx_cycle_len=256 burst_size=25 burst_period=50')
         exec('seq_delay '..timer)
        exec('amf_fake_paging_stop amf=1-5 gnbs=2 session_id=1 ')
        exec('seq_delay 0.1')
        --exec("seq_loop_end")
        --end
        --exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		gr_id = gr_id + 1
	end


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--RNA:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 79
	for seq_gr_id = 79,86 do		
			if gr_id > 86 then
			   gr_id = 79
			end
		    exec('seq_set id='..seq_gr_id..' name=RNA-'..seq_gr_id..' ue_group='..gr_id)	
			exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
			exec('ue_pdu_session_setup pdu=1 nwslice=1')
			exec('seq_delay 16200')
			exec('ue_deregister by=ue ue_deregister_type=switch_off')
			exec('seq_end')
			gr_id = gr_id + 1
	end

end
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled') --Proxy proto flag enabled
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled') 
exec('sim_param_set TTI=5 ')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set purge_buffer_on_full=on')
exec('sim_param_set CM_OPTIMIZATION=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4 max_file_num=20 max_log_size=500M')                   --loglevel should be 4
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('sim_param_set pet_5g_testing=on')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=500M')
exec('sim_start version_check=off')
exec('debug_sim_log level=4 uec=1-6')
exec('debug_sim_log level=4 amf=1-5')
--exec('sim_trace uec=1-6 protocol=nr_rrc on')
--exec('debug_sim_log level=0 enb=2')
--exec('sim_trace enb=4 protocol=nr_rrc on')
exec('sim_debug_log level=4 app_type=ueproxy')

end
