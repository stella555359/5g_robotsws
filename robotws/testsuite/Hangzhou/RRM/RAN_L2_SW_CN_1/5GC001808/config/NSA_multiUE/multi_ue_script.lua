-- Copyright (c) 2019 Nokia. All rights reserved.

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'

function lte_attach_multi_ue(num_ues)
    local ue_list = fill_ue_list(1, num_ues)
    ue_fast_attach(ue_list)
end

function sgnb_release_and_detach_multi_ue(num_ues, bearer_id)
    local func_name = "sgnb_release_and_detach_multi_ue"
    local result = {}
    local err = {}
    local ue_ = {}

    for ue_id=1, num_ues do
        ue_ = ue(tonumber(ue_id))
        sgnb_release(func_name, err, ue_, ue_id, bearer_id)
        if (err[g_StepNum] ~= nil) then
            error(err[g_StepNum], 0)
        end
        detach(func_name, ue_id, err, result)
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
        sgnb_addition(func_name, err, ue(tonumber(ue_id)), ue_id, bearer_id, target_gnb, target_gnb_cell)
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

        printStep(func_name .. ": UE"..ue_id.." UL Bearer stats")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=all")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=mcg")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=scg")
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")
        check_traffic_going_through_cell_group(ul_result, err, ue_, bearer_, "UL", bearer.SCG, ul_trf_bytes, delay)
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")

        printStep(func_name .. ": UE"..ue_id.." DL Bearer stats")
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=all")
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=mcg")
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=scg")
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")
        check_traffic_going_through_cell_group(dl_result, err, ue_, bearer_, "DL", bearer.SCG, dl_trf_bytes, delay)
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")

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

function check_dl_traffic_multi_ue(num_ues, bearer_id, dl_trf_bytes, delay)
    local func_name = "check_ul_dl_traffic_multi_ue"
    local ul_result = {}
    local dl_result = {}
    local err = {}
    local passed = 0

    for ue_id=1, num_ues do
        printStep(func_name .. ": UE"..ue_id.." Check internal ul and dl traffic")
        local ue_ = ue(tonumber(ue_id))
        local bearer_ = ue_:bearer(bearer_id)

        -- printStep(func_name .. ": UE"..ue_id.." UL Bearer stats")
        -- exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=all")
        -- exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=mcg")
        -- exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=scg")
        -- printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")
        -- check_traffic_going_through_cell_group(ul_result, err, ue_, bearer_, "UL", bearer.SCG, ul_trf_bytes, delay)
        -- printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")

        printStep(func_name .. ": UE"..ue_id.." DL Bearer stats")
        -- exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=all")
        -- exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=mcg")
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=scg")
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")
        check_traffic_going_through_cell_group(dl_result, err, ue_, bearer_, "DL", bearer.SCG, dl_trf_bytes, delay)
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")

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

function check_ul_traffic_multi_ue(num_ues, bearer_id, ul_trf_bytes, delay)
    local func_name = "check_ul_dl_traffic_multi_ue"
    local ul_result = {}
    local dl_result = {}
    local err = {}
    local passed = 0

    for ue_id=1, num_ues do
        printStep(func_name .. ": UE"..ue_id.." Check internal ul and dl traffic")
        local ue_ = ue(tonumber(ue_id))
        local bearer_ = ue_:bearer(bearer_id)

        printStep(func_name .. ": UE"..ue_id.." UL Bearer stats")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=all")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=mcg")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=scg")
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")
        check_traffic_going_through_cell_group(ul_result, err, ue_, bearer_, "UL", bearer.SCG, ul_trf_bytes, delay)
        printStep(func_name .. ": UE"..ue_id.."---------------------------------------------------")

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
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=all")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=mcg")
        exec("bearer_stats type=l3 dir=ul id=2 ue="..ue_.id.." dc_cell_group=scg")
    else
        bearer_l3_stats_ = bearer_:get_l3_bearer_stats(bearer.DL)
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=all")
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=mcg")
        exec("bearer_stats type=l3 dir=dl id=2 ue="..ue_.id.." dc_cell_group=scg")
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
