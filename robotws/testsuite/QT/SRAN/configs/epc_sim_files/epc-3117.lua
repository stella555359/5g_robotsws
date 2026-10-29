local edaemon_ip = '127.0.0.1'
local edaemon_port = '10000'

local s1_ip = "10.0.1.1"
local s1_ip_sgw = "10.0.1.1"

local pgw_ip = '10.0.3.254/24'

local s1u_port = "2152"
local s11_port = "2153"

local mme_port = "36412"
local mmegi = "1"
local mmec = "3"

local tac = "2010"

local ue_count_per_cell = 10
local sec_key='00112233445566778899AABBCCDDEEFF'
local sec_op_key = '01020304050607080910111213141516'
local imsi_prefix = '244:09'


enb_id={"0x007DA"}
plmn={"244:09"}
enb_s1_ip={"10.0.1.2"}

cells={{ 1, 2, 3, }}

exec("set_pgw".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." devtype=tun ".." devname=tunPGW".." addr="..pgw_ip.." apn=apn.fddciexec.net ")
exec("set_sgw".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." s1u="..s1_ip_sgw..":"..s1u_port.." s11="..s1_ip_sgw..":"..s11_port)
exec("set_mme".." id=1".." type=simulated".." ip="..edaemon_ip..":"..edaemon_port.." s1="..s1_ip..":"..mme_port.." mmegi="..mmegi.." mmec="..mmec)

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
    print("cell_id:"..cell_id..", phy_cell_id: "..phy_cell_id)
    exec("set_cell"..
      " id="..cell_id..
      " enb="..i..
      " tac="..tac..
      " eci="..enb_id[i].."0"..cell_id)
  end
end
--------------------------------------------------------------------------------------
exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
exec('set_ue id=1 external sec_key=00112233445566778899AABBCCDDEEFF imsi=244:09:1101114015 mbr_ul=100000 mbr_dl=100000')
exec('set_bearer id=1 ue=1 default=on qci=9 ip=10.0.3.1 trf_type=external')
--------------------------------------------------------------------------------------
--turn off console prints (except errors and abnormal case reports)
exec('mme_param id=1 enable_detailed_print=all')
exec('debug_log level=5')
--exec("trace uec=1 protocol=all on")
exec('set_log log_to_file=on')
exec('cfg_end')
--------------------------------------------------------------------------------------
sleep (2)
