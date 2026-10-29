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

function start_traffic_kbps_with_range(start_ue, end_ue, brid, dir, trf_id, kbpsrate, packetsize)
    if not packetsize then
        for ue_id=start_ue, end_ue do
            exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate)
        end
	else
	    for ue_id=start_ue, end_ue do
            exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate..' size='..packetsize)
        end
	end
end

function stop_traffic(start_ue, end_ue, brid, dir)
    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' id='..brid..' dir='..dir)
        sleep(1)
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
			if (ul_bpsrate_temp >= 160000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=160000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=160000000 size='..packetsize)
				end
			elseif (ul_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp..' size='..packetsize)
				end
			end
			ul_bpsrate_temp = ul_bpsrate_temp-160000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 160000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=160000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=160000000 size='..packetsize)
				end
			elseif (dl_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp..' size='..packetsize)
				end
			end
			dl_bpsrate_temp = dl_bpsrate_temp-160000000
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
			if (ul_bpsrate_temp >= 160000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=160000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=160000000 size='..packetsize)
				end
			elseif (ul_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp..' size='..packetsize)
				end
			end
			ul_bpsrate_temp = ul_bpsrate_temp-160000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 160000000) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=160000000')
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=160000000 size='..packetsize)
				end
			elseif (dl_bpsrate_temp > 0) then
			    if not packetsize then
			        exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp)
				else
				    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp..' size='..packetsize)
				end
			end
			dl_bpsrate_temp = dl_bpsrate_temp-160000000
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
	print('All NSA UEs are attached')
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

function handover_mue(start_ue_ho, end_ue_ho, delay_bw_ue_ho, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
	for ue_id=start_ue_ho, end_ue_ho do
	    handover(ue_id, target_phycellid, meas_id, measevent, srsrp, srsrq, nrsrp, nrsrq)
		sleep(delay_bw_ue_ho)
	end
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
	sleep(3)
    for ue_id=start_ue, end_ue do
		local ue_
		ue_ = ue(ue_id)
		if ue_.state == ue.ON then		
		    exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..brid..' type=split_scg')
            sleep(1)
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

function get_pdcp_type(ue_id, bearer_id)	
	local ue_
	local bearer_	
	local pdcp_type = 0
       ue_ = ue(ue_id)
	bearer_ = ue_:bearer(bearer_id)
	pdcp_type = bearer_:get_info(initiator.ENB).pdcp_type
	print('PDCP_TYPE returned in get_pdcp_type='..pdcp_type)
	return pdcp_type	
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
		local pdcp_type = 0
	    br_count = get_number_of_bearers(ue_)
	    if br_count ~= 0 then
			pdcp_type = get_pdcp_type(ue_id, bearer_id)
            if(pdcp_type == 2) then	    
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
    local pdcp_type = 0
	lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
	for ue_id=start_ue, end_ue do
	    local ue_ = ue(ue_id)
	    br_count = get_number_of_bearers(ue_)
		if br_count ~= 0 then
		    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
		        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
			end
			sleep(1)
			sgnbadd_flag = wait_sgnb_addition_status(ue_id, bearer_id)
            pdcp_type = get_pdcp_type(ue_id, bearer_id)
			if pdcp_type == 2 and dl_rate_bps > 0 and sgnbadd_flag == 'success' then
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
	print('All UE Traffic is started')
end

function attach_with_complete_call_without_timer_4x4(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_bps, dl_rate_bps, ul_packetsize, dl_packetsize)
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
            exec('csi_override_testmode_nr cqi_mode=fixed cqi=15 cqi_min=0 cqi_max=15 profile_id=3 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1')
            exec('ue_testmode_set_nr id='..ue_id..' testmode=csi_override action=activate profile_id=3')
            sleep(0.1)
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
    print('All UE Traffic is started')
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

function set_precedence_for_2bearer(start_ue, end_ue)
    local func_name = "set_precedence_2bearer"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do         
        exec("bearer_add ue="..ue_id.." id=3 filter=0 precedence=0")
        sleep(0.5)
        exec("bearer_add ue="..ue_id.." id=4 filter=0 precedence=1")
        sleep(0.5)
    end    
end

function set_precedence(start_ue, end_ue)
    local func_name = "set_precedence"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        exec("bearer_add ue="..ue_id.." id=3 filter=0 precedence=0")
        sleep(0.5) 
    end
end

function attach_with_2cell_with_traffic(start_ue, end_ue, bearer_id, target_gnb, ul_rate_bps, dl_rate_bps, ul_packetsize, dl_packetsize)
    local num_ues =  end_ue - start_ue + 1
    local ul_rate_bps_per_ue = ul_rate_bps
        local dl_rate_bps_per_ue = dl_rate_bps
        local prof_id = 1
        local trf_id = 1
        local sgnbadd_flag = ''
        local target_gnb_cell = 1

        for ue_id=start_ue, end_ue do
	    exec('ue_attach id='..ue_id..' profile='..prof_id)
	    sleep(1)
            local ue_ = ue(ue_id)
            br_count = get_number_of_bearers(ue_)
                if br_count ~= 0 then
                    if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 1 then
			if (ue_id % 2) == 0 then
				local target_gnb_cell = 2
				print('local target_gnb_cell ='..target_gnb_cell) 
	                        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
       	                         sgnbadd_flag = wait_sgnb_addition_status(ue_id, bearer_id)

                        		if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and sgnbadd_flag == 'success' then
				 	    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue)
				 	    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue)
                                	else
	                                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue..' size='..dl_packetsize)
	                                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue..' size='..ul_packetsize)
       		                         end
			else
                                local target_gnb_cell = 1
                                print('local target_gnb_cell ='..target_gnb_cell)
                                exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
                                 sgnbadd_flag = wait_sgnb_addition_status(ue_id, bearer_id)
                        		if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and sgnbadd_flag == 'success' then
				 	    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue)
				 	    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue)
                                	else
	                                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_rate_bps_per_ue..' size='..dl_packetsize)
	                                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_rate_bps_per_ue..' size='..ul_packetsize)
       		                         end
				end
                        end
                end
        end
end

function rrc_connect_UEs_traffic_with_5g_attach(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate, packetsize)
    local func_name = "rrc_connect_UEs_traffic_with_5g_attach"
    local prof_id = 1
    local ue_
    local trf_id = 1
    local err = {}

    exec('ue_attach id='..start_ue..'-'..end_ue..' profile='..prof_id)
    sleep(5)
    for ue_id=start_ue, end_ue do
        exec("bearer_add ue="..ue_id.." id=3 filter=0 precedence=0")
        sleep(0.5)
        ue_ = ue(ue_id)
        if ue_.state == ue.ON then
            sgnb_addition_with_range(func_name, err, ue_id, bearer_id, target_gnb, target_gnb_cell)

	    if dl_bpsrate > 0 and dir == 'dl' or dir == 'both' then
	        if not packetsize then
		    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate)
		else
		    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate..' size='..packetsize)
		end
	    end
	    if ul_bpsrate > 0 and dir == 'ul' or dir == 'both' then
	        if not packetsize then
		    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate)
		else
		    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate..' size='..packetsize)
		end
	    end
        end
    end
end

function rrc_connect_UEs_sgnb_release_detach_complete_call(start_ue, end_ue, brid1, brid2)
    local func_name = "sgnb_release_detach_complete_call"
    local result = {}
    local err = {}
    local ue_ = {}

    for ue_id=start_ue, end_ue do
            exec('trf_data_stop ue='..ue_id..' id='..brid1..'-'..brid2)
                sleep(0.3)
                print('Triggering sgNB release for UE='..ue_id)
        exec('enb_ue_dc_release ue='..ue_id..' bearer='..brid1..' by=enb cause=off')
            sleep(0.3)
        exec('enb_ue_dc_release ue='..ue_id..' bearer='..brid2..' by=enb cause=off')
            sleep(0.3)
                print('Triggering LTE detach for UE='..ue_id)
                detach(func_name, ue_id, err, result)
        end
        print("Multi-UE SgNB Release and detach for all UEs successful")
end


function attach_start_traffic_detach_multiue_NSA(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_kbps, dl_rate_kbps, ul_packetsize, dl_packetsize, iterations)
    local func_name = "attach_start_traffic_detach_multiue_NSA"
    local err = {}
    local result = {}
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        --attach_start_traffic_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction, delay_bw_ue_attach, trf_type, packet_size, duration)
        attach_with_complete_call_without_timer(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_kbps, dl_rate_kbps, ul_packetsize, dl_packetsize)
	sleep(10)
        sgnb_release_detach_complete_call_without_timer(start_ue, end_ue, bearer_id)
        --sleep(delay_bw_ue_attach)
    end
    print('Script execution is finished')
end

function attach_ueto_testmode_profile(start_ue, end_ue, prof_id, number_of_cells)
    local func_name = "attach_ueto_testmode_profile"
    local err = {}
    local result = {}
    local last_cell_id = number_of_cells - 1
    for ue_id=start_ue, end_ue do
        exec('ue_testmode_set_nr id='..ue_id..' testmode=beam_control action=activate profile_id='..prof_id..' beamaction=attach scell=0-'..last_cell_id..'')
    end
end

function check_SIBs(start_cell, end_cell)
    local log_file_handle
    local log_file_name = "egate_console.log"
    local current_pattern = nil
    local pattern_found = false
    local expected_patterns = {}
    local remaining_cells = {}

    for cell_id=start_cell, end_cell do
        table.insert(remaining_cells, cell_id)
    end

    exec("set_log flush")
    log_file_handle = io.open(log_file_name, "r")
    local cell_index = 1
    while cell_index <= #remaining_cells do
        local cell_id = remaining_cells[cell_index]
        table.remove(expected_patterns)
        local pattern="eNB 2 cell "..cell_id..": SystemInformationBlockType"
        table.insert(expected_patterns, pattern)

        for _, pattern in ipairs(expected_patterns) do
            log_file_handle:seek("set")
            pattern_found = false
            current_pattern = pattern

            for line in log_file_handle:lines() do
                local i, j = string.find(line, pattern)
                if i then
                    pattern_found = true;
                    print("eNB 2 cell "..cell_id..": SIB Found")
                    table.remove(remaining_cells, cell_index)
                    do break end
                end
            end
            if pattern_found == false then
                cell_index = cell_index + 1
            end
        end
    end
    for _, cell_id in ipairs(remaining_cells) do
        local err="eNB 2 cell "..cell_id..": SIB NOT Received"
        print(err)
        exec("set_log flush")
    end
    io.close(log_file_handle)
print('SIB Check Script Completed')
end

function ue_register(func_name, ue_id, trf_type, err, result)
    local timeout_ = 2
    local pdu_id = 1
    local ue_ = ue(tonumber(ue_id))
    if (ue_ == nil) then
        result[g_StepNum],err[g_StepNum] =  "UE is NIL!"
        return
    end

    printStep(func_name .. ": Start UE Register")
    if ue_.state ~= ue.OFF then
        if ue_.state == ue.ON then
            print_warn("UE is already ACTIVE. Ignore.")
            return
        else
            result[g_StepNum], err[g_StepNum] =  "UE is not OFF or ACTIVE. Can not perform Register."
            return
        end
    else
        if trf_type == 'internal' then
            exec('set_pdu_param ue='..ue_id..' pdu='..pdu_id..' trf_type='..trf_type)
            sleep(0.05)
            exec('ue_register id='..ue_id)
        end
    end
end

function start_call(ue_id, trf_type)
    local func_name = "start_call"
    local err = {}
    local result = {}
    local pdu_id = 1

    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    for i=1, 30 do
          if ue_.state == ue.ON then 
             printStep(func_name .. ": Start PDU Session Establishment")
             exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")
             break
          else
             printStep(" UE still in Activating state")
          end
          sleep(0.1)
     end
end

function start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction, packetsize, duration)
    local ue_ = ue(tonumber(ue_id))
    print('Starting traffic for ue_id='..ue_id)
    if not packetsize and not duration then
        if direction == 'both' then
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir=dl')
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir=ul')
        else
            if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir='..direction)
            else
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir='..direction)
            end
        end
    end
    if packetsize and not duration then
       print("enter internal")
        if direction == 'both' then
            if dl_datarate_kbps > 175000 then
                dl_datarate_kbps1 = 175000
                dl_datarate_kbps2 = dl_datarate_kbps - 175000
                trf_id1 = trf_id + 1
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps1..' dir=dl')
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id1..' kbps='..dl_datarate_kbps2..' dir=dl')
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir=ul')
            else
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir=ul size='..packetsize)
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir=dl size='..packetsize)
            end
        else
            if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir='..direction..' size='..packetsize)
            else
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir='..direction..' size='..packetsize)
            end
        end
    end
    if  not packetsize and duration then
        if direction == 'both' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id1..' kbps='..dl_datarate_kbps..' dir=dl')
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir=ul')
        else
            if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir='..direction..' seconds='..duration)
            else
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir='..direction..' seconds='..duration)
            end
        end
    end
    if packetsize and duration then
        if direction == 'both' then
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir=ul seconds='..duration..' size='..packetsize)
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir=dl seconds='..duration..' size='..packetsize)
        else
            if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..ul_datarate_kbps..' dir='..direction..' seconds='..duration..' size='..packetsize)
            else
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' kbps='..dl_datarate_kbps..' dir='..direction..' seconds='..duration..' size='..packetsize)
            end
        end
    end
end

function attach_start_traffic_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction, delay_bw_ue_attach, trf_type, packet_size, duration)
    local func_name = "attach_start_traffic_multiue"
    local err = {}
    local result = {}
    print('attach and start traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for ue_id=start_ue, end_ue do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
        if not packet_size and not duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction)
        end
        if not packet_size and duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction, duration)
        end
        if packet_size and not duration then
            print("entering internal traffic")
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction, packet_size)
        end
        if packet_size and duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_kbps, dl_datarate_kbps, direction, packet_size, duration)
        end
    end
    print('All UE Traffic is started')
end

function register_multiue_with_traffic_parallel(start_ue, end_ue, num_cells, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize, Retry_IDLE_OFF_UE, srbInactivityTimerSA)
    local func_name = "register_multiue_with_traffic_parallel"
    local err = {}
    local result = {}
    local state = {}
    local start_ue_2 = start_ue
    local end_ue_2 = end_ue
    
    local end_ue = end_ue / num_cells
    local end_ue_range = start_ue + num_cells - 1
    local start_ue_range = start_ue / num_cells

    for loop_id=start_ue_range, end_ue do
        if trf_type == 'internal' then
            exec('set_pdu_param ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' trf_type='..trf_type)
            exec('ue_register id='..start_ue..'-'..end_ue_range)
        end
        multiue_pdu_session(start_ue, end_ue_range, pdu_id)
            if end_ue_range <= 800 then
            sleep (delay_bw_ue_attach - 0.5)
            elseif(end_ue_range <= 1800) then 
             sleep (delay_bw_ue_attach - 0.2)
            else 
                sleep (delay_bw_ue_attach)
            end

            if not packetsize then
                if direction == 'both' then
                    exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul')
                    exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl')
                else
                    if direction == 'ul' then
                        exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul')
                    else
                        exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl')
                    end
                end
             end
            if packetsize then
                if direction == 'both' then
                    exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul size='..packetsize)
                    exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl size='..packetsize)
                else
                    if direction == 'ul' then
                        exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul size='..packetsize)
                    else
                        exec('trf_data_start ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl size='..packetsize)
                    end
                end
             end
        sleep(0.03)
        start_ue = end_ue_range + 1
        end_ue_range = start_ue + num_cells - 1
    end
    if Retry_IDLE_OFF_UE == 'yes' then
        start_ue = end_ue_range - start_ue - num_cells + 2
        end_ue_range = end_ue * num_cells
        for i=1,srbInactivityTimerSA do
            multiue_retry_IDLE_UE_start_traffic(start_ue_2, end_ue_2, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
            sleep(1)
            multiue_retry_OFF_UE_start_traffic(start_ue_2, end_ue_2, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
            print('Completed Iteration ' ..i.. '  search of OFF and IDLE UEs and Reconnect' )
        end
        print("Finished All Iterations IDLE and OFF UE search and Reconnect")
    end
    print("Completed Loop for UEs")
end

function multiue_retry_IDLE_UE_start_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
    local func_name = "multiue_retry_IDLE_UE_start_traffic"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue  do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.IDLE  then
            print("The UE:" ..ue_.id.. " IDLE state.Doing DeReg and Reg")
            stop_call(ue_id)
            start_call(ue_id, trf_type)
            sleep(1.2)
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, packetsize)
        end
    end
end

function set_amf_to_register_multiue(start_amf, end_amf, plmn, num_ues, start_ue)
    local err = {}
    local result = {}
    local state = {}
    local amf_region_id = start_amf
    local amf_set_id = 2
    local amf_pointer = 2
    if not start_ue then
        loop_id = loop_id 
    else
        loop_id = start_ue
    end
    for loop_id=loop_id, num_ues do
        exec("ue_nr_rrc_setup_param  id="..loop_id.." registered_amf="..plmn.."|"..amf_region_id..":"..amf_set_id..":"..amf_pointer)
        if amf_region_id >= end_amf then
            amf_region_id = start_amf
            amf_set_id = 2
            amf_pointer = 2
        else
            amf_region_id = amf_region_id + 1
            amf_set_id = amf_set_id + 1
            amf_pointer = amf_pointer + 1
        end
    end
    print('AMF registeration completed')
end

function multiue_pdu_session(start_ue, end_ue_range, pdu_id)
      local func_name = "multiue_pdu_session"
      local err = {}
      local result = {}

    for ue_id=start_ue, end_ue_range do
        local ue_ = ue(tonumber(ue_id))
        for i=1, 40 do
            if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
             printStep(func_name .. ": Start PDU Session Establishment UEID:"..ue_.id)
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")    
              goto label1
            else
                printStep(" UE still in Activating state")
            end
            sleep(0.05)
        end
        ::label1::
end
end

function stop_call(ue_id)
    local func_name = "stop_call"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"

    local ue_ = ue(tonumber(ue_id))
    if ue_.state == ue.ON or ue_.state == ue.IDLE or ue_.state == ue.ACTIVE then
        exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
        sleep(0.3)
    end
end

function multiue_retry_dereg(start_ue_range, end_ue_range, delay)
    local func_name = "multiue_retry_dereg"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"
    for ue_id=start_ue_range, end_ue_range  do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state ~= ue.OFF  then
            print("The UE:"..ue_.id.." state is "..ue_.state.." .Doing DeReg")
            exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
            sleep(delay)
        end
    end
    print("Complete Deregister")
end

function set_amf_to_register_single_ue(amf, plmn, ue_id)
    local err = {}
    local result = {}
    local state = {}
    local amf_region_id = amf
    local amf_set_id = amf + 1
    local amf_pointer = amf + 1
    exec("ue_nr_rrc_setup_param  id="..ue_id.." registered_amf="..plmn.."|"..amf_region_id..":"..amf_set_id..":"..amf_pointer)
    print('AMF registeration completed')
end

function multiue_retry_OFF_UE_start_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
    local func_name = "multiue_retry_OFF_UE_start_traffic"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue  do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.OFF  then
            print("The UE:" ..ue_.id.. " OFF state.Doing Reg")
            start_call(ue_id, trf_type)
            sleep(1.2)
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, packetsize)
        end
    end
end

function attach_start_traffic_multiue_retry(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packet_size, Retry_IDLE_OFF_UE, srbInactivityTimerSA, duration)
    local func_name = "attach_start_traffic_multiue"
    local err = {}
    local result = {}
    print('attach and start traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for ue_id=start_ue, end_ue do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
        if not packet_size and not duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction)
        end
        if not packet_size and duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, duration)
        end
        if packet_size and not duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, packet_size)
        end
        if packet_size and duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, packet_size, duration)
        end
    end
    if Retry_IDLE_OFF_UE == 'yes' then
        print('Starting Search for OFF and IDLE UEs in range' ..start_ue..'-'..end_ue..  'and retry Registration if any')
        for i=1,srbInactivityTimerSA do
            multiue_retry_IDLE_UE_start_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
            sleep(1)
            multiue_retry_OFF_UE_start_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
            print('Completed Iteration ' ..i.. '  search of OFF and IDLE UEs and Reconnect' )
        end
        print("Finished All Iterations IDLE and OFF UE search and Reconnect")
    end
    print("Completed Loop for UEs")
end

function register_multiue_with_pdu_check_traffic_parallel_retry(start_ue, end_ue, num_cells, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize, Retry_IDLE_OFF_UE, srbInactivityTimerSA)
    local func_name = "register_multiue_with_pdu_check_traffic_parallel_retry"
    local err = {}
    local result = {}
    local state = {}
    local start_ue_2 = start_ue
    local end_ue_2 = end_ue
    local end_ue = end_ue / num_cells
    local end_ue_range = start_ue + num_cells - 1
    local start_ue_range = start_ue / num_cells
    local traffic_started_ctr = 0
    local traffic_started_arr = {0}
    local log_flush_sleep_period = 1.0
    
    print("Egate_console Log rotate triggered before ue loop")
    egate_console_log_rotate()
    for loop_id=start_ue_range, end_ue do
        if trf_type == 'internal' then
            exec('set_pdu_param ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' trf_type='..trf_type)
            exec('ue_register id='..start_ue..'-'..end_ue_range..' ue_nr_capabilities=UE_CAP capability_file=./capability.cfg')
        end
        multiue_pdu_session_with_pattern_grep(start_ue, end_ue_range, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, delay_bw_ue_attach)
        sleep(0.02)
        start_ue = end_ue_range + 1
        end_ue_range = start_ue + num_cells - 1
    end
    if Retry_IDLE_OFF_UE == 'yes' then
        for i=1,srbInactivityTimerSA do
            local delay_bw_ue_attach_1 = delay_bw_ue_attach + 1
            multiue_retry_IDLE_UE_start_traffic_ue_cap(start_ue_2, end_ue_2, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach_1, trf_type, packetsize)
            sleep(1)
            multiue_retry_OFF_UE_start_traffic_ue_cap(start_ue_2, end_ue_2, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach_1, trf_type, packetsize)
            print('Completed Iteration ' ..i.. ' search of OFF and IDLE UEs and Reconnect' )
        end
        print("Finished All Iterations IDLE and OFF UE search and Reconnect")
    end
    print("Completed Loop for UEs")
end

function multiue_pdu_session_with_pattern_grep(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, dir, packetsize, delay_bw_ue_attach)
    local func_name = "multiue_pdu_session_with_pattern_grep"
    local err = {}
    local result = {}

    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        for i=1, 60 do
            if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
                printStep(func_name .. ": Start PDU Session Establishment UEID:"..ue_.id)
                exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")
                goto label1
            else
                sleep(0.025)
            end
        end
        ::label1::
    end
    sleep (delay_bw_ue_attach)
    grep_for_event_pattern_for_SUE_using_log_analyses_module(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, dir, packetsize)
end

function multiue_retry_IDLE_UE_start_traffic_ue_cap(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
    local func_name = "multiue_retry_IDLE_UE_start_traffic_ue_cap"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue  do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.IDLE  then
            print("The UE:" ..ue_.id.. " IDLE state.Doing DeReg and Reg")
            stop_call(ue_id)
            start_call_ue_cap(ue_id, trf_type)
            sleep(1.2)
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, packetsize)
        end
    end
end

function multiue_retry_OFF_UE_start_traffic_ue_cap(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packetsize)
    local func_name = "multiue_retry_OFF_UE_start_traffic_ue_cap"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue  do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.OFF  then
            print("The UE:" ..ue_.id.. " OFF state.Doing Reg")
            start_call_ue_cap(ue_id, trf_type)
            sleep(1.2)
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, direction, packetsize)
        end
    end
end

function grep_for_event_pattern_for_SUE_using_log_analyses_module(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, dir, packetsize)
    local log_file_name = "egate_console.log"
    local handle_file = "test.txt"
    local pattern_found = false
    local expected_patterns = {}
    local remaining_ues = {}
    --local cmd = "grep -F UE-"..ue_id.." PDU SESSION ID-1 setup/reestablishment complete "..log_file_name.." > test.txt"
    --local cmd = "grep -F \" PDU SESSION ID-1 setup/reestablishment complete\" | cut -d ']' -f2 | cut -d ':' -f3 "..log_file_name.." > test.txt"

    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
            table.insert(remaining_ues, ue_id)
        end
    end

    exec("set_log flush")
    local grep_cmd = "grep -F \" PDU SESSION ID-1 setup/reestablishment complete\" "..log_file_name.." > test.txt"
    local handle = io.popen(grep_cmd)
    handle:close()
    local handle2 = io.open(handle_file, "r")

    for i=1,40 do
        local ue_index = 1
        while ue_index <= #remaining_ues do
            local ue_id = remaining_ues[ue_index]
            table.remove(expected_patterns)
            local pattern="UE%-"..ue_id.." PDU SESSION ID%-1 setup/reestablishment complete"
            table.insert(expected_patterns, pattern)

            for _, pattern in ipairs(expected_patterns) do
                handle2:seek("set")
                pattern_found = false
                for line in handle2:lines() do
                    local i, j = string.find(line, pattern)
                    if i then
                        pattern_found = true
                        table.remove(remaining_ues, ue_index)
                        start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate, dl_datarate, dir, packetsize)
                        do break end
                    end
                end
                if pattern_found == false then
                    ue_index = ue_index + 1
                end
            end
        end
        if #remaining_ues > 0 then
            ue_index = 1
            handle2:close()
            sleep(0.035)
            exec("set_log flush")
            handle = io.popen(grep_cmd)
            handle:close()
            handle2 = io.open(handle_file, "r")
        else
            do break end
        end
    end
    for _, ue_id in ipairs(remaining_ues) do
        local err="UE%-"..ue_id.." PDU SESSION ID Pattern NOT Found"
        print(err)
        exec("set_log flush")
    end
    io.close(handle2)

    local modres = end_ue % log_rotate_ue_limit
    if modres == 0 then
        print("Egate_console Log rotate triggered at UE-"..end_ue)
        egate_console_log_rotate()
    end
end

function egate_console_log_rotate()
    cur_time = os.date("*t")
    cur_time_str = string.format("%02d%02d%04d%02d%02d%02d",cur_time.day,cur_time.month,cur_time.year,cur_time.hour,cur_time.min,cur_time.sec)
    print("Egate_console Log rotated")
    exec("set_log flush")
    os.execute("cp egate_console.log egate_console.log."..cur_time_str)
    exec("sim_log_set log_to_file=off")
    exec("sim_log_set log_to_file=on")
end

function start_call_ue_cap(ue_id, trf_type)
    local func_name = "start_call_ue_cap"
    local err = {}
    local result = {}
    local pdu_id = 1

    local ue_ = ue(tonumber(ue_id))
    ue_register_ue_cap(func_name, ue_id, trf_type, err, result)
    for i=1, 60 do
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
             printStep(func_name .. ": Start PDU Session Establishment")
             exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")
             break
          else
             printStep(" UE still in Activating state")
          end
          sleep(0.025)
    end
end

function attach_with_complete_call_without_timer_with_tag(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell, ul_rate_kbps, dl_rate_kbps, ul_packetsize, dl_packetsize, tag)
    local num_ues =  end_ue - start_ue + 1
    local ul_rate_kbps_per_ue = round(ul_rate_kbps/num_ues)
    local dl_rate_kbps_per_ue = round(dl_rate_kbps/num_ues)
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
                sleep(1)
                sgnbadd_flag = wait_sgnb_addition_status(ue_id, bearer_id)
            end
            if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and dl_rate_kbps > 0 and sgnbadd_flag == 'success' then
                if not dl_packetsize then
                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' kbps='..dl_rate_kbps_per_ue)
                else
                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=dl trf_id='..trf_id..' kbps='..dl_rate_kbps_per_ue..' size='..dl_packetsize)
                end
            end
            if ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type == 2 and ul_rate_kbps > 0 and sgnbadd_flag == 'success' then
                if not ul_packetsize then
                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' kbps='..ul_rate_kbps_per_ue)
                else
                    exec('trf_data_start ue='..ue_id..' id='..bearer_id..' dir=ul trf_id='..trf_id..' kbps='..ul_rate_kbps_per_ue..' size='..ul_packetsize)
                end
            end
        end
    end
    print('All UE Traffic is started for ' .. tag)
end
