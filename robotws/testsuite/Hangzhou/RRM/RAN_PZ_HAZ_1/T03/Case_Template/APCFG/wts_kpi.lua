-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
SERVER_IP="10.0.2.1"
EDAEMON_IP="10.0.2.1"
EDAEMON_PORT="22222"

GNB_NG_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"

GNB_SIM_NG_ADDR="10.0.1.30"
GNB_SIM_XN_ADDR="10.0.1.31"
PROXY_SERVER_IP="10.0.2.80"
PROXY2_SERVER_IP="10.0.2.90"
AMF_NG_ADDR="10.0.1.1"
AMF2_NG_ADDR="10.0.1.102"
AMF3_NG_ADDR="10.0.1.103"
ADDITIONAL_NGU_ADDR="10.0.1.200"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

--NSA VARIABLES
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.112"
ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"
MME1_S1_ADDR="10.0.1.131"
SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"
ENB1_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.90')
os.execute('sudo ifconfig eth3:ADD_NGU add '..ADDITIONAL_NGU_ADDR)

----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' xp_management=on xp=10.0.1.1:32742 xpu=10.0.1.1:32742 x2='..ENB1_X2_ADDR..' x2u='..ENB1_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 bw=20MHz eci=0x1234601 pci=3:2 tac=222 proxy='..EDAEMON_IP..':12219|'..EDAEMON_IP..':8889 earfcn=300:18300 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
-- exec('mme_pool_area id=2 mmegi=2 plmn=311:489 tac_list=777,111,222,444,333,200')
-- exec('mme_pool_area id=3 mmegi=3 plmn=311:489 tac_list=777,111,222,444,333,200')
-- exec('set_mme id=1 ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1 pool=2:3 pool=3:4')
exec('set_mme id=1 ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..EDAEMON_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 gscn=7880 nr_arfcn=636666:636666')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,201,788,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
--exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_additional_ip='..ADDITIONAL_NGU_ADDR)

---------------------------------------------------------------------------------------------------
--GNB sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=7880 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE Capabilities
---------------------------------------------------------------------------------------------------
SA_UE_Capa="E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0"

NSA_UE_CAPABILITIES="E120700047D0FFB17DE8E6BC3A000D01A4E7CD2279F002400C403E03E0101F8005B79C00003DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783379C00803DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783379C06C03DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783779F13403DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA160703878293FE4FF8B10006CA0000A000006F3802007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3809807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3812807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3813807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3814007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3826007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F06FE0000005C007C005638280381F84800E07C003968000038000395340006000025949400F2AA685800E001E006A054000810181C4C040C2C4044486430606C7D0494989CA0915200"

NR_EUTRA_CAPABILITIES="A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801"

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
local UE_COUNT=40
local GW_COUNT=255
for i=1,UE_COUNT do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=21A000000109000800C4DAA2FFCBFF0110389A00000014DE000000000000045400000000000005400000400801022280')
end
for i=1,GW_COUNT do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

local UE_COUNT_NSA=140
local PDN_COUNT=40
for i=101,UE_COUNT_NSA do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:021645'..(i+399)..' enb=1 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities='..NSA_UE_CAPABILITIES..' dual_conn=eutra_nr ue_eutra_nr_capabilities='..NR_EUTRA_CAPABILITIES)
end
for i=1,PDN_COUNT do
    exec('set_bearer id=2 ue='..(i+100)..' qci=9 pdn=1 ip=4.7.254.'..i..' default=on trf_type=internal')
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
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows='..ALL_QoS_FLOWS_IDs..' qos_rules='..ALL_QoS_FLOWS_IDs)

exec('uec_param id=1 srb_reordering_enabled=on')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')

-- Capacity and Performance Related Flag
exec('sim_param_set purge_buffer_on_full=on')
exec('amf_registration_param id=1 release_ue_tau_update=on')
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled')
exec('sim_param_set ENABLE_MULTIPLE_L2NRT=on')
exec('sim_param_set TTI=3')

exec('debug_log level=4')
exec('sim_debug_log level=1 mme=1')
exec('sim_debug_log level=1 pgw=1')
exec('sim_debug_log level=1 uec=1')
exec('sim_debug_log level=1 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=rrc,nr_rrc,x2 on')
exec('sim_trace amf=1 protocol=ng on')
exec('set_log log_to_file=on')
exec('cfg_end')
exec('start version_check=off')