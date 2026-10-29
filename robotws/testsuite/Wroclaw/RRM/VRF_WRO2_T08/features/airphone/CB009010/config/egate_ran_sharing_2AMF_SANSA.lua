---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"
local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local AMF2_NG_ADDR="10.0.1.3"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"
local EDAEMON_PORT="10000"
NUMBER_OF_UES_SA=10

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=788 proxy='..SERVER_IP..':12219|'..SERVER_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=100,200,777,788,111,222,444,333')
exec('set_mme id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..SERVER_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=100,200 plmn=311:492')
exec('set_amf_region id=2 tac_list=100,200 plmn=311:495')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('set_amf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null ignore_ng=on')
exec('amf_param id=2 full_nas_auth=on nia=null nea=null ignore_ng=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 plmnList=311:489,311:492,311:495,311:498 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none')
exec('set_cell id=1 gnb=2 pci=16:2 tac=100 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 eci=0x000021f nr_arfcn=135760:126380 gscn=1582 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 eci=0x000021f nr_arfcn=135760:126380 gscn=1582 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 sctp_rto_min=100 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
--registration to PLMN: 311:489
for ue_id=1,5 do
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
         ' ue_nr_capabilities=E1A00000074E5A031E000382A003C1260C80008783803100D0098040603807546C28D6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B133582028680965944C1C07AD8202020E1DE38720C38002064F1F57001FF001C007FC000E201DB800040000000380004000000001546C4DD6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B13B582028680965944C1C07AD8202020E1DE38720C38002064F1F55000005000000E201DB8000400000003800040000000000210713400000000809A16003804044F6138036003C00301C1401E0C026007800683E0000000000000E54D000100000965950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12A9A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

--registration to PLMN: 311:492
for ue_id=6,8 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:492:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E000382A003C1260C80008783803100D0098040603807546C28D6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B133582028680965944C1C07AD8202020E1DE38720C38002064F1F57001FF001C007FC000E201DB800040000000380004000000001546C4DD6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B13B582028680965944C1C07AD8202020E1DE38720C38002064F1F55000005000000E201DB8000400000003800040000000000210713400000000809A16003804044F6138036003C00301C1401E0C026007800683E0000000000000E54D000100000965950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12A9A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

--registration to PLMN: 311:495
for ue_id=9,10 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:495:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E000382A003C1260C80008783803100D0098040603807546C28D6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B133582028680965944C1C07AD8202020E1DE38720C38002064F1F57001FF001C007FC000E201DB800040000000380004000000001546C4DD6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B13B582028680965944C1C07AD8202020E1DE38720C38002064F1F55000005000000E201DB8000400000003800040000000000210713400000000809A16003804044F6138036003C00301C1401E0C026007800683E0000000000000E54D000100000965950034AAA84801C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12A9A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=5 default=on')
exec('set_qosflow id=2 5qi=1')
exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('set_nwslice id=1 qos_flows=1,2 qos_rules=1,2 snssai=0x80:0xD143A6 default=on amf=1,2')
---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('ue_param id=2 nr_usage_setting=voice_centric')
exec('amf_param id=1 ims_voice_3gpp=on')

-- MISC
exec('debug_log level=4')
exec('sim_debug_log level=1 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace uec=1 protocol=all on')
exec('sim_trace amf=1 protocol=all on')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('set_log flush')
exec('cfg_end')
exec('set_log log_to_file=on')
sleep(1)
