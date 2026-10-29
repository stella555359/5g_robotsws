-- Copyright (c) 2024 Nokia. All rights reserved.
function enable_beamforming_with_6_profiles()
    print('enable_beamforming_profiles')
    sleep(1)
    exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
    exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
    exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
    sleep(1)
    print('enable_beamforming_profiles  script completed!')
end

function exec_ue_srs_beam_pos_nr_4_profiles()
    exec('ue_srs_beam_pos_nr profile_id=1 srsMode=fixed init_pos=0')
    exec('ue_srs_beam_pos_nr profile_id=2 srsMode=fixed init_pos=1')
    exec('ue_srs_beam_pos_nr profile_id=3 srsMode=fixed init_pos=2')
    exec('ue_srs_beam_pos_nr profile_id=4 srsMode=fixed init_pos=3')
    print('exec_ue_srs_beam_pos_nr_4_profiles  script completed')
end

function testmode_beam_control(profile_id_count, start_ue, end_ue, active_cells, num_cells)
    print('testmode_beam_control')
    local profile_id=1
    for ue_id=start_ue,end_ue,1
    do
        if profile_id > profile_id_count then
            profile_id = 1
        end
        local cell = get_cell_id_for_ue(ue_id, num_cells)
        local is_included = is_cell_included(cell, active_cells)
        if profile_id > profile_id_count then
            profile_id = 1
        end
        if is_included then
            exec('ue_testmode_set_nr id='..ue_id..' testmode=beam_control action=activate profile_id='..profile_id..' beamaction=attach')
            profile_id=profile_id+1
        end
    end
    print('testmode_beam_control  script completed')
end

function testmode_beam_control_1_profile_per_cell(profile_id_count, start_ue, end_ue, num_cells)
    print('testmode_beam_control_1_profile_per_cell')
    local profile_id=1
    local ue_id_inc=(end_ue/num_cells)
    local ue_id=1
    for cell_start=1,num_cells,1
    do
        if profile_id > profile_id_count then
            profile_id = 1
        end
        exec('ue_testmode_set_nr id='..ue_id..'-'..ue_id_inc..' testmode=beam_control action=activate profile_id='..profile_id..' beamaction=attach')
        profile_id=profile_id+1
        ue_id=ue_id_inc
        ue_id_inc=ue_id_inc+ue_id_inc
    end
    print('testmode_beam_control_1_profile_per_cell  script completed')
end

function  testmode_ue_srs_beam_pos(profile_id_count, start_ue, end_ue, active_cells, num_cells)
    local profile_id=1
    for ue_id=start_ue,end_ue,1
    do
        local cell = get_cell_id_for_ue(ue_id, num_cells)
        local is_included = is_cell_included(cell, active_cells)
        if profile_id > profile_id_count then
            profile_id = 1
        end
        if is_included then
            exec('ue_testmode_set_nr id='..ue_id..' testmode=ue_srs_beam_pos action=activate profile_id='..profile_id)
            profile_id=profile_id+1
        end
    end
    print('testmode_ue_srs_beam_pos  script completed')
end

function enable_cell_srs_testmode_profile_1(active_cells, num_cells)
    exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')
    for cell_id=1,num_cells,1
    do
        local is_included = is_cell_included(cell_id, active_cells)
        if is_included then
            exec('cell_testmode_set_nr cell_id='..cell_id..' gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
        end
    end
    sleep(3)
end
