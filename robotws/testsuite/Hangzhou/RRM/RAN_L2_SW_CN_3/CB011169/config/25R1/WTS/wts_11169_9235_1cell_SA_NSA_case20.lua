-- Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT=22222
GNB_NG_ADDR="10.0.11.10"
GNB_XN_ADDR="10.0.12.10"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.11.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="10.12.2.1"

EDAEMON_PORT="22222"

--Variables for NSA configuration
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.210"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.10"
GNB_X2U_ADDR="10.0.1.210"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP1="4.7.254.208"
PDN_IP2="4.7.254.209"
PDN_IP2="4.7.254.210"
PDN_IP2="4.7.254.211"
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=1400:19400 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')
--exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=$DAEMON_IP:12219|$DAEMON_IP:8889 earfcn=1400:19400 tdd_cell=on mandatory_for_activation=off')
--exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')


----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x1:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_XN_ADDR..' x2u='..GNB_X2U_ADDR..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=280 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0,280 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
--Cell 1 UEs:
FIRST_UE_SA_CELL_1 = 1
END_UD_SA_CELL_1 = 120
FIRST_UE_NSA_CELL_1 = 121
END_UE_NSA_CELL_1 = 160



IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700

QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UD_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A05000574F7A03560003064002C1001018093170019C3D09003120D0098040623805506C4DD608C21A0810748240516CAA2A121CFA067D813E31CF9863CA160703878170005F001C0017C00122003650000500000741B0A303582308682041D2090145B2A8A84873E819F604F8C73E618F28581C0E1E05C0017C0070005F00048800D940001400000507C46D608C21A0810788240416CAA2A021CF8C73E618F28581C0E1E027F0000001FC0000000258389A100004201D61E2680061340000101700101343C0064050226CB5E3C2893B65AF1C7A09C01F00140018080A00E06012803800301F004010000000080040000000E54D00010000001B010034AAA848036006814000100021010020040400800000802002254020204840')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end
--smallbwp backup
--E1A01000074E7A031E0003C420007820020301260C800087848018806804C060180E01D51B0A3582028680965944C3400F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8002C4003B7000080000000700008000000002A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4DD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA36276B04050D012CB28986801EB608080838778E1C830E0008193C7D54000014000005880076E000100000000E000100000000000841C4D0000000020268B80003804044F617001800140E0A00E06013003800341F000000000000072868000800004B2CA801A51542C007000B00000004008011AB130001020304050607080B101112131921252627284A41A80
--for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do
    --exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
    --exec('ue_param id='..UEID..' ue_nr_capabilities=E120700047D0FFB17DE8E6BC2A003406939F3489E7C007006201F01F0080FC002DBCE00001EF7ADC341914083800001D7038145B25AA05813E439F40478C73E618F28581C0E1E0CDE700200F7BD6E1A0C8A041C00000EB81C0A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0E0516C96A81604F90E7D011E31CF9863CA1607038783779F13403DEF5B8683228107000003AE07028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC38803650000500000379C01003DEF5B8683228107000003AE07028B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00C01EF7ADC341914083800001D7038145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB81C0A2D92D502C09F21CFA023C639F30C7942C0E070F066F3809807BDEB70D0645020E0000075C0E0516C96A81604F90E7D011E31CF9863CA1607038783379C09403DEF5B8683228107000003AE07028B64B540B027C873E808F18E7CC31E50B0381C3C19BCE04E01EF7ADC341914083800001D7038145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB81C0A2D92D502C09F21CFA023C639F30C7942C0E070F066F3826007BDEB70D0645020E0000075C0E0516C96A81604F90E7D011E31CF9863CA16070387837F00000026007C005638280381F84800E07C003968000038000394340006000010600000F288284801C003C00D40A8001020303898081858808890C860C0D8FA092931394122A40 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801')
	--exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
--end

for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1209000575F7A13160003C12016080080C0498B800CE1E81826C830E7CC31E50B03826010188000D51B137582308682041D2011F5B262AC6873E238F40CFB027C66471E439F40CFB027D473E618F28581C0E1E2E000BE0038002F80012403800D940001400001D46C28C0D608C21A0810748047D6C98AB1A1CF88E3D033EC09F1991C790E7D033EC09F51CF9863CA160703878B8002F800E000BE0004800E07A0700260F00440603E1380200000001000002008000000040000080200000801000006008000040040000280200100401004000030020000180100000E008000070040020000000800008004002018060080000900400005002001010040040020380E0080000B925002060185C92800030B92500606018060185C928020300C030B92500C060180601806018061724A0100C0300C0300C2E49403818060180601806018061704A0000C2E494000189C928010300C4E49401018060189C12800031392500E060180601806018060189C928030300C0300C4E494000181C928070300C0300C0300C0300C0E4940181806018060704A0000C0C0100001A06F2A6B2A6B052B032B036B066B296B266B016B012B022B236B748C15A0682000012CA4A080000CB29202000052CA4A080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB2928200818064B29282000192CA4A062955552A8BA55574AA2A82C55038AA0D154A62A93455018AA051548EAABB500C5F027A05028140E070381C0A05028140A050381C0E07038140A05028140A05028140A05028140A05028140A050281C002540C00020406080C0E8400 dual_conn=eutra_nr ue_eutra_nr_capabilities=A107C18C2604018280389A000000883982C080389A100004883D86C0801010713400309A0002022E442E6130220E2680061340006442E6130200E1400061340008441C8160441C2800000A4400A026C0280041A01420D1274E85B1CF870A742D8E7C38D3A7429DB1CF87127429DB1CF87127429DB1CF870A742D8E7C301005100008020200C000080300810001004040700418000802000200008030080200C0008000601010060100401800100008020200C0200803000100018040401804')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


-------------------------------------------------------------------------------
--COMMON CONFIGURATION
--------------------------------------------------------------------------------------------------
--exec('set_qosflow id=1 5qi=6 default=on')
--exec('set_qosflow id=2 5qi=5')
--exec('set_qosflow id=3 5qi=1')
--exec('set_qosflow id=4 5qi=2')
--exec('set_qosrule id=1 proto=udp  qos_flow=1')
--exec('set_qosrule id=2 proto=tcp  qos_flow=2')
--exec('set_qosrule id=3 proto=udp qos_flow=3')
--exec('set_qosrule id=4 proto=udp qos_flow=4')
--exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3,4 snssai=0x01:0xD143A5 default=on ue=all amf=1')
--qosflow_set id=4  5qi=2   gfbr_ul=30720  gfbr_dl=30720  mfbr_ul=30720  mfbr_dl=30720  qos_flow_type=gbr ue=all

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
--exec('set_qosrule id=1 proto=udp  qos_flow=1')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp  qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')
exec('nwslice_set id=2 snssai=0x01:0xD143A6 ue=1 amf=1')
exec('nwslice_set id=3 snssai=0x01:0xD143A7 ue=1 amf=1')
exec('nwslice_set id=4 snssai=0x01:0xD143A8 ue=1 amf=1')
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 sgw=1')
exec('sim_debug_log level=2 app_type=l2nrt')
exec('sim_debug_log level=2 app_type=l2rt')
exec('sim_debug_log level=2 app_type=ueproxy')
exec('sim_debug_log enable_events_date=on')
exec('sim_debug_log enable_debug_date=on')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
