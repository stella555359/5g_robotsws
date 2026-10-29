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
local AP_CONFIG_PATH="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/5GC000937/5GC000937_A/config/AirphoneConfig2.xml"
--local AP_CONFIG_PATH="/opt/wts/latest/AirphoneConfig2.xml"

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
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 file='..AP_CONFIG_PATH)

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,50 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E9A09000575F5A13160003C5200016093170019C3D0B004D9061CF9863CA160704C060188E01771F13703582308682041D211001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E000BE0038002F8003A00000E0541F11B582308682041E21100195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F60000007400001C0A83E236B04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13F8000000FE0000000E800003800AA0711810000048150789A001C46000002120561E2600061180004120560E26040003010758789800184C0002008380180830130740001C81604ED8E7C3853A76C73E1C2893B639F0E044D8E7C3851276C73E18F4230003C00281C1401C0C02500700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C0100080000002000020010000120080040300C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000196524040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240314AAAE954552A8BA55154162A81C55068AA531549A2A80C55028AA4D5541E28780178095028140A05028140A05028140A05028140A0502814001000203C030404008020100C018202004010080600000101800820200401008010003543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E82820D40')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('sim_start version_check=off')
