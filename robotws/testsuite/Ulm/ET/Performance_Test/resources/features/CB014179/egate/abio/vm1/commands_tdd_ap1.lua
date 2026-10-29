-- Functions for Common Scripts for AP9000
-- Note currently, only support one configuration,


function configure()
    require "sansa.lua"
    run_configure()
end

function x2_link_up()
    exec('enb_x2_link_up enb=1 target=2')
end

function stop_max_dl_ul()
    require "multi_ue_sa_script_v3"

    stop_multiue_call_parallel(1,24,6,1,0.3)
end
function stop_max_dl()
    require "multi_ue_sa_script_v3"

    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_test_max_ul()
    require "multi_ue_sa_script_v3"

    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_max_ue()
    require "multi_ue_sa_script_v3"
    stop_multiue_call_parallel(1,4450,6,1,0.3)
end

function show_ue_nr_stats_24_ue_dl()
    exec("ue_stats_nr id=1-24 type=pdsch scell=0")
end
function show_ue_nr_stats_24_ue_ul()
    exec('ue_stats_nr id=1-24 type=pusch scell=0')
end


function start_max_dl_ul()
    require "multi_ue_sa_script_v3"
    --- Max throughput case (4 UEs * 6(cells/AP) = 24) UL 46200 kbps/ 150000 kbps
    --- start_ue: integer)
    --- end_ue: integer
    --- num_cellsI: integer
    --- pdu_id: integer
    --- qfi_id: integer
    --- trf_id: integer
    --- rate: bps, kbps, mbps
    --- ul_datarate: integer
    --- dl_datarate: integer
    --- direction: dl,ul,both
    --- delay_bw_ue_attach: integer,fraction
    --- trf_type: internal
    --- packetsize: between 42 to 1350
    --- Retry_IDLE_OFF_UE (yes,no)
    --- srbInactivityTimerSA:  (integer)  It should be same as commission file.
    set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",46,150,"both",2,"internal",1350,"yes",60)
end

function start_max_dl()
    require "multi_ue_sa_script_v3"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",1,150,"dl",1.6,"internal",1350,"yes",60)
end
function start_max_ul()
    require "multi_ue_sa_script_v3"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"kbps",46000,2,"both",1.6,"internal",1350,"yes",60)
end

function start_max_ue()
    require "multi_ue_sa_script_new"
    --- Max Ues case: 350 UEs * 6(cells/AP) = 2100 Ues with 74bps UL/DL
    --- Use 6Cell_6UEC_2100UEs_350UEs_PerCell.lua
exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",9000)
    sleep (3)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,9000,6,1,1,1,"bps",74,74,"both",0.3,"internal",42,"yes",60)
end
function ue_stats_dl()
     print(" ############# PDSCH stats for Cell-1  Begins  ################### ")
     exec('ue_stats_nr id=1-4 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-1  Ends  ##################### ")
     sleep(15)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-2  Start ##################### ")
     exec('ue_stats_nr id=5-8 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-2  Ends  ##################### ")
     sleep(10)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-3  Begins #################### ")
     exec('ue_stats_nr id=9-12 type=pdsch scell=0')
     sleep (0.5)
     print(" ############# PDSCH stats for Cell-3  Ends  #################### ")
     sleep(8)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-4  Begins #################### ")
     exec('ue_stats_nr id=13-16 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-4  Ends  ##################### ")
     sleep(7)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-5  Start ##################### ")
     exec('ue_stats_nr id=17-20 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-5  Ends  ##################### ")
     sleep(6)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-6  Begins #################### ")
     exec('ue_stats_nr id=21-24 type=pdsch scell=0')
     sleep (1)
     print(" ############ PDSCH stats for Cell-6  Ends    ################### ")


end
function ue_stats_ul()
     print(" ############# PDSCH stats for Cell-1  Begins  ################### ")
     exec('ue_stats_nr id=1-4 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-1  Ends  ##################### ")
     sleep(10)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-2  Start ##################### ")
     exec('ue_stats_nr id=5-8 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-2  Ends  ##################### ")
     sleep(8)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-3  Begins #################### ")
     exec('ue_stats_nr id=9-12 type=pusch scell=0')
     sleep(0.5)
     print(" ############# PDSCH stats for Cell-3  Ends  #################### ")
     sleep(7)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-4  Begins #################### ")
     exec('ue_stats_nr id=13-16 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-4  Ends  ##################### ")
     sleep(6)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-5  Start ##################### ")
     exec('ue_stats_nr id=17-20 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-5  Ends  ##################### ")
     sleep(5)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-6  Begins #################### ")
     exec('ue_stats_nr id=21-24 type=pusch scell=0')
     sleep (0.5)
     print(" ############ PDSCH stats for Cell-6  Ends    ################### ")


end

function start_max_ues()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep (1)
    set_amf_to_register_multiue(1,6,"311:489",3000)
    sleep (1)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,3000,6,1,1,1,"bps",74,74,"both",0.4,"internal",42,"yes",60)
end

function  trf_rate_down()
   require "multi_ue_sa_script_v3"
    run_traffic_only_with_range(1,24,1,1,1,2,2,"both",64)
end
function  trf_rate_up()
   require "multi_ue_sa_script_v3"
    run_traffic_only_with_range(1,24,1,1,1,46000,151000,"both",1350)
end
function sib_check()
    require "multi_ue_sa_script_new"
    check_SIBs(1,6)
end

------------------------------------------------------------------------------------------------------------------
---------------------------------------- performance team custom function ----------------------------------------
------------------------------------------------------------------------------------------------------------------
function tdd_3cells_varUEs_UL()
    --[=====[  DOCUMENTATION
    Use this function for tdd_3cells_varUEs_UL_ABIO_CB014179_pooling
    Cell 1 <--> 16 UEs
    Cell 2 <--> 16 UEs
    Cell 3 <--> 8 UEs
    --]=====]
    require "commands_common"
    local args = {}
    args['bearer_stats_collection'] = 'true'
    args['trf_direction'] = 'ul'
    args['ul_datarate'] = '0'
    args['dl_datarate'] = '0'
    args['rate'] = 'kbps'
    args['trf_protocol'] = 'udp'
    args['pdu_id'] = '1'
    args['qfi_id'] = '1'
    args['trf_id'] = '1'
    args['packetsize'] = '1350'
    args['period_ms'] = 'none'
    args['active_cells'] = '1!2!3'
    args['cell_max_ue'] = '16!16!8!0!0!0'
    args['cell_ul_throughput'] = '15000!15000!30000!0!0!0'
    args['cell_dl_throughput'] = 'null'
    args['cell_trf_dir'] = 'null'
    args['num_cells_online'] = '6'
    args['start_ue'] = '1'
    args['end_ue'] = '96'
    args['ue_per_cell'] = '16'
    args['start_cell'] = '1'
    args['end_cell'] = '6'
    args['ue_nr_cap'] = 'UE_CAP'
    args['registration_type'] = 'none'
    args['deregister_type'] = 'switch_off'
    args['deregister_by'] = 'ue'
    args['deregister_range_split'] = 'all'
    args['deregister_delay'] = '0'
    args['deregister_retry'] = 'false'
    args['verify'] = 'true'
    args['duplex'] = 'tdd'
    args['ue_count_in_cell'] = 'null'
    args['pmc_verification_sublabel'] = 'traffic'
    args['egate_script_delay_per_vm'] = '0s'
    args['AP_CELL_STATUS'] = 'False'
    args['ARGS_HASH'] = 'None'
    args['dcap_started'] = 'False'
    args['SIB_STATUS'] = 'False'
    args['num_cells'] = '6'
    args['total_active_cells'] = '3'
    args['total_active_ue'] = '40'
    args['bearer_stats_collection'] = 'true'
    args['trf_direction'] = 'ul'
    local argp=set_default_value_to_args(args)
    performance_common_seq_active_cells_lua(argp)
    print("performance_common_seq_active_cells_lua_tdd script completed")
end

function performance_common_seq_lua_tdd(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_seq_lua(args)
    print("performance_common_seq_lua_tdd script completed")
end

function PERFORMANCE_COMMON_TDD_MUMIMO_SRSBF(argp)
    --[=====[  DOCUMENTATION
        flexible version of PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL()

        required args: start_ue, end_ue, num_cells, active_cells, ul_datarate, dl_datarate, rate, trf_direction,
        optional args: ue_nr_cap, registration_type, period_ms, packetsize,
    --]=====]

    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua_mumimo_srs(args)
    print("PERFORMANCE_COMMON_TDD_MUMIMO_SRSBF script completed")
end

function PERFORMANCE_COMMON_TDD_BF_6PROFILES(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use AIRPHONE created commands
            with Beamforming 5 profiles
        this functions wraps register_multiue_with_traffic_parallel to work with performance "Run Common Test"

        --- from 1208FF_6Cells_432UEs ---

    --]=====]

    require "commands_common"
    local args = convert_str_to_table(argp)
    enable_beamforming_with_6_profiles()
    local profile_id_count=6
    testmode_beam_control(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_lua(args)
    print("PERFORMANCE_COMMON_TDD_BF_6PROFILES script completed")
end

function PERFORMANCE_COMMON_TDD_PET_1070FF_BF(argp)
    --[=====[  DOCUMENTATION
        --- from PET_1070FF_BF_9000UE_DLUL_rate1dot5 ---
    --]=====]

    require "commands_common"
    local args = convert_str_to_table(argp)

    -- enable_beamforming_with_6_profiles()
    exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
    exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
    exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
    -- exec('ue_testmode_set_nr id=1-1500 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=1501-3000 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=3001-4500 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=4501-6000 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=6001-7500 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=7501-9000 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')

    local profile_id_count=6
    testmode_beam_control(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_lua_v2(args)
    print("PERFORMANCE_COMMON_TDD_BF_6PROFILES script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_BF_6PROFILES(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach with Beamforming 6 profiles sequentially
        this functions wraps register_multiue_with_traffic_parallel to work with performance "Run Common Test"

        --- from 1208FF_6Cells_432UEs ---

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    enable_beamforming_with_6_profiles()
    local profile_id_count=6
    testmode_beam_control(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_lua_v2(args) -- performance_common_seq_active_cells_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_BF_6PROFILES script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_BF(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially with beamforming 1 profile
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    exec('ue_testmode_set_nr id=1-'..args.end_ue..' testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
    performance_common_seq_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_BF script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_BF_ACTIVE_CELLS(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially with beamforming 1 profile
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    local profile_id_count=6
    enable_beamforming_with_6_profiles()
    testmode_beam_control_1_profile_per_cell(profile_id_count, args.start_ue, args.end_ue, args.num_cells)
    performance_common_seq_active_cells_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_BF_ACTIVE_CELLS script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_SRS_ACTIVE_CELLS(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially with SRS
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    local profile_id_count=4
    exec_ue_srs_beam_pos_nr_4_profiles()
    testmode_ue_srs_beam_pos(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_seq_active_cells_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_SRS_ACTIVE_CELLS script completed")
end

function PERFORMANCE_COMMON_TDD(argp)
    --[=====[  DOCUMENTATION
        Uses the original airphone script

        required args: start_ue, end_ue, num_cells, active_cells, ul_datarate, dl_datarate, rate, trf_direction,
        optional args: ue_nr_cap, registration_type, period_ms, packetsize,
    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua(args)
    print("PERFORMANCE_COMMON_TDD script completed")
end

function PERFORMANCE_COMMON_TDD_V2(argp)
    --[=====[  DOCUMENTATION
        similar to PERFORMANCE_COMMON_TDD, use this when the parameters inside the multi_ue_sa_script needs to be changed dynamically
        it supports,
            active cells,
            custom number of ue per cells, etc...

        required args: start_ue, end_ue, num_cells, active_cells, ul_datarate, dl_datarate, rate, trf_direction,
        optional args: ue_nr_cap, registration_type, period_ms, packetsize,
    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua_v2(args)
    print("PERFORMANCE_COMMON_TDD_V2 script completed")
end
