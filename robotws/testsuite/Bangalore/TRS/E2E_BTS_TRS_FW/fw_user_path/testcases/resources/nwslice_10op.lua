function split(inputstr, sep)

        if sep == nil then
                        sep = "%s"
        end
        t = {}; i = 1;
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                        t[i] = str
                        i = i + 1
        end
        return t

end
--mandatory update - enter number UEs that will be configured
ue_num=200
-- allowed maximum number of UEs
max_num=16000

sec_key="00112233445566778899AABBCCDDEEFF" --will be used for all configured UEs
start_imsi="244:09:1001201001" -- first 6 digits of start_imsi must be equal to PLMN

imsi_parts = split(start_imsi, ":")
imsi_len = string.len(imsi_parts[3])
--reference configuration file of ePC Sim
--TBD

--
exec("set_log log_to_file=off")

--mandatory update
--parameter should match the value in ./edaemon --port <DAEMON_PORT>
exec("set DAEMON_PORT=10000")

--mandatory update
--verify with eNodeB under test S1 interface
exec('set ENB_S1_IP="10.0.3.210"')
exec('set ENB_S1U_IP="10.0.3.210"')

exec('set ENB2_S1_IP="10.0.3.214"')
exec('set ENB2_S1U_IP="10.0.3.214"')

exec('set ENB3_S1_IP="10.0.3.218"')
exec('set ENB3_S1U_IP="10.0.3.218"')

exec('set ENB4_S1_IP="10.0.3.222"')
exec('set ENB4_S1U_IP="10.0.3.222"')

exec('set ENB5_S1_IP="10.0.3.226"')
exec('set ENB5_S1U_IP="10.0.3.226"')

exec('set ENB6_S1_IP="10.0.3.230"')
exec('set ENB6_S1U_IP="10.0.3.230"')

exec('set ENB7_S1_IP="10.0.3.234"')
exec('set ENB7_S1U_IP="10.0.3.234"')

exec('set ENB8_S1_IP="10.0.3.238"')
exec('set ENB8_S1U_IP="10.0.3.238"')

exec('set ENB9_S1_IP="10.0.3.242"')
exec('set ENB9_S1U_IP="10.0.3.242"')

exec('set ENB10_S1_IP="10.0.3.246"')
exec('set ENB10_S1U_IP="10.0.3.246"')


--mandatory update
--verify with host linux pc interface towards eNodeB
exec('set MME_S1_IP="10.0.1.26"')
exec('set MME2_S1_IP="10.0.1.27"')
exec('set MME3_S1_IP="10.0.1.28"')
exec('set MME4_S1_IP="10.0.1.29"')
exec('set MME5_S1_IP="10.0.1.30"')
exec('set MME6_S1_IP="10.0.1.31"')
exec('set MME7_S1_IP="10.0.1.46"')
exec('set MME8_S1_IP="10.0.1.47"')
exec('set MME9_S1_IP="10.0.1.48"')
exec('set MME10_S1_IP="10.0.1.49"')

exec('set SGW1_S1U_IP="10.0.1.20"')
exec('set SGW2_S1U_IP="10.0.1.21"')
exec('set SGW3_S1U_IP="10.0.1.22"')
exec('set SGW4_S1U_IP="10.0.1.23"')
exec('set SGW5_S1U_IP="10.0.1.24"')
exec('set SGW6_S1U_IP="10.0.1.25"')
exec('set SGW7_S1U_IP="10.0.1.44"')
exec('set SGW8_S1U_IP="10.0.1.45"')
exec('set SGW9_S1U_IP="10.0.1.50"')
exec('set SGW10_S1U_IP="10.0.1.51"')

exec('set SGW1_S11_IP="10.0.1.1"')

--possible update - update when changing UE addresses
--PGW addresses and UE IPs should belong to the same subnet
--IP pool 192.186.0.0/19 divided to four ip pools for 4 PGW's =>
--UE IP Pool PGW1: 192.186.0.0/21 =>  192.186.0.1 - 192.186.7.254
--UE IP Pool PGW2: 192.186.8.0/21 =>  192.186.8.1 - 192.186.15.254
--UE IP Pool PGW2: 192.186.16.0/21 => 192.186.16.1 - 192.186.23.254
--UE IP Pool PGW2: 192.186.24.0/21 => 192.186.24.1 - 192.186.24.254

exec('set PGW_ADDR1=4.7.254.207')

--no update needed - Standard LTE valc

exec('set MME_S1_PORT=36412')
exec('set SGW1_S1U_PORT=2152')
exec('set SGW1_S11_PORT=2153')

--parameters below should match the configuration of eNB UT
exec('set ENB_ID=0x052DE') 
exec('set ECI1=0x052DE01')-- ECI and ENB_ID should match (5 most significant digits of ECI are equal to ENB_ID)
--exec('set PLMN="244:09"') -- mcc:mnc
exec('set PLMN="244:09"') -- mcc:mnc
exec('set PCI1="80:2"')
exec('set TAC="124"')

for QCI = 128, 158 do
exec('set_qci qci='..QCI..' gbr=no priority=1 delay=80')
end

for QCI = 231, 254 do
exec('set_qci qci='..QCI..' gbr=yes priority=3 delay=80')
end


--possible update - most updates made in variables above
--Providing information real-life devices in the setup
exec('set_enb id=1 plmn=$PLMN s1=$ENB_S1_IP s1u=$ENB_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=2 plmn=404:99 s1=$ENB2_S1_IP s1u=$ENB2_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=3 plmn=777:12 s1=$ENB3_S1_IP s1u=$ENB3_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=4 plmn=777:17 s1=$ENB4_S1_IP s1u=$ENB4_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=5 plmn=777:18 s1=$ENB5_S1_IP s1u=$ENB5_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=6 plmn=777:19 s1=$ENB6_S1_IP s1u=$ENB6_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=7 plmn=777:20 s1=$ENB7_S1_IP s1u=$ENB7_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=8 plmn=777:21 s1=$ENB8_S1_IP s1u=$ENB8_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=9 plmn=777:22 s1=$ENB9_S1_IP s1u=$ENB9_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')
exec('set_enb id=10 plmn=777:23 s1=$ENB10_S1_IP s1u=$ENB10_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')

exec('set_cell id=11 enb=1 shared_plmn=404:99,777:12,777:17,777:18,777:19 tac=$TAC eci=$ECI1 pci=$PCI1')
exec('set_cell id=12 enb=1 shared_plmn=777:20,777:21,777:22,777:23 tac=125 eci=$ECI1 pci=$PCI1')

exec('mme_pool_area id=1 mmegi=1 plmn=244:09 tac_list=124')
exec('mme_pool_area id=2 mmegi=2 plmn=404:99 tac_list=124')
exec('mme_pool_area id=3 mmegi=3 plmn=777:12 tac_list=124')
exec('mme_pool_area id=4 mmegi=4 plmn=777:17 tac_list=124')
exec('mme_pool_area id=5 mmegi=5 plmn=777:18 tac_list=124')
exec('mme_pool_area id=6 mmegi=6 plmn=777:19 tac_list=124')
exec('mme_pool_area id=7 mmegi=7 plmn=777:20 tac_list=125')
exec('mme_pool_area id=8 mmegi=8 plmn=777:21 tac_list=125')
exec('mme_pool_area id=9 mmegi=9 plmn=777:22 tac_list=125')
exec('mme_pool_area id=10 mmegi=10 plmn=777:23 tac_list=125')

--possible update - most updates made in variables above
--configuring simulated devices (ePC)
exec('set_mme id=1 ip=:$DAEMON_PORT s1=$MME_S1_IP:$MME_S1_PORT pool=1:1 supported_rat=lte,nblte')
exec('set_mme id=2 ip=:$DAEMON_PORT s1=$MME2_S1_IP:$MME_S1_PORT pool=2:3 supported_rat=lte,nblte')
exec('set_mme id=3 ip=:$DAEMON_PORT s1=$MME3_S1_IP:$MME_S1_PORT pool=3:3 supported_rat=lte,nblte')
exec('set_mme id=4 ip=:$DAEMON_PORT s1=$MME4_S1_IP:$MME_S1_PORT pool=4:3 supported_rat=lte,nblte')
exec('set_mme id=5 ip=:$DAEMON_PORT s1=$MME5_S1_IP:$MME_S1_PORT pool=5:3 supported_rat=lte,nblte')
exec('set_mme id=6 ip=:$DAEMON_PORT s1=$MME6_S1_IP:$MME_S1_PORT pool=6:3 supported_rat=lte,nblte')
exec('set_mme id=7 ip=:$DAEMON_PORT s1=$MME7_S1_IP:$MME_S1_PORT pool=7:3 supported_rat=lte,nblte')
exec('set_mme id=8 ip=:$DAEMON_PORT s1=$MME8_S1_IP:$MME_S1_PORT pool=8:3 supported_rat=lte,nblte')
exec('set_mme id=9 ip=:$DAEMON_PORT s1=$MME9_S1_IP:$MME_S1_PORT pool=9:3 supported_rat=lte,nblte')
exec('set_mme id=10 ip=:$DAEMON_PORT s1=$MME10_S1_IP:$MME_S1_PORT pool=10:3 supported_rat=lte,nblte')


exec('set_sgw id=1 ip=:$DAEMON_PORT s1u=$SGW1_S1U_IP:$SGW1_S1U_PORT s11=$SGW1_S11_IP:$SGW1_S11_PORT s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=2 ip=:$DAEMON_PORT s1u=$SGW2_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=3 ip=:$DAEMON_PORT s1u=$SGW3_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=4 ip=:$DAEMON_PORT s1u=$SGW4_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=5 ip=:$DAEMON_PORT s1u=$SGW5_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=6 ip=:$DAEMON_PORT s1u=$SGW6_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=7 ip=:$DAEMON_PORT s1u=$SGW7_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=8 ip=:$DAEMON_PORT s1u=$SGW8_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=9 ip=:$DAEMON_PORT s1u=$SGW9_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
exec('set_sgw id=10 ip=:$DAEMON_PORT s1u=$SGW10_S1U_IP:$SGW1_S1U_PORT  s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')

exec('set_pgw id=1 ip=:$DAEMON_PORT apn=dyaptiveruskoap1 devtype=tun devname=tunPGW1 addr=$PGW_ADDR1/21 sgi_rcv_buff_size=1048576 sgi_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')

--FOR MULTIPDN configuration the line below should be uncommented, variable PGW_ADDR_2 should be defined and at least 1 UE should have default bearers for both PDNs.
-- exec('set_pgw id=2 ip=:$DAEMON_PORT apn=pdn2.net devtype=tun devname=tunPGW_2 addr=$PGW_ADDR_2/16')

--mandatory update
--Configuring UEs
--SEC_OP_KEY parameter and per-UE parameters sec_key and imsi should be aligned with UE configuration (real UE SIM card, LMTS config file, etc)
--if the real UE is used for testing and it's release > 9, it is necessary to turn on integrity, different from EIA0. It  may be done by adding parameter eia=snow3g in set_ue command.

exec('set_param SEC_OP_KEY=01020304050607080910111213141516')

--Checking if entered number of Ues is not greater than maximum allowed number of Ues. If it is greater, maximum allowed number will be configured.
if (ue_num>max_num) then 
        ue_conf=max_num
else
        ue_conf=ue_num
end

--Configuration cycle
current_imsi=string.sub(start_imsi,-imsi_len)

max_allowed_imsi = 999999999
if (imsi_len == 10) then
        max_allowed_imsi = 9999999999
end

exec('set_uec dev_sim_type=external id=1 enable_cus_if=on uec_cus_if_ip=10.0.2.1:40000 ip=:10000 pdn=1 devtype=tun addr=72.22.0.1/26 peer=:2152 gtpu=off retries=unlimited proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
--exec('set_uec dev_sim_type=external id=2 ip=:50001 pdn=1 devtype=tun devname=uec1 addr=61.1.1.1/16 peer=127.0.0.1:2152 retries=unlimited')
--divide the configured UE's to 4 PGW
--ue_conf = ue_conf/4

--start_imsi="244:09:1001201001" -- first 6 digits of start_imsi must be equal to PLMN

MAX_NUM_UES = 100
IMSI_FIRST_UE=1001201001
IMSI_FIRST_UE_SA=21645400


--imsi_parts = split(start_imsi, ":")
PGW_ADDR="4.7.254.207"
QCI = 128
QCI2 = 129
QCI3 = 130
QOS_ID = 2
for UEID = 1, 20 do
	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=12 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=244:09:'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096140211807135E0000018800000080 ue_nr_capabilities=E120700047D0FFB17DE8E6BC32001A0349CF9A44F3E0048018807C07C0203F08006F3826807BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0C0200413400FF00000026007C005638280381F84800E07C003968000038000395340006000010600000F2A8284801C003C00D40A80010203038980858808890C860C0D8FA09293139414922A400 ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010') 
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=external')
    exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')  
    exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1') 
    exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
	    QCI = QCI + 1
        if (QCI2 < 147) then 
        QCI2 = QCI2 + 1
        else QCI2 = QCI2 - 1 
        end
		if (QCI3 < 145) then 
		QCI3 = QCI3 + 1 
		else QCI3 = QCI3 - 2 
		end
end

--for LMTS UEs it is may be turned on the feature of network-initiated bearer activation by sending traffic packets to the specified port
exec('pgw_lmts_param bearer_activation_by_trf=on')

--turn on tracing per request from ePC Sim support
--exec('trace protocol=nas mme=1 on')
--exec('trace protocol=all on sgw=1 mme=1')
--exec('trace protocol=nas uec=1 on')
--exec('trace protocol=rrc uec=1 on')
--exec('trace protocol=all uec=1 mme=1 on')
--exec('trace protocol=nas mme=1 on')

--Turning on the information only about errors--for high perfomance
--exec('debug_log level=5')

--WARNINGS
if(max_allowed_imsi-tonumber(current_imsi)<0) then
        print("WARNING:OVERFLOW OF ALLOWED IMSI! CONFIGURATION STOPPED!")
end

if (ue_num>max_num) then
        print("WARNING:ENTERED NUMBER OF UEs "..tostring(ue_num).." IS GREATER THEN ALLOWED MAXIMUM NUMBER "..tostring(max_num)..". NUMBER OF CONFIGURED UEs IS:" .. tostring(max_num))
end
------------------
exec('cfg_end')


