trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=60
sleep_script 1

trf_data_start ue=2 pdu=2 qfi=1 dir=ul trf_id=1 mbps=60
sleep_script 1

trf_data_start ue=3 pdu=3 qfi=1 dir=ul trf_id=1 mbps=60
sleep_script 1                                       
													 
trf_data_start ue=4 pdu=4 qfi=1 dir=ul trf_id=1 mbps=60
sleep_script 1    

ue_stats_nr id=1-4 type=pusch
sleep_script 1                                   

trf_data_start ue=31 pdu=1 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=32 pdu=2 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=33 pdu=3 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=34 pdu=4 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

ue_stats_nr id=31-34 type=pusch
sleep_script 1

trf_data_start ue=35 pdu=5 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=36 pdu=6 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=37 pdu=7 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=38 pdu=8 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=39 pdu=9 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=61 pdu=1 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1

trf_data_start ue=62 pdu=2 qfi=1 dir=ul trf_id=1 mbps=10
sleep_script 1

trf_data_start ue=63 pdu=3 qfi=1 dir=ul trf_id=1 mbps=100
sleep_script 1                                       
													 
trf_data_start ue=64 pdu=4 qfi=1 dir=ul trf_id=1 mbps=10
sleep_script 1

ue_stats_nr id=61-64 type=pusch
sleep_script 5

ue_stats_nr id=1-4 type=pusch
sleep_script 1

