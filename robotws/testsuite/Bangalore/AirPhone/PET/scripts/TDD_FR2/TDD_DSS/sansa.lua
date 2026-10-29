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
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3')
end

for ip2 = 3, 28 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4')
end

for ip3 = 121, 139 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3')
end

for ip4 = 200, 214 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3')
end

os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA

----------------------------------------------------------------------------------------------------
--COMMON VARIABLES for ALL WTS
----------------------------------------------------------------------------------------------------

EDAEMON_IP="10.0.2.1"
EDAEMON_PORT=22222


MULTI_AP_FLAG = 'no'
cellDepType = 'SA+NSA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Enabled = 'no'  --Sim-gNBs configured for Handover if set to 'yes'


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

NR_CELL_ID_TABLE_AP1	= { 1,2 ,3,4,5,6 }	--Cells belong to Airphone-1

NR_CELL_ID_TABLE_AP2	= { }	--Cells belong to Airphone-2

NR_CELLS_IN_AP1 = #NR_CELL_ID_TABLE_AP1

NR_CELLS_IN_AP2 = #NR_CELL_ID_TABLE_AP2

NR_CELL_TECH_TABLE_AP1	= { "TDD",
							"TDD",
							"TDD",
							"FDD",
							"FDD",
							"FDD"
							}	--Cells Tech of Airphone-1

NR_CELL_TECH_TABLE_AP2	= {}	--Cells Tech of Airphone-2


PCI_TABLE_AP1   = { "16:2",
                    "17:0",
					"17:1",
					"17:2",
					"18:0",
					"18:1"
					
					}
					
PCI_TABLE_AP2   = { } 
					
 --Table for ARFCN
 
NR_ARFCN_TABLE_AP1 	= { "650000:650000",
                        "528600:528600",
                        "623400:623400",
                        "136300:127100",
                        "348440:433000",
                        "348600:428600"
					 }  -- NRARFCN UL:DL for each cell
					 
NR_ARFCN_TABLE_AP2  = { } -- NRARFCN UL:DL for each cell
 --Table for GSCN 
						
GSCN_TABLE_AP1   =   { 	"8019",
						"6570",
                        "7742",
                        "1588",
                        "5411",
                        "5356"
                    }

GSCN_TABLE_AP2   =   {}

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


NUM_CELL_PER_ENB = 3

ENB_X2_OR_XP_TABLE = {"10.0.1.137",
					   }
ENB_S1_ADDR = { "10.0.1.138",
				}
				
SIM_ENB_PCI   = {	"3:2",
					"4:0",
					"4:1"
					}
ENB_CELL_TECH_TABLE = { "FDD",
						"FDD",
						"FDD"
						}
					
SIM_ENB_EARFCN =  { 
                    "68771:133307",
					"66986:132294",
				    "66766:132302" 		--need to change as per nrarfcn for cell 3
                    } -- EARFCN DL:UL for each cell
				  

---------------------------------------------------------------------------------------------------
--5G GNB SIM VARIABLE
---------------------------------------------------------------------------------------------------
NUM_SIM_GNB=3
			  
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


--------------------------------------------------------------------------------------------------
--UEC configuration
--------------------------------------------------------------------------------------------------


UEC_COUNT = 6   --Total number of UEC
UE_GROUP_COUNT_PER_CELL = 1   --Number of PET_SE UE_Groups per cell

TOTAL_UE_GROUP_FOR_AP1 = NR_CELLS_IN_AP1*UE_GROUP_COUNT_PER_CELL
TOTAL_UE_GROUP_FOR_AP2 = NR_CELLS_IN_AP2*UE_GROUP_COUNT_PER_CELL

-------------------------------------------------------------------------------------
-- UE RELATED VARIABLE
-------------------------------------------------------------------------------------

SA_UES_PER_GROUP=1500

TOTAL_SA_UES_PER_CELL = UE_GROUP_COUNT_PER_CELL*SA_UES_PER_GROUP

TOTAL_SA_UES_PER_AP1 = NR_CELLS_IN_AP1*TOTAL_SA_UES_PER_CELL

TOTAL_SA_UES_PER_AP2 = NR_CELLS_IN_AP2*TOTAL_SA_UES_PER_CELL

function run_configuration(duration)

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
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x2 daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..' xp_management=on xp='..GNB_X2_ADDR..':32742 xpu='..GNB_X2_ADDR..':32742')

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

    local cell_udp_port=12219
	exec('set_enb id=1 plmn='..PLMN..' s1='..ENB_S1_ADDR[1]..' enb_id_macro=0x00001 daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2='..ENB_X2_OR_XP_TABLE[1]..' x2u='..ENB_X2_OR_XP_TABLE[1]..' type=simulated xp_management=on xp='..ENB_X2_OR_XP_TABLE[1]..':32742 xpu='..ENB_X2_OR_XP_TABLE[1]..':32742 x2_peers=none')
    exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
	exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:31')
    exec('enb_xp_param id=1  xp_peers=2 ignore_xp=off xp_listening_socket=on')
	for enb_cell_id = 1 ,NUM_CELL_PER_ENB do
        if ENB_CELL_TECH_TABLE[enb_cell_id] == 'FDD' then
            tdd_flag = 'off'
        else
            tdd_flag = 'on'
        end	
		exec('set_cell id='..enb_cell_id..' enb=1 eci=0x0000101 pci='..SIM_ENB_PCI[enb_cell_id]..' tac=222 proxy='..EDAEMON_IP..':'..cell_udp_port..'|'..EDAEMON_IP..':8889 earfcn='..SIM_ENB_EARFCN[enb_cell_id]..' tdd_cell='..tdd_flag..' bw=20MHz mandatory_for_activation=off')	
	    --exec("enb_cell_param enb=1 id="..enb_cell_id.." lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2")
        cell_udp_port=cell_udp_port+1
    end
		
end

----------------------------------------------------------------------------------------------------
--SIM-GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
if HO_Enabled == 'yes' then
	for simgnb_id = 1, NUM_SIM_GNB do
    local sim_nrci_i = simgnb_id + 2
    local sim_nrci_o = string.format("%x", sim_nrci_i)
    if Test_Tech == 'FDD' then
        tdd_flag = 'off'
    else
        tdd_flag = 'on'
    end
	exec('set_gnb id='..sim_nrci_i..' type=simulated plmn='..PLMN..' daemon='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':'..EDAEMON_PORT..' xn='..SIM_GNB_XN_IP_TABLE[simgnb_id]..' ng='..SIM_GNB_NG_IP_TABLE[simgnb_id]..' gnb_id=0x'..sim_nrci_o..' x2_peers=none amf=1-'..AMF_COUNT..' plmnList='..PLMN..' nssai='..SNSSAI)
	exec('gnb_param id='..sim_nrci_i..' xn_listening_socket=on send_xn_setup=on measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
	exec('enb_timer T_RELOCprepTimeout=2000')
	exec('set_cell id=1 gnb='..sim_nrci_i..' pci='..SIM_GNB_PCI_TABLE[simgnb_id]..' tac='..TAC..' nrci=0x01 tdd_cell='..tdd_flag..' proxy='..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':9999|'..SIM_GNB_SERVER_IP_TABLE[simgnb_id]..':8888 nr_arfcn='..SIM_GNB_NR_ARFCN_TABLE[simgnb_id]..' mandatory_for_activation=off gscn='..SIM_GSCN_TABLE[simgnb_id]..'')
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
--[[exec('set_trf_data_profile profile_id=1 trf_id=1  size=178 kbps=176  seconds=8')  ----started in 2 Non-GBR DRB per UE
exec('set_trf_data_profile profile_id=2 trf_id=1  size=859 kbps=1166  seconds=8') --- started on 2 non-gBR DRB per UE
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')  -----> for VoNR same traffic in DL and UL
--]]


----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--UE GROUPS AND UE ASSIGNMENT  FOR PET_SE
---------------------------------------------------------------------------------------------------

uecid = 1
cell_index=1

for ue_group_id = 1, TOTAL_UE_GROUP_FOR_AP1 do
	if NR_CELLS_IN_AP1 > cell_index then
		cell_index=1
	end
	if uecid > UEC_COUNT then
		uecid = 1
	end
	exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP1[cell_index].." uec="..uecid.." enb=2 cell="..NR_CELL_ID_TABLE_AP1[cell_index].." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
	cell_index = cell_index + 1
	uecid = uecid + 1
end

if MULTI_AP_FLAG == "yes" then

	cell_index=1

	for ue_group_id = (TOTAL_UE_GROUP_FOR_AP1+1), (TOTAL_UE_GROUP_FOR_AP1+TOTAL_UE_GROUP_FOR_AP2) do
		if NR_CELLS_IN_AP2 > cell_index then
			cell_index=1
		end
		if uecid > UEC_COUNT then
			uecid = 1
		end
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP2[cell_index].." uec="..uecid.." enb=2 cell="..NR_CELL_ID_TABLE_AP2[cell_index].." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
		cell_index = cell_index + 1
		uecid = uecid + 1
	end
end


------------------------------------------
SA_UE_COUNT=1
ue_group_id=1
cell_index=1
if Test_UEs == 'SA' or Test_UEs == 'Both' then
	
	for SA_UEID = 1, TOTAL_SA_UES_PER_AP1 do
	
		if SA_UE_COUNT > SA_UES_PER_GROUP then
			ue_group_id=ue_group_id+1
            cell_index=cell_index+1
			SA_UE_COUNT=1
		end
		exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP1[cell_index]..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
		
		SA_UE_COUNT=SA_UE_COUNT+1
	end
end
cell_index=1
if MULTI_AP_FLAG == "yes" then

	SA_UE_COUNT =1
	ue_group_id = TOTAL_UE_GROUP_FOR_AP1+1

	if Test_UEs == 'SA' or Test_UEs == 'Both' then
		
		for SA_UEID = (TOTAL_SA_UES_PER_AP1+1), (TOTAL_SA_UES_PER_AP1+TOTAL_SA_UES_PER_AP2) do
		
			if SA_UE_COUNT > SA_UES_PER_GROUP then
				ue_group_id=ue_group_id+1
                cell_index=cell_index+1
				SA_UE_COUNT=1
			end
			exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..NR_CELL_ID_TABLE_AP2[cell_index]..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
			exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
			
			SA_UE_COUNT=SA_UE_COUNT+1
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
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1,2,3 amf_region_id=1-5 plmn_list='..PLMN..'  ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")


---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--[[exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')
exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate') --]]

---------------------------------------------------------------------------------------------------
--SEQUENCE  CONFIGURATION
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE 3T[MUMIMO]_3F-DSS TPUT case 
--------------------------------------------------------------------------------------------------

if PET_SE_FLAG == 'yes' then

    exec('seq_set id=1  name=TDD_PCELL_CA_UE_WITH_TPUT ue_group=1')
    exec('ue_register ue_nr_capabilities=DL_CA_6CC capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')		
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=95000 size=1350') --([[[2940+1542+1542+(3*282.7)]/72]*40]/40)=95Mbps/UE=3817.83Mbps/40UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration)
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
	

    exec('seq_set id=2 name=TDD_PCELL_CA_SCELL_ADDED_UE ue_group=1')
    exec('ue_register ue_nr_capabilities=DL_CA_6CC capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=40000 size=1350')-- [[[2940/72]*32]/32]=40.8Mbps/UE=1306.6Mbps/32UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 24 Hour
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')
	

    exec('seq_set id=3 name=TDD_SCELL_nonCA_UE_CELL_2 ue_group=2')
    exec('ue_register ue_nr_capabilities=NONCA_TDD_n41 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=40000 size=1350')-- [[[1542/72]*32]/32]=21.46Mbps/UE=685.3Mbps/32UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 24 Hour
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	

    exec('seq_set id=4 name=TDD_SCELL_nonCA_UE_CELL_3 ue_group=3')
	exec('ue_register ue_nr_capabilities=NONCA_TDD_n77 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=40000 size=1350')-- [[[1542/72]*32]/32]=21.46Mbps/UE=685.3Mbps/32UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 24 Hour
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	

    exec('seq_set id=5 name=FDD_SCELL_nonCA_UE_CELL_4 ue_group=4')
    exec('ue_register ue_nr_capabilities=N71_NONCA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=15000 size=1350')-- [[[282.7/72]*32]/32]=3.92Mbps/UE=125.6Mbps/32UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 24 Hour
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
 
 
    exec('seq_set id=6 name=FDD_SCELL_nonCA_UE_CELL_5 ue_group=5')
    exec('ue_register ue_nr_capabilities=N66_NONCA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=15000 size=1350')-- [[[282.7/72]*32]/32]=3.92Mbps/UE=125.6Mbps/32UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 24 Hour
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')


    exec('seq_set id=7 name=FDD_SCELL_nonCA_UE_CELL_6 ue_group=6')
    exec('ue_register ue_nr_capabilities=N66_NONCA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=15000 size=1350')-- [[[282.7/72]*32]/32]=3.92Mbps/UE=125.6Mbps/32UE
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')    
    exec('sleep '..duration) --For 24 Hour
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

end


------------------------------------TC2-ULCAWITH-3TX----------------------------
if PET_SE_FLAG == 'yes' then

	exec('seq_set id=8 name=40CAUE_ON_TDD_PCELL-cellid-2 ue_group=2')
    exec('ue_register ue_nr_capabilities=THREE_TX capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=6930 size=1350') --For 10.014Mbps 
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 1.5 Hrs
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	
	
	exec('seq_set id=9 name=32CAUE_ON_TDD_PCELL-cellid-2 ue_group=2')
    exec('ue_register ue_nr_capabilities=THREE_TX capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=5833 size=1350') --For 5.931Mbps
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 1.5 Hrs
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')
	
	exec('seq_set id=10 name=32Non_CAUE_ON_FDD_SCELL-cellid-4 ue_group=4')
    exec('ue_register ue_nr_capabilities=N71 capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=1097 size=1350') --For 3.083Mbps
    exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
    exec('sleep '..duration) --For 1.5 Hrs
	exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled') --Proxy proto flag enabled
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled') 
exec('sim_param_set TTI=3  ENABLE_MULTIPLE_L2NRT=on')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set purge_buffer_on_full=on')
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
	sleep(2)
	exec('enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200')
    sleep(0.1)
	exec('enb_cell_param enb=1 id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=4')
	exec('enb_cell_param enb=1 id=2 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=4')
	exec('enb_cell_param enb=1 id=3 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=4')

    sleep(0.1)
	exec('enb_cell_dss_feature enb=1 id=1 nr_dl_peak_rate_increase=on superfast_allocation=on')
	exec('enb_cell_dss_feature enb=1 id=2 nr_dl_peak_rate_increase=on superfast_allocation=on')
	exec('enb_cell_dss_feature enb=1 id=3 nr_dl_peak_rate_increase=on superfast_allocation=on')

    sleep(0.1)
	exec('enb_dss_cell_param enb=1 id=1 dl_resource_sharing_algo=dl_prb_load_based')
	exec('enb_dss_cell_param enb=1 id=2 dl_resource_sharing_algo=dl_prb_load_based')
	exec('enb_dss_cell_param enb=1 id=3 dl_resource_sharing_algo=dl_prb_load_based')

    sleep(0.1)
	exec('enb_dss_configure_partnership enb=1 cell=1 dss_peer=2:4')
	exec('enb_dss_configure_partnership enb=1 cell=2 dss_peer=2:5')
	exec('enb_dss_configure_partnership enb=1 cell=3 dss_peer=2:6')

    sleep(3)
	exec('enb_crm_cell_resource_reservation enb=1 cell=1  tgt_enb=2 tgt_cell=4  assigned_dl_minimum_share_to_nr=30 assigned_dl_maximum_share_to_nr=95 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70')
	exec('enb_crm_cell_resource_reservation enb=1 cell=2  tgt_enb=2 tgt_cell=5  assigned_dl_minimum_share_to_nr=30 assigned_dl_maximum_share_to_nr=95 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70')
	exec('enb_crm_cell_resource_reservation enb=1 cell=3  tgt_enb=2 tgt_cell=6  assigned_dl_minimum_share_to_nr=30 assigned_dl_maximum_share_to_nr=95 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70')
	
	sleep(3)
	exec('enb_dss_establish_partnership enb=1 cell=1  tgt_enb=2 tgt_cell=4')
	exec('enb_dss_establish_partnership enb=1 cell=2  tgt_enb=2 tgt_cell=5')
	exec('enb_dss_establish_partnership enb=1 cell=3  tgt_enb=2 tgt_cell=6')
	
    sleep(3)
	exec('enb_dss_cell_resource_reservation_dl enb=1 cell=1  reset')
	exec('enb_dss_cell_resource_reservation_dl enb=1 cell=2  reset')
	exec('enb_dss_cell_resource_reservation_dl enb=1 cell=3  reset')

    sleep(3)
	exec('enb_dss_cell_resource_reservation_ul enb=1 cell=1  reset')
	exec('enb_dss_cell_resource_reservation_ul enb=1 cell=2  reset')
	exec('enb_dss_cell_resource_reservation_ul enb=1 cell=3  reset')

	sleep(3)
	exec('enb_dss_dl_resource_cell_reservation cell=1  enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=95 reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000')
	exec('enb_dss_dl_resource_cell_reservation cell=2  enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=95 reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000')
	exec('enb_dss_dl_resource_cell_reservation cell=3  enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=95 reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000')
	
	sleep(3)
	exec('enb_dss_cell_resource_coordination enb=1 cell=1  tgt_enb=2 tgt_cell=4 dir=DL')
	exec('enb_dss_cell_resource_coordination enb=1 cell=2  tgt_enb=2 tgt_cell=5 dir=DL')
	exec('enb_dss_cell_resource_coordination enb=1 cell=3  tgt_enb=2 tgt_cell=6 dir=DL')
	
	
	sleep(3)
	exec('enb_dss_ul_resource_cell_reservation cell=1  enb=1 minimum_prb_share=30 maximum_prb_share=70')
	exec('enb_dss_ul_resource_cell_reservation cell=2  enb=1 minimum_prb_share=30 maximum_prb_share=70')
	exec('enb_dss_ul_resource_cell_reservation cell=3  enb=1 minimum_prb_share=30 maximum_prb_share=70')

	
	sleep(3)
	exec('enb_dss_cell_resource_coordination enb=1 cell=1  tgt_enb=2 tgt_cell=4  dir=UL')
	exec('enb_dss_cell_resource_coordination enb=1 cell=2  tgt_enb=2 tgt_cell=5  dir=UL')
	exec('enb_dss_cell_resource_coordination enb=1 cell=3  tgt_enb=2 tgt_cell=6  dir=UL')
	
    
	sleep(3)
	exec('enb_dss_resource_allocation enb=1 cell=1  tgt_enb=2 tgt_cell=4  dir=DL allocation_start_time=immediate dl_allocated_normal_subframes=1010111011-1110110111-1010111011-1110110111-1010111011-1110110111-1010111011-1110110111 dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106')
	exec('enb_dss_resource_allocation enb=1 cell=2  tgt_enb=2 tgt_cell=5  dir=DL allocation_start_time=immediate dl_allocated_normal_subframes=1010111011-1110110111-1010111011-1110110111-1010111011-1110110111-1010111011-1110110111 dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106')
	exec('enb_dss_resource_allocation enb=1 cell=3  tgt_enb=2 tgt_cell=6  dir=DL allocation_start_time=immediate dl_allocated_normal_subframes=1011110011-1110110111-1011110011-1110110111-1011110011-1110110111-1011110011-1110110111 dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106')
	
	sleep(3)
	exec('enb_dss_resource_allocation enb=1 cell=1  tgt_enb=2 tgt_cell=4  dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3')
	exec('enb_dss_resource_allocation enb=1 cell=2  tgt_enb=2 tgt_cell=5  dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3')
	exec('enb_dss_resource_allocation enb=1 cell=3  tgt_enb=2 tgt_cell=6  dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3')
	exec('filter_sim_rfm enable=all')
    print('parallel_dss_setup script completed')
    exec("sim_log_set flush")
end

