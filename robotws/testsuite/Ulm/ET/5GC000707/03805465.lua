ues=10
pdu_start=1
pdu_stop=15


for pdu = pdu_start,pdu_stop do
    --exec('rlf_testmode_nr profile_id=1 delete=yes')
    exec('set_log log_to_file=off')
    exec('sleep 1')
    exec('set_log log_to_file=on')

    for ue_id = 1,ues do
        exec('ue_kill id='..ue_id)
        exec('sleep 1')
        exec('ue_change_location cell=1 enb=2 id='..ue_id)
        exec('sleep 1')
        exec('ue_register registration_type=InitialRegistration id='..ue_id)
        exec('sleep 1')
        exec('set_pdu_param pdu='..pdu..' trf_type=internal ue='..ue_id)
        exec('sleep 1')
        exec('ue_pdu_session_setup pdu='..pdu..' nwslice=1 ue='..ue_id)
        exec('sleep 1')
        exec('ue_meas_cfg_disp id='..ue_id)
        exec('trf_data_start pdu='..pdu..' qfi=1 dir=dl mbps=1 trf_id=1 ue='..ue_id)
        exec('trf_data_start pdu='..pdu..' qfi=1 dir=ul mbps=1 trf_id=1 ue='..ue_id)
        exec('sleep 1')
        exec('ue_measurement_send_nr meas_id=1 event=A2 id='..ue_id)
        exec('sleep 1')
        exec('ue_meas_cfg_disp id='..ue_id)
    end

    exec('ue_disp')
    exec('sleep 3')
    exec('rlf_testmode_nr profile_id=1 num_stop_dlharq_tx=5000 num_stop_csi_report=5000')

    for ue_id = 1,ues do
        exec('ue_testmode_set_nr testmode=rlf action=activate profile_id=1 id='..ue_id)
    end

    exec('sleep 3')

    for ue_id = 1,ues do
        exec('ue_measurement_send_nr meas_id=3 event=B2 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17 id='..ue_id)
    end

    exec('sleep 2')

    for ue_id = 1,ues do
        --exec('ue_kill id='..ue_id)
        exec('ue_testmode_set_nr testmode=rlf action=deactivate profile_id=1 id='..ue_id)
        exec('ue_deregister by=ue ue_deregister_type=switch_off id='..ue_id)
    end

    exec('rlf_testmode_nr profile_id=1 delete=yes')

    exec('sleep 3')
    exec('ue_disp')
    exec('sleep 3')

    exec('set_log flush')
end
