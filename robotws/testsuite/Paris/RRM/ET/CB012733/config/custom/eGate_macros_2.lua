
function run_test_40Ue_PS_BWP()

    --#exec('ul_sinr_testmode_nr profile_id=1 pathloss=80')
    --#exec('ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-680')
    --#exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate')
    --#exec('sleep 2')
	local ue_id
	
	for ue_id = 1,20 do
		exec('ue_register id='..ue_id..' ')
		exec('sleep 2')
		exec('set_pdu_param ue='..ue_id..' pdu=1 trf_type=internal')
		exec('sleep 2')
		exec('ue_pdu_session_setup pdu=1 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=1 Mbps=2 dir=dl')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 Mbps=2 dir=ul')
		--#exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 mbps=140 dir=ul')
        exec('sleep 2')
		
	end
	
	for ue_id = 21,30 do
		exec('ue_register id='..ue_id..' ')
		exec('sleep 2')
		exec('set_pdu_param ue='..ue_id..' pdu=1 trf_type=internal')
		exec('sleep 2')
		exec('ue_pdu_session_setup pdu=1 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=1 Kbps=50 dir=dl')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 Kbps=50 dir=ul')
		--#exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 mbps=140 dir=ul')
        exec('sleep 2')
		
	end
	
	for ue_id = 31,40 do
		exec('ue_register id='..ue_id..' ')
		exec('sleep 2')
		exec('set_pdu_param ue='..ue_id..' pdu=1 trf_type=internal')
		exec('sleep 2')
		exec('ue_pdu_session_setup pdu=1 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=1 Mbps=2 dir=dl')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 Mbps=2 dir=ul')
		--#exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 mbps=140 dir=ul')
        exec('sleep 2')
		
	end
	

end
function run_test_10Ue_NSA()

	local ue_id
	exec('enb_x2_link_up enb=1 target=2')
	exec('sleep 5')
	for ue_id = 41,50 do
		exec('ue_attach id='..ue_id..' profile=1')
		exec('sleep 2')
		exec('ue_dc_enb_start ue='..ue_id..' target_gnb=2 target_cells=1 bearer=2 type=split_scg')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' id=2 dir=dl trf_id=1 Mbps=1 ')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' id=2 trf_id=1 dir=ul Mbps=1 ')
        exec('sleep 2')
		
	end
	
end

function run_test_2Ue_small()

	local ue_id
	
	for ue_id = 51,52 do
		exec('ue_register id='..ue_id..' ')
		exec('sleep 2')
		exec('set_pdu_param ue='..ue_id..' pdu=1 trf_type=internal')
		exec('sleep 2')
		exec('ue_pdu_session_setup pdu=1 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=1 mbps=140 dir=dl')
		--#exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 mbps=140 dir=ul')
        exec('sleep 1')
        exec('bearer_stats ue='..ue_id..' pdu=1 qfi=1 dir=dl')
		exec('sleep 3')
		
	end


end


function run_test_10Ue_VONR_and_UL()

    exec('smf_param additional_qosflows_to_activate=2,3 id=1')
    exec('sleep 3')
    exec('set_pdu_param ue=31-40 pdu=3 trf_type=internal')
    exec('sleep 3')
	local ue_id
	
	

	for ue_id = 31,40 do	
		exec('ue_register id='..ue_id..' ')
		exec('sleep 3')
		exec('set_pdu_param ue='..ue_id..' pdu=3 trf_type=internal')
		exec('sleep 3')
		exec('ue_pdu_session_setup pdu=3 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 3')
		exec('ue_pdu_session_modify ue='..ue_id..' pdu=3 qosflows_to_add=2 by=amf')
		exec('sleep 3')
		exec('ue_pdu_session_modify  ue='..ue_id..' pdu=3 qosflows_to_add=3 by=amf')
		exec('sleep 3')
		exec('trf_data_start ue='..ue_id..' pdu=3 qfi=1 trf_id=1 protocol=udp mbps=5 dir=ul')
		exec('sleep 3')
		exec('trf_data_start ue='..ue_id..' pdu=3 qfi=3 trf_id=5 dir=ul period_ms=40 rtp_codec=amr_wb_18_25')
        --#exec('trf_data_start ue='..ue_id..' pdu=3 qfi=3 trf_id=6 dir=ul period_ms=40 rtp_codec=g728')
        exec('sleep 3')
        exec('bearer_stats ue='..ue_id..' pdu=3 qfi=1 dir=ul')
		exec('bearer_stats ue='..ue_id..' pdu=3 qfi=2 dir=ul')
		exec('bearer_stats ue='..ue_id..' pdu=3 qfi=3 dir=ul')
	end

	
end

function run_test_10Ue_VONR_and_DL()

    exec('smf_param additional_qosflows_to_activate=2,3 id=1')
    exec('sleep 3')
    exec('set_pdu_param ue=41-50 pdu=3 trf_type=internal')
    exec('sleep 3')
	local ue_id
	
	for ue_id = 41,50 do
	
		exec('ue_register id='..ue_id..' ')
		exec('sleep 3')
		exec('set_pdu_param ue='..ue_id..' pdu=3 trf_type=internal')
		exec('sleep 3')
		exec('ue_pdu_session_setup pdu=3 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 3')
		exec('ue_pdu_session_modify ue='..ue_id..' pdu=3 qosflows_to_add=2 by=amf')
		exec('sleep 3')
		exec('ue_pdu_session_modify  ue='..ue_id..' pdu=3 qosflows_to_add=3 by=amf')
		exec('sleep 3')
		exec('trf_data_start ue='..ue_id..' pdu=3 qfi=1 trf_id=1 protocol=udp mbps=5 dir=dl')
		exec('sleep 3')
		exec('trf_data_start ue='..ue_id..' pdu=3 qfi=3 trf_id=5 dir=dl period_ms=40 rtp_codec=amr_wb_18_25')
        --#exec('trf_data_start ue='..ue_id..' pdu=3 qfi=3 trf_id=6 dir=dl period_ms=40 rtp_codec=g728')
        exec('sleep 3')
        exec('bearer_stats ue='..ue_id..' pdu=3 qfi=1 dir=dl')
		exec('bearer_stats ue='..ue_id..' pdu=3 qfi=2 dir=dl')
		exec('bearer_stats ue='..ue_id..' pdu=3 qfi=3 dir=dl')
	end

	
end

function run_test_50Ue_CELL2()

    --#exec('ul_sinr_testmode_nr profile_id=1 pathloss=80')
    --#exec('ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-680')
    --#exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate')
    --#exec('sleep 2')
	local ue_id
print('PROCESSING')	
	for ue_id = 51,100 do
		exec('ue_register id='..ue_id..' ')
		exec('sleep 2')
		exec('set_pdu_param ue='..ue_id..' pdu=1 trf_type=internal')
		exec('sleep 2')
		exec('ue_pdu_session_setup pdu=1 ue='..ue_id..' nwslice=1 gw='..ue_id..' ')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=1 Mbps=2 dir=dl')
		exec('sleep 2')
		exec('trf_data_start ue='..ue_id..' pdu=1 qfi=1 trf_id=2 Mbps=2 dir=ul')
        exec('sleep 2')
		print ("Ue : ", ue_id)
	end
print('ALL UE REGISTERED ON CELL2')	
end

function run_check_all_ues_dl_tput()

	local ue_id
	
	for ue_id = 1,40 do
		exec('ue_stats_nr id='..ue_id..' type=pdsch scell=0-5')
		exec('sleep 2')
	end
	for ue_id = 41,50 do
		exec('ue_stats_nr    id='..ue_id..' type=pdsch    scell=0-20')
		exec('sleep 2')
	end
	
end

function run_check_all_ues_ul_tput()

	local ue_id
	
	for ue_id = 1,50 do
		exec('ue_stats_nr id='..ue_id..' type=pusch scell=0-5')
		exec('sleep 2')
	end
	for ue_id = 41,50 do
		exec('ue_stats_nr    id='..ue_id..' type=pusch    scell=0-20')
		exec('sleep 2')
	end
	
end

function run_check_all_ues_dl_tput_CELL2()

	local ue_id
	
	for ue_id = 51,100 do
		exec('ue_stats_nr id='..ue_id..' type=pdsch scell=0-5')
		exec('sleep 2')
	end
end

function run_check_all_ues_ul_tput_CELL2()

	local ue_id
	
	for ue_id = 51,100 do
		exec('ue_stats_nr id='..ue_id..' type=pusch scell=0-5')
		exec('sleep 2')
	end
	
end
function deregister_all_ues()
	local ue_id
	
	for ue_id = 1,40 do
		exec('ue_deregister id='..ue_id..' by=amf')
		exec('sleep 2')
	end
	
	for ue_id = 41,50 do
		exec('ue_detach id='..ue_id..' ')
		exec('sleep 2')
	end
end	

function deregister_all_ues_CELL2()
	local ue_id
	
	for ue_id = 51,100 do
		exec('ue_deregister id='..ue_id..' by=amf')
		exec('sleep 2')
	end

end	
