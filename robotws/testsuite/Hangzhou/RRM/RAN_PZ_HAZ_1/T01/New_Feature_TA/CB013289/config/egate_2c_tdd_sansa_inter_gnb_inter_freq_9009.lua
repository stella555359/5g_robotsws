---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
NUMBER_OF_UES_SA=10
NUMBER_OF_UES_SA_8239=10
NUMBER_OF_UES_NSA=10
local EDAEMON_PORT="22222"
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

--VARIABLES for SA configuration
local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local GNB2_XN_ADDR="10.0.1.101"
local GNB2_NG_ADDR="10.0.1.102"
local ENB1_S1_ADDR="10.0.1.136"
local ENB2_S1_ADDR="10.0.1.137"
local ENB1_X2_ADDR="10.0.1.138"
local ENB_X2U_ADDR="10.0.1.132"

local GNB5_S1U_ADDR="10.0.1.105"
local GNB5_X2_ADDR="10.0.1.141"
local GNB5_NG_ADDR="10.0.1.106"
local SERVER_ADDR="10.0.1.132"

local MME1_S1_ADDR="10.0.1.131"

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
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=1 amf=1 xn='..GNB_NG_ADDR)
--TDD cells PCI 50 and 51
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=632000:632000 gscn=7832 mandatory_for_activation=off')
--FDD cells PCI 52 and 53
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
-- target gNB (acting as eNB stub)
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=5 type=simulated plmn=311:489 ng='..ENB2_S1_ADDR..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' gnb_id=0x74321:28 nssai=0x01:0xD143A5')
exec('set_cell id=1 gnb=5 pci=10:0 eci=0x7432101 earfcn=2200:20200 mapped_earfcn=4400:22400 tac=788 proxy='..SERVER_IP..':12219 nrci=0x01 tdd_cell=off bw=20MHz technology=lte mandatory_for_activation=off')
exec('gnb_cell_param id=1 gnb=5 enable_drx_profile_for_anr=on')
exec('gnb_param id=5 xn_listening_socket=off sib1_period=20000')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_UES_SA do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
        ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58380810205898D93803B80000001')
    exec('set_pdu_gateway id='..ue_id..
         ' ue_nat_ip=72.23.0.'..ue_id..
         ' dl_nat_gw='..SERVER_IP..
         ' ul_nat_gw='..SERVER_IP)
end

for ue_id=NUMBER_OF_UES_SA+1,NUMBER_OF_UES_SA+NUMBER_OF_UES_SA_8239 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
        ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58400810205898D938001BB80000001')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=NUMBER_OF_UES_SA+NUMBER_OF_UES_SA_8239+1,NUMBER_OF_UES_SA+NUMBER_OF_UES_SA_8239+NUMBER_OF_UES_NSA do
    local imsi_prefix = '311:489:216455'
    local ue_id_aligned
                if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
                elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
                end
                local imsi = imsi_prefix..ue_id_aligned

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
         ' nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null'..
         ' imsi='..imsi)
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=610000000470840002000268800040000003402A02200301C0C0300F000000000000022A0000400000000000042A80'..
         ' dual_conn=eutra_nr'..
         ' ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801')
    exec('set_bearer id=2 ue='..ue_id..
         ' qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=8 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('set_log log_to_file=on')
exec('set_log flush')
exec('cfg_end')
exec('start version_check=off')
sleep(1)
