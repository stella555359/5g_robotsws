exec("set_enb id=1 plmn=244:09 s1=10.0.1.2 enb_id_macro=0x00001  daemon=:10000")
exec("set_cell id=1 enb=1 tac=124 eci=0x0000101 pci=0:1")
exec("set_cell id=2 enb=1 tac=124 eci=0x0000102 pci=0:2")
exec("set_cell id=3 enb=1 tac=124 eci=0x0000103 pci=1:0")
exec("set_cell id=4 enb=1 tac=124 eci=0x0000104 pci=1:1")
exec("set_cell id=5 enb=1 tac=124 eci=0x0000105 pci=1:2")
exec("set_cell id=6 enb=1 tac=124 eci=0x0000106 pci=2:0")
exec("set_cell id=7 enb=1 tac=124 eci=0x0000107 pci=2:1")
exec("set_cell id=8 enb=1 tac=124 eci=0x0000108 pci=2:2")
exec("set_cell id=9 enb=1 tac=124 eci=0x0000109 pci=3:0")
exec("set_cell id=10 enb=1 tac=124 eci=0x000010A pci=3:1")
exec("set_cell id=11 enb=1 tac=124 eci=0x000010B pci=3:2")
exec("set_cell id=12 enb=1 tac=124 eci=0x000010C pci=4:0")
exec("set_mme id=1 ip=:10000 s1=10.0.1.1:36412 mmegi=1 mmec=3 supported_plmn=244:09 supported_plmn=666:14 supported_plmn=555:12")
exec("set_sgw id=1 ip=:10000 s1u=10.0.1.1:2152 s11=10.0.1.1:2153")
exec("set_pgw id=1 ip=:10000 apn=nokia1.net devtype=tun devname=tunPGW_1 addr=30.61.255.254/16")
exec("set_pgw id=2 ip=:10000 apn=nokia2.net devtype=tun devname=tunPGW_2 addr=30.62.255.254/16")
exec("set_qci qci=100 gbr=yes priority=15 delay=80")
exec("set_qci qci=128 gbr=yes priority=15 delay=80")
exec("set_qci qci=129 gbr=yes priority=15 delay=80")
exec("set_qci qci=130 gbr=yes priority=15 delay=80")
exec("set_qci qci=131 gbr=yes priority=15 delay=80")
exec("set_qci qci=135 gbr=yes priority=15 delay=80")
exec("set_qci qci=136 gbr=yes priority=15 delay=80")
exec("set_qci qci=160 gbr=yes priority=15 delay=80")
exec("set_qci qci=161 gbr=no priority=15 delay=80")
exec("set_qci qci=200 gbr=no priority=15 delay=80")
exec("set_qci qci=253 gbr=yes priority=15 delay=80")
exec("set_qci qci=254 gbr=yes priority=15 delay=80")
exec("set_param SEC_OP_KEY=01020304050607080910111213141516")
--================================================================================
-- UEs section
--================================================================================
local mcc = 244
local mnc = 9
local mnc_length = 2
local msin = 8723000001
local ip_1 = 30
local ip_2 = 61
local ip_3 = 0
local ip_4 = 1
for ue_id=1,10 do
    exec("set_ue lmts id="..ue_id.." sec_key=000102030405060708090a0b0c0d0e0f imsi="..mcc..":"..string.format('%0'..mnc_length..'d', mnc)..":"..msin.." eea=null eia=null")
    exec("set_bearer id=1 ue="..ue_id.." default=on qci=9 ip="..ip_1.."."..ip_2.."."..ip_3.."."..ip_4.." trf_type=external")
    exec("set_bearer id=2 ue="..ue_id.." default=off qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31")
    exec("set_bearer id=3 ue="..ue_id.." default=off qci=65 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=4 ue="..ue_id.." default=off qci=5")
    exec("set_bearer id=5 ue="..ue_id.." default=off qci=6")
    exec("set_bearer id=6 ue="..ue_id.." default=off qci=7")
    exec("set_bearer id=7 ue="..ue_id.." default=off qci=100 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=8 ue="..ue_id.." default=off qci=128 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=9 ue="..ue_id.." default=off qci=129 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=10 ue="..ue_id.." default=off qci=130 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=11 ue="..ue_id.." default=off qci=131 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=12 ue="..ue_id.." default=off qci=135 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=13 ue="..ue_id.." default=off qci=136 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=14 ue="..ue_id.." default=off qci=254 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64")
    exec("set_bearer id=15 ue="..ue_id.." default=off qci=200")
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
--================================================================================
exec("trace protocol=nas mme=1 on")
exec("trace protocol=s1 mme=1 on")
exec("set_cnode")
exec("debug_log level=5")
exec("set_log log_to_file=on")
exec("pgw_lmts_param bearer_activation_by_trf=on")
exec("link_ctrl_param hb_period=180 hb_retries=10 app_type=mme")
exec("cfg_end")
