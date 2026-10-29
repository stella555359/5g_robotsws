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
local AP_CONFIG_PATH="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/resources/AirPhoneConfig_SA_TDD.xml"


local EDAEMON_PORT="10000"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633364:633364')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633364:633364 mandatory_for_activation=off')
---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 file='..AP_CONFIG_PATH)

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,50 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01D51B0A3582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE000310EDC000200000001C0002000000000AA36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F57001FF001C007FC000621DB800040000000380004000000001546C4DD6080A1A02596513010F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8000C43B7000080000000700008000000002A8D89DAC10143404B2CA26021EB608080838778E1C830E0008193C7D540000140000018876E000100000000E000100000000000841C4D00000000202682807008089EC1701B001E00180E0601E0C01601E001A0F8000000000000395340004000025965400D2AAA0207000B000000040080118B130001020304050607080B101112131921252627284A')
end


---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=9 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=8')
exec('set_qosflow id=4 5qi=154')
exec('set_qosflow id=5 5qi=153')
exec('set_qosflow id=6 5qi=152')
exec('set_qosflow id=7 5qi=128')
exec('set_qosflow id=8 5qi=129')
exec('set_qosflow id=9 5qi=130')
exec('set_qosflow id=10 5qi=131')
exec('set_qosflow id=11 5qi=132')
exec('set_qosflow id=12 5qi=133')
exec('set_qosflow id=13 5qi=134')
exec('set_qosflow id=14 5qi=135')
exec('set_qosflow id=15 5qi=136')
exec('set_qosflow id=16 5qi=137')
exec('set_qosflow id=17 5qi=138')
exec('set_qosflow id=18 5qi=139')
exec('set_qosflow id=19 5qi=140')
exec('set_qosflow id=20 5qi=141')
exec('set_qosflow id=21 5qi=142')
exec('set_qosflow id=22 5qi=143')
exec('set_qosflow id=23 5qi=144')
exec('set_qosflow id=24 5qi=145')
exec('set_qosflow id=25 5qi=146')
exec('set_qosflow id=26 5qi=147')
exec('set_qosflow id=27 5qi=148')
exec('set_qosflow id=28 5qi=149')
exec('set_qosflow id=29 5qi=150')
exec('set_qosflow id=30 5qi=151')
exec('set_qosflow id=31 5qi=1')
exec('set_qosflow id=32 5qi=2')
exec('set_qosflow id=33 5qi=3')
exec('set_qosflow id=34 5qi=4')
exec('set_qosflow id=35 5qi=15')
exec('set_qosflow id=36 5qi=16')
exec('set_qosflow id=37 5qi=7')
exec('set_qosflow id=38 5qi=18')
exec('set_qosflow id=39 5qi=19')
exec('qosrule_set id=1 proto=tcp qos_flow=3')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=3,2,1,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39 qos_rules=1,2')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


exec('debug_log level=0')
--debug_log level=6 --uncomment for traffic

exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
