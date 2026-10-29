require "sim_config"

function seq_configuration(duration)

    ------------TC : FDD_TDD CA PCELL FDD  ----------------------------------


        exec('seq_set id=1 name=NSA_TDD  ue_group=3')
        exec('ue_attach ue_nr_capabilities=NSA_UE_NR_CAP ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE capability_file=./capability.cfg ')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
        exec('seq_delay 1.0')
        exec('trf_data_start id=2 dir=dl trf_id=1 kbps=29559 size=1350')
        exec('sleep '..duration)
        exec('trf_data_stop id=2')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
        exec('seq_delay 1.0')
        exec('ue_detach ')
        exec('seq_end')

        exec('seq_set id=2 name=NSA_TDD  ue_group=4')
        exec('ue_attach ue_nr_capabilities=NSA_UE_NR_CAP ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE capability_file=./capability.cfg ')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
        exec('seq_delay 1.0')
        exec('trf_data_start id=2 dir=dl trf_id=1 kbps=29559 size=1350')
        exec('sleep '..duration)
        exec('trf_data_stop id=2')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
        exec('seq_delay 1.0')
        exec('ue_detach ')
        exec('seq_end')


------------TC : FDD_TDD CA PCELL scell added UE ----------------------------------

        exec('seq_set id=3 name=NSA_RRC_UE  ue_group=3')
        exec('ue_attach ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE ue_nr_capabilities=NSA_UE_NR_CAP capability_file=./capability.cfg')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
        exec('seq_delay 1.0')
        exec('trf_data_start id=2 dir=dl trf_id=1 kbps=5708 size=1350')
        exec('sleep '..duration)
        exec('trf_data_stop id=2')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
        exec('seq_delay 1.0')
        exec('ue_detach ')
        exec('seq_end')

        exec('seq_set id=4 name=NSA_RRC_UE  ue_group=4')
        exec('ue_attach ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE ue_nr_capabilities=NSA_UE_NR_CAP capability_file=./capability.cfg')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
        exec('seq_delay 1.0')
        exec('trf_data_start id=2 dir=dl trf_id=1 kbps=5708 size=1350')
        exec('sleep '..duration)
        exec('trf_data_stop id=2')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
        exec('seq_delay 1.0')
        exec('ue_detach ')
        exec('seq_end')

------------TC : FDD_TDD CA SCELL Non CA UEs ----------------------------------

        exec('seq_set id=5 name=NSA_RRC_UE  ue_group=5')
        exec('ue_attach ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE ue_nr_capabilities=NSA_UE_NR_CAP capability_file=./capability.cfg')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
        exec('seq_delay 1.0')
        exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350')
        exec('trf_data_start id=2 dir=dl trf_id=2 kbps=30185 size=1350')
        exec('sleep '..duration)
        exec('trf_data_stop id=2')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
        exec('seq_delay 1.0')
        exec('ue_detach ')
        exec('seq_end')

        exec('seq_set id=6 name=NSA_RRC_UE  ue_group=6')
        exec('ue_attach ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE ue_nr_capabilities=NSA_UE_NR_CAP capability_file=./capability.cfg')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
        exec('seq_delay 1.0')
        exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350')
        exec('trf_data_start id=2 dir=dl trf_id=2 kbps=30185 size=1350')
        exec('sleep '..duration)
        exec('trf_data_stop id=2')
        exec('seq_delay 0.5')
        exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
        exec('seq_delay 1.0')
        exec('ue_detach ')
        exec('seq_end')

end

function PET_NSA_FDD_TDD_CA()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
    sleep(1)
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
    sleep(1)
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=UL_MIMO')
    sleep(1)
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=UL_MIMO')
    sleep(1)
    enable_vip_logs()
    sleep(1)
    exec('seq_start id=1-2 rate=1 detailed_print=on max_start=32')
    sleep(66)
    exec('seq_start id=3-6 rate=1 detailed_print=on max_start=4')
    sleep(8)
    profile_id=1
    for i = 217,224 do
            if profile_id > 4  then
                profile_id = 1
            end
            exec('ue_testmode_set_nr id='..i..' testmode=ul_mimo_srs_beam_pos action=activate profile_id='..profile_id..'')
            profile_id = profile_id+1
    end
    sleep(1)
    vm0_print("PET_NSA_FDD_TDD_CA script completed")
end


--[[ 

commands to egate
  cfg file=sim_config.lua entry=run_configuration(sim_data,5400)
  script file=sim_config.lua entry=mib_sib_check(sim_data)
  script file=sim_config.lua entry=x2_connections(sim_data)
--]]
