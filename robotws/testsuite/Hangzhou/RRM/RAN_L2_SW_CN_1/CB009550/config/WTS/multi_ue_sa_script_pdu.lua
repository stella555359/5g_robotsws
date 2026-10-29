-- Copyright (c) 2019 Nokia. All rights reserved.
--1.0 Handling pduSize as optional parameter when generating traffic

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'
require 'ext_traffic'

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
			sleep(0.1)
			exec('ue_register id='..ue_id)
            sleep(1)
		end
    end
end

function start_call_with_delay(ue_id, trf_type)
    local func_name = "start_call"
    local err = {}
    local result = {}
	local pdu_id = 1
	
	local ue_ = ue(tonumber(ue_id))
	ue_register(func_name, ue_id, trf_type, err, result)
	sleep(2)
	
    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice=1")
            sleep(1)
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
             exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice=1") 
             break
          else
             printStep("UE still in Registering/Activating state")
          end
          sleep(0.1)     
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
	    sleep(1)	 
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
	print('All UEs are established successfully')
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
--		local ue_ = ue(tonumber(ue_id))
--	    if ue_.state == ue.ON or ue_.state == ue.ACTIVE then
--			exec('trf_data_stop ue='..ue_id..' pdu=1')
--			pdu_release(ue_id)
--		else
--			pdu_release(ue_id)
--		end
	    stop_call(ue_id)
	end
	print('All UEs are released successfully')
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

function start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
    local ue_ = ue(tonumber(ue_id))
    print('Starting traffic for ue_id='..ue_id)
	if not packetsize then
	    if direction == 'both' then
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..ul_datarate_bps..' dir=ul seconds='..duration)
			exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..dl_datarate_bps..' dir=dl seconds='..duration)
		else
		    if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..ul_datarate_bps..' dir='..direction..' seconds='..duration)
			else
			    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..dl_datarate_bps..' dir='..direction..' seconds='..duration)
			end
        end			
	else
	    if direction == 'both' then
		    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..ul_datarate_bps..' dir=ul seconds='..duration..' size='..packetsize)
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..dl_datarate_bps..' dir=dl seconds='..duration..' size='..packetsize)
		else
		    if direction == 'ul' then
	            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..ul_datarate_bps..' dir='..direction..' seconds='..duration..' size='..packetsize)
			else
			    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' bps='..dl_datarate_bps..' dir='..direction..' seconds='..duration..' size='..packetsize)
			end
		end
	end
end

function start_traffic_internal_in_mbps_arc(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_mbps, dl_datarate_mbps, direction, duration, packetsize)
    local ue_ = ue(tonumber(ue_id))
    print('Starting traffic for ue_id='..ue_id)
	if not packetsize then
	    if direction == 'both' then
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir=ul seconds='..duration)
			exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir=dl seconds='..duration)
		else
		    if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir='..direction..' seconds='..duration)
			else
			    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir='..direction..' seconds='..duration)
			end
        end			
	else
	    if direction == 'both' then
		    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir=ul seconds='..duration..' size='..packetsize)
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir=dl seconds='..duration..' size='..packetsize)
		else
		    if direction == 'ul' then
	            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir='..direction..' seconds='..duration..' size='..packetsize)
			else
			    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi='..qfi_id..' trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir='..direction..' seconds='..duration..' size='..packetsize)
			end
		end
	end
end

function calculate_number_of_trf_id_arc(rate_in_mbps)
    local func_name = "calculate_number_of_trf_id"
    local err = {}
    local result = {}
	local rate = rate_in_mbps
   
    if rate>160 then 
        num_trf_ids = rate/160
		return num_trf_ids
	else
        num_trf_ids = 1
		return num_trf_ids
	end
	if rate>160 then 
        last_trf_rate = rate%160
		return last_trf_rate
	else
        last_trf_rate = rate
		return last_trf_rate
	end
	if last_trf_rate>0 then 
        num_trf = num_trf_ids+1
		return num_trf
	else
        num_trf = num_trf_ids
		return num_trf
	end
	if last_trf_rate==rate then 
        num_trf_final = 1
		return num_trf_final
	else
        num_trf_final = num_trf
		return num_trf_final
	end
	if last_trf_rate==0 then 
        last_trf_rate_final = 160
		return last_trf_rate_final
	else
        last_trf_rate_final = last_trf_rate
		return last_trf_rate_final
	end
end

function start_traffic_internal_in_mbps_multiple_trf_id_arc(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_mbps, dl_datarate_mbps, direction, duration, packetsize)
    local func_name = "start"
    local err = {}
    local result = {}
	
	calculate_number_of_trf_id(rate_in_mbps)
	num_trf_for_loop = num_trf + 1
    for trf_id=1, num_trf_for_loop do
	    start_traffic_internal_in_mbps(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_mbps, dl_datarate_mbps, direction, duration, packetsize)
		sleep(delay_bw_ue_attach)
	end
end

function start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
    print('starting traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for id=start_ue, end_ue do
	    if not packetsize then
		    start_traffic_internal(id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration)
		else
	        start_traffic_internal(id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
		end
	end
	print('All UE Traffic is started')
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
	    exec('trf_data_stop ue='..ue_id..' pdu=1 qfi=1 trf_id='..trf_id)
	end
	print('ALL UE Traffic is stopped successfully')
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
	
function run_SA_Internal_traffic_profile1(g1_start_ue, g1_end_ue, g2_start_ue, g2_end_ue, g3_start_ue, g3_end_ue, g4_start_ue, g4_end_ue, g1_trf_direction, g1_ul_datarate_bps, g1_dl_datarate_bps, g2_trf_direction, g2_ul_datarate_bps, g2_dl_datarate_bps, g4_trf_direction, g4_ul_datarate_bps, g4_dl_datarate_bps, overallduration_mins)

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
	start_traffic_internal_multiue(g1_start_ue, g1_end_ue, trf_id, g1_ul_datarate_bps, g1_dl_datarate_bps, g1_trf_direction, overallduration_seconds, packet_size)
	
	start_multiue_call(g2_start_ue, g2_end_ue, delay_bw_ue_attach, trf_type)
    start_traffic_internal_multiue(g2_start_ue, g2_end_ue, trf_id, g2_ul_datarate_bps, g2_dl_datarate_bps, g2_trf_direction, overallduration_seconds, packet_size)
	
	start_multiue_call(g4_start_ue, g4_end_ue, delay_bw_ue_attach, trf_type)
	
	starttime_overall = os.time()
	while(endtime_overall < overallduration_seconds) do
        print('Iteration '..iteration..' is started')
	    start_multiue_call(g3_start_ue, g3_end_ue, delay_bw_ue_attach, trf_type)
		sleep(1)
		
		start_traffic_internal_multiue(g4_start_ue, g4_end_ue, trf_id, g4_ul_datarate_bps, g4_dl_datarate_bps, g4_trf_direction, overallduration_seconds, packet_size)
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
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice="..nw_sliceid.."") 
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
    local gw_id = 250 - ue_id
    local ue_id20 = 20
    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    sleep(2)

    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice="..nw_sliceid.."")
            sleep(1.5)                 
            if ue_id == ue_id20 then
               exec("ue_pdu_session_setup pdu="..pdu_id2.." ue="..ue_id.." gw="..gw_id.." nwslice="..nw_sliceid2_for_ue20.."")
               sleep(1.5)
            else
               exec("ue_pdu_session_setup pdu="..pdu_id2.." ue="..ue_id.." gw="..gw_id.." nwslice="..nw_sliceid2.."")
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
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice="..nw_sliceid.."")
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

function start_traffic_internal_multiue_in2qfi(start_ue, end_ue, pdu_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
    print('starting traffic from ue_id='..start_ue..' to ue_id='..end_ue)    
    for id=start_ue, end_ue do
        local qfi_id = id
        local qfi_id2 = id + 1
        if not packetsize then
            start_traffic_internal(id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration)
            start_traffic_internal(id, pdu_id, qfi_id2, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration)
        else
            start_traffic_internal(id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
            start_traffic_internal(id, pdu_id, qfi_id2, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
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
        print('Invalid number of beam control testmode profiles. Profiles can be 2 or 8')
    end
end

function attach_start_traffic_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, delay_bw_ue_attach, trf_type, packet_size)
    local func_name = "attach_start_traffic_multiue"
    local err = {}
    local result = {}
    print('attach and start traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for ue_id=start_ue, end_ue do
        start_call(ue_id, trf_type)
        sleep(delay_bw_ue_attach)
		if not packet_size then
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration)
            sleep(delay_bw_ue_attach)
		else
            start_traffic_internal(ue_id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packet_size)
            sleep(delay_bw_ue_attach)
		end
    end
	print('All UE Traffic is started')
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


function attach_start_traffic_detach_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, ul_direction, dl_direction, duration, delay_bw_ue_attach, trf_type, iterations)
    local func_name = "attach_start_traffic_detach_multiue"
    local err = {}
    local result = {}
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        attach_start_traffic_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, ul_direction, dl_direction, duration, delay_bw_ue_attach, trf_type)
        sleep(10)
        stop_multiue_call(start_ue, end_ue)
        sleep(delay_bw_ue_attach)
    end
    print('Script execution is finished')
end

function register_2drb_UEs_with_traffic(start_ue, end_ue, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, trf_type, packetsize, duration)
    local func_name = "attach_2drb_start_traffic"
    local err = {}
    local result = {}
	local pdu_id = 1
    local qfi_id2 = 2
    local delay_bw_ue_attach = 1
--  local trf_type = 'internal'

    start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    sleep(2.0)
    start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, packetsize, duration)
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.ON then
            printStep(func_name .. ": Modify PDU Session Establishment with QFI-2")
            exec("ue_pdu_session_modify ue="..ue_id.." pdu="..pdu_id.." qosflows_to_add="..qfi_id2.."")
        else
            printStep("UE still in Registering/Activating state")
        end
        sleep(1.5)
    end
    sleep(1.0)
    start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id2, trf_id, ul_datarate_bps, dl_datarate_bps, direction, packetsize, duration)
    sleep(3)
    exec("ue_disp state=ACTIVE format=long")
    sleep(1)
    exec("ue_disp state=IDLE format=long")
	print('Registered and started traffic for all UEs')
end

function stop_2drb_internal_traffic_release_deregister(start_ue, end_ue, trf_id)
    local func_name = "stop_2drb_internal_traffic_release_deregister"
    local pdu_id = 1
    local pdu_id2 = 2
    local err = {}
    local result = {}
    local deregister_type = "switch_off"
	local total_ues = end_ue - start_ue

    for ue_id=start_ue, end_ue do
        exec('trf_data_stop ue='..ue_id..' pdu=1 qfi=1 trf_id='..trf_id)
        exec('trf_data_stop ue='..ue_id..' pdu=1 qfi=2 trf_id='..trf_id)
    end
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        if ue_.state == ue.ON or ue_.state == ue.ACTIVE then
            exec('ue_pdu_session_release ue='..ue_id..' pdu=1')
            sleep(0.5)
        else
            if ue_.state == ue.IDLE then
            exec('ue_pdu_session_release ue='..ue_id..' pdu=1 by=amf')
            sleep(0.5)
            end
        end
    end
    for ue_id=start_ue, end_ue do
        exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
        sleep(0.3)
    end
	print('UEs deregisterd successfully')
end

function attach_detach_multiue_with_2drb_traffic(start_ue, end_ue, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, delay_bw_ue_attach, trf_type, iterations, packetsize, duration)
    local func_name = "attach_start_traffic_detach_multiue"
    local err = {}
    local result = {}
--	local trf_type = 'internal'
	
    for iter=1, iterations do
        print('Iteration '..iter..' is started')
        register_2drb_UEs_with_traffic(start_ue, end_ue, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, trf_type, packetsize, duration)
        sleep(delay_bw_ue_attach)
        stop_2drb_internal_traffic_release_deregister(start_ue, end_ue, trf_id)
    end
    print('Script execution is finished')
end
