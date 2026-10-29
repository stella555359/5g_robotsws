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

for ip2 = 1, 28 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 111, 150 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3'..GNB_VLAN..'')
end

for ip4 = 200, 214 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3'..GNB_VLAN..'')
end

for ip5 = 100, 102 do	--To configure IP 10.0.1.102,.. on eth4. If interface has vlan 1001, configure below with dev eth4.1001'
    os.execute('sudo ip addr add 10.0.1.'..ip5..'/24 dev eth4'..AP_VLAN..'')
end

os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA

----------------------------------------------------------------------------------------------------
--COMMON VARIABLES for ALL WTS
----------------------------------------------------------------------------------------------------

EDAEMON_IP="10.0.2.1"
EDAEMON_PORT=22222


MULTI_AP_FLAG = 'NO' --YES/NO
cellDepType = 'Both'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Enabled = 'NO'  --Sim-gNBs configured for Handover if set to 'YES'

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
SA_IMSI = 21645400
NSA_IMSI = 21645500



-------------------------------------------------------------------------------------
-- FOR REAL GNB VARIABLE
--------------------------------------------------------------------------------------
REAL_gNB_ID=2

GNB_X2_ADDR = "10.0.1.2"
GNB_S1U_ADDR = "10.0.2.112"
GNB_XN_ADDR = GNB_X2_ADDR
GNB_NG_ADDR = GNB_X2_ADDR
GNB_NGU_ADDR="10.0.2.112"

MUTLI_AP_IP_TABLE 	= { "10.0.2.80",
						"10.0.2.90",
						}  --IP table for each AP

NR_CELL_ID_TABLE_AP1	= { 1 }	--Cells belong to Airphone-1
	
NR_CELL_ID_TABLE_AP2	= {  }	--Cells belong to Airphone-2


NR_CELLS_IN_AP1 = #NR_CELL_ID_TABLE_AP1

NR_CELLS_IN_AP2 = #NR_CELL_ID_TABLE_AP2



NR_CELL_TECH_TABLE_AP1	= { "TDD",			}	--Cells Tech of Airphone-1

NR_CELL_TECH_TABLE_AP2	= { }	--Cells Tech of Airphone-2


PCI_TABLE_AP1   = { "16:2",
                    	}
	

	
PCI_TABLE_AP2   = { } 
				
				
 --Table for ARFCN
 
NR_ARFCN_TABLE_AP1 	= { "2070015:2070015"
					 }  -- NRARFCN UL:DL for each cell

			 
NR_ARFCN_TABLE_AP2  = { } -- NRARFCN UL:DL for each cell


 --Table for GSCN 
						
GSCN_TABLE_AP1   =   { 	"22441",
						}

GSCN_TABLE_AP2   =   { }

---------------------------------------------------------------------------------------------------
--5G CN SIM VARIABLE
---------------------------------------------------------------------------------------------------					

AMF_COUNT = 1   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only

FIRST_AMF_ID = 1   --Starting AMF id
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
	
	
AMF_IP_TABLE 	= { "10.0.1.1",
                    }  --IP table for each AMF

UPF_IP_TABLE 	= { "1.2.4.1",
                    }  --IP table for each UPF
UPF_NGU_IP_TABLE = {
					"10.0.2.100",
					}
					
---------------------------------------------------------------------------------------------------
--4G SIM VARIABLE
---------------------------------------------------------------------------------------------------

MME_COUNT=1

LTE_CORE_COUNT=1

MME_S1_IP_TABLE    =   {   "10.0.1.131",
                      }   --IP table for each MME
					
SGW_S1U_IP_TABLE 	= { "10.0.1.133",
                        }  --IP table for each SGW S1U
SGW_S11_IP_TABLE 	= { 
						"10.0.1.134",
                        }  --IP table for each SGW S11

SGW_S11U_IP_TABLE    = {
						"10.0.2.102",
					}

PGW_IP_TABLE    =   {   "4.7.254.207",
                      }  --IP table for each PGW

-- SIM ENB VARIABLES

NUM_SIM_ENB = 1


NUM_CELL_PER_SIM_ENB = 1

SIM_ENB_IDENTIFIER = {1,4,5,6,7,8}

SIM_ENB_SERVER_IP_TABLE = { "10.0.2.1",
                           }  --Daemon IP table for each sim-gNB

SIM_ENB_X2_OR_XP_TABLE = {	"10.0.1.137",
					   }
					   
SIM_ENB_X2U_TABLE = { 
						"10.0.1.135",
					}
					
SIM_ENB_S1_ADDR = { "10.0.1.136",
				}
				
SIM_ENB_PCI   = {	
					{"3:2"} ,
				 }
SIM_ENB_CELL_TECH_TABLE = { 
							{"TDD"},
						}
					
SIM_ENB_EARFCN =  { {"4200:22200"},
                    } -- EARFCN DL:UL for each cell
				  

---------------------------------------------------------------------------------------------------
--5G GNB SIM VARIABLE
---------------------------------------------------------------------------------------------------
if HO_Enabled == 'YES' then

NUM_SIM_GNB=1

SIM_GNB_IDENTIFIER = {9}

NUM_CELL_PER_SIM_GNB=1
			  
SIM_GNB_SERVER_IP_TABLE	= { "10.0.2.14",
            	           }  --Daemon IP table for each sim-gNB

SIM_GNB_XN_IP_TABLE	= { "10.0.1.201",
           	           }  --XN IP table for each sim-gNB
					   
SIM_GNB_NG_IP_TABLE	= { "10.0.1.202",
        	           }  --NG IP table for each sim-gNB

SIM_GNB_PCI_TABLE	= { {"0:1"},
	    				}  -- 6 phycical cell ids configured in table
						
SIM_GNB_CELL_TECH_TABLE = { {"FDD"},
	    				}

SIM_GNB_NR_ARFCN_TABLE 	= { {"390000:424000"},
                        }  
SIM_GNB_GSCN_TABLE  = 	{ 	{"5297"},
						}   --Table for GSCN

end
--------------------------------------------------------------------------------------------------
--UEC configuration
--------------------------------------------------------------------------------------------------


UEC_COUNT = 1   --Total number of UEC

UEC_PEERUPLANE={ "10.0.2.101" }

---------------------------------------------------------
--UE GROUP 
---------------------------------------------------------

SA_UE_GROUP_COUNT_PER_CELL = 1   --Number of PET_SE UE_Groups per cell
NSA_UE_GROUP_COUNT_PER_CELL = 1

TOTAL_SA_UE_GROUP_FOR_AP1 = NR_CELLS_IN_AP1*SA_UE_GROUP_COUNT_PER_CELL
TOTAL_SA_UE_GROUP_FOR_AP2 = NR_CELLS_IN_AP2*SA_UE_GROUP_COUNT_PER_CELL

SA_UE_GROUP_START=1
SA_UE_GROUP_END = TOTAL_SA_UE_GROUP_FOR_AP1 + TOTAL_SA_UE_GROUP_FOR_AP2

TOTAL_NSA_UE_GROUP_FOR_AP1 = NR_CELLS_IN_AP1*NSA_UE_GROUP_COUNT_PER_CELL
TOTAL_NSA_UE_GROUP_FOR_AP2 = NR_CELLS_IN_AP2*NSA_UE_GROUP_COUNT_PER_CELL

NSA_UE_GROUP_START=SA_UE_GROUP_END + 1
NSA_UE_GROUP_END = SA_UE_GROUP_END + TOTAL_NSA_UE_GROUP_FOR_AP1 + TOTAL_NSA_UE_GROUP_FOR_AP2

-------------------------------------------------------------------------------------
-- UE RELATED VARIABLE
-------------------------------------------------------------------------------------

--SA UEs
SA_UES_PER_GROUP=0

TOTAL_SA_UES_PER_CELL = SA_UE_GROUP_COUNT_PER_CELL*SA_UES_PER_GROUP

TOTAL_SA_UES_PER_AP1 = NR_CELLS_IN_AP1*TOTAL_SA_UES_PER_CELL

TOTAL_SA_UES_PER_AP2 = NR_CELLS_IN_AP2*TOTAL_SA_UES_PER_CELL

SA_UE=TOTAL_SA_UES_PER_AP1+TOTAL_SA_UES_PER_AP2

--NSA UEs

NSA_UES_PER_GROUP=40

TOTAL_NSA_UES_PER_CELL = NSA_UE_GROUP_COUNT_PER_CELL*NSA_UES_PER_GROUP

TOTAL_NSA_UES_PER_AP1 = NR_CELLS_IN_AP1*TOTAL_NSA_UES_PER_CELL

TOTAL_NSA_UES_PER_AP2 = NR_CELLS_IN_AP2*TOTAL_NSA_UES_PER_CELL


function run_configuration(timer)

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
UEC_IP2 = UEC_COUNT + 2
UEC_IP = 1

for uec_id = 1, UEC_COUNT do
    exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane='..UEC_PEERUPLANE[uec_id]..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
end

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id='..REAL_gNB_ID..' type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' ngu='..GNB_NGU_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x76C daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..' xp_management=on xp='..GNB_X2_ADDR..':32742 xpu='..GNB_X2_ADDR..':32742')

for cell_count=1, #NR_CELL_ID_TABLE_AP1 do   
	
	local nrci_i = NR_CELL_ID_TABLE_AP1[cell_count]
    local nrci_o = string.format("%x", nrci_i)
	if NR_CELL_TECH_TABLE_AP1[cell_count] == 'FDD' then
        tdd_flag = 'off'
    else
        tdd_flag = 'on'
    end
	PROXY_SERVER = MUTLI_AP_IP_TABLE[1]
	exec('set_cell id='..NR_CELL_ID_TABLE_AP1[cell_count]..' gnb='..REAL_gNB_ID..' gscn='..GSCN_TABLE_AP1[cell_count]..' pci='..PCI_TABLE_AP1[cell_count]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE_AP1[cell_count]..' mandatory_for_activation=off')
	
end

if MULTI_AP_FLAG == "YES" then
    
	for cell_count=1, #NR_CELL_ID_TABLE_AP2 do   
		
		local nrci_i = NR_CELL_ID_TABLE_AP2[cell_count]
		local nrci_o = string.format("%x", nrci_i)
		
		if NR_CELL_TECH_TABLE_AP2[cell_count] == 'FDD' then
			tdd_flag = 'off'
		else
			tdd_flag = 'on'
		end
		PROXY_SERVER = MUTLI_AP_IP_TABLE[2]
		exec('set_cell id='..NR_CELL_ID_TABLE_AP2[cell_count]..' gnb='..REAL_gNB_ID..' gscn='..GSCN_TABLE_AP2[cell_count]..' pci='..PCI_TABLE_AP2[cell_count]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER..':9999|'..PROXY_SERVER..':8888 nr_arfcn='..NR_ARFCN_TABLE_AP2[cell_count]..' mandatory_for_activation=off')
		
	end

end

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
if cellDepType == 'NSA' or cellDepType == 'Both' then

	exec('mme_pool_area id=1 mmegi=1 plmn='..PLMN..' tac_list=777,111,222,444,333,'..TAC..'')

    for mme_id=1, MME_COUNT do
        exec('set_mme id='..mme_id..' name=SimModeMME-'..mme_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..MME_S1_IP_TABLE[mme_id]..':36412 s11='..SGW_S11U_IP_TABLE[mme_id]..':57973 supported_rat=lte,nblte pool=1:1')
    end

    for sgw_id = 1,LTE_CORE_COUNT do
        exec('set_sgw id='..sgw_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1u='..SGW_S11U_IP_TABLE[sgw_id]..' s11='..SGW_S11U_IP_TABLE[sgw_id]..':60100 s11u='..SGW_S11U_IP_TABLE[sgw_id]..':57972 s5='..SGW_S11U_IP_TABLE[sgw_id]..':60518 s5u='..SGW_S11U_IP_TABLE[sgw_id]..':60519 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=20')
        exec('set_pgw id='..sgw_id..' type=simulated ip='..EDAEMON_IP..':'..EDAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 s5='..SGW_S11U_IP_TABLE[sgw_id]..':60520 s5u='..SGW_S11U_IP_TABLE[sgw_id]..':60521 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
    end
end

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
local cell_udp_port=12219
if cellDepType == 'NSA' or cellDepType == 'Both' then
    for sim_enb_count = 1, NUM_SIM_ENB do
        
        exec('enb_set id='..SIM_ENB_IDENTIFIER[sim_enb_count]..' name=SimModeLTERAN-'..sim_enb_count..' type=simulated plmn='..PLMN..' s1='..SIM_ENB_S1_ADDR[sim_enb_count]..' enb_id_macro=0x0000'..sim_enb_count..' daemon='..SIM_ENB_SERVER_IP_TABLE[sim_enb_count]..':'..EDAEMON_PORT..' x2='..SIM_ENB_X2_OR_XP_TABLE[sim_enb_count]..' x2u='..SIM_ENB_X2U_TABLE[sim_enb_count]..' x2_peers=none mme='..sim_enb_count..'')
        exec('enb_param id='..SIM_ENB_IDENTIFIER[sim_enb_count]..' drb_id_begin=3 endc_capable_qci=7,9')
        exec('enb_endc_param id='..SIM_ENB_IDENTIFIER[sim_enb_count]..' control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:31')
        for sim_enb_cell_id = 1 ,NUM_CELL_PER_SIM_ENB do
            
            if SIM_ENB_CELL_TECH_TABLE[sim_enb_count][sim_enb_cell_id] == 'FDD' then
                tdd_flag = 'off'
            else
                tdd_flag = 'on'
            end
            exec('set_cell id='..sim_enb_cell_id..' enb='..SIM_ENB_IDENTIFIER[sim_enb_count]..' eci=0x0000'..sim_enb_count..'0'..sim_enb_cell_id..' pci='..SIM_ENB_PCI[sim_enb_count][sim_enb_cell_id]..' tac=222 proxy='..SIM_ENB_SERVER_IP_TABLE[sim_enb_count]..':'..cell_udp_port..'|'..SIM_ENB_SERVER_IP_TABLE[sim_enb_count]..':8889 earfcn='..SIM_ENB_EARFCN[sim_enb_count][sim_enb_cell_id]..' tdd_cell='..tdd_flag..' bw=20MHz mandatory_for_activation=off')
            cell_udp_port=cell_udp_port+1
        end
    end
end

----------------------------------------------------------------------------------------------------
--SIM-GNB CONFIGURATION
----------------------------------------------------------------------------------------------------

if HO_Enabled == 'YES' then

	for sim_gnb_count = 1, NUM_SIM_GNB do
		local sim_nrci_o = string.format("%x", sim_gnb_id)
		
		exec('set_gnb id='..SIM_GNB_IDENTIFIER[sim_gnb_count]..' name=SimMode5GRAN-'..sim_gnb_id..' type=simulated plmn='..PLMN..' daemon='..SIM_GNB_SERVER_IP_TABLE[sim_gnb_count]..':'..EDAEMON_PORT..' xn='..SIM_GNB_XN_IP_TABLE[sim_gnb_count]..' ng='..SIM_GNB_NG_IP_TABLE[sim_gnb_count]..' gnb_id=0x'..sim_nrci_o..' x2_peers= amf=1-'..AMF_COUNT..' plmnList='..PLMN..' nssai='..SNSSAI)
		exec('gnb_param id='..SIM_GNB_IDENTIFIER[sim_gnb_count]..' xn_listening_socket=on send_xn_setup=on measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
		exec('enb_timer T_RELOCprepTimeout=2000')
		for sim_enb_cell_id = 1 ,NUM_CELL_PER_SIM_GNB do
            if SIM_GNB_CELL_TECH_TABLE[sim_gnb_count][sim_enb_cell_id] == 'FDD' then
                tdd_flag = 'off'
            else
                tdd_flag = 'on'
            end
			exec('set_cell id='..sim_enb_cell_id..' gnb='..sim_gnb_count..' pci='..SIM_GNB_PCI_TABLE[sim_gnb_count]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[sim_gnb_count]..':9999|'..SIM_GNB_SERVER_IP_TABLE[sim_gnb_count]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[sim_gnb_count]..' mandatory_for_activation=off gscn='..SIM_GNB_GSCN_TABLE[sim_gnb_count]..'')
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
    exec('set_upf id='..amf_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[amf_id]..'/21 ngu='..UPF_NGU_IP_TABLE[amf_id]..' devname=tunUPF'..amf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

    exec('smf_upf_mapping id='..amf_id..' upf='..amf_id)
    exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
	
end


-------------------------------------------------------------------------------------------------------
--Traffic profile creation
-------------------------------------------------------------------------------------------------------
--[[exec('set_trf_data_profile profile_id=1 trf_id=1  size=178 kbps=176  seconds=8')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=859 kbps=1166  seconds=8') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')  -----> for VoNR same traffic in DL and UL
--]]


----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--UE GROUPS AND UE ASSIGNMENT  FOR PET_SE
---------------------------------------------------------------------------------------------------

--SA UE GROUP

uecid = 1
cell_index=1

for ue_group_id = SA_UE_GROUP_START, TOTAL_SA_UE_GROUP_FOR_AP1 do
	if NR_CELLS_IN_AP1 > cell_index then
		cell_index=1
	end
	if uecid > UEC_COUNT then
		uecid = 1
	end
	exec("set_ue_group id="..ue_group_id.." name=UE_GRP-SA-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP1[cell_index].." uec="..uecid.." enb="..REAL_gNB_ID.." cell="..NR_CELL_ID_TABLE_AP1[cell_index].." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
	cell_index = cell_index + 1
	uecid = uecid + 1
end

if MULTI_AP_FLAG == "YES" then

	cell_index=1

	for ue_group_id = (TOTAL_SA_UE_GROUP_FOR_AP1+1),(TOTAL_SA_UE_GROUP_FOR_AP1+TOTAL_SA_UE_GROUP_FOR_AP2) do
		if NR_CELLS_IN_AP2 > cell_index then
			cell_index=1
		end
		if uecid > UEC_COUNT then
			uecid = 1
		end
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-SA-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP2[cell_index].." uec="..uecid.." enb="..REAL_gNB_ID.." cell="..NR_CELL_ID_TABLE_AP2[cell_index].." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
		cell_index = cell_index + 1
		uecid = uecid + 1
	end
end

--NSA UE GROUP

uecid = 1
cell_index=1
pgw_id = 1

for ue_group_id = (NSA_UE_GROUP_START),(NSA_UE_GROUP_START+TOTAL_NSA_UE_GROUP_FOR_AP1-1) do
    if NR_CELLS_IN_AP1 > cell_index then
        cell_index=1
    end
    if uecid > UEC_COUNT then
        uecid = 1
    end
    if pgw_id > LTE_CORE_COUNT then
        pgw_id = 1
    end
    exec("set_ue_group id="..ue_group_id.." name=UE_GRP-NSA-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP1[cell_index].." uec="..uecid.." pdn="..pgw_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g")
    exec('set_bearer id=2 ue_group='..ue_group_id..' qci=9 pdn='..pgw_id..' default=on trf_type=internal dl_nat_gw='..EDAEMON_IP..' ul_nat_gw='..EDAEMON_IP)
    exec('set_bearer id=3 ue_group='..ue_group_id..' qci=7 pdn='..pgw_id..'')
    cell_index = cell_index + 1
    uecid = uecid + 1
    pgw_id = pgw_id + 1
end

if MULTI_AP_FLAG == "YES" then

    cell_index=1

    for ue_group_id = (NSA_UE_GROUP_START+TOTAL_NSA_UE_GROUP_FOR_AP1+1),(NSA_UE_GROUP_START+TOTAL_NSA_UE_GROUP_FOR_AP1+TOTAL_NSA_UE_GROUP_FOR_AP2-1) do
        if NR_CELLS_IN_AP2 > cell_index then
            cell_index=1
        end
        if uecid > UEC_COUNT then
            uecid = 1
        end
        if pgw_id > LTE_CORE_COUNT then
            pgw_id = 1
        end
        exec("set_ue_group id="..ue_group_id.." name=UE_GRP-NSA-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP2[cell_index].." uec="..uecid.." pdn="..pgw_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g")
        exec('set_bearer id=2 ue_group='..ue_group_id..' qci=9 pdn='..pgw_id..' default=on trf_type=internal dl_nat_gw='..EDAEMON_IP..' ul_nat_gw='..EDAEMON_IP)
        exec('set_bearer id=3 ue_group='..ue_group_id..' qci=7 pdn='..pgw_id..'')
        cell_index = cell_index + 1
        uecid = uecid + 1
        pgw_id = pgw_id + 1
    end
end

--------------------------------------------------------------------------
-- SA UE ASSIGNMENT
---------------------------------------------------------------------------


UE_COUNT=1
ue_group_id=SA_UE_GROUP_START
cell_index=1

if  cellDepType == 'SA' or cellDepType  == 'Both' then
	
	for SA_UEID = 1, TOTAL_SA_UES_PER_AP1 do

		if UE_COUNT > SA_UES_PER_GROUP then
			ue_group_id=ue_group_id+1
            cell_index=cell_index+1
			UE_COUNT=1
		end
		exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb='..REAL_gNB_ID..' cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
		
		UE_COUNT=UE_COUNT+1
	end
end

cell_index=1
if MULTI_AP_FLAG == "YES" then

	UE_COUNT =1
	ue_group_id = SA_UE_GROUP_START+TOTAL_SA_UE_GROUP_FOR_AP1+1

	if cellDepType == 'SA' or cellDepType == 'Both' then
		
		for SA_UEID = (TOTAL_SA_UES_PER_AP1+1), (TOTAL_SA_UES_PER_AP1+TOTAL_SA_UES_PER_AP2) do
		
			if UE_COUNT > SA_UES_PER_GROUP then
				ue_group_id=ue_group_id+1
                cell_index=cell_index+1
				UE_COUNT=1
			end
			exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb='..REAL_gNB_ID..' cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
			exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
			
			UE_COUNT=UE_COUNT+1
		end
	end

end 

--------------------------------------------------------------------------
-- NSA UE ASSIGNMENT
---------------------------------------------------------------------------

UE_COUNT=1
ue_group_id=NSA_UE_GROUP_START
sim_enb_count=1
enb_cell_id=1

if cellDepType == 'NSA' or cellDepType == 'Both' then
	
	for NSA_UEID = (SA_UE+1), (SA_UE+TOTAL_NSA_UES_PER_AP1) do
		if UE_COUNT > NSA_UES_PER_GROUP then
			ue_group_id=ue_group_id+1
            enb_cell_id=enb_cell_id+1
            
            if enb_cell_id > NUM_CELL_PER_SIM_ENB then
                enb_cell_id=1
                sim_enb_count=sim_enb_count+1
            end
            if sim_enb_count >  NUM_SIM_ENB then
                sim_enb_count=1
            end

			UE_COUNT=1
		end
		exec('set_ue id='..NSA_UEID..' group='..ue_group_id..' enb='..SIM_ENB_IDENTIFIER[sim_enb_count]..' cell='..enb_cell_id..' sec_key=0102030405060708090A0B0C0D0EFF00 imsi='..PLMN..':'.. NSA_IMSI + NSA_UEID - 1)
	    exec('ue_param id='..NSA_UEID..' dual_conn=eutra_nr')	
		UE_COUNT=UE_COUNT+1
	end
end
cell_index=1
sim_enb_count=1
enb_cell_id=1

if MULTI_AP_FLAG == "YES" then

	UE_COUNT =1
	ue_group_id = NSA_UE_GROUP_START+TOTAL_NSA_UE_GROUP_FOR_AP1+1

	if cellDepType == 'NSA' or cellDepType == 'Both' then
		
		for NSA_UEID = (SA_UE+TOTAL_NSA_UES_PER_AP1+1), (SA_UE+TOTAL_NSA_UES_PER_AP1+TOTAL_NSA_UES_PER_AP2) do
		    
			if UE_COUNT > NSA_UES_PER_GROUP then
				ue_group_id=ue_group_id+1
				enb_cell_id=enb_cell_id+1
           
                if enb_cell_id > NUM_CELL_PER_SIM_ENB then
                    enb_cell_id=1
                    sim_enb_count=sim_enb_count+1
                end
                if sim_enb_count >  NUM_SIM_ENB then
                    sim_enb_count=1
                end 
              
                UE_COUNT=1
			end
			exec('set_ue id='..NSA_UEID..' group='..ue_group_id..' enb='..SIM_ENB_IDENTIFIER[sim_enb_count]..' cell='..enb_cell_id..' sec_key=0102030405060708090A0B0C0D0EFF00 imsi='..PLMN..':'.. NSA_IMSI + NSA_UEID - 1)
			exec('ue_param id='..NSA_UEID..' dual_conn=eutra_nr')
			UE_COUNT=UE_COUNT+1
		end
	end

end


---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
exec('set_qosflow id=4 5qi=8 default=off')
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1,2,3 amf_region_id=1 plmn_list='..PLMN..'  ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
--exec("smf_param id=2 additional_qosflows_to_activate=2")
--exec("smf_param id=3 additional_qosflows_to_activate=2")
--exec("smf_param id=4 additional_qosflows_to_activate=2")
--exec("smf_param id=5 additional_qosflows_to_activate=2")

-------------------------------------------
--SA SEQUENCE
-------------------------------------------

-------------------------------------------
--NSA SEQUENCE
-------------------------------------------
if PET_SE_FLAG == 'yes' then

cell_id=1
ue_group_id=NSA_UE_GROUP_START

--TC12:DCM_FR2_PROFILE_3_DL_540Mbps--

	for seq_gr_id = 1,1 do
        if ue_group_id > (NSA_UE_GROUP_START+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
            ue_group_id=NSA_UE_GROUP_START
        end
        if cell_id > (NR_CELLS_IN_AP1+NR_CELLS_IN_AP2) then
            cell_id=1
        end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..ue_group_id)
        exec('ue_attach ue_nr_capabilities=UL_1UE_MMWV ue_eutra_nr_capabilities=NSA_FR2_DCM capability_file=./capability.cfg ')
		exec('seq_delay 1.0')
        exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
        exec('seq_delay 1.0')
	exec('trf_data_start id=2 dir=dl trf_id=1 mbps=160 size=1350')
        exec('trf_data_start id=2 dir=dl trf_id=2 mbps=160 size=1350')
        exec('trf_data_start id=2 dir=dl trf_id=3 mbps=160 size=1350')
        exec('trf_data_start id=2 dir=dl trf_id=4 mbps=60 size=1350')	
	    exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1-4')
        --exec('trf_data_stop id=2 dir=ul trf_id=1')
		exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
        cell_id=cell_id+1
        ue_group_id=ue_group_id+1
	end
end

if PET_SE_FLAG == 'yes' then

cell_id=1
ue_group_id=NSA_UE_GROUP_START

--TC13:DCM_FR2_PROFILE_3_UL_140Mbps--

	for seq_gr_id = 2,2 do
        if ue_group_id > (NSA_UE_GROUP_START+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
            ue_group_id=NSA_UE_GROUP_START
        end
        if cell_id > (NR_CELLS_IN_AP1+NR_CELLS_IN_AP2) then
            cell_id=1
        end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..ue_group_id)
        exec('ue_attach ue_nr_capabilities=UL_1UE_MMWV ue_eutra_nr_capabilities=NSA_FR2_DCM capability_file=./capability.cfg ')
		exec('seq_delay 1.0')
        exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
        exec('seq_delay 1.0')
	exec('trf_data_start id=2 dir=ul trf_id=1 mbps=140 size=1350')	
	    exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=ul trf_id=1')
        --exec('trf_data_stop id=2 dir=ul trf_id=1')
		exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
        cell_id=cell_id+1
        ue_group_id=ue_group_id+1
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
exec('sim_param_set ENABLE_CORE_LIMIT=on purge_buffer_on_full=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=5 max_file_num=50 max_log_size=200M')
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=200M')
exec('sim_start version_check=off')

end
