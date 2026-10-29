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

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local EDAEMON_PORT="10000"
NUMBER_OF_UES_SA=30

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
exec('set_cell id=1 gnb=2 pci=16:2 tac=788 nrci=0x01 tdd_cell=off nr_arfcn=347380:425040 gscn=5313 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=788 nrci=0x02 tdd_cell=off nr_arfcn=347380:425040 gscn=5313 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=788 nrci=0x03 tdd_cell=on nr_arfcn=640000:640000 gscn=7915 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=788 nrci=0x04 tdd_cell=off nr_arfcn=167300:176300 gscn=2203 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 pci=18:0 tac=788 nrci=0x03 tdd_cell=off nr_arfcn=349000:431000 gscn=5389 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 pci=18:1 tac=788 nrci=0x04 tdd_cell=on nr_arfcn=650000:650000 gscn=8019 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---UE SA TDD with inactiveState capability and no RedCap, cell#3

for ue_id=1,4 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=6')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000014000000420E268000000010134640000E010113D86C003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA868007000B00000004008011AB130001020304050607080B101112131921252627284A44A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---UE SA TDD without inactiveState capability, cell#3

for ue_id=5,10 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null  nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=6')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E000382A003C1260C80008783803100D0098040603807546C28D6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B133582028680965944C1C07AD8202020E1DE38720C38002064F1F57001FF001C007FC000E201DB800040000000380004000000001546C4DD6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B13B582028680965944C1C07AD8202020E1DE38720C38002064F1F55000005000000E201DB8000400000003800040000000000210713400000000809A16003804044F6138036003C00301C1401E0C026007800683E0000000000000E54D000100000965950034AAA84801C002C00000010020044AC4C0004080C1014181C202C4044484C648494989CA12A9A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---UE SA TDD without inactiveState capability, cell#6 with eDRX

for ue_id=11,12 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 nr_idle_edrx_cycle_len=8 nr_eptw=1.28 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null  nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=6')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E000382A003C1260C80008783803100D0098040603807546C28D6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B133582028680965944C1C07AD8202020E1DE38720C38002064F1F57001FF001C007FC000E201DB800040000000380004000000001546C4DD6080A1A025965130701EB608080838778E1C830E0008193C7D5C007FC007001FF000388076E000100000000E0001000000000551B13B582028680965944C1C07AD8202020E1DE38720C38002064F1F55000005000000E201DB8000400000003800040000000000210713400000000809A16003804044F6138036003C00301C1401E0C026007800683E0000000000000E54D000100000965950034AAA84801C002C00000010020044AC4C0004080C1014181C202C4044484C648494989CA12A9A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---UE SA TDD with inactiveState capability and RedCap, cell#3

for ue_id=13, 16 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null  nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr red_cap=true enb=2 cell=3')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603807546C28D6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B133582028680965944C44003D6C10101070EF1C39061C00103278FAB800FF800E003FE000E10001DB800040000000380004000000001546C4DD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE003FE003800FF80038400076E000100000000E0001000000000551B13B582028680965944C44003D6C10101070EF1C39061C00103278FAA800002800000E10001DB8000400000003800040000000000210713400000000809A3A00001C020227B118001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55543C001C002C00000010020046AC500004080C1014181C202C4044484C648494989CA1192814A20001422502000180')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---UE SA TDD with inactiveState capability, cell#6 with eDRX

for ue_id=17,20 do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 nr_idle_edrx_cycle_len=8 nr_eptw=1.28 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null  nea=null suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=6')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000014000000420E268000000010134640000E010113D86C003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA868007000B00000004008011AB130001020304050607080B101112131921252627284A44A9440000840')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
--maing
exec('set_qosflow id=1 5qi=5 default=off')
exec('set_qosflow id=2 5qi=7 default=on')
exec('set_qosflow id=3 5qi=6 default=off')
exec('set_qosflow id=4 5qi=8 default=off')

exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')
exec('qosrule_set id=3 proto=udp qos_flow=3')
exec('qosrule_set id=4 proto=udp qos_flow=4')
exec('set_nwslice id=1 qos_flows=1,2,3,4 qos_rules=1,2,3,4 snssai=0x01:0xD143A5 default=on amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('ue_param id=1 nr_usage_setting=voice_centric')
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
exec('start version_check=off')
sleep(1)
