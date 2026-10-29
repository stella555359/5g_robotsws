-- Copyright (c) 2019 Nokia. All rights reserved.

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'
require 'ext_traffic'
require 'log_analyses'

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
function ue_register_ue_cap(func_name, ue_id, trf_type, err, result)
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
            exec('ue_register id='..ue_id..' ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg')
        end
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

function start_call_trial(ue_id, trf_type)
    local func_name = "start_call_trial"
    local err = {}
    local result = {}
	local pdu_id = 1
	
	local ue_ = ue(tonumber(ue_id))
	ue_register(func_name, ue_id, trf_type, err, result)
	sleep(2)
	
    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
               exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")
               sleep(0.4)
               --exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1")
            --sleep(0.1)
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
--    ue_register_ue_cap(func_name, ue_id, trf_type, err, result)
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

function register_withrange(ue_id, trf_type)
    local func_name = "register_withrange"
    local err = {}
    local result = {}
    local pdu_id = 1

    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    sleep(0.3)
end

function start_multiue_registrationwithrange(start_ue, end_ue, trf_type)
    local func_name = "start_multiue_registrationwithrange"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        register_withrange(ue_id, trf_type)
    end
end

function pdu_release(ue_id)
    local func_name = "pdu_release"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"
    local ue_ = ue(tonumber(ue_id))
	printStep(func_name .. ": Start PDU Session Establishment")
    if ue_.state == ue.ON or ue_.state == ue.ACTIVE then
        exec('ue_pdu_session_release ue='..ue_id..' pdu=1')
        sleep(0.5)
    else
        if ue_.state == ue.IDLE then
            exec('ue_pdu_session_release ue='..ue_id..' pdu=1 by=amf')
            sleep(0.5)
        else
            sleep(0.05)
        end
    end
end

function pdu_release_multiue_session(start_ue, end_ue)
    local func_name = "pdu_release_multiue_session"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        pdu_release(ue_id)
    end
    print('All UEs PDU session released successfully')
end

function stop_call(ue_id)
    local func_name = "stop_call"
    local err = {}
    local result = {}
	local deregister_type = "switch_off"
	
    local ue_ = ue(tonumber(ue_id))
    if ue_.state == ue.ON or ue_.state == ue.IDLE or ue_.state == ue.ACTIVE then
       	exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
	    sleep(0.2)
    end
end

function start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    local func_name = "start_multiue_call"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
	    start_call(ue_id, trf_type)
		sleep(delay_bw_ue_attach)
	end
end

function start_multiue_call_3cell(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3, delay_bw_ue_attach, trf_type)
    local func_name = "start_multiue_call_3cell"
    local err = {}
    local result = {}
    for ue_id=start_ue_cell1, end_ue_cell1 do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
    end
    for ue_id=start_ue_cell2, end_ue_cell2 do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
    end
    for ue_id=start_ue_cell3, end_ue_cell3 do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
    end
end

function stop_multiue_call(start_ue, end_ue)
    local func_name = "stop_multiue_call"
    local err = {}
    local result = {}
	local deregister_type = "switch_off"
	
	for ue_id=start_ue, end_ue do
		local ue_ = ue(tonumber(ue_id))
	    if ue_.state == ue.ON or ue_.state == ue.IDLE or ue_.state == ue.ACTIVE then
		--	exec('trf_data_stop ue='..ue_id..' pdu=1')
		--	pdu_release(ue_id)
		--else
		--	pdu_release(ue_id)
        stop_call(ue_id)
		end
	    --stop_call(ue_id)
	end
end

function attach_detach(start_ue, end_ue, delay_bw_ue_attach, timer, iterations, trf_type)
    local func_name = "attach_detach"
    local err = {}
    local result = {}
	local deregister_type = "switch_off"
	
	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
	    start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type)
	    sleep(timer)
	    stop_multiue_call(start_ue, end_ue)
	    sleep(1)
	end
end

function attach_detach_3cell(start_ue_cell1, end_ue_cell1, start_ue_cell2, end_ue_cell2, start_ue_cell3, end_ue_cell3, delay_bw_ue_attach, timer, iterations, trf_type)
    local func_name = "attach_detach_3cell"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"

    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        start_multiue_call(start_ue_cell1, end_ue_cell1, delay_bw_ue_attach, trf_type)
        start_multiue_call(start_ue_cell2, end_ue_cell2, delay_bw_ue_attach, trf_type)
        start_multiue_call(start_ue_cell3, end_ue_cell3, delay_bw_ue_attach, trf_type)
        sleep(timer)
        stop_multiue_call(start_ue_cell1, end_ue_cell1)
        sleep(0.1)
        stop_multiue_call(start_ue_cell2, end_ue_cell2)
        sleep(0.1)
        stop_multiue_call(start_ue_cell3, end_ue_cell3)
        sleep(1)
    end
end

function start_traffic_dl(client_ip, port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
    print('iperf -c '..client_ip..' -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection)
    os.execute('iperf -c '..client_ip..' -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection..' &')
	sleep(1)
    print('iperf -s -u -p '..port..' -i 1 -B '..bind_ip)
	os.execute('iperf -s -u -p '..port..' -i 1 -B '..bind_ip..' &')
	sleep(1)
end

function start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
    local ue_ = ue(tonumber(ue_id))
    if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
        print('Starting traffic for ue_id='..ue_id)
    	if not packetsize and not duration then
    	    if direction == 'both' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul')
    			exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl')
    		else
    			if direction == 'ul' then
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir='..direction)
    			else
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir='..direction)
    			end
    		end
    	end
    	if packetsize and not duration then
    	    if direction == 'both' then
    		    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul size='..packetsize)
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl size='..packetsize)
    		else
    			if direction == 'ul' then
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir='..direction..' size='..packetsize)
    			else
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir='..direction..' size='..packetsize)
    			end
    		end
    	end
    	if  not packetsize and duration then
    	    if direction == 'both' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul seconds='..duration)
    			exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl seconds='..duration)
    		else
    			if direction == 'ul' then
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir='..direction..' seconds='..duration)
    			else
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir='..direction..' seconds='..duration)
    			end
    		end
    	end
    	if packetsize and duration then
    	    if direction == 'both' then
    		    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir=ul seconds='..duration..' size='..packetsize)
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir=dl seconds='..duration..' size='..packetsize)
    		else
    			if direction == 'ul' then
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..ul_datarate..' dir='..direction..' seconds='..duration..' size='..packetsize)
    			else
    				exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' '..rate..'='..dl_datarate..' dir='..direction..' seconds='..duration..' size='..packetsize)
    			end
    		end
    	end
    end
end
function start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
    print('starting traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for id=start_ue, end_ue do
	    if not packetsize and duration then
		    start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, duration)
		end
		if packetsize and duration then
	        start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
		end
		if not packetsize and not duration then
		    start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction)
		end
		if packetsize and not duration then
			start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
		end
	end
end

function start_traffic_ul(port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, ue_id, packet_size)
    print('iperf -c 72.23.'..ue_id..'.1 -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection)
    os.execute('iperf -c 72.23.'..ue_id..'.1 -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection..' &')
	sleep(1)
    print('iperf -s -u -p '..port..' -i 1 -B '..bind_ip)
	os.execute('iperf -s -u -p '..port..' -i 1 -B '..bind_ip..' &')
	sleep(1)
end

function start_traffic_multi_ue_dl(start_ue, end_ue, starting_client_ip_octets, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
    for id=start_ue, end_ue do
	    local starting_client_ip = starting_client_ip_octets..'.'..id + 1
	    start_traffic_dl(starting_client_ip, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
		starting_port = starting_port + 1
	end
end

function start_traffic_multi_ue_ul(start_ue, end_ue, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
    for id=start_ue, end_ue do
	    start_traffic_ul(starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, id, packet_size)
		starting_port = starting_port + 1
	end
end

function stop_iperf_traffic()
    os.execute('pkill -9 iperf')
	sleep(2)
end

function attach_detach_concurrent(start_ue, end_ue, callholdingtime, overallduration_mins, do_need_traffic, trf_type)
    local starttime_ueid = {}
	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
	local delay_bw_ue_attach = 5
    for ue_id=start_ue, end_ue do
	    start_call(ue_id, trf_type)
		starttime_ueid[ue_id] = os.time()
		if do_need_traffic == 'yes' then
		    start_traffic_dl(starting_client_ip, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
		end
		sleep(delay_bw_ue_attach)
	end
	sleep(0.1)
	starttime_overall = os.time()
	while(endtime_overall < overallduration_seconds) do
	    for ue_id=start_ue, end_ue do
	        starttime_ueid[ue_id] = monitor_start_attach_detach(ue_id, starttime_ueid[ue_id], callholdingtime, do_need_traffic, trf_type)
		end
	    endtime_overall = os.time() - starttime_overall
	end
	stop_multiue_call(start_ue, end_ue)
end

function monitor_start_attach_detach(ue_id, starttime, callholdingtime, do_need_traffic, trf_type)
    timediff = os.time() - starttime
	local restarttime = 0
	if (timediff > callholdingtime) then
	    stop_call(ue_id)
		sleep(0.1)
        start_call(ue_id, trf_type)
		if do_need_traffic == 'yes' then
		    start_traffic_dl(starting_client_ip, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
		end
		restarttime = os.time()
		return restarttime
	else
	    return starttime
	end
end

function stop_internal_traffic(start_ue, end_ue, trf_id)
    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' pdu=1')
	end
end

function run_SA_external_traffic_profile1(g1_start_ue, g1_end_ue, g2_start_ue, g2_end_ue, g3_start_ue, g3_end_ue, g4_start_ue, g4_end_ue, packet_size, trf_type, overallduration_mins)
    local starttime_ueid = {}
	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
	local delay_bw_ue_attach_group = 5
	local starting_client_ip_octets = '1.2.4'
	local starting_port_dl = 7071
	local bandwidth_dl = '3M'
	local interval = 1
	local time_for_new_traffic_connection = 6600
	local bind_ip = '10.0.2.1'
	local packet_size = 1350
	local starting_port_ul = 7131
	local bandwidth_ul = '1M'
	local delay_bw_ue_attach = 5
    local iteration = 1
		
    start_multiue_call(g1_start_ue, g1_end_ue, delay_bw_ue_attach, trf_type)
	start_traffic_multi_ue_dl(g1_start_ue, g1_end_ue, starting_client_ip_octets, starting_port_dl, bandwidth_dl, interval_dl, time_for_new_traffic_connection, bind_ip, packet_size)
	
	start_multiue_call(g2_start_ue, g2_end_ue, delay_bw_ue_attach, trf_type)
	start_traffic_multi_ue_dl(g2_start_ue, g2_end_ue, starting_client_ip_octets, starting_port_dl, bandwidth_dl, interval_dl, time_for_new_traffic_connection, bind_ip, packet_size)
	start_traffic_multi_ue_ul(g2_start_ue, g2_end_ue, starting_port_ul, bandwidth_ul, interval_ul, time_for_new_traffic_connection, bind_ip, packet_size)
	
	starttime_overall = os.time()
	while(endtime_overall < overallduration_seconds) do
        print('Iteration '..iteration..' is started')
	    start_multiue_call(g3_start_ue, g3_end_ue, delay_bw_ue_attach, trf_type)
		sleep(1)
		start_multiue_call(g4_start_ue, g4_end_ue, delay_bw_ue_attach, trf_type)
		start_traffic_multi_ue_dl(g4_start_ue, g4_end_ue, starting_client_ip_octets, starting_port_dl, bandwidth_dl, interval_dl, time_for_new_traffic_connection, bind_ip, packet_size)
		sleep(1)
		start_traffic_multi_ue_ul(g4_start_ue, g4_end_ue, starting_port_ul, bandwidth_ul, interval_ul, time_for_new_traffic_connection, bind_ip, packet_size)
		sleep(1)
		stop_iperf_traffic()
		start_traffic_multi_ue_dl(g4_start_ue, g4_end_ue, starting_client_ip_octets, starting_port_dl, bandwidth_dl, interval_dl, time_for_new_traffic_connection, bind_ip, packet_size)
		start_traffic_multi_ue_dl(g2_start_ue, g2_end_ue, starting_client_ip_octets, starting_port_dl, bandwidth_dl, interval_dl, time_for_new_traffic_connection, bind_ip, packet_size)
	    start_traffic_multi_ue_ul(g2_start_ue, g2_end_ue, starting_port_ul, bandwidth_ul, interval_ul, time_for_new_traffic_connection, bind_ip, packet_size)
		stop_multiue_call(g3_start_ue, g3_end_ue)
		sleep(1)
		stop_multiue_call(g4_start_ue, g4_end_ue)
		endtime_overall = os.time() - starttime_overall
		iteration = iteration + 1
	end
end
	
function run_SA_Internal_traffic_profile1(g1_start_ue, g1_end_ue, g2_start_ue, g2_end_ue, g3_start_ue, g3_end_ue, g4_start_ue, g4_end_ue, g1_rate, g1_trf_direction, g1_ul_datarate, g1_dl_datarate, g2_rate, g2_trf_direction, g2_ul_datarate, g2_dl_datarate, g4_rate, g4_trf_direction, g4_ul_datarate, g4_dl_datarate, overallduration_mins)

	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
	local packet_size = 1350
	local delay_bw_ue_attach = 5
    local iteration = 1
	local trf_id = 1
	local g4_traffic_duration = 60
	local trf_type = 'internal'
	
    start_multiue_call(g1_start_ue, g1_end_ue, delay_bw_ue_attach, trf_type)
	start_traffic_internal_multiue(g1_start_ue, g1_end_ue, trf_id, g1_rate, g1_ul_datarate, g1_dl_datarate, g1_trf_direction, overallduration_seconds, packet_size)
	
	start_multiue_call(g2_start_ue, g2_end_ue, delay_bw_ue_attach, trf_type)
    start_traffic_internal_multiue(g2_start_ue, g2_end_ue, trf_id, g2_rate, g2_ul_datarate, g2_dl_datarate, g2_trf_direction, overallduration_seconds, packet_size)
	
	start_multiue_call(g4_start_ue, g4_end_ue, delay_bw_ue_attach, trf_type)
	
	starttime_overall = os.time()
	while(endtime_overall < overallduration_seconds) do
        print('Iteration '..iteration..' is started')
	    start_multiue_call(g3_start_ue, g3_end_ue, delay_bw_ue_attach, trf_type)
		sleep(1)
		
		start_traffic_internal_multiue(g4_start_ue, g4_end_ue, trf_id, g4_rate, g4_ul_datarate, g4_dl_datarate, g4_trf_direction, overallduration_seconds, packet_size)
        sleep(g4_traffic_duration)
		stop_internal_traffic(g4_start_ue, g4_end_ue, trf_id)
		sleep(120)
		
		stop_multiue_call(g3_start_ue, g3_end_ue)
		sleep(1)
				
		endtime_overall = os.time() - starttime_overall
		iteration = iteration + 1
	end
	stop_multiue_call(g4_start_ue, g4_end_ue)
	stop_internal_traffic(g2_start_ue, g2_end_ue, trf_id)
	sleep(1)
	stop_multiue_call(g2_start_ue, g2_end_ue)
	stop_internal_traffic(g2_start_ue, g2_end_ue, trf_id)
	sleep(1)
	stop_multiue_call(g1_start_ue, g1_end_ue)
end
   
function ue_state(ue_id)
    local ue_ = ue(ue_id)
    print('UE state is '..ue_.state)
end

function start_call_with_networkslice(ue_id, trf_type)
    local func_name = "start_call_with_networkslice"
    local err = {}
    local result = {}
    local pdu_id = 1
    local nw_sliceid = ue_id 
    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    sleep(2)

    if ue_.state ~= ue.OFF then
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice="..nw_sliceid.."") 
            sleep(1.5)
        end
    end
end

function start_multiue_call_with_networkslice(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    local func_name = "start_multiue_call_with_networkslice"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        start_call_with_networkslice(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
    end
end

function start_call_with_networkslice_2drb(ue_id, trf_type)
    local func_name = "start_call_with_networkslice_2drb"
    local err = {}
    local result = {}
    local pdu_id = 1
    local pdu_id2 = 2
    local nw_sliceid = ue_id 
    local nw_sliceid2 = ue_id + 1
    local nw_sliceid2_for_ue20 = ue_id - 1
    local ue_id20 = 20
    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    sleep(2)

    if ue_.state ~= ue.OFF then
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice="..nw_sliceid.."")
            sleep(1.5)                 
            if ue_id == ue_id20 then
               exec("ue_pdu_session_setup pdu="..pdu_id2.." ue="..ue_id.." nwslice="..nw_sliceid2_for_ue20.."")
               sleep(1.5)
            else
               exec("ue_pdu_session_setup pdu="..pdu_id2.." ue="..ue_id.." nwslice="..nw_sliceid2.."")
               sleep(1.5)
            end           
        end
    end
end

function start_multiue_call_with_networkslice_2drb(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    local func_name = "start_multiue_call_with_networkslice_2drb"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        start_call_with_networkslice_2drb(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
    end
end

function start_call_with_networkslice_2qfi(ue_id, trf_type)
    local func_name = "start_call_with_networkslice_2qfi"
    local err = {}
    local result = {}
    local pdu_id = 1
    local nw_sliceid = ue_id 
    local qfi_id = ue_id + 1
    local qfi_id_forue20 = ue_id - 1
    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    sleep(2)

    if ue_.state ~= ue.OFF then
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice="..nw_sliceid.."")
            sleep(1.5)
            if ue_id == 20 then
               exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..ue_id.."")
               sleep(1.5)
               exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..qfi_id_forue20.."")
               sleep(1.5)
            else
               exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..ue_id.."")
               sleep(1.5)
               exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..qfi_id.."")
               sleep(1.5)
            end
        end
    end
end
 
function start_multiue_call_with_networkslice_2qfi(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    local func_name = "start_multiue_call_with_networkslice_2qfi"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        start_call_with_networkslice_2qfi(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
    end
end

function start_traffic_internal_multiue_in2qfi(start_ue, end_ue, pdu_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
    print('starting traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for id=start_ue, end_ue do
        local qfi_id = id
        local qfi_id2 = id + 1
        if not packetsize and duration then
            start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, duration)
            start_traffic_internal(id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, duration)
        end
        if packetsize and not duration then
            start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
            start_traffic_internal(id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
        end
        if not packetsize and not duration then
            start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction)
            start_traffic_internal(id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction)
        end
        if packetsize and duration then
            start_traffic_internal(id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
            start_traffic_internal(id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
		end
    end
end

function associate_ue_to_beamcontrol_testmode_profile(start_ue, end_ue, prof_id, number_of_cells)
    local func_name = "associate_ue_to_beamcontrol_testmode_profile"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        exec('ue_testmode_set_nr id='..ue_id..' testmode=beam_control action=activate profile_id='..prof_id..' beamaction=attach scell=0-'..number_of_cells..'')
        sleep(1)
    end
    print('UEs associated successfully')
end

function create_beamcontrol_testmode_nr_profile(number_of_profiles)
    local func_name = "create_beamcontrol_testmode_nr_profile"
    local err = {}
    local result = {}
    if number_of_profiles == 2 then
        exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
        sleep(0.1)
        print('Beam control profiles created successfully')
    elseif number_of_profiles == 4 then
        exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5,6,7 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
        sleep(0.1)
    elseif number_of_profiles == 6 then
        exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5,6,7 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5,6,7 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4,6,7 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
        sleep(0.1)
    elseif number_of_profiles == 8 then
        exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5,6,7 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5,6,7 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4,6,7 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=6,0,1,2,3,4,5,7 ssbeam_bestbeam=6 ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-100')
        sleep(0.1)
        exec('beam_control_testmode_nr profile_id=8 ueBeamIndexInitial=7,0,1,2,3,4,5,6 ssbeam_bestbeam=7 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100')
        sleep(0.1)
        print('Beam control profiles created successfully')
    else
        print('Invalid number of beam control testmode profiles. Profiles can be 2 or 4 or 6 or 8')
    end
end

function create_csi_override_testmode_profile(prof_id)
    local func_name = "set_multi_ue_nr_csi_override_testmode"
    local err = {}
    local result = {}
	
	exec('csi_override_testmode_nr cqi_mode=fixed cqi=15 cqi_min=0 cqi_max=15 profile_id='..prof_id..' ri_mode=fixed ri=3 pmi_mode=fixed pmi=1')
	print('CSI override testmode profile created successfully')
end

function associate_ue_to_csi_override_testmode_profile(ue_id, prof_id, number_of_cells)
    local func_name = "associate_ue_to_csi_override_testmode_profile"
    local err = {}
    local result = {}
	local last_cell_id = number_of_cells - 1
	
    local ue_ = ue(tonumber(ue_id))
    if ue_.state == ue.ON or ue_.state == ue.IDLE or ue_.state == ue.ACTIVE then
	    exec('ue_testmode_set_nr id='..ue_id..' testmode=csi_override action=activate profile_id='..prof_id..' scell=0-'..last_cell_id..'')
	    sleep(1)	 
    end
	print('CSI override testmode profile associated successfully')
end

function create_associate_multi_ue_to_csi_override_testmode_profile(start_ue, end_ue, prof_id, number_of_cells)
    local func_name = "associate_multi_ue_to_csi_override_testmode_profile"
    local err = {}
    local result = {}
	
	create_csi_override_testmode_profile(prof_id)
	for ue_id=start_ue, end_ue do
	    associate_ue_to_csi_override_testmode_profile(ue_id, prof_id, number_of_cells)
	end
end

function attach_start_traffic_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packet_size, Retry_IDLE_OFF_UE, srbInactivityTimerSA, duration)
    local func_name = "attach_start_traffic_multiue"
    local err = {}
    local result = {}
    print('attach and start traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for ue_id=start_ue, end_ue do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
		if not packet_size and not duration then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction)
		end
		if not packet_size and duration then
			start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, duration)
		end
		if packet_size and not duration then
			start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packet_size)
		end
		if packet_size and duration then
			start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packet_size, duration)
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
end

function attach_start_traffic_detach_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, iterations, packet_size, duration)
    local func_name = "attach_start_traffic_detach_multiue"
    local err = {}
    local result = {}
    local Retry_IDLE_OFF_UE = no
	local srbInactivityTimerSA = 0
	
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
		attach_start_traffic_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, packet_size, Retry_IDLE_OFF_UE, srbInactivityTimerSA, duration)
        sleep(10)
        stop_multiue_call(start_ue, end_ue)
        sleep(delay_bw_ue_attach)
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

function sa_handover(ue_id, meas_id, event, phycell_id, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr)
    local func_name = "sa_handover"
    local err = {}
    local result = {}
    local event = "A3"
    local ue_ = ue(tonumber(ue_id))
    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Initiating Handover for UE")
            exec("ue_measurement_send_nr id="..ue_id.." meas_id="..meas_id.." event="..event.." srsrp_nr="..srsrp_nr.." srsrq_nr="..srsrq_nr.." phycell_id="..phycell_id.." nrsrp_nr="..nrsrp_nr.." nrsrq_nr="..nrsrq_nr.."")
        end
    end
end

function start_multiue_sa_handover(start_ue, end_ue, meas_id, event, phycell_id, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr, delay_bw_ue_handover)
    local func_name = "start_multiue_sa_handover"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        sa_handover(ue_id, meas_id, event, phycell_id, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr)
        sleep(delay_bw_ue_handover)
    end
end

function addition_of_uehistory_info_sa_handover(start_ue, end_ue, plmn, gnb_id)
    local func_name = "addition_of_uehistory_info_sa_handover"
    local err = {}
    local result = {}
    local nrcgi = ""..plmn.."|0x01"
    exec("ue_history_information_list id=1 action=reset")
    sleep(0.1)
    exec("ue_history_information_list_add_ngran id=1 cell_type=large nrcgi="..nrcgi.." gnb_id="..gnb_id.." time_ue_stayed_in_cell=97")
    sleep(0.1)
    exec("ue_history_information_list id=1 action=commit")
    for ue_id=start_ue, end_ue do
        exec("ue_enb_param id="..ue_id.." ue_history_list=1")
        sleep(0.1)
    end
end

function start_multiue_sa_handover_multicell(start_ue, end_ue, meas_id, event, phycell_sid, phycell_tid, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr, delay_bw_ue_handover)
    local func_name = "start_multiue_sa_handover_multicell"
    local err = {}
    local result = {}
    local phycell_id = phycell_sid
    for ue_id=start_ue, end_ue do
        sa_handover(ue_id, meas_id, event, phycell_id, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr)
        sleep(delay_bw_ue_handover)
    	if phycell_id >= phycell_tid then
            phycell_id = phycell_sid
        else
            phycell_id = phycell_id + 1
        end
    end
end

function start_continuous_multiue_sa_intergnb_handover(start_ue, end_ue, fwd_meas_id, fwd_event, fwd_phycell_sid, fwd_phycell_tid, fwd_srsrp_nr, fwd_srsrq_nr, fwd_nrsrp_nr, fwd_nrsrq_nr, rvr_meas_id, rvr_event, plmn, gnb_id, rvr_phycell_sid, rvr_phycell_tid, rvr_srsrp_nr, rvr_srsrq_nr, rvr_nrsrp_nr, rvr_nrsrq_nr, delay_bw_ue_handover, timer, iterations)
    local func_name = "start_continuous_multiue_sa_intergnb_handover"
    local err = {}
    local result = {}
    local split_timer1 = round ( timer / 2 )
    local split_timer2 = round ( timer / 4 )
    for iter=1, iterations do
        exec("ue_disp state=ACTIVE format=long")
        sleep(0.3)
        exec("ue_disp state=IDLE format=long")
        sleep(0.2)
        print('Iteration '..iter..' is started')
        start_multiue_sa_handover_multicell(start_ue, end_ue, fwd_meas_id, fwd_event, fwd_phycell_sid, fwd_phycell_tid, fwd_srsrp_nr, fwd_srsrq_nr, fwd_nrsrp_nr, fwd_nrsrq_nr, delay_bw_ue_handover)
        sleep(0.3)
        exec("ue_disp state=ACTIVE format=long")
        sleep(0.2)
        exec("ue_disp state=IDLE format=long")
        sleep(timer - 0.5)
        addition_of_uehistory_info_sa_handover(start_ue, end_ue, plmn, gnb_id)
        start_multiue_sa_handover_multicell(start_ue, end_ue, rvr_meas_id, rvr_event, rvr_phycell_sid, rvr_phycell_tid, rvr_srsrp_nr, rvr_srsrq_nr, rvr_nrsrp_nr, rvr_nrsrq_nr, delay_bw_ue_handover)
        sleep(timer - 0.5)
    end
end

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function register_2drb_UEs_with_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, trf_type, packetsize, duration)
    local func_name = "register_2drb_UEs_with_traffic"
    local err = {}
    local result = {}
    local qfi_id2 = 2
    local delay_bw_ue_attach = 1

    start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    sleep(1.0)
    start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
            printStep(func_name .. ": Modify PDU Session Establishment with QFI-2")
            exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..qfi_id2.."")
        else
            printStep("UE still in Registering/Activating state")
        end
        sleep(1.5)
    end
    sleep(1.0)
    start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
    sleep(3)
    exec("ue_disp state=ACTIVE format=long")
    sleep(1)
    exec("ue_disp state=IDLE format=long")
end

function stop_2drb_internal_traffic_releaase_deregister(start_ue, end_ue, trf_id)
    local func_name = "stop_2drb_internal_traffic_releaase_deregister"
    local pdu_id = 1
    local pdu_id2 = 2
    local err = {}
    local result = {}
    local deregister_type = "switch_off"

    for ue_id=start_ue, end_ue do
        exec('trf_data_stop ue='..ue_id..' pdu=1 qfi=1 trf_id='..trf_id)
        exec('trf_data_stop ue='..ue_id..' pdu=1 qfi=2 trf_id='..trf_id)
    end
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.ON or ue_.state == ue.ACTIVE then
            exec('ue_pdu_session_release ue='..ue_id..' pdu=1')
        else
            if ue_.state == ue.IDLE then
            exec('ue_pdu_session_release ue='..ue_id..' pdu=1 by=amf')
            end
        end
        sleep(0.5)
    end
    for ue_id=start_ue, end_ue do
        exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
        sleep(0.5)
    end
end

function attach_detach_multiue_with_2drb_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, trf_type, iterations, packetsize, duration)
    local func_name = "attach_detach_multiue_with_2drb_traffic"
    local err = {}
    local result = {}
	
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        register_2drb_UEs_with_traffic(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, trf_type, packetsize, duration)
        sleep(delay_bw_ue_attach)
        stop_2drb_internal_traffic_releaase_deregister(start_ue, end_ue, trf_id)
    end
    print('Script execution is finished')
end

function register_2drb_beam_UEs_with_traffic(start_ue, end_ue, number_of_profiles, number_of_cells, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
    local func_name = "register_2drb_beam_UEs_with_traffic"
    local err = {}
    local result = {}
    local pdu_id = 1
	local trf_id = 1
	local qfi_id = 1
	local qfi_id2 = 2
	local prof_id = 1
	local temp_profid = prof_id
    local delay_bw_ue_attach = 0.5
	local trf_type = 'internal'

    create_beamcontrol_testmode_nr_profile(number_of_profiles)
    sleep(delay_bw_ue_attach)
    local last_cell_id = number_of_cells - 1
    for ue_id=start_ue, end_ue do
		exec('ue_testmode_set_nr id='..ue_id..' testmode=beam_control action=activate profile_id='..temp_profid..' beamaction=attach scell=0-'..last_cell_id..'')
		if temp_profid < number_of_profiles then
			temp_profid = temp_profid + 1
		else
			temp_profid = 1
		end
		sleep (delay_bw_ue_attach)
	end
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
	    start_call(ue_id, trf_type)
		sleep(delay_bw_ue_attach)
        if ue_.state == ue.ON then
            printStep(func_name .. ": Modify PDU Session Establishment with QFI-2")
            exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..qfi_id2.."")
			sleep(delay_bw_ue_attach)
--			exec('csi_override_testmode_nr cqi_mode=fixed cqi=15 cqi_min=0 cqi_max=15 profile_id=3 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1')
--			exec('ue_testmode_set_nr id='..ue_id..' testmode=csi_override action=activate profile_id=3')
--			sleep(0.1)
--			exec('ue_testmode_decode_muxphychan decode_mux_phy_chan=decode_PDSCH')
--			sleep(0.1)
			if not packetsize and duration then
				start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, duration)
				sleep(delay_bw_ue_attach)
				start_traffic_internal(ue_id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, duration)
			end
			if packetsize and duration then
				start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
				sleep(delay_bw_ue_attach)
				start_traffic_internal(ue_id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
			end
			if not packetsize and not duration then
				start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction)
				sleep(delay_bw_ue_attach)
				start_traffic_internal(ue_id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction)
			end
			if packetsize and not duration then
				start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
				sleep(delay_bw_ue_attach)
				start_traffic_internal(ue_id, pdu_id, qfi_id2, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
			end
        else
            printStep("UE still in Registering/Activating state")
        end
        sleep(delay_bw_ue_attach)
    end
    sleep(3)
    exec("ue_disp state=ACTIVE format=long")
    sleep(1)
    exec("ue_disp state=IDLE format=long")
end

function attach_detach_multiue_with_2drb_beam_traffic(start_ue, end_ue, number_of_profiles, number_of_cells, rate, ul_datarate, dl_datarate, direction, delay_bw_ue_attach, iterations, packetsize, duration)
    local func_name = "attach_detach_multiue_with_2drb_beam_traffic"
    local err = {}
    local result = {}
    local pdu_id = 1
	local trf_id = 1
	
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        register_2drb_beam_UEs_with_traffic(start_ue, end_ue, number_of_profiles, number_of_cells, rate, ul_datarate, dl_datarate, direction, packetsize, duration)
        sleep(delay_bw_ue_attach)
        stop_2drb_internal_traffic_releaase_deregister(start_ue, end_ue, trf_id)
    end
    print('Script execution is finished')
end

function Addition_Multiple_drb(start_ue, end_ue, pdu_id)
    local func_name = "Addition_Multiple_drb"
    local err = {}
    local result = {}
	local qfi_id2 = 2
	local qfi_id3 = 3
    local start_ue_range = 1
    local end_ue_range = start_ue_range + 5
    for ue_id=start_ue, end_ue do
		for ue_id1=start_ue_range, end_ue_range do
			exec("ue_pdu_session_modify ue="..ue_id1.." pdu="..pdu_id.." qosflows_to_add="..qfi_id2..","..qfi_id3.."")
			sleep(0.05)
		end
		sleep(0.5)
		start_ue_range = start_ue_range + 6
		end_ue_range = end_ue_range + 6
		if ue_id > end_ue then
			print(" ")
			break
		end
	end
end

function deletion_Multiple_drb(start_ue, end_ue, pdu_id)
    local func_name = "deletion_Multiple_drb"
    local err = {}
    local result = {}
	local qfi_id2 = 2
	local qfi_id3 = 3
    local start_ue_range = 1
    local end_ue_range = start_ue_range + 5
    for ue_id=start_ue, end_ue do
		for ue_id1=start_ue_range, end_ue_range do
			exec("ue_pdu_session_modify ue="..ue_id1.." pdu="..pdu_id.." qosflows_to_del="..qfi_id2..","..qfi_id3.."")
			sleep(0.05)
		end
		sleep(0.5)
		start_ue_range = start_ue_range + 6
		end_ue_range = end_ue_range + 6
		if ue_id > end_ue then
			print(" ")
			break
		end
	end
end

function Addition_deletion_Multiple_drb(start_ue, end_ue, pdu_id, iterations)
    local func_name = "Addition_deletion_Multiple_drb"
    local err = {}
    local result = {}
    local qfi_id2 = 2
    local qfi_id3 = 3
    local end_ue = end_ue / 6
    local start_ue_range = 1
    local end_ue_range = start_ue_range + 5
    for iter=1, iterations do
        print('Iteration '..iter..' addition is started')
        Addition_Mutilple_drb(start_ue, end_ue, pdu_id)
		sleep (0.1)
		print('Iteration '..iter..' deletion is started')
		deletion_Mutilple_drb(start_ue, end_ue, pdu_id)
		sleep (0.1)
	end
end

function stop_multiue_call_parallel(start_ue, end_ue, num_cells, pdu_id, delay)
    local func_name = "stop_multiue_call_parallel"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"
    local start_ue_2 = start_ue
    local end_ue_2 = end_ue

    local end_ue = end_ue / num_cells
    local end_ue_range = start_ue + num_cells - 1
    local start_ue_range = start_ue / num_cells
	
    for ue_id = start_ue_range, end_ue do
   	    exec("ue_deregister id="..start_ue.."-"..end_ue_range.." by=ue ue_deregister_type="..deregister_type)
        sleep(delay)
        start_ue = end_ue_range + 1
        end_ue_range = start_ue + num_cells - 1
    end
    multiue_retry_dereg(start_ue_2, end_ue_2, delay)
end

function mue_state(start_ue, end_ue)
    local state_id = 0
    local count = end_ue - start_ue

    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        for i=1, 10 do
            if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
                state_id = state_id + 1
                goto label1
            else
                printStep(" UE still in Activating state")
            end
            sleep(0.3)
        end
        ::label1::
    end
    if state_id == count then
        print('state :'..state_id)
        return ok
    else
        print('state :'..state_id)
        return notok
    end
end

function register_multiue_parallel(start_ue, end_ue, num_cells, pdu_id, trf_type, delay)
    local end_ue = end_ue / num_cells
    local end_ue_range = start_ue + num_cells - 1
    local start_ue_range = start_ue / num_cells 

    for loop_id = start_ue_range, end_ue do
        if trf_type == 'internal' then
            exec('set_pdu_param ue='..start_ue..'-'..end_ue_range..' pdu='..pdu_id..' trf_type='..trf_type)
            exec('ue_register id='..start_ue..'-'..end_ue_range..' ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg')
--            sleep(0.03)
--            exec('ue_register id='..start_ue + 3 ..'-'..end_ue_range)
            sleep(1.0)
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..start_ue.."-"..end_ue_range.." nwslice=1")
        end
        sleep(delay)
        start_ue = end_ue_range + 1
        end_ue_range = start_ue + num_cells - 1
    end
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
			exec('ue_register id='..start_ue..'-'..end_ue_range..' ue_nr_capabilities=FR1_TDD_VTM  capability_file=./capability.cfg')
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
end

function run_traffic_only_with_range(start_ue, end_ue, pdu_id, qfi_id, trf_id1, rate, ul_bpsrate, dl_bpsrate, dir, packetsize)
    local trf_id
    local ul_bpsrate_temp
	local dl_bpsrate_temp

	for ue_id=start_ue, end_ue do
		local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
	        trf_id = trf_id1
    		if ((rate == 'mbps') and (ul_bpsrate >= 0 or dl_bpsrate >= 0)) then
			    ul_bpsrate_temp = ul_bpsrate * 1000000
		    	dl_bpsrate_temp = dl_bpsrate * 1000000
	    	else
    			if ((rate == 'kbps') and (ul_bpsrate >= 0 or dl_bpsrate >= 0)) then
    				ul_bpsrate_temp = ul_bpsrate * 1000
    				dl_bpsrate_temp = dl_bpsrate * 1000
    			else
    				ul_bpsrate_temp = ul_bpsrate
    				dl_bpsrate_temp = dl_bpsrate
	    		end
    		end

    		while ((ul_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "ul"))))) do
    			if (ul_bpsrate_temp >= 160000000) then
    			    if not packetsize then
    					exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps=160000000 dir=ul')
    				else
    				    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps=160000000 dir=ul size='..packetsize)
	    			end
    			elseif (ul_bpsrate_temp > 0) then
    			    if not packetsize then
    					exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' dir=ul bps='..ul_bpsrate_temp)
    				else
    					exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..ul_bpsrate_temp..' dir=ul size='..packetsize)
    				end
    			end
	    		ul_bpsrate_temp = ul_bpsrate_temp-160000000
    			trf_id = trf_id + 1
    		end
    		trf_id = trf_id1
    		while ((dl_bpsrate_temp >= 0) and ((string.match(dir, "both") or (string.match(dir, "dl"))))) do
    			if (dl_bpsrate_temp >= 160000000) then
    			    if not packetsize then
    					exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps=160000000 dir=dl')
    				else
    				    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps=160000000 dir=dl size='..packetsize)
	    			end
    			elseif (dl_bpsrate_temp > 0) then
    			    if not packetsize then
    					exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' dir=dl bps='..dl_bpsrate_temp)
	    			else
    					exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..dl_bpsrate_temp..' dir=dl size='..packetsize)
    				end
    			end
    			dl_bpsrate_temp = dl_bpsrate_temp-160000000
    			trf_id = trf_id + 1
    		end
        end
    end
end

function attach_detach_parallel(start_ue, end_ue, num_cells, pdu_id, delay, timer, iterations, trf_type)
    local func_name = "attach_detach_parallel"
    local err = {}
    local result = {}
    local qfi_id = 1
    local trf_id = 1
    local ul_datarate = 0
    local dl_datarate = 1
    local direction = "dl"
    local packetsize = 64
	local rate = 'kbps'
    local Retry_IDLE_OFF_UE = 'no'

	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
		register_multiue_with_traffic_parallel(start_ue, end_ue, num_cells, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay, trf_type, packetsize, Retry_IDLE_OFF_UE)
	    sleep(timer)
        exec("ue_disp state=ACTIVE format=long")
        sleep(0.2)
        exec("ue_disp state=IDLE format=long")
        stop_multiue_call_parallel(start_ue, end_ue, num_cells, pdu_id, delay)
	end
end

function register_deregister_parallel(start_ue, end_ue, num_cells, pdu_id, delay, iterations, trf_type)
    local func_name = "register_deregister_parallel"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"
    local dereg_delay = 0.3

	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
        local start_ue1 = start_ue
        local end_ue1 = end_ue
        local start_ue2 = start_ue
        local end_ue2 = end_ue

        local end_ue1 = end_ue1 / num_cells
        local end_ue_range1 = start_ue1 + num_cells - 1
        local start_ue_range1 = start_ue1 / num_cells 

        local end_ue2 = end_ue2 / num_cells
        local end_ue_range2 = start_ue2 + num_cells - 1
        local start_ue_range2 = start_ue2 / num_cells 

        for loop_id1 = start_ue_range1, end_ue1 do
            if trf_type == 'internal' then
                exec('set_pdu_param ue='..start_ue1..'-'..end_ue_range1..' pdu='..pdu_id..' trf_type='..trf_type)
                exec('ue_register id='..start_ue1..'-'..end_ue_range1..' ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg')
--                exec('ue_register id='..start_ue1..'-'..end_ue_range1 - 3)
--                sleep(0.03)
--                exec('ue_register id='..start_ue1 + 3 ..'-'..end_ue_range1)
            end
            sleep(delay)
            start_ue1 = end_ue_range1 + 1
            end_ue_range1 = start_ue1 + num_cells - 1
        end

        for loop_id2 = start_ue_range2, end_ue2 do
           	exec("ue_deregister id="..start_ue2.."-"..end_ue_range2.." ue_deregister_type="..deregister_type)
            sleep(dereg_delay)
            start_ue2 = end_ue_range2 + 1
            end_ue_range2 = start_ue2 + num_cells - 1
        end
	end
end

function register_deregister_with_pdu_traffic_parallel(start_ue, end_ue, num_cells, pdu_id, delay, iterations, trf_type)
    local func_name = "register_deregister_with_pdu_traffic_parallel"
    local err = {}
    local result = {}
    local qfi_id = 1
    local trf_id = 1
    local ul_datarate = 0
    local dl_datarate = 1
    local direction = "dl"
    local packetsize = 64
    local dereg_delay = 0.3
	local rate = 'kbps'

    for iter=1, iterations do
        print('Iteration '..iter..' is started')
		register_multiue_with_traffic_parallel(start_ue, end_ue, num_cells, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, delay, trf_type, packetsize)
        stop_multiue_call_parallel(start_ue, end_ue, num_cells, pdu_id, dereg_delay)
    end
end

function set_amf_to_register_multiue(start_amf, end_amf, plmn, num_ues)
    local err = {}
    local result = {}
    local state = {}
    local amf_region_id = start_amf
    local amf_set_id = 2
    local amf_pointer = 2

    for loop_id=1, num_ues do
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
end

function set_multi_amf_to_register_multiue(start_amf, end_amf, plmn, start_ue, end_ue)
    local err = {}
    local result = {}
    local state = {}
    local amf_region_id = start_amf
    local amf_set_id = start_amf + 1
    local amf_pointer = start_amf + 1

   for loop_id=start_ue, end_ue do
        exec("ue_nr_rrc_setup_param  id="..loop_id.." registered_amf="..plmn.."|"..amf_region_id..":"..amf_set_id..":"..amf_pointer)
        if amf_region_id >= end_amf then
            amf_region_id = start_amf
            amf_set_id = start_amf + 1
            amf_pointer = start_amf + 1
        else
            amf_region_id = amf_region_id + 1
            amf_set_id = amf_set_id + 1
            amf_pointer = amf_pointer + 1
        end
    end
end

function set_multi_amf_to_register_multiue2(start_amf, end_amf, plmn, start_ue, end_ue)
    local err = {}
    local result = {}
    local state = {}
    local amf_region_id = start_amf
    local amf_set_id = start_amf + 1
    local amf_pointer = start_amf + 1

   for loop_id=start_ue, end_ue do
        exec("ue_nr_rrc_setup_param  id="..loop_id.." registered_amf="..plmn.."|"..amf_region_id..":"..amf_set_id..":"..amf_pointer.." exclude_stmsi=on s_tmsi_format=random:none:none")
        if amf_region_id >= end_amf then
            amf_region_id = start_amf
            amf_set_id = start_amf + 1
            amf_pointer = start_amf + 1
        else
            amf_region_id = amf_region_id + 1
            amf_set_id = amf_set_id + 1
            amf_pointer = amf_pointer + 1
        end
    end
end

function Paging_from_multi_amf_to_multiue(start_amf, end_amf, start_ue, end_ue)
    local err = {}
    local result = {}
    local state = {}
    local amf_paging_start_id = start_amf

    for loop_id=start_ue, end_ue do
        exec("amf_paging_start id="..amf_paging_start_id.." ue="..loop_id)
        if amf_paging_start_id >= end_amf then
            amf_paging_start_id = start_amf
        else
            amf_paging_start_id = amf_paging_start_id + 1
        end
        sleep(0.3)
    end
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
			start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
		end
	end
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
			start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
		end
	end
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
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
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
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, direction, packetsize)
        end
    end
end

function multiue_pdu_session(start_ue, end_ue, pdu_id)
    local func_name = "multiue_pdu_session"
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

function multiue_retry_dereg(start_ue, end_ue, delay)
    local func_name = "multiue_retry_dereg"
    local err = {}
    local result = {}
    local deregister_type = "switch_off"
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
		if ue_.state ~= ue.OFF  then
            print("The UE:"..ue_.id.." state is "..ue_.state.." .Doing DeReg")
            exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
            sleep(delay)
        end
    end
end

log_rotate_ue_limit = 126

function grep_for_event_pattern_using_log_analyses_module(start_ue, end_ue, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, dir, packetsize)
	local log_file_handle
    local log_file_name = "egate_console.log"
    local current_pattern = nil
    local pattern_found = false
    local expected_patterns = {}
    local remaining_ues = {}

    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
		if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
			table.insert(remaining_ues, ue_id)
		end
    end

    exec("set_log flush")
    log_file_handle = io.open(log_file_name, "r")
    for i=1,50 do
        local ue_index = 1
        while ue_index <= #remaining_ues do
            local ue_id = remaining_ues[ue_index]
            table.remove(expected_patterns)
            local pattern="UE%-"..ue_id.." PDU SESSION ID%-1 setup/reestablishment complete"
            table.insert(expected_patterns, pattern)

            for _, pattern in ipairs(expected_patterns) do
                log_file_handle:seek("set")
                pattern_found = false
                current_pattern = pattern

                for line in log_file_handle:lines() do
                    local i, j = string.find(line, pattern)
                    if i then
                        pattern_found = true;
                        table.remove(remaining_ues, ue_index)
						start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, dir, packetsize)
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
            sleep(0.025)
            exec("set_log flush")
        else
            do break end
        end
    end
    for _, ue_id in ipairs(remaining_ues) do
        local err="UE%-"..ue_id.." PDU SESSION ID Pattern NOT Found"
        print(err)
        exec("set_log flush")
    end
    local modres = end_ue % log_rotate_ue_limit
    if modres == 0 then
        print("Egate_console Log rotate triggered at UE-"..end_ue)
        egate_console_log_rotate()
    end
    io.close(log_file_handle)
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
                        start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, rate, ul_datarate, dl_datarate, dir, packetsize)
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

function register_pdusetup_with_traffic_parallel(start_ue, end_ue, num_cells, pdu_id, qfi_id, trf_id, rate, ul_datarate_kbps, dl_datarate_kbps, direction, delay_bw_ue_attach, trf_type, packetsize)
    local func_name = "register_pdusetup_with_traffic_parallel"
    local err = {}
    local result = {}
    local state = {}
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
			exec('ue_register id='..start_ue..'-'..end_ue_range..' ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg')
		end
        multiue_pdu_session(start_ue, end_ue_range, pdu_id)
--        state = mue_state(start_ue, end_ue_range)
--        if state == ok then
--            printStep(func_name .. ": Start PDU Session Establishment")
--            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..start_ue.."-"..end_ue_range.." nwslice=1")
            sleep(delay_bw_ue_attach)
--            print(os.date("Before Matching patterns: %c"))

            grep_for_event_pattern_using_log_analyses_module(start_ue, end_ue_range, pdu_id, qfi_id, trf_id, rate, ul_datarate_kbps, dl_datarate_kbps, direction, packetsize)
--            print(os.date("After Matching patterns: %c"))
--        end
        sleep(0.02)
        start_ue = end_ue_range + 1
        end_ue_range = start_ue + num_cells - 1
    end
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
			exec('ue_register id='..start_ue..'-'..end_ue_range..' ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg')
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
end

function check_NgLInk(start_amf, end_amf)
    local log_file_handle
    local log_file_name = "egate_console.log"
    local current_pattern = nil
    local pattern_found = false
    local expected_patterns = {}
    local remaining_amf = {}

    for amf_id=start_amf, end_amf do
        table.insert(remaining_amf, amf_id)
    end

    exec("set_log flush")
    log_file_handle = io.open(log_file_name, "r")
    local amf_index = 1
    while amf_index <= #remaining_amf do
        local amf_id = remaining_amf[amf_index]
        table.remove(expected_patterns)
        local pattern="AMF%-"..amf_id..": AMF %- IP:10%.0%.1%.2 NG link is Up"
        table.insert(expected_patterns, pattern)

        for _, pattern in ipairs(expected_patterns) do
            log_file_handle:seek("set")
            pattern_found = false
            current_pattern = pattern

            for line in log_file_handle:lines() do
                local i, j = string.find(line, pattern)
                if i then
                    pattern_found = true;
                    print("AMF-"..amf_id..": AMF Found")
                    table.remove(remaining_amf, amf_index)
                    do break end
                end
            end
            if pattern_found == false then
                amf_index = amf_index + 1
            end
        end
    end
    for _, amf_id in ipairs(remaining_amf) do
        local err="AMF-"..amf_id..": AMF Not Found"
        print(err)
        exec("set_log flush")
    end
    io.close(log_file_handle)
print('Ng Link Check Script Completed')
exec("set_log flush")
end

function check_CellSetup(start_cell, end_cell)
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
        local pattern="Airphone: Cell Setup completed for %[CELL%_ID:"..cell_id.."%]"
        table.insert(expected_patterns, pattern)

        for _, pattern in ipairs(expected_patterns) do
            log_file_handle:seek("set")
            pattern_found = false
            current_pattern = pattern

            for line in log_file_handle:lines() do
                local i, j = string.find(line, pattern)
                if i then
                    pattern_found = true;
                    print("Cell Setup for"..cell_id..": Cell Setup Found")
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
        local err=("Cell Setup for"..cell_id..": Cell Setup Not Found")
        print(err)
        exec("set_log flush")
    end
    io.close(log_file_handle)
print('Cell Setup Check Script Completed')
exec("set_log flush")
end

function check_SIBs_withUECcount(start_cell, end_cell, uec_count)
    local log_file_handle
    local log_file_name = "egate_console.log"
    local uec_pattern_found = false
    local cell_pattern_found = false
    local expected_patterns = {}
    local remaining_cells = {}
    local cell_id
    local uec_start_id = 1
    local uec_end_id = uec_count
    local count = 0
	local c_count = 0
	local cell_count = 0
    local sep = "%s"
    
    local cell_info = {}
    for str in string.gmatch(start_cell, "([^"..sep.."]+)") do
        table.insert(cell_info, str)
    end
    
    for _ in pairs(cell_info) do c_count = c_count + 1 end
    print(" count is ",c_count)
    
    if c_count > 1 then    
        for i, value in ipairs(cell_info) do
            table.insert(remaining_cells, tonumber(value))
            cell_count = cell_count + 1
        end 
    else
        cell_count = (end_cell - start_cell) + 1
        for cell_id=start_cell, end_cell do
            table.insert(remaining_cells, cell_id)
        end
    end
    
    exec("set_log flush")
    log_file_handle = io.open(log_file_name, "r")
    local cell_index = 1
    while cell_index <= #remaining_cells do
        cell_id = remaining_cells[cell_index]

        for uec_id=uec_start_id, uec_end_id do
            table.remove(expected_patterns)
            local pattern="-"..uec_id..": eNB 2 cell "..cell_id..": SystemInformationBlockType"
            table.insert(expected_patterns, pattern)

            for _, pattern in ipairs(expected_patterns) do
                log_file_handle:seek("set")
                cell_pattern_found = false
                uec_pattern_found = false

                for line in log_file_handle:lines() do
                    local i, j = string.find(line, pattern)
                    if i then
                        uec_pattern_found = true;
                        print("UEC-"..uec_id.." eNB 2 cell "..cell_id..": SIB Found")
			count = count + 1
                        if uec_id >= uec_end_id then
                            table.remove(remaining_cells, cell_index)
			    cell_pattern_found = true
                         end
                         do break end
                    end
                end
                if uec_pattern_found == false then
                    print("UEC-"..uec_id..": eNB 2 cell "..cell_id..": SIB NOT Received")
                end
                if cell_pattern_found == false and uec_id >= uec_end_id then
                    cell_index = cell_index + 1
                end
            end
        end
    end
    for _, cell_id in ipairs(remaining_cells) do
        local err="   eNB 2 cell "..cell_id..": SIB NOT Received"
        print(err)
        exec("set_log flush")
    end
    print("Number of UEC: "..uec_count.." | Number of CELL: "..cell_count.." | Number of Expected SIBs:"..uec_count * cell_count.."| Total SIBs received:"..count)
    exec("set_log flush")
    io.close(log_file_handle)
end

function beam_profile_creation_and_UEs_association(start_ue, end_ue, number_of_profiles, number_of_cells)
    local func_name = "beam_profile_creation_and_UEs_association"
    local err = {}
    local result = {}
    local prof_id = 1
    local temp_profid = prof_id
    local last_cell_id = number_of_cells - 1
    local delay_bw_ue_attach = 0.01
    local start_ue_range = start_ue / number_of_profiles
    local end_ue_range = number_of_profiles
    create_beamcontrol_testmode_nr_profile(number_of_profiles)
    sleep(delay_bw_ue_attach)
      
    for ue_id=start_ue_range, end_ue do
        exec('ue_testmode_set_nr id='..start_ue..'-'..end_ue_range..' testmode=beam_control action=activate profile_id='..temp_profid..' beamaction=attach scell=0-'..last_cell_id..'')
        if temp_profid < number_of_profiles then
            temp_profid = temp_profid + 1
        else
            temp_profid = 1
        end
        start_ue=end_ue_range + 1
        end_ue_range=start_ue + number_of_profiles - 1
        sleep (delay_bw_ue_attach)
        if start_ue > end_ue then
            break
        end
    end
end

function check_SIBs_eNB(start_cell, end_cell)
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
        local pattern="eNB 1 cell "..cell_id..": SystemInformationBlockType2"
        table.insert(expected_patterns, pattern)

        for _, pattern in ipairs(expected_patterns) do
            log_file_handle:seek("set")
            pattern_found = false
            current_pattern = pattern

            for line in log_file_handle:lines() do
                local i, j = string.find(line, pattern)
                if i then
                    pattern_found = true;
                    print("eNB 1 cell "..cell_id..": eNB SIB Found")
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
        local err="eNB 1 cell "..cell_id..": eNB SIB NOT Received"
        print(err)
        exec("set_log flush")
    end
    io.close(log_file_handle)
print('SIB Check eNB Script Completed')
end

function check_CRM(start_cell, end_cell)
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
        local pattern="ENB%-1: Cell%-"..cell_id.." has No CRM Partnership created"
        table.insert(expected_patterns, pattern)

        for _, pattern in ipairs(expected_patterns) do
            log_file_handle:seek("set")
            pattern_found = false
            current_pattern = pattern

            for line in log_file_handle:lines() do
                local i, j = string.find(line, pattern)
                if i then
                    pattern_found = true;
                    print("ENB%-1: Cell%-"..cell_id.." CRM Found")
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
        local err="ENB%-1: Cell%-"..cell_id.." CRM NOT Received"
        print(err)
        exec("set_log flush")
    end
    io.close(log_file_handle)
print('CRM check Script Completed')
end
