-- Copyright (c) 2019 Nokia. All rights reserved.
-- Version 1.0 == Modified date 29-03-2021 -- New function wait_for_ue_registration_complete added for removing static delay during registration

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'
require 'ext_traffic'

function wait_for_ue_registration_complete(ue_id)
    local ue_ = ue(tonumber(ue_id))
	starttime = os.time()
    while(true) do
        if ue_.state == ue.ACTIVE then	    
	        return 'success'
	    end
		currenttime = os.time() - starttime
		if currenttime > 3 then
		    return 'fail'
		end
    end
end

function ue_register(func_name, ue_id, trf_type, err, result)
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
			sleep(0.01)
			exec('ue_register id='..ue_id)
			sleep(5)
			wait_for_ue_registration_complete(ue_id)
		end
    end
end

function start_call(ue_id, trf_type,delay_bw_ue_attach, trf_type, ul_datarate_bps, dl_datarate_bps, direction)
    local func_name = "start_call"
    local err = {}
    local result = {}
	local pdu_id = 1
	local ue_ = ue(tonumber(ue_id))
	ue_register(func_name, ue_id, trf_type, err, result)
    sim_log_set_flush()
	sleep(5)
    printStep(func_name .. ": Start PDU Session Establishment")
    exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." gw="..ue_id.." nwslice=1")
    --exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")
    --sleep(15)
    sim_log_set_flush()
    --start_traffic_internal(ue_id, ul_datarate_bps, dl_datarate_bps, direction)
    sleep(delay_bw_ue_attach)
    sim_log_set_flush()
end

function stop_call(ue_id)
    local func_name = "stop_call"
    local err = {}
    local result = {}
	local pdu_id = 1
	local deregister_type = "switch_off"
	
    local ue_ = ue(tonumber(ue_id))
	exec("ue_pdu_session_release ue="..ue_id.." pdu="..pdu_id)
	sleep(1)
    exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type.." by=ue")
	sleep(1)	 
end

function start_multiue_call(start_ue, end_ue, delay_bw_ue_attach, trf_type, ul_datarate_bps, dl_datarate_bps, direction)
    local func_name = "start_multiue_call"
    local err = {}
    local result = {}
    sim_log_set_flush()
    for ue_id=start_ue, end_ue do
	    start_call(ue_id, trf_type, delay_bw_ue_attach, trf_type, ul_datarate_bps, dl_datarate_bps, direction)
		sleep(5)
        start_traffic_internal(ue_id, ul_datarate_bps, dl_datarate_bps, direction)
	    sleep(delay_bw_ue_attach)
        sim_log_set_flush()
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
end

function start_traffic_internal(ue_id, ul_datarate_bps, dl_datarate_bps, direction)
    local ue_ = ue(tonumber(ue_id))
    print('Starting traffic for ue_id='..ue_id)
	local pdu_id = 1
	local trf_id = 1
	if direction == 'both' then
        exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' bps='..ul_datarate_bps..' dir=ul')
        sim_log_set_flush()
        sleep(5)
		exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' bps='..dl_datarate_bps..' dir=dl')
        sim_log_set_flush()
        sleep(5)
	else
	    if direction == 'ul' then
            exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' bps='..ul_datarate_bps..' dir='..direction)
		else
		    exec('trf_data_start ue='..ue_id..' pdu='..pdu_id..' qfi=1 trf_id='..trf_id..' bps='..dl_datarate_bps..' dir='..direction)
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

function stop_internal_traffic(start_ue, end_ue, trf_id)
    for ue_id=start_ue, end_ue do
	    exec('trf_data_stop ue='..ue_id..' pdu=1 qfi=1 trf_id='..trf_id)
	end
end

function ue_state(ue_id)
    local ue_ = ue(ue_id)
    print('UE state is '..ue_.state)
end

function sim_log_set_flush()
    local func_name = "sim_log_set_flush"
    printStep(func_name .. ": sending egate prints to egate_console.log file")
    exec("sim_log_set flush")
end
