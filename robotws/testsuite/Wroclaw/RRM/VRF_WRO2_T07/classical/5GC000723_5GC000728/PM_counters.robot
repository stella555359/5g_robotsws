*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...   This is the TESTSUITE file for 5GC000723 PM counters


Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   CRT   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB
...           PY36

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Resource    ./resources/keywords_PM.robot

Suite Setup     Run Keywords
...             Prepare Testline                                                AND
...             Setup preconditions                                             AND
...             Require Ue   UE_1   capabilities=REAL_UE_SA                     AND
...             start_btslog_on_local_machine                                   AND
...             TcpdumpSmod.start_tcpdump_on_smod    filename=PMCounters    smod_master=${true}    smod_slave=${tl.smod_slave}        AND
...             Attach Ue    UE_1                                               AND
...             Wait till UE will entered IDLE state                            AND
...             Connection attempt with DL traffic                              AND
...             Wait till UE will entered IDLE state                            AND
...             Connection attempt with UL traffic                              AND
...             Wait till UE will entered IDLE state                            AND
# ...             Connection attempt with cause Emergency Access                  AND
# ...             Detach Ue    UE_1                                               AND
# ...             Attach UE using high prio access cell search                    AND
# ...             Wait till UE will entered IDLE state                            AND
# ...             Connection attempt with cause High Priority Access              AND
...             Run keyword and ignore error   Detach Ue    UE_1                AND
...             TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod            AND
...             Sleep  22m  reason=wait for the counters to gather


Suite Teardown    Run keywords
...               TcpdumpSmod.teardown_tcpdump_on_smod      AND
...               stop_and_collect_btslog


*** Test Cases ***
[1]5GC000723_F_4_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Signaling_PM_Counter_M55124C01001
    [1]5GC000723_F_4_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Signaling_PM_Counter_M55124C01001


[1]5GC000723_F_5_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Data_PM_Counter_M55124C01002
    [1]5GC000723_F_5_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Data_PM_Counter_M55124C01002


[1]5GC000723_F_6_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Terminated_Access_PM_Counter_M55124C01003
    [1]5GC000723_F_6_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Terminated_Access_PM_Counter_M55124C01003


# [1]5GC000723_F_7_Number_of_RRC_CONNECTION_Attempts_for_Emergency_PM_Counter_M55124C01004
#     [1]5GC000723_F_7_Number_of_RRC_CONNECTION_Attempts_for_Emergency_PM_Counter_M55124C01004


# [1]5GC000723_F_8_Number_of_RRC_CONNECTION_Attempts_for_highPriorityAccess_PM_Counter_M55124C01005
#     [1]5GC000723_F_8_Number_of_RRC_CONNECTION_Attempts_for_highPriorityAccess_PM_Counter_M55124C01005


[1]5GC000723_F_9_Number_of_INITIAL_UE_MESSAGE_sent_PM_Counter_M55125C00001
    [1]5GC000723_F_9_Number_of_INITIAL_UE_MESSAGE_sent_PM_Counter_M55125C00001


[1]5GC000723_F_10_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Signaling_PM_Counter_M55127C00001
    [1]5GC000723_F_10_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Signaling_PM_Counter_M55127C00001


[1]5GC000723_F_11_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Data_PM_Counter_M55127C00002
    [1]5GC000723_F_11_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Originated_Data_PM_Counter_M55127C00002


[1]5GC000723_F_12_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Terminated_Access_PM_Counter_M55127C00003
    [1]5GC000723_F_12_Number_of_RRC_CONNECTION_Attempts_for_Mobile_Terminated_Access_PM_Counter_M55127C00003


# [1]5GC000723_F_13_Number_of_RRC_CONNECTION_Attempts_for_Emergency_PM_Counter_M55127C00004
#     [1]5GC000723_F_13_Number_of_RRC_CONNECTION_Attempts_for_Emergency_PM_Counter_M55127C00004


# [1]5GC000723_F_14_Number_of_RRC_CONNECTION_Attempts_for_highPriorityAccess_PM_Counter_M55127C00005
#     [1]5GC000723_F_14_Number_of_RRC_CONNECTION_Attempts_for_highPriorityAccess_PM_Counter_M55127C00005


[1]5GC000723_F_15_DL_MAC_SDU_volume_transmitted_on_CCCH_for_SRB0_PM_Counter_M55309C03001
    [1]5GC000723_F_15_DL_MAC_SDU_volume_transmitted_on_CCCH_for_SRB0_PM_Counter_M55309C03001


[1]5GC000723_F_16_UL_MAC_SDU_volume_received_on_CCCH_for_SRB0_PM_Counter_M55309C05001
    [1]5GC000723_F_16_UL_MAC_SDU_volume_received_on_CCCH_for_SRB0_PM_Counter_M55309C05001


[1]5GC000723_F_17_DL_MAC_SDUs_transmitted_on_CCCH_for_SRB0_PM_Counter_M55309C07001
    [1]5GC000723_F_17_DL_MAC_SDUs_transmitted_on_CCCH_for_SRB0_PM_Counter_M55309C07001


[1]5GC000723_F_18_UL_MAC_SDUs_receiveded_on_CCCH_for_SRB0_PM_Counter_M55309C09001
    [1]5GC000723_F_18_UL_MAC_SDUs_receiveded_on_CCCH_for_SRB0_PM_Counter_M55309C09001


[1]5GC000728_AF_6_Number_of_Ue_Context_Release_Command_sent_PMConter_M55113C01009
    [1]5GC000728_AF_6_Number_of_Ue_Context_Release_Command_sent_PMConter_M55113C01009


[1]5GC000728_AF_7_Number_of_Ue_Context_Release_Complete_received_PMConter_M55113C01010
    [1]5GC000728_AF_7_Number_of_Ue_Context_Release_Complete_received_PMConter_M55113C01010


[1]5GC000728_AF_8_Number_of_Ue_Context_Release_Command_received_PMConter_M55117C01009
    [1]5GC000728_AF_8_Number_of_Ue_Context_Release_Command_received_PMConter_M55117C01009


[1]5GC000728_AF_9_Number_of_Ue_Context_Release_Complete_sent_PMConter_M55117C01010
    [1]5GC000728_AF_9_Number_of_Ue_Context_Release_Complete_sent_PMConter_M55117C01010


[1]5GC000728_AF_10_Number_of__RRC_RELEASE_Messages_sent_PMConter_M55124C00001
    [1]5GC000728_AF_10_Number_of__RRC_RELEASE_Messages_sent_PMConter_M55124C00001


[1]5GC000728_AF_11_Number_of__UE_CONTEXT_RELEASE_COMMAND_received_PMConter_M55125C00501
    [1]5GC000728_AF_11_Number_of__UE_CONTEXT_RELEASE_COMMAND_received_PMConter_M55125C00501


[1]5GC000728_AF_12_Number_of__UE_CONTEXT_RELEASE_COMPLETE_sent_PMConter_M55125C00502
    [1]5GC000728_AF_12_Number_of__UE_CONTEXT_RELEASE_COMPLETE_sent_PMConter_M55125C00502


[1]5GC000728_AF_13_Number_of__RRC_RELEASE_Messages_sent_PMConter_M55127C01001
    [1]5GC000728_AF_13_Number_of__RRC_RELEASE_Messages_sent_PMConter_M55127C01001


[1]5GC000728_AF_14_Number_of__BEARER_CONTEXT_RELEASE_COMMAND_received_PMConter_M55133C00001
    [1]5GC000728_AF_14_Number_of__BEARER_CONTEXT_RELEASE_COMMAND_received_PMConter_M55133C00001


[1]5GC000728_AF_15_Number_of__BEARER_CONTEXT_RELEASE_COMPLETE_sent_PMConter_M55133C00002
    [1]5GC000728_AF_15_Number_of__BEARER_CONTEXT_RELEASE_COMPLETE_sent_PMConter_M55133C00002


[1]5GC000728_AF_16_Number_of__BEARER_CONTEXT_RELEASE_COMMAND_sent_PMConter_M55135C00001
    [1]5GC000728_AF_16_Number_of__BEARER_CONTEXT_RELEASE_COMMAND_sent_PMConter_M55135C00001


[1]5GC000728_AF_17_Number_of__BEARER_CONTEXT_RELEASE_COMPLETE_received_PMConter_M55135C00002
    [1]5GC000728_AF_17_Number_of__BEARER_CONTEXT_RELEASE_COMPLETE_received_PMConter_M55135C00002


[1]5GC000728_B_6_Number_of__gNB_Initiated_UE_Context_Release_triggered_due_to_Inactivity_PMConter_M55125C00503
    [1]5GC000728_B_6_Number_of__gNB_Initiated_UE_Context_Release_triggered_due_to_Inactivity_PMConter_M55125C00503
