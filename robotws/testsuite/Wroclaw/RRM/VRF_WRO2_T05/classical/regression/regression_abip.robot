*** Settings ***
Documentation    Suite description

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/5GC000900-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/5GC002060.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/5GC001348-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-A.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/5GC002534-B.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002060/resources/5GC002060keysFDD.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/5GC002015-C.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/CB008662-AD.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/CB008662-ABIP.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000545/545-B_ASIM.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/resources/keywords_2015.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5G_CRT    RAN_5GSC_CRT
...             CLOUD_5G_CLASSICAL_QC_ASIML_ABIPB1_1xAHFIB_ENB



Suite Setup     Run keywords
...             Prepare and check TL   AND
...             Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2   AND
...             Setup attenuators   AND
...             Set initial attenuation

Test Setup      Run keywords
...             Run Keyword and Ignore Error   Start syslog collection  AND
# ...             UE Reboot Before Test   AND
...             Connect to Coam   AND
...             Get SCF   AND
...             Set global variable bts id    AND
...             Get number of cells and set ID

Test Teardown   Run Keywords
...             Sleeping cell test    AND
...             Run Keyword and Ignore Error  Make snapshot in case of error    AND
...             Run Keyword and Ignore Error   Stop syslog collection  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
# ...             Run Keyword and Ignore Error   Verify Crash occurrence In Syslog  AND
...             Disconnect coam

*** Test Cases ***
[1]CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI_ABIP
    [Tags]    SBTS00
    [1]CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI_ABIP

[1]CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm_ABIP
    [Tags]   SBTS00
    [1]CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm_ABIP

[1]CB008662-A_8_A#B6_Interworking_with_Carrier_Aggregation_ABIP
    [Tags]   SBTS00
    [1]CB008662-A_8_A#B6_Interworking_with_Carrier_Aggregation_ABIP

[1]Transform_Precoder_activation_64QAM_SA_UE_ASIM
    [1]Transform_Precoder_activation_64QAM_SA_UE_ASIM
