*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...   This is the TESTSUITE file for feature 5GC000728


Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           PY36

Resource        ./resources/keywords_728.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/swconfig.py

Suite Setup     prepare_swconfig

Test Setup      start_btslog_on_local_machine

Test Teardown   TC_teardown_728


*** Test Cases ***
[1]5GC000728_AF_2_20MHz_FDD_SA_Classical_UE_detach_Network_initiated_without_Traffic
    [Documentation]   The purpose of this test is to confirm succesful UE state change from RRC-Connected to
    ...               RRC-Idle triggered by AMF. Signaling Radio Bearers and UE contexts will no longer be alocated in gNB
    [1]5GC000728_AF_2_20MHz_FDD_SA_Classical_UE_detach_Network_initiated_without_Traffic


[1]5GC000728_AF_5_15MHz_FDD_SA_Classical_UE_Reattach_Ue_initiated_without_Traffic
    [Documentation]   The purpose of this test is to confirm successful reattach after UE state change from
    ...               RRC-Connected to RRC-Idle triggered by UE
    [1]5GC000728_AF_5_15MHz_FDD_SA_Classical_UE_Reattach_Ue_initiated_without_Traffic


[1]5GC000728_B_2_20MHz_FDD_SA_Classical_UE_Activity_not_active_Without_Traffic
    [1]5GC000728_B_2_20MHz_FDD_SA_Classical_UE_Activity_not_active_Without_Traffic


[1]5GC000728_B_3_10MHz_FDD_SA_Classical_UE_Activity_Active_With_Traffic
    [1]5GC000728_B_3_10MHz_FDD_SA_Classical_UE_Activity_Active_With_Traffic
