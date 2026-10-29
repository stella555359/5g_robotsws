local edaemon_ip = '127.0.0.1'
local edaemon_port = '10000'
local s1_ip = "10.0.1.1"

local pgw_net_part = '1.7'
local pgw_ip = '1.7.255.254/16'

local s1u_port = "2152"
local s11_port = "2153"

local mme_port = "36412"
local mmegi = "1"
local mmec = "3"

local uec_ip = "11.7.255.254/16"
local uec_net_part = "11.7"
local uec_server_ip = "10.0.2.1"
local uec_proxy_ip = "10.0.2.2"
local uec_proxy_port = "2152"

local plmn = "244:09"
local enb_s1_ip = "10.0.1.2"
local enb_macro_id = "0x00001"

local cells = { 11, 12, 13 }
local tac = "124"

-- Limit for this configuration is 250 UEs per Cell
local ue_count_per_cell = 20
local sec_key='0102030405060708090A0B0C0D0'
local sec_op_key = 'ABCDEF0123456789ABCDEF0123456789'
local imsi_prefix = '666:652:4050'


function DecToBase(IN,BASE)
    local B,K,OUT,D=BASE or 10,"0123456789ABCDEFGHIJKLMNOPQRSTUVW",""
    while IN>0 do
        IN,D=math.floor(IN/B),math.modf(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end


exec('debug_log gate=1 level=0')

exec("set_pgw"..
     " id=1"..
     " type=simulated"..
     " ip="..edaemon_ip..":"..edaemon_port..
	 " devtype=tun "..
	 " devname=tunPGW"..
	 " addr="..pgw_ip)

exec("set_sgw"..
     " id=1"..
     " type=simulated"..
     " ip="..edaemon_ip..":"..edaemon_port..
     " s1u="..s1_ip..":"..s1u_port..
     " s11="..s1_ip..":"..s11_port)

exec("set_mme"..
	 " id=1"..
	 " type=simulated"..
	 " ip="..edaemon_ip..":"..edaemon_port..
	 " s1="..s1_ip..":"..mme_port..
	 " mmegi="..mmegi..
	 " mmec="..mmec)

exec("set_uec"..
     " id=1"..
     " ip="..edaemon_ip..":"..edaemon_port..
     " gtpu=on"..
     " pdn=1"..
     " addr="..uec_ip..
     " peer="..uec_server_ip..":"..uec_proxy_port..
     " retries=unlimited")

exec("set_enb type=external"..
     " id=1"..
     " plmn="..plmn..
     " enb_id_macro="..enb_macro_id..
     " s1="..enb_s1_ip..
     " daemon="..edaemon_ip..":"..edaemon_port)

for cell_id, phy_cell_id in pairs(cells) do
	exec("set_cell"..
	     " id="..phy_cell_id..
	     " enb=1"..
	     " pci="..math.floor(phy_cell_id/3)..":"..math.fmod(phy_cell_id,3)..
	     " tac="..tac..
	     " proxy="..uec_proxy_ip..":"..uec_proxy_port..
	     " eci="..enb_macro_id.."0"..DecToBase(phy_cell_id, 16)..
         " mandatory_for_activation=false")
end

for cell_index, cell_id in pairs(cells) do
	for ue_index=1,ue_count_per_cell do

		local ue_id = (cell_index - 1) * ue_count_per_cell + ue_index

		local ue_id_aligned
        if (cell_id<10) then
		    if (ue_index>0 and ue_index<10) then ue_id_aligned = '000'..ue_index
    		elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '00'..ue_index
    		elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = '0'..ue_index
    		end
        end
        if (cell_id>=10) then
		    if (ue_index>0 and ue_index<10) then ue_id_aligned = '00'..ue_index
    		elseif (ue_index>=10 and ue_index<100) then ue_id_aligned = '0'..ue_index
    		elseif (ue_index>=100 and ue_index<1000) then ue_id_aligned = ''..ue_index
    		end
        end

		local rohc_profile = '16'
		local ue_sec_key = sec_key..cell_id..ue_id_aligned
		local ue_imsi = imsi_prefix..cell_id..ue_id_aligned
		local ue_ip = pgw_net_part..'.'..cell_id..'.'..ue_index

		exec('set_ue id='..ue_id..
		     ' rohc='..rohc_profile..
		     ' sec_key='..ue_sec_key..
		     ' imsi='..ue_imsi..
		     ' cell='..cell_id)

		exec('set_bearer id=1'..
		     ' ue='..ue_id..
		     ' trf_type=internal'..
		     ' default=on'..
		     ' qci=8'..
		     ' ip='..ue_ip)
	end
end

exec('set_log log_to_file=on')
exec("cfg_end")

exec('debug_log level=5')
exec('debug_log gate=1 level=0')
exec('debug_log')
-----exec('trace uec=1 protocol=rrc on')
sleep(1)
