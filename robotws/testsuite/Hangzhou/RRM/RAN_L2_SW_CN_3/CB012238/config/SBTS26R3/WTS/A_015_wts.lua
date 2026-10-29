exec('ue_register id=1')
exec('set_pdu_param ue=1 pdu=1 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('set_pdu_param ue=1 pdu=2 default_qos_flow=2 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=1 nwslice=1 ue=1')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=2 nwslice=2 ue=1')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=1 pdu=1 trf_id=1 dir=ul mbps=50')
exec('trf_data_start ue=1 pdu=1 trf_id=1 dir=dl mbps=170')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=1 pdu=2 trf_id=1 dir=ul mbps=50')
exec('trf_data_start ue=1 pdu=2 trf_id=1 dir=dl mbps=170')

exec('ue_register id=2')
exec('set_pdu_param ue=2 pdu=1 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('set_pdu_param ue=2 pdu=2 default_qos_flow=2 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=1 nwslice=1 ue=2')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=2 nwslice=2 ue=2')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=2 pdu=1 trf_id=1 dir=ul kbps=100')
exec('trf_data_start ue=2 pdu=1 trf_id=1 dir=dl kbps=100')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=2 pdu=2 trf_id=1 dir=ul kbps=100')
exec('trf_data_start ue=2 pdu=2 trf_id=1 dir=dl kbps=100')

exec('ue_register id=3')
exec('set_pdu_param ue=3 pdu=1 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('set_pdu_param ue=3 pdu=2 default_qos_flow=3 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=1 nwslice=1 ue=3')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=2 nwslice=2 ue=3')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=3 pdu=1 trf_id=1 dir=ul mbps=50')
exec('trf_data_start ue=3 pdu=1 trf_id=1 dir=dl mbps=170')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=3 pdu=2 trf_id=1 dir=ul mbps=50')
exec('trf_data_start ue=3 pdu=2 trf_id=1 dir=dl mbps=170')

exec('ue_register id=4')
exec('set_pdu_param ue=4 pdu=1 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('set_pdu_param ue=4 pdu=2 default_qos_flow=3 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=1 nwslice=1 ue=4')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=2 nwslice=2 ue=4')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=4 pdu=1 trf_id=1 dir=ul kbps=100')
exec('trf_data_start ue=4 pdu=1 trf_id=1 dir=dl kbps=100')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=4 pdu=2 trf_id=1 dir=ul kbps=100')
exec('trf_data_start ue=4 pdu=2 trf_id=1 dir=dl kbps=100')

exec('ue_register id=5')
exec('set_pdu_param ue=5 pdu=1 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('set_pdu_param ue=5 pdu=2 default_qos_flow=5 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=1 nwslice=1 ue=5')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=2 nwslice=3 ue=5')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=5 pdu=1 trf_id=1 dir=ul mbps=50')
exec('trf_data_start ue=5 pdu=1 trf_id=1 dir=dl mbps=170')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=5 pdu=2 trf_id=1 dir=ul mbps=50')
exec('trf_data_start ue=5 pdu=2 trf_id=1 dir=dl mbps=170')

exec('ue_register id=6')
exec('set_pdu_param ue=6 pdu=1 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('set_pdu_param ue=6 pdu=2 default_qos_flow=5 trf_type=internal')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=1 nwslice=1 ue=6')
exec('sleep 1') --For 2 Hrs
exec('ue_pdu_session_setup pdu=2 nwslice=3 ue=6')
--exec('sleep 1') --For 2 Hrs
--exec('trf_data_start ue=6 pdu=1 trf_id=1 dir=ul mbps=50')
--exec('trf_data_start ue=6 pdu=1 trf_id=1 dir=dl mbps=130')
exec('sleep 1') --For 2 Hrs
exec('trf_data_start ue=6 pdu=2 trf_id=1 dir=ul kbps=100')
exec('trf_data_start ue=6 pdu=2 trf_id=1 dir=dl kbps=100')
