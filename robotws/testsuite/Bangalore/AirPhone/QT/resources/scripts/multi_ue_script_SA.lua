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
			sleep(0.1)
			exec('ue_register id='..ue_id)
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
	sleep(2)
	
    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice=1")
            sleep(1.5)
--            exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1") 
--            sleep(0.1)
        end
    end
end

function stop_call(ue_id)
    local func_name = "stop_call"
    local err = {}
    local result = {}
	local deregister_type = "switch_off"
    local pdu_id = 1
	
    local ue_ = ue(tonumber(ue_id))
    if ue_.state == ue.ON or ue_.state == ue.IDLE or ue_.state == ue.ACTIVE then
        exec("ue_pdu_session_release pdu="..pdu_id.." ue="..ue_id.." by=ue")
        sleep(0.5)
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
	    stop_call(ue_id)
	end
    print('...SA UE Deregister is over...')
    exec('sim_log_set flush')
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

function start_traffic_internal_multiue(start_ue, end_ue, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
    print('starting traffic from ue_id='..start_ue..' to ue_id='..end_ue)
    for id=start_ue, end_ue do
	    if not packetsize then
		    start_traffic_internal(id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration)
		else
	        start_traffic_internal(id, pdu_id, qfi_id, trf_id, ul_datarate_bps, dl_datarate_bps, direction, duration, packetsize)
		end
	end
    print(direction..' Traffic is started for SA UEs successfully ')
    exec('sim_log_set flush')
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

function start_call_with_networkslice(ue_id, trf_type, nw_sliceid)
    local func_name = "start_call_with_networkslice"
    local err = {}
    local result = {}
    local pdu_id = 1
    --local nw_sliceid = ue_id 
    local ue_ = ue(tonumber(ue_id))
    ue_register(func_name, ue_id, trf_type, err, result)
    sleep(2)

    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            sleep(1)
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice="..nw_sliceid.."") 
            sleep(2)
--            exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1")
--            sleep(1)
        end
    end
end

function start_multiue_call_with_networkslice(start_ue, end_ue, delay_bw_ue_attach, trf_type)
    local func_name = "start_multiue_call_with_networkslice"
    local err = {}
    local result = {}
    local nw_sliceid = 1
    for ue_id=start_ue, end_ue do
        start_call_with_networkslice(ue_id, trf_type, nw_sliceid)
        sleep(delay_bw_ue_attach)
        nw_sliceid = nw_sliceid + 1
    end
    print('...SA UE Register is over...')
    exec('sim_log_set flush')
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
--            exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1")
--            sleep(0.1)
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
--            exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1")
--            sleep(0.1)
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

function ue_register_sixoperator(func_name, ue_id, trf_type, err, result, plmn)
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
			sleep(0.5)
			exec('ue_register id='..ue_id..' selected_plmn='..plmn..'')
            sleep(1)
		end
    end
end

function start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn)
    local func_name = "start_call_with_networkslice"
    local err = {}
    local result = {}
    local pdu_id = 1
    local ue_ = ue(tonumber(ue_id))
    ue_register_sixoperator(func_name, ue_id, trf_type, err, result, plmn)
    sleep(5)

    if ue_.state ~= ue.OFF then
         if ue_.state == ue.ON then
            printStep(func_name .. ": Start PDU Session Establishment")
            sleep(1)
            exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice="..nw_sliceid.."") 
            sleep(2)
--            exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1")
--            sleep(1)
        end
    end
end

function start_multiue_call_with_networkslice_sixoperator(startop1_ue, endop1_ue, startop2_ue, endop2_ue, startop3_ue, endop3_ue, startop4_ue, endop4_ue, startop5_ue, endop5_ue, startop6_ue, endop6_ue, delay_bw_ue_attach, trf_type, plmn1, plmn2, plmn3, plmn4, plmn5, plmn6)
    local func_name = "start_multiue_call_with_networkslice"
    local err = {}
    local result = {}
	local nw_sliceid = 1
    sleep(2)
    for ue_id=startop1_ue, endop1_ue do
        start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn1)
        sleep(delay_bw_ue_attach)
		nw_sliceid = nw_sliceid + 1
    end
	--local nw_sliceid = nw_sliceid + endop1_ue - startop1_ue + 1
	for ue_id=startop2_ue, endop2_ue do
        start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn2)
        sleep(delay_bw_ue_attach)
		nw_sliceid = nw_sliceid + 1
    end
	--local nw_sliceid = nw_sliceid + endop2_ue - startop2_ue + 1
	for ue_id=startop3_ue, endop3_ue do
        start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn3)
        sleep(delay_bw_ue_attach)
		nw_sliceid = nw_sliceid + 1
    end
	--local nw_sliceid = nw_sliceid + endop3_ue - startop3_ue + 1
	for ue_id=startop4_ue, endop4_ue do
        start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn4)
        sleep(delay_bw_ue_attach)
		nw_sliceid = nw_sliceid + 1
    end
	--local nw_sliceid = nw_sliceid + endop4_ue - startop4_ue + 1
	for ue_id=startop5_ue, endop5_ue do
        start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn5)
        sleep(delay_bw_ue_attach)
		nw_sliceid = nw_sliceid + 1
    end
	--local nw_sliceid = nw_sliceid + endop5_ue - startop5_ue + 1
	for ue_id=startop6_ue, endop6_ue do
        start_call_with_networkslice_sixoperator(ue_id, trf_type, nw_sliceid, plmn6)
        sleep(delay_bw_ue_attach)
		nw_sliceid = nw_sliceid + 1
    end
    print('SA UE Register is over for 6 operators')
    exec('sim_log_set flush')
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

function start_multiue_sa_handover(start_ue, end_ue, meas_id, event, phycell_id, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr, delay_bw_ue_handover, ho_type)
    local func_name = "start_multiue_sa_handover"
    local err = {}
    local result = {}
    for ue_id=start_ue, end_ue do
        sa_handover(ue_id, meas_id, event, phycell_id, srsrp_nr, srsrq_nr, nrsrp_nr, nrsrq_nr)
        sleep(delay_bw_ue_handover)
    end
    print(ho_type..' SA HO completed')
    exec('sim_log_set flush')
end

function addition_of_uehistory_info_sa_handover(start_ue, end_ue, plmn, gnb_id, num)  
    local func_name = "start_multiue_sa_handover"
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
    print("UE History"..num.." Info added")
    exec('sim_log_set flush')
end

function start_call_with_same_networkslice_sixoperator(start_ue, end_ue, trf_type, nw_sliceid, plmn)
    local func_name = "start_call_with_same_networkslice"
    local err = {}
    local result = {}
    local pdu_id = 1
    for ue_id=start_ue, end_ue do
        local ue_ = ue(tonumber(ue_id))
        ue_register_sixoperator(func_name, ue_id, trf_type, err, result, plmn)
        sleep(4)

       if ue_.state ~= ue.OFF then
            if ue_.state == ue.ON then
               printStep(func_name .. ": Start PDU Session Establishment")
                exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice="..nw_sliceid.."")
                sleep(3)
--                exec("ue_cqi_param id="..ue_id.." on=nr nr_cqi_mode=fixed nr_cqi=15 scell=primary nr_ri_mode=fixed nr_ri=1")
--                sleep(1)
            end
        end
    end
end



