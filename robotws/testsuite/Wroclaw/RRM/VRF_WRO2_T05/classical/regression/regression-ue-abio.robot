*** Settings ***
Documentation    Suite description

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/5GC002060.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/CB008662-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/resources/5GC002060keysFDD.robot
#Resource        testsuite/RRM/Wroclaw/5GC002015/resources/keywords_2015.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000545/545-B.robot


Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CIT
...             CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1_3xAHLOA_ENB

Suite Setup     Run keywords
...             Prepare and check TL   AND
# ...             UE Reboot Before Test   AND
...             Setup attenuators   AND
...             Set initial attenuation

Test Setup      Run keywords
# ...             Require Ue    UE_1    capabilities=REAL_ANDROID_UE_NSA  AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA_MTK  AND
# ...             Require Ue    UE_3    capabilities=REAL_ANDROID_UE_NSA_MTK  AND
...             Run Keyword and Ignore Error   Start syslog collection  AND
...             Connect to Coam   AND
...             Get SCF   AND
...             Set global variable bts id    AND
...             Get number of cells and set ID  AND
...             Get Resource Usage before test  AND
...             Watch alarms

Test Teardown   Run Keywords
...             Sleeping cell test    AND
...             keywords.Collect Snapshot  AND
...             Run keyword and ignore error    Delete active DCAP trace for BTS  AND
...             Run Keyword and Ignore Error    Get Resource Usage after test  AND
...             Run Keyword and Ignore Error    Stop syslog collection  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Verify Crash occurrence In Syslog  AND
...             Stop watching alarms    AND
...             Disconnect coam

*** Test Cases ***
# [1]Transform_Precoder_activation_64QAM_SA_UE_DSS_enabled
#     [Tags]   SBTS23R4
#     [1]Transform_Precoder_activation_64QAM_SA_UE

[1]Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    ...      CDRT
    [1]Successul_SA_UE_handover_between_Transform_Precoder_capable_and_non-capable_cells

[1]Dynamic Transform Precoder Switching_NSA_UE_DCI_0_1_ 20MHz_SRB3_TCP_Open_Loop_MIMO
    [Tags]   SBTS00
    ...      SBTS23R4
    ...      CDRT
    [1]Dynamic Transform Precoder Switching_NSA_UE_DCI_0_1_ 20MHz_SRB3_TCP_Open_Loop_MIMO

# [1]5GC002060_A_2_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle160_LowBurstyDLTraffic
#     [Tags]   SBTS23R4
#     [1]5GC002060_A_2_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle160_LowBurstyDLTraffic_Counters

# [1]5GC002060_A_12_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle640_LowBurstyDLTraffic
#     [Tags]   SBTS23R1
#     [1]5GC002060_A_12_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle640_LowBurstyDLTraffic_Counters
#
# [1]5GC002060_A_7_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle320_LowBurstyDLTraffic
#     [Tags]   SBTS23R1
#     [1]5GC002060_A_7_NSA-classical-cmw-FDD_StaticCall_DrxLongCycle320_LowBurstyDLTraffic_Counters

[1]CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI
    [Tags]   SBTS24R1
    ...      SBTS23R4
    [1]CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI

# [1]CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm
#     [Tags]   SBTS23R4
#     [1]CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm

[1]CB008662-A_8_A#B6_Interworking_with_Carrier_Aggregation
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    ...      SBTS23R4
    [1]CB008662-A_8_A#B6_Interworking_with_Carrier_Aggregation
