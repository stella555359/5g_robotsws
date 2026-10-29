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
os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'FDD'	--Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA+NSA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet

Multi_AP_FLAG = 'no' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 1 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 1 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 1   --Total number of Cells
AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 6   --Total number of UEC
SA_UE_COUNT_PER_CELL = 1500 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 0 --NSA UE Count per cell

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 18001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 1     --Number of PET_SE UE_Groups per cell
--UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
UE_GROUP_COUNT = 18
SEQ_GROUP_COUNT = 6 --TOTAL_NUMBER_OF_CELLS	--Total Number of Sequence_set groups

END_CELL_ID = FIRST_CELL_ID + TOTAL_NUMBER_OF_CELLS - 1 --End cell id =  FIRST_CELL_ID + NUMBER_OF_CELLS - 1, Ex: = 7+6-1
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
--GSCN = 7880	--GSCN value
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
							}	--Cells belong to Airphone-1

CELL_ID_TABLE_FOR_AP2	= { 7,
							8,
							9,
							10,
							11,
							12,
							}	--Cells belong to Airphone-2

CELL_TECH_TABLE_OF_AP1	= { "'FDD'",
							"'TDD'",
							"'FDD'",
							"'TDD'",
							"'FDD'",
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
                    "10.0.1.65"
                    }  --IP table for each AMF

UPF_IP_TABLE 	= { "1.2.0.1",
                    "1.2.8.1",
                    "1.2.16.1",
					"1.2.24.1",
					"1.2.32.1",
                    "1.2.40.1"
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
					
					}  -- 6 phycical cell ids configured in table.

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

GSCN_TABLE    =   {   "4875",
                      "6570",
					  "5400",
					  "7742",
					  "5460",
					  "6339",
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
    	exec('set_cell id='..cell_id..' gnb=2 pci='..PCI_TABLE[array_id]..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..tdd_flag..' proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NR_ARFCN_TABLE[array_id]..' mandatory_for_activation=off')
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

---UE group for 1500 UE for Cell 1

UE_GROUP_FOR_1500_UES=UE_GROUP_COUNT+1

exec("set_ue_group id="..UE_GROUP_FOR_1500_UES.." name=UE_GROUP_FOR_1500 uec=1 enb=2 cell=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")



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
			--exec('ue_param id='..SA_UEID..' ue_nr_capabilities=CA_4CC capability_file=./capability.cfg')
        end
		SA_UECID = SA_UECID + 1
		SA_CELLID = SA_CELLID + 1
        ue_group_id = ue_group_id + 1
	end
end


--- SA UE allocation for 1500 UE group---

-------------------------------------------------------------------
--SA UEs allocation on UE wise: UE1 on cell1, UE2 on cell2,..
-------------------------------------------------------------------

if Test_UEs == 'SA' or Test_UEs == 'Both' then
	for SA_UEID = (LAST_SA_UE_ID+1), (LAST_SA_UE_ID+1500) do
	
        if PET_SE_FLAG == 'yes' then
	        exec('set_ue id='..SA_UEID..' group='..UE_GROUP_FOR_1500_UES..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
        end
	end
end
-------------------------------------------------------------------
--SA UEs allocation on CELL wise: UE1 on cell1, UE2 on cell1,..
-------------------------------------------------------------------
--[[
UE_PER_CELL = UE_COUNT_ON_CELL
UEID = FIRST_UE_SA_CELL

if Test_UEs == 'SA' or Test_UEs == 'Both' then
    for SA_CELLID = FIRST_CELL_ID, END_CELL_ID do
        for SA_UEID = UEID, UE_PER_CELL do
            if PET_SE_FLAG == 'yes' then
    	        exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
    		    exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
            else
        		exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
            end
        end
		if ue_group_id >= UE_GROUP_COUNT then
			 ue_group_id = 1	 
		end
		if SA_UECID > UEC_COUNT then
			SA_UECID = 1
        end

        UEID = UE_PER_CELL + 1
        UE_PER_CELL = UE_COUNT_ON_CELL + UE_PER_CELL
		SA_UECID = SA_UECID + 1
		ue_group_id = ue_group_id + 1
    end
end
--]]
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
--DRB configuartion
---------------------------------------------------------------------------------------------------
--2DRB for RRC SA UEs
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=7')
exec('nwslice_set id=1 qos_flows=1,2 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)
for amf_id = FIRST_AMF_ID, END_AMF_ID do
	exec('smf_param id='..amf_id..' additional_qosflows_to_activate=2')
end

--------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR SA UES
---------------------------------------------------------------------------------------------------
--1500 UEs for Cell1--

exec('seq_set id=1000 name=1500_RRC_UE_for_CELL-1 ue_group=19') 	
exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
exec('ue_pdu_session_setup pdu=1 nwslice=1')
exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=67 size=1350') 
exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=135 size=1350')  
exec('sleep 6300') --hardcoded the value to avoid timer expiry
exec('ue_deregister by=ue ue_deregister_type=switch_off')
exec('seq_end')



gr_id = 1

---500 RRC connected ue per cell ---

if PET_SE_FLAG == 'yes' then
	for seq_gr_id = 1,18 do
		if gr_id > UE_GROUP_COUNT then
			gr_id = 1
		end
		exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'') 	
		exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul bps=72 size=42') --72 bps
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl bps=72 size=42') --72 bps
		exec('sleep '..timer)
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		gr_id = gr_id + 1
	end
end

--- 72UE UL+DL TPUT ---
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 19,36 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'')
        exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=7013 size=1350') --7013 kbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=14097 size=1350') --14097 kbps
        exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---72UE UL TPUT ---
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 37,54 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'')
        exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=2805 size=1350') --2916 kbps
        exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

---72UE DL TPUT ----
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 55,72 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'')
        exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=5638 size=1350') --5638 kbps
        exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

----POOL level DL TPUT [9cells-9UEs-2403DL]----
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 73,90 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'')
        exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=160000 size=1350') --160 Mbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=107000 size=1350') --107 Mbps
        exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

----POOL level UL TPUT [9cells-9UEs-1127UL]----
if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 91,108 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'')
        exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=125222 size=1350') --125 Mbps
        exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end

----POOL level DL+UL TPUT [9cells-9UEs-1127UL]----
if PET_SE_FLAG == 'yes' then
    for seq_gr_id =109,126 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=max_RRC_connection'..seq_gr_id..' ue_group='..gr_id..'')
        exec('ue_register ue_nr_capabilities=ORAN_BW40_20 capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=160000 size=1350') --160 Mbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=107000 size=1350') --107 Mbps
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=125222 size=1350') --125 Mbps
        exec('ue_pdu_session_modify pdu=1 qosflows_to_del=2')
        exec('sleep '..timer)
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
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled TTI=3') --Proxy proto flag enabled
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_param_set ENABLE_CORE_LIMIT=on')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')
end
