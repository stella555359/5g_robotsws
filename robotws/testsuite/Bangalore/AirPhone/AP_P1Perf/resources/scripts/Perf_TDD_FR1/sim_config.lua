function covert_to_pci(input)
	local value=tonumber(input)
	a=math.floor(value/3)
	b=value%3
	return (''..a..':'..b..'')
	
end

function real_gnb_configuartion()
	for real_gnb_id, data in pairs(GNB_DATA) do 
		if data.xp_management == "on" then
			exec('set_gnb id='..real_gnb_id..' type=external gnb_id='..data.gnb_id..' plmn='..data.plmn..' plmnList='..data.plmn..' nssai='..data.snssai..' x2_peers=none amf=all s1u='..data.s1u..' x2='..data.x2..':36422 x2u='..data.x2u..':36422 ng='..data.ng..' ngu='..data.ngu..' xn='..data.xn..' xnu='..data.xnu..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' xp_management='..data.xp_management..' xp='..data.xp..':32742 xpu='..data.xpu..':32742')
		else 
			exec('set_gnb id='..real_gnb_id..' type=external gnb_id='..data.gnb_id..' plmn='..data.plmn..' plmnList='..data.plmn..' nssai='..data.snssai..' x2_peers=none amf=all s1u='..data.s1u..' x2='..data.x2..':36422 x2u='..data.x2u..':36422 ng='..data.ng..' ngu='..data.ngu..' xn='..data.xn..' xnu='..data.xnu..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..'')
		end
	end
end

function real_gnb_cell_configuartion()
	for _, cell_data in ipairs(GNB_CELL_DATA) do
        local pci = covert_to_pci(cell_data.pci)       	
		if cell_data.gscn > 2 then
            exec('set_cell id='..cell_data.cell_id..' nrci=0x'..string.format('%x',cell_data.cell_id)..' gnb='..cell_data.gnb..' pci='..pci..' tac='..cell_data.tac_list..' tdd_cell='..cell_data.tdd_flag..' gscn='..cell_data.gscn..' nr_arfcn='..cell_data.nrarfcn..' proxy='..cell_data.ue_proxy_ip..':9999|'..cell_data.ue_proxy_ip..':8888 mandatory_for_activation=off')
        else
            exec('set_cell id='..cell_data.cell_id..' nrci=0x'..string.format('%x',cell_data.cell_id)..' gnb='..cell_data.gnb..' pci='..pci..' tac='..cell_data.tac_list..' tdd_cell='..cell_data.tdd_flag..' nr_arfcn='..cell_data.nrarfcn..' proxy='..cell_data.ue_proxy_ip..':9999|'..cell_data.ue_proxy_ip..':8888 mandatory_for_activation=off') 
        end
	end
end

function sim_enb_configuartion()
	for sim_enb_id, sim_enb_data in pairs(SIM_ENB_DATA) do
		if sim_enb_data.xp_management == "on" then
			exec('enb_set id='..sim_enb_id..' name=SimModeLTERAN-'..sim_enb_id..' type=simulated enb_id_macro=0x0000'..sim_enb_id..' plmn='..sim_enb_data.plmn..' s1='..sim_enb_data.s1..' s1u='..sim_enb_data.s1u..' x2='..sim_enb_data.x2..' x2u='..sim_enb_data.x2u..' x2_peers='..sim_enb_data.x2_peers..' daemon='..sim_enb_data.enb_server_ip..':'..EDAEMON_PORT..' xp_management='..sim_enb_data.xp_management..' xp='..sim_enb_data.xp..':32742 xpu='..sim_enb_data.xpu..':32742 x2u_snd_buff_size=41943040 x2u_rcv_buff_size=41943040 proxy_read_packets_threshold=10')
			exec('enb_xp_param id='..sim_enb_id..'  xp_peers='..sim_enb_data.xp_peers..' ignore_xp=off xp_listening_socket=on')
		else 	
			exec('enb_set id='..sim_enb_id..' name=SimModeLTERAN-'..sim_enb_id..' type=simulated enb_id_macro=0x0000'..sim_enb_id..' plmn='..sim_enb_data.plmn..' s1='..sim_enb_data.s1..' s1u='..sim_enb_data.s1u..' x2='..sim_enb_data.x2..' x2u='..sim_enb_data.x2u..' x2_peers='..sim_enb_data.x2_peers..' daemon='..sim_enb_data.enb_server_ip..':'..EDAEMON_PORT..' x2u_snd_buff_size=41943040 x2u_rcv_buff_size=41943040 proxy_read_packets_threshold=10')
		end
		exec('enb_param id='..sim_enb_id..' drb_id_begin=3 endc_capable_qci='..sim_enb_data.qci_supported..'')
		exec('enb_endc_param id='..sim_enb_id..' control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:31')
	end
end

function sim_enb_cell_configuartion()
	local cell_udp_port=12219
	for _, sim_enb_cell_data in ipairs(SIM_ENB_CELL_DATA) do
		local pci = covert_to_pci(sim_enb_cell_data.pci)
--		exec('set_cell id='..sim_enb_cell_data.cell_id..' enb='..sim_enb_cell_data.enb..' eci='..sim_enb_cell_data.eci..' pci='..pci..' tac=222 tdd_cell='..sim_enb_cell_data.tdd_flag..' earfcn='..sim_enb_cell_data.earfcn..' bw=20MHz proxy='..sim_enb_cell_data.cell_proxy..':'..cell_udp_port..'|'..sim_enb_cell_data.cell_proxy..':8889 mandatory_for_activation=off')
		exec('set_cell id='..sim_enb_cell_data.cell_id..' enb='..sim_enb_cell_data.enb..' eci='..sim_enb_cell_data.eci..' pci='..pci..' tac=222 tdd_cell='..sim_enb_cell_data.tdd_flag..' earfcn='..sim_enb_cell_data.earfcn..' bw=20MHz proxy='..sim_enb_cell_data.cell_proxy..':'..cell_udp_port..'|'..sim_enb_cell_data.cell_proxy..':8889 mandatory_for_activation=off')
		cell_udp_port = cell_udp_port + 1 
	end
end

function sim_gnb_configuartion()
	for sim_gnb_id, sim_gnb_data in pairs(SIM_GNB_DATA) do 
		exec('set_gnb id='..sim_gnb_id..' name=SimMode5GRAN-'..sim_gnb_id..' type=simulated gnb_id=0x0000'..sim_gnb_id..' plmn='..sim_gnb_data.plmn..' plmnList='..sim_gnb_data.plmn..' nssai='..sim_gnb_data.snassi..' x2_peers=none s1u='..sim_gnb_data.sim_gnb_s1u..' x2='..sim_gnb_data.sim_gnb_x2..':36422 ng='..sim_gnb_data.sim_gnb_ng..' xn='..sim_gnb_data.sim_gnb_xn..' daemon='..sim_gnb_data.sim_gnb_server_ip..':'..EDAEMON_PORT..'')
		exec('gnb_param id='..sim_gnb_id..' xn_listening_socket=on send_xn_setup=on measEvent=A1 measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4 sib1_period=2000')
		exec('enb_timer T_RELOCprepTimeout=2000')
	end
end

function sim_gnb_cell_configuartion()
	for _, sim_gnb_cell_data in pairs(SIM_GNB_CELL_DATA) do
		local pci = covert_to_pci(sim_gnb_cell_data.pci)
		exec('set_cell id='..sim_gnb_cell_data.cell_id..' nrci=0x'..string.format('%x',sim_gnb_cell_data.cell_id)..' gnb='..sim_gnb_cell_data.gnb..' pci='..pci..' tac='..sim_gnb_cell_data.tac..' tdd_cell='..sim_gnb_cell_data.tdd_flag..' gscn='..sim_gnb_cell_data.gscn..' nr_arfcn='..sim_gnb_cell_data.nrarfcn..' proxy='..sim_gnb_cell_data.cell_proxy..':9999|'..sim_gnb_cell_data.cell_proxy..':8888 mandatory_for_activation=off')
	end
end

function sim_amf_configuration()
	for sim_amf_id, sim_amf_data in pairs(SIM_AMF_DATA) do
		exec('set_amf_region id='..sim_amf_data.amf_region..' plmn='..sim_amf_data.plmn..' tac_list=7627107,100,788,'..sim_amf_data.tac_list..',0')
		exec('set_amf id='..sim_amf_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' ng='..sim_amf_data.amf_ng..':38412 region='..sim_amf_data.amf_region..' set_id='..sim_amf_data.amf_set..' pointer='..sim_amf_data.amf_pointer..'')
		exec('amf_param id='..sim_amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
	end	
end

function sim_upf_configuration()
	for sim_upf_id, sim_upf_data in pairs(SIM_UPF_DATA) do
		exec('set_upf id='..sim_upf_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' type=simulated addr='..sim_upf_data.upf_addr..'/21 ngu='..sim_upf_data.upf_ngu..' devname=tunUPF'..sim_upf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
	end
end

function sim_smf_configuration()
	for sim_smf_id, sim_smf_data in pairs(SIM_SMF_DATA) do
		exec('smf_upf_mapping id='..sim_smf_id..' upf='..sim_smf_data.upf_list..'')
		exec('smf_param id='..sim_smf_id..'  max_pdu_session_supported='..sim_smf_data.pdu_sessions..'')
	end
end

function sim_mme_configuration()
    for sim_mme_id, sim_mme_data in pairs(SIM_MME_DATA) do
		exec('mme_pool_area id=1 mmegi=1 plmn='..sim_mme_data.plmn..' tac_list=777,111,222,444,333,'..TAC..'')
        exec('set_mme id='..sim_mme_id..' name=SimModeMME-'..sim_mme_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1='..sim_mme_data.mme_slc..':36412 s11='..sim_mme_data.mme_sl1..':57973 supported_rat=lte,nblte pool=1:1')
	end
end

function sim_sgw_configuration()
	for sim_sgw_id, sim_sgw_data in pairs(SIM_SGW_DATA) do
        exec('set_sgw id='..sim_sgw_id..' ip='..EDAEMON_IP..':'..EDAEMON_PORT..' s1u='..sim_sgw_data.sgw_s1u..' s11='..sim_sgw_data.sgw_s11..':60100 s11u='..sim_sgw_data.sgw_s11u..':57972 s5='..sim_sgw_data.sgw_s5..':60518 s5u='..sim_sgw_data.sgw_s5u..':60519 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
	end
end

function sim_pgw_configuration()
	for sim_pgw_id, sim_pgw_data in pairs(SIM_PGW_DATA) do
        exec('set_pgw id='..sim_pgw_id..' type=simulated ip='..EDAEMON_IP..':'..EDAEMON_PORT..' addr='..sim_pgw_data.pgw_addr..'/17 s5='..sim_pgw_data.pgw_s5..':60520 s5u='..sim_pgw_data.pgw_s5u..':60521 apn=lteapn'..sim_pgw_id..'.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA'..sim_pgw_id..' sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')
	end
end

function sim_uec_configuaration()
	for sim_uec_id, sim_uec_data in pairs(UEC_DATA) do
		exec('set_uec id='..sim_uec_id..' daemon='..sim_uec_data.uec_ip..':'..EDAEMON_PORT..' peer='..sim_uec_data.uec_ip..':2152 peer_uplane='..sim_uec_data.uplane_ip..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..sim_uec_id..' addr=72.'..sim_uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10 sctp_rto_min=100 ctrl_conn_timeout=150000')
		exec('uec_param id='..sim_uec_id..' reordering_window_size=1000 reordering_timer=500')
	end
end

function sim_trf_gen_configuaration()
	exec('sim_param_set trf_gen_client_ports=10001-37000 trf_gen_server_ports=41001-41010 L2_HI_IP_ADDRESS=10.0.2.81,10.0.2.82,10.0.2.83,10.0.2.84,10.0.2.85,10.0.2.86')
	for sim_trf_gen_id, sim_trf_gen_data in pairs(SIM_TRF_GEN_DATA) do
		
		if sim_trf_gen_data.trf_gen_type == "client" then
			exec('set_trf_gen id='..sim_trf_gen_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' loc='..sim_trf_gen_data.trf_gen_loc..' trf_gen_type=client client_addr='..sim_trf_gen_data.trf_gen_ip_address..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310')
		elseif sim_trf_gen_data.trf_gen_type == "server" then
			exec('set_trf_gen id='..sim_trf_gen_id..' daemon='..EDAEMON_IP..':'..EDAEMON_PORT..' loc='..sim_trf_gen_data.trf_gen_loc..' trf_gen_type=server server_addr='..sim_trf_gen_data.trf_gen_ip_address..' quick_ack=off drop_packets_on_congestion=on send_buff_size=40M recv_buff_size=40M mss=1310')
		else 
			print(" Invaild trf_gen_type : "..sim_trf_gen_data.trf_gen_type.." Might be typo")
			return
		end
	end
end

function sim_ue_group_and_ue_configuration()
	local current_ue_id=1
    for _, ue_group_data in pairs(UE_GROUP_DATA) do
    	
		--[[ FOR SA UE ALLOCATON BASED ON UE GROUP DATA --]]
	  
		exec('set_ue_group id='..ue_group_data.ue_group_id..' name='..ue_group_data.name..' enb='..ue_group_data.ran_id..' cell='..ue_group_data.cell..' uec='..ue_group_data.uec..'  pdn='..ue_group_data.pdn..' ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
	    print(' UE GROUP ID '..ue_group_data.ue_group_id..' : UEs Range allacted '..current_ue_id..' - '..(current_ue_id+ue_group_data.num_ue-1)..'')	
		if ue_group_data.ue_type == "SA" then
			for ue_id = current_ue_id,(current_ue_id+ue_group_data.num_ue-1) do
				if ue_group_data.additional_qosflows_to_activate == "NIL" then
					exec('set_ue id='..ue_id..' group='..ue_group_data.ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb='..ue_group_data.ran_id..' cell='..ue_group_data.cell..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + ue_id - 1)
				else
					exec('set_ue id='..ue_id..' group='..ue_group_data.ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb='..ue_group_data.ran_id..' cell='..ue_group_data.cell..' additional_qosflows_to_activate='..ue_group_data.additional_qosflows_to_activate..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + ue_id - 1)
				end
				
				if UPLANE_DATA_WITH_TRF_GEN == "YES" and ue_group_data.trf_gen then
					local set_ue_trfgen_param = "set_ue_trfgen_param ue="..ue_id..""
					
					for _, pdu in ipairs(ue_group_data.ue_trf_gen_profile.pdu) do
						for _,qfi in ipairs(ue_group_data.ue_trf_gen_profile.qfi) do
							for _,upf in ipairs(ue_group_data.ue_trf_gen_profile.upf) do
								if #ue_group_data.ue_trf_gen_profile.dl_trf_gen_client_id ~= 0 then
									for index,_ in ipairs(ue_group_data.ue_trf_gen_profile.dl_trf_gen_client_id) do
										set_ue_trfgen_param = ""..set_ue_trfgen_param.." pdu="..pdu.." upf="..upf.." qfi="..qfi.." dir=dl max_data_rate=1 trf_gen_client="..ue_group_data.ue_trf_gen_profile.dl_trf_gen_client_id[index].." trf_gen_server="..ue_group_data.ue_trf_gen_profile.dl_trf_gen_server_id[index]..""
									end
								end
								if #ue_group_data.ue_trf_gen_profile.ul_trf_gen_client_id ~= 0 then
									for index,_ in ipairs(ue_group_data.ue_trf_gen_profile.ul_trf_gen_client_id) do
										set_ue_trfgen_param = ""..set_ue_trfgen_param.." pdu="..pdu.." upf="..upf.." qfi="..qfi.." dir=ul max_data_rate=1 trf_gen_client="..ue_group_data.ue_trf_gen_profile.ul_trf_gen_client_id[index].." trf_gen_server="..ue_group_data.ue_trf_gen_profile.ul_trf_gen_server_id[index]..""
									end
								end
							end
						end
					end
					exec(set_ue_trfgen_param)
                    exec("set_pdu_param ue="..ue_id.." pdu=1 trf_type=external_trf_gen")
                else
                    exec("set_pdu_param ue="..ue_id.." pdu=1 trf_type=internal")	
				end
			end
		--[[ FOR NSA UE ALLOCATON BASED ON UE GROUP DATA --]]
		
		elseif ue_group_data.ue_type == "NSA" then
	        for _, bearer_data in ipairs(ue_group_data.bearer_set) do
                if UPLANE_DATA_WITH_TRF_GEN == "YES" and ue_group_data.trf_gen then
                    if bearer_data.default == "on" then
                        exec('set_bearer id='..bearer_data.id..' ue_group='..ue_group_data.ue_group_id..' qci='..bearer_data.qci..' pdn='..ue_group_data.pdn..' default=on trf_type=external_trf_gen dl_nat_gw='..EDAEMON_IP..' ul_nat_gw='..EDAEMON_IP)
                    else
                        exec('set_bearer id='..bearer_data.id..' ue_group='..ue_group_data.ue_group_id..' qci='..bearer_data.qci..' pdn='..ue_group_data.pdn..'')
                    end
                else
                    if bearer_data.default == "on" then
                        exec('set_bearer id='..bearer_data.id..' ue_group='..ue_group_data.ue_group_id..' qci='..bearer_data.qci..' pdn='..ue_group_data.pdn..' default=on trf_type=internal dl_nat_gw='..EDAEMON_IP..' ul_nat_gw='..EDAEMON_IP)
                    else
                        exec('set_bearer id='..bearer_data.id..' ue_group='..ue_group_data.ue_group_id..' qci='..bearer_data.qci..' pdn='..ue_group_data.pdn..'')
                    end
                end
            end
    	
			for ue_id = current_ue_id,(current_ue_id+ue_group_data.num_ue-1)do 
				exec('set_ue id='..ue_id..' group='..ue_group_data.ue_group_id..' enb='..ue_group_data.ran_id..' cell='..ue_group_data.cell..' sec_key=0102030405060708090A0B0C0D0EFF00 imsi='..PLMN..':'.. NSA_IMSI + ue_id - 1)
				exec('ue_param id='..ue_id..' dual_conn=eutra_nr')
				exec('ue_mme_param id='..ue_id..' sgw_id='..ue_group_data.sgw_id)
				
                if UPLANE_DATA_WITH_TRF_GEN == "YES"  and ue_group_data.trf_gen then
					local set_ue_trfgen_param = "set_ue_endc_trfgen_param ue="..ue_id..""
					
					for _,bearerId  in ipairs(ue_group_data.ue_trf_gen_profile.bearerId) do
						if #ue_group_data.ue_trf_gen_profile.dl_trf_gen_client_id ~= 0 then
							for index,_ in ipairs(ue_group_data.ue_trf_gen_profile.dl_trf_gen_client_id) do
								set_ue_trfgen_param = ''..set_ue_trfgen_param..' pgw='..ue_group_data.ue_trf_gen_profile.pgw[index]..' bearerId='..bearerId..' dir=dl max_data_rate=1 trf_gen_client='..ue_group_data.ue_trf_gen_profile.dl_trf_gen_client_id[index]..'  trf_gen_server='..ue_group_data.ue_trf_gen_profile.dl_trf_gen_server_id[index]..''
							end
						end
						if #ue_group_data.ue_trf_gen_profile.ul_trf_gen_client_id ~= 0 then
							for index,_ in ipairs(ue_group_data.ue_trf_gen_profile.ul_trf_gen_client_id) do
								set_ue_trfgen_param = ''..set_ue_trfgen_param..'  pgw='..ue_group_data.ue_trf_gen_profile.pgw[index]..' bearerId='..bearerId..' dir=ul max_data_rate=1 trf_gen_client='..ue_group_data.ue_trf_gen_profile.ul_trf_gen_client_id[index]..'  trf_gen_server='..ue_group_data.ue_trf_gen_profile.ul_trf_gen_server_id[index]..''
							end
						end
					end
					exec(set_ue_trfgen_param)
				end
			end
		
		else
			print("Invaild UE type: it must be SA or NSA")
            return
		end
        current_ue_id=current_ue_id+ue_group_data.num_ue
	end
end

function qos_and_bearer_configuration()

	for qos_flows_id, qos_flows_data in pairs(QOS_GROUP_DATA) do
		exec('set_qosflow id='..qos_flows_id..' 5qi='..qos_flows_data.fiveqi..' default='..qos_flows_data.default)
	end

	for nwslice_id, nwslice_data in pairs(NWSLICE_DATA) do
		exec('set_nwslice default='..nwslice_data.default..' id='..nwslice_id..' snssai='..nwslice_data.snssai..' qos_flows='..nwslice_data.qos_flows..' amf_region_id='..nwslice_data.amf_region_id..' plmn_list='..nwslice_data.plmn_list..'  ue='..nwslice_data.ue..'')
	end
end



-- Copyright (c) 2019 Nokia. All rights reserved.

os.execute("ulimit -c unlimited")   --To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")  --To enable all types of coredumps on WTS VM

-------------------------------------------------------------------------------------
--VLAN Finder
-------------------------------------------------------------------------------------
function ip_configuration()
    function find_vlan(interface)
        local filename = os.tmpname()
        local command = "ip link > " .. filename
        os.execute(command)

		local file = io.open(filename, "r")
		local output = ""
		if file then
		for line in file:lines() do
			if string.match(line, "trunk") then
				break
			elseif string.match(line, interface) then
			local vlan = string.match(line, "%.%d+")
			if vlan then
				output = vlan
				break
			end
			end
		end
		file:close()
		os.remove(filename)
		end
		if output ~= "" then
		return output -- Return VLAN ID if found
		else
		return "" -- Return empty string if VLAN ID is not found
		end
    end

	GNB_VLAN = find_vlan("eth3")
	AP_VLAN = find_vlan("eth4")
	
	-- Write the VLAN IDs to file
	os.execute('echo "GNB_VLAN:'..GNB_VLAN..'"> /opt/wts/latest/vlan')
	os.execute('echo "AP_VLAN'..AP_VLAN..'">> /opt/wts/latest/vlan')

		-------------------------------------------------------------------------------------
		--IP configuration
		--------------------------------------------------------------------------------------
		for ip1 = 1,254 do --To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
		--    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3.1801')
			if not (ip1 == 2) then
				os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3'..GNB_VLAN..'')
			end
		end

		for ip2 = 1,15 do  --To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
			if not( ip2 == 80 or ip2 == 81 or ip2 == 82 or ip2 == 83 or ip2 == 84 or ip2 == 85 or ip2 == 86 or ip2 == 90 or ip2 == 91 or ip2 == 92 or ip2 == 93 or ip2 == 94 or ip2 == 95 or ip2 == 96 ) then
				os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
			end
		end


    os.execute('sudo sysctl -w net.sctp.rto_min=100')
    os.execute('sudo sysctl -w net.sctp.sack_timeout=200')
    os.execute('sudo sysctl -w net.sctp.rto_initial=3000')
    os.execute('sudo sysctl -w net.sctp.rto_max=60000')
    os.execute('sudo sysctl -w net.core.wmem_max=20971520')
    os.execute('sudo sysctl -w net.core.wmem_default=20971520')
    os.execute('sudo sysctl -w net.core.rmem_max=20971520')
    os.execute('sudo sysctl -w net.core.rmem_default=20971520')
    os.execute('sudo sysctl -w net.ipv4.tcp_rmem="10240 87380 20971520"') --Only for TCP
    os.execute('sudo sysctl -w net.ipv4.tcp_wmem="10240 87380 20971520"') --Only for TCP
    os.execute('sudo sysctl -w net.core.wmem_max=20971520') --Only for TCP
    os.execute('sudo sysctl -w net.core.rmem_max=20971520') --Only for TCP
    os.execute('sudo sysctl -w net.ipv4.tcp_limit_output_bytes=62914560') --Only for TCP
    os.execute('sudo sysctl -w net.ipv4.tcp_congestion_control=cubic') --Only for TCP
end

function run_configuration(file_name,duration)	
	
	local IS_OK,sim_data=pcall(require,file_name)
    require('test_sequence')    
	
	if not IS_OK then
		print("SIM_DATA LOADING FAILED : "..sim_data)
        print("SIM_DATA file not exits:\""..file_name.."\" or have SYNTAX ERROR PLease do reset gate and try loading with proper file")
		return
	end
    ip_configuration()  
	sim_uec_configuaration()
	--To Configure 4G core sim
	if SIMULATE_4G_CORE == "YES" then
		sim_mme_configuration()
		sim_sgw_configuration()
		sim_pgw_configuration()
	end
	
	--To Configure 4G RAN sim
	if SIMULATE_4G_RAN == "YES" then
		sim_enb_configuartion()
		sim_enb_cell_configuartion()
	end
	
	--To Configure 5G core sim
	if SIMULATE_5G_CORE == "YES" then 
		sim_amf_configuration()
		sim_upf_configuration()
		sim_smf_configuration()
	end
	
	--To Configure 5G RAN sim
	if SIMULATE_5G_RAN == "YES" then 
		sim_gnb_configuartion()
		sim_gnb_cell_configuartion()
	end
	
	--To Configure REAL gNB and CELL
	real_gnb_configuartion()
	real_gnb_cell_configuartion()
	--To Configure trf_gen
	if UPLANE_DATA_WITH_TRF_GEN == "YES" then
		sim_trf_gen_configuaration()
	end
	--To Configure qfi and nwslice
	sim_ue_group_and_ue_configuration()
	qos_and_bearer_configuration()

    --To configure sequence
    seq_configuration(duration)
	
    ---------------------------------------------------------------------------------------------------
	--OTHER CONFIGURATION
    ---------------------------------------------------------------------------------------------------
    exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')
    exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
    ---------------------------------------------------------------------------------------------------
	--Cipher offload flag to distribute:ciphering=uec/distributed
	---------------------------------------------------------------------------------------------------
	exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
	exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled ENABLE_MULTIPLE_L2NRT=on') --Proxy proto flag enabled
	exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=disabled') 
	exec('sim_param_set TTI=5')
	exec('sim_param_set pet_5g_testing=on')
 
--	exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
--	exec('sim_param_set purge_buffer_on_full=on')
	---------------------------------------------------------------------------------------------------
	--DEBUG CONFIGURATION
	---------------------------------------------------------------------------------------------------
	exec('debug_log level=4 max_file_num=50 max_log_size=200M')
	exec('sim_param_set ENABLE_CORE_LIMIT=on')
    exec('link_ctrl_param use_hb=off app_type=uec')
--	exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
	exec('cfg_end')
	exec('set_log log_to_file=true max_file_num=55 max_log_size=200M')
	exec('sim_start version_check=off')
	
	
end

function x2_connections(data_file)
    local IS_OK,sim_data=pcall(require,data_file)

    if not IS_OK then
        print("ERR : "..sim_data)
        print("SIM_DATA file not exits:\""..data_file.."\" or have SYNTAX ERROR")
        return
    end
    
	for _,x2_connect_data in ipairs(X2_CONNECTION) do
	
		exec('enb_x2_link_up enb='..x2_connect_data.sim_enb_id..' target='..x2_connect_data.target_gnb_id..'')
		sleep(0.5)
		exec("sim_log_set flush")
	end
end


function xp_connections(data_file)
    local IS_OK,sim_data=pcall(require,data_file)

    if not IS_OK then
        print("ERR : "..sim_data)
        print("SIM_DATA file not exits:\""..data_file.."\" or have SYNTAX ERROR")
        return
    end
    
	for _,xp_connect_data in ipairs(DSS_XP_CONNECTION) do
	
		exec('enb_xp_param id='..xp_connect_data.sim_enb_id..' xp_peers='..xp_connect_data.target_gnb_id..'')
		sleep(0.5)
		exec('enb_xp_link_up enb='..xp_connect_data.sim_enb_id..' target='..xp_connect_data.target_gnb_id..'')
		sleep(0.5)
		exec('enb_x2_link_up enb='..xp_connect_data.sim_enb_id..' target='..xp_connect_data.target_gnb_id..'')
		sleep(0.5)
		exec("sim_log_set flush")
	end
end


function dss_setup(data_file)
        
    local IS_OK,sim_data=pcall(require,data_file)

    if not IS_OK then
        print("SIM_DATA LOADING FAILED : "..sim_data)
        print("SIM_DATA file not exits:\""..data_file.."\" or have SYNTAX ERROR")
        return
    end
    for sim_enb_id,_ in pairs(SIM_ENB_DATA) do
        exec('enb_dss_param id='..sim_enb_id..' feature_flag=on message_sets=DMS3')
        sleep(3)
        exec('enb_crm_param id='..sim_enb_id..' ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200')
        sleep(3)
    end

    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_cell_param enb='..map_data.sim_enb_id..' id='..map_data.sim_enb_cell_id..' lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=4')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_cell_dss_feature enb='..map_data.sim_enb_id..' id='..map_data.sim_enb_cell_id..' nr_dl_peak_rate_increase=on superfast_allocation=on')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_cell_param enb='..map_data.sim_enb_id..' id='..map_data.sim_enb_cell_id..' dl_resource_sharing_algo=dl_prb_load_based')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_configure_partnership enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..' dss_peer='..map_data.target_gnb_id..':'..map_data.target_gnb_cell_id..'')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
    exec('enb_crm_cell_resource_reservation enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  tgt_enb='..map_data.target_gnb_id..' tgt_cell='..map_data.target_gnb_cell_id..' assigned_dl_maximum_share_to_nr=95 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
    exec('enb_dss_establish_partnership enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  tgt_enb='..map_data.target_gnb_id..' tgt_cell='..map_data.target_gnb_cell_id..'')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_cell_resource_reservation_dl enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  reset')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_cell_resource_reservation_ul enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  reset')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_dl_resource_cell_reservation cell='..map_data.sim_enb_cell_id..'  enb='..map_data.sim_enb_id..' prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=95 reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_cell_resource_coordination enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  tgt_enb='..map_data.target_gnb_id..' tgt_cell='..map_data.target_gnb_cell_id..' dir=DL')
    end
	sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_ul_resource_cell_reservation cell='..map_data.sim_enb_cell_id..'  enb='..map_data.sim_enb_id..' minimum_prb_share=30 maximum_prb_share=70')
    end

    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_cell_resource_coordination enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  tgt_enb='..map_data.target_gnb_id..' tgt_cell='..map_data.target_gnb_cell_id..'  dir=UL')
    end

    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_resource_allocation enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  tgt_enb='..map_data.target_gnb_id..' tgt_cell='..map_data.target_gnb_cell_id..'  dir=DL allocation_start_time=immediate dl_allocated_normal_subframes='..map_data.subframe_allocation..' dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106')
    end
    sleep(3)
    for _,map_data in ipairs(DSS_ENB_TO_GNB_MAP) do
        exec('enb_dss_resource_allocation enb='..map_data.sim_enb_id..' cell='..map_data.sim_enb_cell_id..'  tgt_enb='..map_data.target_gnb_id..' tgt_cell='..map_data.target_gnb_cell_id..'  dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3')
    end
end

