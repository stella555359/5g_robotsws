----------------------------------------------------
--COMMON VARIABLE
----------------------------------------------------

EDAEMON_IP="10.0.2.1"
EDAEMON_PORT=22222
PLMN="311:489"
SNSSAI = "0x01:0xD143A5"
TAC=200
SA_IMSI = 21640000
NSA_IMSI = 21650000


UPLANE_DATA_WITH_TRF_GEN="YES" --- YES or NO

SIMULATE_5G_RAN = "NO" --- YES or NO
SIMULATE_4G_RAN = "YES" --- YES or NO

SIMULATE_5G_CORE = "YES" --- YES or NO
SIMULATE_4G_CORE = "YES" --- YES or NO



-----------------------------------------------------------------------------------------------------------
---REAL GNB DATA 
-----------------------------------------------------------------------------------------------------------
--GNB DATA Syntax
-------------["GNB_ID"] = { NRBTSID, PLMN , NW SLICE, GNB_S1U_ADDR , GNB_X2_ADDR , GNB_X2U_ADDR , GNB_NG_ADDR , GNB_NGU_ADDR , GNB_XN_ADDR, GNB_XNU_ADDR , GNB_XP_ADDR ,GNB_XPU_ADDR}

GNB_DATA = { 
				["2"] = { gnb_id="0xE78F", plmn=PLMN , snssai=SNSSAI  ,  s1u= "10.0.3.2" , x2="10.0.3.2" , x2u="10.0.3.2" , ng="10.0.3.2" , ngu="10.0.3.2", xn="10.0.3.2" , xnu="10.0.3.2" , xp="10.0.3.2" ,xpu="10.0.3.2" ,xp_management="off" },

			}

--[[
		IF Multiple REAL gNB need just repeat DATA Syntax proper values
		NRBTSID --> value from SCF converted to Hexadecimal {In case DSS it should match to SCF}
--]]

-----------------------------------------------------------------------------------------------------------
---REAL GNB CELL DATA 
-----------------------------------------------------------------------------------------------------------
-- GNB CELL DATA Syntax 
-------------{ "CELL_ID, GNB_ID , PCI , TAC , TDD_FLAG [FDD=off or TDD=on] , GSCN , UL_NRARFCN:DL_NRARFCN, AP_PROXY [If cell belongs to AP1=10.0.2.80 or AP2=10.0.2.90] }

GNB_CELL_DATA = {
					{ cell_id=1   , gnb=2 , pci=50  , tac_list=TAC , tdd_flag="on" , gscn=7880 , nrarfcn="636666:636666" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=2   , gnb=2 , pci=51  , tac_list=TAC , tdd_flag="on" , gscn=7880 , nrarfcn="636666:636666" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=3   , gnb=2 , pci=52  , tac_list=TAC , tdd_flag="on" , gscn=7880 , nrarfcn="636666:636666" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=4   , gnb=2 , pci=53  , tac_list=TAC , tdd_flag="on" , gscn=7880 , nrarfcn="636666:636666" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=5   , gnb=2 , pci=54  , tac_list=TAC , tdd_flag="on" , gscn=7880 , nrarfcn="636666:636666" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=6   , gnb=2 , pci=55  , tac_list=TAC , tdd_flag="on" , gscn=7880 , nrarfcn="636666:636666" , ue_proxy_ip="10.0.2.80" },
				
					{ cell_id=7   , gnb=2 , pci=56  , tac_list=TAC , tdd_flag="on" , gscn=7940 , nrarfcn="640000:640000" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=8   , gnb=2 , pci=57  , tac_list=TAC , tdd_flag="on" , gscn=7940 , nrarfcn="640000:640000" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=9   , gnb=2 , pci=58  , tac_list=TAC , tdd_flag="on" , gscn=7940 , nrarfcn="640000:640000" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=10   , gnb=2 , pci=59  , tac_list=TAC , tdd_flag="on" , gscn=7940 , nrarfcn="640000:640000" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=11   , gnb=2 , pci=60  , tac_list=TAC , tdd_flag="on" , gscn=7940 , nrarfcn="640000:640000" , ue_proxy_ip="10.0.2.80" },
					{ cell_id=12   , gnb=2 , pci=61  , tac_list=TAC , tdd_flag="on" , gscn=7940 , nrarfcn="640000:640000" , ue_proxy_ip="10.0.2.80" },					
					
				}
--[[ 
	 IF Multiple CELL needed, just repeat GNB CELL DATA Syntax with proper values 
--]]

-----------------------------------------------------------------------------------------------------------
---4G SIM ENB DATA 
-----------------------------------------------------------------------------------------------------------
--SIM ENB DATA Syntax--------------["SIM_ENB_ID"] = { PLMN , ENB_S1_ADDR , ENB_X2_ADDR , X2_PEER , ENB_SERVER_IP}

SIM_ENB_DATA = {
					["3"] = { plmn=PLMN , s1="10.0.3.111" , x2="10.0.3.112" , x2u="10.0.3.113", x2_peers="none" , xp_peers="none" , xp="10.0.3.112",  xpu="10.0.3.112" , xp_management="on", qci_supported="9,7" , enb_server_ip="10.0.2.14" },
					["4"] = { plmn=PLMN , s1="10.0.3.114" , x2="10.0.3.115" , x2u="10.0.3.116", x2_peers="none" , xp_peers="none" , xp="10.0.3.115",  xpu="10.0.3.115" , xp_management="on", qci_supported="9,7" , enb_server_ip="10.0.2.15" },
					["5"] = { plmn=PLMN , s1="10.0.3.117" , x2="10.0.3.118" , x2u="10.0.3.119", x2_peers="none" , xp_peers="none" , xp="10.0.3.118",  xpu="10.0.3.118" , xp_management="on", qci_supported="9,7" , enb_server_ip="10.0.2.16" },
					["6"] = { plmn=PLMN , s1="10.0.3.120" , x2="10.0.3.121" , x2u="10.0.3.122", x2_peers="none" , xp_peers="none" , xp="10.0.3.121",  xpu="10.0.3.121" , xp_management="on", qci_supported="9,7" , enb_server_ip="10.0.2.17" },
					["7"] = { plmn=PLMN , s1="10.0.3.123" , x2="10.0.3.124" , x2u="10.0.3.125", x2_peers="none" , xp_peers="none" , xp="10.0.3.124",  xpu="10.0.3.124" , xp_management="on", qci_supported="9,7" , enb_server_ip="10.0.2.18" },
					["8"] = { plmn=PLMN , s1="10.0.3.126" , x2="10.0.3.127" , x2u="10.0.3.128", x2_peers="none" , xp_peers="none" , xp="10.0.3.127",  xpu="10.0.3.127" , xp_management="on", qci_supported="9,7" , enb_server_ip="10.0.2.19" },

				}

--[[
		IF Multiple SIM ENB needed,  just repeat SIM ENB DATA Syntax proper values
--]]

-----------------------------------------------------------------------------------------------------------
---SIM ENB CELL DATA 
-----------------------------------------------------------------------------------------------------------
-- SIM ENB  CELL DATA Syntax 

------------------["ENB_CELL_ID"] =  { ENB_ID , PCI , TAC , TDD_FLAG [FDD=off/TDD=on] , DL_EARFCN:DL_ARFCN, ENB_SERVER_IP } 

SIM_ENB_CELL_DATA = {						
						{ cell_id=1  , enb=3 , pci=11 , eci="0x0000301" , tac_list=TAC , tdd_flag="on" , earfcn="2000:20000", cell_proxy=SIM_ENB_DATA["3"].enb_server_ip },
						
                        { cell_id=1  , enb=4 , pci=12 , eci="0x0000401" , tac_list=TAC , tdd_flag="on" , earfcn="2000:20000", cell_proxy=SIM_ENB_DATA["4"].enb_server_ip },
						
                        { cell_id=1  , enb=5 , pci=13 , eci="0x0000501" , tac_list=TAC , tdd_flag="on" , earfcn="2000:20000", cell_proxy=SIM_ENB_DATA["5"].enb_server_ip },
						
                        { cell_id=1  , enb=6 , pci=15 , eci="0x0000601" , tac_list=TAC , tdd_flag="on" , earfcn="2000:20000", cell_proxy=SIM_ENB_DATA["6"].enb_server_ip },
                        
                        { cell_id=1  , enb=7 , pci=15 , eci="0x0000701" , tac_list=TAC , tdd_flag="on" , earfcn="2000:20000", cell_proxy=SIM_ENB_DATA["7"].enb_server_ip },
						
                        { cell_id=1  , enb=8 , pci=16 , eci="0x0000801" , tac_list=TAC , tdd_flag="on" , earfcn="2000:20000", cell_proxy=SIM_ENB_DATA["8"].enb_server_ip },						
						
				}

--[[ 
		IF Multiple CELL needed, just repeat GNB CELL DATA Syntax Syntax proper values
--]]
 
----------------------------------------------------------------------------------------------------
--4G CN SIM DATA
---------------------------------------------------------------------------------------------------					
--SIM MME DATA Syntax
-------------["SIM_MME_ID"] =  { MME_S1C_IP , PLMN }

SIM_MME_DATA = {
					["1"] = { mme_slc="10.0.3.131" , plmn=PLMN},
               }


--SIM SGW DATA Syntax
------------- ["SIM_SGW_ID"] =  { SGW_S1U_IP , SGW_S11_IP } 

SIM_SGW_DATA = {
					["1"] = { sgw_s1u="10.0.3.137" , sgw_s11="10.0.3.138" },
                    ["2"] = { sgw_s1u="10.0.3.139" , sgw_s11="10.0.3.140" },
                    ["3"] = { sgw_s1u="10.0.3.141" , sgw_s11="10.0.3.142" },
					["4"] = { sgw_s1u="10.0.3.143" , sgw_s11="10.0.3.144" },
					["5"] = { sgw_s1u="10.0.3.145" , sgw_s11="10.0.3.146" },
					["6"] = { sgw_s1u="10.0.3.147" , sgw_s11="10.0.3.148" },
                    ["7"] = { sgw_s1u="10.0.3.149" , sgw_s11="10.0.3.150" },
                    ["8"] = { sgw_s1u="10.0.3.151" , sgw_s11="10.0.3.152" },
                    ["9"] = { sgw_s1u="10.0.3.153" , sgw_s11="10.0.3.154" },
                    ["10"] = { sgw_s1u="10.0.3.155" , sgw_s11="10.0.3.156" },
                    ["11"] = { sgw_s1u="10.0.3.157" , sgw_s11="10.0.3.158" },
                    ["12"] = { sgw_s1u="10.0.3.159" , sgw_s11="10.0.3.160" },

                    ["13"] = { sgw_s1u="10.0.3.184" , sgw_s11="10.0.3.185" },
                    ["14"] = { sgw_s1u="10.0.3.186" , sgw_s11="10.0.3.187" },
                    ["15"] = { sgw_s1u="10.0.3.188" , sgw_s11="10.0.3.189" },
                    ["16"] = { sgw_s1u="10.0.3.190" , sgw_s11="10.0.3.191" },
                    ["17"] = { sgw_s1u="10.0.3.192" , sgw_s11="10.0.3.193" },
                    ["18"] = { sgw_s1u="10.0.3.194" , sgw_s11="10.0.3.195" },
					
               }


-- SIM PGW Syntax
--------------["SIM_PGW_ID"] = { "PGW_IP" }

SIM_PGW_DATA = {
					["1"] = { pgw_addr="4.7.0.254"   },
                    ["2"] = { pgw_addr="4.7.128.254" },
                    ["3"] = { pgw_addr="4.8.0.254"   },
					["4"] = { pgw_addr="4.8.128.254" },
					["5"] = { pgw_addr="4.9.0.254"   },
					["6"] = { pgw_addr="4.9.128.254" },
                    ["7"] = { pgw_addr="4.10.0.254"   },
                    ["8"] = { pgw_addr="4.10.128.254" },
                    ["9"] = { pgw_addr="4.11.0.254"   },
                    ["10"] = { pgw_addr="4.11.128.254" },
                    ["11"] = { pgw_addr="4.12.0.254"   },
                    ["12"] = { pgw_addr="4.12.128.254" },
                    ["13"] = { pgw_addr="4.13.0.254"   },
                    ["14"] = { pgw_addr="4.13.128.254" },
                    ["15"] = { pgw_addr="4.14.0.254"   },
                    ["16"] = { pgw_addr="4.14.128.254" },
                    ["17"] = { pgw_addr="4.15.0.254"   },
                    ["18"] = { pgw_addr="4.15.128.254" },
              }

-----------------------------------------------------------------------------------------------------------
---SIM GNB DATA 
-----------------------------------------------------------------------------------------------------------
--SIM GNB DATA Syntax
------------- ["SIM_GNB_ID"] = { PLMN , NW SLICE, SIM_GNB_S1U_ADDR , SIM_GNB_X2_ADDR , SIM_GNB_NG_ADDR , SIM_GNB_XN_ADDR, SIM_GNB_SERVER_IP }

 SIM_GNB_DATA = { 
					["9"]  = { plmn=PLMN , snassi=SNSSAI , sim_gnb_s1u="10.0.3.201" , sim_gnb_x2="10.0.3.202" , sim_gnb_ng="10.0.3.203" , sim_gnb_xn="10.0.3.204" ,  sim_gnb_server_ip="10.0.2.13"},
					["10"] = { plmn=PLMN , snassi=SNSSAI , sim_gnb_s1u="10.0.3.205" , sim_gnb_x2="10.0.3.206" , sim_gnb_ng="10.0.3.207" , sim_gnb_xn="10.0.3.208" ,  sim_gnb_server_ip="10.0.2.14"},
					["11"] = { plmn=PLMN , snassi=SNSSAI , sim_gnb_s1u="10.0.3.209" , sim_gnb_x2="10.0.3.210" , sim_gnb_ng="10.0.3.211" , sim_gnb_xn="10.0.3.212" ,  sim_gnb_server_ip="10.0.2.15"},
				}

--[[ 
		IF Multiple REAL gNB need just repeat DATA Syntax proper values
--]]

-----------------------------------------------------------------------------------------------------------
---SIM GNB CELL DATA 
-----------------------------------------------------------------------------------------------------------
--SIM GNB CELL DATA Syntax 
-----------  { CELL_ID, SIM_GNB_ID , PCI , TAC , TDD_FLAG , GSCN , UL_NRARFCN:DL_NRARFCN, SIM_GNB_SERVER_IP} 

SIM_GNB_CELL_DATA = {
					{ cell_id=1 , gnb=9  , pci=1 , tac=TAC , tdd_flag="on" , gscn="1579" , nrarfcn="135760:126380", cell_proxy=SIM_GNB_DATA["9"].sim_gnb_server_ip  },
					{ cell_id=1 , gnb=10 , pci=2 , tac=TAC , tdd_flag="on" , gscn="1579" , nrarfcn="135760:126380", cell_proxy=SIM_GNB_DATA["10"].sim_gnb_server_ip },
					{ cell_id=1 , gnb=11 , pci=3 , tac=TAC , tdd_flag="on" , gscn="1579" , nrarfcn="135760:126380", cell_proxy=SIM_GNB_DATA["11"].sim_gnb_server_ip },
				}

--[[ 
		IF Multiple CELL needed, just repeat GNB CELL DATA Syntax Syntax proper values 
--]]

----------------------------------------------------------------------------------------------------
--5G CN SIM DATA
---------------------------------------------------------------------------------------------------					
--Total number of AMF/UPF: Single AMF supports Max 2000UEs only
--SIM AMF DATA Syntax
-------------["SIM_AMF_ID"] =  { AMF_NGC_IP , TAC , PLMN , REGION , SET , POINTER}

SIM_AMF_DATA = { 
					["1"] = { amf_ng="10.0.3.1"  , plmn=PLMN , tac_list=TAC , amf_region=1 , amf_set=2 ,  amf_pointer=2 },
                    ["2"] = { amf_ng="10.0.3.61" , plmn=PLMN , tac_list=TAC , amf_region=2 , amf_set=3 ,  amf_pointer=3 },
                    ["3"] = { amf_ng="10.0.3.62" , plmn=PLMN , tac_list=TAC , amf_region=3 , amf_set=4 ,  amf_pointer=4 },
					["4"] = { amf_ng="10.0.3.63" , plmn=PLMN , tac_list=TAC , amf_region=4 , amf_set=5 ,  amf_pointer=5 },
					["5"] = { amf_ng="10.0.3.64" , plmn=PLMN , tac_list=TAC , amf_region=5 , amf_set=6 ,  amf_pointer=6 },
					["6"] = { amf_ng="10.0.3.65" , plmn=PLMN , tac_list=TAC , amf_region=6 , amf_set=7 ,  amf_pointer=7 },
               }


--SIM UPF DATA Syntax 
------------- ["SIM_UPF_ID"] =  { UPF_ADDR , UPF_NGU_IP }

SIM_UPF_DATA = { 
					["1"] =  { upf_addr="1.2.0.1"  , upf_ngu="10.0.3.1"  },
                    ["2"] =  { upf_addr="1.2.8.1"  , upf_ngu="10.0.3.61" },
                    ["3"] =  { upf_addr="1.2.16.1" , upf_ngu="10.0.3.62" },
					["4"] =  { upf_addr="1.2.24.1" , upf_ngu="10.0.3.63" },
					["5"] =  { upf_addr="1.2.32.1" , upf_ngu="10.0.3.64" },
					["6"] =  { upf_addr="1.2.64.1" , upf_ngu="10.0.3.65" },
               } 


-- SIM SMF mapping Syntax
--------------["SIM_SMF_ID"] = { "UPF_LIST","MAX_PDU_SESSIONS" }

SIM_SMF_DATA = { 
					["1"] = { upf_list="1,2,3,4,5,6" , pdu_sessions="3000" },
                    ["2"] = { upf_list="1,2,3,4,5,6" , pdu_sessions="3000" },
                    ["3"] = { upf_list="1,2,3,4,5,6" , pdu_sessions="3000" },
					["4"] = { upf_list="1,2,3,4,5,6" , pdu_sessions="3000" },
					["5"] = { upf_list="1,2,3,4,5,6" , pdu_sessions="3000" },
					["6"] = { upf_list="1,2,3,4,5,6" , pdu_sessions="3000" },
               }

-- SIM TRF GEN Syntax with Cleint and sever mode
--------------["SIM_TRF_GEN_ID"] = { "","MAX_PDU_SESSIONS" }

-----------------------------------------------------------------------------------------------------
--QOS Flow GROUP & NWSLICE DATA
-----------------------------------------------------------------------------------------------------					
--QOS Flow GROUP Syntax
-------------["QOS_GROUP_DATA"] =  {   ID , 5QI ID, DEFAULT[on/off] } 

QOS_GROUP_DATA = {
					["1"]  = { id=1 , fiveqi=6 , default="on"  },
					["2"]  = { id=2 , fiveqi=7 , default="off" },
					["3"]  = { id=3 , fiveqi=1 , default="off" },
					["4"]  = { id=4 , fiveqi=8 , default="off" },
			 	} 
				

 --NWSLICE Synt ax
 -------------["NWSLICE_DATA"] =  {   Id , SNSSAI , DEFAULT[on/off] , QOS_FLOWS ID , AMF_REGION ID [start_id-end_id] , PLMN_LIST , UE_COUNT  } 
 
 NWSLICE_DATA =  {
 					["1"]  = { id=1 , snssai=SNSSAI , default="on"	, qos_flows="1,2,3,4" , amf_region_id="1-6"	, plmn_list=PLMN , ue="all"  },
 --[[				["2"]  = { id=2 , snssai=SNSSAI , default="off"	, qos_flows="1,2,3" , amf_region_id="1-5" , plmn_list=PLMN , ue="1-100"  },
 					["3"]  = { id=3 , snssai=SNSSAI , default="off"	, qos_flows="1,2,3,4" , amf_region_id="1-5" , plmn_list=PLMN , ue="all"  },
 					["4"]  = { id=4 , snssai=SNSSAI , default="off"	, qos_flows="1" , amf_region_id="1-5" , plmn_list=PLMN , ue="all"  },
 -]]			 	} 
  


SIM_TRF_GEN_DATA = { 

                    --[[ for DL cleint -> core ; sever-> ue and  for UL client -> ue ; server -> core --]] 
             
					["1"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.161"},
                    ["2"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.162"},
					["3"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.163"},
                    ["4"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.164"},
					["5"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.165"},
                    ["6"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.166"},
					["7"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.167"},
                    ["8"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.168"},
					["9"]  = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.169"},
                    ["10"] = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.170"},
					["11"] = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.171"},
                    ["12"] = { trf_gen_type="client"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.172"},
					
					["13"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.161"},
                    ["14"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.162"},
					["15"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.163"},
                    ["16"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.164"},
					["17"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.165"},
                    ["18"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.166"},
					["19"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.167"},
                    ["20"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.168"},
					["21"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.169"},
                    ["22"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.160"},
					["23"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.171"},
                    ["24"] = { trf_gen_type="client"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.172"},
					
					  
					["25"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.173"},
                    ["26"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.174"},
					["27"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.175"},
                    ["28"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.176"},
					["29"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.177"},
                    ["30"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.178"},
					["31"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.179"},
                    ["32"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.180"},
					["33"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.181"},
                    ["34"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.182"},
					["35"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.183"},
                    ["36"] = { trf_gen_type="server"  , trf_gen_loc="core"  ,  trf_gen_ip_address="10.0.3.184"},
					
					["37"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.173"},
                    ["38"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.174"},
					["39"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.175"},
                    ["40"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.176"},
					["41"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.177"},
                    ["42"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.178"},
					["43"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.179"},
                    ["44"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.180"},
					["45"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.181"},
                    ["46"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.182"},
					["47"] = { trf_gen_type="server"  , trf_gen_loc="ue"    ,  trf_gen_ip_address="10.0.2.183"}, 
			   }

----------------------------------------------------------------------------------------------------
--UEC DATA
----------------------------------------------------------------------------------------------------					
--UEC DATA Syntax 
-------------["UEC_ID"] =  { UEC_IP , UPLANE_IP} 

UEC_DATA = { 
				["1"]  = { uec_ip="10.0.2.1" , uplane_ip="10.0.2.21"},
				["2"]  = { uec_ip="10.0.2.2" , uplane_ip="10.0.2.22"},
				["3"]  = { uec_ip="10.0.2.3" , uplane_ip="10.0.2.23"},
				["4"]  = { uec_ip="10.0.2.4" , uplane_ip="10.0.2.24"},
				["5"]  = { uec_ip="10.0.2.5" , uplane_ip="10.0.2.25"},
				["6"]  = { uec_ip="10.0.2.6" , uplane_ip="10.0.2.26"}, 
                ["7"]  = { uec_ip="10.0.2.7" , uplane_ip="10.0.2.27"},
                ["8"]  = { uec_ip="10.0.2.8" , uplane_ip="10.0.2.28"}, 
                ["9"]  = { uec_ip="10.0.2.9" , uplane_ip="10.0.2.29"},
                ["10"]  = { uec_ip="10.0.2.10" , uplane_ip="10.0.2.30"}, 
                ["11"]  = { uec_ip="10.0.2.11" , uplane_ip="10.0.2.31"},
                ["12"]  = { uec_ip="10.0.2.12" , uplane_ip="10.0.2.32"}, 
				
               }

-----------------------------------------------------------------------------------------------------
--UE GROUP DATA
-----------------------------------------------------------------------------------------------------					
--UE GROUP Syntax 
-------------["UE_GROUP"] =  {   NAME , RAN (gNB/enB)ID, CELL ID , UEC_ID , PDN , UE_TYPE , UE_COUNT , additional_qosflows_to_activate or add_drb [NIL or qosflow_id: 2 or 2,3] } 

UE_GROUP_DATA = {
--[[					
		{ ue_group_id=1  , name="SA_UE_GROUP_CELL1" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=1 , uec=1  , pdn=1 , upf=1 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=1, dl_server=25, ul_client=13, ul_server=37,}},
        { ue_group_id=2  , name="SA_UE_GROUP_CELL2" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=2 , uec=2  , pdn=1 , upf=2 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=2, dl_server=26, ul_client=14, ul_server=38,}},
        { ue_group_id=3  , name="SA_UE_GROUP_CELL3" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=3 , uec=3  , pdn=1 , upf=3 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=3, dl_server=27, ul_client=15, ul_server=39,}},
        { ue_group_id=4  , name="SA_UE_GROUP_CELL4" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=4 , uec=4  , pdn=1 , upf=4 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=4, dl_server=28, ul_client=16, ul_server=40,}},
        { ue_group_id=5  , name="SA_UE_GROUP_CELL5" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=5 , uec=5  , pdn=1 , upf=5 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=5, dl_server=29, ul_client=17, ul_server=41,}},
        { ue_group_id=6  , name="SA_UE_GROUP_CELL6" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=6 , uec=6  , pdn=1 , upf=6 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=6, dl_server=30, ul_client=18, ul_server=42,}},
        { ue_group_id=7  , name="SA_UE_GROUP_CELL7" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=1 , uec=1  , pdn=1 , upf=1 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=7, dl_server=31, ul_client=19, ul_server=43,}},
        { ue_group_id=8  , name="SA_UE_GROUP_CELL8" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=2 , uec=2  , pdn=1 , upf=2 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=8, dl_server=32, ul_client=20, ul_server=44,}},
        { ue_group_id=9  , name="SA_UE_GROUP_CELL9" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=3 , uec=3  , pdn=1 , upf=3 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=9, dl_server=33, ul_client=21, ul_server=45,}},
        { ue_group_id=10  , name="SA_UE_GROUP_CELL10" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=4 , uec=4  , pdn=1 , upf=4 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=10, dl_server=34, ul_client=22, ul_server=46,}},
        { ue_group_id=11  , name="SA_UE_GROUP_CELL11" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=5 , uec=5  , pdn=1 , upf=5 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=11, dl_server=35, ul_client=23, ul_server=47,}},
        { ue_group_id=12  , name="SA_UE_GROUP_CELL12" , ue_type="SA" , num_ue=72 , ran_id=2 , cell=6 , uec=6  , pdn=1 , upf=6 , additional_qosflows_to_activate="NIL" , pdu_sesstions={ { pdu=1,qfi={1}} }, trf_gen=true , ue_trf_gen_to_use={ dl_client=12, dl_server=36, ul_client=24, ul_server=47,}},
		--]]
		------------------------NSA UE GROUPS-------------------------------------------------------------[ only one bearer can be set as defalut ]						

		{ ue_group_id=13  , name="NSA_UE_GROUP_CELL13", ue_type="NSA" , num_ue=60 , ran_id=3 , cell=1 , uec=1 , pdn=1 , sgw_id=1 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=1, dl_server=37, ul_client=13, ul_server=25 } },
		{ ue_group_id=14  , name="NSA_UE_GROUP_CELL14", ue_type="NSA" , num_ue=60 , ran_id=4 , cell=1 , uec=2 , pdn=2 , sgw_id=2 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=2, dl_server=38, ul_client=14, ul_server=26 } },
		{ ue_group_id=15  , name="NSA_UE_GROUP_CELL15", ue_type="NSA" , num_ue=60 , ran_id=5 , cell=1 , uec=3 , pdn=3 , sgw_id=3 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=3, dl_server=39, ul_client=15, ul_server=27 } },
		{ ue_group_id=16  , name="NSA_UE_GROUP_CELL16", ue_type="NSA" , num_ue=60 , ran_id=6 , cell=1 , uec=4 , pdn=4 , sgw_id=4 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=4, dl_server=40, ul_client=16, ul_server=28 } },
		{ ue_group_id=17  , name="NSA_UE_GROUP_CELL17", ue_type="NSA" , num_ue=60 , ran_id=7 , cell=1 , uec=5 , pdn=5 , sgw_id=5 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=5, dl_server=41, ul_client=17, ul_server=29 } },
		{ ue_group_id=18  , name="NSA_UE_GROUP_CELL18", ue_type="NSA" , num_ue=60 , ran_id=8 , cell=1 , uec=6 , pdn=6 , sgw_id=6 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=6, dl_server=42, ul_client=18, ul_server=30 } },

		{ ue_group_id=19  , name="NSA_UE_GROUP_CELL19", ue_type="NSA" , num_ue=60 , ran_id=3 , cell=1 , uec=1 , pdn=7  , sgw_id=7 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=7, dl_server=43, ul_client=19, ul_server=31 } },
		{ ue_group_id=20  , name="NSA_UE_GROUP_CELL20", ue_type="NSA" , num_ue=60 , ran_id=4 , cell=1 , uec=2 , pdn=8  , sgw_id=8 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=8, dl_server=44, ul_client=20, ul_server=32 } },
		{ ue_group_id=21  , name="NSA_UE_GROUP_CELL21", ue_type="NSA" , num_ue=60 , ran_id=5 , cell=1 , uec=3 , pdn=9  , sgw_id=9 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=9, dl_server=45, ul_client=21, ul_server=33 } },
		{ ue_group_id=22  , name="NSA_UE_GROUP_CELL22", ue_type="NSA" , num_ue=60 , ran_id=6 , cell=1 , uec=4 , pdn=10 , sgw_id=10 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=10, dl_server=46, ul_client=22, ul_server=34 } },
		{ ue_group_id=23  , name="NSA_UE_GROUP_CELL23", ue_type="NSA" , num_ue=60 , ran_id=7 , cell=1 , uec=5 , pdn=11 , sgw_id=11 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=11, dl_server=47, ul_client=23, ul_server=35 } },
		{ ue_group_id=24  , name="NSA_UE_GROUP_CELL24", ue_type="NSA" , num_ue=60 , ran_id=8 , cell=1 , uec=6 , pdn=12 , sgw_id=12 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=true , ue_trf_gen_to_use={ dl_client=12, dl_server=47, ul_client=24, ul_server=30 } },

		{ ue_group_id=25  , name="NSA_UE_GROUP_CELL25", ue_type="NSA" , num_ue=315 , ran_id=3 , cell=1 , uec=7  , pdn=13 , sgw_id=13 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=1, dl_server=37, ul_client=13, ul_server=25 } },
		{ ue_group_id=26  , name="NSA_UE_GROUP_CELL26", ue_type="NSA" , num_ue=315 , ran_id=4 , cell=1 , uec=8  , pdn=14 , sgw_id=14 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=2, dl_server=38, ul_client=14, ul_server=26 } },
		{ ue_group_id=27  , name="NSA_UE_GROUP_CELL27", ue_type="NSA" , num_ue=315 , ran_id=5 , cell=1 , uec=9  , pdn=15 , sgw_id=15 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=3, dl_server=39, ul_client=15, ul_server=27 } },
		{ ue_group_id=28  , name="NSA_UE_GROUP_CELL28", ue_type="NSA" , num_ue=315 , ran_id=6 , cell=1 , uec=10 , pdn=16 , sgw_id=16 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=4, dl_server=40, ul_client=16, ul_server=28 } },
		{ ue_group_id=29  , name="NSA_UE_GROUP_CELL29", ue_type="NSA" , num_ue=315 , ran_id=7 , cell=1 , uec=11 , pdn=17 , sgw_id=17 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=5, dl_server=41, ul_client=17, ul_server=29 } },
		{ ue_group_id=30  , name="NSA_UE_GROUP_CELL30", ue_type="NSA" , num_ue=315 , ran_id=8 , cell=1 , uec=12 , pdn=18 , sgw_id=18 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=6, dl_server=42, ul_client=18, ul_server=30 } },

		{ ue_group_id=31  , name="NSA_UE_GROUP_CELL31", ue_type="NSA" , num_ue=315 , ran_id=3 , cell=1 , uec=7  , pdn=13 , sgw_id=13 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=7, dl_server=43, ul_client=19, ul_server=31 } },
		{ ue_group_id=32  , name="NSA_UE_GROUP_CELL32", ue_type="NSA" , num_ue=315 , ran_id=4 , cell=1 , uec=8  , pdn=14 , sgw_id=14 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=8, dl_server=44, ul_client=20, ul_server=32 } },
		{ ue_group_id=33  , name="NSA_UE_GROUP_CELL33", ue_type="NSA" , num_ue=315 , ran_id=5 , cell=1 , uec=9  , pdn=15 , sgw_id=15 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=9, dl_server=45, ul_client=21, ul_server=33 } },
		{ ue_group_id=34  , name="NSA_UE_GROUP_CELL34", ue_type="NSA" , num_ue=315 , ran_id=6 , cell=1 , uec=10 , pdn=16 , sgw_id=16 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=10, dl_server=46, ul_client=22, ul_server=34 } },
		{ ue_group_id=35  , name="NSA_UE_GROUP_CELL35", ue_type="NSA" , num_ue=315 , ran_id=7 , cell=1 , uec=11 , pdn=17 , sgw_id=17 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=11, dl_server=47, ul_client=23, ul_server=35 } },
		{ ue_group_id=36  , name="NSA_UE_GROUP_CELL36", ue_type="NSA" , num_ue=315 , ran_id=8 , cell=1 , uec=12 , pdn=18 , sgw_id=18 , bearer_set={{ bearerId=2,qci=9,default="on"},{ bearerId=3,qci=7,default="off"}} ,trf_gen=false , ue_trf_gen_to_use={ dl_client=12, dl_server=36, ul_client=24, ul_server=30 } },

	}         


--- SPECIFIC to DSS 
 
DSS_ENB_TO_GNB_MAP  = { 
							{ sim_enb_id=3 , sim_enb_cell_id=1 , target_gnb_id=2 , target_gnb_cell_id=1 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=3 , sim_enb_cell_id=2 , target_gnb_id=2 , target_gnb_cell_id=2 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=4 , sim_enb_cell_id=1 , target_gnb_id=2 , target_gnb_cell_id=3 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=4 , sim_enb_cell_id=2 , target_gnb_id=2 , target_gnb_cell_id=4 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=5 , sim_enb_cell_id=1 , target_gnb_id=2 , target_gnb_cell_id=5 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=5,  sim_enb_cell_id=2 , target_gnb_id=2 , target_gnb_cell_id=6 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=6 , sim_enb_cell_id=1 , target_gnb_id=2 , target_gnb_cell_id=7 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=6 , sim_enb_cell_id=2 , target_gnb_id=2 , target_gnb_cell_id=8 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=7 , sim_enb_cell_id=1 , target_gnb_id=2 , target_gnb_cell_id=9 ,  subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=7 , sim_enb_cell_id=2 , target_gnb_id=2 , target_gnb_cell_id=10 , subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=8 , sim_enb_cell_id=1 , target_gnb_id=2 , target_gnb_cell_id=11 , subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
							{ sim_enb_id=8 , sim_enb_cell_id=2 , target_gnb_id=2 , target_gnb_cell_id=12 , subframe_allocation="1011111001-1111101101-1011111001-1111101101-1011111001-1111101101-1011111001-1111101101"},
						}

DSS_XP_CONNECTION  =  { 
						{ sim_enb_id=3 , target_gnb_id=2 },
						{ sim_enb_id=4 , target_gnb_id=2 },
						{ sim_enb_id=5 , target_gnb_id=2 },
						{ sim_enb_id=6 , target_gnb_id=2 },
						{ sim_enb_id=7 , target_gnb_id=2 },
						{ sim_enb_id=8 , target_gnb_id=2 },
                      }					 

X2_CONNECTION  =  {
                        { sim_enb_id=3 , target_gnb_id=2 },
                        { sim_enb_id=4 , target_gnb_id=2 },
                        { sim_enb_id=5 , target_gnb_id=2 },
                        { sim_enb_id=6 , target_gnb_id=2 },
                        { sim_enb_id=7 , target_gnb_id=2 },
                        { sim_enb_id=8 , target_gnb_id=2 },
                     }		 
--[[ 
	
	Contact for HELP
	
	Shivaraju N
	Dineshwaran Subramani
	
--]]
