local edaemon_ip = '127.0.0.1'
local edaemon_port = '10000'

local s1_ip = "10.0.1.1" -- MME address

local pgw_net_part = '1.7'
local pgw_ip = '1.7.255.254/16'

local s1u_port = "2152"
local s11_port = "2153"

local mme_port = "36412" 
local mmegi = "1"
local mmec = "3"

local uec_ip = "11.7.255.254/16"
local uec_net_part = "11.7"

local uec_proxy_port = "2152"
local tac = "124"
local fgi_missing_14 = "2,3,5,6,7,13,16,17,18,20,21,25,28,31"

-- Limit for this configuration is 250 UEs per Cell
local ue_count_per_cell = 150
local sec_key='0102030405060708090A0B0C0D0E'
local sec_op_key = 'ABCDEF0123456789ABCDEF0123456789'
local imsi_prefix = '244:09:111111'


enb_id={"0x00001"}--, "0x00003",}
plmn={"244:09"}
enb_s1_ip={"10.0.1.2"}--,"10.0.1.6"}
cells={{ 21, 22, 23, }}--,{ 51, 52, 53,}}
uec_server_ip={"10.0.2.1"}--,"10.0.2.5"}
uec_proxy_ip={"10.0.2.2"}--,"10.0.2.6"}

exec("set_pgw".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." devtype=tun ".." devname=tunPGW".." addr="..pgw_ip)
exec("set_sgw".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." s1u="..s1_ip..":"..s1u_port.." s11="..s1_ip..":"..s11_port)
exec("set_mme".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." s1="..s1_ip..":"..mme_port.." mmegi="..mmegi.." mmec="..mmec)
exec("set_uec".." id=1".." ip="..edaemon_ip..":"..edaemon_port.." gtpu=on".." pdn=1".." addr="..uec_ip.." peer="..uec_server_ip[1]..":"..uec_proxy_port.." retries=unlimited")

-- Setting eNBs
for i=1,table.getn(enb_id) do
	exec("set_enb type=external"..
     " id="..i..
     " plmn="..plmn[1]..
     " enb_id_macro="..enb_id[i]..
     " s1="..enb_s1_ip[i]..
     " x2_peers=3"..
     " daemon="..edaemon_ip..":"..edaemon_port)
	 -- Setting cells on eNB
	for cell_id, phy_cell_id in pairs(cells[i]) do
		print("cell_id:"..cell_id..", phy_cell_id: "..phy_cell_id)
		exec("set_cell"..
			" id="..cell_id..
			" enb="..i..
			" pci="..math.floor(phy_cell_id/3)..":"..math.fmod(phy_cell_id,3)..
			" tac="..tac..
			" proxy="..uec_proxy_ip[i]..":"..uec_proxy_port..
			" eci="..enb_id[i].."0"..cell_id)
	end	
end

for cell_id=1,1 do
	for ue_index=1,ue_count_per_cell do
		print(ue_index,ue_id_aligned)
		local ue_id = (cell_id - 1) * ue_count_per_cell + ue_index
	
		local ue_id_aligned
		if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
		elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
		elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ue_index
		end
		
		local rohc_profile = '16'
		local ue_sec_key = sec_key..cell_id..ue_id_aligned
		local ue_imsi = imsi_prefix..cell_id..ue_id_aligned
		local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index
		
		-- Configuring 100 UEs (1:100) with 4 GBRs, 4 NONGBRs:
		if(ue_index<=100) then
		exec('set_ue id='..ue_id..
		     ' rohc='..rohc_profile..
		     ' sec_key='..ue_sec_key..
		     ' imsi='..ue_imsi..
		     ' cell=1')
			 
		-- Configuring 20 UEs (101:120) without FGI14:
		elseif(ue_index>100 and ue_index<=120) then
		exec('set_ue id='..ue_id..
		     ' rohc='..rohc_profile..
		     ' sec_key='..ue_sec_key..
		     ' imsi='..ue_imsi..
		     ' cell=1'..
		     ' fgi='..fgi_missing_14)    
		
		-- Configuring 30 UEs (121:150) with Carrier Aggregation capability:
		-- ONLY from IPHY144
		elseif(ue_index>120) then
		exec('set_ue id='..ue_id..
		     ' rohc='..rohc_profile..
		     ' sec_key='..ue_sec_key..
		     ' imsi='..ue_imsi..
		     ' cell=1')
		-- Cross Carrier Aggregation (P-CELL possible on band 1 and on band 7)
		exec("ue_param ca_supported_bands=8:a:a+3:a|3:a:a+8:a|7:a:a+7:a|7:a:a+7:a|8:a:a+20:a|20:a:a+8:a|3:a:a+20:a|20:a:a+3:a|8:a:a+20:a+3:a|3:a:a+20:a+8:a|20:a:a+8:a+3:a id="..ue_id)
		end
		--Configure bearers
		exec('set_bearer id=1'..
		     ' ue='..ue_id..
		     ' trf_type=internal'..
		     ' default=on'..
		     ' qci=8'..
		     ' ip='..ue_ip)
			 
		exec('set_bearer id=2'..
		     ' ue='..ue_id..
		     ' qci=1'..
			 ' gbr_ul=31'..
			 ' gbr_dl=31'..
			 ' mbr_ul=31'..
			 ' mbr_dl=31')
	end
end

-- UTRAN 

--local UTRAN_RNC_UT_ID = 22
local UTRAN_ENB_ID = 2
local UTRAN_CELL_ID = 1
--exec("set_enb type=simulated".." id="..UTRAN_ENB_ID.." plmn="..plmn[1].." enb_id_macro="..enb_id[i].." s1="..enb_s1_ip[i].." daemon="..edaemon_ip..":"..edaemon_port)
exec('set_enb id='..UTRAN_ENB_ID..' type=simulated s1=10.0.1.3 plmn=244:09 enb_id_macro=0x00002 daemon=:'..edaemon_port)
--exec('enb_param id=4 mlbSupportedRelease=r9 mlb_feature_flag=on')
exec('set_cell id=1 enb='..UTRAN_ENB_ID..' tac=124 pci=1:0 proxy=:2154 earfcn=2800:20800 eci=0x0000201')
--exec('enb_cell_param enb=4 cac_value=100 rsr_cio_change_accept=on mlb_max_sup_partners=1 rsr_reporting_period=10000')
--exec('enb_timer T_X2_ResourceStatusPeriod=10 T_MLB_ResourceStatusGuardPeriod=150 T_X2_MobilityChangePeriod=20')

-- Simulated gNB
--exec('set_gnb id=3 type=simulated s1=10.0.1.4 plmn=244:09 enb_id_macro=0x00003 daemon=:'..edaemon_port)
exec('set_gnb id=3 gnb_id=0x00003 type=simulated s1u=10.0.1.4 ng_multihome_ip=10.0.1.5 plmn=244:09 daemon=:'..edaemon_port)
--exec('set_cell id=1 gnb=3 tac=124 pci=0:1 proxy=:2155 eci=0x0000301') -- jaki arfcn dla 5G eNB?
exec('set_cell id=1 gnb=3 tac=124 pci=0:1 proxy=:2155 nrci=0x0301 earfcn=2000:20000 nr_arfcn=514000:524000')
exec("mme_param id=1 s1_hb_interval=120")
exec("enb_timer T_ShutdownNoX2TrafficTimer=none")

--exec("set_utran_rnc id="..UTRAN_RNC_UT_ID.." host_enb="..UTRAN_ENB_ID.." rnc_id=222")
--exec("set_utran_cell id="..UTRAN_CELL_ID.." rnc="..UTRAN_RNC_UT_ID.." pci=222 uarfcn=4140:4140")

exec("debug_log level=2")
exec("set_log log_to_file=on")
exec("set_log flush")
exec("cfg_end")
sleep(1)
