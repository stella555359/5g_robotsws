-- Copyright (c) 2019 Nokia. All rights reserved.

---------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP="10.0.2.1"
SERVER_IP="10.0.2.1"
DAEMON_PORT="22222"
GNB1_NG_ADDR="10.0.1.2"
GNB2_NG_ADDR="10.0.1.3"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

-- Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB1_S1U_ADDR="10.0.1.112"
GNB2_S1U_ADDR="10.0.1.113"

ENB1_X2_ADDR="10.0.1.137"
GNB1_X2_ADDR="10.0.1.2"
GNB2_X2_ADDR="10.0.1.3"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"

PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"

SA_UE_CAPABILITIES="E9A09000575F5A13160003C52000160BF170019C2EB42C013641873E618F28581C13018062380DDC6C4CC0D608C21A081078844006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0BFFFFF800FFFFFE000D80000703A0D85155AC1184341020F108800CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC7FE003FB1FF8003600001C0EA3626D56B04610D04083C4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05FFFFFC007FFFFF0006C0000381D06C46AAD608C21A08107884400656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001B00000E0771B00B03582308682041E211001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFF800003FFE000003600001C0A83620EB04610D00083C4220032B64C55890E7D813E238F0091C790E7D473E618F28581C0E1E13FB000000FEC000000D80000702A8D837AC1184341020F108800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17FFC00001FFF000001B00000E006AC3C4C000E140000000B02B17130003850001C4D000004160563E26000706C00388C001C4D00000E160561E26000713000000858158B898001C4D000E140000040B02B0F0A00038500000242C0AC5C4D000E26800711800005058158789A001C4D000018160401E23000710400001AC5C46000E20800710400002858158F804001C1B000E23000710400005858158788C001C4600000C160561E0D800713400004058100D011A026404D8051006E00140411B4002941B0A244D8E7C38912244D8E7C38D0204081B1CF810A040D8E7C08902040D8E7C0850206C73E044810206C73E0428103639F0214489B1CF871224489B1CF871A0408103639F0214081B1CF810A040D8E7C00054346318C6318C6318C607EAAAAA83E000F000A070500703009401C0018090010180F82800800000004000008020000080100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C00400201004000008020080203B953591B594358195833582B594B5933580B581B58095811583B5953582940D04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240374AAAE91D55288BA55154162A82C55068AA531549A2A80C55028AA4D5541E2A95450F002F012A05028140A05028140A05028140A05028140A05028006040400801010020042020040080801002201002004040080101002004202044058080D014201002004040080101002004402044058080D014020340504040880B0102202C602004008081101602044058080100210102202C0400801080801002020040088040080101002004040880B18080D0140204405808110160203405040400801010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05955555554E0B40"

NSA_UE_CAPABILITIES="E1201000014F5E0302C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C203141F11B586368E9315047F2CA4D94220020B64C1203063C63FF30C7942C0E070F0113804E0771B00B03582308682041E211001B5B062B1A1CF88E3D033EC09F1891C790E7D473E618F28581C7E1E02FFF800003FFE000003600001C0A83620EB04610D04083C422002CB24C55890E7D813E238F0091C790E7D473E618F40E1F3FB000000FEC000000D80000702A89837AC11843410001108800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C1FFF000007FFC000006C0000381DC6C4CC0D608C01A0800011001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFFFFE003FFFFF8003600001C0E82614556B04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0FEC7FE003FB1FF8003600001C0EA3626D56B04610D04083C4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05FFFFFC007FFFFF0006C000038001C20C0468005010600DC04C805101379343E02C8200000148200000548200000949280000D392400002292400002A01781B7953781B5BAC646D650D01C1000009652504000065949410000296525040000E594941000049652524000154B292920000CA594941000079652501F40F2E9565D03ABA55934AB22BB9148F2A94650F000F0034020100000010"

EUTRAN_CAPABILITIES="A10186102C0C0388C000000888160641C460000024440B0320E0D800002222058190706C0000191102C0C03804000010888160641C0200000A4440B0300E1400000622205819070A00000391102C0C03898000020888160641C4C0000124440B0300E2680000A22205819071340000591006007011A00DC00280510132026900B080004020200C01840004010100600C200010080803006100010040401803080004020200C01840004010100600C2000100808020041000100404010020800040202008010400040101004008200010080802004100010040401002"

----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 eq_plmn=250:255 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on ims_voice_3gpp=on voice_fallback=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc indirect_data_forwarding=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

----------------------------------------------------------------------------------------------------
--GNB1 CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB1_S1U_ADDR..' x2='..GNB1_X2_ADDR..':36422 ng='..GNB1_NG_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145000:156000 mandatory_for_activation=off gscn=1947')
exec('set_cell id=2 gnb=2 pci=17:1 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=349400:368400 mandatory_for_activation=off gscn=4605')
exec('set_cell id=3 gnb=2 pci=17:2 tac=200 nrci=0x03 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=650000:650000 mandatory_for_activation=off gscn=8019')
exec('set_cell id=4 gnb=2 pci=18:0 tac=200 nrci=0x04 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=645000:645000 mandatory_for_activation=off gscn=7967')

----------------------------------------------------------------------------------------------------
--GNB2 CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=external plmn=311:489 s1u='..GNB1_S1U_ADDR..' x2='..GNB2_X2_ADDR..':36422 ng='..GNB2_NG_ADDR..' gnb_id=0x02:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=5 gnb=3 pci=18:1 tac=200 nrci=0x05 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145000:156000 mandatory_for_activation=off gscn=1950')
exec('set_cell id=6 gnb=3 pci=18:2 tac=200 nrci=0x06 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=136100:126900 mandatory_for_activation=off gscn=1584')
exec('set_cell id=7 gnb=3 pci=19:0 tac=200 nrci=0x07 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=635666:635666 mandatory_for_activation=off gscn=7870')
exec('set_cell id=8 gnb=3 pci=19:1 tac=200 nrci=0x08 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=640666:640666 mandatory_for_activation=off gscn=7922')
exec('set_cell id=9 gnb=3 pci=19:2 tac=200 nrci=0x09 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=346000:428000 mandatory_for_activation=off gscn=5350')
exec('set_cell id=10 gnb=3 pci=20:0 tac=200 nrci=0x10 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=650000:650000 mandatory_for_activation=off gscn=8019')

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
----------------------------------------------------------------------------------------------------
local UE_COUNT_SA=100
local UE_COUNT_NSA=200
for i=1,UE_COUNT_SA do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645'..(i+399)..' enb=2 cell=2')
    exec('ue_param id='..i..' ue_nr_capabilities='..SA_UE_CAPABILITIES)
end

for i=101,UE_COUNT_NSA do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:021645'..(i+399)..' enb=1 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities='..NSA_UE_CAPABILITIES..' dual_conn=eutra_nr ue_eutra_nr_capabilities='..EUTRAN_CAPABILITIES)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
ALL_QoS_FLOWS_IDs = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,39,50,51'
DEFAULT_NON_GBR_5QI = '9'
USER_DEFINED_NON_GBR = '170'
UDP_5QIs = { ['1']='udp',
             ['2']='udp',
             ['3']='udp',
             ['5']='udp',
             ['6']='udp'
            }

-- mapping in GBR_5QIs and NON_GBR_5QIs reflects mapping in DevKr/CB008379/resources/CB008379-common_keywords.robot in opposite direction

GBR_5QIs = {    [1] = '1',
                [2] = '2',
                [3] = '3',
                [4] = '4',
                [5] = '65', -- Voice, PTT
                [6] = '66', -- Voice, PTT
                [7] = '67', -- MC video
                [8] = '71',
                [9] = '72',
                [10] = '73', -- Unsupported
                [11] = '74', -- Unsupported
                [12] = '75', -- Unsupported
                [13] = '76',
                [14] = '88',
                [15] = '89',  -- Unsupported DC-GBR
                [16] = '90',  -- Unsupported DC-GBR
                [17] = '128',
                [18] = '212',
                [19] = '254',
            }

NON_GBR_5QIs = {[31] = '5',
                [32] = '6',
                [33] = '7',
                [34] = '8',
                [35] = '9',
                [36] = '10',
                [37] = '11',
                [38] = '68',
                [39] = '69',
                [40] = '70',
                [41] = '77', -- Unsupported
                [42] = '78', -- Unsupported
                [43] = '79', -- Unsupported
                [44] = '80',
                [45] = '81', -- Unsupported
                [46] = '91',
                [47] = '92',
                [48] = '100',
                [49] = '122',
                [50] = '126',
                [51] = '127'
            }

-- 5QI1/2/3 - udp,  else - tcp
for id, gbr_5qi in pairs(GBR_5QIs) do
    exec('set_qosflow id='..id..' 5qi='..gbr_5qi..' gfbr_ul=1000 gfbr_dl=1000 mfbr_ul=1000 mfbr_dl=1000 priority=15 qos_flow_type=gbr ue=all')
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

exec('set_nwslice id=1 snssai=0x1:0xD143A5 default=on amf=1 qos_flows='..ALL_QoS_FLOWS_IDs..' qos_rules='..ALL_QoS_FLOWS_IDs)

local GW_COUNT=100
for i=1,GW_COUNT do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
    exec('amf_ue_ics_param id=1 ue='..i..' core_network_assistance_info=on ue_identity_index_value='..i..' ue_specific_drx=64 periodic_registration_update_timer=1:30secs plmn_id=311:489 tac_id=788')
end

local PDN_COUNT=100
for i=1,PDN_COUNT do
    exec('set_bearer id=2 ue='..(i+100)..' qci=9 pdn=1 ip=4.7.254.'..i..' default=on trf_type=internal')
    exec('set_bearer id=3 ue='..(i+100)..' qci=7 pdn=1')
    exec('set_bearer id=4 ue='..(i+100)..' qci=1 pdn=1 gbr_ul=256 gbr_dl=256 rlc_mode=um')
end

exec('uec_param id=1 srb_reordering_enabled=on')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')

----------------------------------------------------------------------------------------------------
-- Capacity and Performance Related Flag
exec('sim_param_set purge_buffer_on_full=on')
exec('amf_registration_param id=1 release_ue_tau_update=on')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled')
exec('sim_param_set ENABLE_MULTIPLE_L2NRT=on')
exec('sim_param_set TTI=3')

exec('debug_log level=4')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc,nr_rrc,x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace enb=1 protocol=x2 on')
exec('set_log log_to_file=on')
exec('cfg_end')
sleep(1)
exec('start version_check=off')