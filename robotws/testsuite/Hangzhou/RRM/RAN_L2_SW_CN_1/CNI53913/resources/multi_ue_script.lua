-- Copyright (c) 2019 Nokia. All rights reserved.

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'

function lte_attach_multi_ue(num_ues)
    local ue_list = fill_ue_list(1, num_ues)
    ue_fast_attach(ue_list)
end

function lte_attach_multi_ue_with_range(start_ue, end_ue)
    local ue_list = fill_ue_list_range(start_ue, end_ue)
    ue_fast_attach(ue_list)
end

function fill_ue_list_range(start_ue_id, finish_ue_id)
    local ue_list = {}
    for i=start_ue_id, finish_ue_id do
        ue_list[i] = i
    end
    return ue_list
end

function lte_attach_with_profile_multi_ue(num_ues, prof_id)
    for ue_id=1, num_ues do
        exec('ue_attach id='..ue_id..' profile='..prof_id)
        sleep(1)
    end
end

function lte_attach_with_profile_multi_ue_with_range(start_ue, end_ue, prof_id)
    for ue_id=start_ue, end_ue do
        exec('ue_attach id='..ue_id)
        sleep(1)
    end
end

function sgnb_addition_with_range(func_name, err, ue_id, nr_bid, target_gnb, target_gnb_cell)
    printStep(func_name .. ": SgNB Addition with SCG Split Bearer")
    local ue_
    ue_ = ue(ue_id)
    if ue_.state == ue.ON then	
        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..nr_bid..' type=split_scg')
    end
    sleep(1)
end

function lte_detach_multi_ue(num_ues)
    local func_name = "lte_detach_multi_ue"
    local result = {}
    local err = {}
    for ue_id=1, num_ues do
         detach(func_name, ue_id, err, result)
    end
    print("All the UEs are detached successfully")
end

function lte_detach_multi_ue_with_range(start_ue, end_ue)
    local func_name = "lte_detach_multi_ue"
    local result = {}
    local err = {}
    for ue_id=start_ue, end_ue do
         detach(func_name, ue_id, err, result)
    end
    print('UEs '..start_ue..'to '..end_ue..' are detached successfully')
end

function lte_attach_detach_multi_ue(num_ues, time_out)
    lte_attach_multi_ue(num_ues)
	print("multi UE's attached and waiting for timeout=", time_out)
	sleep(time_out)
	print("timeout expired", time_out)
	lte_detach_multi_ue(num_ues)
end

function sgnb_addition_multi_ue_with_range(start_ue, end_ue, bearer_id, target_gnb, target_gnb_cell)
    local func_name = "sgnb_addition_multi_ue"
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

    for ue_id=1, num_ues do
        ue_ = ue(tonumber(ue_id))
		local pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
	    if (ue_.state == ue.ON and pdcptype == 2) then
		    sgnb_release(func_name, err, ue_, ue_id, bearer_id)
		end
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end
        detach(func_name, ue_id, err, result)
    end
    print("Multi-UE SgNB Release is successful")
end

function sgnb_release_multi_ue_with_range(start_ue, end_ue, bearer_id)
    local ue_ = {}

    for ue_id=start_ue, end_ue do
        ue_ = ue(tonumber(ue_id))
		local pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
	    if (ue_.state == ue.ON and pdcptype == 2) then   
            exec('enb_ue_dc_release ue='..ue_id..' bearer='..bearer_id..' by=enb cause=off')
			sleep(0.7)
		end
    end
    print("Multi-UE SgNB Release is successful")
end

function sgnb_release_and_detach_multi_ue_with_range(start_ue, end_ue, bearer_id)
    local func_name = "sgnb_release_and_detach_multi_ue_with_range"
    local result = {}
    local err = {}
    local ue_ = {}

    for ue_id=start_ue, end_ue do
        ue_ = ue(tonumber(ue_id))
		local pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
	    
		if ue_.state == ue.IDLE then
		    print("UE "..ue_id.."is already in IDLE state")
		else
            if (ue_.state == ue.ON and pdcptype == 2) then
		        exec('enb_ue_dc_release ue='..ue_id..' bearer='..bearer_id..' by=enb cause=off')
			    sleep(0.7)
		    end
			detach(func_name, ue_id, err, result)
		end
	end
	print("Multi-UE SgNB Release is successful")
end

function multi_ue_attach_then_traffic(num_ues, bearer_id, target_gnb,
    target_gnb_cell, ul_trf_tput, ul_trf_bytes, dl_trf_tput, dl_trf_bytes)

    local func_name = "multi_ue_attach_then_traffic"
    local nr_bid = nil
    local ul_traffic_params = create_traffic_rate_and_bytes(ul_trf_tput, ul_trf_bytes)
    local dl_traffic_params = create_traffic_rate_and_bytes(dl_trf_tput, dl_trf_bytes)

    lte_attach_multi_ue(num_ues)

    for ue_id=1, num_ues do
        local err = {}
        local result = {}

        sgnb_addition(func_name, err, ue(tonumber(ue_id)), ue_id, bearer_id, target_gnb, target_gnb_cell)
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end

        printStep(func_name .. ": UE"..ue_id.." Run internal ul and dl traffic")
        result, err = start_dl_ul_traffic(ue(tonumber(ue_id)):bearer(bearer_id), dl_traffic_params, ul_traffic_params)
        if (result == false) then
            error(err[g_StepNum], 0)
        end
    end
    print("Multi-UE Attach and Traffic is successful")
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

function create_traffic_rate_and_bytes(rate_, bytes_)
    traffic_params = create_traffic_by_rate(traffic.UDP, rate_)
    traffic_params:limit(traffic.LIMIT_BYTES, bytes_)
    return traffic_params
end

function start_ul_dl_traffic_multi_ue(num_ues, bearer_id, ul_trf_tput, ul_trf_bytes, dl_trf_tput, dl_trf_bytes)
    local func_name = "start_ul_dl_traffic_multi_ue"
    local result, err = {}
    local ul_traffic_params = create_traffic_rate_and_bytes(ul_trf_tput, ul_trf_bytes)
    local dl_traffic_params = create_traffic_rate_and_bytes(dl_trf_tput, dl_trf_bytes)

    for ue_id=1, num_ues do
        printStep(func_name .. ": UE"..ue_id.." Run internal ul and dl traffic")
        result, err = start_dl_ul_traffic(ue(tonumber(ue_id)):bearer(bearer_id), dl_traffic_params, ul_traffic_params)
        if (result == false) then
            error(err[g_StepNum], 0)
        end
    end
    print("Multi-UE UL and DL Traffic has started.")
end

function check_ul_dl_traffic_multi_ue(num_ues, bearer_id, ul_trf_bytes, dl_trf_bytes, delay)
    local func_name = "check_ul_dl_traffic_multi_ue"
    local ul_result = {}
    local dl_result = {}
    local err = {}
    local passed = 0

    for ue_id=1, num_ues do
        printStep(func_name .. ": UE"..ue_id.." Check internal ul and dl traffic")
        local ue_ = ue(tonumber(ue_id))
        local bearer_ = ue_:bearer(bearer_id)
        check_traffic_going_through_cell_group(ul_result, err, ue_, bearer_, "UL", bearer.SCG, ul_trf_bytes, delay)
        check_traffic_going_through_cell_group(dl_result, err, ue_, bearer_, "DL", bearer.SCG, dl_trf_bytes, delay)
        if (ul_result[ue_id] ~= nil and dl_result[ue_id] ~= nil) then
            passed = passed + 1
        elseif (err[g_StepNum] ~= nil) then
            break
        end
    end

    if (passed == num_ues) then
        print("Multi-UE UL and DL Traffic is successful.")
    end
end

function check_traffic_going_through_cell_group(result, err, ue_, bearer_, dir, cell_group, target_trf_bytes, delay)
    local cell_group_ = cell_group or bearer.ALL
    local previous_bytes = nil
    local current_bytes = nil
    local total_bytes_sent = nil

    if dir == "UL" then
        previous_bytes = bearer_:get_l3_bearer_stats(bearer.UL, cell_group_).bytes_sent
        sleep(delay)
        current_bytes = bearer_:get_l3_bearer_stats(bearer.UL, cell_group_).bytes_sent
        total_bytes_sent = bearer_:get_l3_bearer_stats(bearer.UL, bearer.ALL).bytes_sent
    else
        previous_bytes = bearer_:get_l3_bearer_stats(bearer.DL, cell_group_).bytes_recv
        sleep(delay)
        current_bytes = bearer_:get_l3_bearer_stats(bearer.DL, cell_group_).bytes_recv
        total_bytes_sent = bearer_:get_l3_bearer_stats(bearer.DL, bearer.ALL).bytes_sent
    end

    print("UE"..ue_.id.." "..dir.." : Prev.("..previous_bytes.." B) Cur.("..current_bytes.. " B) | Total Sent("..total_bytes_sent.." B)")

    if previous_bytes == current_bytes then
        if total_bytes_sent == target_trf_bytes then
            result[ue_.id] = "UE"..ue_.id..": "..dir.." Traffic is finished."
            print(result[ue_.id])
        else
            err[g_StepNum] = "UE"..ue_.id..": "..dir.." Traffic is failed."
            print_err(err[g_StepNum])
        end
    end
end

function check_ul_dl_traffic_packet_lost_multi_ue(num_ues, bearer_id, ul_trf_pass_rate, dl_trf_pass_rate)
    local func_name = "check_for_packet_lost_multi_ue"

    for ue_id=1, num_ues do
        printStep(func_name .. ": UE"..ue_id.." Check ul and dl packet lost")
        local ue_ = ue(tonumber(ue_id))
        local bearer_ = ue_:bearer(bearer_id)
        check_for_packet_lost(ue_, bearer_, "UL", ul_trf_pass_rate)
        check_for_packet_lost(ue_, bearer_, "DL", dl_trf_pass_rate)
    end

    print_info("Traffic Packet Losts checking is done.")
end

function check_for_packet_lost(ue_, bearer_, dir, trf_pass_rate)
    local current_bytes = nil
    local total_packets_losts = nil
    local result = nil

    if dir == "UL" then
        bearer_l3_stats_ = bearer_:get_l3_bearer_stats(bearer.UL)
    else
        bearer_l3_stats_ = bearer_:get_l3_bearer_stats(bearer.DL)
    end

    result = bearer_l3_stats_.received / bearer_l3_stats_.sent * 100
    if (result >= trf_pass_rate) then
        print("UE"..ue_.id..": "..dir.." Traffic Packet Integrity is PASSED "..string.format("%.2f", result).."%")
    else
        print("UE"..ue_.id..": "..dir.." Traffic Packet Integrity is FAILED "..string.format("%.2f", result).."%")
    end
    print("Total Packets Sent: "..bearer_l3_stats_.sent)
    print("Total Packets Lost: "..bearer_l3_stats_.lost)
end

function start_dl_traffic_multi_ue(num_ues, bearer_id, dl_trf_tput, dl_trf_bytes)
    local func_name = "start_dl_traffic_multi_ue"
    local result, err = {}
    local dl_traffic_params = create_traffic_rate_and_bytes(dl_trf_tput, dl_trf_bytes)
    
    for ue_id=1, num_ues do
        printStep(func_name .. ": UE"..ue_id.." Run internal dl traffic")
        result, err = start_dl_traffic(ue(tonumber(ue_id)):bearer(bearer_id), dl_traffic_params)
        if (result == false) then
            error(err[g_StepNum], 0)
        end
    end
    print("Multi-UE DL Traffic has started.")
end

function start_dl_traffic(bearer_, traffic_dl_)
    local tmp_result_ul, tmp_err_ul, result, err
    result, err = data_start(bearer_, traffic_dl_, bearer.DL);
    return result, err
end

function start_traffic_kbps(num_ues, brid, dir, trf_id, kbpsrate)
    for ue_id=1, num_ues do
        exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate)
    end
end

function start_traffic_kbps_with_range(start_ue, end_ue, brid, dir, trf_id, kbpsrate)
    for ue_id=start_ue, end_ue do
        exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' kbps='..kbpsrate)
    end
end

function stop_traffic(start_ue, end_ue, brid, dir)
    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' id='..brid..' dir='..dir)
    end
end
	    
function run_traffic_with_5g_attach(num_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate)
	local brid = 2
	for ue_id=1, num_ues do
        exec('ue_attach id='..ue_id..' profile=1')
	end
	sleep(20)
	for ue_id=1, num_ues do
        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
	end
	sleep(60)
	run_traffic_only(num_ues, brid, dir, ul_bpsrate, dl_bpsrate)
end

function run_traffic_only(num_ues, brid, dir, ul_bpsrate, dl_bpsrate)
    local trf_id = 0
	for ue_id=1, num_ues do
	    local ul_bpsrate_temp = ul_bpsrate
		local dl_bpsrate_temp = dl_bpsrate
	    trf_id = 1
		while ((ul_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "ul"))))) do
			if (ul_bpsrate_temp >= 175000000) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000')
			elseif (ul_bpsrate_temp > 0) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp)
			end
			ul_bpsrate_temp = ul_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 175000000) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000')
			elseif (dl_bpsrate_temp > 0) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp)
			end
			dl_bpsrate_temp = dl_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
    end
end

function run_traffic_only_with_range(start_ue, end_ue, brid, dir, ul_bpsrate, dl_bpsrate)
    local trf_id = 0
	for ue_id=start_ue, end_ue do
	    local ul_bpsrate_temp = ul_bpsrate
		local dl_bpsrate_temp = dl_bpsrate
	    trf_id = 1
		while ((ul_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "ul"))))) do
			if (ul_bpsrate_temp >= 175000000) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000')
			elseif (ul_bpsrate_temp > 0) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp)
			end
			ul_bpsrate_temp = ul_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 175000000) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000')
			elseif (dl_bpsrate_temp > 0) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp)
			end
			dl_bpsrate_temp = dl_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
    end
end

function run_traffic_only_with_params(start_ue, end_ue, brid, dir, ul_bpsrate, dl_bpsrate, packetsize)
    local trf_id = 0
	for ue_id=start_ue, end_ue do
	    local ul_bpsrate_temp = ul_bpsrate
		local dl_bpsrate_temp = dl_bpsrate
	    trf_id = 1
		while ((ul_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "ul"))))) do
			if (ul_bpsrate_temp >= 175000000) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps=175000000 size='..packetsize)
			elseif (ul_bpsrate_temp > 0) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=ul trf_id='..trf_id..' bps='..ul_bpsrate_temp..' size='..packetsize)
			end
			ul_bpsrate_temp = ul_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
		trf_id = 1
		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
			if (dl_bpsrate_temp >= 175000000) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps=175000000 size='..packetsize)
			elseif (dl_bpsrate_temp > 0) then
			    exec('trf_data_start ue='..ue_id..' id='..brid..' dir=dl trf_id='..trf_id..' bps='..dl_bpsrate_temp..' size='.. packetsize)
			end
			dl_bpsrate_temp = dl_bpsrate_temp-175000000
			trf_id = trf_id + 1
		end
    end
end

function run_traffic_for_partial_ues_with_5g_attach(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate)
    local brid = 2
	for ue_id=1, num_ues do
        exec('ue_attach id='..ue_id..' profile=1')
		sleep(1)
		exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_gnb_cell..' bearer='..bearer_id..' type=split_scg')
		sleep(1)
	end
	sleep(20)
	run_traffic_only(traffic_ues, brid, dir, ul_bpsrate, dl_bpsrate)
end

function attach_defined_ues(start_ue, end_ue, brid, target_gnb, target_gnb_cell)
    local prof_id = 1
	lte_attach_5g_attach(start_ue, end_ue, prof_id, target_gnb, target_gnb_cell, brid)
end

function run_traffic_and_detach_defined_ues(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate, start_release_ue, end_release_ue, timer, iterations)
    run_traffic_for_partial_ues_with_5g_attach(num_ues, traffic_ues, bearer_id, target_gnb, target_gnb_cell, dir, ul_bpsrate, dl_bpsrate)
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
 	for ue_id=start_ue, end_ue do
	    exec('ue_attach id='..ue_id..' profile=1')
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
	run_traffic_only_with_params(g4_start_ue, g4_end_ue, bearer_id, g4_traffic_dir, g4_ulrate, g4_dlrate, g4_packsize)
    
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
			run_traffic_only_with_params(g4_start_ue, g4_end_ue, bearer_id, g4_traffic_dir, g4_ulrate, g4_dlrate, g4_packsize)
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
    for ue_id=start_ue, end_ue do
	    exec('ue_attach id='..ue_id..' profile='..prof_id)
		sleep(1)
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
	sleep(0.5)
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

    ue_ = ue(tonumber(ue_id))
	local pdcptype = ue_:bearer(bearer_id):get_info(initiator.ENB).pdcp_type
	if (ue_.state == ue.ON and pdcptype == 2) then
	    sgnb_release(func_name, err, ue_, ue_id, bearer_id)
	end
    if (err[g_StepNum] ~= nil) then
        error(err[g_StepNum], 0)
    end
    exec('ue_detach id='..ue_id)
    print('SgNB Release and Detach is successful for UE='..ue_id)
end	

function attach_detach_concurrent(start_ue, end_ue, callholdingtime, overallduration_mins, target_gnb, target_cell, bearer_id)
    local starttime_ueid = {}
	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
    for ue_id=start_ue, end_ue do
	    exec('ue_attach id='..ue_id..' profile=1')
	end
	sleep(1)
	for ue_id=start_ue, end_ue do
	    local ue_
        ue_ = ue(ue_id)
	    if ue_.state == ue.ON then
	        exec('ue_dc_enb_start ue='..ue_id..' target_gnb='..target_gnb..' target_cells='..target_cell..' bearer='..bearer_id..' type=split_scg')
			sleep(1)
		end
		sleep(0.1)
		starttime_ueid[ue_id] = os.time()
	end
	starttime_overall = os.time()
	while(endtime_overall < overallduration_seconds) do
	    for ue_id=start_ue, end_ue do
	        starttime_ueid[ue_id] = monitor_start_attach_detach(ue_id, starttime_ueid[ue_id], callholdingtime, target_gnb, target_cell, bearer_id)
		end
	    endtime_overall = os.time() - starttime_overall
	end
	lte_detach_multi_ue_with_range(start_ue, end_ue)
end

function monitor_start_attach_detach(ue_id, starttime, callholdingtime, target_gnb, target_cell, bearer_id)
    timediff = os.time() - starttime
	local restarttime = 0
	local ue_
    ue_ = ue(ue_id)
	if (timediff > callholdingtime) then
	    if ue_.state == ue.ON then
	        sgnb_release_detach_single_UE(ue_id, bearer_id)
		end
   		if ue_.state == ue.OFF then
		    exec('ue_attach id='..ue_id..' profile=1')
		end
		sleep(0.1)
		if ue_.state == ue.ON then
		    exec('ue_dc_enb_start ue='..ue_id..' target_gnb='.. target_gnb..'target_cells='..target_cell..' bearer='..bearer_id..' type=split_scg')
			restarttime = os.time()
			return restarttime
		else
		    return starttime
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

function start_ping_with_range(start_ue, end_ue, brid, dir, trf_id, bpsrate)
    for ue_id=start_ue, end_ue do
        exec('trf_data_start ue='..ue_id..' id='..brid..' dir='..dir..' trf_id='..trf_id..' bps='..bpsrate)
    end
end

function case005(start_ue, end_ue, num_ues, brid, dir, trf_id, kbpsrate)
    for id=1, 100 do
      start_traffic_kbps_with_range(start_ue, end_ue, brid, dir, trf_id, kbpsrate)
      sleep(5)
	    stop_traffic(start_ue, end_ue, brid, dir)
	  	sleep(5)
	end
end