-- Copyright (c) 2019 Nokia. All rights reserved.

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
			sleep(1)
			exec('ue_register id='..ue_id)
			sleep(1)

			elseif trf_type == 'external' then
		    exec('ue_register id='..ue_id..' profile=1')
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
	sleep(1)
	printStep(func_name .. ": Start PDU Session Establishment")
    exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice=1")
    sleep(1)
end

function stop_call(ue_id)
    local func_name = "stop_call"
    local err = {}
    local result = {}
	local deregister_type = "switch_off"
	
    exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
    sleep(1)	
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

function stop_multiue_call(start_ue, end_ue)
    local func_name = "stop_multiue_call"
    local err = {}
    local result = {}
	
	for ue_id=start_ue, end_ue do
	    stop_call(ue_id)
	end
end

function attach_detach(start_ue, end_ue, delay_bw_ue_attach, timer, iterations, trf_type)
    local func_name = "attach_detach"
    local err = {}
    local result = {}
	
	for iter=1, iterations do
	    print('Iteration '..iter..' is started')
	    start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type)
	    sleep(timer)
	    stop_multiue_call(start_ue, end_ue)
	    sleep(1)
	end
end

function start_traffic_dl(client_ip, port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size,id)
    print('iperf -c '..client_ip..' -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection)
    os.execute('iperf -c '..client_ip..' -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection..' &')
	sleep(10)
    print('iperf -s -u -p '..port..' -i 1 -B '..bind_ip)
	os.execute('iperf -s -u -p '..port..' -i 1 -B '..bind_ip..'| tee /tmp/iperf_dl_'..id..'.txt &')
	sleep(10)
end

function start_traffic_internal(ue_id, trf_id, ul_datarate_mbps, dl_datarate_mbps, direction, duration, packetsize)
    local pdu_id = 1
    print('Starting traffic for ue_id='..ue_id)
	if not packetsize then
	    if direction == 'both' then
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir=ul seconds='..duration)
			exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir=dl seconds='..duration)
		else
		    if direction == 'ul' then
                exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir='..direction..' seconds='..duration)
			else
			    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir='..direction..' seconds='..duration)
			end
        end			
	else
	    if direction == 'both' then
		    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir=ul seconds='..duration..' size='..packetsize)
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir=dl seconds='..duration..' size='..packetsize)
		else
		    if direction == 'ul' then
	            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..ul_datarate_mbps..' dir='..direction..' seconds='..duration..' size='..packetsize)
			else
			    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' mbps='..dl_datarate_mbps..' dir='..direction..' seconds='..duration..' size='..packetsize)
			end
		end
	end
end

function start_traffic_internal_multiue(start_ue, end_ue, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
    print('starting traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for id=start_ue, end_ue do
	    if not packetsize then
		    start_traffic_internal(id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration)
		else
	        start_traffic_internal(id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
		end
	end
end
function start_traffic_ul(port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, ue_id, packet_size)
    local id = ue_id
    ue_id = ue_id - 1
    print('iperf -c 72.23.'..ue_id..'.1 -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection)
    os.execute('iperf -c 72.23.'..ue_id..'.1 -u -p '..port..' -l '..packet_size..' -b '..bandwidth..' -i 1 -t '..time_for_new_traffic_connection..' &')
	sleep(10)
    print('iperf -s -u -p '..port..' -i 1 -B '..bind_ip)
	os.execute('iperf -s -u -p '..port..' -i 1 -B '..bind_ip..'| tee /tmp/iperf_ul_'..id..'.txt  &')
	sleep(10)
end

function start_traffic_multi_ue_dl(start_ue, end_ue, starting_client_ip_octets, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size)
    for id=start_ue, end_ue do
	    local starting_client_ip = starting_client_ip_octets..'.'..id + 1
	    start_traffic_dl(starting_client_ip, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size,id)
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

function attach_traffic_detach(start_ue, end_ue, callholdingtime, overallduration_mins, do_attach, do_dl_traffic, do_ul_traffic)
    local starttime_ueid = {}
    local starttime_overall = 0
    local endtime_overall = 0
    local overallduration_seconds = overallduration_mins * 60
    local delay_bw_ue_attach = 5
    local starting_client_ip_octets = '1.2.4'
    local starting_port = 7071
    local bandwidth_dl = '50M'
    local interval = 1
    local time_for_new_traffic_connection = 6600
    local bind_ip = '10.0.2.1'
    local packet_size = 1200
    local starting_port_ul = 7131
    local bandwidth = '20M'
    local delay_bw_ue_attach = 5
    local iteration = 1

    for ue_id=start_ue, end_ue do
	    if do_attach == 'yes' then
	        start_call(ue_id,'external')
		    starttime_ueid[ue_id] = os.time()
		    sleep(delay_bw_ue_attach)
		end		
		if do_dl_traffic == 'yes' then
		    local starting_client_ip = starting_client_ip_octets..'.'..ue_id + 1
		    start_traffic_dl(starting_client_ip, starting_port, bandwidth_dl, interval, time_for_new_traffic_connection, bind_ip, packet_size,ue_id)
		    starting_port = starting_port + 1
		end		  
		if do_ul_traffic == 'yes' then
		    start_traffic_ul(starting_port_ul, bandwidth, interval, time_for_new_traffic_connection, bind_ip, ue_id, packet_size)
		    starting_port_ul = starting_port_ul + 1
		end
    end
    --stop_multiue_call(start_ue, end_ue)
	stop_iperf_traffic()
    print("Script End")
end

function attach_detach_concurrent(start_ue, end_ue, callholdingtime, overallduration_mins, do_need_traffic, trf_type)
    local starttime_ueid = {}
	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
	local delay_bw_ue_attach = 5
    local starting_client_ip_octets = '1.2.4'
    local starting_port = 7071
    local bandwidth_dl = '1M'
    local interval = 1
    local time_for_new_traffic_connection = 6600
    local bind_ip = '10.0.2.1'
    local packet_size = 1350
    local starting_port_ul = 7131
    local bandwidth = '1M'
    local delay_bw_ue_attach = 5
    local iteration = 1

    for ue_id=start_ue, end_ue do
	    start_call(ue_id)
		starttime_ueid[ue_id] = os.time()
		if do_need_traffic == 'yes' then
		    local starting_client_ip = starting_client_ip_octets..'.'..ue_id
		    start_traffic_dl(starting_client_ip, starting_port, bandwidth, interval, time_for_new_traffic_connection, bind_ip, packet_size,ue_id)
			starting_port = starting_port + 1
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


function run_SA_Internal_traffic(start_ue, end_ue, trf_direction, ul_datarate_mbps,dl_datarate_mbps, overallduration_mins)
	local starttime_overall = 0
	local endtime_overall = 0
	local overallduration_seconds = overallduration_mins * 60
	local packet_size = 1350
	local delay_bw_ue_attach = 2
    local iteration = 1
	local trf_id = 1
	local traffic_duration = 60
	local trf_type = 'internal'
	
    start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type)
	start_traffic_internal_multiue(start_ue, end_ue, trf_id, ul_datarate_mbps, dl_datarate_mbps, trf_direction, overallduration_seconds, packet_size)
	
	sleep(1)
end
    
function monitor_multiue_traffic(start_ue, end_ue, delay_time, trf_direction) 
    local func_name = "monitor_multiue_traffic"
    local err = {}
    local result = {}

	for ue_id=start_ue, end_ue do
	    monitor_traffic(ue_id, trf_direction)
		sleep(delay_time)
	end

end

function monitor_traffic(ue_id, trf_direction)
    local func_name = "monitor_traffic"
    local err = {}
    local result = {}
	
    if trf_direction == 'both' then
        exec('ue_stats_nr id='..ue_id..' type=pdsch scell=0-31')
		sleep(1)
		exec('ue_stats_nr id='..ue_id..' type=pusch scell=0-31')
	else
	    if trf_direction == 'ul' then
            exec('ue_stats_nr id='..ue_id..' type=pusch scell=0-31')
		else
		    exec('ue_stats_nr id='..ue_id..' type=pdsch scell=0-31')
		end
    end	    	
end 