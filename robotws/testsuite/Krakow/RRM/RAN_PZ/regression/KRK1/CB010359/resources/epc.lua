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
ue_num=500
-- allowed maximum number of UEs
max_num=500

sec_key="00112233445566778899AABBCCDDEEFF" --will be used for all configured UEs
start_imsi="244:09:1001201001" -- first 6 digits of start_imsi must be equal to PLMN

imsi_parts = split(start_imsi, ":")
imsi_len = string.len(imsi_parts[3])
--reference configuration file of ePC Sim
--TBD

--
exec("set_log log_to_file=on")

--mandatory update
--parameter should match the value in ./edaemon --port <DAEMON_PORT>
exec("set DAEMON_PORT=10000")

--mandatory update
--verify with eNodeB under test S1 interface
exec('set ENB_S1_IP="10.0.1.2"')
exec('set ENB_S1U_IP="10.0.1.2"')


--mandatory update
--verify with host linux pc interface towards eNodeB
exec('set MME_S1_IP="10.0.1.1"')
exec('set SGW1_S1U_IP="10.0.1.1"')
exec('set SGW1_S11_IP="10.0.1.1"')
--possible update - update when changing UE addresses
--PGW addresses and UE IPs should belong to the same subnet
--IP pool 192.186.0.0/19 divided to four ip pools for 4 PGW's =>
--UE IP Pool PGW1: 192.186.0.0/21 =>  192.186.0.1 - 192.186.7.254
--UE IP Pool PGW2: 192.186.8.0/21 =>  192.186.8.1 - 192.186.15.254
--UE IP Pool PGW2: 192.186.16.0/21 => 192.186.16.1 - 192.186.23.254
--UE IP Pool PGW2: 192.186.24.0/21 => 192.186.24.1 - 192.186.24.254

exec('set PGW_ADDR1=41.7.254.254')

--no update needed - Standard LTE values
exec('set MME_S1_PORT=36412')
exec('set SGW1_S1U_PORT=2152')
exec('set SGW1_S11_PORT=2153')

--parameters below should match the configuration of eNB UT
exec('set ENB_ID=0x00001') 
exec('set PLMN="244:09"') -- mcc:mnc

--possible update - most updates made in variables above
--Providing information real-life devices in the setup
exec('set_enb id=1 plmn=$PLMN s1=$ENB_S1_IP s1u=$ENB_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')

--possible update - most updates made in variables above
--configuring simulated devices (ePC)
exec('set_mme id=1 ip=:$DAEMON_PORT s1=$MME_S1_IP:$MME_S1_PORT mmegi=1 mmec=3 supported_plmn=$PLMN  supported_rat=lte,nblte')
exec('set_sgw id=1 ip=:$DAEMON_PORT s1u=$SGW1_S1U_IP:$SGW1_S1U_PORT s11=$SGW1_S11_IP:$SGW1_S11_PORT s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576')
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

--divide the configured UE's to 4 PGW
--ue_conf = ue_conf/4

for i=1,ue_conf,1 do
                if(max_allowed_imsi-tonumber(current_imsi)>=0) then
                        exec('set_ue external id='..tonumber(i)..' pdn=1 sec_key='..sec_key..' eea=aes eia=aes imsi='..imsi_parts[1]..':'..imsi_parts[2]..':'..current_imsi) 
                        exec('set_bearer id=1 ue='..tonumber(i)..' default=on priority=7 qci=6 pdn=1 trf_type=external')
                        exec('set_bearer id=2 ue='..tonumber(i)..' default=off qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 pdn=1')
                        exec('set_bearer id=3 ue='..tonumber(i)..' default=off qci=5 pdn=1') 
                        exec('set_bearer id=4 ue='..tonumber(i)..' default=off qci=9 pdn=1')
                        exec('set_bearer id=5 ue='..tonumber(i)..' default=off qci=8 pdn=1')

                        current_imsi=current_imsi+1
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
exec('debug_log level=0')

--WARNINGS
if(max_allowed_imsi-tonumber(current_imsi)<0) then
        print("WARNING:OVERFLOW OF ALLOWED IMSI! CONFIGURATION STOPPED!")
end

if (ue_num>max_num) then
        print("WARNING:ENTERED NUMBER OF UEs "..tostring(ue_num).." IS GREATER THEN ALLOWED MAXIMUM NUMBER "..tostring(max_num)..". NUMBER OF CONFIGURED UEs IS:" .. tostring(max_num))
end

exec('link_ctrl_param hb_period=180 hb_retries=10 app_type=mme')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec("set_amf_region id=1 tac_list=0xA05078 plmn=450:08")
exec("set_amf id=1 daemon=:10000 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2")
exec("amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc")
--exec("set_upf id=1 daemon=:10000 type=simulated addr=1.2.4.1/24 ngu=192.168.1.123")
exec("set_upf id=1 daemon=:10000 type=simulated addr=1.2.4.1/24 ngu=10.0.1.100")
exec('trace protocol=all amf=1 on')
 
-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec("set_gnb id=2 type=external plmn=450:08 ng=10.0.1.2 gnb_id=0x401A9 daemon=:10000 x2_peers=none amf=1")
exec("set_cell id=1 gnb=2 pci=0:1 tac=8000 nrci=0x0 tdd_cell=on nr_arfcn=510000:510000 mandatory_for_activation=off")
 
-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
 
exec("set_ue lmts id=9000 nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1")
exec("ue_param id=9000 ue_nr_capabilities=01000000010800000004D780000000000001150000000000000150")
 
exec("set_qosflow id=1 5qi=6 default=on")
exec("set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=9000 amf=1")

exec("link_ctrl_param use_hb=off")
exec("sim_trace amf=1 protocol=ng on")

------------------
exec('cfg_end')


