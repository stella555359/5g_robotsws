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
--local AP_CONFIG_PATH="/home/ute/Auto5G/testsuite/migration/Wroclaw/RRM/5G_SW_WRO/resources/AirPhoneConfig_SA_TDD.xml"
local AP_CONFIG_PATH="AirphoneConfig.xml"
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
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 xn=10.0.1.2')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off gscn=7853')

exec('set_gnb id=3 xn=10.0.1.101 ng=10.0.1.102 plmn=311:489 gnb_id=0x3 type=simulated daemon='..SERVER_IP..':'..EDAEMON_PORT..' nssai=0x01:0xD143A5')
exec('gnb_param id=3 sib1_period=40 send_xn_setup=false xn_listening_socket=on  measEvent=A5')
exec('cell_set id=1 gnb=3 tac=200 pci=127:0 earfcn=2000:20000 nr_arfcn=636666:636666  proxy=:5555 nrci=0x1')
---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 file='..AP_CONFIG_PATH)

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,50 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:021645400 enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=FDA0000001475803030000A4D1800260D09003100D0098040621803546C4DD618C21A0C54083E50480A2D931542C09F21CFA023C639F30C7942C0E070F022AA8AAA130000E0541B11B58630868315020F9412024B64C55050E7D811E31CF9863CA160703878127809E009800070005C1E230007134000000480BFFFFFFFFE006026C046F413003800281C1401C0C025007000600480080C05002000002012013400073E618F2858181F00401001000008040080000100995359535840001040200001009D749410000175D2400B4AAAA954530828480640228140A05028140A050280000101002004040100218A0304414246400')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=6')
exec('link_ctrl_param use_hb=off')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace amf=1 protocol=ng on')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('sim_start version_check=off')
