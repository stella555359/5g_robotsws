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
ue_num=100
-- allowed maximum number of UEs
max_num=100

sec_key="00112233445566778899AABBCCDDEEFF" --will be used for all configured UEs
start_imsi="242:08:1200013466" -- first 6 digits of start_imsi must be equal to PLMN

imsi_parts = split(start_imsi, ":")
imsi_len = string.len(imsi_parts[3])

exec("set_log log_to_file=off")

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

exec('set PGW_ADDR1=30.61.255.254')

--no update needed - Standard LTE values
exec('set MME_S1_PORT=36412')
exec('set SGW1_S1U_PORT=2152')
exec('set SGW1_S11_PORT=2153')

--parameters below should match the configuration of eNB UT

exec('set ENB_ID=0x00001') 
exec('set PLMN="242:08"') -- mcc:mnc

--possible update - most updates made in variables above
--Providing information real-life devices in the setup
exec('set_enb id=1 plmn=$PLMN s1=$ENB_S1_IP s1u=$ENB_S1U_IP enb_id_macro=$ENB_ID daemon=:$DAEMON_PORT')

--possible update - most updates made in variables above
--configuring simulated devices (ePC)
exec('set_mme id=1 ip=:$DAEMON_PORT s1=$MME_S1_IP:$MME_S1_PORT mmegi=1 mmec=3 supported_plmn=$PLMN')
exec('set_sgw id=1 ip=:$DAEMON_PORT s1u=$SGW1_S1U_IP:$SGW1_S1U_PORT s11=$SGW1_S11_IP:$SGW1_S11_PORT')
exec('set_pgw id=1 ip=:$DAEMON_PORT apn=nokia1.net devtype=tun devname=tunPGW1 addr=$PGW_ADDR1/16')

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

pdnswitch=1
for i=1,ue_conf,1 do
		if(max_allowed_imsi-tonumber(current_imsi)>=0) then
			exec('set_ue external id='..tonumber(i)..' pdn='..tonumber(pdnswitch)..' sec_key='..sec_key..' eea=aes eia=aes imsi='..imsi_parts[1]..':'..imsi_parts[2]..':'..current_imsi) 
			exec('set_bearer id=1 ue='..tonumber(i)..' default=on priority=7 qci=6 pdn='..tonumber(pdnswitch)..' trf_type=external')
			exec('set_bearer id=2 ue='..tonumber(i)..' default=off qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 pdn='..tonumber(pdnswitch)..'')
			exec('set_bearer id=3 ue='..tonumber(i)..' default=off qci=5 pdn='..tonumber(pdnswitch)..'') 
			exec('set_bearer id=4 ue='..tonumber(i)..' default=off qci=9 pdn='..tonumber(pdnswitch)..'')
			exec('set_bearer id=5 ue='..tonumber(i)..' default=off qci=8 pdn='..tonumber(pdnswitch)..'')

			current_imsi=current_imsi+1
		end
end


--for LMTS UEs it is may be turned on the feature of network-initiated bearer activation by sending traffic packets to the specified port
exec('pgw_lmts_param bearer_activation_by_trf=on')

--turn on tracing per request from ePC Sim support
--Turning on the information only about errors--for high perfomance
exec('debug_log level=5')

--WARNINGS
if(max_allowed_imsi-tonumber(current_imsi)<0) then
	print("WARNING:OVERFLOW OF ALLOWED IMSI! CONFIGURATION STOPPED!")
end

if (ue_num>max_num) then
	print("WARNING:ENTERED NUMBER OF UEs "..tostring(ue_num).." IS GREATER THEN ALLOWED MAXIMUM NUMBER "..tostring(max_num)..". NUMBER OF CONFIGURED UEs IS:" .. tostring(max_num))
end
------------------
exec('cfg_end')
