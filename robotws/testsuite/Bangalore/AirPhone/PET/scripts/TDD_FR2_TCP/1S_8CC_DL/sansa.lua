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
for ip1 = 61, 91 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3'..GNB_VLAN..'')
end

for ip2 = 3, 48 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 131, 141 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3'..GNB_VLAN..'')
end

for ip4 = 200, 221 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3'..GNB_VLAN..'')
end

for ip5 = 151, 180 do	--To configure IP 10.0.2.151,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip5..'/24 dev eth4'..AP_VLAN..'')
end

for ip6 = 151, 180 do	--To configure IP 10.0.1.151,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip6..'/24 dev eth3'..GNB_VLAN..'')
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
os.execute('sudo sysctl -w net.ipv4.tcp_rmem="10240 87380 20971520"') --Only for TCP
os.execute('sudo sysctl -w net.ipv4.tcp_wmem="10240 87380 20971520"') --Only for TCP
os.execute('sudo sysctl -w net.ipv4.tcp_limit_output_bytes=62914560') --Only for TCP

os.execute('sudo sysctl -w net.ipv4.tcp_congestion_control=cubic')
os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'TDD'	--Set values as 'FDD' or 'TDD' or 'Both' based on your Test Line
cellDepType = 'SA'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'SA+NSA'
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet

Multi_AP_FLAG = 'no' --To support multiple APs set flag as 'yes', else set as 'no'. Default: 'no' will be considered as single Airphone used
NUMBER_OF_AIRPHONE = 1 --Number of Airphone to use
NUMBER_OF_CELLS_IN_AP1 = 24 --Number of cells in Airphone-1 incase of multiple airphones supported
NUMBER_OF_CELLS_IN_AP2 = 0 --Number of cells in Airphone-2 incase of multiple airphones supported

TOTAL_NUMBER_OF_CELLS = 24   --Total number of Cells
AMF_COUNT = 6   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
MULTI_UPF_SUPPORT = 'yes' --Set value as 'yes' if user wants to enable Multi-UPF per AMF
UPF_COUNT = 12 --Total number of UPF count if UPF count > AMF_COUNT; Mapping all UPF to all AMFs

UEC_COUNT = 12   --Total number of UEC
--SA_UE_COUNT_PER_CELL = 53 --750 --1500 --SA UE Count per cell
NSA_UE_COUNT_PER_CELL = 0 --NSA UE Count per cell

FIRST_AMF_ID = 1   --Starting AMF id
FIRST_SA_UE_ID = 1    --Starting SA UEid
FIRST_NSA_UE_ID = 18001    --Starting NSA UEid

UE_GROUP_COUNT_PER_CELL = 1     --Number of PET_SE UE_Groups per cell
UE_GROUP_COUNT = UE_GROUP_COUNT_PER_CELL * TOTAL_NUMBER_OF_CELLS     --Total Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = TOTAL_NUMBER_OF_CELLS * 5	--Total Number of Sequence_set groups

END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
--LAST_SA_UE_ID = FIRST_SA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * SA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
LAST_NSA_UE_ID = FIRST_NSA_UE_ID + ( TOTAL_NUMBER_OF_CELLS * NSA_UE_COUNT_PER_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

TRF_GEN_SUPPORT_FOR_UE = 'yes' --Traffic support for UEs: Only TCP or Mixed (TCP+UDP) 
TRF_GEN_DIR = 'DL' -- Set TRF_GEN Direction as : 'DL' or 'UL' or 'Both, if 'Both' set & TRF_GEN_COUNT=6 (6DL+6UL:24trf_gens)
TRF_GEN_COUNT = 22 --Total number of Traffic Generator [DL:core+UE & UL:UE+core] EX: TRF_GEN_COUNT=2 with TRF_GEN_DIR = 'Both' {4DL, 4UL} ;Max Count=11 (max limit=47)
MAX_UE_TRF_GEN = 8 --LAST_SA_UE_ID --Max number of UEs support with Traffic Generator, Set flag only TRF_GEN_SUPPORT_FOR_UE='yes'

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
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
							12,
							13,
							14,
							15,
							16,
							17,
							18,
							19,
							20,
							21,
							22,
							23,
							24,
                                  }	--Cells belong to Airphone-1

CELL_ID_TABLE_FOR_AP2   = { 25,
                            26,
							27,
							28,
							29,
							30,
							31,
							31,
                            }   --Cells belong to Airphone-2
							
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
							"TDD",
							}	--Cells Tech of Airphone-1

CELL_TECH_TABLE_OF_AP2	= { "TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							"TDD",
							}	--Cells Tech of Airphone-2

SA_UE_COUNT_FOR_ALL_CELLS   = { 4, --Cell1
                            0,  --Cell2
                            0,  --Cell3
                            0,  --Cell4
                            0,  --Cell5
                            0,  --Cell6
                            0,  --Cell7
                            0,  --Cell8
                            4,  --Cell9
                            0,  --Cell10
                            0,  --Cell11
                            0,  --Cell12
                            0,  --Cell13
                            0,  --Cell14
                            0,  --Cell15
                            0,  --Cell16
                            0,  --Cell17
                            0,  --Cell18
                            0,  --Cell19
                            0,  --Cell20
                            0,  --Cell21
                            0,  --Cell22
                            0,  --Cell23
                            0,  --Cell24
                            } --UEs count per Cell belong to Multi-Airphone

AMF_IP_TABLE 	= { "10.0.1.1", --AMF1
                    "10.0.1.61", --AMF2
                    "10.0.1.62", --AMF3
					"10.0.1.63", --AMF4
					"10.0.1.64", --AMF5
					"10.0.1.65", --AMF6
                    }  --IP table for each AMF

UPF_NGU_IP_TABLE 	= { "10.0.1.66","10.0.1.67","10.0.1.68","10.0.1.69","10.0.1.70","10.0.1.71","10.0.1.72","10.0.1.73",
					"10.0.1.74","10.0.1.75","10.0.1.76","10.0.1.77","10.0.1.78","10.0.1.79","10.0.1.65",
                    }  --IP table for each UPF NGU

UPF_IP_TABLE 	= { "1.2.0.1",
                    "1.2.8.1",
                    "1.2.16.1",
					"1.2.24.1",
					"1.2.32.1",
					"1.2.40.1",
					"1.2.48.1",
					"1.2.56.1",
					"1.2.64.1",
					"1.2.72.1",
					"1.2.80.1",
					"1.2.88.1",
					"1.2.96.1",
					"1.2.104.1",
					"1.2.112.1",
					"1.2.120.1",
					"1.2.128.1",
					"1.2.136.1",
					"1.2.144.1",
					"1.2.152.1",
                    }  --IP table for each UPF

PCI_TABLE       = { "17:0",
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
                    "22:2",
                    "23:0",
                    "23:1",
                    "23:2",
                    "24:0",
                    "24:1",
                    "24:2",
					}  --Physical cell ids configured in table for Multi-AP

NR_ARFCN_TABLE 	= { "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
					"2078255:2078255",
                    "2079921:2079921",
                    "2081587:2081587",
                    "2083253:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2078255:2078255",
                    "2079921:2079921",
                    "2081587:2081587",
                    "2083253:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2078255:2078255",
                    "2079921:2079921",
                    "2081587:2081587",
                    "2083253:2076589",
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

GSCN_TABLE    =   {   "22446",
                      "22452",
					  "22458",
					  "22464",
					  "22470",
                      "22476",
					  "22482",
                      "22488",
					  "22446",
                      "22452",
					  "22458",
					  "22464",
					  "22470",
                      "22476",
					  "22482",
                      "22488",
					  "22446",
                      "22452",
					  "22458",
					  "22464",
					  "22470",
                      "22476",
					  "22482",
                      "22488",
                    }  --GSCN Table with absolute value for Multi-AP

TRF_CORE_TABLE 	= { "10.0.1.151",
                    "10.0.1.152",
                    "10.0.1.153",
                    "10.0.1.154",
                    "10.0.1.155",
					"10.0.1.156",
					"10.0.1.157",
                    "10.0.1.158",
					"10.0.1.159",
					"10.0.1.160",
                    "10.0.1.161",
					"10.0.1.162",
					"10.0.1.163",
					"10.0.1.164",
					"10.0.1.165",
					"10.0.1.166",
					"10.0.1.167",
					"10.0.1.168",
					"10.0.1.169",
					"10.0.1.170",
                    "10.0.1.171",
                    "10.0.1.172",
                    "10.0.1.173",
                    "10.0.1.174",
                    }  --IP table for TRF CORE

TRF_UE_TABLE 	= { "10.0.2.151",
                    "10.0.2.152",
                    "10.0.2.153",
                    "10.0.2.154",
                    "10.0.2.155",
					"10.0.2.156",
					"10.0.2.157",
					"10.0.2.158",
                    "10.0.2.159",
					"10.0.2.160",
					"10.0.2.161",
                    "10.0.2.162",
					"10.0.2.163",
					"10.0.2.164",
                    "10.0.2.165",
					"10.0.2.166",
					"10.0.2.167",
					"10.0.2.168",
					"10.0.2.169",
					"10.0.2.170",
                    "10.0.2.171",
                    "10.0.2.172",
                    "10.0.2.173",
                    "10.0.2.174",
                    }  --IP table for TRF UE

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
    exec('set_enb id=1 plmn='..PLMN..' s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB1_X2U_ADDR..' type=simulated x2_peers=none proxy_read_packets_threshold=10 x2u_snd_buff_size=41943040 x2u_rcv_buff_size=41943040')
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
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..'')

local array_id = 1
local multi_ap_id = 1
local cell_tech

local temp_table = {unpack(CELL_ID_TABLE_FOR_AP1)} --copy AP1 cell ids in temp table1

if Multi_AP_FLAG == 'yes' then 
	local temp_table2 ={unpack(CELL_ID_TABLE_FOR_AP2)}  --copy AP2 cell ids in temp table2
	for k, v in pairs(temp_table2) do table.insert(temp_table, v) end  --concatenate AP1 & AP2 cell ids in temp table2
end

local cell_table ={unpack(temp_table)}  --copy cell ids in another temp table3
table.sort(temp_table)  --sort cell ids in temp table2
FIRST_CELL_ID = temp_table[1]  --assign First cell id
END_CELL_ID = temp_table[#temp_table]  --assign End cell id

for i=1, #cell_table do
    cell_id = cell_table[i]
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
	local resultemp_table = string.match(cell_tech, 'FDD')
    if (resultemp_table == nil) then	tdd_flag = 'on'	else	tdd_flag = 'off'	end

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
local upf_id

if MULTI_UPF_SUPPORT == 'yes' and UPF_COUNT > AMF_COUNT then END_UPF_ID = UPF_COUNT else END_UPF_ID = AMF_COUNT end

for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' name=SimModeAMF-'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[amf_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
    exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
end

for upf_id = 1, END_UPF_ID do
    exec('set_upf id='..upf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[upf_id]..'/21 ngu='..UPF_NGU_IP_TABLE[upf_id]..' devname=tunUPF'..upf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 n6_read_packets_threshold=40 n6_queue=2500')
end
       
if MULTI_UPF_SUPPORT == 'yes' and UPF_COUNT > AMF_COUNT then
--Map all UPF to all AMFs
    for amf_id = FIRST_AMF_ID, END_AMF_ID do
        exec('smf_upf_mapping id='..amf_id..' upf='..FIRST_AMF_ID..'-'..END_UPF_ID)
        exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
    end
else
--Map single UPF to single AMF
    for amf_id = FIRST_AMF_ID, END_AMF_ID do
        exec('smf_upf_mapping id='..amf_id..' upf='..amf_id)
        exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
    end
end

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
UEC_IP2 = UEC_COUNT + 2
UEC_IP = 1

for uec_id = 1, UEC_COUNT do
    exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
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

---------------------------------------------------------------------------------------------------
--TRF GEN
---------------------------------------------------------------------------------------------------
local array_id = 1
local id
local trf_id = 1

if TRF_GEN_SUPPORT_FOR_UE == 'yes' then
	exec('sim_param_set trf_gen_client_ports=39000-41000 trf_gen_server_ports=41001-41010 L2_HI_IP_ADDRESS=10.0.2.81,10.0.2.82,10.0.2.83,10.0.2.84,10.0.2.85,10.0.2.86')
	for id = 1, TRF_GEN_COUNT do
		if TRF_GEN_DIR == 'DL' then    --DL
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=core trf_gen_type=client client_addr='..TRF_CORE_TABLE[array_id]..' id='..trf_id..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310')
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=ue trf_gen_type=server server_addr='..TRF_UE_TABLE[array_id]..' id='..trf_id + 1 ..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310')
			trf_id = 1 + (id * 2)
			array_id = array_id + 1
		elseif TRF_GEN_DIR == 'UL' then    --UL
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=ue trf_gen_type=client client_addr='..TRF_UE_TABLE[array_id]..' id='..trf_id..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310')
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=core trf_gen_type=server server_addr='..TRF_CORE_TABLE[array_id]..' id='..trf_id + 1 ..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310')
			trf_id = 1 + (id * 2)
			array_id = array_id + 1
		elseif TRF_GEN_DIR == 'Both' then    --DL+UL
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=core trf_gen_type=client client_addr='..TRF_CORE_TABLE[array_id]..' id='..trf_id..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310') --DL
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=ue trf_gen_type=server server_addr='..TRF_UE_TABLE[array_id]..' id='..trf_id + 1 ..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310') --DL
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=ue trf_gen_type=client client_addr='..TRF_UE_TABLE[array_id + 1 ]..' id='..trf_id + 2 ..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310') --UL
			exec('set_trf_gen daemon='..SERVER_IP..':'..EDAEMON_PORT..' loc=core trf_gen_type=server server_addr='..TRF_CORE_TABLE[array_id + 1 ]..' id='..trf_id + 3 ..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310') --UL
			trf_id = 1 + (id * 4)
			array_id = array_id + 2
		end
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
upf_id = 1
trf_id = 1

-------------------------------------------------------------------
--SA UEs allocation on UE wise: UE1 on cell1, UE2 on cell2,..
-------------------------------------------------------------------
local total_ue = 0
for z = 1, #SA_UE_COUNT_FOR_ALL_CELLS do
    TEMP_UE = SA_UE_COUNT_FOR_ALL_CELLS[z]
    total_ue = total_ue + TEMP_UE
end
LAST_SA_UE_ID = total_ue

if Test_UEs == 'SA' or Test_UEs == 'Both' then
	for SA_UEID = FIRST_SA_UE_ID, LAST_SA_UE_ID do
::label_ue_check::
		if SA_CELLID > END_CELL_ID then SA_CELLID = FIRST_CELL_ID end
		if SA_UECID > UEC_COUNT then SA_UECID = 1 end
		if ue_group_id > UE_GROUP_COUNT then ue_group_id = 1 end
		if upf_id > AMF_COUNT  then upf_id = 1 end
		if SA_UE_COUNT_FOR_ALL_CELLS[SA_CELLID] == 0 then
			SA_UECID = SA_UECID + 1
			SA_CELLID = SA_CELLID + 1
			ue_group_id = ue_group_id + 1
            goto label_ue_check
		else

		if PET_SE_FLAG == 'yes' then
			if TRF_GEN_SUPPORT_FOR_UE == 'yes' and  MAX_UE_TRF_GEN > 0 and SA_UEID <= MAX_UE_TRF_GEN then --Check TCP traffic support enabled
				if upf_id > AMF_COUNT  then upf_id = 1 end
--				exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
				exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' additional_qosflows_to_activate=2 suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
				exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=external_trf_gen")
                exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=external_trf_gen")
--				exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal upf="..AMF_COUNT + upf_id )
				if TRF_GEN_DIR == 'DL' then
                    if trf_id > (TRF_GEN_COUNT * 2) or trf_id + 1 > (TRF_GEN_COUNT * 2) then trf_id = 1 end
--					exec("set_ue_trfgen_param ue="..SA_UEID.." pdu=1 upf="..upf_id.." qfi=1 dir=dl max_data_rate=1 trf_gen_client="..trf_id.." trf_gen_server="..trf_id + 1)
--                  exec("set_ue_trfgen_param ue="..SA_UEID.." pdu=1 upf="..upf_id.." qfi=1 dir=dl max_data_rate=1 trf_gen_client="..trf_id.." trf_gen_server="..trf_id + 1 .." pdu=2 upf="..upf_id + 1 .." qfi=2 dir=dl max_data_rate=1 trf_gen_client="..trf_id + 2 .." trf_gen_server="..trf_id + 3 )
					exec("set_ue_trfgen_param ue="..SA_UEID.." pdu=1 upf="..upf_id.." qfi=1 dir=dl max_data_rate=1 trf_gen_client="..trf_id.." trf_gen_server="..trf_id + 1 .." pdu=2 upf="..upf_id + 6 .." qfi=2 dir=dl max_data_rate=1 trf_gen_client="..trf_id + 2 .." trf_gen_server="..trf_id + 3 )
					trf_id = trf_id + 4
--					upf_id = upf_id + 2
                    upf_id = upf_id + 1
				elseif TRF_GEN_DIR == 'UL' then
--                    if trf_id > (TRF_GEN_COUNT * 2) or trf_id + 3 > (TRF_GEN_COUNT * 2) then trf_id = 1 end
					if trf_id > (TRF_GEN_COUNT * 2) or trf_id + 1 > (TRF_GEN_COUNT * 2) then trf_id = 1 end
					exec("set_ue_trfgen_param ue="..SA_UEID.." pdu=1 upf="..upf_id.." qfi=1 dir=ul max_data_rate=1 trf_gen_client="..trf_id.." trf_gen_server="..trf_id + 1 )
					trf_id = trf_id + 2
				elseif TRF_GEN_DIR == 'Both' then
                    if trf_id > (TRF_GEN_COUNT * 4) or trf_id + 3 > (TRF_GEN_COUNT * 4) then trf_id = 1 end
					exec("set_ue_trfgen_param ue="..SA_UEID.." pdu=1 upf="..upf_id.." qfi=1 dir=dl max_data_rate=1 trf_gen_client="..trf_id.." trf_gen_server="..trf_id + 1 .." pdu=1 upf="..upf_id.." qfi=1 dir=ul max_data_rate=1 trf_gen_client="..trf_id + 2 .." trf_gen_server="..trf_id + 3 )
					trf_id = trf_id + 4
				end
			else
				exec('set_ue id='..SA_UEID..' group='..ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' additional_qosflows_to_activate=2 suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
				exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
			end
		else
			exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		end
		SA_UECID = SA_UECID + 1
		SA_CELLID = SA_CELLID + 1
        ue_group_id = ue_group_id + 1
--		upf_id = upf_id + 1
        end
    end
end

-------------------------------------------------------------------
--NSA UEs allocation on UE wise: UE1 on cell1, UE2 on cell2,..
-------------------------------------------------------------------
--[[
if Test_UEs == 'NSA' or Test_UEs == 'Both' then
	for NSA_UEID = FIRST_NSA_UE_ID, LAST_NSA_UE_ID do
		if NSA_CELLID > END_CELL_ID then
			NSA_CELLID = FIRST_CELL_ID
		end
		if NSA_UECID > UEC_COUNT then
			NSA_UECID = 1
		end
		exec('set_ue simulated id='..NSA_UEID..' uec='..NSA_UECID..' pdn=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. NSA_IMSI + NSA_UEID - 1)
		exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=NSA_UE_CAP_2x2 dual_conn=eutra_nr ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg')
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
--]]
---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
--Multi-DRB configuration for SA UEs
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=7')
exec('nwslice_set id=1 qos_flows=1,2 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)
--exec('nwslice_set id=1 qos_flows=1 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR DL TP with 53UEs 1_8CC
---------------------------------------------------------------------------------------------------
--[[
gr_id = 1

if PET_SE_FLAG == 'yes' then
	for seq_gr_id = 1, 24 do
--	for seq_gr_id = 1, 1 do
		if gr_id > UE_GROUP_COUNT then
			gr_id = 1
		end
		exec('seq_set id='..seq_gr_id..' name=TCPTesting_Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register mode=ccsrt ue_nr_capabilities=UL_CA_TDD_SA_8CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 nwslice=1')
--		exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=74 size=42') --UDP
--        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=74 size=42') --74 bps UDP
--        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=74 size=42') --74 bps UDP
--        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul bps=74 size=42') --74 bps UDP
--        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl bps=74 size=42') --74 bps UDP
--		exec('ue_pdu_session_setup pdu=2 nwslice=1')
		--exec('ue_pdu_session_setup pdu=3 nwslice=1')

	    exec('trf_data_start pdu=1 qfi=1 dir=dl kbps=32603 size=1350 protocol=tcp') --TCP
--        exec('trf_data_start pdu=1 qfi=1 dir=ul mbps=11 size=1350 protocol=tcp') --TCP
--	    exec('trf_data_start pdu=2 qfi=1 trf_id=1 dir=dl mbps=1 size=1350 protocol=tcp') --TCP
--        exec('trf_data_start pdu=2 qfi=1 trf_id=1 dir=ul mbps=1 size=1350 protocol=tcp') --TCP
--		exec('trf_data_start pdu=3 qfi=2 trf_id=1 dir=dl bps=74 size=42') --UDP
--		exec('trf_data_start pdu=3 qfi=2 trf_id=1 dir=ul bps=74 size=42') --UDP
		exec('sleep '..timer)
--		exec('trf_data_stop pdu=1 qfi=1 dir=ul')	--TCP
		exec('trf_data_stop pdu=1 qfi=1 dir=dl')	--TCP
--		exec('trf_data_stop pdu=1 qfi=2 dir=ul')	--TCP
--		exec('trf_data_stop pdu=1 qfi=2 dir=dl')	--TCP
		exec('sleep 0.5')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
		gr_id = gr_id + 1
	end
end


---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR UL TP 53 UEs 1S-8CC
---------------------------------------------------------------------------------------------------

gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 25, 48 do
--  for seq_gr_id = 1, 1 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register mode=ccsrt ue_nr_capabilities=UL_CA_TDD_SA_8CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
--      exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=74 size=42') --UDP
--        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=74 size=42') --74 bps UDP
--        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=74 size=42') --74 bps UDP
--        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=ul bps=74 size=42') --74 bps UDP
--        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl bps=74 size=42') --74 bps UDP
--      exec('ue_pdu_session_setup pdu=2 nwslice=1')
        --exec('ue_pdu_session_setup pdu=3 nwslice=1')

--        exec('trf_data_start pdu=1 qfi=1 dir=dl mbps=34 size=1350 protocol=tcp') --TCP
        exec('trf_data_start pdu=1 qfi=1 dir=ul mbps=11 size=1350 protocol=tcp') --TCP
--      exec('trf_data_start pdu=2 qfi=1 trf_id=1 dir=dl mbps=1 size=1350 protocol=tcp') --TCP
--        exec('trf_data_start pdu=2 qfi=1 trf_id=1 dir=ul mbps=1 size=1350 protocol=tcp') --TCP
--      exec('trf_data_start pdu=3 qfi=2 trf_id=1 dir=dl bps=74 size=42') --UDP
--      exec('trf_data_start pdu=3 qfi=2 trf_id=1 dir=ul bps=74 size=42') --UDP
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
--]]

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR DL UL TP 4 UEs 1S-8CC
---------------------------------------------------------------------------------------------------
gr_id = 1

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 1, 1 do
--	for seq_gr_id = 49, 72 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register mode=ccsrt ue_nr_capabilities=UL_CA_TDD_SA_8CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
       exec('ue_pdu_session_setup pdu=2 nwslice=1')
        exec('trf_data_start pdu=2 qfi=2 trf_id=1 dir=dl mbps=160 size=1298 protocol=tcp')
        exec('trf_data_start pdu=2 qfi=2 trf_id=2 dir=dl mbps=160 size=1298 protocol=tcp')
        exec('trf_data_start pdu=2 qfi=2 trf_id=3 dir=dl mbps=160 size=1298 protocol=tcp')
        exec('trf_data_start pdu=2 qfi=2 trf_id=4 dir=dl mbps=38 size=1298 protocol=tcp')
        exec('sleep 0.5')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=160 size=1298 protocol=tcp') --TCP
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl mbps=160 size=1298 protocol=tcp') --TCP
        exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl mbps=160 size=1298 protocol=tcp')
       exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl mbps=38 size=1298 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=1 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=2 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=4 dir=dl mbps=45 size=1350 protocol=tcp')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR DL UL TP 4 UEs 1S-8CC
---------------------------------------------------------------------------------------------------
gr_id = 9

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 9, 9 do
--  for seq_gr_id = 49, 72 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register mode=ccsrt ue_nr_capabilities=UL_CA_TDD_SA_8CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
       exec('ue_pdu_session_setup pdu=2 nwslice=1')
        exec('trf_data_start pdu=2 qfi=2 trf_id=1 dir=dl mbps=160 size=1298 protocol=tcp')
        exec('trf_data_start pdu=2 qfi=2 trf_id=2 dir=dl mbps=99 size=1298 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=4 dir=dl mbps=38 size=1350 protocol=tcp')
        exec('sleep 0.5')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=160 size=1298 protocol=tcp') --TCP
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl mbps=99 size=1298 protocol=tcp') --TCP
--        exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl mbps=38 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=1 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=2 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=4 dir=dl mbps=45 size=1350 protocol=tcp')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
--[[
---------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR DL UL TP 4 UEs 1S-8CC
---------------------------------------------------------------------------------------------------
gr_id = 17

if PET_SE_FLAG == 'yes' then
    for seq_gr_id = 17, 17 do
--  for seq_gr_id = 49, 72 do
        if gr_id > UE_GROUP_COUNT then
            gr_id = 1
        end
        exec('seq_set id='..seq_gr_id..' name=Register-Sleep-Deregister-'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register mode=ccsrt ue_nr_capabilities=UL_CA_TDD_SA_8CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 nwslice=1')
       exec('ue_pdu_session_setup pdu=2 nwslice=1')
        exec('trf_data_start pdu=2 qfi=2 trf_id=1 dir=dl mbps=160 size=1350 protocol=tcp')
        exec('trf_data_start pdu=2 qfi=2 trf_id=2 dir=dl mbps=99 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=4 dir=dl mbps=38 size=1350 protocol=tcp')
        exec('sleep 0.5')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=160 size=1350 protocol=tcp') --TCP
        exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl mbps=99 size=1350 protocol=tcp') --TCP
--        exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl mbps=38 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=1 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=2 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=3 dir=dl mbps=160 size=1350 protocol=tcp')
--        exec('trf_data_start pdu=2 qfi=2 trf_id=4 dir=dl mbps=45 size=1350 protocol=tcp')
        exec('sleep '..timer)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
]]--
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
--exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled NR_CLUB_PROXY_PROTO_MSGS=enabled TTI=5') --Proxy proto flags enabled and added TTI param
---------------------------------------------------------------------------------------------------
--DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4 max_file_num=10 max_log_size=100M')
--exec('debug_log level=4')
exec('sim_param_set ENABLE_CORE_LIMIT=on')
exec('sim_param_set TTI=5 pet_5g_testing=on')
--exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('link_ctrl_param use_hb=off')
exec('sim_start version_check=off')
end
