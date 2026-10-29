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

for ip2 = 1, 49 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 111, 160 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
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


MULTI_AP_FLAG = 'NO' --YES/NO
cellDepType = 'Both'	--Configure cell deployment type value either as 'SA' or 'NSA' or 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet
HO_Enabled = 'NO'  --Sim-gNBs configured for Handover if set to 'YES'

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"	--SLICE ID
TAC = 200	--gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000
NSA_IMSI = 21650000



-------------------------------------------------------------------------------------
-- FOR REAL GNB VARIABLE
--------------------------------------------------------------------------------------
REAL_gNB_ID=2

GNB_X2_ADDR = "10.0.1.2"
GNB_S1U_ADDR = GNB_X2_ADDR
GNB_XN_ADDR = GNB_X2_ADDR
GNB_NG_ADDR = GNB_X2_ADDR

MUTLI_AP_IP_TABLE 	= { "10.0.2.80",
						"10.0.2.90",
						}  --IP table for each AP

NR_CELL_ID_TABLE_AP1    = { 1,
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
                            24
							}  --Cells belong to Airphone-1	

NR_CELL_ID_TABLE_AP2	= {  }	--Cells belong to Airphone-2


NR_CELLS_IN_AP1 = #NR_CELL_ID_TABLE_AP1

NR_CELLS_IN_AP2 = #NR_CELL_ID_TABLE_AP2



NR_CELL_TECH_TABLE_AP1  = { "TDD",
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
                            "TDD"
                            }   --Cells Tech of Airphone-1


NR_CELL_TECH_TABLE_AP2	= { }	--Cells Tech of Airphone-2


PCI_TABLE_AP1   = { "17:0",
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
					}  -- 18 phycical cell ids configured in table. 
                       -- PCI 16:2 = (16x3) + 2 = 50, 17:0 = 51 ... 
                       -- Compare with gNB commissioning and align 
                       -- with NUMBER_OF_CELLS parameter	

	
PCI_TABLE_AP2   = { } 
				
				
 --Table for ARFCN
 
NR_ARFCN_TABLE_AP1  = { "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    "2071591:2071591",
                    "2073257:2073257",
                    "2074923:2074923",
                    "2076589:2076589",
                    }  -- NRARFCN UL:DL for each cell
			 
NR_ARFCN_TABLE_AP2  = { } -- NRARFCN UL:DL for each cell


 --Table for GSCN 
						
GSCN_TABLE_AP1   =   {  "22446",
                          "22452",
				    	  "22458",
					      "22464",
                          "22446",
                          "22452",
	     				  "22458",
		     			  "22464",
                          "22446",
                          "22452",
				    	  "22458",
    					  "22464",
                          "22446",
                          "22452",
					      "22458",
					      "22464",
                          "22446",
                          "22452",
					      "22458",
					      "22464",
                          "22446",
                          "22452",
					      "22458",
					      "22464",
                    }  --GSCN Table with absolute value for Multi-AP

GSCN_TABLE_AP2   =   { }

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

LTE_CORE_COUNT=12

MME_S1_IP_TABLE    =   {   "10.0.1.131",
                        "10.0.1.132",
						"10.0.1.133",
						"10.0.1.134",
						"10.0.1.135",
						"10.0.1.136",
                      }   --IP table for each MME
					
SGW_S1U_IP_TABLE 	= { "10.0.1.137",
                        "10.0.1.138",
						"10.0.1.139",
						"10.0.1.140",
						"10.0.1.141",
						"10.0.1.142",
                                                "10.0.1.143",
                                                "10.0.1.144",
		 				"10.0.1.145",
						"10.0.1.146",
						"10.0.1.147",
						"10.0.1.148",

                        }  --IP table for each SGW S1U
SGW_S11_IP_TABLE 	= { "10.0.1.149",
                        "10.0.1.150",
						"10.0.1.151",
                        "10.0.1.152",
						"10.0.1.153",
                        "10.0.1.154",

                        "10.0.1.155",
                        "10.0.1.156",
						"10.0.1.157",
                        "10.0.1.158",
						"10.0.1.159",
                        "10.0.1.160",
                        }  --IP table for each SGW S11

PGW_IP_TABLE    =   {   "4.7.0.254",
                        "4.7.128.254",
						"4.8.0.254",
                        "4.8.128.254",
						"4.9.0.254",
                        "4.9.128.254",
						"4.10.0.254",
                        "4.10.128.254",
                        "4.11.0.254",
                        "4.11.128.254",
						"4.12.0.254",
                        "4.12.128.254",
						"4.13.0.254",
                        "4.13.128.254",
						"4.14.0.254",
                        "4.14.128.254",
                      }  --IP table for each PGW




-- SIM ENB VARIABLES

NUM_SIM_ENB = 6


NUM_CELL_PER_SIM_ENB = 8

SIM_ENB_IDENTIFIER = {3,4,5,6,7,8}

SIM_ENB_SERVER_IP_TABLE = { "10.0.2.1",
                            "10.0.2.2",
                            "10.0.2.3",
                            "10.0.2.4",
                            "10.0.2.5",
                            "10.0.2.6",
                           }  --Daemon IP table for each sim-gNB

SIM_ENB_X2_OR_XP_TABLE = {	"10.0.1.111",
						"10.0.1.112",
						"10.0.1.113",
						"10.0.1.114",
						"10.0.1.115",
						"10.0.1.116",
					   }
SIM_ENB_S1_ADDR = { "10.0.1.117",
				"10.0.1.118",
				"10.0.1.119",
				"10.0.1.120",
				"10.0.1.121",
				"10.0.1.122",
				}
				
SIM_ENB_PCI   = {	{"3:2","4:0","4:1","4:2","5:0","5:1","5:2","6:0"},
					{"6:1","6:2","7:0","7:1","7:2","8:0","8:1","8:2"},
					{"9:0","9:1","9:2","10:0","10:1","10:2","11:0","11:1"},
					{"11:2","12:0","12:1","12:2","13:0","13:1","13:2","14:0"},
					{"14:1","14:2","15:0","15:1","15:2","16:0","16:1","16:2"},
					{"17:0","17:1","17:2","18:0","18:1","18:2","19:0","19:1"},
					}
SIM_ENB_CELL_TECH_TABLE = { {"TDD","TDD","TDD","TDD","TDD","TDD","TDD","TDD"},
							{"TDD","TDD","TDD","TDD","TDD","TDD","TDD","TDD"},
							{"TDD","TDD","TDD","TDD","TDD","TDD","TDD","TDD"},
							{"TDD","TDD","TDD","TDD","TDD","TDD","TDD","TDD"},
							{"TDD","TDD","TDD","TDD","TDD","TDD","TDD","TDD"},
							{"TDD","TDD","TDD","TDD","TDD","TDD","TDD","TDD"},
						}
					
SIM_ENB_EARFCN =  { {"68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307"},
					{"68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307"},
					{"68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307"},
					{"68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307"},
					{"68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307"},
					{"68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307","68771:133307"},
                    } -- EARFCN DL:UL for each cell
				  

---------------------------------------------------------------------------------------------------
--5G GNB SIM VARIABLE
---------------------------------------------------------------------------------------------------
if HO_Enabled == 'YES' then

NUM_SIM_GNB=3

SIM_GNB_IDENTIFIER = {9,10,11}

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
    					{"1:0"},
	    				}  -- 6 phycical cell ids configured in table
						
SIM_GNB_CELL_TECH_TABLE = { {"FDD"},
							{"FDD"},
							{"FDD"},
	    				}

SIM_GNB_NR_ARFCN_TABLE 	= { {"390000:424000"},
							{"349000:364000"},
							{"353000:368000"}
                        }  
SIM_GNB_GSCN_TABLE  = 	{ 	{"5297"},
							{"4547"},
							{"4600"},
						}   --Table for GSCN

end
--------------------------------------------------------------------------------------------------
--UEC configuration
--------------------------------------------------------------------------------------------------


UEC_COUNT = 6   --Total number of UEC

---------------------------------------------------------
--UE GROUP 
---------------------------------------------------------

SA_UE_GROUP_COUNT_PER_CELL = 1   --Number of PET_SE UE_Groups per cell
NSA_UE_GROUP_COUNT_PER_CELL = 2

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
SA_UES_PER_GROUP=50

TOTAL_SA_UES_PER_CELL = SA_UE_GROUP_COUNT_PER_CELL*SA_UES_PER_GROUP

TOTAL_SA_UES_PER_AP1 = NR_CELLS_IN_AP1*TOTAL_SA_UES_PER_CELL

TOTAL_SA_UES_PER_AP2 = NR_CELLS_IN_AP2*TOTAL_SA_UES_PER_CELL

SA_UE=TOTAL_SA_UES_PER_AP1+TOTAL_SA_UES_PER_AP2

--NSA UEs

NSA_UES_PER_GROUP=106

TOTAL_NSA_UES_PER_CELL = NSA_UE_GROUP_COUNT_PER_CELL*NSA_UES_PER_GROUP

TOTAL_NSA_UES_PER_AP1 = NR_CELLS_IN_AP1*TOTAL_NSA_UES_PER_CELL

TOTAL_NSA_UES_PER_AP2 = NR_CELLS_IN_AP2*TOTAL_NSA_UES_PER_CELL

exec('set_qci qci=128 gbr=no priority=1 delay=80')

function run_configuration(duration)

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
UEC_IP2 = UEC_COUNT + 2
UEC_IP = 1
ue_group_id = 1
for uec_id = 1, UEC_COUNT do
exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100')

         if ue_group_id > (NSA_UE_GROUP_START+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
            ue_group_id = 25 
        end 

        if ue_group_id == 25 or ue_group_id == 26 or ue_group_id == 27 or ue_group_id == 28 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 29 or ue_group_id == 30 or ue_group_id == 31 or ue_group_id == 32 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=2 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 33 or ue_group_id == 34 or ue_group_id == 35 or ue_group_id == 36 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=3 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 37 or ue_group_id == 38 or ue_group_id == 39 or ue_group_id == 40 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=4 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 41 or ue_group_id == 42 or ue_group_id == 43 or ue_group_id == 44 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=5 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 45 or ue_group_id == 46 or ue_group_id == 47 or ue_group_id == 48 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=6 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end

        if ue_group_id == 49 or ue_group_id == 50 or ue_group_id == 51 or ue_group_id == 52 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=7 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 53 or ue_group_id == 54 or ue_group_id == 55 or ue_group_id == 56 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=8 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 57 or ue_group_id == 58 or ue_group_id == 59 or ue_group_id == 60 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=9 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 61 or ue_group_id == 62 or ue_group_id == 63 or ue_group_id == 64 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=10 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 65 or ue_group_id == 66 or ue_group_id == 67 or ue_group_id == 68 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=11 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end
        if ue_group_id == 69 or ue_group_id == 70 or ue_group_id == 71 or ue_group_id == 72 then
            exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=12 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
        end

	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500 disable_sib1_flood=true disable_sib_during_ho=true')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
    ue_group_id = ue_group_id + 1
end

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id='..REAL_gNB_ID..' type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x76C daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..' xp_management=on xp='..GNB_X2_ADDR..':32742 xpu='..GNB_X2_ADDR..':32742')

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
        exec('set_mme id='..mme_id..' name=SimModeMME-'..mme_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..MME_S1_IP_TABLE[mme_id]..':36412 supported_rat=lte,nblte pool=1:1')
    end

    for sgw_id = 1,LTE_CORE_COUNT do
        exec('set_sgw id='..sgw_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_IP_TABLE[sgw_id]..' s11='..SGW_S11_IP_TABLE[sgw_id]..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=20')
        exec('set_pgw id='..sgw_id..' type=simulated ip='..EDAEMON_IP..':'..EDAEMON_PORT..' addr='..PGW_IP_TABLE[sgw_id]..'/17 apn=lteapn'..sgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
    end
end

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
local cell_udp_port=12219
if cellDepType == 'NSA' or cellDepType == 'Both' then
    for sim_enb_count = 1, NUM_SIM_ENB do
        
        exec('enb_set id='..SIM_ENB_IDENTIFIER[sim_enb_count]..' name=SimModeLTERAN-'..sim_enb_count..' type=simulated plmn='..PLMN..' s1='..SIM_ENB_S1_ADDR[sim_enb_count]..' enb_id_macro=0x0000'..sim_enb_count..' daemon='..SIM_ENB_SERVER_IP_TABLE[sim_enb_count]..':'..EDAEMON_PORT..' x2='..SIM_ENB_X2_OR_XP_TABLE[sim_enb_count]..' x2u='..SIM_ENB_X2_OR_XP_TABLE[sim_enb_count]..' x2_peers='..REAL_gNB_ID..' mme=1 proxy_read_packets_threshold=10 x2u_snd_buff_size=41943040 x2u_rcv_buff_size=41943040')
        exec('enb_param id='..SIM_ENB_IDENTIFIER[sim_enb_count]..' drb_id_begin=3 endc_capable_qci=9,128')
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

for ue_group_id = (NSA_UE_GROUP_START),(NSA_UE_GROUP_START+TOTAL_NSA_UE_GROUP_FOR_AP1-1) do
	if NR_CELLS_IN_AP1 > cell_index then
		cell_index=1
	end
	if uecid > UEC_COUNT then
		uecid = 1
	end

    if ue_group_id == 25 or ue_group_id == 26 or ue_group_id == 27 or ue_group_id == 28 then
        sgw_id = 1
    end
    if ue_group_id == 29 or ue_group_id == 30 or ue_group_id == 31 or ue_group_id == 32 then
        sgw_id = 2
    end
    if ue_group_id == 33 or ue_group_id == 34 or ue_group_id == 35 or ue_group_id == 36 then
        sgw_id = 3
    end
	if ue_group_id == 37 or ue_group_id == 38 or ue_group_id == 39 or ue_group_id == 40 then
        sgw_id = 4
    end	
    if ue_group_id == 41 or ue_group_id == 42 or ue_group_id == 43 or ue_group_id == 44 then
        sgw_id = 5
    end
    if ue_group_id == 45 or ue_group_id == 46 or ue_group_id == 47 or ue_group_id == 48 then
        sgw_id = 6
    end

    if ue_group_id == 49 or ue_group_id == 50 or ue_group_id == 51 or ue_group_id == 52 then
        sgw_id = 7
    end
    if ue_group_id == 53 or ue_group_id == 54 or ue_group_id == 55 or ue_group_id == 56 then
        sgw_id = 8
    end
    if ue_group_id == 57 or ue_group_id == 58 or ue_group_id == 59 or ue_group_id == 60 then
        sgw_id = 9
    end
    if ue_group_id == 61 or ue_group_id == 62 or ue_group_id == 63 or ue_group_id == 64 then
        sgw_id = 10
    end
    if ue_group_id == 65 or ue_group_id == 66 or ue_group_id == 67 or ue_group_id == 68 then
        sgw_id = 11
    end
    if ue_group_id == 69 or ue_group_id == 70 or ue_group_id == 71 or ue_group_id == 72 then
        sgw_id = 12
    end


	exec("set_ue_group id="..ue_group_id.." name=UE_GRP-NSA-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP1[cell_index].." uec="..uecid.." pdn="..sgw_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g")
    cell_index = cell_index + 1
	uecid = uecid + 1
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
		exec("set_ue_group id="..ue_group_id.." name=UE_GRP-NSA-"..ue_group_id.."-CELL-"..NR_CELL_ID_TABLE_AP2[cell_index].." uec="..uecid.."  pdn="..sgw_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g")
		exec('set_bearer id=2 ue_group='..ue_group_id..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..EDAEMON_IP..' ul_nat_gw='..EDAEMON_IP)
        cell_index = cell_index + 1
		uecid = uecid + 1
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
    if ue_group_id == 25 or ue_group_id == 26 or ue_group_id == 27 or ue_group_id == 28 then
        sgw_id = 1
        enb_cell_id = 3
    end
    if ue_group_id == 29 or ue_group_id == 30 or ue_group_id == 31 or ue_group_id == 32 then
        sgw_id = 2
        enb_cell_id = 4
    end
    if ue_group_id == 33 or ue_group_id == 34 or ue_group_id == 35 or ue_group_id == 36 then
        sgw_id = 3
        enb_cell_id = 5
    end
    if ue_group_id == 37 or ue_group_id == 38 or ue_group_id == 39 or ue_group_id == 40 then
        sgw_id = 4
        enb_cell_id = 6
    end
    if ue_group_id == 41 or ue_group_id == 42 or ue_group_id == 43 or ue_group_id == 44 then
        sgw_id = 5
        enb_cell_id = 7
    end
    if ue_group_id == 45 or ue_group_id == 46 or ue_group_id == 47 or ue_group_id == 48 then
        sgw_id = 6
        enb_cell_id = 8
    end
    if ue_group_id == 49 or ue_group_id == 50 or ue_group_id == 51 or ue_group_id == 52 then
        sgw_id = 7
        enb_cell_id = 3
    end
    if ue_group_id == 53 or ue_group_id == 54 or ue_group_id == 55 or ue_group_id == 56 then
        sgw_id = 8
        enb_cell_id = 4
    end
    if ue_group_id == 57 or ue_group_id == 58 or ue_group_id == 59 or ue_group_id == 60 then
        sgw_id = 9
        enb_cell_id = 5
    end
    if ue_group_id == 61 or ue_group_id == 62 or ue_group_id == 63 or ue_group_id == 64 then
        sgw_id = 10
        enb_cell_id = 6
    end
    if ue_group_id == 65 or ue_group_id == 66 or ue_group_id == 67 or ue_group_id == 68 then
        sgw_id = 11
        enb_cell_id = 7
    end
    if ue_group_id == 69 or ue_group_id == 70 or ue_group_id == 71 or ue_group_id == 72 then
        sgw_id = 12
        enb_cell_id = 8
    end
		exec('set_ue id='..NSA_UEID..' group='..ue_group_id..' enb='..enb_cell_id..' sec_key=0102030405060708090A0B0C0D0EFF00 imsi='..PLMN..':'.. NSA_IMSI + NSA_UEID - 1)
	    exec('ue_param id='..NSA_UEID..' dual_conn=eutra_nr')
        exec('ue_mme_param id='..NSA_UEID..' sgw_id='..sgw_id)	
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

local SERVER_IPS = {CONTAINER_IP, "10.0.2.3", "10.0.2.4", "10.0.2.5", "10.0.2.6", "10.0.2.7", "10.0.2.8","10.0.2.9","10.0.2.10","10.0.2.11","10.0.2.12","10.0.2.13","10.0.2.14","10.0.2.15","10.0.2.16","10.0.2.17","10.0.2.18","10.0.2.19","10.0.2.20","10.0.2.21","10.0.2.22","10.0.2.23", "10.0.2.24", "10.0.2.25", "10.0.2.26", "10.0.2.27", "10.0.2.28", "10.0.2.29", "10.0.2.30", "10.0.2.31", "10.0.2.32", "10.0.2.33", "10.0.2.34", "10.0.2.35", "10.0.2.36", "10.0.2.37", "10.0.2.38", "10.0.2.39", "10.0.2.40", "10.0.2.41", "10.0.2.42", "10.0.2.43", "10.0.2.44", "10.0.2.45", "10.0.2.46", "10.0.2.47", "10.0.2.48", "10.0.2.49", "10.0.2.50", "10.0.2.51", "10.0.2.52", "10.0.2.53", "10.0.2.54", "10.0.2.55", "10.0.2.56", "10.0.2.57", "10.0.2.58", "10.0.2.59", "10.0.2.60", "10.0.2.61", "10.0.2.62", "10.0.2.63", "10.0.2.64", "10.0.2.65", "10.0.2.66", "10.0.2.67", "10.0.2.68", "10.0.2.69", "10.0.2.70", "10.0.2.71", "10.0.2.72", "10.0.2.73"}
for ue_group_id = 25, 72 do
    local server_ip = SERVER_IPS[(ue_group_id-1 % #SERVER_IPS) + 1]  
    local pdn
    if ue_group_id <= 28 then
        pdn = 1
    elseif ue_group_id <= 32 then
        pdn = 2
    elseif ue_group_id <= 36 then
        pdn = 3
    elseif ue_group_id <= 40 then
        pdn = 4
    elseif ue_group_id <= 44 then
        pdn = 5
    elseif ue_group_id <= 48 then
        pdn = 6
    elseif ue_group_id <= 52 then
        pdn = 7
    elseif ue_group_id <= 56 then
        pdn = 8
    elseif ue_group_id <= 60 then
        pdn = 9
    elseif ue_group_id <= 64 then
        pdn = 10
    elseif ue_group_id <= 68 then
        pdn = 11
    else
        pdn = 12
    end

    exec('set_bearer id=2 ue_group=' .. ue_group_id .. ' qci=9 pdn=' .. pdn .. ' default=on trf_type=internal dl_nat_gw=' .. server_ip .. ' ul_nat_gw=' .. server_ip)
end   
---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
--ec('set_qosflow id=4 5qi=8 default=off')
exec('set_qosflow id=4 5qi=128 default=off')
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1,2,3 amf_region_id=1-5 plmn_list='..PLMN..'  ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")


---------------------------------------------------------------------------------------------------
--SEQUENCE  CONFIGURATION
---------------------------------------------------------------------------------------------------
-------------------------------------------
--SA SEQUENCE
-------------------------------------------

-------------------------------------------
--NSA SEQUENCE
-------------------------------------------

------------TC : 13Gbps peak tput 4UEs per cell scenario ----------------------------------

ue_group_id=NSA_UE_GROUP_START
cell_id=1
for seq_id = 1, 24 do 
    if ue_group_id > (NSA_UE_GROUP_START+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
        ue_group_id=NSA_UE_GROUP_START  
    end
	if cell_id > (NR_CELLS_IN_AP1+NR_CELLS_IN_AP2) then
		cell_id=1
	end
    exec('seq_set id='..seq_id..' name=NSA_RRC_UE  ue_group='..ue_group_id..'')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_CA_3S_8CC ue_nr_capabilities=NSA_TDD_4CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb='..REAL_gNB_ID..' target_cells='..cell_id..' bearer=2 type=split_scg') --sgnb add
    exec('seq_delay 1.0')
    exec('trf_data_start id=2 dir=dl trf_id=1 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=2 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=3 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=4 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=5 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=6 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=7 mbps=133 size=1350') --72 bps
--  exec('trf_data_start id=2 dir=ul trf_id=1 bps=72 size=42') --72 bps
    exec('sleep '..duration..'') --For 1.5 Hrs
	exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('trf_data_stop id=2 dir=dl trf_id=2')
    exec('trf_data_stop id=2 dir=dl trf_id=3')
    exec('trf_data_stop id=2 dir=dl trf_id=4')
    exec('trf_data_stop id=2 dir=dl trf_id=5')
    exec('trf_data_stop id=2 dir=dl trf_id=6')
    exec('trf_data_stop id=2 dir=dl trf_id=7')
  --exec('trf_data_stop id=2 dir=ul trf_id=1')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 1.0')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end


cell_id=1
for seq_id = 25, 48 do
    if ue_group_id > (49+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
        ue_group_id=49
    end
    if cell_id > (NR_CELLS_IN_AP1+NR_CELLS_IN_AP2) then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_RRC_UE  ue_group='..ue_group_id..'')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_CA_3S_8CC ue_nr_capabilities=NSA_TDD_4CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb='..REAL_gNB_ID..' target_cells='..cell_id..' bearer=2 type=split_scg') --sgnb add
    exec('seq_delay 1.0')
    exec('trf_data_start id=2 dir=dl trf_id=1 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=2 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=3 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=4 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=5 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=6 mbps=160 size=1350') --72 bps
    exec('trf_data_start id=2 dir=dl trf_id=7 mbps=133 size=1350') --72 bps
--  exec('trf_data_start id=2 dir=ul trf_id=1 bps=72 size=42') --72 bps
    exec('sleep '..duration..'') --For 1.5 Hrs
    exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('trf_data_stop id=2 dir=dl trf_id=2')
    exec('trf_data_stop id=2 dir=dl trf_id=3')
    exec('trf_data_stop id=2 dir=dl trf_id=4')
    exec('trf_data_stop id=2 dir=dl trf_id=5')
    exec('trf_data_stop id=2 dir=dl trf_id=6')
    exec('trf_data_stop id=2 dir=dl trf_id=7')
  --exec('trf_data_stop id=2 dir=ul trf_id=1') 
 --exec('trf_data_stop id=2 dir=ul trf_id=1')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 1.0')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

------------TC : 571Mbps peak tput 2UEs per cell UL scenario ----------------------------------

ue_group_id=NSA_UE_GROUP_START
cell_id=1
for seq_id = 49, 72 do
    if ue_group_id > (NSA_UE_GROUP_START+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
        ue_group_id=NSA_UE_GROUP_START
    end
    if cell_id > (NR_CELLS_IN_AP1+NR_CELLS_IN_AP2) then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_RRC_UE  ue_group='..ue_group_id..'')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_CA_3S_8CC ue_nr_capabilities=NSA_TDD_4CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb='..REAL_gNB_ID..' target_cells='..cell_id..' bearer=2 type=split_scg') --sgnb add
    exec('seq_delay 1.0')
    exec('trf_data_start id=2 dir=ul trf_id=1 mbps=143 size=1350') 
   -- exec('trf_data_start id=2 dir=ul trf_id=2 mbps=126 size=1350')
    exec('sleep '..duration..'') --For 1.5 Hrs
 --  exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('trf_data_stop id=2 dir=ul trf_id=1')
 --   exec('trf_data_stop id=2 dir=ul trf_id=2')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 1.0')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

cell_id=1
for seq_id = 73, 96 do
    if ue_group_id > (49+NR_CELLS_IN_AP1+NR_CELLS_IN_AP2-1) then
        ue_group_id=49
    end
    if cell_id > (NR_CELLS_IN_AP1+NR_CELLS_IN_AP2) then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_RRC_UE  ue_group='..ue_group_id..'')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_CA_3S_8CC ue_nr_capabilities=NSA_TDD_4CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb='..REAL_gNB_ID..' target_cells='..cell_id..' bearer=2 type=split_scg') --sgnb add
    exec('seq_delay 1.0')
    exec('trf_data_start id=2 dir=ul trf_id=1 mbps=143 size=1350') --72 bps
--  exec('trf_data_start id=2 dir=ul trf_id=1 bps=72 size=42') --72 bps
    exec('sleep '..duration..'') --For 1.5 Hrs
    exec('trf_data_stop id=2 dir=ul trf_id=1')
  --exec('trf_data_stop id=2 dir=ul trf_id=1') 
 --exec('trf_data_stop id=2 dir=ul trf_id=1')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 1.0')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled') --Proxy proto flag enabled
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled') 
exec('sim_param_set TTI=5 ')
exec('sim_param_set pet_5g_testing=on')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set purge_buffer_on_full=on')
exec('sim_param_set PET_PROFILE=on')
--exec('sim_param_set pet_nsa_ping_testing=on')
exec('sim_param_set stop_traffic_on_ho=on')
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
