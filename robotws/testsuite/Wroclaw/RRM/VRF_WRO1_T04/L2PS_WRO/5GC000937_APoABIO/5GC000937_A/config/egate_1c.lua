-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
--local AP_CONFIG_PATH="/home/ute/Auto5G/testsuite/migration/Wroclaw/RRM/5G_SW_WRO/resources/AirPhoneConfig_SA_TDD.xml"
local AP_CONFIG_PATH="AirphoneConfig.xml"
local EDAEMON_PORT="10000"

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
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
--exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633364:633364')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 file='..AP_CONFIG_PATH)

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,50 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')

--UE CAPABLE:
    exec('ue_param id='..i..' ue_nr_capabilities=AD80000001B00606000149A30004C1A12006201A0130080C43002A8D89BAC31943418A810700001CA090145B262A85813E439F40478C73E618F28581C0E1E045FF97FE260001C00150389A00000025FFFFFFFFF0010137D04C00E000A070500703009401C0018090010180A0040000040240268000E7CC31E50B0301E0000000000000454000080000000008008554000004008010')
--UE NON-CAPABLE:
    --exec('ue_param id='..i..' ue_nr_capabilities=FDA000000147580303000049A30004C1A0603100D0098040621805506C28D618C21A0C54083E5008A2D931542C09F21CFA023C639F30C7942C0E070F04427909E0E00702A0D88DAC31843418A8107CA01125B262A82873EC08F18E7CC31E50B0381C3C093C04F001C00E00403134AAA2AA805C182340A0000480BFFFFFFFFE0060144046F40B00E000A070300E0600A80E000C0090010180A00400000400C13400073E618F2858181F004010010000080400800001009943581B404002080400002013AE928200002EBA4801694555038A0100219008A05028140A05028140A0000040C008018020040600400C0100218A030441424640')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace amf=1 protocol=ng on')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('sim_start version_check=off')
