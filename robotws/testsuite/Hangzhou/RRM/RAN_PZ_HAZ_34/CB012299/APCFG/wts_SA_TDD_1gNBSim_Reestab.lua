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
local PROXY2_SERVER_IP="10.0.2.90"
local AMF_NG_ADDR="10.0.1.1"
local ADDITIONAL_NGU_ADDR="10.0.1.200"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_IP="127.0.0.1"
local EDAEMON_PORT="22222"

require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.90')
os.execute('sudo ifconfig eth3:ADD_NGU add '..ADDITIONAL_NGU_ADDR)

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,201,788,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
--exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ambr_remove=pdu_setup')
--exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_additional_ip='..ADDITIONAL_NGU_ADDR)


---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=5878 nr_arfcn=470000:470000')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=5878 nr_arfcn=470000:470000')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=5922 nr_arfcn=474000:474000 nr_scs=30kHz bs_channel_bandwidth=40MHz')
exec('gnb_cell_param id=1 gnb=3 enable_anr=off neighbor_pci=16:2')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sa_ho=xn_based sib1_period=40 measEvent=A3 srb1_rlc_sn_field_size=size_12')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
local UE_COUNT=40
local GW_COUNT=255
for i=1,UE_COUNT do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A2FFA047F436001C0028000FA0900E07A877FFF83C6B80003C005C0000A000000068170101E0935F1E7FF7D0D800C6E3C00050370500663813D57C0000D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FFC7F0007FF1FC0008E80000380028015B2000200032000200001D57C0200D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FFC7F0007FF1FC0008E80000380028015B3000300033000300001D57C0400D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FE0780007F81E00008E000003800281D57C0700D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FC0700007F01C00008E000003800281D57C1B00D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FD0740007F41D00008E000003800281D57C2500D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FF87E0007FE1F80008E000003800281D57C2700D609C21D881043F284C0020B65514030C8D62973109942A12DF3F019FFC7FC007FF1FF0008E000003800281D57C28E0D609C21D881043F284C0020B65514030C8D62973109942A12DF3F015DDC77C007771DF0008E8000038002800D940001400001D57C4C00D609C21D881043F284C0020B65514030C8D62973109942A12DF3F015DFC7FC0077F1FF0008E8000038002800D940001400001D57C4D00D609C21D881043F284C0020B65514030C8D62973109942A12DF3F015DFC7FC0077F1FF0008E8000038002800D9400014000000420709C00000023071340000002006013C04D2900000058080420210FE600000BE8001F00152018003800080E0B00E000C062138038003800301F000410000000072A68000C00004B2CA001A55145C0001C002C00000010020046AC18081C8494989CA3FC00000000501806CAF0380C000C03540BC0E0068200')
	--exec('ue_param id='..i..' ue_nr_capabilities=E9A01000077F0240381684C080208350000120931600098350D0026C030E7CC31E50B038260500623825506C4ED608C21A08107CA13000B2D931543439F11C7A067D813E31CF9863CA1607038782E000000038000000046000001C0A83626EB04610D04083E509800596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C170004F001C0013C0023000000E0541F11B582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F8000000FE00000011800000702A0F883AC1184341020F942600125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000008C00000381D06C28C0D608C21A08107CA13000B2D931543439F11C7A067D813E31CF9863CA1607038782E000960038002580046000001C0A83E0DEB04610D04083E509800496C98AA0A1CF88E3C639F30C7942C0E070F027F4000001FD00000023000000E0541F063582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F8000000FE00000011800000702A0F80DAC1184341020F942600125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000008C00000381507C02D608C21A08107CA1300092D931541439F11C78C73E618F28581C0E1E04FE0000003F800000046000001C0A83E00EB04610D04083E509800496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC00000023000000E0541F003582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813FB000000FEC0000011800000702A0D85FAC1184341020F942600165B262A86873E238F40CFB027C639F30C7942C0E070F09C00120007000480008C00000381506C27D608C21A08107484C0028B65515090E7D033EC09F18E7CC31E50B0381C3C0B801E5800E007960011100001B280002800002A0D84BAC1184341020F942600165B262A86873E238F40CFB027C639F30C7942C0E070F09C00100007000400008C00000381507C13D608C21A08107CA1300092D931541439F11C78C73E618F28581C0E1E04FE0000003F800000046000001C0A83E06EB04610D04083E509800496C98AA0A1CF88E3C639F30C7942C0E070F027C0000001F000000023000000E0541F02F582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F0000000FC00000011800000702A0F80FAC1184341020F942600125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000008C00000381507C04D608C21A08107CA1300092D931541439F11C78C73E618F28581C0E1E04FE0000003F800000046000001C00308389A00000160E140400010107507850001C460000041204048020081282A0560DC1F03E8DD805052800002101C089B1CF870A74ED8E7C380C1FF830070318C7E85E0000E000A070500603009001C0301401C0F81400800000004000008020000080100000600800004004000028020000180100000E00800008004000048020000280A654DE54D6065606D60A560CD64CD652D646D602560450301000009652504000065949410000296525040000E594901000049652404000165949010000696524040001E594901000051652404000225949010000996524040002A5949010000B9652402D4AAAE9555503AAA0B1541A2A9545D2A8AA4D154A62A91C55018AA05145C0007402A8140E070381C0A050281C0E0004001002004002004008404008010100600C6A80C0905091902280')
    -- exec('ue_param id='..i..' ue_nr_capabilities=E1A2FC0007D7E0240381F21D7FFE0E3C9A78F7FFF001A001007F3C4801400626D53D55FFD54F557FF550003009AAAAA9AAAAA80840E268000000440E0100000005B41E000000000000045400000000000005400000400801CA0228')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
ALL_QoS_FLOWS_IDs = '1,2,3,4,5,6,7,8,11,12,13,14,15,16'
DEFAULT_NON_GBR_5QI = '9'
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
                [8] = '212'}

NON_GBR_5QIs = {[11] = '5',
                [12] = '6',
                [13] = '7',
                [14] = '8',
                [15] = '9',
                [16] = '128',
                [17] = '170',
                [18] = '254'}

-- 5QI1/2/3 - udp,  else - tcp
for id, gbr_5qi in pairs(GBR_5QIs) do
    exec('set_qosflow id='..id..' 5qi='..gbr_5qi..' gfbr_ul=1000 gfbr_dl=1000 mfbr_ul=9000 mfbr_dl=9000 priority=15 qos_flow_type=gbr ue=all')
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
exec('sim_debug_log level=0 uec=1')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace uec=1 protocol=rrc on')
exec('set_log log_to_file=on')
exec('cfg_end')
sleep(1)
exec('start version_check=off')
