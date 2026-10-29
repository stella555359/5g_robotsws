----------------------------------------------------------------------------------------------------
--USER OR OPERATOR EDITABLE VARIABLES
----------------------------------------------------------------------------------------------------
Test_Tech = 'TDD'	--Set values as 'FDD or 'TDD' based on your Test Line
Test_UEs = 'SA'	--Planning to test only SA UEs then set value as 'SA', for only NSA UEs set as 'NSA' and SA+NSA UEs then set as 'Both'
PET_SE_FLAG = 'yes'	--Set value as 'yes' if user wants to test PET_SE, else set 'no' to use normal configuration: >> NSA PET_SE NOT supported yet

AMF_COUNT = 5   --Total number of AMF/UPF: Single AMF supports Max 2000UEs only
UEC_COUNT = 8   --Total number of UEC
UE_COUNT_ON_CELL = 1500 --Intra-Loki: 2CELLS per LOKI, supports max 250UE per Cells
UEID_TO_GROUP_FILE = '/opt/iphy/latest/ueid_to_group_map.lua'

FIRST_CELL_ID = 1   --Starting cell id, for next AP change this to 7,13,19,25,31,....
NUMBER_OF_CELLS = 4  --Total number of Cells
CELL_ID_TABLE = {
                   { cell_id=1, technology="TDD", pci="16:2", nrarfcn="636666:636666", gscn=7853, additional="8DL_SRS_SB" },
				   { cell_id=4, technology="TDD", pci="17:2", nrarfcn="630000:630000", gscn=7812, additional="8DL_SRS_SB" },
				   { cell_id=7, technology="FDD", pci="18:2", nrarfcn="145600:156600", gscn=1956, additional="none" },
				   { cell_id=10, technology="FDD", pci="19:2", nrarfcn="145600:156600", gscn=1956, additional="none" }
				}
                       -- PCI 16:2 = (16x3) + 2 = 50, 17:0 = 51 ... 
                       -- Compare with gNB commissioning physcellid
                       -- 8DL_SRS 8DL_PMI 8UL_SRS, 16DL_SRS, 8DL_SRS_SB

FIRST_AMF_ID = 1   --Starting AMF id
FIRST_UE_SA_CELL = 1    --Starting SA UEid
FIRST_UE_NSA_CELL = 10001    --Starting NSA UEid

UE_GROUP_COUNT = NUMBER_OF_CELLS     --Number of PET_SE UE_Groups
SEQ_GROUP_COUNT = NUMBER_OF_CELLS	--Number of Sequence_set groups

END_CELL_ID = FIRST_CELL_ID + NUMBER_OF_CELLS - 1 --End cell id =  FIRST_CELL_ID + NUMBER_OF_CELLS - 1, Ex: = 7+6-1
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
END_UE_SA_CELL = FIRST_UE_SA_CELL + ( NUMBER_OF_CELLS * UE_COUNT_ON_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell
END_UE_NSA_CELL = FIRST_UE_NSA_CELL + ( NUMBER_OF_CELLS * UE_COUNT_ON_CELL ) - 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

PLMN = "311:489" --gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI1 = "0x01:0xD143A5"	     --SLICE ID = 13714341
SNSSAI2 = "0x01:0xD143A6"        --SLICE ID = 13714342
SNSSAI3 = "0x01:0xD143A7"        --SLICE ID = 13714343
SNSSAI4 = "0x01:0xD143A8"        --SLICE ID = 13714344
SNSSAI5 = "0x01:0xD143A9"        --SLICE ID = 13714345
SNSSAI6 = "0x01:0xD143AA"        --SLICE ID = 13714346
TAC = 200	--gNB & AMF supported Tracking Area Code
GSCN = 7880	--GSCN value
SA_IMSI = 21640000
NSA_IMSI = 21650000
CORENETWORK_COUNT = 1	--Total number of SGW/PGW in core network

-------------------------------------------------------------------------------------
--IP TABLES
--------------------------------------------------------------------------------------

AMF_IP_TABLE 	= { "10.0.1.1",
                    "10.0.1.61",
                    "10.0.1.200",
					"10.0.1.201",
					"10.0.1.202",
                    }  --IP table for each AMF

UPF_IP_TABLE 	= { "1.2.0.1",
                    "1.2.8.1",
                    "1.2.24.1",
					"1.2.32.1",
					"1.2.40.1",
                    }  --IP table for each UPF

-- PCI_TABLE       = { "17:2",
					-- "18:0",
					-- "18:1"
					-- }  -- 6 phycical cell ids configured in table. 
                       -- -- PCI 16:2 = (16x3) + 2 = 50, 17:0 = 51 ... 
                       -- -- Compare with gNB commissioning and align 
                       -- -- with NUMBER_OF_CELLS parameter
-- NR_ARFCN_TABLE  = { "630000:630000",
                    -- "630000:630000",
                    -- "630000:630000"
                    -- }  -- NRARFCN UL:DL for each cell

SGW_S1U_IP_TABLE 	= { "10.0.1.132"
                        }  --IP table for each SGW S1U
SGW_S11_IP_TABLE 	= { "10.0.1.133"
                        }  --IP table for each SGW S11

PGW_IP_TABLE    =   {   "4.7.0.254"
                      }  --IP table for each PGW


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
UEC2_ADDR="72.22.0.1"
UEC3_ADDR="72.23.0.1"
UEC4_ADDR="72.24.0.1"
UEC5_ADDR="72.25.0.1"
UEC6_ADDR="72.26.0.1"

----------------------------------------------------------------------------------------------------
-- VARIABLES for MULTI-AIRPHONE support
----------------------------------------------------------------------------------------------------
--LTE definitions
ENB1_X2U_ADDR="10.0.1.138"
ENB1_X2_ADDR="10.0.1.137"
ENB1_S1_ADDR="10.0.1.136"

MME1_S1_ADDR="10.0.1.131"

PDN_IP="4.7.0.253"
PDN_IP2="4.7.100.253"
PDN_IP3="4.7.150.253"
PDN_IP4="4.7.200.253"