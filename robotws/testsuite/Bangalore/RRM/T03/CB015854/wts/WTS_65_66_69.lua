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
local PROXY3_SERVER_IP="10.0.2.91"
local ADDITIONAL_NGU_ADDR="10.0.1.200"
local AMF_NG_ADDR="10.0.1.1"
local AMF2_NG_ADDR="10.0.1.102"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local DAEMON_PORT="22222"

local PDN_IP="4.7.254.208"

require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.90')
os.execute('sudo ifconfig eth4:gNB3_PR2 add 10.0.2.91')
os.execute('sudo ifconfig eth3:ADD_NGU add '..ADDITIONAL_NGU_ADDR)

local SA_UE_CAPABILITIES_TDD="E9A0100007C3F0240381684C080208350000120931600098350D0026C030E7CC31E50B038260500623825506C4ED608C21A08107CA13000B2D931543439F11C7A067D813E31CF9863CA1607038782E000000038000000046000001C0A83626EB04610D04083E509800596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C170004F001C0013C0023000000E0541F11B582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F8000000FE00000011800000702A0F883AC1184341020F942600125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000008C00000381D06C28C0D608C21A08107CA13000B2D931543439F11C7A067D813E31CF9863CA1607038782E000960038002580046000001C0A83E0DEB04610D04083E509800496C98AA0A1CF88E3C639F30C7942C0E070F027F4000001FD00000023000000E0541F063582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F8000000FE00000011800000702A0F80DAC1184341020F942600125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000008C00000381507C02D608C21A08107CA1300092D931541439F11C78C73E618F28581C0E1E04FE0000003F800000046000001C0A83E00EB04610D04083E509800496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC00000023000000E0541F003582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813FB000000FEC0000011800000702A0D85FAC1184341020F942600165B262A86873E238F40CFB027C639F30C7942C0E070F09C00120007000480008C00000381506C27D608C21A08107CA13000B2D931543439F11C7A067D813E31CF9863CA1607038784E000120038000480046000001C0A83612EB04610D04083E509800596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C2700040001C001000023000000E0541F04F582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F8000000FE00000011800000702A0F81BAC1184341020F942600125B262A82873E238F18E7CC31E50B0381C3C09F00000007C00000008C00000381507C0BD608C21A08107CA1300092D931541439F11C78C73E618F28581C0E1E04FC0000003F000000046000001C0A83E03EB04610D04083E509800496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC00000023000000E0541F013582308682041F284C0024B64C55050E7C471E31CF9863CA16070387813F8000000FE000000118000007000C20E26800000583850100004041D41E1400071180000104810120080204A0A81583707C0FA37601414A0000084070226C73E1C29D3B639F0E0307FE0C01C0C631FA1780003800281C140180C02400700C0500503E050020000000100000200800002004000018020000100100000A0080000600400003802000020010000120080000A02995379535819581B582958335933594B591B5809581140C04000025949410000196525040000A594941000039652404000125949010000596524040001A59490100007965240400014594901000089652404000265949010000A96524040002E594900B52AABA555540EAA82C55068AA55174AA2A93455298AA47154062A8145170001D00AA050381C0E07028140A070380010004008010008010021010020040401803DAAB03024142464265AD4A200016F64A500002E80"
local SA_UE_CAPABILITIES_FDD="E1A01000017F0240381780D0B02083540001200500000201808367130F850D0026C020FFCC31E50B038260500622814014C600141F06F586368E9315047F2CA49942600105B260901831E31FF9863CA160703878093FF4FFC08006000000000E0D80000000210780D88F2E0A00F021F00241000000800E0250001000009652400340628B80007801A010080000000000200400CD54025004FAAAAAAAA22F0380C000C029440000DEC0"

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,0 plmn=311:489,311:402')
exec('set_amf_region id=2 tac_list=7627107,100,200,0 plmn=311:402')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('set_amf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes+null nea=snow3g+zuc+aes+null ims_voice_3gpp=on intra5gs_data_forwarding=on')
exec('amf_param id=2 full_nas_auth=on nia=snow3g+zuc+aes+null nea=snow3g+zuc+aes+null ims_voice_3gpp=on intra5gs_data_forwarding=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_additional_ip='..ADDITIONAL_NGU_ADDR)

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x05 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x06 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:402 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1 plmnList=311:402')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=on sa_ho=ng_based sib1_period=40 measEvent=A3 srb1_rlc_sn_field_size=size_12 ng_data_forwarding_HO=on gbr_data_forwarding_HO=on')

exec('set_cell id=1 gnb=3 pci=2:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..DAEMON_PORT..' gscn=7854 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('set_cell id=2 gnb=3 pci=2:2 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY3_SERVER_IP..':'..DAEMON_PORT..' gscn=7842 nr_arfcn=633000:633000 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_cell_param id=1 gnb=3 enable_anr=off neighbor_pci=16:2')
exec('gnb_cell_param id=2 gnb=3 enable_anr=off neighbor_pci=16:2')

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')
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
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD)
end
--UE SA cell 3
for i=31,UE_COUNT_TDD do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
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
ALL_QoS_FLOWS_IDs = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,19'
DEFAULT_NON_GBR_5QI = '69'
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
                [8] = '212',
                [9] = '65',
                [10] = '66'}

NON_GBR_5QIs = {[11] = '5',
                [12] = '6',
                [13] = '7',
                [14] = '8',
                [15] = '9',
                [16] = '128',
                [17] = '170',
                [18] = '254',
                [19] = '69'}

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

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1-2 qos_flows='..ALL_QoS_FLOWS_IDs..' qos_rules='..ALL_QoS_FLOWS_IDs)

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
exec('sim_trace uec=1 protocol=nr_rrc,nas,rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace enb=3 protocol=ng,xn,x2,s1 on')
exec('set_log log_to_file=on')
exec('cfg_end')
sleep(1)
exec('start version_check=off')

