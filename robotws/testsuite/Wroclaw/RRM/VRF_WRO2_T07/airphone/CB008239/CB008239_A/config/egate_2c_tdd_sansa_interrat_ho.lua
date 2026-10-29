---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------

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
local ENB2_S1_ADDR="10.0.1.137"
local GNB_S1U_ADDR="10.0.1.112"
local GNB2_S1U_ADDR="10.0.1.3"

local ENB1_X2_ADDR="10.0.1.138"
local GNB_X2_ADDR="10.0.1.2"
local GNB2_X2_ADDR="10.0.1.3"

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
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x65432 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x6543201 pci=3:2 tac=788 proxy='..SERVER_IP..':12218|'..SERVER_IP..':8889 earfcn=2200:20200 mapped_earfcn=4400:22400 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=788,777,111,222,444,333')
exec('set_mme id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=8M s5u_rcv_buff_size=8M s1u_snd_buff_size=8M s1u_rcv_buff_size=8M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..SERVER_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=1 amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=788 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=788 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
exec('set_cell id=3 gnb=2 pci=17:1 tac=788 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=788 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
-- target gNB (acting as eNB stub)
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..ENB2_S1_ADDR..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' gnb_id=0x74321:28 nssai=0x01:0xD143A5')
exec('set_cell id=1 gnb=3 pci=10:0 eci=0x7432101 earfcn=2200:20200 mapped_earfcn=4400:22400 tac=788 proxy='..SERVER_IP..':12219 nrci=0x01 tdd_cell=off bw=20MHz technology=lte mandatory_for_activation=off')
exec('gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on')
exec('gnb_param id=3 xn_listening_socket=off sib1_period=20000')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 sctp_rto_min=100')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,9 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    end

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
        ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58400810205898D938001BB80000001')
    exec('ue_param id='..ue_id..
         ' dual_conn=eutra_nr')
    exec('set_pdu_gateway id='..ue_id..
         ' ue_nat_ip=72.23.0.'..ue_id..
         ' dl_nat_gw='..SERVER_IP..
         ' ul_nat_gw='..SERVER_IP)
end

for ue_id_EC=10,14 do
    exec('set_ue simulated id='..ue_id_EC..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_EC..
        ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id_EC..
         ' ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58400810205898D938001BB80000001')
    exec('ue_param id='..ue_id_EC..
         ' dual_conn=eutra_nr')
    exec('set_pdu_gateway id='..ue_id_EC..
         ' ue_nat_ip=72.23.0.'..ue_id_EC..
         ' dl_nat_gw='..SERVER_IP..
         ' ul_nat_gw='..SERVER_IP)
end

--No Eutra-CGI
exec('set_ue simulated id=15 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645415 mode=nr enb=2 cell=1')
exec('ue_param id=15 ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00E800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58400810205898D938001BB80000001')
exec('ue_param id=15 dual_conn=eutra_nr')


-- only B4
exec('set_ue simulated id=16 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645416 mode=nr enb=2 cell=1')
exec('ue_param id=16 ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58380810205898D9381BB80000001')
exec('ue_param id=16 dual_conn=eutra_nr')

-- only B10
exec('set_ue simulated id=17 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645417 mode=nr enb=2 cell=1')
exec('ue_param id=17 ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58380810205898D9384BB80000001')
exec('ue_param id=17 dual_conn=eutra_nr')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=8 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')
exec('set_pdu_gateway id=11 ue_nat_ip=72.23.0.11 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ')
exec('set_pdu_gateway id=12 ue_nat_ip=72.23.0.12 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ')
exec('set_pdu_gateway id=13 ue_nat_ip=72.23.0.13 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ')
exec('set_pdu_gateway id=14 ue_nat_ip=72.23.0.14 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ')
exec('set_pdu_gateway id=15 ue_nat_ip=72.23.0.15 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ')
---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('set_log log_to_file=on')
exec('set_log flush')
exec('cfg_end')
sleep(1)
