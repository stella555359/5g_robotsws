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
for ip1 = 61, 64 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3'..GNB_VLAN..'')
end

for ip2 = 3, 28 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 131, 174 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3'..GNB_VLAN..'')
end

for ip4 = 200, 214 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3'..GNB_VLAN..'')
end

--os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA
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
Test_Tech = 'TDD'	--Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA+NSA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'Both'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration:

Multi_AP_FLAG = 'no' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 1 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 12 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 12   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
SA_UE_COUNT_PER_CELL = 0 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 750 --NSA UE Count per cell

FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 9001   --Starting NSA UEid
sim_enbs = 6   --Sim-eNBs for NSAtest
UE_GROUP_COUNT_PER_CELL = 1   --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = TOTAL_NUMBER_OF_CELLS * 9	--Total Number of Sequence_set groups

END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 9 --Total number of SGW/PGW in core network
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

CELL_ID_TABLE_FOR_AP2	= { 4,
							5,
							6,
							}	--Cells belong to Airphone-2
CELL_TECH_TABLE_OF_AP1	= { "TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							}	--Cells Tech of Airphone-1

CELL_TECH_TABLE_OF_AP2	= { "TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
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
					}  --Physical cell ids configured in table for Multi-AP

ENB_PCI_TABLE       = { "3:2 ",
                    "4:0",
					"4:1",
					"4:2",
					"5:0",
					"5:1",
					}  
NR_ARFCN_TABLE 	= { "636666:636666",
                    "636666:636666",
                    "636666:636666",
					"636666:636666",
					"636666:636666",
					"636666:636666",
					"640000:640000",
					"640000:640000",
					"640000:640000",
					"640000:640000",
					"640000:640000",
					"640000:640000",
                    }  --NRARFCN UL:DL for each cell for Multi-AP

SGW_S1U_IP_TABLE 	= { "10.0.1.132",
                        "10.0.1.134",
                        "10.0.1.140",
                        "10.0.1.142",
                        "10.0.1.144",
                        "10.0.1.146",
                        "10.0.1.148",
                        "10.0.1.150",
                        "10.0.1.152",
                        "10.0.1.154",
                        "10.0.1.156",
                        "10.0.1.158",
                        }  --IP table for each SGW S1U
SGW_S11_IP_TABLE 	= { "10.0.1.133",
                        "10.0.1.135",
                        "10.0.1.141",
                        "10.0.1.143",
                        "10.0.1.145",
                        "10.0.1.147",
                        "10.0.1.149",
                        "10.0.1.151",
                        "10.0.1.153",
                        "10.0.1.155",
                        "10.0.1.157",
                        "10.0.1.159",
                        }  --IP table for each SGW S11

PGW_IP_TABLE    =   {   "4.7.0.254",
			"4.7.1.254",
			"4.7.2.254",
			"4.7.3.254",
			"4.7.4.254",
			"4.7.5.254",
			"4.7.6.254",
			"4.7.7.254",
			"4.7.8.254",
			"4.7.9.254",
			"4.7.10.254",
			"4.7.11.254",
                   --     "4.7.128.254",
                      }  --IP table for each PGW

MME_IP_TABLE    =   {   "10.0.1.131",
                        "10.0.1.139",
                      }  --IP table for each MME

PLMN_TABLE    =   {   "311:489",
                      "311:488",
                    }  --PLMN table for Multi-AP

GSCN_TABLE    =   {   "7880",
					  "7880",
					  "7880",
					  "7880",
					  "7880",
					  "7880",
					  "7940",
					  "7940",
					  "7940",
					  "7940",
					  "7940",
					  "7940",
                    }  --GSCN Table with absolute value for Multi-AP


SERVERS_IP 	= { "10.0.2.1",
                        "10.0.2.3",
                        "10.0.2.4",
                        "10.0.2.5",
                        "10.0.2.6",
                        "10.0.2.7",
                        "10.0.2.8",
                        "10.0.2.9",
                        "10.0.2.10",
                        "10.0.2.11",
                        "10.0.2.12",
                        "10.0.2.13",
                        }  --IP table for server IP
                        

ENB_X2U_ADDR  ={ "10.0.1.136",
			"10.0.1.160",
			"10.0.1.163",
			"10.0.1.166",
			"10.0.1.169",
			"10.0.1.172",
		
			}


ENB_X2_ADDR={   "10.0.1.137",
		"10.0.1.161",
		"10.0.1.164",
		"10.0.1.167",
		"10.0.1.170",
		"10.0.1.173",
		}
		

ENB_S1_ADDR= { "10.0.1.138",
		"10.0.1.162",
		"10.0.1.165",
		"10.0.1.168",
		"10.0.1.171",
		"10.0.1.174",
		}
----------------------------------------------------------------------------------------------------
--COMMON VARIABLES for ALL WTS
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP

DAEMON_PORT=22222
EDAEMON_PORT="22222"
--PROXY_SERVER_IP="10.0.2.80"
--PROXY_SERVER_IP2="10.0.2.90"

GNB_S1U_ADDR="10.0.1.2"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"

--UEC1_ADDR="72.21.0.1"
--UEC2_ADDR="72.23.0.1"
--UEC3_ADDR="72.24.0.1"
--UEC4_ADDR="72.25.0.1"
--UEC5_ADDR="72.26.0.1"
--UEC6_ADDR="72.27.0.1"

----------------------------------------------------------------------------------------------------
-- VARIABLES for MULTI-AIRPHONE support
----------------------------------------------------------------------------------------------------

MME1_S1_ADDR="10.0.1.131"

function run_configuration(timer,timer1)

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------

if cellDepType == 'NSA' or cellDepType == 'SA+NSA' then
local i = 6
local cell_udp_port = 12219
	for simenb_id = 1, sim_enbs  do
	local sim_eci_i = simenb_id + 2
        local sim_eci_o = string.format("%x", sim_eci_i)
     
    exec('set_enb id='..sim_eci_i..' plmn='..PLMN..' s1='..ENB_S1_ADDR[simenb_id]..' enb_id_macro=0x0000'..simenb_id..' daemon='..SERVERS_IP[simenb_id]..':'..DAEMON_PORT..' x2='..ENB_X2_ADDR[simenb_id]..' x2u='..ENB_X2U_ADDR[simenb_id]..' type=simulated x2_peers=none x2u_snd_buff_size=41943040 x2u_rcv_buff_size=41943040')
    exec('enb_param id='..sim_eci_i..' drb_id_begin=3 endc_capable_qci=9,7')
    if Test_Tech == 'FDD' then
        tdd_flag = 'off'
    else
        tdd_flag = 'on'
    end
    exec('set_cell id=1 enb='..sim_eci_i..' eci=0x0000'..simenb_id..'01 pci='..ENB_PCI_TABLE[simenb_id]..' tac=222 proxy='..SERVERS_IP[simenb_id]..':'..cell_udp_port..'|'..SERVERS_IP[simenb_id]..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell='..tdd_flag..' mandatory_for_activation=off')
    exec('enb_endc_param id='..sim_eci_i..' control_flow_period=3gpp1 use_nr_ran_cont=on allowed_bc_list_mrdc=1:1|3:1')
    i = i +1 
    cell_udp_port = cell_udp_port + 1
    end
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
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' name=SIMmode-'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
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
    exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500 srb_reordering_enabled=on disable_sib1_flood=true disable_sib_during_ho=true')
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

if PET_SE_FLAG == 'yes' and Test_UEs == 'SA' or 'both' then 
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
--UE GROUPS FOR PET_SE for NSA
---------------------------------------------------------------------------------------------------
nsa_ue_group_id = UE_GROUP_COUNT +1

if PET_SE_FLAG == 'yes' and Test_UEs == 'NSA' or 'both' then
uecid =1
enbid=3
pdn=1
	
	for ue_group_id = nsa_ue_group_id , (nsa_ue_group_id + UE_GROUP_COUNT -1) do
	
		if uecid > UEC_COUNT then
			uecid = 1
		end
		if pdn > CORENETWORK_COUNT then
			pdn = 1
		end

--		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.." uec="..uecid.." enbid="..enbid.." pdn="..pdn.." release=15 idle_edrx_cycle_len=2 ptw=2.56 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g")
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-"..ue_group_id.." uec="..uecid.." pdn="..pdn.." release=15 idle_edrx_cycle_len=2 ptw=2.56 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g")

		uecid = uecid + 1
		pdn= pdn + 1
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

if Test_UEs == 'SA' or 'Both' then
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
	        exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' additional_qosflows_to_activate=2 suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
        else
    		exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    		exec('ue_param id='..SA_UEID..' ue_nr_capabilities=SRS_CA_3CC capability_file=./capability.cfg')
        end
		SA_UECID = SA_UECID + 1
		SA_CELLID = SA_CELLID + 1
        ue_group_id = ue_group_id + 1
	end
end

-------------------------------------------------------------------
--NSA UEs allocation on UE wise: UE1 on cell1, UE2 on cell2,..
-------------------------------------------------------------------

ue_group_id =nsa_ue_group_id
if Test_UEs == 'NSA' or 'Both' then
pdn = 1
enbid=3
	for NSA_UEID = FIRST_NSA_UE_ID, LAST_NSA_UE_ID do
		if     ue_group_id > (nsa_ue_group_id + UE_GROUP_COUNT -1) then
			ue_group_id = nsa_ue_group_id
		end
		if enbid > (sim_enbs + 2 ) then
			enbid = 3
		end
		exec('set_ue id='..NSA_UEID..' group='..ue_group_id.. ' enb='..enbid..'  sec_key=0102030405060708090A0B0C0D0EFF00  imsi=311:489:'.. NSA_IMSI + NSA_UEID - 1)
		exec('ue_param id='..NSA_UEID..' dual_conn=eutra_nr ')	
		ue_group_id = ue_group_id + 1	
		enbid = enbid + 1
	end
	for ue_group_id = nsa_ue_group_id , (nsa_ue_group_id + UE_GROUP_COUNT -1) do
	 	if pdn > CORENETWORK_COUNT then
			pdn = 1
		end
		
		exec('set_bearer id=2 ue_group='..ue_group_id..' qci=9 pdn='..pdn..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
		exec('set_bearer id=3 ue_group=' .. ue_group_id .. ' qci=7 pdn=' .. pdn)
		pdn = pdn +1
		

	end
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
--NonGBR,GBR,VONR for RRC SA UEs
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720')
exec('set_qosflow id=3 5qi=5')
exec('set_qosflow id=4 5qi=1')
exec('set_qosflow id=5 5qi=7')
exec('set_nwslice id=1 default=ON snssai=0x01:0xD143A5 qos_flows=1,5 amf_region_id=1-5 plmn_list='..PLMN.. ' ue=all')
exec('set_nwslice id=2 default=OFF snssai=0x80:0xD143AE qos_flows=3,4 amf_region_id=1-5 plmn_list='..PLMN.. ' ue=all')
exec('set_nwslice id=3 default=OFF snssai=0x81:0xD143AF qos_flows=1,2,3,4 amf_region_id=1-5 plmn_list='..PLMN.. ' ue=all')
exec('set_nwslice id=4 default=OFF snssai=0x82:0xD143B0 qos_flows=1,2 amf_region_id=1-5 plmn_list='..PLMN.. ' ue=all')
exec('set_nwslice id=5 default=OFF snssai=0x83:0xD143B1 qos_flows=1,3,4 amf_region_id=1-5 plmn_list='..PLMN.. ' ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2,3,4,5")
exec("smf_param id=2 additional_qosflows_to_activate=2,3,4,5")
exec("smf_param id=3 additional_qosflows_to_activate=2,3,4,5")
exec("smf_param id=4 additional_qosflows_to_activate=2,3,4,5")
exec("smf_param id=5 additional_qosflows_to_activate=2,3,4,5")

--------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------


if PET_SE_FLAG == 'yes' then

--TC3:TDD_NSA_16DL8UL_MUMIMO_3Cells_BF_1208FF_DLpeak_tp_6192Mbps_72UEs_percell_1cell_ABIO--
gr_id = nsa_ue_group_id
	for seq_gr_id = 1,3 do
		if gr_id > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id = nsa_ue_group_id
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id)
        	exec('ue_attach ue_nr_capabilities=MU_MIMO ue_eutra_nr_capabilities=EUTRA_MUMIMO capability_file=./capability.cfg ')
		exec('seq_delay 1.0')
        	exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
                exec('seq_delay 1.0')
		exec('trf_data_start id=2 dir=dl trf_id=1 mbps=86 size=1350')
		exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id = gr_id + 1
	end
--TC4:TDD_NSA_16DL8UL_MUMIMO_3Cells_BF_8406FF_UL_peak_tp_860Mbps_72UEs_percell_1cell_ABIO--
gr_id1 = nsa_ue_group_id
	for seq_gr_id = 4,6 do
		if gr_id1 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id1 = nsa_ue_group_id
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id1)
        	exec('ue_attach ue_nr_capabilities=MU_MIMO ue_eutra_nr_capabilities=EUTRA_MUMIMO capability_file=./capability.cfg ')
		exec('seq_delay 1.0')
        	exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
                exec('seq_delay 1.0')
		exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11945 size=1350')
		exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=ul trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id1 = gr_id1 + 1
	end
	
--TC5:TDD_NSA_16DL8UL_6Cells_BF_1116_0ms_Total_DLpeak_tp_10464Mbps_perBBUcard_2UEs_percell_ABIP--
gr_id2 = nsa_ue_group_id
i=1
	for seq_gr_id = 7,12 do
		if gr_id2 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id2 = nsa_ue_group_id
		end
		if i > 6 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id2)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.5')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2 type=split_scg')  --sgnb add
                exec('seq_delay 1.0')
		exec('trf_data_start id=2 dir=dl trf_id=1 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=2 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=3 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=4 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=5 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=6 mbps=72 size=1350')
		exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id2 = gr_id2 + 1
		i = i + 1
	end
--TC5:TDD_NSA_16DL8UL_6Cells_BF_1116_0ms_Total_ULpeak_tp_10464Mbps_perBBUcard_2UEs_percell_ABIP--
gr_id3 = nsa_ue_group_id
i=1
	for seq_gr_id = 13,18 do
		if gr_id3 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id3 = nsa_ue_group_id
		end
		if i > 6 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id3)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.5')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2 type=split_scg')  --sgnb add
                exec('seq_delay 1.0')
		exec('trf_data_start id=2 dir=dl trf_id=1 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=2 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=3 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=4 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=5 mbps=160 size=1350')
		exec('trf_data_start id=2 dir=dl trf_id=6 mbps=72 size=1350')
		exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id3 = gr_id3 + 1
		i = i + 1
	end
--TC1:TDD_NSA_4DL4UL_6Cells_BF_1208FF_DLpeak_tp_1539Mbps_72UEs_percell_2cell_ABIO--
gr_id4 = nsa_ue_group_id
i=1
	for seq_gr_id = 19,24 do
		if gr_id4 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id4 = nsa_ue_group_id
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id4)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.5')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2 type=split_scg')  --sgnb add
                exec('seq_delay 1.0')
		exec('trf_data_start id=2 dir=dl trf_id=1 kbps=21388 size=1350')
		exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id4 = gr_id4 + 1
		i=i+1
	end
--TC2:TDD_NSA_4DL4UL_6Cells_BF_1208FF_ULpeak_tp_234Mbps_72UEs_2cell_ABIO--
gr_id5 = nsa_ue_group_id
i=1
	for seq_gr_id = 25,30 do
		if gr_id5 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id5 = nsa_ue_group_id
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id5)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.5')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2 type=split_scg')  --sgnb add
                exec('seq_delay 1.0')
		exec('trf_data_start id=2 dir=ul trf_id=1 kbps=3250 size=1350')
		exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id5 = gr_id5 + 1
		i=i+1
	end


--TC7:TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_4UE_percell_total_DL_peak_tp_3244.3Mbps_ABIP--
print(nsa_ue_group_id)
gr_id6 = nsa_ue_group_id
i=1
 for seq_gr_id = 31,42 do
		if gr_id6 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id6 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id6)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.5')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 1.0')
        	exec('trf_data_start id=2 dir=dl trf_id=1 kbps=67590 size=1350')
       -- 	exec('trf_data_start id=3 dir=dl trf_id=1 kbps=33875  size=1350')
               	exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
	--	exec('trf_data_stop id=3 dir=dl trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id6 = gr_id6 + 1
		i=i+1
	end
--TC8:TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_4UE_percell_total_UL_peak_tp_1450.3Mbps_ABIP--
print(nsa_ue_group_id)
gr_id7 = nsa_ue_group_id
i=1
 for seq_gr_id = 43,54 do
		if gr_id7 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id7 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id7)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.5')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 1.0')
        	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=30215 size=1350')
  --      	exec('trf_data_start id=3 dir=ul trf_id=1 kbps=15105  size=1350')
               	exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=ul trf_id=1')
--		exec('trf_data_stop id=3 dir=ul trf_id=1')
		exec('seq_delay 0.5')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 1.0')
		exec('ue_detach ')
		exec('seq_end')
		gr_id7 = gr_id7 + 1
		i=i+1
	end
--TC9:TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244.3Mbps_ABIP--60UEs/cell will have -high thrp
print(nsa_ue_group_id)
gr_id8 = nsa_ue_group_id
i=1
 for seq_gr_id = 55,66 do
		if gr_id8 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id8 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id8)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.1')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
		exec('seq_delay 0.1')
	--	exec('trf_data_start id=2 dir=dl trf_id=1 kbps=450 size=1350')
	--	exec('seq_delay 0.1')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 0.1')
        	exec('trf_data_start id=2 dir=dl trf_id=1 kbps=4506 size=1350')
               	exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.1')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 0.1')
		exec('ue_detach ')
		exec('seq_end')
		gr_id8 = gr_id8 + 1
		i=i+1
	end
--TC9:TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244.3Mbps_ABIP--315Ue/cell will have pingdata
print(nsa_ue_group_id)
gr_id9 = nsa_ue_group_id
i=1
 for seq_gr_id = 67,78 do
		if gr_id9 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id9 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id9)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.1')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
		exec('seq_delay 0.1')  	
        --	exec('trf_data_start id=2 packets=1 dir=dl trf_id=1 size=42')
        --	exec('seq_delay 0.1')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 0.1')
        	exec("seq_loop_start loop="..timer1..'')
        	exec('seq_delay 4.5')
 		exec('trf_data_start id=2 packets=1 dir=dl trf_id=1 size=42')
        	exec('trf_data_start id=2 packets=1 dir=ul trf_id=1 size=42')
               	exec('seq_delay 5')
    		exec('trf_data_stop')
    		--exec('seq_delay 4.5')
    		exec("seq_loop_end")
		exec('seq_delay 0.1')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 0.1')
		exec('ue_detach ')
		exec('seq_end')
		gr_id9 = gr_id9 + 1
		i=i+1
	end
--TC19:TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_4UE_percell_total_DL_peak_tp_3244.3Mbps_in1cell_ABIP--
print(nsa_ue_group_id)
gr_id10 = nsa_ue_group_id
i=1
 for seq_gr_id = 79,90 do
		if gr_id10 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id10 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id10)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.1')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
        	exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 0.1')
        	exec('trf_data_start id=2 dir=dl trf_id=1 mbps=175 size=1350')
        	exec('trf_data_start id=2 dir=dl trf_id=2 mbps=175 size=1350')
        	exec('trf_data_start id=2 dir=dl trf_id=3 mbps=175 size=1350')
        	exec('trf_data_start id=2 dir=dl trf_id=4 mbps=175 size=1350')
        	exec('trf_data_start id=2 dir=dl trf_id=5 mbps=111 size=1350')
               	exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=dl trf_id=1')
		exec('seq_delay 0.1')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 0.1')
		exec('ue_detach ')
		exec('seq_end')
		gr_id10 = gr_id10 + 1
		i=i+1
	end
--TC10:TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_375UE_percell_total_UL_peak_tp_1450.3Mbps_ABIP--60UE/cell will have more thrp 
print(nsa_ue_group_id)
gr_id11 = nsa_ue_group_id
i=1
 for seq_gr_id = 91,102 do
		if gr_id11 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id11 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id11)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.1')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
		exec('seq_delay 0.1')
	--	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=201 size=1350')
	--	exec('seq_delay 0.1')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 0.1')
        	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=2015 size=1350')
               	exec('sleep '..timer)
		exec('trf_data_stop id=2 dir=ul trf_id=2')
		exec('seq_delay 0.1')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		--exec('seq_delay 1.0')
		exec('seq_delay 0.1')
		exec('ue_detach ')
		exec('seq_end')
		gr_id11 = gr_id11 + 1
		i=i+1
	end
--TC10:TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_375UE_percell_total_UL_peak_tp_1450.3Mbps_ABIP--315UE/cell will have ping data
print(nsa_ue_group_id)
gr_id12 = nsa_ue_group_id
i=1
 for seq_gr_id = 103,114 do
		if gr_id12 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id12 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id12)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
		exec('seq_delay 0.1')
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
		exec('seq_delay 0.1')  	
      --  	exec('trf_data_start id=2 packets=1 dir=ul trf_id=1 size=42')
      --  	exec('seq_delay 0.1')
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 0.1')
        	exec("seq_loop_start loop="..timer1..'')
        	exec('seq_delay 4.5') 	
        	exec('trf_data_start id=2 packets=1 dir=dl trf_id=1 size=42')
        	exec('trf_data_start id=2 packets=1 dir=ul trf_id=1 size=42')
               	exec('seq_delay 5')
    		exec('trf_data_stop id=2 trf_id=1')
    --		exec('seq_delay 4.5')
    		exec("seq_loop_end")
		exec('seq_delay 0.1')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 0.1')
		exec('ue_detach ')
		exec('seq_end')
		gr_id12 = gr_id12 + 1
		i=i+1
	end
--TC15:TDD_NSA_4DL4UL_12Cells_9000UEs_750UE_percell_with_pingtraffic_2DRB_perUE
print(nsa_ue_group_id)
gr_id13 = nsa_ue_group_id
i=1
 for seq_gr_id = 115,126 do
		if gr_id13 > (nsa_ue_group_id + UE_GROUP_COUNT - 1) then
			gr_id13 = nsa_ue_group_id
		end
		if i > 12 then
			i = 1
		end
		exec('seq_set id='..seq_gr_id..' name=NSA-'..seq_gr_id..' ue_group='..gr_id13)
        	exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
        	exec('seq_delay 0.1') 
		exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
		exec('seq_delay 1')  	
        	exec('ue_dc_enb_start target_gnb=2 target_cells='..i..' bearer=2,3 type=split_scg')  --sgnb add
        	exec('seq_delay 0.1')  
        	exec("seq_loop_start loop="..timer1..'')  	
        	exec('trf_data_start id=2,3 dir=dl trf_id=1 size=42 packets=1')
        	exec('trf_data_start id=2,3 dir=ul trf_id=1 size=42 packets=1')
              	exec('seq_delay 9.5')
    		exec("seq_loop_end")
		exec('seq_delay 0.1')
        	exec('enb_ue_dc_release bearer=2,3 by=enb cause=off ')     --sgnb del
		exec('seq_delay 0.1')
		exec('ue_detach ')
		exec('seq_end')
		gr_id13 = gr_id13 + 1
		i=i+1
	end
end
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled NR_CLUB_PROXY_PROTO_MSGS=enabled TTI=5') --Proxy proto flags enabled and added TTI param
exec('sim_param_set pet_5g_testing=on')
exec('sim_param_set PET_PROFILE=on')
--exec('sim_param_set pet_nsa_ping_testing=on')
exec('sim_param_set stop_traffic_on_ho=on')
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('sim_param_set ENABLE_CORE_LIMIT=on')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=55 max_log_size=500M')
--exec('set_log log_to_file=true max_file_num=1')
--exec('debug_sim_log level=4 uec=1-6')
--exec('debug_sim_log level=4 amf=1-5')
--exec('sim_trace uec=1-6 protocol=nr_rrc on')
exec('debug_sim_log level=4 pgw=1-9')
exec('debug_sim_log level=4 sgw=1-9')
exec('debug_sim_log level=4 enb=3-8')
--exec('sim_trace enb=1 protocol=nr_rrc on')
--exec('sim_debug_log level=4 app_type=ueproxy')
exec('sim_start version_check=off')
end
