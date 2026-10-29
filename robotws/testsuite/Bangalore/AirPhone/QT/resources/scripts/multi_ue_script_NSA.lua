-- Copyright (c) 2019 Nokia. All rights reserved.
-- Version 1.0 == Modified date 23-02-2021 -- Replaced “sequence LTE attach” with “MUE LTE attach together” 
-- Version 1.1 == Modified date 24-02-2021 -- DL traffic is disable for attach/detach with minimal data function
-- Version 1.2 == Modified date 24-02-2021 -- DL traffic is disabled for attach/detach with minimal data function in attach_detach_with_state_transition function 
-- Version 1.3 == Modified date 25-02-2021 -- sgnb addition check is added before triggering data for state transition functions
-- Version 1.4 == Modified date 01-03-2021 -- sgnb addition and sgnb release functions are addded  without any sleep timer
-- Version 1.5 == Modified date 01-03-2021 -- attach_detach_complete_call_without_timer is added
-- Version 1.6 == Modified date 03-03-2021 -- attach, attach_detach functions are added for 3 cell configurations
-- Version 1.7 == Modified date 03-03-2021 -- Traffic is diabled for state transition UEs
-- Version 1.8 == Modified date 12-03-2021 -- LTE attach sequence function is added
-- Version 1.9 == Modified date 15-03-2021 -- LTE attach sequence is handled based on previous UE lte attach result
-- Version 2.0 == Modified date 17-03-2021 -- Debug prints added during sgnb release and detach and lte_sequence functions are removed

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'

function lte_attach_with_profile_multi_ue(num_ues, prof_id)
    exec('ue_attach id=1-'..num_ues..' profile='..prof_id)
    sleep(1)
end

function lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
    exec('ue_attach id='..start_ue..'-'..end_ue..' profile='..prof_id)
    sleep(1)
end

function sgnb_addition_with_range(func_name, err, ue_id, nr_bid, target_gnb, target_gnb_cell)
    printStep(func_name .. ": SgNB Addition with SCG Split Bearer")
    local ue_
    ue_ = ue(ue_id)
    if ue_.state == ue.ON then	
        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..nr_bid..' type=split_scg')
        sleep(1)
    end
    sleep(1)
end

function lte_detach_multi_ue(num_ues)
    local func_name = "lte_detach_multi_ue"
    local result = {}
    local err = {}
    for ue_id=1, num_ues do
	    print('Triggering LTE detach for UE='..ue_id)
        detach(func_name, ue_id, err, result)
    end
    print("All the UEs are detached successfully")
end

function lte_detach_multi_ue_with_range(start_ue, end_ue)
    local func_name = "lte_detach_multi_ue"
    local result = {}
    local err = {}
    for ue_id=start_ue, end_ue do
	    print('Triggering LTE detach for UE='..ue_id) 
        detach(func_name, ue_id, err, result)
    end
    print('UEs '..start_ue..'to '..end_ue..' are detached successfully')
end

function sgnb_addition_multi_ue_with_range(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
    local func_name = "sgnb_addition_multi_ue_with_range"
    local err = {}

    for ue_id=start_ue, end_ue do
	    local ue_
	    ue_ = ue(ue_id)
	    if ue_.state == ue.ON then  
            sgnb_addition_with_range(func_name, err, ue_id, bearer_id, target_gnb, target_gnb_cell)
		end
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end
    end
    print("Multi-UE SgNBAddition is successful")
end

function sgnb_release_and_detach_multi_ue(num_ues, bearer_id)
    local func_name = "sgnb_release_and_detach_multi_ue"
    local result = {}
    local err = {}
    local ue_ = {}
    local pdcptype = ''
    for ue_id=1, num_ues do
        ue_ = ue(tonumber(ue_id))
		br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
		end
		print('PDCP value is '..pdcptype..' UE='..ue_id)
	    if (ue_.state == ue.ON and pdcptype == 2) then
		    print('Triggering sgNB release for UE='..ue_id)
		    sgnb_release(func_name, err, ue_, ue_id, bearer_id)
		end
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end
		print('Triggering LTE detach for UE='..ue_id)
        detach(func_name, ue_id, err, result)
    end
    print("Multi-UE SgNB Release is successful")
end

function sgnb_release_multi_ue_with_range(start_ue, end_ue, bearer_id)
    local ue_ = {}
    local pdcptype = ''
    for ue_id=start_ue, end_ue do
        ue_ = ue(tonumber(ue_id))
		br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
			print('PDCP value is '..pdcptype..' UE='..ue_id)
		end
		if (ue_.state == ue.ON and pdcptype == 2) then
		    print('Triggering sgNB release for UE='..ue_id)
            exec('enb_ue_dc_release ue='..ue_id..' bearer='..bearer_id..' by=enb cause=off')
			sleep(0.7)
		end
    end
    print("Multi-UE SgNB Release is successful")
end

function sgnb_release_and_detach_single_ue(ue_id, bearer_id)
    local func_name = "sgnb_release_and_detach_single_ue"
    local result = {}
    local err = {}
    local ue_ = {}
    local pdcptype = ''
    ue_ = ue(tonumber(ue_id))
    br_count = get_number_of_bearers(ue_)
	if br_count ~= 0 then
	    pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
	end
	if ue_.state == ue.IDLE then
	    print("UE "..ue_id.."is already in IDLE state")
	else
	    print('PDCP value is '..pdcptype..' UE='..ue_id)
        if (ue_.state == ue.ON and pdcptype == 2) then
		    print('Triggering sgNB release for UE='..ue_id)
	        exec('enb_ue_dc_release ue='..ue_id..' bearer='..bearer_id..' by=enb cause=off')
		    sleep(0.7)
	    end
		print('Triggering LTE detach for UE='..ue_id)
		detach(func_name, ue_id, err, result)
	end
	print("SgNB Release and detach is successful for UE"..ue_id)
end

function sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
    local func_name = "sgnb_release_and_detach_multi_ue_with_range"
    local result = {}
    local err = {}
    local ue_ = {}

    for ue_id=start_ue, end_ue do
        sgnb_release_and_detach_single_ue(ue_id, bearer_id)
	end
	print("Multi-UE SgNB Release is successful")
end

function sgnb_addition_multi_ue(num_ues, bearer_id, target_gnb, target_gnb_cell)
    local func_name = "sgnb_addition_multi_ue"
    local err = {}

    for ue_id=1, num_ues do
	    local ue_
	    ue_ = ue(ue_id)
	    if ue_.state == ue.ON then
            sgnb_addition(func_name, err, ue(tonumber(ue_id)), ue_id, bearer_id, target_gnb, target_gnb_cell)
		end
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end
    end
    print("Multi-UE SgNBAddition is successful")
end

function start_traffic_kbps(num_ues, brid, dir, trf_id, kbpsrate, packetsize)
    if not packetsize then
        for ue_id=1, num_ues do
            exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate)
        end
	else
	    for ue_id=1, num_ues do
            exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate..' size='..packetsize)
        end
	end
end

function start_traffic_kbps_with_range(UE_TYPE, start_ue, end_ue, brid, dir, trf_id, kbpsrate, packetsize)
    if not packetsize then
        for ue_id=start_ue, end_ue do
            exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate)
        end
	else
	    for ue_id=start_ue, end_ue do
            exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate..' size='..packetsize)
        end
	end
    print(UE_TYPE..' '..dir..' Traffic is started successfully')
    exec('sim_log_set flush')
end

function stop_traffic(start_ue, end_ue, brid, dir)
    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' id='..brid..' dir='..dir)
    end
end
	    
function run_traffic_with_5g_attach(num_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate, packetsize)
	local brid = 2
    exec('ue_attach id=1-'..num_ues..' profile=1')
	sleep(1)
	for ue_id=1, num_ues do
        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
	end
	sleep(60)
	if not packetsize then
	    run_traffic_only(num_ues, brid, dir, ul_bpsrate, dl_bpsrate)
	else
	    run_traffic_only(num_ues, brid, dir, ul_bpsrate, dl_bpsrate, packetsize)
	end
end

function run_traffic_only(num_ues, brid, dir, ul_bpsrate, dl_bpsrate, packetsize)
    local trf_id = 0
	for ue_id=1, num_ues do
	    local ul_bpsrate_temp = ul_bpsrate
		local dl_bpsrate_temp = dl_bpsrate
	    trf_id = 1
		while ((ul_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "ul"))))) do
			if (ul_bpsrate_temp >= 175000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000 size='..packetsize)
				end
			elseif (ul_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp..' size='..packetsize)
				end
			end
			ul_bpsrate_temp = ul_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 175000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000 size='..packetsize)
				end
			elseif (dl_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp..' size='..packetsize)
				end
			end
			dl_bpsrate_temp = dl_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
    end
end

function run_traffic_only_with_range(start_ue, end_ue, brid, dir, ul_bpsrate, dl_bpsrate, packetsize)
    local trf_id = 0
	for ue_id=start_ue, end_ue do
	    local ul_bpsrate_temp = ul_bpsrate
		local dl_bpsrate_temp = dl_bpsrate
	    trf_id = 1
		while ((ul_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "ul"))))) do
			if (ul_bpsrate_temp >= 175000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000 size='..packetsize)
				end
			elseif (ul_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp..' size='..packetsize)
				end
			end
			ul_bpsrate_temp = ul_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 175000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000 size='..packetsize)
				end
			elseif (dl_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp..' size='..packetsize)
				end
			end
			dl_bpsrate_temp = dl_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
    end
end

function run_traffic_for_partial_ues_with_5g_attach(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate, packetsize)
    local brid = 2
	exec('ue_attach id=1-'..num_ues..' profile=1')
	sleep(1)
	for ue_id=1, num_ues do
        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
		sleep(1)
	end
	sleep(20)
	if not packetsize then
	    run_traffic_only(traffic_ues, brid, dir, ul_bpsrate, dl_bpsrate)
	else
	    run_traffic_only(traffic_ues, brid, dir, ul_bpsrate, dl_bpsrate, packetsize)
	end
end

function attach_defined_ues(start_ue, end_ue, brid, target_gnb, target_gnb_cell)
    local prof_id = 1
	lte_attach_5g_attach(start_ue, end_ue, prof_id, target_gnb, target_gnb_cell, brid)
end

function run_traffic_and_detach_defined_ues(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate, start_release_ue, end_release_ue, timer, iterations, packetsize)
    if not packetsize then
        run_traffic_for_partial_ues_with_5g_attach(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate)
	else
	    run_traffic_for_partial_ues_with_5g_attach(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate, packetsize)
	end
	sleep(timer)
	sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
	sleep(2)
	attach_detach_defined_ues(start_release_ue, end_release_ue, bearer_id, target_gnb, target_gnb_cell, timer, iterations)
end

function attach_detach_defined_ues(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, timer, iterations)
    for iter=1, iterations do
	    print('Iteration '..iter..' is started')
        attach_defined_ues(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
		sleep(timer)
		sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
		sleep(2)
	end
	print('Script execution is finished')
end

function attach_mue_with_delay(start_ue, end_ue, brid, target_gnb, target_gnb_cell, delay_bw_ue)
    exec('ue_attach id='..start_ue..'-'..end_ue..' profile=1')
	sleep(1)
 	for ue_id=start_ue, end_ue do
	    sleep(1)
		local ue_
	    ue_ = ue(ue_id)
	    if ue_.state == ue.ON then
		    exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..brid..' type=split_scg')
		end
		sleep(delay_bw_ue)
	end   
end

function run_traffic_model_1(g1_start_ue, g1_end_ue, g2_start_ue, g2_end_ue, g3_start_ue, g3_end_ue, g4_start_ue, g4_end_ue, g1_traffic_dir, g1_ulrate, g1_dlrate, g1_packsize, g2_traffic_dir, g2_ulrate, g2_dlrate, g2_packsize, g3_attach_delay_bw_ue, g4_attach_delay_bw_ue, g4_traffic_dir, g4_ulrate, g4_dlrate, g4_packsize, g4_traffic_duration_per_iteration, g4_start_traffic_delay_after_stop, testduration_mins)
    local bearer_id = 2
	local target_gnb = 2
	local target_gnb_cell = 2
	local testduration_secs = testduration_mins * 60
	local start_wholetest_time = 0
	local timediff = 0
	local idletime = 600
	local looptime_g3 = 0
	local looptime_g4 = 0
	local starttime_g3 = 0
    local starttime_g4 = 0
	
    attach_defined_ues(g1_start_ue, g1_end_ue, bearer_id, target_gnb, target_gnb_cell)
	run_traffic_only(g1_start_ue, g1_end_ue, bearer_id, g1_traffic_dir, g1_ulrate, g1_dlrate)
	    
	attach_defined_ues(g2_start_ue, g2_end_ue, bearer_id, target_gnb, target_gnb_cell)
	run_traffic_only(g2_start_ue, g2_end_ue, bearer_id, g2_traffic_dir, g2_ulrate, g2_dlrate)
	    
    attach_mue_with_delay(g3_start_ue, g3_end_ue, bearer_id, target_gnb, target_gnb_cell, g3_attach_delay_bw_ue)
	    
	attach_mue_with_delay(g4_start_ue, g4_end_ue, bearer_id, target_gnb, target_gnb_cell, g4_attach_delay_bw_ue)
	run_traffic_only(g4_start_ue, g4_end_ue, bearer_id, g4_traffic_dir, g4_ulrate, g4_dlrate, g4_packsize)
    
	local start_wholetest_time = os.time()
	while (timediff < testduration_secs) do
		if (looptime_g3 > idletime) then
		    lte_detach_multi_ue_with_range(g3_start_ue, g3_end_ue)
			sleep(5)
			attach_mue_with_delay(g3_start_ue, g3_end_ue, bearer_id, target_gnb, target_gnb_cell, g3_attach_delay_bw_ue)
			looptime_g3 = 0
			starttime_g3 = os.time()
		end
		if (looptime_g4 >= g4_traffic_duration_per_iteration) then
		    stop_traffic(g4_start_ue, g4_end_ue, bearer_id, g4_traffic_dir)
		    sleep(g4_start_traffic_delay_after_stop)
			run_traffic_only(g4_start_ue, g4_end_ue, bearer_id, g4_traffic_dir, g4_ulrate, g4_dlrate, g4_packsize)
			looptime_g4 = 0
			starttime_g4 = os.time()
		end
		sleep(5)
		looptime_g3 = os.time() - starttime_g3
		looptime_g4 = os.time() - starttime_g4
		timediff = os.time() - start_wholetest_time
	end
	lte_detach_multi_ue_with_range(g1_start_ue, g4_end_ue) 
end

function handover(ue_id, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
    exec('ue_measurement_send_nr id='..ue_id..' meas_id='..meas_id..' event='..measevent..' srsrp_nr='..srsrp..' srsrq_nr='..srsrq..' phycell_id='..target_phycellid..' nrsrp_nr='..nrsrp..' nrsrq_nr='..nrsrq)
end

function handover_to_source(ue_id)
    exec('gnb_ue_dc_change ue='..ue_id..' gnb=2 target_sgnb_cells=2 cause=RN_sCG_Mobility')
end

function handover_mue(start_ue_ho, end_ue_ho, delay_bw_ue_ho, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq, ho_type)
	for ue_id=start_ue_ho, end_ue_ho do
	    handover(ue_id, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
		sleep(delay_bw_ue_ho)
	end
    print(ho_type..' NSA HO completed')
    exec('sim_log_set flush')
end

function handover_mue_to_source(start_ue_ho, end_ue_ho, delay_bw_ue_ho)
	for ue_id=start_ue_ho, end_ue_ho do
	    handover_to_source(ue_id)
		sleep(delay_bw_ue_ho)
	end
end

function attach_and_handover(num_ues, start_ue_ho, end_ue_ho, delay_bw_ue_ho, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
    local prof_id = 1
	local bearer_id = 2
	local target_gnb = 2
	local target_gnb_cell = 2
    lte_attach_with_profile_multi_ue(num_ues, prof_id)
    sgnb_addition_multi_ue(num_ues, bearer_id, target_gnb, target_gnb_cell)
	sleep(delay_bw_ue_ho)
	for ue_id=start_ue_ho, end_ue_ho do
	    handover(ue_id, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
		sleep(delay_bw_ue_ho)
	end
end

function lte_attach_5g_attach(start_ue, end_ue, prof_id, target_gnb, target_gnb_cell, brid)
    exec('ue_attach id='..start_ue..'-'..end_ue..' profile='..prof_id)
	sleep(1)
    for ue_id=start_ue, end_ue do
		local ue_
		ue_ = ue(ue_id)
		if ue_.state == ue.ON then		
		    exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..brid..' type=split_scg')
		end
		sleep(2)
	end
end

function attach_defined_ues_nonsequence(start_ue, end_ue, brid, target_gnb, target_gnb_cell)
    local prof_id = 1
	exec('ue_attach id='..start_ue..'-'..end_ue..' profile='..prof_id)
	sleep(1)
	sgnb_addition_multi_ue_with_range(start_ue, end_ue, brid, target_gnb, target_gnb_cell)
end

function attach_detach_defined_ues_nonsequence(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, timer, iterations)
    for iter=1, iterations do
	    print('Iteration '..iter..' is started')
        attach_defined_ues_nonsequence(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
		sleep(timer)
		sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
		sleep(2)
	end
end

function run_traffic_model_2(g1_start_ue, g1_end_ue, g2_start_ue, g2_end_ue, g3_start_ue, g3_end_ue, g4_start_ue, g4_end_ue, g1_traffic_dir, g1_ulrate, g1_dlrate, g2_traffic_dir, g2_ulrate, g2_dlrate, g3_delay_bw_attach_detach, g4_delay_bw_ue_ho, g4_delay_bw_ho_iteration, testduration_mins)
    local bearer_id = 2
	local target_gnb = 2
	local target_gnb_cell = 2
	local testduration_secs = testduration_mins * 60
	local start_wholetest_time = 0
	local timediff = 0
	local idletime = 600
	local looptime_g3 = 0
	local looptime_g4 = 0
	local starttime_g3 = 0
    local starttime_g4 = 0
	local meas_id = 1
	local measevent = 'A3'
	local srsrp = 10
	local srsrq = 10
	local nrsrp = 20
	local nrsrq = 20
	local target_phycellid = 51
	
    attach_defined_ues(g1_start_ue, g1_end_ue, bearer_id, target_gnb, target_gnb_cell)
	run_traffic_only_with_range(g1_start_ue, g1_end_ue, bearer_id, g1_traffic_dir, g1_ulrate, g1_dlrate)
	    
	attach_defined_ues(g2_start_ue, g2_end_ue, bearer_id, target_gnb, target_gnb_cell)
	run_traffic_only_with_range(g2_start_ue, g2_end_ue, bearer_id, g2_traffic_dir, g2_ulrate, g2_dlrate)
	    
    attach_defined_ues(g3_start_ue, g3_end_ue, bearer_id, target_gnb, target_gnb_cell)
	
	attach_defined_ues(g4_start_ue, g4_end_ue, bearer_id, target_gnb, target_gnb_cell)
	handover_mue(g4_start_ue, g4_end_ue, g4_delay_bw_ue_ho, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
	
    local start_wholetest_time = os.time()
	while (timediff < testduration_secs) do
		if (looptime_g3 > g3_delay_bw_attach_detach) then
		    lte_detach_multi_ue_with_range(g3_start_ue, g3_end_ue)
			sleep(5)
			attach_defined_ues_nonsequence(g3_start_ue, g3_end_ue, bearer_id, target_gnb, target_gnb_cell)
			looptime_g3 = 0
			starttime_g3 = os.time()
		end
		if (looptime_g4 > g4_delay_bw_ho_iteration) then
		    handover_mue_to_source(g4_start_ue, g4_end_ue, g4_delay_bw_ue_ho)
			sleep(5)
			lte_detach_multi_ue_with_range(g4_start_ue, g4_end_ue)
			sleep(2)
			attach_defined_ues_nonsequence(g4_start_ue, g4_end_ue, bearer_id, target_gnb, target_gnb_cell)
			sleep(5)
		    handover_mue(g4_start_ue, g4_end_ue, g4_delay_bw_ue_ho, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
			looptime_g4 = 0
			starttime_g4 = os.time()
		end
		sleep(60)
		looptime_g3 = os.time() - starttime_g3
		looptime_g4 = os.time() - starttime_g4
		timediff = os.time() - start_wholetest_time
	end
end

function ue_display(ue_id, bearer_id)
    local ue_
	local bearer_
	local b
    ue_ = ue(ue_id)
	bearer_ = ue_:bearer(bearer_id)
	b = bearer_:get_info(initiator.ENB).pdcp_type
	print(b)
end

function sgnb_release_detach_single_UE(ue_id, bearer_id)
    local func_name = "sgnb_release_detach_single_UE"
    local result = {}
    local err = {}
    local ue_ = {}
    local pdcptype = ''
    ue_ = ue(tonumber(ue_id))
	br_count = get_number_of_bearers(ue_)
    if br_count ~= 0 then
	    pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
		print('PDCP value is '..pdcptype..' UE='..ue_id)
	    if (ue_.state == ue.ON and pdcptype == 2) then
		    print('Triggering sgNB release for UE='..ue_id)
	        sgnb_release(func_name, err, ue_, ue_id, bearer_id)
		    sleep(0.1)
	    end
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end
	    if pdcptype == 1 then
		    print('Triggering LTE detach for UE='..ue_id)
            exec('ue_detach id='..ue_id)
	    end
	end
    print('SgNB Release and Detach is successful for UE='..ue_id)
end	

    

function attach_detach_concurrent(start_ue, end_ue, callholdingtime, overallduration_mins, target_gnb, target_cell, bearer_id)
    local starttime_ueid = {}
	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
	exec('ue_attach id='..start_ue..'-'..end_ue..' profile=1')
	sleep(1)
	starttime_overall = os.time()
	for ue_id=start_ue, end_ue do
	    local ue_
        ue_ = ue(ue_id)
		br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
	        if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
	            exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_cell..' bearer='..bearer_id..' type=split_scg')
			    starttime_ueid[ue_id] = os.time()
			    sleep(3)
		    end
		end
		for reattach_ueid=start_ue, end_ue do
		    if reattach_ueid < ue_id then
		        starttime_ueid[reattach_ueid] = monitor_start_attach_detach(reattach_ueid, starttime_ueid[reattach_ueid], callholdingtime, target_gnb, target_cell, bearer_id)
			end
		end
	end
	
	while(endtime_overall < overallduration_seconds) do
	    for ue_id=start_ue, end_ue do
	        starttime_ueid[ue_id] = monitor_start_attach_detach(ue_id, starttime_ueid[ue_id], callholdingtime, target_gnb, target_cell, bearer_id)
		end
		endtime_overall = os.time() - starttime_overall
	end
	sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
end

function monitor_start_attach_detach(ue_id, starttime, callholdingtime, target_gnb, target_cell, bearer_id)
    local func_name = "monitor_start_attach_detach"
    local err = {}
    timediff = os.time() - starttime
	local restarttime = 0
	local ue_
    ue_ = ue(ue_id)
	local pdcptype = 0
	local br_count = 0
	
	if (timediff > callholdingtime) then
	    if ue_.state == ue.ON then
		    br_count = get_number_of_bearers(ue_)
		    if br_count > 0 then
		        if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 then
				    sgnb_release_detach_single_UE(ue_id, bearer_id)
				elseif ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
				    exec('ue_detach id='..ue_id)
				end
            else
                print('UE'..ue_id..' does not have any active bearer')	
			end
		end
   		if ue_.state == ue.OFF then
		    exec('ue_attach id='..ue_id..' profile=1')
		end
		sleep(0.1)
		br_count = get_number_of_bearers(ue_)
		if br_count > 0 then
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
		        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_cell..' bearer='..bearer_id..' type=split_scg')
			    restarttime = os.time()
			    return restarttime
		    else
		        return starttime
		    end
		end
	else
	    return starttime
	end
end

function attach_detach_defined_ues_nonsequence_3cell(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3 ,bearer_id, target_gnb, target_gnb_cell1, target_gnb_cell2, target_gnb_cell3, timer, iterations)
    for iter=1, iterations do
	    print('Iteration '..iter..' is started')
        attach_defined_ues_nonsequence(start_ue_cell1, end_ue_cell1, bearer_id, target_gnb, target_gnb_cell1)
		attach_defined_ues_nonsequence(start_ue_cell2, end_ue_cell2, bearer_id, target_gnb, target_gnb_cell2)
		attach_defined_ues_nonsequence(start_ue_cell3, end_ue_cell3, bearer_id, target_gnb, target_gnb_cell3)
		sleep(timer)
		sgnb_release_and_detach_multi_ue_with_range(start_ue_cell1, end_ue_cell1, bearer_id)
		sgnb_release_and_detach_multi_ue_with_range(start_ue_cell2, end_ue_cell2, bearer_id)
		sgnb_release_and_detach_multi_ue_with_range(start_ue_cell3, end_ue_cell3, bearer_id)
		sleep(2)
	end
end

function attach_defined_ues_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
    local prof_id = 1
	local sgnbadd_flag = ''
	lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
	for ue_id=start_ue, end_ue do
	    local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
		        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
				sgnbadd_flag = wait_sgnb_addition_status(ue_id, bearer_id)
			end
		end
	end
end

function attach_defined_ues_nonsequence_3cell(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3 ,bearer_id, target_gnb, target_gnb_cell1, target_gnb_cell2, target_gnb_cell3)
    attach_defined_ues_nonsequence(start_ue_cell1, end_ue_cell1, bearer_id, target_gnb, target_gnb_cell1)
    attach_defined_ues_nonsequence(start_ue_cell2, end_ue_cell2, bearer_id, target_gnb, target_gnb_cell2)
    attach_defined_ues_nonsequence(start_ue_cell3, end_ue_cell3, bearer_id, target_gnb, target_gnb_cell3)
end

function handover_mue_3cell(start_ue_ho, end_ue_ho, delay_bw_ue_ho, target_phycellid1, target_phycellid2, target_phycellid3, meas_id, measevent, srsrp1, srsrp2, srsrp3, srsrq1, srsrq2, srsrq3, nrsrp1, nrsrp2, nrsrp3, nrsrq1, nrsrq2, nrsrq3, timer, Iterations)
    for iter=1, iterations do
	    print('Iteration '..iter..' is started')
	    for ue_id=start_ue_ho, end_ue_ho do
            handover(ue_id, target_phycellid2, meas_id, measevent, srsrp1, srsrq1, nrsrp2, nrsrq2)
            sleep(delay_bw_ue_ho)
        end
	    for ue_id=start_ue_ho, end_ue_ho do
            handover(ue_id, target_phycellid3, meas_id, measevent, srsrp2, srsrq2, nrsrp3, nrsrq3)
            sleep(delay_bw_ue_ho)
        end
	    for ue_id=start_ue_ho, end_ue_ho do
            handover(ue_id, target_phycellid1, meas_id, measevent, srsrp3, srsrq3, nrsrp1, nrsrq1)
            sleep(delay_bw_ue_ho)
        end
		sleep(timer)
	end
end

function attach_detach_defined_ues_nonsequence_and_perform_HO_for_few_ues_3cell(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3 ,bearer_id, target_gnb, target_gnb_cell1, target_gnb_cell2, target_gnb_cell3, start_ue_ho, end_ue_ho, delay_bw_ue_ho, target_phycellid1, target_phycellid2, target_phycellid3, meas_id, measevent, srsrp1, srsrp2, srsrp3, srsrq1, srsrq2, srsrq3, nrsrp1, nrsrp2, nrsrp3, nrsrq1, nrsrq2, nrsrq3, timer, iterations)
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        attach_defined_ues_nonsequence(start_ue_cell1, end_ue_cell1, bearer_id, target_gnb, target_gnb_cell1)
		for ue_id=start_ue_ho, end_ue_ho do
		    handover(ue_id, target_phycellid2, meas_id, measevent, srsrp1, srsrq1, nrsrp2, nrsrq2)
            sleep(delay_bw_ue_ho)
		end
        attach_defined_ues_nonsequence(start_ue_cell2, end_ue_cell2, bearer_id, target_gnb, target_gnb_cell2)
	    for ue_id=start_ue_ho, end_ue_ho do
            handover(ue_id, target_phycellid3, meas_id, measevent, srsrp2, srsrq2, nrsrp3, nrsrq3)
            sleep(delay_bw_ue_ho)
        end
        attach_defined_ues_nonsequence(start_ue_cell3, end_ue_cell3, bearer_id, target_gnb, target_gnb_cell3)
		for ue_id=start_ue_ho, end_ue_ho do
            handover(ue_id, target_phycellid1, meas_id, measevent, srsrp3, srsrq3, nrsrp1, nrsrq1)
            sleep(delay_bw_ue_ho)
        end
        sleep(timer)
        sgnb_release_and_detach_multi_ue_with_range(start_ue_cell1, end_ue_cell1, bearer_id)
        sgnb_release_and_detach_multi_ue_with_range(start_ue_cell2, end_ue_cell2, bearer_id)
        sgnb_release_and_detach_multi_ue_with_range(start_ue_cell3, end_ue_cell3, bearer_id)
        sleep(2)
    end
end

function get_number_of_bearers(ue_)
	local bearer_count = 0
	for bearer in ue_:bearers(bearer.ON) do
	    local pdcp = bearer:get_info(initiator.ENB).pdcp_type
	    print('PDCP_Value='..pdcp)
		if bearer:get_info(initiator.ENB).pdcp_type == 1 or bearer:get_info(initiator.ENB).pdcp_type == 2 then
			bearer_count = bearer_count + 1
		end
	end
	return bearer_count
end

function ue_active_in_5G_or_not(start_ue, end_ue)
    local br_count = 0
	local pdcptype = 0
    for ue_id=start_ue, end_ue do
	    ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
    	    pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
    	    if (ue_.state == ue.ON and pdcptype == 2) then
	   	 	    print('UE'..ue_id..' is in 5G state')
	   	    else 
			    if (ue_.state == ue.ON and pdcptype == 1) then
			        print('UE'..ue_id..' is in 4G state')
			    end
			end
		end
    end
end

function attach_detach_defined_ues_for_duration(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, timer, totaltime_hours)
    local totaltime_seconds = totaltime_hours * 60 * 60
	local timediff = 0
	local starttime = os.time()
	local iteration = 1
    while(timediff < totaltime_seconds) do
	    print('Iteration '..iteration..' is started')
        attach_defined_ues_nonsequence(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
		sleep(timer)
		sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
		sleep(2)
		timediff = os.time() - starttime
		iteration = iteration + 1
	end
end

function attach_with_complete_call(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps, ul_packetsize, dl_packetsize)
    local num_ues =  end_ue - start_ue + 1
    local ul_rate_bps_per_ue = round(ul_rate_bps/num_ues)
	local dl_rate_bps_per_ue = round(dl_rate_bps/num_ues)
	local prof_id = 1
	local trf_id = 1
	lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
	sleep(0.5)
	for ue_id=start_ue, end_ue do
	    local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
		        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
				sleep(0.5)
			end
			if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and dl_rate_bps > 0 then
			    if not dl_packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue)
				else
				    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue..' size='..dl_packetsize)
				end
			end
			if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and ul_rate_bps > 0 then
			    if not ul_packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue)
				else
				    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue..' size='..ul_packetsize)
				end
			end
		end
	end
end    

function sgnb_release_detach_complete_call(start_ue, end_ue, brid)
    local func_name = "sgnb_release_detach_complete_call"
    local result = {}
    local err = {}
    local ue_ = {}

    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' id='..brid)
		sleep(0.3)
		print('Triggering sgNB release for UE='..ue_id)
        exec('enb_ue_dc_release ue='..ue_id..' bearer='..brid..' by=enb cause=off')
	    sleep(0.3)
		print('Triggering LTE detach for UE='..ue_id)
		detach(func_name, ue_id, err, result)
	end
	print("Multi-UE SgNB Release and detach for all UEs successful")
end

function attach_detach_complete_call(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, callholdingtimer, iterations)
    local num_ues =  end_ue - start_ue + 1
    local ul_rate_bps = num_ues * 1000
	local dl_rate_bps = 0
	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
        attach_with_complete_call(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps)
		sleep(callholdingtimer)
		sgnb_release_detach_complete_call(start_ue, end_ue, bearer_id)
	end
end

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function state_transitions(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, inacttimer, iterations)
    local prof_id = 1
    lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
	    sgnb_addition_with_minimal_data(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
		sleep(inacttimer)
	end
	sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
end

function sgnb_addition_with_minimal_data_single_ue(ue_id, bearer_id, target_gnb, target_gnb_cell)
    exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
	sleep(0.7)
end

function sgnb_addition_with_minimal_data(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
    for ue_id=start_ue, end_ue do
	    sgnb_addition_with_minimal_data_single_ue(ue_id, bearer_id, target_gnb, target_gnb_cell)
	end
end

function attach_detach_with_state_transition(state_trans_start_ue, state_trans_end_ue, att_det_start_ue, att_det_end_ue, bearer_id, target_gnb, target_gnb_cell, iterations)
    local num_ues =  att_det_end_ue - att_det_start_ue + 1
    local ul_rate_bps = num_ues * 1000
	local dl_rate_bps = 0
    local prof_id = 1
	print('Iteration 1 is started')
	lte_attach_with_profile_multi_ue_with_range(state_trans_start_ue, state_trans_end_ue, prof_id)
	sgnb_addition_with_minimal_data(state_trans_start_ue, state_trans_end_ue, bearer_id, target_gnb, target_gnb_cell)
  	attach_with_complete_call(att_det_start_ue, att_det_end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps)
	for iter=2, iterations do
	    sgnb_release_detach_complete_call(att_det_start_ue, att_det_end_ue, bearer_id)
	    sgnb_addition_with_minimal_data(state_trans_start_ue, state_trans_end_ue, bearer_id, target_gnb, target_gnb_cell)
	    print('Iteration '..iter..' is started')
		attach_with_complete_call(att_det_start_ue, att_det_end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps)
    end
    sgnb_release_detach_complete_call(att_det_start_ue, att_det_end_ue, bearer_id)
	sgnb_release_and_detach_multi_ue_with_range(state_trans_start_ue, state_trans_end_ue, bearer_id)
end


function wait_sgnb_addition_status(ue_id, bearer_id)
    starttime = os.time()
    while(true) do
        local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
	    if br_count ~= 0 then
            if(ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2) then	    
		        return 'success'
		    end
	    end
		currenttime = os.time() - starttime
		if currenttime > 1 then
		    return 'fail'
		end
    end
end

function sgnb_addition_with_minimal_data_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
    local sgnb_flag = ''
    for ue_id=start_ue, end_ue do
	    local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
                exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
				sgnb_flag = wait_sgnb_addition_status(ue_id, bearer_id)
			end
		end
	end
end

function sgnb_addition_state_transition_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
    local sgnb_flag = ''
    for ue_id=start_ue, end_ue do
	    local ue_ = ue(ue_id)
	    if ue_.state == ue.ON then
            exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
	        sgnb_flag = wait_sgnb_addition_status(ue_id, bearer_id)
		end
	end
end

function wait_sgnb_release(ue_id, bearer_id)
    starttime = os.time()
    while(true) do
        local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		test_timer(ue_id)
	    if br_count ~= 0 then
            if(ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1) then	    
		        return 'success'
		    end
		else
		    print('ERROR_FROM_SCRIPT - There are no bearers attached with UE'..ue_id)
		    return 'fail'
	    end
		currenttime = os.time() - starttime
		if currenttime > 1 then
		    return 'fail'
		end
    end
end

function attach_with_complete_call_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps, ul_packetsize, dl_packetsize)
    local num_ues =  end_ue - start_ue + 1
    local ul_rate_bps_per_ue = round(ul_rate_bps/num_ues)
	local dl_rate_bps_per_ue = round(dl_rate_bps/num_ues)
	local prof_id = 1
	local trf_id = 1
	local sgnbadd_flag = ''
	lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
	for ue_id=start_ue, end_ue do
	    local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
		        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
				sgnbadd_flag = wait_sgnb_addition_status(ue_id, bearer_id)
			end
			if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and dl_rate_bps > 0 and sgnbadd_flag == 'success' then
			    if not dl_packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue)
				else
				    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue..' size='..dl_packetsize)
				end
			end
			if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and ul_rate_bps > 0 and sgnbadd_flag == 'success' then
			    if not ul_packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue)
				else
				    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue..' size='..ul_packetsize)
				end
			end
		end
	end
end

function sgnb_release_complete_call_without_timer(start_ue, end_ue, bearer_id)
    local ue_ = {}
	local sgnb_relflag = ''
	local pdcptype = ''
    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' id='..bearer_id)
		sleep(0.3)
		local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
		    print('PDCP value is '..pdcptype..' UE='..ue_id)
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 then
			    print('Triggering sgNB release for UE='..ue_id)
			    exec('enb_ue_dc_release ue='..ue_id..' bearer='..bearer_id..' by=enb cause=off')
				sleep(0.2)
			end
		end
    end
	print("Multi-UE SgNB Release for all UEs successful")
end

function lte_detach_multi_ue_with_range_without_timer(start_ue, end_ue)
    for ue_id=start_ue, end_ue do
	    print('Triggering LTE detach for UE='..ue_id)
        exec('ue_detach id='..ue_id)
	end
	sleep(3)
	print("Multi-UE SgNB Release and detach for all UEs successful")
    exec('sim_log_set flush')
end

function sgnb_release_detach_complete_call_without_timer(start_ue, end_ue, bearer_id)
    sgnb_release_complete_call_without_timer(start_ue, end_ue, bearer_id)
	sleep(0.5)
    lte_detach_multi_ue_with_range_without_timer(start_ue, end_ue)	
end

function attach_detach_with_state_transition_without_timer(state_trans_start_ue, state_trans_end_ue, att_det_start_ue, att_det_end_ue, bearer_id, target_gnb, target_gnb_cell, iterations)
    local num_ues =  att_det_end_ue - att_det_start_ue + 1
    local ul_rate_bps = num_ues * 1000
	local dl_rate_bps = 0
    local prof_id = 1
	print('Iteration 1 is started')
	lte_attach_with_profile_multi_ue_with_range(state_trans_start_ue, state_trans_end_ue, prof_id)
    sgnb_addition_state_transition_without_timer(state_trans_start_ue, state_trans_end_ue, bearer_id, target_gnb, target_gnb_cell)
	attach_with_complete_call_without_timer(att_det_start_ue, att_det_end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps)
	for iter=2, iterations do
	    sgnb_release_detach_complete_call_without_timer(att_det_start_ue, att_det_end_ue, bearer_id)
	    sgnb_addition_state_transition_without_timer(state_trans_start_ue, state_trans_end_ue, bearer_id, target_gnb, target_gnb_cell)
	    print('Iteration '..iter..' is started')
		attach_with_complete_call_without_timer(att_det_start_ue, att_det_end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps)
    end
	sgnb_release_detach_complete_call_without_timer(att_det_start_ue, att_det_end_ue, bearer_id)
	lte_detach_multi_ue_with_range_without_timer(state_trans_start_ue, state_trans_end_ue)	
end

function attach_detach_complete_call_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, callholdingtimer, iterations)
    local num_ues =  end_ue - start_ue + 1
    local ul_rate_bps = num_ues * 1000
	local dl_rate_bps = 0
	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
        attach_with_complete_call_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps)
		sleep(callholdingtimer)
		sgnb_release_detach_complete_call_without_timer(start_ue, end_ue, bearer_id)
	end
end

function attach_defined_ues_3cell_without_timer(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3 ,bearer_id, target_gnb, target_gnb_cell1, target_gnb_cell2, target_gnb_cell3)
    attach_defined_ues_without_timer(start_ue_cell1, end_ue_cell1, bearer_id, target_gnb, target_gnb_cell1)
    attach_defined_ues_without_timer(start_ue_cell2, end_ue_cell2, bearer_id, target_gnb, target_gnb_cell2)
    attach_defined_ues_without_timer(start_ue_cell3, end_ue_cell3, bearer_id, target_gnb, target_gnb_cell3)
end

function attach_detach_ues_3cell_without_timer(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3 ,bearer_id, target_gnb, target_gnb_cell1, target_gnb_cell2, target_gnb_cell3, timer, iterations)
    for iter=1, iterations do
	    print('Iteration '..iter..' is started')
		attach_defined_ues_3cell_without_timer(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3 ,bearer_id, target_gnb, target_gnb_cell1, target_gnb_cell2, target_gnb_cell3)
		sleep(timer)
		sgnb_release_detach_complete_call_without_timer(start_ue_cell1, end_ue_cell1, bearer_id)
		sgnb_release_detach_complete_call_without_timer(start_ue_cell2, end_ue_cell2, bearer_id)
		sgnb_release_detach_complete_call_without_timer(start_ue_cell3, end_ue_cell3, bearer_id)
	end
end

function set_precedence(start_ue, end_ue)
    local func_name = "set_precedence"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do         
        exec("bearer_add ue="..ue_id.." id=3 filter=0 precedence=0")
        sleep(0.5)
        exec("bearer_add ue="..ue_id.." id=4 filter=0 precedence=1")
        sleep(0.5)
    end    
end

function lte_attach_with_profile_for_ap_iphy(ue_id, prof_id, bearer_id, sgateway_id, plmn)
    local func_name = "lte_attach_with_profile_for_ap_iphy"
    local err = {}
    local result = {}
    exec('ue_mme_param id='..ue_id..' sgw_id='..sgateway_id..'')
	sleep(1)
    exec('ue_attach id='..ue_id..' profile='..prof_id..' selected_plmn='..plmn..'')
    sleep(1)
	exec('bearer_add ue='..ue_id..' id='..bearer_id..' filter=3 precedence=3 proto=17 filter=4 precedence=4 proto=17')
	sleep(1)
end

function lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_ue, end_ue, delay_bw_ue_attach, prof_id, bearer_id, plmn)
    local func_name = "lte_attach_with_profile_multi_ue_with_range_for_AP_iphy"
    local err = {}
    local result = {}
	if bearer_id == 2 then
	   for ue_id=start_ue, end_ue do
	       lte_attach_with_profile_for_ap_iphy(ue_id, prof_id, bearer_id, 1, plmn)
		   sleep(delay_bw_ue_attach)
	   end	   
	else 
            for ue_id=start_ue, end_ue do
			   if ue_id >= 1 and ue_id <= 20 then 
                  lte_attach_with_profile_for_ap_iphy(ue_id, prof_id, bearer_id, ue_id, plmn)
                  sleep(delay_bw_ue_attach) 
			   end 
		       if ue_id >= 21 and ue_id <= 40 then 
                  sgateway_id = ue_id - 20
                  lte_attach_with_profile_for_ap_iphy(ue_id, prof_id, bearer_id, sgateway_id, plmn)
                  sleep(delay_bw_ue_attach) 
			   end
		       if ue_id >= 41 and ue_id <= end_ue then
                    lte_attach_with_profile_for_ap_iphy(ue_id, prof_id, bearer_id, 1, plmn)
                    sleep(delay_bw_ue_attach)
			   end
	        end
	end
    print('...Attach is completed successfully...')
    exec('sim_log_set flush')
end

function fiveG_attach_for_ap_iphy(ue_id)
    local func_name = "fiveG_attach_for_ap_iphy"
    local err = {}
    local result = {}
    exec('ue_measurement_send id='..ue_id..' phycell_id=50 nrsrp=127 event=B1_NR')   
    sleep(1)
end

function fiveG_attach_multi_ue_with_range_for_AP_iphy(start_ue, end_ue, delay_bw_ue_attach)
    local func_name = "fiveG_attach_multi_ue_with_range_for_AP_iphy"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        fiveG_attach_for_ap_iphy(ue_id)
        sleep(delay_bw_ue_attach)		
    end
    print('5G Attach is completed successfully')
    exec('sim_log_set flush')
end

function setting_percentage_in_ap_iphy(start_ue, end_ue, brid, ul_percent)
        for ue_id=start_ue, end_ue do
		    exec('bearer_ue_param ue='..ue_id..' id='..brid..' scg_ul_dist_percent='..ul_percent..'')
			sleep(1)   
        end
        print('Traffic distribution is set...')
        exec('sim_log_set flush')
end

function lte_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_operator(start_op1ue, end_op1ue, start_op2ue, end_op2ue, start_op3ue, end_op3ue, start_op4ue, end_op4ue, start_op5ue, end_op5ue, start_op6ue, end_op6ue, delay_bw_ue_attach, prof_id, bearer_id, plmn1, plmn2, plmn3, plmn4, plmn5, plmn6, UE_TYPE)
    local func_name = "lte_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_opearator"
    local err = {}
    local result = {}
	lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_op1ue, end_op1ue , delay_bw_ue_attach, prof_id, bearer_id, plmn1)
	sleep(1)
	lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_op2ue, end_op2ue , delay_bw_ue_attach, prof_id, bearer_id, plmn2)
	sleep(1)
	lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_op3ue, end_op3ue , delay_bw_ue_attach, prof_id, bearer_id, plmn3)
	sleep(1)
	lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_op4ue, end_op4ue , delay_bw_ue_attach, prof_id, bearer_id, plmn4)
	sleep(1)
	lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_op5ue, end_op5ue , delay_bw_ue_attach, prof_id, bearer_id, plmn5)
	sleep(1)
	lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(start_op6ue, end_op6ue , delay_bw_ue_attach, prof_id, bearer_id, plmn6)
    sleep(1)
    print(UE_TYPE..' UE Attach is completed for 6 operators')
    exec('sim_log_set flush')
end

function fiveG_attach_multi_ue_with_range_for_AP_iphy_for_six_operator(start_op1ue, end_op1ue, start_op2ue, end_op2ue, start_op3ue, end_op3ue, start_op4ue, end_op4ue, start_op5ue, end_op5ue, start_op6ue, end_op6ue, delay_bw_ue_attach)
    local func_name = "fiveG_attach_multi_ue_with_range_for_AP_iphy_for_six_operator"
    local err = {}
    local result = {}
    fiveG_attach_multi_ue_with_range_for_AP_iphy(start_op1ue, end_op1ue, delay_bw_ue_attach)
	sleep(1)
	fiveG_attach_multi_ue_with_range_for_AP_iphy(start_op2ue, end_op2ue, delay_bw_ue_attach)
	sleep(1)
	fiveG_attach_multi_ue_with_range_for_AP_iphy(start_op3ue, end_op3ue, delay_bw_ue_attach)
	sleep(1)
	fiveG_attach_multi_ue_with_range_for_AP_iphy(start_op4ue, end_op4ue, delay_bw_ue_attach)
	sleep(1)
	fiveG_attach_multi_ue_with_range_for_AP_iphy(start_op5ue, end_op5ue, delay_bw_ue_attach)
	sleep(1)
	fiveG_attach_multi_ue_with_range_for_AP_iphy(start_op6ue, end_op6ue, delay_bw_ue_attach)
end



