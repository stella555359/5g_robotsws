-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_XN_ADDR="10.0.1.2"
local GNB3_NG_ADDR="10.0.1.3"
local GNB3_XN_ADDR="10.0.1.4"

local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local EDAEMON_PORT="10000"


---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=100,788,200,0 plmn=311:489,311:402')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..'')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x1:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_XN_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880')

---------------------------------------------------------------------------------------------------
--GNB SIM CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:402 ng='..GNB3_NG_ADDR..' gnb_id=0x3:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB3_XN_ADDR..' x2_peers=none nssai=0x1:0xd143a5 amf=1')
exec('gnb_param id=3 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=ng_based')
exec('set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x03 tdd_cell=on proxy='..GNB3_NG_ADDR..':9999 nr_arfcn=636666:636666 gscn=7880')


---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')
---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645400 enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=E1A00000074E5A031E000380A03C1260C80008780818806804C020300C032A36142B04050D012CB289D70004F001C0013C002A3617AB04050D012CB289D70004F001C0013C002A3626AB04050D012CB289D70004F001C0013C002A36272B04050D012CB289D5000005000000108389A00000000404DF60701C00140E020381801C07000683E0000000000000E54D000100000965950034AAA8081C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA128')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 default=on snssai=0x01:0xD143A5 qos_flows=1 ue=1 amf_region_id=1 plmn_list=311:489,311:402')

exec('set_pdu_gateway id=1 ue_nat_ip=72.23.1.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')


exec('debug_log level=0')
exec('sim_debug_log level=1 mme=1')
exec('sim_debug_log level=1 uec=1')
exec('sim_debug_log level=1 pgw=1')
exec('sim_debug_log level=1 sgw=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('start version_check=off')


