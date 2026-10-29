--ue deregister
exec('ue_deregister id=1-200 ue_deregister_type=switch_off')
exec('sleep 4')  --for 4s
exec('ue_deregister id=221-255 ue_deregister_type=switch_off')
exec('sleep 4')  --for 4s

---SRS beam position
exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=10 mode=fixed init_quad_pos=2 init_sub_quad_pos=1 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=13 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=14 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=15 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS')
exec('ul_mimo_srs_beam_pos_nr profile_id=16 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS')

FIRST_UE_SA_CELL = 2    --Starting SA UEid
END_UE_SA_CELL = 1 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

if END_UE_SA_CELL - FIRST_UE_SA_CELL >= 0 then
	exec('ue_register id=1')
	exec('sleep 2')  --for 2s
	exec('set_pdu_param ue=1 pdu=1 trf_type=internal')
	exec('ue_pdu_session_setup pdu=1 gw=1 ue=1 nwslice=1')
	exec('sleep 2')  --for 2s
	exec('trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 dir=dl mbps=150 protocol=udp')
	exec('trf_data_start ue=1 pdu=1 qfi=1 trf_id=2 dir=dl mbps=150 protocol=udp')
	exec('trf_data_start ue=1 pdu=1 qfi=1 trf_id=3 dir=dl mbps=150 protocol=udp')
		
	exec('sleep 2')  --for 2s
	for SA_UEID = FIRST_UE_SA_CELL, END_UE_SA_CELL do
--		exec('ue_deregister id='..SA_UEID..' ue_deregister_type=switch_off')
		exec('sleep 1')  --for 1s
		exec('ue_register id='..SA_UEID)
		exec('sleep 2')  --for 2s
		exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
		exec('ue_pdu_session_setup pdu=1 gw='..SA_UEID..' ue='..SA_UEID..' nwslice=1')
		exec('sleep 2')  --for 2s
		exec('ue_pdu_session_modify ue='..SA_UEID..' pdu=1 qosflows_to_add=4 by=amf')
		exec('sleep 2')  --for 2s
		exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=2 trf_id=1 dir=dl mbps=1 protocol=udp')
	end
	
--	for SA_UEID = FIRST_UE_SA_CELL, END_UE_SA_CELL do
--		exec('sleep 1')  --for 1s
--		
--		if (SA_UEID % 16) == 0 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
 --       elseif (SA_UEID % 16) == 1 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
--		elseif (SA_UEID % 16) == 2 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
--		elseif (SA_UEID % 16) == 3 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
--		elseif (SA_UEID % 16) == 4 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=5')
--		elseif (SA_UEID % 16) == 5 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=6')
--		elseif (SA_UEID % 16) == 6 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=7')
--		elseif (SA_UEID % 16) == 7 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=8')
--		elseif (SA_UEID % 16) == 8 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=9')
--		elseif (SA_UEID % 16) == 9 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=10')
--		elseif (SA_UEID % 16) == 10 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=11')
--		elseif (SA_UEID % 16) == 11 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=12')
--		elseif (SA_UEID % 16) == 12 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=13')
--		elseif (SA_UEID % 16) == 13 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=14')
--		elseif (SA_UEID % 16) == 14 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=15')
--		elseif (SA_UEID % 16) == 15 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=16')
--		end
--	end
	
end


FIRST_UE_SA_WO90M_CELL = 101    --Starting SA UEid
END_UE_SA_WO90M_CELL = 100 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

if END_UE_SA_WO90M_CELL - FIRST_UE_SA_WO90M_CELL >= 0 then

--	for SA_UEID = FIRST_UE_SA_WO90M_CELL, END_UE_SA_WO90M_CELL do
--		exec('sleep 1')  --for 1s
--		
--		if (SA_UEID % 16) == 0 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
--        elseif (SA_UEID % 16) == 1 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
--		elseif (SA_UEID % 16) == 2 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
--		elseif (SA_UEID % 16) == 3 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
--		elseif (SA_UEID % 16) == 4 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=5')
--		elseif (SA_UEID % 16) == 5 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=6')
--		elseif (SA_UEID % 16) == 6 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=7')
--		elseif (SA_UEID % 16) == 7 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=8')
--		elseif (SA_UEID % 16) == 8 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=9')
--		elseif (SA_UEID % 16) == 9 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=10')
--		elseif (SA_UEID % 16) == 10 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=11')
--		elseif (SA_UEID % 16) == 11 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=12')
--		elseif (SA_UEID % 16) == 12 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=13')
--		elseif (SA_UEID % 16) == 13 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=14')
--		elseif (SA_UEID % 16) == 14 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=15')
--		elseif (SA_UEID % 16) == 15 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=16')
--		end
--	end
	
	exec('sleep 2')  --for 2s
	for SA_UEID = FIRST_UE_SA_WO90M_CELL, END_UE_SA_WO90M_CELL do
--		exec('ue_deregister id='..SA_UEID..' ue_deregister_type=switch_off')
		exec('sleep 1')  --for 1s
		exec('ue_register id='..SA_UEID)
		exec('sleep 2')  --for 2s
		exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
		exec('ue_pdu_session_setup pdu=1 gw='..SA_UEID..' ue='..SA_UEID..' nwslice=1')
		exec('sleep 2')  --for 2s
		exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=1 trf_id=1 dir=dl mbps=175 protocol=udp')
	end
end

--	exec('sleep 5')  --for 5s
--	for SA_UEID = FIRST_UE_SA_CELL, END_UE_SA_CELL do
--		exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
--		exec('ue_pdu_session_setup pdu=1 gw='..SA_UEID..' ue='..SA_UEID..' nwslice=1')
--	end

--	for SA_UEID = FIRST_UE_SA_CELL, END_UE_SA_CELL do
--		exec('ue_deregister id='..SA_UEID..' ue_deregister_type=switch_off')
--	end

FIRST_UE_SA_CELL_TDD100M = 221    --Starting SA UEid
END_UE_SA_CELL_TDD100M = 254 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

if END_UE_SA_CELL_TDD100M - FIRST_UE_SA_CELL_TDD100M >= 0 then
		
	exec('sleep 2')  --for 2s
	for SA_UEID = 221, 249 do
--		exec('ue_deregister id='..SA_UEID..' ue_deregister_type=switch_off')
		exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
		exec('sleep 1')  --for 1s
		exec('ue_register id='..SA_UEID)
		exec('sleep 2')  --for 2s
		exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
		exec('ue_pdu_session_setup pdu=1 gw='..SA_UEID..' ue='..SA_UEID..' nwslice=1')
		exec('sleep 2')  --for 2s
		exec('ue_pdu_session_modify ue='..SA_UEID..' pdu=1 qosflows_to_add=4 by=amf')
		exec('sleep 2')  --for 2s
		exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=2 trf_id=1 dir=dl mbps=31 protocol=udp')
		--exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=2 trf_id=2 dir=dl mbps=175 protocol=udp')
		exec('sleep 1')  --for 1s
        --exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
	end

		exec('ue_testmode_set_nr id=250 testmode=ul_mimo_srs_beam_pos action=activate profile_id=12')
		exec('sleep 1')  --for 1s
		exec('ue_register id=250')
		exec('sleep 2')  --for 2s
		exec('set_pdu_param ue=250 pdu=1 trf_type=internal')
		exec('ue_pdu_session_setup pdu=1 gw=250 ue=250 nwslice=1')
		exec('sleep 2')  --for 2s
		--exec('ue_pdu_session_modify ue=250 pdu=1 qosflows_to_add=4 by=amf')
		exec('sleep 2')  --for 2s
		exec('trf_data_start ue=250 pdu=1 qfi=1 trf_id=1 dir=dl mbps=175 protocol=udp')
		exec('trf_data_start ue=250 pdu=1 qfi=1 trf_id=2 dir=dl mbps=175 protocol=udp')
		exec('trf_data_start ue=250 pdu=1 qfi=1 trf_id=3 dir=dl mbps=175 protocol=udp')
		exec('sleep 1')  --for 1s
		
		

--	for SA_UEID = 241, 250 do
--		exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id='..SA_UEID-236)
--		exec('sleep 1')  --for 1s
--		exec('ue_register id='..SA_UEID)
--		exec('sleep 2')  --for 2s
--		exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
--		exec('ue_pdu_session_setup pdu=1 gw='..SA_UEID..' ue='..SA_UEID..' nwslice=1')
--		exec('sleep 2')  --for 2s
--		--exec('ue_pdu_session_modify ue='..SA_UEID..' pdu=1 qosflows_to_add=4 by=amf')
--		--exec('sleep 2')  --for 2s
--		exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=1 trf_id=1 dir=dl mbps=100 protocol=udp')
--		--exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=1 trf_id=2 dir=dl mbps=175 protocol=udp')
--		exec('sleep 1')  --for 1s
--		--exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=5')
--	end
	
	
--	for SA_UEID = FIRST_UE_SA_CELL_TDD100M, END_UE_SA_CELL_TDD100M do
--		exec('sleep 1')  --for 1s
--		
--		if (SA_UEID % 16) == 0 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
 --       elseif (SA_UEID % 16) == 1 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
--		elseif (SA_UEID % 16) == 2 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
--		elseif (SA_UEID % 16) == 3 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
--		elseif (SA_UEID % 16) == 4 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=5')
--		elseif (SA_UEID % 16) == 5 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=6')
--		elseif (SA_UEID % 16) == 6 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=7')
--		elseif (SA_UEID % 16) == 7 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=8')
--		elseif (SA_UEID % 16) == 8 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=9')
--		elseif (SA_UEID % 16) == 9 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=10')
--		elseif (SA_UEID % 16) == 10 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=11')
--		elseif (SA_UEID % 16) == 11 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=12')
--		elseif (SA_UEID % 16) == 12 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=13')
--		elseif (SA_UEID % 16) == 13 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=14')
--		elseif (SA_UEID % 16) == 14 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=15')
--		elseif (SA_UEID % 16) == 15 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=16')
--		end
--	end
	
end

FIRST_UE_SA_CELL_TDD100M = 255    --Starting SA UEid
END_UE_SA_CELL_TDD100M = 250 --Total UE counts = NUMBER_OF_CELLS * UE_count_per_cell

if END_UE_SA_CELL_TDD100M - FIRST_UE_SA_CELL_TDD100M >= 0 then
		
	exec('sleep 2')  --for 2s
	for SA_UEID = FIRST_UE_SA_CELL_TDD100M, END_UE_SA_CELL_TDD100M do
--		exec('ue_deregister id='..SA_UEID..' ue_deregister_type=switch_off')
		exec('sleep 1')  --for 1s
		exec('ue_register id='..SA_UEID)
		exec('sleep 2')  --for 2s
		exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
		exec('ue_pdu_session_setup pdu=1 gw='..SA_UEID..' ue='..SA_UEID..' nwslice=1')
		exec('sleep 2')  --for 2s
		exec('ue_pdu_session_modify ue='..SA_UEID..' pdu=1 qosflows_to_add=4 by=amf')
		exec('sleep 2')  --for 2s
		exec('trf_data_start ue='..SA_UEID..' pdu=1 qfi=2 trf_id=1 dir=dl mbps=50 protocol=udp')
	end
	
--	for SA_UEID = FIRST_UE_SA_CELL_TDD100M, END_UE_SA_CELL_TDD100M do
--		exec('sleep 1')  --for 1s
--		
--		if (SA_UEID % 16) == 0 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
 --       elseif (SA_UEID % 16) == 1 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
--		elseif (SA_UEID % 16) == 2 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
--		elseif (SA_UEID % 16) == 3 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
--		elseif (SA_UEID % 16) == 4 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=5')
--		elseif (SA_UEID % 16) == 5 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=6')
--		elseif (SA_UEID % 16) == 6 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=7')
--		elseif (SA_UEID % 16) == 7 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=8')
--		elseif (SA_UEID % 16) == 8 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=9')
--		elseif (SA_UEID % 16) == 9 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=10')
--		elseif (SA_UEID % 16) == 10 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=11')
--		elseif (SA_UEID % 16) == 11 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=12')
--		elseif (SA_UEID % 16) == 12 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=13')
--		elseif (SA_UEID % 16) == 13 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=14')
--		elseif (SA_UEID % 16) == 14 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=15')
--		elseif (SA_UEID % 16) == 15 then
--			exec('ue_testmode_set_nr id='..SA_UEID..' testmode=ul_mimo_srs_beam_pos action=activate profile_id=16')
--		end
--	end
	
end

