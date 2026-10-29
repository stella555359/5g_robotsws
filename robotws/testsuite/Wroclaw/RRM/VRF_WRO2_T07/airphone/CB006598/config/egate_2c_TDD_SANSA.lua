-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_XN_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_IP="127.0.0.1"
local EDAEMON_PORT="10000"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,788,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
--SA UEs
for i=1,15 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=1 ue=all gfbr_dl=10000 mfbr_dl=170000 priority=15 qos_flow_type=gbr')
exec('set_qosflow id=2 5qi=2 ue=all gfbr_dl=10000 mfbr_dl=170000 priority=15 qos_flow_type=gbr')
exec('set_qosflow id=3 5qi=3 ue=all gfbr_dl=10000 mfbr_dl=170000 priority=15 qos_flow_type=gbr')
exec('set_qosflow id=5 5qi=5 default=on')

exec('qosrule_set id=1 proto=udp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('qosrule_set id=3 proto=udp qos_flow=3')
exec('qosrule_set id=5 proto=tcp qos_flow=5')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1,2,3,5 qos_rules=1,2,3,5')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 qos_flows=1,2,3,5 qos_rules=1,2,3,5')

for i=1,20 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('debug_log level=4')
exec('cfg_end')
sleep(1)

