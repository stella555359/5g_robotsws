start_ue_set1=1
end_ue_set1=8
for i = start_ue_set1, end_ue_set1 do
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
start_ue_set2=21
end_ue_set2=28
for i = start_ue_set2, end_ue_set2 do
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
start_ue_set3=31
end_ue_set3=38
for i = start_ue_set3, end_ue_set3 do
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
start_ue_set4=41
end_ue_set4=48
for i = start_ue_set4, end_ue_set4 do
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
