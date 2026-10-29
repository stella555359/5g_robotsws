function ue_register_TDD()
    --cell1 TDD SA non-GBR calls
    start_nGBRue=1
    end_nGBRue=8
    for i = start_nGBRue, end_nGBRue do
        exec('ue_register id='..i..'')
        sleep(1)
        exec('set_pdu_param ue='..i..' pdu=1 trf_type=internal')
        sleep(1)
        exec('ue_pdu_session_setup ue='..i..' pdu=1 nwslice=1 gw='..i..'')
        sleep(1)
        exec('trf_data_start ue='..i..' pdu=1 qfi=1 dir=dl mbps=100')
        sleep(1)
        exec('trf_data_start ue='..i..' pdu=1 qfi=1 dir=ul mbps=50')
        sleep(1)
    end
end
function sim_log_set_flush()
    exec('sim_log_set flush')
end

