---------------------------------------------------------------------------------------------------
--IP ADDRESSES FOR WTS NODES
---------------------------------------------------------------------------------------------------

local CONTAINER_IP="10.0.2.1"
local SERVER_IP="10.0.2.1"

local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="10.12.2.1"

local DAEMON_IP="10.0.2.1"
local DAEMON_PORT="10000"

local ENB1_S1_ADDR="10.0.1.136"
local GNB1_S1U_ADDR="10.0.1.112"
local GNB2_S1U_ADDR="10.0.1.113"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local GNB1_NG_ADDR="10.0.1.2"
local GNB2_NG_ADDR="10.0.1.3"
local GNB1_X2_ADDR="10.0.1.2"
local GNB2_X2_ADDR="10.0.1.3"


local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local PDN_IP11="4.7.254.211"

---------------------------------------------------------------------------------------------------
-- UE CAPABILITIES
---------------------------------------------------------------------------------------------------
local SA_UE_CAPABILITIES="E9A09000575F5A13160003C52000160BF170019C2EB42C013641873E618F28581C13018062380DDC6C4CC0D608C21A081078844006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0BFFFFF800FFFFFE000D80000703A0D85155AC1184341020F108800CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC7FE003FB1FF8003600001C0EA3626D56B04610D04083C4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05FFFFFC007FFFFF0006C0000381D06C46AAD608C21A08107884400656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001B00000E0771B00B03582308682041E211001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFF800003FFE000003600001C0A83620EB04610D00083C4220032B64C55890E7D813E238F0091C790E7D473E618F28581C0E1E13FB000000FEC000000D80000702A8D837AC1184341020F108800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17FFC00001FFF000001B00000E006AC3C4C000E140000000B02B17130003850001C4D000004160563E26000706C00388C001C4D00000E160561E26000713000000858158B898001C4D000E140000040B02B0F0A00038500000242C0AC5C4D000E26800711800005058158789A001C4D000018160401E23000710400001AC5C46000E20800710400002858158F804001C1B000E23000710400005858158788C001C4600000C160561E0D800713400004058100D011A026404D8051006E00140411B4002941B0A244D8E7C38912244D8E7C38D0204081B1CF810A040D8E7C08902040D8E7C0850206C73E044810206C73E0428103639F0214489B1CF871224489B1CF871A0408103639F0214081B1CF810A040D8E7C00054346318C6318C6318C607EAAAAA83E000F000A070500703009401C0018090010180F82800800000004000008020000080100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C00400201004000008020080203B953591B594358195833582B594B5933580B581B58095811583B5953582940D04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240374AAAE91D55288BA55154162A82C55068AA531549A2A80C55028AA4D5541E2A95450F002F012A05028140A05028140A05028140A05028140A05028006040400801010020042020040080801002201002004040080101002004202044058080D014201002004040080101002004402044058080D014020340504040880B0102202C602004008081101602044058080100210102202C0400801080801002020040088040080101002004040880B18080D0140204405808110160203405040400801010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05955555554E0B40"

---------------------------------------------------------------------------------------------------
-- NUMBER OF UEs DECLARATION
---------------------------------------------------------------------------------------------------

NUMBER_OF_UES_SA=99
NUMBER_OF_UES_NSA=1

---------------------------------------------------------------------------------------------------
-- VM IPs SETUP RELATED TO SIMULATED GNB
---------------------------------------------------------------------------------------------------

--require('os')
--os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.102')
--os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.101')

---------------------------------------------------------------------------------------------------
-- NR CORE CONFIG
---------------------------------------------------------------------------------------------------

exec('set_amf_region id=1 tac_list=200,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=8M ngu_rcv_buff_size=8M ngu_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
-- 4G CORE CONFIG
---------------------------------------------------------------------------------------------------

exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20971520 s5u_rcv_buff_size=20971520 s1u_snd_buff_size=20971520 s1u_rcv_buff_size=20971520 gtpu_read_packets_threshold=0')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20971520 sgi_snd_buff_size=20971520 s5u_rcv_buff_size=20971520 s5u_snd_buff_size=20971520 gtpu_read_packets_threshold=0')

---------------------------------------------------------------------------------------------------
-- GNB1 CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB1_S1U_ADDR..' x2='..GNB1_X2_ADDR..':36422 ng='..GNB1_NG_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145000:156000 mandatory_for_activation=off gscn=1947')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=349400:368400 mandatory_for_activation=off gscn=4605')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=658000:658000 mandatory_for_activation=off gscn=8103')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=659984:659984 mandatory_for_activation=off gscn=8125')

---------------------------------------------------------------------------------------------------
-- GNB2 CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=external plmn=311:489 s1u='..GNB1_S1U_ADDR..' x2='..GNB2_X2_ADDR..':36422 ng='..GNB2_NG_ADDR..' gnb_id=0x02:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=5 gnb=3 pci=18:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145000:156000 mandatory_for_activation=off gscn=1950')
exec('set_cell id=6 gnb=3 pci=18:1 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=136100:126900 mandatory_for_activation=off gscn=1584')
exec('set_cell id=7 gnb=3 pci=18:2 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=640000:640000 mandatory_for_activation=off gscn=7916')
exec('set_cell id=8 gnb=3 pci=19:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=645000:645000 mandatory_for_activation=off gscn=7967')



---------------------------------------------------------------------------------------------------
-- SIMULATED eNB (LTE BTS) CONFIG
---------------------------------------------------------------------------------------------------

exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 bw=10MHz enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..SERVER_IP..':12219 earfcn=68787:133323')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited  proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=0')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,99 do
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
         ' ue_nr_capabilities='..SA_UE_CAPABILITIES)
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
-- NETWORK SLICING AND QI
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=7')
exec('set_qosflow id=3 5qi=9')
exec('set_qosflow id=4 5qi=5')
exec('set_qosflow id=5 5qi=1')
exec('set_qosflow id=6 5qi=4')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
exec('set_qosrule id=4 proto=udp qos_flow=5')
exec('set_qosrule id=5 proto=udp qos_flow=6')
exec('nwslice_set id=1 qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 snssai=0x01:0xD143A5 default=on ue=all amf=1')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=40,20,-40,-40')
exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')

-- MISC
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace uec=1 protocol=all on')
exec('sim_trace amf=1 protocol=all on')
exec('cfg_end')
exec('set_log log_to_file=on')
