-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_XN_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_IP="127.0.0.1"
local EDAEMON_PORT="10000"


local ENB1_S1_ADDR="10.0.1.21"

local ENB1_X2_ADDR="10.0.1.21"

local MME1_S1_ADDR="10.0.1.111"

local SERVER_ADDR="192.168.4.132"
local SGW_S1U_ADDR="10.0.1.111"
local SGW_S11_ADDR="10.0.1.111"

local ENB_X2U_ADDR="10.0.1.21"
local PGW_ADDR="4.7.254.207"


require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')
os.execute('sudo ifconfig eth4:MME add 10.0.1.111')
os.execute('sudo ifconfig eth3:eNB add 10.0.1.21')

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=2')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..EDAEMON_IP..':2154 earfcn=2000:20000 mapped_earfcn=4200:22200')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')


---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..':2152 s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..EDAEMON_IP..':'..EDAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')


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
exec('set_cell id=1 gnb=2 pci=16:2 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7881 nr_arfcn=636666:636666')
exec('set_cell id=3 gnb=2 pci=17:1 tac=0 nrci=0x03 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')
exec('set_cell id=4 gnb=2 pci=17:2 tac=0 nrci=0x04 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7881 nr_arfcn=636666:636666')

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

--NSA UEs
for i=16,20 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:216454'..i..' enb=1 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0'..
    ' dual_conn=eutra_nr'..
    ' ue_eutra_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E260000000010130540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=5 default=on')
exec('set_qosflow id=2 5qi=1 ue=all')

exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1,2 qos_rules=1,2')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 qos_flows=1,2 qos_rules=1,2')

for i=1,20 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
for i=16,20 do
    local ue_ip = 207 + i
    exec('set_bearer id=2 ue='..i..' qci=9 pdn=1 ip=4.7.254.'..ue_ip..' default=on trf_type=internal')
end

exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('debug_log level=0')
exec('cfg_end')
sleep(1)
