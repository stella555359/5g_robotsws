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
local AP_CONFIG_PATH="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/config/sa_fdd_cmWv/AirPhoneConfig.xml"

local EDAEMON_PORT="10000"
NUMBER_OF_UES=5
NUMBER_OF_PDU_GW_ID= 2 * NUMBER_OF_UES

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 file='..AP_CONFIG_PATH)

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_UES do
    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+snow3g+aes nea=null+zuc+snow3g+aes suci=0:311:489:0000:0:0:02164540'..ue_id..
         ' mode=nr enb=2 rohc=8:rtp,udp cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A01380014F5E0302C0020640024106CE261F0A1201360107FE618F28581C130080C450180531800507C46D618DA3A4C5411FCB29265048082D930480C18F18FFCC31E50B0381C3C044E013800200711800000001083011B9343E01C8200000148200000548200000949280000D300F81B795378195BA40141000009652404000065949010000296524040000E594941000049652424000154B29200BA07174AA2E81C4D2A89A55115D881200F00340201000000000004008010A2280  nr_usage_setting=voice_centric')
    exec('ue_nr_capabilities id='..ue_id..' voice_over_nr=on:on:off')
end

for gw_id=1, NUMBER_OF_PDU_GW_ID do
    exec('set_pdu_gateway id='..gw_id..
         ' ue_nat_ip=72.23.0.'..gw_id..
         ' dl_nat_gw='..SERVER_IP..
         ' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=8')
exec('set_qosflow id=2 5qi=5 default=on')
exec('set_qosflow id=3 5qi=1')
--exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')
-- exec('qosrule_set id=1 proto=tcp qos_flow=2')
-- exec('qosrule_set id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 snssai=0x01:0xD143A5 default=on amf=1')

exec('debug_log level=0')
exec('set_log log_to_file=on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec("set_log flush")
exec('cfg_end')
