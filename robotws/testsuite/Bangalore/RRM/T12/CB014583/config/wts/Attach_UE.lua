start_nGBRue=1
end_nGBRue=24
for i = start_nGBRue, end_nGBRue do
    exec('ue_register id='..i..'')
    sleep(5)
    exec('set_pdu_param ue='..i..' pdu=1 trf_type=internal')
    sleep(1)
    exec('ue_pdu_session_setup ue='..i..' pdu=1 nwslice=1 gw='..i..'')
    sleep(5)
    exec('trf_data_start ue='..i..' pdu=1 qfi=1 trf_id=1 mbps=10 dir=dl')
    sleep(2)
    exec('trf_data_start ue='..i..' pdu=1 qfi=1 trf_id=2 mbps=5 dir=ul')
    sleep(2)
end
