-- Copyright (c) 2024 Nokia. All rights reserved.
function is_cell_included(cell, active_cells, separator)
    if separator == nil then
        separator = "!"
    end
    if active_cells == 'all' then
        return true
    end
    local _active_cells = string.gmatch(active_cells, '([^'..separator..']+)')
    for specific_cell in _active_cells do
        if tonumber(cell) == tonumber(specific_cell) then
            return true
        end
    end
    return false
end

function is_cell_max_ue_reached(args, ue_cell)
    ue_cell = tonumber(ue_cell)
    if args.cell_max_ue[ue_cell] ~= 'null' and args.cell_max_ue[ue_cell] ~= nil then
        print('[DEBUG]    ue_count_in_cell '..ue_cell..' : '..args.ue_count_in_cell[ue_cell])
        if tonumber(args.ue_count_in_cell[ue_cell]) >= tonumber(args.cell_max_ue[ue_cell]) then
            return true
        end
    end
    return false
end

function get_range_for_included_cells(start_range, end_range, args)
    range=''
    for current_ue = start_range,end_range do
        cellid = get_cell_id_for_ue(current_ue, args.num_cells)
        is_included = is_cell_included(cellid, args.active_cells)
        is_cell_max_ue = is_cell_max_ue_reached(args, cellid)
        print('[DEBUG]    get_range_for_included_cells, ue: '..current_ue..', cellid: '..cellid)
        print('[DEBUG]    is_included('..tostring(is_included)..')'..', is_cell_max_ue('..tostring(is_cell_max_ue)..')')
        if is_included and not is_cell_max_ue then
            range=range..current_ue..','
        end
        print('[DEBUG]    range: '..range)
    end
    if range == '' then
        print('[DEBUG]    range is nil!')
        return nil
    else
        range=range:sub(1, -2)
        print('[DEBUG]    total range: '..range)
        return range
    end
end

function count_items(tbl)
    tbl = string.gmatch(tbl, '([^,]+)')
    count = 0
    for i in tbl do
        count = count + 1
    end
    return count
end

function get_cell_id_for_ue(ue_id, num_cells)
    local ue_cell = ue_id % num_cells
    if ue_cell == 0 then
        ue_cell = num_cells
    end
    print("[DEBUG]    UE: "..ue_id.." Cell: "..ue_cell)
    return tonumber(ue_cell)
end

-- converts ampersand % separated string to table with named keys
function convert_str_to_table(arg_str, separator)
    if (type(arg_str) == "table") then
        return arg_str
    end
    local resulting_table = {}
    if separator == nil then
        separator = "%%"
    end
    print('========= start: convert_str_to_table =========')
    print('    arg_str: '..arg_str)
    for key, value in string.gmatch(arg_str, "([%w_]+)=([%w_!%.']+)"..separator.."?") do
        print('        key: '..key..', value: '..value)
        resulting_table[key] = value
    end
    resulting_table = set_default_value_to_args(resulting_table)
    print_dictionary(resulting_table)
    print('========= end: convert_str_to_table =========')
    return resulting_table
end

function set_default_value_to_args(args)
    if args.active_cells == nil then
        print('  - active_cells set to default value')
        args['active_cells'] = 'all'
    end
    if args.rate == nil then
        print('  - rate set to default value')
        args['rate'] = 'kbps'
    end
    if args.start_ue == nil then
        print('  - start_ue set to default value')
        args['start_ue'] = 1
    end
    if args.num_cells == nil then
        args['num_cells'] = 1
        print('  - num_cells set to default value')
    end
    if args.end_ue == nil or args.end_ue == 'null' then
        print('  - end_ue set to default value')
        args['end_ue'] = tonumber(args['num_cells']) * 1
    end
    if args.start_amf == nil then
        args['start_amf'] = 1
        print('  - start_amf set to default value')
    end
    if args.end_amf == nil then
        args['end_amf'] = 5
        print('  - end_amf set to default value')
    end
    if args.plmn == nil then
        args['plmn'] = "311:489"
        print('  - plmn set to default value')
    end
    if args.ue_nr_cap == nil then
        args['ue_nr_cap'] = 'UE_CAP'
        print('  - ue_nr_cap set to default value')
    end
    if args.packetsize == nil then
        args['packetsize'] = 1350
        print('  - packetsize set to default value')
    end
    if args.trf_type == nil then
        args['trf_type'] = 'internal'
        print('  - trf_type set to default value')
    end
    if args.pdu_id == nil then
        args['pdu_id'] = {1}
        print('  - pdu_id set to default value')
    else
        args['pdu_id'] = convert_separator_to_table(args['pdu_id'])
    end
    if args.qfi_id == nil then
        args['qfi_id'] = {1}
        print('  - qfi_id set to default value')
    else
        args['qfi_id'] = convert_separator_to_table(args['qfi_id'])
    end
    if args.trf_id == nil then
        args['trf_id'] = {1}
        print('  - trf_id set to default value')
    else
        args['trf_id'] = convert_separator_to_table(args['trf_id'])
    end
    if args.delay_bw_ue_attach == nil then
        args['delay_bw_ue_attach'] = 1.0
        print('  - delay_bw_ue_attach set to default value')
    end
    if args.multiue_pdu_session_retry == nil then
        args['multiue_pdu_session_retry'] = 20
        print('  - multiue_pdu_session_retry set to default value')
    end
    if args.Retry_IDLE_OFF_UE == nil then
        args['Retry_IDLE_OFF_UE'] = "no"
        print('  - Retry_IDLE_OFF_UE set to default value')
    end
    if args.srbInactivityTimerSA == nil then
        args['srbInactivityTimerSA'] = 60
        print('  - srbInactivityTimerSA set to default value')
    end
    if args.trf_protocol == nil then
        args['trf_protocol'] = 'udp'  -- udp|tcp|icmp
        print('  - trf_protocol set to default value')
    end
    if args.register_delay == nil then
        args['register_delay'] = 0
        print('  - register_delay set to default value')
    end
    if args.deregister_delay == nil then
        args['deregister_delay'] = 0
        print('  - deregister_delay set to default value')
    end
    if args.deregister_retry == nil then
        args['deregister_retry'] = 'false'
        print('  - deregister_retry set to default value')
    end
    if args.deregister_type == nil then
        args['deregister_type'] = 'switch_off'
        print('  - deregister_type set to default value')
    end
    if args.deregister_by == nil then
        args['deregister_by'] = 'ue'
        print('  - deregister_by set to default value')
    end
    if args.cell_dl_throughput ~= 'null' and args.cell_dl_throughput ~= nil then
        args['cell_dl_throughput'] = convert_separator_to_table(args['cell_dl_throughput'])
        for cellid=tonumber(args.start_cell), tonumber(args.end_cell) do
            if args['cell_dl_throughput'][tonumber(cellid)] == nil then
                args['cell_dl_throughput'][tonumber(cellid)]='null'
            end
        end
    else
        print('  - cell_dl_throughput set to default value')
        args['cell_dl_throughput'] = 'null'
    end
    if args.cell_ul_throughput ~= 'null' and args.cell_ul_throughput ~= nil then
        args['cell_ul_throughput'] = convert_separator_to_table(args['cell_ul_throughput'])
        for cellid=tonumber(args.start_cell), tonumber(args.end_cell) do
            if args['cell_ul_throughput'][tonumber(cellid)] == nil then
                args['cell_ul_throughput'][tonumber(cellid)]='null'
            end
        end
    else
        print('  - cell_ul_throughput set to default value')
        args['cell_ul_throughput'] = 'null'
    end
    if args.cell_max_ue ~= 'null' and args.cell_max_ue ~= nil then
        args['cell_max_ue'] = convert_separator_to_table(args['cell_max_ue'])
        for cellid=tonumber(args.start_cell), tonumber(args.end_cell) do
            if args['cell_max_ue'][tonumber(cellid)] == nil then
                args['cell_max_ue'][tonumber(cellid)]='null'
            end
        end
    else
        print('  - cell_max_ue set to default value')
        args['cell_max_ue'] = 'null'
    end
    if args.ue_count_in_cell ~= 'null' and args.ue_count_in_cell ~= nil then
        args['ue_count_in_cell'] = convert_separator_to_table(args['ue_count_in_cell'])
        for cellid=tonumber(args.start_cell), tonumber(args.end_cell) do
            if args['ue_count_in_cell'][tonumber(cellid)] == nil then
                args['ue_count_in_cell'][tonumber(cellid)] = 0
            end
        end
    else
        print('  - ue_count_in_cell set to default value')
        args['ue_count_in_cell'] = {}
        for cellid=tonumber(args.start_cell), tonumber(args.end_cell) do
            args['ue_count_in_cell'][tonumber(cellid)] = 0
        end
    end
    if args.cell_trf_dir ~= 'null' and args.cell_trf_dir ~= nil then
        args['cell_trf_dir'] = convert_separator_to_table(args['cell_trf_dir'])
        for cellid=tonumber(args.start_cell), tonumber(args.end_cell) do
            if args['cell_trf_dir'][tonumber(cellid)] == nil then
                args['cell_trf_dir'][tonumber(cellid)] = 'null'
            end
        end
    else
        print('  - cell_trf_dir set to default value')
        args['cell_trf_dir'] = 'null'
    end

    if args.deregister_range_split == nil then
        print('  - deregister_range_split set to default value')
        args['deregister_range_split'] = 'all'
    else
        if args.deregister_range_split ~= 'all' then
            args['deregister_range_split'] = tonumber(args['deregister_range_split'])
        end
    end

    should_be_number={'start_ue', 'end_ue', 'num_cells'}
    for _, key in ipairs(should_be_number) do
        args[key] = tonumber(args[key])
    end

    return args
end

function convert_separator_to_table(str, separator)
    if separator == nil then
        separator = "!"
    end
    item_table = {}

    local items = string.gmatch(str, '([^'..separator..']+)')
    for item in items do
        table.insert(item_table, item)
    end
    return item_table
end

function print_dictionary(dict)
    for key, value in pairs(dict) do
        if (type(value) == "table") then
            print('    '..key..": ")
            for key2, value2 in pairs(value) do
                print("     - "..value2)
            end
        else
            print('    '..key..": "..value)
        end
    end
end

function multiue_pdu_session_v2(range, pdu_id, retry)
    for ue_id in string.gmatch(range, '([^,]+)') do
        local ue_ = ue(tonumber(ue_id))
        for i=1, retry do
            if ue_.state == ue.ON and ue_.state == ue.ACTIVE then
                for _,pdu_id in pairs(pdu_id) do
                    exec("ue_pdu_session_setup pdu="..pdu_id.." ue="..ue_id.." nwslice=1")
                end
                goto exit_pdu
            else
                sleep(0.025)
            end
        end
        ::exit_pdu::
    end
end

function trf_start(range, args)
    print("[DEBUG] trf_start: "..range)
    packetsize = args.packetsize
    period_ms = args.period_ms
    trf_direction = args.trf_direction
    pdu_id = args.pdu_id
    qfi_id = args.qfi_id
    trf_id = args.trf_id
    rate = args.rate
    trf_protocol = args.trf_protocol
    ul_datarate = args.ul_datarate
    dl_datarate = args.dl_datarate
    cell_ul_throughput = args.cell_ul_throughput
    cell_dl_throughput = args.cell_dl_throughput
    cell_trf_dir = args.cell_trf_dir
    num_cells = args.num_cells

    if packetsize ~= nil and packetsize ~= 'none' then
        packetsize_cmd = ' size='..packetsize
    else
        packetsize_cmd = ''
    end
    if period_ms ~= nil and period_ms ~= 'none' then
        period_ms_cmd = ' period_ms='..period_ms
    else
        period_ms_cmd = ''
    end

    if cell_ul_throughput == 'null' and cell_dl_throughput == 'null' and cell_trf_dir == 'null' then -- for single value throughput for all cells
        for index=1,#pdu_id do -- loop for multi pdu sessions
            local trf_cmd='trf_data_start ue='..range..' pdu='..pdu_id[index]..' qfi='..qfi_id[index]..' trf_id='..trf_id[index]
            trf_cmd=trf_cmd..' protocol='..trf_protocol..packetsize_cmd..period_ms_cmd
            ul_rate = return_rate(rate, ul_datarate)
            dl_rate = return_rate(rate, dl_datarate)
            ul_trf_cmd=trf_cmd..' dir=ul '..ul_rate
            dl_trf_cmd=trf_cmd..' dir=dl '..dl_rate

            if trf_direction == 'both' then
                exec(ul_trf_cmd)
                exec(dl_trf_cmd)
            else
                if trf_direction == 'ul' then
                    exec(ul_trf_cmd)
                elseif trf_direction == 'dl' then
                    exec(dl_trf_cmd)
                else
                    print("[DEBUG] [ERROR] trf_direction is invalid!")
                end
            end
        end
    else -- for variable value throughput for each cells
        range_table = convert_separator_to_table(range, ',')
        for _, ue_id in ipairs(range_table) do
            for index=1,#pdu_id do -- loop for multi pdu sessions
                local trf_cmd='trf_data_start ue='..ue_id..' pdu='..pdu_id[index]..' qfi='..qfi_id[index]..' trf_id='..trf_id[index]
                trf_cmd=trf_cmd..' protocol='..trf_protocol..packetsize_cmd..period_ms_cmd
                cell_id = get_cell_id_for_ue(ue_id, num_cells)
                if cell_ul_throughput[tonumber(cell_id)] == 'null' or cell_ul_throughput[tonumber(cell_id)] == nil then
                    ul_datarate_2 = ul_datarate
                else
                    ul_datarate_2 = tonumber(cell_ul_throughput[tonumber(cell_id)])
                end
                if cell_dl_throughput[tonumber(cell_id)] == 'null' or cell_dl_throughput[tonumber(cell_id)] == nil then
                    dl_datarate_2 = dl_datarate
                else
                    dl_datarate_2 = tonumber(cell_dl_throughput[tonumber(cell_id)])
                end

                ul_rate = return_rate(rate, ul_datarate_2)
                dl_rate = return_rate(rate, dl_datarate_2)
                ul_trf_cmd=trf_cmd..' dir=ul '..ul_rate
                dl_trf_cmd=trf_cmd..' dir=dl '..dl_rate


                local _trf_direction = args.cell_trf_dir[cell_id]
                if _trf_direction == 'null' or _trf_direction == nil then
                    _trf_direction = args.trf_direction
                end
                if _trf_direction == 'both' then
                    exec(ul_trf_cmd)
                    exec(dl_trf_cmd)
                else
                    if _trf_direction == 'ul' then
                        exec(ul_trf_cmd)
                    elseif _trf_direction == 'dl' then
                        exec(dl_trf_cmd)
                    else
                        print("[DEBUG] [ERROR] trf_direction is invalid!")
                    end
                end
            end
        end
    end
end

function return_rate(rate, datarate)
    if tonumber(datarate) ~= 0 and datarate ~= nil then
        return rate..'='..datarate
    else
        return ''
    end
end