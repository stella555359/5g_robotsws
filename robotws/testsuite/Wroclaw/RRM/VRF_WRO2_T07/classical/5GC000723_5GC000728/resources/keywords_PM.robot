*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...   This is the ROBOT KEYWORDS file for 5GC000723 PM counters

Library         taf.ue
Library         testsuite/Wroclaw/RRM/resources/pm_counters.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000723_5GC000728/resources/common_keywords.robot


*** Variables ***
${trafic_duration}   65s
${throughput}        10Mbits/sec

# those counters need to be checked in another test
${723_f4_counter_val}                       None
${723_f5_counter_val}                       None
${723_f6_counter_val}                       None
${723_f7_counter_val}                       None
${723_f8_counter_val}                       None


*** Keywords ***
[1]5GC000723_F_4_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Signaling_PM_Counter_M55124C01001
    ${value}=  get_sum_of_counter_values    M55124C01001   reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    Set suite variable    ${723_f4_counter_val}   ${filtered}
    should be true  ${filtered} > 0


[1]5GC000723_F_5_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Data_PM_Counter_M55124C01002
    ${value}=  get_sum_of_counter_values    M55124C01002    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    Set suite variable    ${723_f5_counter_val}   ${filtered}
    should be true  ${filtered} > 0


[1]5GC000723_F_6_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Terminated_Access_PM_Counter_M55124C01003
    ${value}=  get_sum_of_counter_values    M55124C01003    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    Set suite variable    ${723_f6_counter_val}   ${filtered}
    should be true  ${filtered} > 0


[1]5GC000723_F_7_Number_of_RRC_CONNECTION_Attempts_for_Emergency_PM_Counter_M55124C01004
    ${value}=  get_sum_of_counter_values    M55124C01004    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    Set suite variable    ${723_f7_counter_val}   ${filtered}
    should be true  ${filtered} > 0


[1]5GC000723_F_8_Number_of_RRC_CONNECTION_Attempts_for_highPriorityAccess_PM_Counter_M55124C01005
    ${value}=  get_sum_of_counter_values    M55124C01005    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    Set suite variable    ${723_f8_counter_val}   ${filtered}
    should be true  ${filtered} > 0


[1]5GC000723_F_9_Number_of_INITIAL_UE_MESSAGE_sent_PM_Counter_M55125C00001
    ${value}=  get_sum_of_counter_values    M55125C00001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000723_F_10_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Signaling_PM_Counter_M55127C00001
    ${value}=  get_sum_of_counter_values    M55127C00001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0
    should be true  ${filtered} == ${723_f4_counter_val}


[1]5GC000723_F_11_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Data_PM_Counter_M55127C00002
    ${value}=  get_sum_of_counter_values    M55127C00002    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0
    should be true  ${filtered} == ${723_f5_counter_val}


[1]5GC000723_F_12_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Terminated_Access_PM_Counter_M55127C00003
    ${value}=  get_sum_of_counter_values    M55127C00003    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0
    should be true  ${filtered} == ${723_f6_counter_val}


[1]5GC000723_F_13_Number_of_RRC_CONNECTION_Attempts_for_Emergency_PM_Counter_M55127C00004
    ${value}=  get_sum_of_counter_values    M55127C00004    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0
    should be true  ${filtered} == ${723_f7_counter_val}


[1]5GC000723_F_14_Number_of_RRC_CONNECTION_Attempts_for_highPriorityAccess_PM_Counter_M55127C00005
    ${value}=  get_sum_of_counter_values    M55127C00005    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0
    should be true  ${filtered} == ${723_f8_counter_val}


[1]5GC000723_F_15_DL_MAC_SDU_volume_transmitted_on_CCCH_for_SRB0_PM_Counter_M55309C03001
    ${value}=  get_sum_of_counter_values    M55309C03001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000723_F_16_UL_MAC_SDU_volume_received_on_CCCH_for_SRB0_PM_Counter_M55309C05001
    ${value}=  get_sum_of_counter_values    M55309C05001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000723_F_17_DL_MAC_SDUs_transmitted_on_CCCH_for_SRB0_PM_Counter_M55309C07001
    ${value}=  get_sum_of_counter_values    M55309C07001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000723_F_18_UL_MAC_SDUs_receiveded_on_CCCH_for_SRB0_PM_Counter_M55309C09001
    ${value}=  get_sum_of_counter_values    M55309C09001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_6_Number_of_Ue_Context_Release_Command_sent_PMConter_M55113C01009
    ${value}=  get_sum_of_counter_values    M55113C01009    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_7_Number_of_Ue_Context_Release_Complete_received_PMConter_M55113C01010
    ${value}=  get_sum_of_counter_values    M55113C01010    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_8_Number_of_Ue_Context_Release_Command_received_PMConter_M55117C01009
    ${value}=  get_sum_of_counter_values    M55117C01009    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_9_Number_of_Ue_Context_Release_Complete_sent_PMConter_M55117C01010
    ${value}=  get_sum_of_counter_values    M55117C01010    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_10_Number_of__RRC_RELEASE_Messages_sent_PMConter_M55124C00001
    ${value}=  get_sum_of_counter_values    M55124C00001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_11_Number_of__UE_CONTEXT_RELEASE_COMMAND_received_PMConter_M55125C00501
    ${value}=  get_sum_of_counter_values    M55125C00501    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_12_Number_of__UE_CONTEXT_RELEASE_COMPLETE_sent_PMConter_M55125C00502
    ${value}=  get_sum_of_counter_values    M55125C00502    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_13_Number_of__RRC_RELEASE_Messages_sent_PMConter_M55127C01001
    ${value}=  get_sum_of_counter_values    M55127C01001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_14_Number_of__BEARER_CONTEXT_RELEASE_COMMAND_received_PMConter_M55133C00001
    ${value}=  get_sum_of_counter_values    M55133C00001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_15_Number_of__BEARER_CONTEXT_RELEASE_COMPLETE_sent_PMConter_M55133C00002
    ${value}=  get_sum_of_counter_values    M55133C00002    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_16_Number_of__BEARER_CONTEXT_RELEASE_COMMAND_sent_PMConter_M55135C00001
    ${value}=  get_sum_of_counter_values    M55135C00001    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_AF_17_Number_of__BEARER_CONTEXT_RELEASE_COMPLETE_received_PMConter_M55135C00002
    ${value}=     get_sum_of_counter_values    M55135C00002    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


[1]5GC000728_B_6_Number_of__gNB_Initiated_UE_Context_Release_triggered_due_to_Inactivity_PMConter_M55125C00503
    ${value}=     get_sum_of_counter_values     M55125C00503    reload_counters=${FALSE}
    ${filtered}=  get_value_from_active_cell   ${value}
    should be true  ${filtered} > 0


Setup preconditions
    Setup and check preconditions in scf   ${scf_params_pm_counters}    skip_parameter_relation_errors=True
    Assign inactivity timer
    Set suite variable                     ${test_name}   PM_counters


Attach UE using high prio access cell search
    Log   TBD
#    ${rc_config_script_high_priority_access}=   make_high_prio_access_rc_config   ${rc_config_script}
#    ${ue_ip}=   Prepare VIAVI and Attach Ues    rc_config=${rc_config_script_high_priority_access}
#    Set suite variable   ${ue_ip}   ${ue_ip}


Connection attempt with cause High Priority Access
    Log   TBD
#    Start tcpdump on CU   filename=${filename}
#    Send command to viavi   FORW MTE NRNASTRIGGERSERVICEREQUEST 1 5 []
#    Send command to viavi   FORW MTE Activate -1
#    BuiltIn.Sleep   5
#    Stop tcpdump on CU and download logs  filename=${filename}


Connection attempt with cause Emergency Access
    Log   Starting Voice Call
    Run keyword and ignore error  Start Voice Call   emergency   UE_1   112
    BuiltIn.Sleep   20
    Run keyword and ignore error  Stop Voice Call       vc_alias=emergency


Connection attempt with UL traffic
    Start Data Transfer   dt_name=DT_UL              ue_alias=UE_1
    ...                   direction=ul               duration=${trafic_duration}
    ...                   throughput=${throughput}   protocol=udp
    BuiltIn.Sleep   70s   reason=data transfer
    # Await Data Transfer Finish     DT_UL


Connection attempt with DL traffic
    Start Data Transfer   dt_name=DT_DL              ue_alias=UE_1
    ...                   direction=dl               duration=${trafic_duration}
    ...                   throughput=${throughput}   protocol=udp
    BuiltIn.Sleep   70s   reason=data transfer
    # Await Data Transfer Finish     DT_DL
