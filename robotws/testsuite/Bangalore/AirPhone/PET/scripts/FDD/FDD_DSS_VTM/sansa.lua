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
--COMMON VARIABLES for ALL WTS
----------------------------------------------------------------------------------------------------

EDAEMON_IP="10.0.2.1"
EDAEMON_PORT=22222


MULTI_AP_FLAG = 'yes'
cellDepType = 'SA+NSA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Enabled = 'yes'  --Sim-gNBs configured for Handover if set to 'yes'
RNA_UPDATE = 'T380' -- To select type of RNA

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000
NSA_IMSI = 21650000



-------------------------------------------------------------------------------------
-- FOR REAL GNB VARIABLE
--------------------------------------------------------------------------------------

 --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
GNB_X2_ADDR = "10.0.1.2"
GNB_S1U_ADDR = GNB_X2_ADDR
GNB_XN_ADDR = GNB_X2_ADDR
GNB_NG_ADDR = GNB_X2_ADDR

MUTLI_AP_IP_TABLE 	= { "10.0.2.80",
						"10.0.2.90",
						}  --IP table for each UPF

PLMN_TABLE    =   {   "311:489",
                      "311:488",
                    }  --Table for PLMN

NR_CELL_ID_TABLE_AP1	= { 1,2 ,3,4,5,6,7,8,9,10,11,12 }	--Cells belong to Airphone-1

NR_CELL_ID_TABLE_AP2	= { 13,14,15,16,17,18,19,20,21,22,23,24 }	--Cells belong to Airphone-2

NR_CELLS_IN_AP1 = #NR_CELL_ID_TABLE_AP1

NR_CELLS_IN_AP2 = #NR_CELL_ID_TABLE_AP2

NR_CELL_TECH_TABLE_AP1	= { "FDD",
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
							"FDD"
							}	--Cells Tech of Airphone-1

NR_CELL_TECH_TABLE_AP2	= { "FDD",
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
							"FDD"
							}	--Cells Tech of Airphone-2


PCI_TABLE_AP1   = { "16:2",
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
					
					}
					
PCI_TABLE_AP2   = { "20:2",
					"21:0",
					"21:1",
                    "21:2",
                    "22:0",
                    "22:1",
					"22:2",
					"23:0",
					"23:1",
					"23:2",
                    "24:0",				
					"24:1"
					} 
					
 --Table for ARFCN
 
NR_ARFCN_TABLE_AP1 	= { "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
					 }  -- NRARFCN UL:DL for each cell
					 
NR_ARFCN_TABLE_AP2  = { "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
                        "136300:127100",
                        "348440:433000",
						} -- NRARFCN UL:DL for each cell
 --Table for GSCN 
						
GSCN_TABLE_AP1   =   { 	"1588",
						"5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                    }

GSCN_TABLE_AP2   =   {  "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                        "1588",
                        "5411",
                    }

---------------------------------------------------------------------------------------------------
--5G CN SIM VARIABLE
---------------------------------------------------------------------------------------------------					

AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only

FIRST_AMF_ID = 1   --Starting AMF id
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
	
	
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
					
---------------------------------------------------------------------------------------------------
--4G SIM VARIABLE
---------------------------------------------------------------------------------------------------

MME_COUNT=1

LTE_CORE_COUNT=1

					
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


-- SIM ENB VARIABLES

NUM_SIM_ENB = 1 


NUM_CELL_PER_SIM_ENB = 24

ENB_X2_OR_XP_TABLE = {"10.0.1.137",
					   }
ENB_S1_ADDR = { "10.0.1.138",
				}
				
SIM_ENB_PCI   = {  {"3:2",
					"4:0",
					"4:1",
					"4:2",
					"5:0",
					"5:1",
					"5:2",
					"6:0",
					"6:1",
					"6:2",
					"7:0",
					"7:1",
					"7:2",
					"8:0",
					"8:1",
					"8:2",
					"9:0",
					"9:1",
					"9:2",
					"10:0",
					"10:1",
					"10:2",
					"11:0",
                    "11:1"}
					}
SIM_ENB_CELL_TECH_TABLE = { 
                       {"FDD",
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
						"FDD"}
						}
					
SIM_ENB_EARFCN =  { {
                    "68771:133307",
					"66986:132294",
				    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294",
                    "68771:133307",
                    "66986:132294"}
                    } -- EARFCN DL:UL for each cell
				  

---------------------------------------------------------------------------------------------------
--5G GNB SIM VARIABLE
---------------------------------------------------------------------------------------------------
NUM_SIM_GNB=2

NUM_CELL_PER_SIM_GNB=1
			  
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

SIM_GNB_PCI_TABLE	= { {"0:1"},
                        {"0:2"},
	    				}  -- 6 phycical cell ids configured in table
SIM_GNB_CELL_TECH_TABLE = { { "FDD"},
							{ "FDD"}
							}

SIM_GNB_NR_ARFCN_TABLE 	= { {"136300:127100"},
							{"348440:433000"},
                        }  
SIM_GSCN_TABLE  = 	{ {"1588"},
					  {"5411"}	
					}   --Table for GSCN


--------------------------------------------------------------------------------------------------
--UEC configuration
--------------------------------------------------------------------------------------------------


UEC_COUNT = 6  --Total number of UEC
UE_GROUP_COUNT_PER_CELL = 12   --Number of PET_SE UE_Groups per cell

TOTAL_UE_GROUP_FOR_AP1 = NR_CELLS_IN_AP1*UE_GROUP_COUNT_PER_CELL
TOTAL_UE_GROUP_FOR_AP2 = NR_CELLS_IN_AP2*UE_GROUP_COUNT_PER_CELL

-------------------------------------------------------------------------------------
-- UE RELATED VARIABLE
-------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--UE DISTRIBUTION
---------------------------------------------------------------------------------------------------
--[[
Scenario                 SEQ and UE group id for cell 1-24       

A-D+SCell ADD-DEL        --->1-24                             
A-D+DEL                  --->25-48                            
PAG                      --->49-72                            
ST                       --->73-96                            
INTRA-GNB+INTRA FREQ     --->97-120                           
INTRA-GNB+INTER FREQ     --->121-144                          
INTER-GNB+INTRA FREQ     --->145-168                          
INTER-GNB+INTER FREQ     --->169-192                          
RNA                      --->193-216                          
TAU                      --->217-240                          
Ad DRB                   --->241-264                          
VoNR                     --->265-288                          

--]]

TOTAL_NUMBER_OF_CELLS=NR_CELLS_IN_AP1+NR_CELLS_IN_AP2

UE_A_D_SCELL_ADD_DEL=4
UE_A_D_SCELL_ADD=18
UE_PAG=8
UE_ST=8
UE_IN_GNB_IN_FREQ=2
UE_IN_GNB_ITR_FREQ=2
UE_ITR_GNB_IN_FREQ=1
UE_ITR_GNB_ITR_FREQ=1
if RNA_UPDATE == 'T380' then
    UE_RNA=105
else
    UE_RNA=11
end
UE_TAU=2
UE_Ad_DRB=2
UE_VoNR=1

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

function run_configuration(duration)

local RRC_inactive_timer=1
local ue_active_delay=15
local LOOP_count=math.floor(duration/ue_active_delay)
local TAU_LOOP_count=math.floor(duration/16)
local RNA_LOOP_count=math.floor(duration/RRC_inactive_timer)
local paging_per_amf=12

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

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0xE78F daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..' xp_management=on xp='..GNB_X2_ADDR..':32742 xpu='..GNB_X2_ADDR..':32742')

for cell_count=1, #NR_CELL_ID_TABLE_AP1 do   
	
	local nrci_i = NR_CELL_ID_TABLE_AP1[cell_count]
    local nrci_o = string.format("%x", nrci_i)
	
	if NR_CELL_TECH_TABLE_AP1[cell_count] == 'FDD' then
        tdd_flag = 'off'
    else
        tdd_flag = 'on'
    end
	PROXY_SERVER = MUTLI_AP_IP_TABLE[1]
	exec('set_cell id='..NR_CELL_ID_TABLE_AP1[cell_count]..' gnb=2 gscn='..GSCN_TABLE_AP1[cell_count]..' pci='..PCI_TABLE_AP1[cell_count]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE_AP1[cell_count]..' mandatory_for_activation=off')
	
end

if MULTI_AP_FLAG == "yes" then

	for cell_count=1, #NR_CELL_ID_TABLE_AP2 do   
		
		local nrci_i = NR_CELL_ID_TABLE_AP2[cell_count]
		local nrci_o = string.format("%x", nrci_i)
		
		if NR_CELL_TECH_TABLE_AP2[cell_count] == 'FDD' then
			tdd_flag = 'off'
		else
			tdd_flag = 'on'
		end
		PROXY_SERVER = MUTLI_AP_IP_TABLE[2]
		exec('set_cell id='..NR_CELL_ID_TABLE_AP2[cell_count]..' gnb=2 gscn='..GSCN_TABLE_AP2[cell_count]..' pci='..PCI_TABLE_AP2[cell_count]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE_AP2[cell_count]..' mandatory_for_activation=off')
		
	end

end

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
if cellDepType == 'NSA' or cellDepType == 'SA+NSA' then
    for mme_id=1, MME_COUNT do
        exec('mme_pool_area id='..mme_id..' mmegi='..mme_id..' plmn='..PLMN_TABLE[mme_id]..' tac_list=777,111,222,444,333,'..TAC..'')
        exec('set_mme id=1 ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..MME_IP_TABLE[mme_id]..':36412 supported_rat=lte,nblte pool=1:1')
    end

    for sgw_id = 1,LTE_CORE_COUNT do
        exec('set_sgw id='..sgw_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_IP_TABLE[sgw_id]..' s11='..SGW_S11_IP_TABLE[sgw_id]..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=20')
        exec('set_pgw id='..sgw_id..' type=simulated ip='..EDAEMON_IP..':'..EDAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
    end
end

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
if cellDepType == 'NSA' or cellDepType == 'SA+NSA' then
    for sim_enb_id = 1, NUM_SIM_ENB do
		local cell_udp_port=12219
		exec('set_enb id='..sim_enb_id..' plmn='..PLMN..' s1='..ENB_S1_ADDR[sim_enb_id]..' enb_id_macro=0x00001 daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2='..ENB_X2_OR_XP_TABLE[sim_enb_id]..' x2u='..ENB_X2_OR_XP_TABLE[sim_enb_id]..' type=simulated xp_management=on xp='..ENB_X2_OR_XP_TABLE[sim_enb_id]..':32742 xpu='..ENB_X2_OR_XP_TABLE[sim_enb_id]..':32742 x2_peers=2')
		exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
		exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:31')
		exec('enb_xp_param id=1  xp_peers=2 ignore_xp=off xp_listening_socket=on')
		for sim_enb_cell_id = 1 ,NUM_CELL_PER_SIM_ENB do
			if SIM_ENB_CELL_TECH_TABLE[sim_enb_id][sim_enb_cell_id] == 'FDD' then
				tdd_flag = 'off'
			else
				tdd_flag = 'on'
			end	
			exec('set_cell id='..sim_enb_cell_id..' enb=1 eci=0x0000101 pci='..SIM_ENB_PCI[sim_enb_id][sim_enb_cell_id]..' tac=222 proxy='..EDAEMON_IP..':'..cell_udp_port..'|'..EDAEMON_IP..':8889 earfcn='..SIM_ENB_EARFCN[sim_enb_id][sim_enb_cell_id]..' tdd_cell='..tdd_flag..' bw=20MHz mandatory_for_activation=off')	
			--exec("enb_cell_param enb=1 id="..enb_cell_id.." lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2")
			cell_udp_port=cell_udp_port+1
		end
	end	
end

----------------------------------------------------------------------------------------------------
--SIM-GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
if HO_Enabled == 'yes' then
	for sim_gnb_id = 1, NUM_SIM_GNB do
		local sim_nrci_i = sim_gnb_id + 2
		local sim_nrci_o = string.format("%x", sim_nrci_i)
		exec('set_gnb id='..sim_nrci_i..' type=simulated plmn='..PLMN..' daemon='..SIM_GNB_SERVER_IP_TABLE[sim_gnb_id]..':'..EDAEMON_PORT..' xn='..SIM_GNB_XN_IP_TABLE[sim_gnb_id]..' ng='..SIM_GNB_NG_IP_TABLE[sim_gnb_id]..' gnb_id=0x'..sim_nrci_o..' x2_peers=none amf=1-'..AMF_COUNT..' plmnList='..PLMN..' nssai='..SNSSAI)
		exec('gnb_param id='..sim_nrci_i..' xn_listening_socket=on send_xn_setup=on measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4 sib1_period=2000')
		exec('enb_timer T_RELOCprepTimeout=2000')
		for sim_gnb_cell_id = 1 ,NUM_CELL_PER_SIM_GNB do
			if SIM_GNB_CELL_TECH_TABLE[sim_gnb_id][sim_gnb_cell_id] == 'FDD' then
				tdd_flag = 'off'
			else
				tdd_flag = 'on'
			end
			exec('set_cell id='..sim_gnb_cell_id..' gnb='..sim_nrci_i..' pci='..SIM_GNB_PCI_TABLE[sim_gnb_id][sim_gnb_cell_id]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[sim_gnb_id]..':9999|'..SIM_GNB_SERVER_IP_TABLE[sim_gnb_id]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[sim_gnb_id][sim_gnb_cell_id]..' mandatory_for_activation=off gscn='..SIM_GSCN_TABLE[sim_gnb_id][sim_gnb_cell_id]..'')
		end
	end
end

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------

for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' name=SimModeAMF-'..amf_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[amf_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
    exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
    exec('set_upf id='..amf_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[amf_id]..'/21 ngu='..AMF_IP_TABLE[amf_id]..' devname=tunUPF'..amf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

    exec('smf_upf_mapping id='..amf_id..' upf='..amf_id)
    exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
	
end


-------------------------------------------------------------------------------------------------------
--Traffic profile creation
-------------------------------------------------------------------------------------------------------
exec('set_trf_data_profile profile_id=1 trf_id=1  size=178 kbps=30  seconds=9')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=859 kbps=250  seconds=9') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')  -----> for VoNR same traffic in DL and UL



----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--UE GROUPS AND UE ASSIGNMENT  FOR PET_SE
---------------------------------------------------------------------------------------------------

uecid = 1
cell_index=1

cell_count=1
for ue_group_id = 1, TOTAL_UE_GROUP_FOR_AP1+TOTAL_UE_GROUP_FOR_AP2 do
	if uecid > UEC_COUNT then
        uecid = 1
    end
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1
    end
    if cell_count <= NR_CELLS_IN_AP1 then
        if cell_index > NR_CELLS_IN_AP1 then
		    cell_index=1
        
	    end
	    exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP1[cell_index].." uec="..uecid.." enb=2 cell="..NR_CELL_ID_TABLE_AP1[cell_index].." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
    else
		if cell_index > NR_CELLS_IN_AP2 then
			cell_index=1
		end
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP2[cell_index].." uec="..uecid.." enb=2 cell="..NR_CELL_ID_TABLE_AP2[cell_index].." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
     end
     cell_index = cell_index + 1
	 cell_count = cell_count + 1
     uecid = uecid + 1
end

---ue group for fake paging sequence----

fake_pag_gr_id=289
    
exec("set_ue_group id="..fake_pag_gr_id.." name=UE_GRP-"..fake_pag_gr_id.."-CELL-1 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")

------------------------------------------
--Attach-Detach with SCell-add-del--

ue_group_id = 1
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_A_D_SCELL_ADD_DEL,END_UE_A_D_SCELL_ADD_DEL do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 1
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
        exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
        exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

--Attach-Detach with SCell-add--

ue_group_id = 25
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_A_D_SCELL_ADD,END_UE_A_D_SCELL_ADD do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 25
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
        exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
        exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

---Paging---

ue_group_id = 49
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_PAG,END_UE_PAG do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 49
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

--UE state transition--

ue_group_id = 73
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_ST,END_UE_ST do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 73
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

----Intra-gNB_Intra_Freq-----

ue_group_id = 97
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_IN_GNB_IN_FREQ,END_UE_IN_GNB_IN_FREQ do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 97
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

----Intra-gNB_Inter_Freq----

ue_group_id = 121
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_IN_GNB_ITR_FREQ,END_UE_IN_GNB_ITR_FREQ do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 121
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

----Inter-gNB_Intra-Freq----

ue_group_id = 145
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_ITR_GNB_IN_FREQ,END_UE_ITR_GNB_IN_FREQ do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 145
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

----Inter-gNB_Inter-Freq----

ue_group_id = 169
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_ITR_GNB_ITR_FREQ,END_UE_ITR_GNB_ITR_FREQ do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 169
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

----RNA-----

ue_group_id = 193
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_RNA,END_UE_RNA do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 193
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

--- TAU------

ue_group_id = 217
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_TAU,END_UE_TAU do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 217
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

-----Additional DRB-------------

ue_group_id = 241
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_Ad_DRB,END_UE_Ad_DRB do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 241
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
		exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
		exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

-----VoNR-----

ue_group_id = 265
cell_count = 1
cell_index = 1
for SA_UEID =START_UE_VoNR,END_UE_VoNR do
    if cell_count > TOTAL_NUMBER_OF_CELLS then
            cell_count = 1 
            ue_group_id = 265
    end
	if cell_count <= NR_CELLS_IN_AP1 then
	    if cell_index > NR_CELLS_IN_AP1 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2  trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1 qfi=3 trf_prof_dl=3  trf_prof_ul=3")
	else 
		if cell_index > NR_CELLS_IN_AP2 then
		   cell_index = 1
		end
		exec('set_ue  id='..SA_UEID..' group='..ue_group_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:311:489:0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec('ue_param id='..SA_UEID..' ignore_paging=on')
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2  trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1 qfi=3 trf_prof_dl=3  trf_prof_ul=3")
	end
	ue_group_id = ue_group_id + 1
	cell_count = cell_count + 1
    cell_index = cell_index + 1
end

--UE group with single UE  for fake Paging

exec('set_ue  id=25000 group='..fake_pag_gr_id..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. SA_IMSI + 25000 - 1)
exec('ue_param id=25000 ignore_paging=on')
exec("set_pdu_param ue=25000 pdu=1 trf_type=internal qfi=1 trf_prof_dl=2  trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")

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
--SEQUENCE  CONFIGURATION
---------------------------------------------------------------------------------------------------
----------------------------------------------------
--Attach-Detach +CA scell add + del
----------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=1 name=scell-add-del-1-2 ue_group=1')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1
---------------------------------------------------------------------------------------------------
		exec('seq_set id=2 name=scell-add-del-1-2 ue_group=2')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=3 name=scell-add-del-1-2 ue_group=3')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-4->cell-3
---------------------------------------------------------------------------------------------------
		exec('seq_set id=4 name=scell-add-del-1-2 ue_group=4')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-5->cell-6
---------------------------------------------------------------------------------------------------
		exec('seq_set id=5 name=scell-add-del-1-2 ue_group=5')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-6->cell-5
---------------------------------------------------------------------------------------------------
		exec('seq_set id=6 name=scell-add-del-1-2 ue_group=6')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-7->cell-8
---------------------------------------------------------------------------------------------------
		exec('seq_set id=7 name=scell-add-del-1-2 ue_group=7')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-8->cell-7
---------------------------------------------------------------------------------------------------
		exec('seq_set id=8 name=scell-add-del-1-2 ue_group=8')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-9->cell-10
---------------------------------------------------------------------------------------------------
		exec('seq_set id=9 name=scell-add-del-1-2 ue_group=9')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-10->cell-9
---------------------------------------------------------------------------------------------------
		exec('seq_set id=10 name=scell-add-del-1-2 ue_group=10')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-11->cell-12
---------------------------------------------------------------------------------------------------
		exec('seq_set id=11 name=scell-add-del-1-2 ue_group=11')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-12->cell-11
---------------------------------------------------------------------------------------------------
		exec('seq_set id=12 name=scell-add-del-1-2 ue_group=12')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-13->cell-14
---------------------------------------------------------------------------------------------------
		exec('seq_set id=13 name=scell-add-del-1-2 ue_group=13')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-14->cell-13
---------------------------------------------------------------------------------------------------
		exec('seq_set id=14 name=scell-add-del-1-2 ue_group=14')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-15->cell-16
---------------------------------------------------------------------------------------------------
		exec('seq_set id=15 name=scell-add-del-1-2 ue_group=15')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-16->cell-15
---------------------------------------------------------------------------------------------------
		exec('seq_set id=16 name=scell-add-del-1-2 ue_group=16')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-17->cell-18
---------------------------------------------------------------------------------------------------
		exec('seq_set id=17 name=scell-add-del-1-2 ue_group=17')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-18->cell-17
---------------------------------------------------------------------------------------------------
		exec('seq_set id=18 name=scell-add-del-1-2 ue_group=18')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-19->cell-20
---------------------------------------------------------------------------------------------------
		exec('seq_set id=19 name=scell-add-del-1-2 ue_group=19')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-20->cell-19
---------------------------------------------------------------------------------------------------
		exec('seq_set id=20 name=scell-add-del-1-2 ue_group=20')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-21->cell-22
---------------------------------------------------------------------------------------------------
		exec('seq_set id=21 name=scell-add-del-1-2 ue_group=21')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-22->cell-21
---------------------------------------------------------------------------------------------------
		exec('seq_set id=22 name=scell-add-del-1-2 ue_group=22')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-23->cell-24
---------------------------------------------------------------------------------------------------
		exec('seq_set id=23 name=scell-add-del-1-2 ue_group=23')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=432970 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-24->cell-23
---------------------------------------------------------------------------------------------------
		exec('seq_set id=24 name=scell-add-del-1-2 ue_group=24')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 4.5')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=127010 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 4.5') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
----------------------------------------------------
--Attach-Detach +CA scell add only
----------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-1->cell-2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=25 name=scell-add-del-1-2 ue_group=25')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-2->cell-1
---------------------------------------------------------------------------------------------------
		exec('seq_set id=26 name=scell-add-del-1-2 ue_group=26')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-3->cell-4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=27 name=scell-add-del-1-2 ue_group=27')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-4->cell-3
---------------------------------------------------------------------------------------------------
		exec('seq_set id=28 name=scell-add-del-1-2 ue_group=28')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-5->cell-6
---------------------------------------------------------------------------------------------------
		exec('seq_set id=29 name=scell-add-del-1-2 ue_group=29')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-6->cell-5
---------------------------------------------------------------------------------------------------
		exec('seq_set id=30 name=scell-add-del-1-2 ue_group=30')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-7->cell-8
---------------------------------------------------------------------------------------------------
		exec('seq_set id=31 name=scell-add-del-1-2 ue_group=31')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-8->cell-7
---------------------------------------------------------------------------------------------------
		exec('seq_set id=32 name=scell-add-del-1-2 ue_group=32')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-9->cell-10
---------------------------------------------------------------------------------------------------
		exec('seq_set id=33 name=scell-add-del-1-2 ue_group=33')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-10->cell-9
---------------------------------------------------------------------------------------------------
		exec('seq_set id=34 name=scell-add-del-1-2 ue_group=34')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-11->cell-12
---------------------------------------------------------------------------------------------------
		exec('seq_set id=35 name=scell-add-del-1-2 ue_group=35')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-12->cell-11
---------------------------------------------------------------------------------------------------
		exec('seq_set id=36 name=scell-add-del-1-2 ue_group=36')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-13->cell-14
---------------------------------------------------------------------------------------------------
		exec('seq_set id=37 name=scell-add-del-1-2 ue_group=37')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-14->cell-13
---------------------------------------------------------------------------------------------------
		exec('seq_set id=38 name=scell-add-del-1-2 ue_group=38')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-15->cell-16
---------------------------------------------------------------------------------------------------
		exec('seq_set id=39 name=scell-add-del-1-2 ue_group=39')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-16->cell-15
---------------------------------------------------------------------------------------------------
		exec('seq_set id=40 name=scell-add-del-1-2 ue_group=40')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-17->cell-18
---------------------------------------------------------------------------------------------------
		exec('seq_set id=41 name=scell-add-del-1-2 ue_group=41')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-18->cell-17
---------------------------------------------------------------------------------------------------
		exec('seq_set id=42 name=scell-add-del-1-2 ue_group=42')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-19->cell-20
---------------------------------------------------------------------------------------------------
		exec('seq_set id=43 name=scell-add-del-1-2 ue_group=43')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-20->cell-19
---------------------------------------------------------------------------------------------------
		exec('seq_set id=44 name=scell-add-del-1-2 ue_group=44')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-21->cell-22
---------------------------------------------------------------------------------------------------
		exec('seq_set id=45 name=scell-add-del-1-2 ue_group=45')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-22->cell-21
---------------------------------------------------------------------------------------------------
		exec('seq_set id=46 name=scell-add-del-1-2 ue_group=46')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-23->cell-24
---------------------------------------------------------------------------------------------------
		exec('seq_set id=47 name=scell-add-del-1-2 ue_group=47')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=127010')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell-24->cell-23
---------------------------------------------------------------------------------------------------
		exec('seq_set id=48 name=scell-add-del-1-2 ue_group=48')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 1') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=432970')
		exec('seq_delay 9') 
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
			
-----------------------------------------
--Paging
------------------------------------------

	for seq_gr_id = 49,72 do
		exec('seq_set id='..seq_gr_id..' name=PagingStartStop-'..seq_gr_id..' ue_group='..seq_gr_id..'')
		exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
		exec('seq_loop_start loop='..LOOP_count..'')
            exec('seq_delay '..ue_active_delay..'')
            exec('amf_paging_start id=1-5')
		exec("seq_loop_end")
        exec('seq_delay 1')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
    end
	
---------------------------------------------------
--Inactive state transition:
--------------------------------------------------------

    for seq_gr_id = 73,96 do
        exec('seq_set id='..seq_gr_id..' name=Pet_UE_STATE-'..seq_gr_id..' ue_group='..seq_gr_id..'')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 nwslice=1")
        exec('seq_loop_start loop='..LOOP_count..'')
            exec('seq_delay  '..ue_active_delay..'')
            exec('ue_nr_rrc_resume')
        exec("seq_loop_end")
        exec('seq_delay 1')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
    end

---------------------------------------------------------------------------------------------------
-----Intra-GNB-------------------
---------------------------------------------------------------------------------------------------

--Intra Frequency HO Between Cell-1 and Cell-3

		exec('seq_set id=97 name=Intragnb-IntraFreq-HO ue_group=97')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-2 and Cell-4

		exec('seq_set id=98 name=Intragnb-IntraFreq-HO ue_group=98')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-3 and Cell-1

		exec('seq_set id=99 name=Intragnb-IntraFreq-HO ue_group=99')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-4 and Cell-2

		exec('seq_set id=100 name=Intragnb-IntraFreq-HO ue_group=100')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-5 and Cell-7

		exec('seq_set id=101 name=Intragnb-IntraFreq-HO ue_group=101')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-6 and Cell-8

		exec('seq_set id=102 name=Intragnb-IntraFreq-HO ue_group=102')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-7 and Cell-5

		exec('seq_set id=103 name=Intragnb-IntraFreq-HO ue_group=103')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-8 and Cell-6

		exec('seq_set id=104 name=Intragnb-IntraFreq-HO ue_group=104')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-9 and Cell-11

		exec('seq_set id=105 name=Intragnb-IntraFreq-HO ue_group=105')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-10 and Cell-12

		exec('seq_set id=106 name=Intragnb-IntraFreq-HO ue_group=106')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-11 and Cell-9

		exec('seq_set id=107 name=Intragnb-IntraFreq-HO ue_group=107')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-12 and Cell-10

		exec('seq_set id=108 name=Intragnb-IntraFreq-HO ue_group=108')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-13 and Cell-15

		exec('seq_set id=109 name=Intragnb-IntraFreq-HO ue_group=109')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-14 and Cell-16

		exec('seq_set id=110 name=Intragnb-IntraFreq-HO ue_group=110')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-15 and Cell-13

		exec('seq_set id=111 name=Intragnb-IntraFreq-HO ue_group=111')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-16 and Cell-14

		exec('seq_set id=112 name=Intragnb-IntraFreq-HO ue_group=112')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-17 and Cell-19

		exec('seq_set id=113 name=Intragnb-IntraFreq-HO ue_group=113')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=68 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-18 and Cell-20

		exec('seq_set id=114 name=Intragnb-IntraFreq-HO ue_group=114')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=69 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-19 and Cell-17

		exec('seq_set id=115 name=Intragnb-IntraFreq-HO ue_group=115')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=68 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-20 and Cell-18

		exec('seq_set id=116 name=Intragnb-IntraFreq-HO ue_group=116')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=69 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-21 and Cell-23

		exec('seq_set id=117 name=Intragnb-IntraFreq-HO ue_group=117')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=72 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=70 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-22 and Cell-24

		exec('seq_set id=118 name=Intragnb-IntraFreq-HO ue_group=118')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=73 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=71 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-23 and Cell-21

		exec('seq_set id=119 name=Intragnb-IntraFreq-HO ue_group=119')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=70 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=72 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-24 and Cell-22

		exec('seq_set id=120 name=Intragnb-IntraFreq-HO ue_group=120')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=71 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=73 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------

--Inter Frequency HO Between Cell-1 and Cell-4

		exec('seq_set id=121 name=Intragnb-InterFreq-HO ue_group=121')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-2 and Cell-3

		exec('seq_set id=122 name=Intragnb-InterFreq-HO ue_group=122')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')	

--Inter Frequency HO Between Cell-3 and Cell-2

		exec('seq_set id=123 name=Intragnb-InterFreq-HO ue_group=123')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-4 and Cell-1

		exec('seq_set id=124 name=Intragnb-InterFreq-HO ue_group=124')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-5 and Cell-8

		exec('seq_set id=125 name=Intragnb-InterFreq-HO ue_group=125')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-6 and Cell-7

		exec('seq_set id=126 name=Intragnb-InterFreq-HO ue_group=126')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-7 and Cell-6

		exec('seq_set id=127 name=Intragnb-InterFreq-HO ue_group=127')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-8 and Cell-5

		exec('seq_set id=128 name=Intragnb-InterFreq-HO ue_group=128')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')	

--Inter Frequency HO Between Cell-9 and Cell-12

		exec('seq_set id=129 name=Intragnb-InterFreq-HO ue_group=129')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-10 and Cell-11

		exec('seq_set id=130 name=Intragnb-InterFreq-HO ue_group=130')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-11 and Cell-10

		exec('seq_set id=131 name=Intragnb-InterFreq-HO ue_group=131')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-12 and Cell-9

		exec('seq_set id=132 name=Intragnb-InterFreq-HO ue_group=132')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-13 and Cell-16

		exec('seq_set id=133 name=Intragnb-InterFreq-HO ue_group=133')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-14 and Cell-15

		exec('seq_set id=134 name=Intragnb-InterFreq-HO ue_group=134')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')	

--Inter Frequency HO Between Cell-15 and Cell-14

		exec('seq_set id=135 name=Intragnb-InterFreq-HO ue_group=135')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-16 and Cell-13

		exec('seq_set id=136 name=Intragnb-InterFreq-HO ue_group=136')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-17 and Cell-20

		exec('seq_set id=137 name=Intragnb-InterFreq-HO ue_group=137')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=69 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-18 and Cell-19

		exec('seq_set id=138 name=Intragnb-InterFreq-HO ue_group=138')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=68 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-19 and Cell-18

		exec('seq_set id=139 name=Intragnb-InterFreq-HO ue_group=139')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=68 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-20 and Cell-17

		exec('seq_set id=140 name=Intragnb-InterFreq-HO ue_group=140')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=69 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')	

--Inter Frequency HO Between Cell-21 and Cell-24

		exec('seq_set id=141 name=Intragnb-InterFreq-HO ue_group=142')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=73 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=70 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-22 and Cell-23

		exec('seq_set id=142 name=Intragnb-InterFreq-HO ue_group=142')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=72 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=71 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-23 and Cell-22

		exec('seq_set id=143 name=Intragnb-InterFreq-HO ue_group=143')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=71 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=72 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-24 and Cell-21

		exec('seq_set id=144 name=Intragnb-InterFreq-HO ue_group=144')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=70 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=73 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
-----Inter-GNB-------------------
---------------------------------------------------------------------------------------------------

--Intra Frequency HO Between Cell-1 and sim-gNB-3

		exec('seq_set id=145 name=Intergnb-IntraFreq-HO ue_group=145')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-2 and sim-gNB-4

		exec('seq_set id=146 name=Intergnb-IntraFreq-HO ue_group=146')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-3 and sim-gNB-3

		exec('seq_set id=147 name=Intergnb-IntraFreq-HO ue_group=147')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-4 and sim-gNB-4

		exec('seq_set id=148 name=Intergnb-IntraFreq-HO ue_group=148')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Intra Frequency HO Between Cell-5 and sim-gNB-3

		exec('seq_set id=149 name=Intergnb-IntraFreq-HO ue_group=149')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-6 and sim-gNB-4

		exec('seq_set id=150 name=Intergnb-IntraFreq-HO ue_group=150')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-7 and sim-gNB-3

		exec('seq_set id=151 name=Intergnb-IntraFreq-HO ue_group=151')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-8 and sim-gNB-4

		exec('seq_set id=152 name=Intergnb-IntraFreq-HO ue_group=152')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-9 and sim-gNB-3

		exec('seq_set id=153 name=Intergnb-IntraFreq-HO ue_group=153')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-10 and sim-gNB-4

		exec('seq_set id=154 name=Intergnb-IntraFreq-HO ue_group=154')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Intra Frequency HO Between Cell-11 and sim-gNB-3

		exec('seq_set id=155 name=Intergnb-IntraFreq-HO ue_group=155')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-12 and sim-gNB-4

		exec('seq_set id=156 name=Intergnb-IntraFreq-HO ue_group=156')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-13 and sim-gNB-3

		exec('seq_set id=157 name=Intergnb-IntraFreq-HO ue_group=157')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-14 and sim-gNB-4

		exec('seq_set id=158 name=Intergnb-IntraFreq-HO ue_group=158')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-15 and sim-gNB-3

		exec('seq_set id=159 name=Intergnb-IntraFreq-HO ue_group=159')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-16 and sim-gNB-4

		exec('seq_set id=160 name=Intergnb-IntraFreq-HO ue_group=160')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Intra Frequency HO Between Cell-17 and sim-gNB-3

		exec('seq_set id=161 name=Intergnb-IntraFreq-HO ue_group=161')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-18 and sim-gNB-4

		exec('seq_set id=162 name=Intergnb-IntraFreq-HO ue_group=162')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-19 and sim-gNB-3

		exec('seq_set id=163 name=Intergnb-IntraFreq-HO ue_group=163')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=68 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Intra Frequency HO Between Cell-20 and sim-gNB-4

		exec('seq_set id=164 name=Intergnb-IntraFreq-HO ue_group=164')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=69 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-21 and sim-gNB-3

		exec('seq_set id=165 name=Intergnb-IntraFreq-HO ue_group=165')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=70 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-22 and sim-gNB-4

		exec('seq_set id=166 name=Intergnb-IntraFreq-HO ue_group=166')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=71 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Intra Frequency HO Between Cell-23 and sim-gNB-3

		exec('seq_set id=167 name=Intergnb-IntraFreq-HO ue_group=167')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=72 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Intra Frequency HO Between Cell-24 and sim-gNB-4

		exec('seq_set id=168 name=Intergnb-IntraFreq-HO ue_group=168')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=73 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
	
------------------------------------------------------------------------------------------------------

	
--Inter Frequency HO Between Cell-1 and sim-gNB-4

		exec('seq_set id=169 name=Intergnb-InterFreq-HO ue_group=169')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=50 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-2 and sim-gNB-3

		exec('seq_set id=170 name=Intergnb-InterFreq-HO ue_group=170')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=51 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-3 and sim-gNB-4

		exec('seq_set id=171 name=Intergnb-InterFreq-HO ue_group=171')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=52 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-4 and sim-gNB-3

		exec('seq_set id=172 name=Intergnb-InterFreq-HO ue_group=172')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=53 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Inter Frequency HO Between Cell-5 and sim-gNB-4

		exec('seq_set id=173 name=Intergnb-InterFreq-HO ue_group=173')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=54 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-6 and sim-gNB-3

		exec('seq_set id=174 name=Intergnb-InterFreq-HO ue_group=174')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=55 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-7 and sim-gNB-4

		exec('seq_set id=175 name=Intergnb-InterFreq-HO ue_group=175')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-8 and sim-gNB-3

		exec('seq_set id=176 name=Intergnb-InterFreq-HO ue_group=176')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-9 and sim-gNB-4

		exec('seq_set id=177 name=Intergnb-InterFreq-HO ue_group=177')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-10 and sim-gNB-3

		exec('seq_set id=178 name=Intergnb-InterFreq-HO ue_group=178')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Inter Frequency HO Between Cell-11 and sim-gNB-4

		exec('seq_set id=179 name=Intergnb-InterFreq-HO ue_group=179')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-12 and sim-gNB-3

		exec('seq_set id=180 name=Intergnb-InterFreq-HO ue_group=180')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-13 and sim-gNB-4

		exec('seq_set id=181 name=Intergnb-InterFreq-HO ue_group=181')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=62 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-14 and sim-gNB-3

		exec('seq_set id=182 name=Intergnb-InterFreq-HO ue_group=182')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=63 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-15 and sim-gNB-4

		exec('seq_set id=183 name=Intergnb-InterFreq-HO ue_group=183')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=64 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-16 and sim-gNB-3

		exec('seq_set id=184 name=Intergnb-InterFreq-HO ue_group=184')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=65 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Inter Frequency HO Between Cell-17 and sim-gNB-4

		exec('seq_set id=185 name=Intergnb-InterFreq-HO ue_group=185')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=66 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-18 and sim-gNB-3

		exec('seq_set id=186 name=Intergnb-InterFreq-HO ue_group=186')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=67 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-19 and sim-gNB-4

		exec('seq_set id=187 name=Intergnb-InterFreq-HO ue_group=187')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=68 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

--Inter Frequency HO Between Cell-20 and sim-gNB-3

		exec('seq_set id=188 name=Intergnb-InterFreq-HO ue_group=188')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=69 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-21 and sim-gNB-4

		exec('seq_set id=189 name=Intergnb-InterFreq-HO ue_group=189')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=70 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-22 and sim-gNB-3

		exec('seq_set id=190 name=Intergnb-InterFreq-HO ue_group=190')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=71 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		

--Inter Frequency HO Between Cell-23 and sim-gNB-4

		exec('seq_set id=191 name=Intergnb-InterFreq-HO ue_group=191')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=2 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=72 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		
--Inter Frequency HO Between Cell-24 and sim-gNB-3

		exec('seq_set id=192 name=Intergnb-InterFreq-HO ue_group=192')
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=1 tgt_cell_ssb_frequency=127010')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=73 tgt_cell_ssb_frequency=432970')
		exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

---------------------------------------------------------------------------------------------------
-----RNA-------------------
---------------------------------------------------------------------------------------------------

if RNA_UPDATE == 'T380' then
    for seq_gr_id = 193,216 do		

        exec('seq_set id='..seq_gr_id..' name=RNA-'..seq_gr_id..' ue_group='..seq_gr_id..'')	
	    exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
	    exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
	    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=750 size=1350 seconds=8')
	    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=125 size=1350 seconds=8')			
    	exec('seq_delay '..duration..'')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
	    exec('seq_end')
    end	
else
    for seq_gr_id = 193,216 do

        exec('seq_set id='..seq_gr_id..' name=RNA_UPDATE'..seq_gr_id..' ue_group='..seq_gr_id)
        exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1  nwslice=1')
        exec('seq_delay  '..ue_active_delay..'')
        exec('seq_loop_start loop='..RNA_LOOP_count..'')
            exec('seq_delay '..RRC_inactive_timer..'')
            exec("ue_nr_rrc_resume")
        exec("seq_loop_end")
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
    end
end

---------------------------------------------------------------------------------------------------
-----TAU-------------------
---------------------------------------------------------------------------------------------------

for seq_gr_id = 217,240 do		

		exec('seq_set id='..seq_gr_id..' name=TAU-'..seq_gr_id..' ue_group='..seq_gr_id..'')
		exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration'	)
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
		exec('seq_loop_start loop='..TAU_LOOP_count..'')
			exec('seq_delay 16')
			exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg reactivate_pdu=off use_suci=off registration_type=MobilityRegistrationUpdting')
		exec("seq_loop_end"	)
		exec('seq_delay 1'	)
		exec('ue_deregister by=ue ue_deregister_type=switch_off')	
		exec('seq_end')

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DRB addition:
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
for seq_gr_id =241,264 do

    exec('seq_set id='..seq_gr_id..' name=Pet_PDU-add-del'..seq_gr_id..' ue_group='..seq_gr_id..'')
    exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
	exec('seq_delay 1')
	exec("ue_pdu_session_setup pdu=2 gw=1 nwslice=1")
    exec('seq_delay 13')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---VONR-------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

for seq_gr_id =265 ,288 do

    exec('seq_set id='..seq_gr_id..' name=Pet_VONR'..seq_gr_id..' ue_group='..seq_gr_id..'')
    exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
    exec('seq_delay 0.1')
    exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
    exec('seq_delay 120')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
end	

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---FAKE PAGING-------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    exec('seq_set id=289 name=FAKE_PAGING ue_group=' .. fake_pag_gr_id..'')
    exec('ue_register ue_nr_capabilities=DSS_VONR capability_file=./capability.cfg registration_type=InitialRegistration')
    exec("ue_pdu_session_setup pdu=1  nwslice=1")
    exec('amf_fake_paging_start amf=1-5 gnbs=2 session_id=1 burst_size='..paging_per_amf..' burst_period=1000 tai=' .. PLMN .. '|' .. TAC .. ' 5g_s_tmsi=1:1:2 5g_s_tmsi_num=5 drx_cycle_len=256')
    exec('seq_delay 1')
    --exec('amf_fake_paging_start amf=1-5 gnbs=2 session_id=2 burst_size=1 burst_period=5000 tai=' .. PLMN .. '|' .. TAC .. ' 5g_s_tmsi=1:1:2 5g_s_tmsi_num=5 drx_cycle_len=256')
    exec('seq_delay '..duration..'')
    exec('amf_fake_paging_stop amf=1-5 gnbs=2 session_id=1')
    --exec('seq_delay 1')
    --exec('amf_fake_paging_stop amf=1-5 gnbs=2 session_id=2')
    exec('seq_delay 1')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled') --Proxy proto flag enabled
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled') 
exec('sim_param_set TTI=3 ')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set ENABLE_CORE_LIMIT=on purge_buffer_on_full=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4 max_file_num=50 max_log_size=200M')
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=200M')
exec('sim_start version_check=off')

end

SUBFRAME_FOR_CELLS = {
                        ["1"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["2"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["3"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["4"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["5"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["6"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["7"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["8"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["9"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["10"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["11"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["12"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["13"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["14"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["15"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["16"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["17"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["18"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["19"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["20"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["21"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["22"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["23"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101",
                        ["24"] = "1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"
                        }

DSS_CELL_MAP = {["1"]="1",["2"]="2",["3"]="3",["4"]="4",["5"]="5",["6"]="6",["7"]="7",["8"]="8",["9"]="9",["10"]="10",["11"]="11",["12"]="12",
                ["13"]="13",["14"]="14",["15"]="15",["16"]="16",["17"]="17",["18"]="18",["19"]="19",["20"]="20",["21"]="21",["22"]="22",["23"]="23",["24"]="24" }

--lte to nr map

function DSS_xp_connections()
    exec('enb_xp_param id=1 xp_peers=2')
    sleep(0.5)
    exec('enb_xp_link_up enb=1 target=2')
    sleep(0.5)
    exec('enb_x2_link_up enb=1 target=2')
    sleep(0.5)
	print('DSS_xp_connections script completed')
    exec("sim_log_set flush")
end


function parallel_dss_setup()
    exec('enb_dss_param id=1 feature_flag=on message_sets=DMS3')
    sleep(3)
    exec('enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200')
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_cell_param enb=1 id='..lte_cell..' lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=4')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_cell_dss_feature enb=1 id='..lte_cell..' nr_dl_peak_rate_increase=on superfast_allocation=on')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_cell_param enb=1 id='..lte_cell..' dl_resource_sharing_algo=dl_prb_load_based')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_configure_partnership enb=1 cell='..lte_cell..' dss_peer=2:'..nr_cell..'')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
    exec('enb_crm_cell_resource_reservation enb=1 cell='..lte_cell..'  tgt_enb=2 tgt_cell='..nr_cell..' assigned_dl_maximum_share_to_nr=95 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
    exec('enb_dss_establish_partnership enb=1 cell='..lte_cell..'  tgt_enb=2 tgt_cell='..nr_cell..'')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_cell_resource_reservation_dl enb=1 cell='..lte_cell..'  reset')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_cell_resource_reservation_ul enb=1 cell='..lte_cell..'  reset')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_dl_resource_cell_reservation cell='..lte_cell..'  enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=95 reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_cell_resource_coordination enb=1 cell='..lte_cell..'  tgt_enb=2 tgt_cell='..nr_cell..' dir=DL')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_ul_resource_cell_reservation cell='..lte_cell..'  enb=1 minimum_prb_share=30 maximum_prb_share=70')
    end

    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_cell_resource_coordination enb=1 cell='..lte_cell..'  tgt_enb=2 tgt_cell='..nr_cell..'  dir=UL')
    end

    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_resource_allocation enb=1 cell='..lte_cell..'  tgt_enb=2 tgt_cell='..nr_cell..'  dir=DL allocation_start_time=immediate dl_allocated_normal_subframes='..SUBFRAME_FOR_CELLS[nr_cell]..' dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106')
    end
    sleep(3)
    for lte_cell,nr_cell in pairs(DSS_CELL_MAP) do
        exec('enb_dss_resource_allocation enb=1 cell='..lte_cell..'  tgt_enb=2 tgt_cell='..nr_cell..'  dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3')
    end
	exec('filter_sim_rfm enable=all')
    print('parallel_dss_setup script completed')
    exec("sim_log_set flush")
end
