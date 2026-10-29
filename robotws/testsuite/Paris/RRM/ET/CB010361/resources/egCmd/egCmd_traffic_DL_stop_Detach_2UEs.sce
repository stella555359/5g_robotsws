#Goal of this Test case:
#STOP DL Data Traffic
#DE-Register in SA mode two UEs

trf_data_stop ue=1 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=2 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=3 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=4 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=5 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=6 dir=dl

trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=2 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=3 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=4 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=5 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=6 dir=dl

sleep_script 1
ue_deregister id=1 by=ue ue_deregister_type=switch_off
sleep_script 1
ue_deregister id=2 by=ue ue_deregister_type=switch_off
sleep_script 1
