package.path = '/home/ute/test_repository/resources/DevWro1/scripts/egate_config.lua'
require("egate_config.lua")
configureLogging()
function generate_imsi (mcc, mnc, ue_id)
    return string.format("%03d:%02d:%010d", mcc, mnc, ue_id)
end

local edaemon_ip = '127.0.0.1'
local edaemon_port = '10000'

local s1_ip = "10.0.1.1" -- MME address
local s1_ip_SGW = "10.0.1.22"  --SGW address

local pgw_net_part = '1.1'
local pgw_ip = '1.1.255.254/16'

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
--local sec_key='0102030405060708090A0B0C0D0E'
--local sec_op_key = 'ABCDEF0123456789ABCDEF0123456789'
--local imsi_prefix = '244:09:111111'
local sec_key = '0102030405060708090A0B0C0D0E1112'
--local sec_op_key = 'ABCDEF0123456789ABCDEF0123456789'
exec('set_param SEC_OP_KEY=ABCDEF0123456789ABCDEF0123456789')



enb_id={"0x00001"}--, "0x00002",}-- "0x00003",}
plmn={"244:09"}
enb_s1_ip={"10.0.1.2"}--,"10.0.1.4",}--"10.0.1.6"}
--cells={{ 61, 62,},{ 41, 42,}}--,{ 51, 52,}}
cells={{1}}--{{ 11, 12, 13,}}--,{ 11, 12,}}--,{ 51, 52,}}
uec_server_ip={"10.0.2.1"}--,"10.0.2.3"}--,"10.0.2.5"}
uec_proxy_ip={"10.0.2.2"}--,"10.0.2.4"}--,"10.0.2.6"}

ue_eutra_cap_v15_10 = 'DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A2E31D0100000208000420000860001100002280004600008E0001200002480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B40003F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000504000003CE800000000000000000000000000000000000000000000000000000000000808E21090002A8001802297000020000104B0A0000CF0000006000000200'

exec("set_pgw".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." devtype=tun ".." devname=tunPGW".." addr="..pgw_ip)
exec("set_sgw".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." s1u="..s1_ip_SGW..":"..s1u_port.." s11="..s1_ip_SGW..":"..s11_port)
exec("set_mme".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." s1="..s1_ip..":"..mme_port.." mmegi="..mmegi.." mmec="..mmec)
exec("set_uec".." dev_sim_type=external id=1".." ip="..edaemon_ip..":"..edaemon_port.." gtpu=on".." pdn=1".." addr="..uec_ip.." peer="..uec_server_ip[1]..":"..uec_proxy_port.." retries=unlimited")

-- Setting eNBs
for i=1,table.getn(enb_id) do
  exec("set_enb type=external"..
     " id="..i..
     " plmn="..plmn[1]..
     " enb_id_macro="..enb_id[i]..
     " s1="..enb_s1_ip[i]..
     " daemon="..edaemon_ip..":"..edaemon_port)
   -- Setting cells on eNB
  for cell_id, phy_cell_id in pairs(cells[i]) do
    --print("cell_id:"..cell_id..", phy_cell_id: "..phy_cell_id)
    exec("set_cell"..
      " id="..cell_id..
      " enb="..i..
      --" pci="..math.floor(phy_cell_id/3)..":"..math.fmod(phy_cell_id,3)..
      " pci=3:2"..
      " tac="..tac..
      " proxy="..uec_proxy_ip[i]..":"..uec_proxy_port..
      " eci="..enb_id[i].."0"..cell_id..
      " bw=5MHz"..
      " earfcn=6200:24200")
  end
end

cell_id = 1
phy_cell_id = 1
print(ue_index,ue_id_aligned)
local ue_index = 1
local ue_id = 1

local ue_id_aligned
if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ue_index
end

local rohc_profile = '16'
--local ue_sec_key = sec_key..cell_id..ue_id_aligned
local ue_imsi = generate_imsi(244, 9, ue_id)
local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index

-- Configuring 100 UEs (1:100) with 4 GBRs, 4 NONGBRs:

exec('set_ue cus id='..ue_id..
     ' rohc='..rohc_profile..
     ' sec_key='..sec_key..
     ' imsi='..ue_imsi..
     ' release=15'..
     ' cell=1'
     )

 exec('set_bearer id=6'..
        ' ue='..ue_index..
        --' trf_type=internal'..
        ' trf_type=external'..
        ' default=on'..
        ' qci=6'..
        ' ip='..ue_ip)
exec('set_bearer id=7'..
        ' ue='..ue_index..
        ' default=off'..
        ' qci=7 preprovisioned=yes filter=1 precedence=1'
        --' qci=7'
       )


print(ue_index,ue_id_aligned)
local ue_index = 2
local ue_id = 2

local ue_id_aligned
if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ue_index
end

local rohc_profile = '16'
--local ue_sec_key = sec_key..cell_id..ue_id_aligned
local ue_imsi = generate_imsi(244, 9, ue_id)
local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index

-- Configuring 100 UEs (1:100) with 4 GBRs, 4 NONGBRs:

exec('set_ue id='..ue_id..
     ' rohc='..rohc_profile..
     ' sec_key='..sec_key..
     ' imsi='..ue_imsi
     -- ' release=15'..
     -- ' cell=1'
     )

 exec('set_bearer id=7'..
        ' ue='..ue_index..
        --' trf_type=internal'..
        ' trf_type=external'..
        ' default=on'..
        ' qci=7'..
        ' ip='..ue_ip)




print(ue_index,ue_id_aligned)
local ue_index = 3
local ue_id = 3

local ue_id_aligned
if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ue_index
end

local rohc_profile = '16'
--local ue_sec_key = sec_key..cell_id..ue_id_aligned
local ue_imsi = generate_imsi(244, 9, ue_id)
local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index

-- Configuring 100 UEs (1:100) with 4 GBRs, 4 NONGBRs:

exec('set_ue id='..ue_id..
     ' rohc='..rohc_profile..
     ' sec_key='..sec_key..
     ' imsi='..ue_imsi
     --' release=15'..
     --' cell=1'
     )

 exec('set_bearer id=6'..
        ' ue='..ue_index..
        --' trf_type=internal'..
        ' trf_type=external'..
        ' default=on'..
        ' qci=6'..
        ' ip='..ue_ip)
exec('set_bearer id=7'..
        ' ue='..ue_index..
        ' default=off'..
        --' qci=7 preprovisioned=yes filter=1 precedence=1'
        ' qci=7'
        )


print(ue_index,ue_id_aligned)
local ue_index = 4
local ue_id = 4

local ue_id_aligned
if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ue_index
end

local rohc_profile = '16'
--local ue_sec_key = sec_key..cell_id..ue_id_aligned
local ue_imsi = generate_imsi(244, 9, ue_id)
local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index

-- Configuring 100 UEs (1:100) with 4 GBRs, 4 NONGBRs:

exec('set_ue external id='..ue_id..
     ' rohc='..rohc_profile..
     ' sec_key='..sec_key..
     ' imsi='..ue_imsi
     --' release=15'..
     --' cell=1'
     )

 exec('set_bearer id=7'..
        ' ue='..ue_index..
        --' trf_type=internal'..
        ' trf_type=external'..
        ' default=on'..
        ' qci=7'..
        ' ip='..ue_ip)


--1 gNB
exec("gnb_set id=2 s1u=10.0.1.11 plmn=244:09 gnb_id=0x1200f x2_peers=none type=simulated daemon=:10000")
exec("cell_set id=1 gnb=2 tac=3 pci=127:0 eci=0x0004501 nrci=0x1 nr_arfcn=500000:524000 proxy=:5555 meas_timing_carrier_freq=524704 ssb_subcarrier_spacing=kHz15 ssb_mtc_periodicity_and_offset=sf10:0 ssb_mtc_duration=sf1 ss_rssi_meas_slots=1000000000 ss_rssi_end_symbol=2")

exec("set_enb id=4 type=simulated s1=10.0.1.1 plmn=244:09 enb_id_macro=0x00004 x2_peers=2 daemon=:10000")
--exec('enb_param id=4 mlbSupportedRelease=r9 mlb_feature_flag=on')
exec("set_cell id=1 enb=4 tac=124 pci=1:0 proxy=:2154 earfcn=6200:24200 eci=0x0000401 bw=5MHz")

--exec("gnb_endc_param id=2 freq_band_indicator_nr=7")
exec("enb_param id=4 endc_capable_qci=7")

exec("mme_param id=1 s1_hb_interval=120")
exec("enb_timer T_ShutdownNoX2TrafficTimer=none")

exec("debug_log level=0")
exec("sim_debug_log level=0 enb=4")
--exec("trace enb=1 protocol=x2 on")
exec("trace enb=2 protocol=x2 on")
exec("trace enb=4 protocol=x2 on")
exec("set_log log_to_file=on")
--exec("trace uec=1 protocol=rrc,nr_rrc hex")
--exec("trace uec=1 protocol=nr_rrc on")

--exec("ue_param id=1-10 pdcp_sn_extension=on dual_conn=eutra_nr")
--exec("ue_param id=1-10 nr_supported_bands=7")
exec("gnb_endc_param id=2 include_reestablish_pdcp=on")
--exec("ue_param id=1-10 ue_eutra_capabilities="..ue_eutra_cap_v15_10)
exec("set_log flush")
exec("enb_timer T_ShutdownNoX2TrafficTimer=none")
exec("set_cnode")
exec("cfg_end")
sleep(1)
