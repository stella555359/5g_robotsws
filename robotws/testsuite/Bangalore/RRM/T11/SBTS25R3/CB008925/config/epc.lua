require('os')
os.execute('sudo ip link add dummy0 type dummy')
os.execute('sudo ip addr add 192.168.1.123/24 dev dummy0')

exec("set_log log_to_file=on max_log_size=104857600 max_file_num=3")
exec("set_sgw id=1 type=simulated daemon=127.0.0.1:10000 s1u=10.0.1.1:2152 s11=10.0.1.1:2153")
exec("set_pgw id=1 type=simulated apn=nokia_1.net daemon=127.0.0.1:10000 addr=11.1.0.0/16 devtype=tun devname=tunPGW_1")
exec("set_pgw id=2 type=simulated apn=nokia_2.net daemon=127.0.0.1:10000 addr=11.2.0.0/16 devtype=tun devname=tunPGW_2")
exec("mme_pool_area id=1 plmn=244:08 mmegi=1 tac_list=123,124")
exec("set_mme id=1 type=simulated daemon=127.0.0.1:10000 s1=10.0.1.1:36412 pool=1:1 supported_rat=lte,nblte")

exec("set EDAEMON_PORT=10000")
-- #---------------------------------------------------------------------------------------------------
-- #5GCN CONFIGURATION
-- #---------------------------------------------------------------------------------------------------
exec("set_amf_region id=1 tac_list=124 plmn=244:08")
exec("set_amf id=1 daemon=:$EDAEMON_PORT ng=10.0.1.1:38412 region=1 set_id=2 pointer=2")
exec("amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc")
exec("set_upf id=1 daemon=:$EDAEMON_PORT type=simulated addr=1.2.4.1/24 ngu=192.168.1.123")

-- #---------------------------------------------------------------------------------------------------
-- #ENB CONFIGURATION
-- #---------------------------------------------------------------------------------------------------

exec("set_enb id=1 type=external enb_id_macro=0x00001 plmn=244:08 s1=10.0.1.2")
exec("set_cell id=1 enb=1 technology=lte eci=0x0000101 pci=0:1 bw=10MHz proxy=:2152 tac=123 tdd_cell=off")

-- #---------------------------------------------------------------------------------------------------
-- #GNB CONFIGURATION
-- #---------------------------------------------------------------------------------------------------

exec("set_gnb id=2 type=external plmn=244:08 ng=10.0.1.2 gnb_id=0x1 daemon=:$EDAEMON_PORT x2_peers=none amf=1")
exec("set_cell id=102 gnb=2 pci=139:2 tac=124 nrci=0x1 tdd_cell=off nr_arfcn=142600:153600")

exec("set_uec dev_sim_type=external id=1 daemon=127.0.0.1:10000 gtpu=on pdn=1 addr=11.1.255.253/16 pdn=2 addr=11.2.255.252/16 peer=10.0.2.1:2152 retries=unlimited")
exec("set_param SEC_OP_KEY=ABCDEF0123456789ABCDEF0123456789")


-- #---------------------------------------------------------------------------------------------------
-- #UE CONFIGURATION
-- #---------------------------------------------------------------------------------------------------

exec("set_ue lmts id=101 nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=2")
exec("ue_param id=101 ue_nr_capabilities=01000000010800000004D780000000000001150000000000000150")


exec("set_qosflow id=1 5qi=6 default=on")
exec("set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=101 amf=1")

local mcc = 244
local mnc = 8
local mnc_length = 2
local msin = 8723000001
local ip_1 = 11
local ip_2 = 1
local ip_3 = 0
local ip_4 = 1
for ue_id=1,10 do
    exec("set_ue cus id="..ue_id.." sec_key=0102030405060708090A0B0C0D000001 imsi="..mcc..":"..string.format('%0'..mnc_length..'d', mnc)..":"..msin.."")
    exec("set_bearer id=1 ue="..ue_id.." default=true qci=9 trf_type=external ip="..ip_1.."."..ip_2.."."..ip_3.."."..ip_4.."")
    exec("set_bearer id=2 ue="..ue_id.." qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1")
    exec("set_bearer id=3 ue="..ue_id.." qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1")
    exec("set_bearer id=4 ue="..ue_id.." qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1")
    exec("set_bearer id=5 ue="..ue_id.." qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1")
    exec("set_bearer id=6 ue="..ue_id.." qci=5 pdn=1")
    exec("set_bearer id=7 ue="..ue_id.." qci=6 pdn=1")
    exec("set_bearer id=8 ue="..ue_id.." qci=7 pdn=1")
    exec("set_bearer id=9 ue="..ue_id.." qci=8 pdn=1")
     msin = msin + 1
    ip_4 = ip_4 + 1
    if ip_4 >= 256 then
        ip_3 = ip_3 + 1
        ip_4 = 0
    end
    if ip_3 >= 256 then
        ip_2 = ip_2 + 1
        ip_3 = 0
    end
    if ip_2 >= 256 then
        ip_1 = ip_1 + 1
        ip_2 = 0
    end
end

exec("trace protocol=nas mme=1 on")
exec("trace protocol=s1 mme=1 on")
exec("set_cnode")
exec("debug_log level=5")
exec("set_log log_to_file=on")
exec("pgw_lmts_param bearer_activation_by_trf=on")
exec("link_ctrl_param hb_period=180 hb_retries=10 app_type=mme")
exec("cfg_end")

--
-- exec("set_ue cus id=2 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000002 cell=2 release=15
-- exec("set_bearer id=1 ue=2 default=true qci=9 trf_type=external ip=11.1.0.2
-- exec("set_bearer id=2 ue=2 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=2 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=2 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=2 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=2 qci=5 pdn=1
-- exec("set_bearer id=7 ue=2 qci=6 pdn=1
-- exec("set_bearer id=8 ue=2 qci=7 pdn=1
-- exec("set_bearer id=9 ue=2 qci=8 pdn=1
--
-- exec("set_ue cus id=3 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000003 cell=2 release=15
-- exec("set_bearer id=1 ue=3 default=true qci=9 trf_type=external ip=11.1.0.3
-- exec("set_bearer id=2 ue=3 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=3 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=3 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=3 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=3 qci=5 pdn=1
-- exec("set_bearer id=7 ue=3 qci=6 pdn=1
-- exec("set_bearer id=8 ue=3 qci=7 pdn=1
-- exec("set_bearer id=9 ue=3 qci=8 pdn=1
--
-- exec("set_ue cus id=4 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000004 cell=2 release=15
-- exec("set_bearer id=1 ue=4 default=true qci=9 trf_type=external ip=11.1.0.4
-- exec("set_bearer id=2 ue=4 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=4 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=4 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=4 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=4 qci=5 pdn=1
-- exec("set_bearer id=7 ue=4 qci=6 pdn=1
-- exec("set_bearer id=8 ue=4 qci=7 pdn=1
-- exec("set_bearer id=9 ue=4 qci=8 pdn=1
--
-- exec("set_ue cus id=5 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000005 cell=2 release=15
-- exec("set_bearer id=1 ue=5 default=true qci=9 trf_type=external ip=11.1.0.5
-- exec("set_bearer id=2 ue=5 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=5 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=5 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=5 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=5 qci=5 pdn=1
-- exec("set_bearer id=7 ue=5 qci=6 pdn=1
-- exec("set_bearer id=8 ue=5 qci=7 pdn=1
-- exec("set_bearer id=9 ue=5 qci=8 pdn=1
--
-- exec("set_ue cus id=6 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000006 cell=2 release=15
-- exec("set_bearer id=1 ue=6 default=true qci=9 trf_type=external ip=11.1.0.6
-- exec("set_bearer id=2 ue=6 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=6 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=6 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=6 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=6 qci=5 pdn=1
-- exec("set_bearer id=7 ue=6 qci=6 pdn=1
-- exec("set_bearer id=8 ue=6 qci=7 pdn=1
-- exec("set_bearer id=9 ue=6 qci=8 pdn=1
--
-- exec("set_ue cus id=7 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000007 cell=2 release=15
-- exec("set_bearer id=1 ue=7 default=true qci=9 trf_type=external ip=11.1.0.7
-- exec("set_bearer id=2 ue=7 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=7 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=7 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=7 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=7 qci=5 pdn=1
-- exec("set_bearer id=7 ue=7 qci=6 pdn=1
-- exec("set_bearer id=8 ue=7 qci=7 pdn=1
-- exec("set_bearer id=9 ue=7 qci=8 pdn=1
--
-- exec("set_ue cus id=8 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000008 cell=2 release=15
-- exec("set_bearer id=1 ue=8 default=true qci=9 trf_type=external ip=11.1.0.8
-- exec("set_bearer id=2 ue=8 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=8 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=8 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=8 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=8 qci=5 pdn=1
-- exec("set_bearer id=7 ue=8 qci=6 pdn=1
-- exec("set_bearer id=8 ue=8 qci=7 pdn=1
-- exec("set_bearer id=9 ue=8 qci=8 pdn=1
--
-- exec("set_ue cus id=9 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000009 cell=2 release=15
-- exec("set_bearer id=1 ue=9 default=true qci=9 trf_type=external ip=11.1.0.9
-- exec("set_bearer id=2 ue=9 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=9 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=9 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=9 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=9 qci=5 pdn=1
-- exec("set_bearer id=7 ue=9 qci=6 pdn=1
-- exec("set_bearer id=8 ue=9 qci=7 pdn=1
-- exec("set_bearer id=9 ue=9 qci=8 pdn=1
--
-- exec("set_ue cus id=10 sec_key=0102030405060708090A0B0C0D000001 imsi=244:08:0000000010 cell=2 release=15
-- exec("set_bearer id=1 ue=10 default=true qci=9 trf_type=external ip=11.1.0.10
-- exec("set_bearer id=2 ue=10 qci=1 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=3 ue=10 qci=2 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=4 ue=10 qci=3 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=5 ue=10 qci=4 gbr_ul=30 gbr_dl=30 mbr_ul=31 mbr_dl=31 pdn=1
-- exec("set_bearer id=6 ue=10 qci=5 pdn=1
-- exec("set_bearer id=7 ue=10 qci=6 pdn=1
-- exec("set_bearer id=8 ue=10 qci=7 pdn=1
-- exec("set_bearer id=9 ue=10 qci=8 pdn=1
--
--
