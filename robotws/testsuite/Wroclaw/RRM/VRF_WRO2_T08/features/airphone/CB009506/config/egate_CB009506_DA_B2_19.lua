---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=1 amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=470000:470000 mandatory_for_activation=on')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=E1A21000014F5A0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020310C00283E13EB0C6D1D262A08FE59493281C082D930480C18F18FFCC31E50B0381C3C04DFFFFEDFFFFE04003000000000709C00000001083009F9343E0048200000100DCA9BC05BC01BC09BC0DBC15BC19A0002000012CA4A0369555D01ABA015740AAE81D5D05ABA0D542401E0068040200000000000801002100')
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.1.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=8 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

-- MISC
exec('debug_log level=4')
exec('sim_debug_log level=1 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace uec=1 protocol=all on')
exec('sim_trace amf=1 protocol=all on')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc off')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('set_log flush')
exec('cfg_end')
exec('set_log log_to_file=on')
sleep(1)
