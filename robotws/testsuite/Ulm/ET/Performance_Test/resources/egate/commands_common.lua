-- Copyright (c) 2024 Nokia. All rights reserved.
require 'performance_configs'
require 'performance_helper'

function performance_common_seq_active_cells_lua(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want a sequential attach with active cells

    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(2)
    set_multi_amf_to_register_multiue(args.start_amf,args.end_amf,args.plmn,args.start_ue,args.end_ue)
    register_multiue_with_traffic_parallel_seq_active_cells(args)
    sleep(1)
    exec('ue_summary')
    sleep(1)
    print("performance_common_seq_active_cells_lua script completed")
end

function performance_common_lua(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use AIRPHONE created commands
        this functions wraps register_multiue_with_traffic_parallel to work with performance "Run Common Test"

    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    sleep(2)
    set_multi_amf_to_register_multiue(args.start_amf,args.end_amf,args.plmn,args.start_ue,args.end_ue)
    sleep(1)
    register_multiue_with_traffic_parallel(  -- calls ap code, cannot simplify anymore
        args.start_ue,
        args.end_ue,
        args.num_cells,
        args.pdu_id[1],
        args.qfi_id[1],
        args.trf_id[1],
        args.rate,
        args.ul_datarate,
        args.dl_datarate,
        args.trf_direction,
        args.delay_bw_ue_attach,
        args.trf_type,
        args.packetsize,
        args.Retry_IDLE_OFF_UE,
        args.srbInactivityTimerSA,
        args.ue_nr_cap
    )
    sleep(1)
    exec('ue_summary')
    print("performance_common_lua script completed")
end

function performance_common_lua_v2(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use all the new performance functionalities
            - max ue per cell
            - active cells ( inactive cells will not attach any UEs )
        this functions wraps register_multiue_with_traffic_parallel_v2 to work with performance "Run Common Test"

    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1) -- some delay for egate processing amf
    exec('sim_debug_log level=0 gate=1')
    sleep(2) -- some delay for egate processing amf
    set_multi_amf_to_register_multiue(args.start_amf,args.end_amf,args.plmn,args.start_ue,args.end_ue)
    sleep(5) -- some delay for egate processing amf
    register_multiue_with_traffic_parallel_v2(args)
    sleep(1) -- some delay to ensure stability
    exec('ue_summary')
    print("performance_common_lua_v2 script completed")
end

function performance_common_lua_mumimo_srs(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use ul mumimo testmode onn top of all performance functionalities
            - max ue per cell
            - active cells ( inactive cells will not attach any UEs )
            - ul_mimo_srs_beam_pos

    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1) -- some delay for egate processing amf
    exec('sim_debug_log level=0 gate=1')
    sleep(2) -- some delay for egate processing amf
    set_multi_amf_to_register_multiue(args.start_amf,args.end_amf,args.plmn,args.start_ue,args.end_ue)
    sleep(5) -- some delay for egate processing amf
    register_multiue_with_traffic_parallel_v2(args)
    sleep(365) -- some delay to ensure stability
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ue_testmode_set_nr id=1-300 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
    exec('ue_testmode_set_nr id=301-600 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
    exec('ue_testmode_set_nr id=601-900 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
    exec('ue_testmode_set_nr id=901-1200 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
    exec('ue_summary')
    print("performance_common_lua_mumimo_srs script completed")
end

function performance_common_seq_lua(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially
        (Does not support some functionalities: TBA )

    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1) -- some delay for egate processing amf
    exec('sim_debug_log level=0 gate=1')
    sleep(2) -- some delay for egate processing amf
    set_multi_amf_to_register_multiue(args.start_amf,args.end_amf,args.plmn,args.start_ue,args.end_ue)
    sleep(1) -- some delay for egate processing amf
    register_multiue_with_traffic_parallel_seq_active_cells(args)
    sleep(1) -- some delay to ensure stability
    exec('ue_summary')
    print("performance_common_seq_lua script completed")
end

function performance_common_seq_pdu_session_lua(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you just want to attach and setup PDU
        (No Traffic)

    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    sleep(2)
    set_multi_amf_to_register_multiue(args.start_amf,args.end_amf,args.plmn,args.start_ue,args.end_ue)
    sleep(1)
    for ue_id=args.start_ue, args.end_ue do
        local ue_cell = get_cell_id_for_ue(ue_id, args.num_cells)
        local is_included = is_cell_included(ue_cell, args.active_cells)
        if is_included then
            for _,pdu_id in pairs(args.pdu_id) do
                exec('set_pdu_param ue='..ue_id..' pdu='..pdu_id..' trf_type=internal')
                exec('ue_register id='..ue_id..' ue_nr_capabilities='..args.ue_nr_cap..' capability_file=./capability.cfg')
                multiue_pdu_session(ue_id, ue_id, pdu_id)
            end
        else
            print("[DEBUG] [SKIP] UE: "..ue_id.." Cell: "..ue_cell)
        end
    end
    exec('ue_summary')
    sleep(1)
    print("performance_common_seq_pdu_session_lua script completed")
end

function deregister_multiue_with_traffic_parallel_seq_active_cells(argp)
    --[=====[  DOCUMENTATION

        simply deregisters all UEs sequentially

    -- required args:
        -- args.start_ue,                  -- start_ue
        -- args.end_ue,                    -- end_ue : total ues
        -- args.num_cells,                 -- num_cells
        -- args.active_cells,              -- which cells to attach to, comma separated e.g '1,3'
        -- args.deregister_type            -- switch_off
        -- args.deregister_by,             -- ue
    --]=====]

    local args = convert_str_to_table(argp)

    for ue_id=args.start_ue, args.end_ue do
        local ue_cell = get_cell_id_for_ue(ue_id, args.num_cells)
        local is_included = is_cell_included(ue_cell, args.active_cells)

        if is_included then
            goto continue_register
        else
            print("[DEBUG] [SKIP] UE: "..ue_id.." Cell: "..ue_cell)
            goto skip_register
        end

        ::continue_register::
        exec('ue_deregister id='..ue_id..' ue_deregister_type='..args.deregister_type..' by='..args.deregister_by)

        if  args.deregister_delay ~= 0 then
            sleep(tonumber(args.deregister_delay))
        end

        ::skip_register::
    end
    if args.deregister_retry == 'true' then
        for ue_id=args.start_ue, args.end_ue do
            local ue_ = ue(tonumber(ue_id))
            if ue_.state ~= ue.OFF  then
                print("The UE:"..ue_.id.." state is "..ue_.state.." .Doing DeReg")
                exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
            end
        end
    end
    print("deregister_multiue_with_traffic_parallel_seq_active_cells script completed")
end

function deregister_multiue_parallel(argp)
    --[=====[  DOCUMENTATION

        simply deregisters all UEs in parallel

    -- required args:
        -- args.start_ue,                  -- start_ue
        -- args.end_ue,                    -- end_ue : total ues
        -- args.num_cells,                 -- num_cells
        -- args.active_cells,              -- which cells to attach to, comma separated e.g '1,3'
        -- args.deregister_type            -- switch_off
        -- args.deregister_by,             -- ue
    --]=====]
    local args = convert_str_to_table(argp)

    local end_ue = args.end_ue / args.num_cells
    local end_ue_range = args.start_ue + args.num_cells - 1
    local start_ue_range = math.floor(args.start_ue / args.num_cells)
    local start_ue = args.start_ue

    for loop_id=start_ue_range, end_ue do
        print('[DEBUG]    loop_id: '..loop_id)
        range = get_range_for_included_cells(start_ue, end_ue_range, args)
        if range == nil then
            goto continue_deregister
        end
        exec('ue_deregister id='..range..' ue_deregister_type='..args.deregister_type..' by='..args.deregister_by)
        included_ues = string.gmatch(range, '([^,]+)')
        for included_ue in included_ues do
            print('[DEBUG]    included_ue: '..included_ue)
            ue_cell = get_cell_id_for_ue(included_ue, args.num_cells)
            args.ue_count_in_cell[ue_cell] = args.ue_count_in_cell[ue_cell] - 1
            print('[DEBUG]    ue_count_in_cell: '..args.ue_count_in_cell[ue_cell])
        end
        if tonumber(args.deregister_delay) ~= 0 then
            print('[DEBUG]    deregister_delay: '..args.deregister_delay)
            sleep(tonumber(args.deregister_delay))
            print('[DEBUG]    deregister_delay: '..args.deregister_delay)
        end
        start_ue = end_ue_range + 1
        print('[DEBUG]    start_ue: '..start_ue)
        end_ue_range = start_ue + args.num_cells - 1
        print('[DEBUG]    end_ue_range: '..end_ue_range)
        ::continue_deregister::
    end
    if args.deregister_retry == 'true' then
        for ue_id=args.start_ue, args.end_ue do
            local ue_ = ue(tonumber(ue_id))
            if ue_.state ~= ue.OFF  then
                print("The UE:"..ue_.id.." state is "..ue_.state.." .Doing DeReg")
                exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
            end
        end
    end
    print("deregister_multiue_parallel script completed")
end

function deregister_multiue_quick(argp)
    --[=====[  DOCUMENTATION

        simply deregisters all UEs

    -- required args:
        -- args.start_ue,                  -- start_ue
        -- args.end_ue,                    -- end_ue : total ues
        -- args.num_cells,                 -- num_cells
        -- args.active_cells,              -- which cells to attach to, comma separated e.g '1,3'
        -- args.deregister_type            -- switch_off
        -- args.deregister_by,             -- ue
        -- args.deregister_range_split,    -- all , 1..X
        -- args.deregister_all_after_split
    --]=====]
    local args = convert_str_to_table(argp)

    if args.deregister_seq_stop_id ~= nil then
        exec('seq_stop id='..args.deregister_seq_stop_id)
    end

    if args.deregister_range_split ~= 'all' then

        increments = math.floor(args.end_ue / args.deregister_range_split)
        store = tonumber(args.start_ue)
        range_table = {}
        while store < args.end_ue do
            if (store + increments) < args.end_ue then
                store = store + increments
            else
                store = store + (args.end_ue - store)
            end
            range_table[#range_table+1] = store
        end

        print("[Debug] range table:")
        print_dictionary(range_table)

        start_ue = tonumber(args.start_ue)
        for _, end_ue in pairs(range_table) do

            print("[Debug] Deregister: "..start_ue..'-'..end_ue)
            --if start_ue == end_ue and start_ue ~= 1 then
            --    range = end_ue
            --else
                range = start_ue..'-'..end_ue
            --end
            exec('ue_deregister id='..range..' ue_deregister_type='..args.deregister_type..' by='..args.deregister_by)

            print("[Debug] Deregister: "..start_ue..'-'..end_ue..' : done')

            start_ue = tonumber(end_ue) + 1
            if tonumber(args.deregister_delay) ~= 0 then
                print("[Debug] Deregister sleep"..args.deregister_delay)
                sleep(tonumber(args.deregister_delay))
                exec('ue_summary')
            end
        end
        print("[Debug] Deregister all")
        exec('ue_deregister id=all '..' ue_deregister_type='..args.deregister_type..' by='..args.deregister_by)
        exec('ue_summary')
    else
        print("[Debug] Deregister all")
        exec('ue_deregister id=all '..' ue_deregister_type='..args.deregister_type..' by='..args.deregister_by)
        exec('ue_summary')
    end

    --if args.deregister_retry == 'true' then
    --    for ue_id=args.start_ue, args.end_ue do
    --        local ue_ = ue(tonumber(ue_id))
    --        if ue_.state ~= ue.OFF  then
    --           print("The UE:"..ue_.id.." state is "..ue_.state.." .Doing DeReg")
    --            exec("ue_deregister id="..ue_id.." ue_deregister_type="..deregister_type)
    --        end
    --    end
    --end

    exec('filter_sim_rfm enable=INFO')
    sleep(2)
    exec('sim_param_set disable_events_on_telnet_session=no')
    sleep(2)
    exec('ue_summary')
    print("deregister_multiue_quick script completed")
end

function performance_common_add_traffic(argp)
    --[=====[  DOCUMENTATION



    --]=====]
    local args = convert_str_to_table(argp)
    if args.duplex == 'fdd' then
        require "multi_ue_sa_script_v5"
    else
        require "multi_ue_sa_script_new"
    end

    local start_ue = args.start_ue
    local end_ue = args.end_ue
    local num_cells = args.num_cells
    local delay_bw_ue_attach = args.delay_bw_ue_attach
    local trf_type = args.trf_type

    local end_ue_range = start_ue + num_cells - 1
    local start_ue_range = start_ue
    local range='1'

    while start_ue_range < end_ue do
    -- for loop_id=start_ue_range, end_ue do
        range = ''..start_ue_range..'-'..end_ue_range
        if args.register_delay ~= 0 then
            sleep (args.register_delay + 0.0)
        end

        if end_ue_range <= 800 then
            sleep (delay_bw_ue_attach - 0.5)
        elseif(end_ue_range <= 1800) then
            sleep (delay_bw_ue_attach - 0.2)
        else
            sleep (delay_bw_ue_attach + 0.0)
        end

        trf_start(range, args)
        sleep(0.03)

        start_ue_range = end_ue_range + 1
        end_ue_range = start_ue_range + num_cells - 1
    end


    exec('ue_summary')

    exec('filter_sim_rfm enable=INFO')
    exec('sim_param_set disable_events_on_telnet_session=no')
    sleep(1)
    print("performance_common_add_traffic script completed")
    sleep(1)
    exec('filter_sim_rfm disable=all')
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR')
    exec('sim_param_set disable_events_on_telnet_session=yes')
end

function performance_common_print(msg)
    print(msg)
end
