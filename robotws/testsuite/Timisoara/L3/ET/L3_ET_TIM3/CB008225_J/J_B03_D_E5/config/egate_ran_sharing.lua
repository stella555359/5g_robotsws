---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"
local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local AMF2_NG_ADDR="10.0.1.3"
local AMF3_NG_ADDR="10.0.1.4"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"
local EDAEMON_PORT="10000"
NUMBER_OF_UES_SA=10

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf_region id=2 tac_list=0,100,200,258,788 plmn=311:492')
exec('set_amf_region id=3 tac_list=0,100,200,258,788 plmn=311:495')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('set_amf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=2 pointer=1')
exec('set_amf id=3 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF3_NG_ADDR..':38412 region=3 set_id=3 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('amf_param id=2 full_nas_auth=on nia=null nea=null')
exec('amf_param id=3 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none nssai=0x01:0xD143A5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=258 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

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
exec('set_qosflow id=1 5qi=8 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1-3')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

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
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc off')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('set_log flush')
exec('cfg_end')
exec('set_log log_to_file=on')
sleep(1)
