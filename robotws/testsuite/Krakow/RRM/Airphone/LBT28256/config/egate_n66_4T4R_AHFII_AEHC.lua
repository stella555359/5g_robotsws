-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_XN_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_IP="127.0.0.1"
local EDAEMON_PORT="10000"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,788,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1')
-- exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 gscn=4888 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=376000:392000 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 gscn=5360 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=348000:430000 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 gscn=6387 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=511200:511200 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=0 gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,15 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=3')
end
--SA
--n41(2A)-n66A TDD PCELL (CELL3) + FDD SCELL (CELL2) + TDD SCELL (CELL4)
--  channelBWs-DL/UL 40,60,80Mhz, supportedBandwidthDL/UL 100Mhz for b41
--  channelBWs-DL/UL 20,40Mhz, supportedBandwidthDL/UL 40Mhz for b66
exec('ue_param id=1 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180533802507C41D618DA210000000000200900F5B000000000007FE618F28581C0E1E90484120A0F851EC31B47498A823F96526CA090105B260901831E31FF9863CA1607038780880B202C0542E1400070A0003882080001FE7FFFFFFFFC00C04180501C800A02339343E00D92000001592000005002C19ACA9800B20000025949590000112CA4A00A836552ACA1200B002402000000080401002010040080400801080')
--SA
--n25A-n41(2A)-n66A TDD PCELL (CELL3) + FDD SCELL (CELL1) + FDD SCELL (CELL2) + TDD SCELL (CELL4)  (supportedBandwidthCombinationSet = 1)
--  channelBWs-DL/UL 40,60,80Mhz, supportedBandwidthDL/UL 100Mhz for b41
--  channelBWs-DL/UL 20Mhz, supportedBandwidthDL/UL 20Mhz for b25
--  channelBWs-DL/UL 20,40Mhz, supportedBandwidthDL/UL 40Mhz for b66                                             channelBWs-DL/UL 50Mhz, supportedBandwidthDL/UL 50Mhz for b78
exec('ue_param id=2 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180533804507C18D618DA210000000000200900F5B000000000007FE618F28581C0E1E90404100A0F883AC31B4420000000000401201EB600000000000FFCC31E50B0381C3D2090824141F0A3D86368E9315047F2CA4D9412020B64C1203063C63FF30C7942C0E070F01101640580A87C18000E1400070A0003882000001FE7D00000000014018808300A039001404672687C02904000002B2400000AB2400001200981B5833595300204000025949590000112CA4AC8000109652500940F2A836552ACA1200F00340201000000000C04008010100600C040180301004008200')
--SA
--n41A-n66A TDD PCELL (CELL3) + FDD SCELL (CELL2) (supportedBandwidthCombinationSet = 0,1)
--  channelBWs-DL/UL 40,60,80Mhz, supportedBandwidthDL/UL 100Mhz for b41
--  channelBWs-DL/UL 20,30,40Mhz, supportedBandwidthDL/UL 40Mhz for b66                                           channelBWs-DL/UL 50Mhz, supportedBandwidthDL/UL 50Mhz for b78
exec('ue_param id=3 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180533802507C41D618DA210000000000200900F5B000000000007FE618F28581C0E1E90584160A0F851AC31B47498A823F96526CA090105B260901831E31FF9863CA1607038780880B202C05C1E140007104000003FC02FE0000000001808300A039001404672687C0190400000290400000A00583359530010400002594941000019652500541B2A9565090058012010000000202008010080100210')
--SA
--n41A-n66A TDD PCELL (CELL3) + FDD SCELL (CELL2) (supportedBandwidthCombinationSet = 0)
--  channelBWs-DL/UL 40,60,80Mhz, supportedBandwidthDL/UL 100Mhz for b41
--  channelBWs-DL/UL 20,40Mhz, supportedBandwidthDL/UL 40Mhz for b66                                          channelBWs-DL/UL 50Mhz, supportedBandwidthDL/UL 50Mhz for b78
exec('ue_param id=4 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180533802507C41D618DA210000000000200900F5B000000000007FE618F28581C0E1E90484120A0F851AC31B47498A823F96526CA090105B260901831E31FF9863CA1607038780880B202C05C1E140007104000003FC02FC0000000001808300A039001404672687C0190400000290400000A00583359530010400002594941000019652500541B2A9565090058012010000000202008010080100210')
--SA
--General UE
for i=5,15 do
    exec('ue_param id='..i..' ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531804507C18D618DA210000000000200B007AD800000000003FF30C7942C0E070F482820A0507C41D618DA210000000000200B007AD800000000003FF30C7942C0E070F48202081507C28D618DA3A4C5411FCB293650580416C9824060C78C7FE618F28581C0E1E022004801142001B28000280000009C1E0C0007104000003FC02FFFFFFFFFB83C18000E140000017F805FC00000000050062020C028E4D0F805208000005208000015208000024017056F036B2960040800004B29282000032CA4A0800014B292805A0B9740F2A94E509007801A010080000000420200400808020041010020040401803080')
end
---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=5 5qi=5 default=on')
exec('set_qosflow id=6 5qi=6 ue=all')

exec('qosrule_set id=1 proto=tcp qos_flow=5')
exec('qosrule_set id=2 proto=udp qos_flow=6')

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=5,6 qos_rules=1,2')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 qos_flows=5,6 qos_rules=1,2')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('start version_check=off')
