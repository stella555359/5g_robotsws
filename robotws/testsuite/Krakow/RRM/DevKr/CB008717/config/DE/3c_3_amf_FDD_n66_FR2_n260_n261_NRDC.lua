local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.2"
local GNB_SIM_XN_ADDR="10.0.1.31"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local AMF_NG_ADDR_2="10.0.1.11"
local AMF_NG_ADDR_3="10.0.1.12"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

require('os')
os.execute('sudo ifconfig eth3:AMF2 add '..AMF_NG_ADDR_2)
os.execute('sudo ifconfig eth3:AMF3 add '..AMF_NG_ADDR_3)

---------------------------------------------------------------------------------------------------
---5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=100,788,200,0 plmn=311:489')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('set_amf id=2 name=AMF2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR_2..':38412 region=1 set_id=2 pointer=2')
exec('set_amf id=3 name=AMF3 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR_3..':38412 region=1 set_id=2 pointer=3')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('amf_param id=2 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('amf_param id=3 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('set_backup_amf main=1 backup_amfs=2')

exec('amf_setup_ng_param id=1 include_backup_amf_name=true')
exec('amf_setup_ng_param id=2 include_backup_amf_name=true')
exec('amf_setup_ng_param id=3 include_backup_amf_name=true')

exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..' ngu='..AMF_NG_ADDR..'')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION NR-ARFCN values UL:DL
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=all')
exec('set_cell id=1 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2254471:2254471 gscn=23081 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=347380:425040 gscn=5313 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:2 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2077917:2077917 gscn=22469 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
----UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')
---------------------------------------------------------------------------------------------------
---UE CONFIGURATION
----------------------------------------------------------------------------------------------------
--- UED_B1c n5_n66_n261A/A + n5_n66_n260G/G + n41_n66_n260G/G + double featureSetIndex
for i=1,3 do
	exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540'..i..' mode=nr enb=2 cell=2')
	exec('ue_param id='..i..' ue_nr_capabilities=E7A05000574F7E03560803C0A02C10010180910600098381C0C4834000A04026010188A01014CE02951B0A3582308682041D201145B2A8A84873E819F604F8C73E618F28581C0E1E02E003BE003800EF800507C04D608C21A081078804496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000283E20EB04610D04083C40224B65515050E7D033E31CF9863CA16070387813FB000000FEC00000540B40F78E3087000A8F3F140447ED982A9001E3C0087104184540A3F7F206E3F1C120180E81682606F1C610E00151E7E28088FDB30552003C78010E208308A8147EFE40DC7E38240301502D00DE38C21C002A3CFC50111FB660AA40078F0021C4106115028FDFC81B8DC604806000C62E020007104003A08000000110B808001C41000E818C30010402E140007104003A0630C008024004808300A2081C1040545E03891274FC0C93E2C49D3A7E0649F1624E9D3F0324F8A01A068040801403D02E03E00280030100C0381802A0380030101088008216021000800193C0400400000492800004B000002008020000000240000201807006C0CADD2327637CA0182000012CA4A080000CB292800080200800000401281D5576A113A0108040080101002004040100210080100202004008080300620300801201002018010030020040C01803805006150B900803280')
end

--- UED_B1c n5_n66_n261A/A + n5_n66_n260G/G + n41_n66_n260G/G + double featureSetIndex + splitDRB-withUL-Both-MCG-SCG is absent
for i=4,5 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540'..i..' mode=nr enb=2 cell=2')
    exec('ue_param id='..i..' ue_nr_capabilities=E7A05000574F7E03560803C320016080080C048830004C1C2600C4834000A04026010188A0300A67016A8D851AC1184341020E90580516CAA2A121CFA067D813E31CF9863CA1607038780B800EF800E003BE000A1000D940001400000507C04D608C21A08107882C024B65515050E7D033E31CF9863CA16070387813F8000000FE000000541F107582308682041E20B0092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB000000282000C1540B40F78E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371F8E290000C0740B4130378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371F8E290000C0540B40378E3087000A8F3F142C023F6CC154800F1E00438820C22A051FBF90371B8C290000C0018C5C04000E2080074100000002217010003882001D031860020805C28000E20800740C61801004800901060144103820822802F01C4893A7E0649F1624E9D3F0324F8B1274E9F81927C500D034020400A01E827007C0050006020280381804A00E000C040422002085808400200064F0100100000124A000012C00000802008000000090000080601C01B032B748C9D8DF28060800004B29282000032CA4A000200802000001004A07555DA844E80420100200404008010100400840200400808010020200C01880C020048040080600400C008010300600E014018142E40000CA00')
end

local UEs_COUNT=5
for i=1,UEs_COUNT do
    exec('amf_ue_ics_param id=1 ue='..i..' indexToRFSP=87')
end

for i=1,10 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
end

---------------------------------------------------------------------------------------------------
---COMMON CONFIGURATION
----------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=170 default=on')
exec('set_qosflow id=2 5qi=2')
exec('set_qosflow id=3 5qi=9')
exec('set_qosflow id=4 5qi=5')
exec('set_qosflow id=5 5qi=4')
exec('set_qosflow id=6 5qi=8 priority=1 pci=may_trigger_pre_emption pvi=not_pre_emptable')


--- For default nonGBR QoS flow
exec('qosrule_set id=1 proto=tcp qos_flow=1')
--- For GBR QoS flow
exec('qosrule_set id=2 proto=udp qos_flow=2')
--- For nonGBR QoS flow
exec('qosrule_set id=3 proto=udp qos_flow=3')
--- For default nonGBR_Signaling QoS flow
exec('qosrule_set id=4 proto=udp qos_flow=4')
--- For GBR QoS flow
exec('qosrule_set id=5 proto=udp qos_flow=5')
--- For pre-emption capable QoS flow
exec('qosrule_set id=6 proto=udp qos_flow=6')


exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-3')

exec('debug_log level=6')
exec('sim_debug_log level=1 uec=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace off')
exec('cfg_end')

exec('set_log log_to_file=on')
--exec('sim_start version_check=off')
