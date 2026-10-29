---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTAINER_IP="10.0.2.1"
local DAEMON_IP="10.0.2.1"
local SERVER_IP="10.0.2.1"
local DAEMON_PORT="10000"
local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

--local SA_UE_CAPABILITIES_TDD="E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C00000010020046AC500004080C1014181C202C4044484C648494989CA1192814A20001422502000180"
-- z VoNR
local SA_UE_CAPABILITIES_TDD="E1A00000074E5A031E000386200007824C1900010F0D000C40340260500603807546C28D6080A1A02596513130007AD8202020E1DE38720C38002064F1F57001FF001C007FC001E20001DB800040000000380004000000001546C4CD6080A1A02596513130007AD8202020E1DE38720C38002064F1F57001FF001C007FC001E20001DB800040000000380004000000001546C4DD6080A1A02596513130007AD8202020E1DE38720C38002064F1F57001FF001C007FC001E20001DB800040000000380004000000001546C4ED6080A1A02596513130007AD8202020E1DE38720C38002064F1F55000005000001E20001DB8000400000003800040000000000210713400000000809A4A000001C020227B138000C000A070500703009801C001A0F8000000000000395340004000025965400D2AAA260003800580000002004008D58A00008101820283038405880889098C9092931394232522F0380C000C029440002844A0400030"
local SA_UE_CAPABILITIES_TDD_NO_RRCINACT="E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C00000010020044AC500004080C1014181C202C4044484C648494989CA1192814A20001422502000180"
local SA_UE_CAPABILITIES_FDD="E1A01000014F5E0302C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C600141F11B586368E9315047F2CA4994220020B64C1203063C63FF30C7942C0E070F0133B0EC33B0EC01000C000000001C4600000000420C046E4D0F80720800000520800001520800002524A000034C02E06DE46D6E900504000025949410000196525040000A594941000039652504000125949490000552CA4A02681D5D23ABA15534AAA2BB503C003C00D0080400000000001002004289A9440002844A0400030"
local SA_UE_CAPABILITIES_FDD_NO_RRCINACT="E1A01000014F5E0302C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C600141F11B586368E9315047F2CA4994220020B64C1203063C63FF30C7942C0E070F0133B0EC33B0EC01000C000000001C4600000000420C046E4D0F80720800000520800001520800002524A000034C02E06DE46D6E900504000025949410000196525040000A594941000039652504000125949490000552CA4A02681D5D23ABA15534AAA2BB503C003C00D0080400000000001002004089A9440002844A0400030"
local SA_UE_CAPABILITIES_FDD_NO_REDCAP="E1A01000014F5E0302C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C600141F11B586368E9315047F2CA4994220020B64C1203063C63FF30C7942C0E070F0133B0EC33B0EC01000C000000001C4600000000420C046E4D0F80720800000520800001520800002524A000034C02E06DE46D6E900504000025949410000196525040000A594941000039652504000125949490000552CA4A02681D5D23ABA15534AAA2BB503C003C00D0080400000000001002004289A9440002844A0400030"
--local SA_UE_CAPABILITIES_TDD_NO_REDCAP="E1A00000074E5A031E000382A003C1260C80008783803100D0098040603807546C28D6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B133582028680965944C1C07AD8202020E1DE38720C38002064F1F57001FF001C007FC000E201DB800040000000380004000000001546C4DD6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B13B582028680965944C1C07AD8202020E1DE38720C38002064F1F55000005000000E201DB8000400000003800040000000000210713400000000809A16003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA84801C002C000000100200462C500004080C1014181C202C4044484C648494989CA11928"
-- z VoNR
local SA_UE_CAPABILITIES_TDD_NO_REDCAP="E1A00000074E5A031E000386200007824C1900010F0D000C40340260500603807546C28D6080A1A02596513130007AD8202020E1DE38720C38002064F1F57001FF001C007FC001E20001DB800040000000380004000000001546C4CD6080A1A02596513130007AD8202020E1DE38720C38002064F1F57001FF001C007FC001E20001DB800040000000380004000000001546C4DD6080A1A02596513130007AD8202020E1DE38720C38002064F1F57001FF001C007FC001E20001DB800040000000380004000000001546C4ED6080A1A02596513130007AD8202020E1DE38720C38002064F1F55000005000001E20001DB8000400000003800040000000000210713400000000809A4A000001C020227B138000C000A070500703009801C001A0F8000000000000395340004000025965400D2AAA260003800580000002004008D58A00008101820283038405880889098C9092931394232520F0380C000C02"

--Variables for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP101="4.7.254.101"

local NSA_UE_CAPABILITIES_TDD="E120700047D0FFB17DE8E6BC3A000D01A4E7CD2279F002400C403E03E0101F8005B79C00003DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783379C00803DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783379C06C03DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783779F13403DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA160703878293FE4FF8B10006CA0000A000006F3802007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3809807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3812807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3813807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3814007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3826007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F06FE0000005C007C005638280381F84800E07C003968000038000395340006000025949400F2AA685800E001E006A054000810181C4C040C2C4044486430606C7D0494989CA0915200"
local NSA_UE_CAPABILITIES_FDD="E1201000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298400283E236B0C6D1D262A08FE5949B28340105B260901831E31FF9863CA160703878089C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D03CBA559740EAE9564D2AC8AEE40B003C00D008040000004"
local NR_EUTRA_CAPABILITIES_TDD="A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801"
local NR_EUTRA_CAPABILITIES_FDD="A10181102C0C0388C000000888160641C460000024400401C0462002100008040401803080008020200C0180"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7853 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

--add ims_voice_3gpp support
--exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
NUMBER_OF_REDCAP_UES_SA_TDD_CELL_1=10
NUMBER_OF_REDCAP_UES_SA_TDD_CELL_2=5
NUMBER_OF_UES_SA_TDD_CELL_1=10
NUMBER_OF_REDCAP_UES_SA_FDD_CELL_3=10
NUMBER_OF_REDCAP_UES_SA_FDD_CELL_4=5
NUMBER_OF_UES_SA_FDD_CELL_4=5
NUMBER_OF_UES_NSA_TDD_CELL_1=10
NUMBER_OF_UES_NSA_TDD_CELL_2=10
NUMBER_OF_UES_NSA_FDD_CELL_3=10
NUMBER_OF_UES_NSA_FDD_CELL_4=10

---------------------------------------------------------------------------------------------------
--TDD_SA_UEID_Configuration
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_REDCAP_UES_SA_TDD_CELL_1 do
     local ue_id_aligned
     if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
     elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
     end
     print(ue_id_aligned)

     exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr red_cap=true enb=2 cell=1')
     exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD..' nr_usage_setting=voice_centric')
     exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.0.'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=11,10+NUMBER_OF_UES_SA_TDD_CELL_1 do
     exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null suci=0:311:489:0000:0:0:0216454'..ue_id..
         ' mode=nr enb=2 cell=1')
     exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD_NO_REDCAP..' nr_usage_setting=voice_centric')
     exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.0.'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=21,20+NUMBER_OF_REDCAP_UES_SA_TDD_CELL_2 do
     exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null suci=0:311:489:0000:0:0:0216454'..ue_id..
         ' mode=nr red_cap=true enb=2 cell=1')
     exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD_NO_RRCINACT)
     exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.0.'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--FDD_SA_UEID_Configuration
---------------------------------------------------------------------------------------------------

for ue_id=51,50+NUMBER_OF_REDCAP_UES_SA_FDD_CELL_3 do
     exec('set_ue simulated id='..ue_id..
         ' uec=1 release=17 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null suci=0:311:489:0000:0:0:0216454'..ue_id..
         ' mode=nr red_cap=true enb=2 cell=3')
     exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD)
     exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.0.'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=61,60+NUMBER_OF_UES_SA_FDD_CELL_4 do
     exec('set_ue simulated id='..ue_id..
         ' uec=1 release=17 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null suci=0:311:489:0000:0:0:0216454'..ue_id..
         ' mode=nr enb=2 cell=3')
     exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD_NO_REDCAP)
     exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.0.'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
for ue_id=71,70+NUMBER_OF_REDCAP_UES_SA_FDD_CELL_4 do
     exec('set_ue simulated id='..ue_id..
         ' uec=1 release=17 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null suci=0:311:489:0000:0:0:0216454'..ue_id..
         ' mode=nr red_cap=true enb=2 cell=3')
     exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD_NO_RRCINACT)
     exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.0.'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--TDD_NSA_UEID_Configuration
---------------------------------------------------------------------------------------------------

for ue_id=1,NUMBER_OF_UES_NSA_TDD_CELL_1 do
     local ue_id_aligned
     local imsi_prefix = '311:489:216454'
     local imsi
     if (ue_id<10) then
          ue_id_aligned = '0'..ue_id
          imsi = imsi_prefix..'0'..ue_id
     elseif (ue_id>=10 and ue_id<100) then
          ue_id_aligned = ue_id
          imsi = imsi_prefix..ue_id
     end

     exec('set_ue simulated id=1'..ue_id_aligned..
          ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
          ' nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g'..
          ' imsi='..imsi)
     exec('ue_param id=1'..ue_id_aligned..
          ' ue_nr_capabilities='..NSA_UE_CAPABILITIES_TDD..' dual_conn=eutra_nr'..
          ' ue_eutra_nr_capabilities='..NR_EUTRA_CAPABILITIES_TDD)
     exec('set_bearer id=2 ue=1'..ue_id_aligned..
          ' qci=9 pdn=1 ip=4.7.254.1'..ue_id_aligned..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
     exec('set_pdu_gateway id=1'..ue_id_aligned..' ue_nat_ip=72.23.0.1'..ue_id_aligned..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=21,20+NUMBER_OF_UES_NSA_TDD_CELL_2 do
     local imsi_prefix = '311:489:216454'
     local imsi = imsi_prefix..ue_id

     exec('set_ue simulated id=1'..ue_id..
          ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
          ' nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g'..
          ' imsi='..imsi)
     exec('ue_param id=1'..ue_id..
          ' ue_nr_capabilities='..NSA_UE_CAPABILITIES_TDD..' dual_conn=eutra_nr'..
          ' ue_eutra_nr_capabilities='..NR_EUTRA_CAPABILITIES_TDD)
     exec('set_bearer id=2 ue=1'..ue_id..
          ' qci=9 pdn=1 ip=4.7.254.1'..ue_id..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
     exec('set_pdu_gateway id=1'..ue_id..' ue_nat_ip=72.23.0.1'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--FDD_NSA_UEID_Configuration
---------------------------------------------------------------------------------------------------

for ue_id=51,50+NUMBER_OF_UES_NSA_FDD_CELL_3 do
     local imsi_prefix = '311:489:216454'
     local imsi = imsi_prefix..ue_id

     exec('set_ue simulated id=1'..ue_id..
          ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
          ' nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g'..
          ' imsi='..imsi)
     exec('ue_param id=1'..ue_id..
          ' ue_nr_capabilities='..NSA_UE_CAPABILITIES_FDD..' dual_conn=eutra_nr'..
          ' ue_eutra_nr_capabilities='..NR_EUTRA_CAPABILITIES_FDD)
     exec('set_bearer id=2 ue=1'..ue_id..
          ' qci=9 pdn=1 ip=4.7.254.1'..ue_id..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
     exec('set_pdu_gateway id=1'..ue_id..' ue_nat_ip=72.23.0.1'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=71,70+NUMBER_OF_UES_NSA_FDD_CELL_4 do
     local imsi_prefix = '311:489:216454'
     local imsi = imsi_prefix..ue_id

     exec('set_ue simulated id=1'..ue_id..
          ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
          ' nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g'..
          ' imsi='..imsi)
     exec('ue_param id=1'..ue_id..
          ' ue_nr_capabilities='..NSA_UE_CAPABILITIES_FDD..' dual_conn=eutra_nr'..
          ' ue_eutra_nr_capabilities='..NR_EUTRA_CAPABILITIES_FDD)
     exec('set_bearer id=2 ue=1'..ue_id..
          ' qci=9 pdn=1 ip=4.7.254.1'..ue_id..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
     exec('set_pdu_gateway id=1'..ue_id..' ue_nat_ip=72.23.0.1'..ue_id..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')

--add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('trace uec=1 protocol=rrc,nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
