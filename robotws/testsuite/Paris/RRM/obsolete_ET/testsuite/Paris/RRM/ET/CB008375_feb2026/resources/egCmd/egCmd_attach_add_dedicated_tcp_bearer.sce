
ue_register id=51
sleep 2
set_pdu_param ue=51 pdu=3 trf_type=external 
sleep 2
ue_pdu_session_setup ue=51 pdu=3  gw=3 nwslice=1
sleep 2

#Add 1 deidcated TCP bearers for UE51
ue_pdu_session_modify ue=51 pdu=3 qosflows_to_add=4 by=amf
sleep 2

sim_log_set flush
exit