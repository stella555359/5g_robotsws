---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
NUMBER_OF_UES_NSA=2


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
local GNB2_S1U_ADDR="10.0.1.3"

local ENB1_X2_ADDR="10.0.1.137"
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
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=788 proxy='..SERVER_IP..':12219|'..SERVER_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
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
--TDD cells PCI 50 and 51
exec('set_cell id=1 gnb=2 pci=16:2 tac=788 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=788 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
--FDD cells PCI 52 and 53
exec('set_cell id=3 gnb=2 pci=17:1 tac=788 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=788 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_UES_NSA do
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
         ' ue_nr_capabilities=E1201000074F5A03020002054004824C5800240D41C04D8061CF9863CA160704C02031040CA83626EB04690D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0E070F05C0013C0070004F0003C000E0541F11B582348682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E000702A0F883AC11A4341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F000381506C28D608D21A08107CA0702CB64C550F027C873E819F11C78C73E618F28581C0E1E0B80027800E0009E00078001C0A83613EB04690D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0E070F09C0013C0070004F0003C000E0541B097582348682041F281C0B2D931543C09F21CFA067C471E31CF9863CA1607038784E00080003800200001E000702A0F837AC11A4341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F000381507C07D608D21A08107CA07024B64C55050E7C471E31CF9863CA16070387813F8000000FE000000078001C0A83E036B04690D04083E5038125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000003C000E0541F013582348682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E000702A0F805AC11A4341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F000381507C01D608D21A08107CA07024B64C55050E7C471E31CF9863CA16070387813F8000000FE000000078001C0A83E006B04690D04083E5038125B262A82873E238F18E7CC31E50B0381C3C09FC0000007F00000003C000E0003809A00001006F412C0260030003E0F00840180F8140080000000400000802000008010000060080000400400002C1280001938250040300C032704A0040601938250060300C0300C980200001C07654DE54D6065606D652D646D6E9181140804000025949410000196525040000A594901000039652404000125949010000596525040001A59490100007965240400022594900852AABA555540E2A94C55238AAED452A8BA551540A284807402A8140E07028140A05028140E00850900008101820303858608098D8F9293139420A3200'..
         ' dual_conn=eutra_nr'..
         ' ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641204269A01C4D00001A460160268000080180384D13782FA23200216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C60216C73E1C60216C73E1C60216C73E1C60216C73E1C4085B1CF870885B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8710216C73E1C4085B1CF8605422000000000000000000244400000024440000003444000000000100D200004040001000000400000200008010024000080000020200008000004000100200480001000000400000101000080002004008C00020200018000006000100200460001000000C0400030000801002300008000006000001808040080118000400000100000080402004008C00020200008000002000100200460001000000404000100008010022000080800020001002004200030100801002300008000002000000808040080110000C04000200008010022000180000040201002004')
end
exec('set_bearer id=2 ue=1 qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('set_bearer id=2 ue=2 qci=9 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')

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
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('set_log log_to_file=on')
exec('set_log flush')
exec('cfg_end')
sleep(1)
