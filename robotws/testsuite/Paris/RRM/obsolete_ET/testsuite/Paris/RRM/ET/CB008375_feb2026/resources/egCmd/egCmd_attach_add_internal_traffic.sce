
ue_register id=1
sleep 2
set_pdu_param ue=1 pdu=1 trf_type=internal 
sleep 2
ue_pdu_session_setup ue=1 pdu=1  gw=1 nwslice=1
sleep 2



ue_register id=2
sleep 2
set_pdu_param ue=2 pdu=2 trf_type=internal 
sleep 2
ue_pdu_session_setup ue=2 pdu=2  gw=2 nwslice=1
sleep 2


ue_register id=3
sleep 2
set_pdu_param ue=3 pdu=3 trf_type=internal 
sleep 2
ue_pdu_session_setup ue=3 pdu=3  gw=3 nwslice=1
sleep 2


ue_register id=4
sleep 2
set_pdu_param ue=4 pdu=4 trf_type=internal 
sleep 2
ue_pdu_session_setup ue=4 pdu=4  gw=4 nwslice=1
sleep 2


#Add  1.4Gbps of traffic
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=2 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=3 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=4 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=5 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=6 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=7 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=8 mbps=175 dir=dl
sleep 2

trf_data_start ue=1 pdu=1 qfi=1 trf_id=9 mbps=175 dir=dl
sleep 2





#Add  1.4Gbps of traffic
trf_data_start ue=2 pdu=2 qfi=1 trf_id=1 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=2 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=3 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=4 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=5 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=6 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=7 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=8 mbps=175 dir=dl
sleep 2

trf_data_start ue=2 pdu=2 qfi=1 trf_id=9 mbps=175 dir=dl
sleep 2


#Add  1.4Gbps of traffic
trf_data_start ue=3 pdu=3 qfi=1 trf_id=1 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=2 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=3 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=4 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=5 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=6 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=7 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=8 mbps=175 dir=dl
sleep 2

trf_data_start ue=3 pdu=3 qfi=1 trf_id=9 mbps=175 dir=dl
sleep 2


#Add  1.4Gbps of traffic
trf_data_start ue=4 pdu=4 qfi=1 trf_id=1 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=2 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=3 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=4 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=5 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=6 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=7 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=8 mbps=175 dir=dl
sleep 2

trf_data_start ue=4 pdu=4 qfi=1 trf_id=9 mbps=175 dir=dl
sleep 2





sim_log_set flush
exit