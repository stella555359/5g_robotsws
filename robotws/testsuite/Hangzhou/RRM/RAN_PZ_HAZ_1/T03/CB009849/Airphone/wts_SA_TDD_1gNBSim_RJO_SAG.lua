-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="10.0.2.1"
local SERVER_IP="10.0.2.1"
local DAEMON_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local DAEMON_PORT="22222"

local PDN_IP="4.7.254.208"

require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.90')

local SA_UE_CAPABILITIES_TDD="E9A09000575F5A13560003C5280016005000002018093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782E007FE0038002F8003600001C0A836016B04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB000000FEC000000D80000702A8D899AC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B00000E0541B06F582308682041E21100195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006C0000381546C4DD608C21A00000404400616C932A221CF88E3C831E819F604F8073E618F28581C0E1E0BD5555554F55555550D800007004961E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563E01000606C0C260184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C000385815878040018020004058158783600181B000485815878040018060005058158780C00181B0005858158B80400180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C030040606C001E160562E2600060080C0D800402C0AC7C4D000C01018060303600110B0201200DC0068099000A0268DA001D212851226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D07C001E00140E0A00E0601280380030120020301F048010000000080040000001000006008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29302000032CA48080001CB29202000092CA48080002CB293020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F143C00BC04A8140A05028140A05028140A05028140A05028140A0022101002004040080110080100202004008080100220100C014040080101002004602018028080600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C014040300501002004202018028080100210100C014040300508080600C02018030404030060100C014202018028080600A20100C01404030060100C014202018030080100220100200404008010100C014602004008080100202018028080600A20100200404030060100C018602004008080600A02018030080600A3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A"
local SA_UE_CAPABILITIES_FDD="E1A01000014F5E0302C0020940004820D9C4C3E142C01360107FE618F28581C13018062280C0298C00283E0DEB0C6D1D262A08FE59493283C0082D930480C18F18FFCC31E50B0381C3C049FFA7FE04003000000000706C00000001083C06C479343E00482000001001C04A0002000012CA4800680C50D001E0068040200000000000801002148140"

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------

exec('set_amf_region id=1 tac_list=7627107,100,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc intra5gs_data_forwarding=on ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=2:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..DAEMON_PORT..' gscn=7854 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_cell_param id=1 gnb=3 enable_anr=off neighbor_pci=16:2')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=on sa_ho=ng_based sib1_period=40 measEvent=A3 srb1_rlc_sn_field_size=size_12')

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')
----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--TDD_SA_UEID_Configuration
----------------------------------------------------------------------------------------------------
local UE_COUNT_TDD=40
local UE_COUNT_FDD=80
local GW_COUNT=255

--UE SA cell 1
for i=1,20 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD)
end
--UE SA cell 2
for i=21,30 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=2')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD)
end
--UE SA cell 3
for i=31,UE_COUNT_TDD do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=3')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD)
end

----------------------------------------------------------------------------------------------------------
--FDD_SA_UEID_Configuration
----------------------------------------------------------------------------------------------------------
--UE SA cell 4
for i=41,60 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=4')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD)
end
--UE SA cell 5
for i=61,70 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=5')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD)
end
--UE SA cell 6
for i=71,80 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=6')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD)
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
    exec('set_qosflow id='..id..' 5qi='..gbr_5qi..' gfbr_ul=6000 gfbr_dl=6000 mfbr_ul=9000 mfbr_dl=9000 priority=15 qos_flow_type=gbr ue=all')
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
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.0.'..i..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
----------------------------------------------------------------------------------------------------
exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('sim_debug_log level=0 uec=1')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace uec=1 protocol=rrc on')
exec('set_log log_to_file=on')
exec('cfg_end')
sleep(1)
exec('start version_check=off')