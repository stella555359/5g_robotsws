---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
NUMBER_OF_UES_SA=30

local EDAEMON_PORT="10000"
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

--VARIABLES for SA configuration

local GNB_NG_ADDR="10.0.1.2"
local GNB2_XN_ADDR="10.0.1.101"
local GNB2_NG_ADDR="10.0.1.102"
local AMF_NG_ADDR="10.0.1.1"
local AMF2_NG_ADDR="10.0.1.3"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local PROXY_SERVER_IP="10.0.2.80"
local SERVER_ADDR="10.0.1.132"
local PGW_ADDR="4.7.254.207"
local PDN_IP="4.7.254.208"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf_region id=2 tac_list=0,100,200,258,788 plmn=311:489,311:492')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('set_amf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('amf_param id=2 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=1 amf=1 xn='..GNB_NG_ADDR)
--TDD cells PCI 50 and 51
exec('set_cell id=1 gnb=2 pci=16:2 tac=788 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880')
exec('set_cell id=2 gnb=2 pci=17:0 tac=788 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880')
--FDD cells PCI 52 and 53
exec('set_cell id=3 gnb=2 pci=17:1 tac=788 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=788 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
--GNB-2 CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 daemon='..SERVER_IP..':'..EDAEMON_PORT..' gnb_id=0x3 xn='..GNB2_XN_ADDR..' ng='..GNB2_NG_ADDR..' nssai=0x01:0xD143A5')
--TDD cell PCI 150 and 151
exec('set_cell id=1 gnb=3 pci=50:0 tac=788 nrci=0x0B tdd_cell=on proxy='..SERVER_IP..':2155 nr_arfcn=636666:636666 gscn=7880 nr_scs=30kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=636576 ssb_mtc_periodicity_and_offset=sf5:1 ssb_mtc_duration=sf1 ssb_subcarrier_spacing=kHz30')
exec('gnb_cell_param id=1 gnb=3 enable_anr=on')
exec('set_cell id=2 gnb=3 pci=50:1 tac=788 nrci=0x0C tdd_cell=on proxy='..SERVER_IP..':2156 nr_arfcn=640000:640000 gscn=7916 nr_scs=30kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=640032 ssb_mtc_periodicity_and_offset=sf10:0 ssb_mtc_duration=sf2 ssb_subcarrier_spacing=kHz30')
exec('gnb_cell_param id=2 gnb=3 enable_anr=on')
exec('set_cell id=3 gnb=3 pci=50:2 tac=788 nrci=0x0D tdd_cell=on proxy='..SERVER_IP..':2157 nr_arfcn=700000:700000 gscn=8544 nr_scs=30kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=700320 ssb_mtc_periodicity_and_offset=sf5:1 ssb_mtc_duration=sf1 ssb_subcarrier_spacing=kHz30')
exec('gnb_cell_param id=1 gnb=3 enable_anr=on')
exec('set_cell id=4 gnb=3 pci=51:0 tac=788 nrci=0x0E tdd_cell=on proxy='..SERVER_IP..':2158 nr_arfcn=636666:636666 gscn=7880 nr_scs=30kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=636576 ssb_mtc_periodicity_and_offset=sf5:1 ssb_mtc_duration=sf1 ssb_subcarrier_spacing=kHz30')
exec('gnb_cell_param id=2 gnb=3 enable_anr=on')
exec('gnb_param id=3 sib1_period=200 send_xn_setup=false xn_listening_socket=on measEvent=A5 sa_ho=ng_based')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_UES_SA do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc nea=null+zuc suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
        ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A03FA047D5FFAEFFFFBAF05400782E0203C126BE7FFF6F800E0080F3B70101F8E01945C003FE2F08EF2F82087FD503819FB29BA478C49F58C49F571893EA3127D441E449F091465BE7E8A2E005FF17847797C1043FEA81C0CFD94DD23C624FAC624FAB8C49F51893EA20F224F848A32DF3F451704DFF8BC23BCBE0821FF540E067ECA6E91E3127D63127D5C624FA8C49F51079127C245196F9F928B8277FC5E11DE5F0410FFAA07033F653748F1893EB1893EAE3127D4624FA883C893E1228CB7CFC80881C4D0000000800809A16006806046D927C0FFFF80004C00F800A070500703109801C001E0F8026400000032000000803C29BCA9A0082000012CB2A080000CB2CA803A15574AAA84806C007CDF80E03803CDF80E03800000003002006008010C58380810205898D93803B80000001')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=5 default=on')
exec('set_qosflow id=2 5qi=1')
exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('set_nwslice id=1 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A5 default=on amf=1,2')

----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('set_log log_to_file=on')
exec('set_log flush')
exec('cfg_end')
sleep(1)
exec('start version_check=off')
