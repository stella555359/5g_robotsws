---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
NUMBER_OF_UES_NSA=2
NUMBER_OF_UES_SA=10

local EDAEMON_PORT="10000"
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

--VARIABLES for SA configuration

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

--VARIABLES for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"
local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"
local GNB3_S1U_ADDR="10.0.1.3"
local GNB4_S1U_ADDR="10.0.1.4"

local GNB3_XN_ADDR="10.0.1.101"
local GNB3_NG_ADDR="10.0.1.102"
local GNB4_XN_ADDR="10.0.1.103"
local GNB4_NG_ADDR="10.0.1.104"
local GNB3_X2_ADDR="10.0.1.105"
local GNB4_X2_ADDR="10.0.1.106"

local MME1_S1_ADDR="10.0.1.131"
local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"
local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"
local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 nssai=0x01:0xD143A5 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=200 proxy='..SERVER_IP..':12219|'..SERVER_IP..':8889 earfcn=2110:20110 mandatory_for_activation=off suggested_band=1')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=0,100,200,201,202,258,788')
exec('set_mme id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=8M s5u_rcv_buff_size=8M s1u_snd_buff_size=8M s1u_rcv_buff_size=8M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..SERVER_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,201,202,258,788 plmn=311:489,311:492,311:495,311:498,311:501')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)
exec('amf_mobility_restriction_list_param id=1 equiv_plmn=311:489 equiv_plmn=311:492 equiv_plmn=311:498 equiv_plmn=311:500 equiv_plmn=311:501 fa_plmn=311:480 forbidden_tacs=1 restricted_plmn=311:479 restricted_rat=both')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 plmnList=311:489,311:492,311:495,311:498,311:500,311:501 ng='..GNB_NG_ADDR..' gnb_id=0x1:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=1 xn='..GNB_NG_ADDR..' nssai=0x01:0xD143A5 amf=1')
--PCI:50
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 eq_plmn=311:492,311:495,311:498,311:500,311:501 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 eq_plmn=311:492,311:495,311:498,311:500,311:501 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off')
--FDD cells
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 eq_plmn=311:492,311:495,311:498,311:500,311:501 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=167300:176300 gscn=2203 mandatory_for_activation=off mapped_MFBI=26')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 eq_plmn=311:492,311:495,311:498,311:500,311:501 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=376000:392000 gscn=4900 mandatory_for_activation=off mapped_MFBI=25 is_fr1sdl_cell=on')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
--SA UE
for ue_id=1,3 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:2164553'..ue_id..
        ' enb=1 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=F9A0D000574D5A13160003C6A00002C1262C003387A1A004D9061CF9863CA160704C0A00C47013A8D83381AC1184341020E90A8002CB64C550D0E7C471E819F604F8C73E618F28581C0E1E05FFFFFFFF7FFFFFFFC8C00000381507C18D608C21A08107885400125B262A82471E439F18E7CC31E50B0381C3C09FFFFFFFF7FFFFFFFC8C00000381507C46D608C21808107015000356098AA081C790E7C639F30C7827F0000001FC00000023000000E0751B13703582308682041D215000596C98AA1A1CF88E3D033EC09F18E7CC31E50B0381C3C0BFFFFFFFEFFFFFFFF918000007002898086E83A06E83A00A503882080000200A8382803882000004240A85C41000C20818410001040158789A001C41000006120460E140400040E30F0A000305000050EB0F0A000388C000018240A83C46000E208000070B02B0F0A000389A000020201D40E02000009080201200CC018808D013600215800000E60A813B639F0E14E9DB1CF871274E9DB1CF870A74ED8E7C38113639F0E14489B1CF870A74FC0FF5EDC29D3F03FD7B70A244D8E7C3813B639F0FD0B80001F0E0A00C0601200301E002030001D80080C03F85400800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000060040000380200001C01000800000020000200100080601802000024010000140080000B0040020280A0080040001C01000818038020000340100001D24A0040F03CB925000079724A00C0F03C0F03CB9250040781E079724A0180F03C0F03C0F03C0F2E4940201E0781E0781E5C9280703C0F03C0F03C0F03C0F2E0940001E5C9280003D39250020781E9C9280203C0F03D382500007A724A01C0F03C0F03C0F03C0F03D39250060781E0781E9C9280003C392500E0781E0781E0781E0781E1C9280103C0F0E4940181E0781E078704A0000F0C10E54D654D60A5606560CD606D652D64CD602D6025604560AD650D646D60ED6E9190940F04000025949410000196524040000A594941000039652404000125949010000596525040001A594901000079652404000225949010000996524040002A5949010000B9652504000325949410000D9652404010380E96525040003A594940F52AAAA55174AAAE95455058AA075541A2A94C55268AA031540A2A9355523AAA0F155DA864251B0001940A880402010180C06030080402010080406030180C060300804020300804020100804020100804020100804020100804020012001028018202004000080800C20101001804040000101000020200C020080800C00101C00C20200C0180801000101006010040400608080800C02020030404018030100600C002044050500'..
         ' dual_conn=eutra_nr ue_eutra_nr_capabilities=A11FF83BC4C0C0383200181800028588817898180713400388C0000002C440BC4C0C0389A001C41000000162205E260601C28000E208000000B0102F130300E2080071180000085808178D81807118003882001C41000004160205E260601C4D000E140000030B010201200CC018007010602695A00000B907893A244D8E7C3893A244D8E7C3893A244D8E7C3893A244D8E7C3893A24498E7D1A7448912639F449D1224C73E01A0718C6318C60C02880002010100200804030061000040202004008080600C3000080404030060100C0180403006100004020200401008010040000000040005030080500C020140000')
    exec('set_bearer id=1 ue='..ue_id..
          ' qci=9 pdn=1 ip=4.7.254.1'..ue_id..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
exec('amf_ue_ics_param id=1 ue=all mobility_restriction_list_id=1')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=9 default=on')
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
exec('set_qosflow id=4 5qi=2 default=off')
exec('set_qosflow id=5 5qi=8 default=off')
exec('set_qosrule id=1 proto=tcp qos_flow=1')
exec('set_qosrule id=2 proto=tcp qos_flow=2')
exec('set_qosrule id=3 proto=udp qos_flow=3')
exec('set_qosrule id=4 proto=udp qos_flow=4')
exec('set_qosrule id=5 proto=tcp qos_flow=5')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 ue=all qos_flows=all qos_rules=all')
exec('set_nwslice id=2 snssai=0x01:0x000001 default=off amf=1 ue=all qos_flows=1,2,3,4 qos_rules=1,2,3,4')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('debug_log level=4')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace uec=1 protocol=all on')
exec('sim_trace amf=1 protocol=all on')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('set_log log_to_file=on')
exec('set_log flush')
exec('cfg_end')
