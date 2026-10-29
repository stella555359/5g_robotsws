-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"
NUMBER_OF_UES=9

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=2077819:2077819 gscn=22468 eci=0x000021f pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=2077919:2077919 gscn=22468 eci=0x000021f pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_UES do
    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g suci=0:311:489:0000:0:0:02164540'..ue_id..
         ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=03A00380020008000001A00080020020001000000101083A0000000200100000037800000000000013A000080000000008008ED00000100200408EB7000000000000')
    exec('set_pdu_gateway id='..ue_id..
         ' ue_nat_ip=72.23.0.'..ue_id..
         ' dl_nat_gw='..SERVER_IP..
         ' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on ue=all')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1')

exec('debug_log level=4')
exec('set_log log_to_file=on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec("set_log flush")
exec('cfg_end')
