local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_NG_ADDR2="10.0.1.40"
local GNB_SIM_XN_ADDR="10.0.1.31"
local GNB_SIM_XN_ADDR2="10.0.1.41"
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local PROXY3_SERVER_IP="10.0.2.100"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB1_NG add '..GNB_SIM_NG_ADDR2)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth3:gNB1_XN add '..GNB_SIM_XN_ADDR2)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)
os.execute('sudo ifconfig eth4:gNB1_PR add '..PROXY3_SERVER_IP)
---------------------------------------------------------------------------------------------------
---5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=222,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..' ngu='..AMF_NG_ADDR..'')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION NR-ARFCN values UL:DL
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=347380:425040 gscn=5313 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=347380:425040 gscn=5313 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2254471:2254471 gscn=23081 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=167300:176300 gscn=2203 mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x05 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=349000:431000 gscn=5389 mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x06 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2077917:2077917 gscn=22469 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5,1:0xD143A6 amf=1')
exec('set_cell id=1 gnb=3 pci=15:1 tac=0 nrci=0x01 tdd_cell=off proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=5313 nr_arfcn=347380:425040 nr_scs=15kHz bs_channel_bandwidth=10MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s')

---------------------------------------------------------------------------------------------------
--GNB1 sim configuration with fake enb cell
---------------------------------------------------------------------------------------------------
exec('set_gnb id=1 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR2..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' gnb_id=0x76E x2_peers=none xn='..GNB_SIM_XN_ADDR2..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=1 pci=3:2 tac=222 nrci=0x01 tdd_cell=on proxy='..PROXY3_SERVER_IP..':'..EDAEMON_PORT..' earfcn=2000:20000 bw=20MHz technology=lte mandatory_for_activation=off')
exec('gnb_param id=1 xn_listening_socket=on send_xn_setup=off')

---------------------------------------------------------------------------------------------------
----UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')
---------------------------------------------------------------------------------------------------
---UE CONFIGURATION
----------------------------------------------------------------------------------------------------
--- sufficient UECap - independentGapConfig is not supported, includeNR-DC is present, support for INTER_RAT_HO
for i=1,4 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540'..i..' mode=nr enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C28D608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E026B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180E81682606F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800318B808001C41000E820000000442E020007104003A0630C004100B850001C41000E818C30020090012020C02882070410650005E03891274FC0C93E2C49D3A7E0649F1624E9D3F0324F8A01A068040801403F7FFD541B800F800A000C070500703009401C001808084400410B0108004000C9E02002000002494000025800001004010000000120000100C0380360656E9193B1BE500C1000009652504000065949400040100400000200940EAABB5089D008402004008080100202008010804008010100200404018031018040090080100C008018010020600C01C0280312B0700020321251C15284285C804019C0')
end

--- insufficient UECap - independentGapConfig is supported, includeNR-DC is not present, support for INTER_RAT_HO
for i=5,8 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540'..i..' mode=nr enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C28D608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E026B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180E81682606F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800318B808001C41000E820000000442E020007104003A0630C004100B850001C41000E818C30020090012020C02882070410650005E03891274FC0C93E2C49D3A7E0649F1624E9D3F0324F8A01A068040801403F7FFD541B800F800E000C070500703009401C001808084400410B0108004000C9E02002000002494000025800001004010000000120000100C0380360656E9193B1BE500C1000009652504000065949400040100400000200940EAABB5089D008402004008080100202008010804008010100200404018031018040090080100C008018010020600C01C0280312B0700020321251C15284285C80401980')
end

--- sufficient UECap with wrong BandCombinationList-v1560 (4 items) with support for INTER_RAT_HO
for i=9,9 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02164540'..i..' mode=nr enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C28D608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E026B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180E81682606F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800318B808001C41000E820000000442E020007104003A0630C004100B850001C41000E818C30020090012020C02882070410650005E03891274FC0C93E2C49D3A7E0649F1624E9D3F0324F8A01E08804080140203F7FFD541B800F800E000C070500703009401C001808084400410B0108004000C9E02002000002494000025800001004010000000120000100C0380360656E9193B1BE500C1000009652504000065949400040100400000200940EAABB5089D008402004008080100202008010804008010100200404018031018040090080100C008018010020600C01C0280312B0700020321251C15284285C804019C0')
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
