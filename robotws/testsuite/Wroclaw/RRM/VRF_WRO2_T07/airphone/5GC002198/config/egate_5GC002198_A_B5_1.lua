---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

--VARIABLES for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local GNB2_S1U_ADDR="10.0.1.3"
local GNB2_X2_ADDR="10.0.1.3"
local GNB2_NG_ADDR="10.0.1.4"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local EDAEMON_PORT="10000"
NUMBER_OF_UES_SA=10
NUMBER_OF_UES_NSA=10

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=250:255 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..SERVER_IP..':12219|'..SERVER_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=777:14 eq_plmn=250:255 tac_list=777,111,222,444,333,200')
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
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=637236:637236 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 gscn=1582 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--GNB-2 CONFIGURATION
---------------------------------------------------------------------------------------------------
exec ('set_gnb id=3 type=simulated plmn=311:489 s1u='..GNB2_S1U_ADDR..' x2='..GNB2_X2_ADDR..' ng='..GNB2_NG_ADDR..' gnb_id=0x3 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec ('set_cell id=1 gnb=3 nr_arfcn=2077829:2077829 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy='..SERVER_ADDR..':2155 gscn=22468 nr_scs=120kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=2077723 ssb_mtc_periodicity_and_offset=sf5:0 ssb_mtc_duration=sf1 ssb_subcarrier_spacing=kHz240')
exec ('gnb_cell_param id=1 gnb=3 enable_anr=on')
exec ('gnb_param id=3 send_xn_setup=false xn_listening_socket=off')
exec ('gnb_param id=3 sib1_period=200')

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
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc nea=null+zuc suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
        ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=ED00700047D874977EBFFFFDF000B7A8134019FB7F97315AFFF7F200003EA7FFFF8000209B00000009C011001A00180E0A00C073BF79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=NUMBER_OF_UES_SA+1,NUMBER_OF_UES_NSA+NUMBER_OF_UES_SA do
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
         ' ue_nr_capabilities=ED00700047D874977EBFFFFDF000B7A8134019FB7F97315AFFF7F200003EA7FFFF8000209B00000009C011001A00180E0A00C073BF79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0'..
         ' dual_conn=eutra_nr'..
         ' ue_eutra_nr_capabilities=BD1BA083058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C03058100713400001018060B0600E26800002030301005D04000008000001002826F4100000289178A028400040201002004AE0020080401008020100402008040100802010040200804010080201004020080402008040100802010000000804010080000000000080400000000000000008040100802010040200000010080201000000000001008000000000000000100802010040200804010080000004020080401008000000000000000100800000000000000000000201380040401008010100202000000080801010000000000008080000000000000000804020080201004020080401008020100402008040100802010040200804010100402004040000001010020200000008080000000000040400000000000202008040080801010000000404008080000000000040400808000000000004040000000000000000404E0020100402008040000002010040200000010080000000000080400000000000402008040100800000040200804000000201000000000001008000000000008020100402008040100802010040200804010080201004020080401008020100802010040200000010080201000000080400000020100000008040000000000040200000000000201380040400808010100202004040000001010020200404000000000002020000000808010100202004040080800000020200404008080000000000040400000010100202004040080801010000000404008080101000000000000808000000201004020080401008020100402008040100802010040200804010080201004020080401008020100802E00201002020000000808010100000000000000001010000000000000000000004020040400000010100202000000000000000020200000000000000000000080400808000000202004040000000000000000404000000000000000000001008010100000004040080801010000000000008080000002020040400000000000000004040000001013880100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801002100008040400801080008020200400800804018010020040100600400C00801')
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
exec('set_log log_to_file=on')
exec('set_log flush')
exec('cfg_end')
sleep(1)
