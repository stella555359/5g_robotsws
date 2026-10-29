local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_XN_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local AMF_NG_ADDR="10.0.1.11"
local AMF_NG_ADDR_2="10.0.1.12"
local AMF_NG_ADDR_3="10.0.1.13"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_IP="127.0.0.1"
local EDAEMON_PORT="10000"

require('os')
os.execute('sudo ifconfig eth3:AMF1 add '..AMF_NG_ADDR)
os.execute('sudo ifconfig eth3:AMF2 add '..AMF_NG_ADDR_2)
os.execute('sudo ifconfig eth3:AMF3 add '..AMF_NG_ADDR_3)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,788,0 plmn=311:489')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1,2')
exec('set_amf id=2 name=AMF2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR_2..':38412 region=1 set_id=2 pointer=1')
-- maximum number of setID-pointer pairs cannot be greater than 4
exec('set_amf id=3 name=AMF3 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR_3..':38412 region=1 set_id=3 pointer=4')

exec('amf_param id=1,2,3 order_backupamfs=deterministic')
--exec('amf_param id=1,2,3 amf_status_indication_support=on')

exec('set_backup_amf main=1 backup_amfs=2,3')


local AMF_COUNT=3
for i=1,AMF_COUNT do
    exec('amf_param id='..i..' full_nas_auth=on nia=null+zuc nea=null+zuc')
    exec('amf_ng_setup_param id='..i..' include_backup_amf_name=on')
    exec('amf_param id='..i..' support_guami_unavailability=on')
end

exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)
---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=all')
exec('set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5,1:0xD143A6 amf=all')
exec('set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=7880 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s')

exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

local UE_COUNT=10
for i=1,UE_COUNT do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    --exec('ue_param id='..i..' ue_nr_capabilities=01000000010900000004D0100026800780000000000001150000000000000150')
    --exec('ue_param id='..i..' ue_nr_capabilities=01200000010900080004DAA011002680005E000000000000045400000000000005404450')
    exec('ue_param id='..i..' ue_nr_capabilities=21A000000109000800C4DAA2FFCBFF0110389A00000014DE000000000000045400000000000005400000400801022280')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=5 default=on')
exec('set_qosflow id=2 5qi=1 ue=all')
exec('set_qosflow id=3 5qi=9 ue=all')
exec('set_qosflow id=4 5qi=4 ue=all')
exec('set_qosflow id=5 5qi=8 ue=all')

exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('qosrule_set id=3 proto=udp qos_flow=3')
exec('qosrule_set id=4 proto=udp qos_flow=4')
exec('qosrule_set id=5 proto=udp qos_flow=5')

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1,2,3 qos_flows=1,2,3,4,5 qos_rules=1,2,3,4,5')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1,2,3 qos_flows=1,2,3 qos_rules=1,2,3')

for i=1,UE_COUNT do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('start version_check=off')

