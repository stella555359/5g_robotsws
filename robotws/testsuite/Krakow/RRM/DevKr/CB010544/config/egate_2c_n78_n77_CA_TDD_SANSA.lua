-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local GNB_XN_ADDR="10.0.1.2"
local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_IP="127.0.0.1"
local EDAEMON_PORT="10000"

require('os')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.90')

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
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 gscn=7853 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 gscn=7992 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=650000:650000')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=17:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=7853 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,20 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    if (i<10) then 	-- full power saving BWP capabilities 100MHz
        -- (phyXdd and phyFrx) or
        -- (tddAdd and not fr2Add) or
        -- (not fddAdd and fr1Add) or
        -- (tddAdd and fr1Add)
        exec('ue_param id='..i..' ue_nr_capabilities=21A000000F00000000140040602F04000000AA82400808004800420626D50BFF2FFC0440E2680000005378000000000000115000000000000015000001002004088A')
    elseif(i>=10 and i<13) then -- bwp-SameNumerology IE only
        exec('ue_param id='..i..' ue_nr_capabilities=21A0000007400406020000000000900202001200108189B542FFCBFF0110389A00000014DE000000000000045400000000000005400000400801022280')
    elseif(i>=13 and i<=15) then -- bwp-SwitchingDelay IE only
        exec('ue_param id='..i..' ue_nr_capabilities=21A000000F000000001400406020000000000900202001200100189B545FF97FE0220713400000029BC00000000000008A80000000000000A80000080100204450')
    -- UE Cap supporting band n41, n77, n78, n79 and small BWP 80MHz: supportedBandwidthDL fr1 : mhz80, supportedBandwidthUL fr1 : mhz80, CA working, PS-BWP working
    elseif(i>=16 and i<=20) then
        exec('ue_param id='..i..' ue_nr_capabilities=E1A00000074E7A031E000384A0003C10010180BF16400042EB82C006241A0130180603807546C28D6080A1A025965130F001EB608080838778E1C830E0008193C7C5C007FC007001FF000608003B7000080000000700008000000002A8D899AC10143404B2CA261E003D6C10101070EF1C39061C00103278F8B800FF800E003FE000C100076E000100000000E0001000000000551B137582028680965944C3C007AD8202020E1DE38720C38002064F1F17001FF001C007FC00182000EDC000200000001C0002000000000AA36276B04050D012CB28987800F5B0404041C3BC70E418700040C9E3E2A00000A00000304001DB80004000000038000400000000002B0F134003898000001FE7FFFFFFFFC00C04D80983200007008089EC36001800140E0A00E06013003800341F00641000000A41000002801E52DE52D0041000009659504000065965401D29ABA53543400380058000020200400808020043162600020406080A0C0E10162022242632424A4C4E5094')
    end
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=5 default=on')

exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1 qos_rules=1')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 qos_flows=1 qos_rules=1')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)

