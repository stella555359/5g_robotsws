-- Copyright (c) 2022 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="10.0.2.1"
local SERVER_IP=CONTAINER_IP

local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local AMF_NG_ADDR="10.0.11.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="10.12.2.1"

local GNB_NG_ADDR="10.0.11.10"
local GNB_XN_ADDR="10.0.12.10"
local GNB_S1U_ADDR="10.0.1.60"
local GNB_X2_ADDR="10.0.1.10"
local GNB_X2U_ADDR="10.0.1.210"

local GNB_SIM_NG_ADDR="10.0.11.30"
local GNB_SIM_XN_ADDR="10.0.12.31"

local PDN_IP1="4.7.254.208"
local EDAEMON_PORT="10000"

os.execute('sudo ifconfig eth3:AMF1 add '..AMF_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')

exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 x2u='..GNB_X2U_ADDR..' x2_peers=none amf=all')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633000:633000')  -- changed from gscn=7880, nr_arfcn=633666
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633000:633000')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=7880 nr_arfcn=636662:636662 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=on sib1_period=10s')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
local UE_COUNT=80
local GW_COUNT=255
for i=1,UE_COUNT do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    -- exec('ue_param id='..i..' ue_nr_capabilities=21201000010900080004DAA011002680005378000000000000115000000000000015011140')	# pdcp 12bits
    exec('ue_param id='..i..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
ALL_QoS_FLOWS_IDs = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16'
DEFAULT_NON_GBR_5QI = '5'
USER_DEFINED_NON_GBR = '170'
UDP_5QIs = { ['1']='udp',
             ['2']='udp',
             ['3']='udp' }

-- mapping in GBR_5QIs and NON_GBR_5QIs reflects mapping in DevKr/CB008379/resources/CB008379-common_keywords.robot in opposite direction

GBR_5QIs = {    [1] = '1',
                [2] = '2',
                [3] = '3',
                [4] = '4',
                [5] = '71',
                [6] = '72',
                [7] = '76',
                [8] = '128',
                [9] = '212',
                [10] = '254'}

NON_GBR_5QIs = {[11] = '5',
                [12] = '6',
                [13] = '7',
                [14] = '8',
                [15] = '9',
                [16] = '170'}

-- 5QI1/2/3 - udp,  else - tcp
for id, gbr_5qi in pairs(GBR_5QIs) do
    exec('set_qosflow id='..id..' 5qi='..gbr_5qi..' gfbr_ul=6000 gfbr_dl=6000 mfbr_ul=6000 mfbr_dl=6000 priority=15 qos_flow_type=gbr ue=all')
    if UDP_5QIs[gbr_5qi] == 'udp' then
        exec('qosrule_set id='..id..' proto=udp qos_flow='..id)
    else
        exec('qosrule_set id='..id..' proto=tcp qos_flow='..id)
    end
end

for id, non_gbr_5qi in pairs(NON_GBR_5QIs) do
    if non_gbr_5qi == DEFAULT_NON_GBR_5QI then
        exec('set_qosflow id='..id..' 5qi='..non_gbr_5qi..' ue=all default=on')
    else
        if non_gbr_5qi == USER_DEFINED_NON_GBR then
            exec('set_qosflow id='..id..' 5qi='..non_gbr_5qi..' priority=15 qos_flow_type=non-gbr ue=all')
        else
            exec('set_qosflow id='..id..' 5qi='..non_gbr_5qi..' ue=all')
        end
    end
    exec('qosrule_set id='..id..' proto=tcp qos_flow='..id)
end

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows='..ALL_QoS_FLOWS_IDs..' qos_rules='..ALL_QoS_FLOWS_IDs)

for i=1,GW_COUNT do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('debug_log level=0')
exec('cfg_end')
sleep(1)
exec('start version_check=off')
