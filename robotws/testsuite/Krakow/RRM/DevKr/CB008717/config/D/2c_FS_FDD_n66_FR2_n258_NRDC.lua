local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.2"
local GNB_SIM_XN_ADDR="10.0.1.31"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

---------------------------------------------------------------------------------------------------
---5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..' ngu='..AMF_NG_ADDR..'')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION NR-ARFCN values UL:DL
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2043943:2043943 gscn=22350 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=347380:425040 gscn=5313 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
----UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')
---------------------------------------------------------------------------------------------------
---UE CONFIGURATION
----------------------------------------------------------------------------------------------------
--- UEB1a n66_n258_featureSetDownlinkPerCC-3_more_MIMO_Layers_than_featureSetDownlinkPerCC-2
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=2')
exec('ue_param id=1 ue_nr_capabilities=E7A05000574F7E03560803C320016080080C048830004C1C2600C4834000A04026010188A0300A67016A8D89BAC1184341020E90580516CAA2A121CFA067D813E31CF9863CA1607038780B800EF800E003BE000A1000D940001400000507C46D608C21A08107882C024B65515050E7D033E31CF9863CA16070387813F8000000FE000000541F107582308682041E20B0092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB000000282000C1540B40F78E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0740B4070378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371F8E290000C0540B40378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0010C3C41000E808000000461E2080074046180002006020C10111400D80A1449DB1CF870A24ED8E7C30058120102008F413803E00280030101401C0C0250070006020211001042C04200100032780400800000925000009724A00402008B0098195BA56EB402040000259494100001965250401008029652500940EAABB555DCA0104040080101004008202004008080200410100200404018030285C8040194')

--- UEB1b n66_n258_featureSetDownlinkPerCC-3_has_higher_QAM_than_featureSetDownlinkPerCC-2
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=2')
exec('ue_param id=2 ue_nr_capabilities=E7A05000574F7E03560803C320016080080C048830004C1C2600C4834000A04026010188A0300A67016A8D89BAC1184341020E90580516CAA2A121CFA067D813E31CF9863CA1607038780B800EF800E003BE000A1000D940001400000507C46D608C21A08107882C024B65515050E7D033E31CF9863CA16070387813F8000000FE000000541F107582308682041E20B0092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB000000282000C1540B40F78E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0740B4070378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371F8E290000C0540B40378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0010C3C41000E808000000461E2080074046180002006020C10111400D80A1449DB1CF870A24ED8E7C30058120102008F413803E00280030101401C0C0250070006020211001042C04200100032780400800000925000009724A00402008B0098195BA36E9402040000259494100001965250401008029652500940EAABB4D5DAA0104040080101004008202004008080200410100200404018030285C8040194')

--- UEB1b n66_n258_featureSetDownlinkPerCC-3_has_greater_scalingFactor_than_featureSetDownlinkPerCC-2
for i=3,8 do
exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540'..i..' mode=nr enb=2 cell=2')
exec('ue_param id='..i..' ue_nr_capabilities=E7A05000574F7E03560803C320016080080C048830004C1C2600C4834000A04026010188A0300A67016A8D89BAC1184341020E90580516CAA2A121CFA067D813E31CF9863CA1607038780B800EF800E003BE000A1000D940001400000507C46D608C21A08107882C024B65515050E7D033E31CF9863CA16070387813F8000000FE000000541F107582308682041E20B0092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB000000282000C1540B40F78E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0740B4070378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371F8E290000C0540B40378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0010C3C41000E808000000461E2080074046180002006020C10111400D80A1449DB1CF870A24ED8E7C30058120102008F413803E00280030101401C0C0250070006020211001042C04200100032780400800000D250000095E9280100802330098195BA56E940204000025949610000165949610040200A9652500940EAABB555DAA0104040080101004008202004008080200410100200404018030285C8040194')
end

for i=1,10 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
end

local UEs_COUNT=8
for i=1,UEs_COUNT do
    exec('amf_ue_ics_param id=1 ue='..i..' indexToRFSP=87')
end
---------------------------------------------------------------------------------------------------
---COMMON CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=170 default=on')
exec('set_qosflow id=2 5qi=1')
exec('set_qosflow id=3 5qi=9')
exec('set_qosflow id=4 5qi=5')
exec('set_qosflow id=5 5qi=4')
exec('set_qosflow id=6 5qi=8')
exec('set_qosflow id=7 5qi=7')

exec('qosrule_set id=1 proto=tcp qos_flow=1 # Dla defaultowego QoS flow typu nonGBR')
exec('qosrule_set id=2 proto=udp qos_flow=2 #Dla QoS typu VoNR')
exec('qosrule_set id=3 proto=udp qos_flow=3')

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3')

exec('debug_log level=6')
exec('sim_debug_log level=1 uec=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace off')
exec('cfg_end')

exec('set_log log_to_file=on')
--exec('sim_start version_check=off')
