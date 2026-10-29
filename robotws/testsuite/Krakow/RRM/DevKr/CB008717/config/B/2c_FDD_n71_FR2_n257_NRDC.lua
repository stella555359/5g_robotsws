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
exec('set_cell id=1 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2071591:2071591 gscn=22446 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=136620:127420 gscn=1589 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
----UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')
---------------------------------------------------------------------------------------------------
---UE CONFIGURATION
----------------------------------------------------------------------------------------------------
--- UEB1a n71_n257_without_featureSetCombinationDC
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=2')
exec('ue_param id=1 ue_nr_capabilities=E7A05000574F7E03560803C320016080080C048830004C1C2600C4834000A04026010188A0300A67016A8D89BAC1184341020E90580516CAA2A121CFA067D813E31CF9863CA1607038780B800EF800E003BE000A1000D940001400000507C46D608C21A08107882C024B65515050E7D033E31CF9863CA16070387813F8000000FE000000541F107582308682041E20B0092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB000000282000C1540B40F78E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0740B4070378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371F8E290000C0540B40378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0008C3C46000E800000000400C046820022800F00C2893B639F0C07014001E827007C0050006020280381804A00E000C040422002085808400200064F0040100000124A000012C0160656E90010400002594941000019652500540EAABB500008080100202008010142E40200CA00')

exec('amf_ue_ics_param id=1 ue=1 indexToRFSP=87')

for i=1,10 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
end

---------------------------------------------------------------------------------------------------
---COMMON CONFIGURATION
----------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=170 default=on')
exec('set_qosflow id=2 5qi=1')

exec('qosrule_set id=1 proto=tcp qos_flow=1 # Dla defaultowego QoS flow typu nonGBR')
exec('qosrule_set id=2 proto=udp qos_flow=2 #Dla QoS typu VoNR')

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1')

exec('debug_log level=6')
exec('sim_debug_log level=1 uec=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace off')
exec('cfg_end')

exec('set_log log_to_file=on')
--exec('sim_start version_check=off')
